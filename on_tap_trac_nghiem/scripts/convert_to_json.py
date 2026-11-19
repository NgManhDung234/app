import json
import re
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

QUESTIONS_DOCX = Path("scripts/input/bo_300_cau_hoi.docx")
ANSWERS_DOCX = Path("scripts/input/dap_an_chi_tiet.docx")
OUTPUT_JSON = Path("assets/data/questions.json")

TIER_MAP = {
    range(1, 4): "Tầng 1: Nền tảng",
    range(4, 12): "Tầng 2: Giao diện người dùng",
    range(12, 16): "Tầng 3: Dữ liệu & Kiến trúc",
    range(16, 19): "Tầng 4: Kỹ nghệ chuyên nghiệp",
    range(19, 21): "Tầng 5: AI & Tích hợp thông minh",
}

Q_HEADER_RE = re.compile(
    r"^Câu\s+(\d+)\.\s*(.+?)\s*\[(K\d{2})\s*[-\u2010-\u2015\u2212]\s*(\d{3})\s*[^\w\]]+\s*(Nhớ|Hiểu|Vận dụng)\]\s*$",
    re.DOTALL,
)
EN_HEADER_RE = re.compile(r"^Question\s+\d+\.\s*(.+)$", re.DOTALL)
ANS_HEADER_RE = re.compile(
    r"^Câu\s+\d+\s*\((K\d{2})\s*[-\u2010-\u2015\u2212]\s*(\d{3})\).*?(?:Đáp án|Answer)\s*[:\-]?\s*([A-D])\b"
)


def p_to_text(p_elem: ET.Element) -> str:
    """Chuyển 1 thẻ <w:p> thành chuỗi, giữ nguyên xuống dòng (<w:br/>) và tab."""
    chunks = []
    for node in p_elem.iter():
        tag = node.tag.rsplit("}", 1)[-1]
        if tag == "t" and node.text:
            chunks.append(node.text)
        elif tag == "br":
            chunks.append("\n")
        elif tag == "tab":
            chunks.append("    ")
    return "".join(chunks)


def extract_paragraphs(doc_path: Path) -> list[dict]:
    with zipfile.ZipFile(doc_path) as z:
        root = ET.fromstring(z.read("word/document.xml"))

    body = root.find("{*}body")
    items = []
    for elem in body:
        tag = elem.tag.rsplit("}", 1)[-1]
        if tag == "p":
            text = p_to_text(elem).strip()
            if text:
                items.append({"text": text, "in_table": False})
        elif tag == "tbl":
            for tr in elem.findall(".//{*}tr"):
                tcs = tr.findall(".//{*}tc")
                if len(tcs) == 1:
                    code_lines = [p_to_text(p).rstrip() for p in tcs[0].findall(".//{*}p")]
                    code_text = "\n".join(l for l in code_lines if l.strip())
                    if code_text:
                        items.append({"text": code_text, "in_table": True})
                else:
                    cells = [" ".join(p_to_text(tc).split()) for tc in tcs]
                    cells = [c for c in cells if c]
                    if cells:
                        items.append({"text": " | ".join(cells), "in_table": True})
    return items


def parse_answers(items: list[dict]) -> tuple[dict, dict]:
    answers, blocks = {}, {}
    qid, buf = None, []

    def flush():
        if not qid or not buf:
            return
        ans_letter = buf[0]
        url = ""
        exps = []
        for line in buf[1:]:
            u = re.search(r"(https?://\S+)", line)
            if u:
                url = u.group(1).rstrip(".,)")
            elif not line.lower().startswith(("nguồn", "source")):
                exps.append(line)

        answers[qid] = {
            "correctAnswer": ans_letter,
            "explanation": {
                "vi": exps[0] if exps else "",
                "en": exps[1] if len(exps) > 1 else (exps[0] if exps else ""),
            },
            "referenceUrl": url,
        }

    for item in items:
        line = item["text"]
        b = re.match(r"^Khối\s+(\d{1,2})\.\s*(.+)$", line)
        if b:
            bid = f"K{int(b.group(1)):02d}"
            blocks[bid] = f"{bid}: {b.group(2).strip()}"
            continue

        m = ANS_HEADER_RE.match(line)
        if m:
            flush()
            qid = f"{m.group(1).upper()}-{m.group(2)}"
            buf = [m.group(3).upper()]
        elif qid:
            buf.append(line)

    flush()
    return answers, blocks


def parse_questions(items: list[dict], ans_map: dict, block_map: dict) -> tuple[list[dict], dict]:
    questions = []
    quick_key = {}
    section = "INTRO"  # INTRO -> PART1 -> PART2
    cur = None

    def flush():
        if not cur:
            return
        options = []
        for k in ("A", "B", "C", "D"):
            lines = cur["opts"].get(k, [""])
            vi = lines[0]
            en = lines[1] if len(lines) > 1 else vi
            options.append({"key": k, "text": {"vi": vi, "en": en}})

        qid = cur["id"]
        ans = ans_map.get(qid, {"correctAnswer": "A", "explanation": {"vi": "", "en": ""}, "referenceUrl": ""})
        questions.append({
            "id": qid,
            "number": cur["number"],
            "tier": cur["tier"],
            "blockId": cur["blockId"],
            "blockName": cur["blockName"],
            "difficulty": cur["difficulty"],
            "question": {"vi": cur["vi"], "en": cur["en"] or cur["vi"]},
            "codeSnippet": "\n".join(cur["code"]).strip(),
            "options": options,
            "correctAnswer": ans["correctAnswer"],
            "explanation": ans["explanation"],
            "referenceUrl": ans["referenceUrl"],
        })

    for item in items:
        line = item["text"]

        # Chỉ bắt tiêu đề phần viết HOA toàn bộ (không bị nhầm với câu giới thiệu ở trang 1)
        if line.startswith("PHẦN I."):
            section = "PART1"
            continue
        if line.startswith("PHẦN II."):
            flush()
            cur = None
            section = "PART2"
            continue

        if section == "PART2":
            for num_str, ans_char in re.findall(r"\b(\d{1,3})\.\s*([A-D])\b", line):
                quick_key[int(num_str)] = ans_char
            continue

        if section != "PART1":
            continue

        if re.match(r"^Khối\s+\d{1,2}\.", line):
            continue

        m_q = Q_HEADER_RE.match(line)
        if m_q:
            flush()
            num = int(m_q.group(1))
            bid = m_q.group(3)
            qid = f"{bid}-{m_q.group(4)}"
            bnum = int(bid[1:])
            tier = next((t for r, t in TIER_MAP.items() if bnum in r), "Khác")
            cur = {
                "number": num,
                "id": qid,
                "tier": tier,
                "blockId": bid,
                "blockName": block_map.get(bid, bid),
                "difficulty": m_q.group(5),
                "vi": m_q.group(2).strip(),
                "en": "",
                "code": [],
                "opts": {},
                "cur_opt": None,
            }
            continue

        if not cur:
            continue

        m_en = EN_HEADER_RE.match(line)
        if m_en and not cur["en"] and not cur["opts"]:
            cur["en"] = m_en.group(1).strip()
            continue

        m_opt = re.match(r"^([A-D])\.\s*(.+)$", line, re.DOTALL)
        if m_opt and not item["in_table"]:
            k = m_opt.group(1)
            cur["cur_opt"] = k
            cur["opts"][k] = [m_opt.group(2).strip()]
            continue

        if cur["cur_opt"]:
            cur["opts"][cur["cur_opt"]].append(line)
        else:
            cur["code"].append(line)

    flush()
    return questions, quick_key


if __name__ == "__main__":
    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    ans_map, block_map = parse_answers(extract_paragraphs(ANSWERS_DOCX))
    questions, quick_key = parse_questions(extract_paragraphs(QUESTIONS_DOCX), ans_map, block_map)

    OUTPUT_JSON.write_text(json.dumps(questions, ensure_ascii=False, indent=2), encoding="utf-8")

    diff_counts = {}
    bad_opts = []
    mismatch_ans = []
    for q in questions:
        diff_counts[q["difficulty"]] = diff_counts.get(q["difficulty"], 0) + 1
        if any(not o["text"]["vi"] for o in q["options"]):
            bad_opts.append(q["id"])
        expected = quick_key.get(q["number"])
        if expected and expected != q["correctAnswer"]:
            mismatch_ans.append((q["id"], q["correctAnswer"], expected))

    print(f"Đã xuất: {len(questions)} câu hỏi / {len(ans_map)} đáp án -> {OUTPUT_JSON}")
    print(f"Phân bố mức độ: {diff_counts} (Chuẩn: Nhớ 103, Hiểu 120, Vận dụng 77)")
    print(f"Câu thiếu phương án: {len(bad_opts)} | Câu lệch đáp án Phần II: {len(mismatch_ans)}")