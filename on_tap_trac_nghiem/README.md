# QuizMaster – Ôn tập trắc nghiệm song ngữ Flutter

Project cuối kỳ học phần **INT1449 – Lập trình di động**.
Chủ đề **32: Ôn tập trắc nghiệm song ngữ** (nhóm F – Giáo dục và ôn tập), phát triển từ dự án mẫu "Ngân hàng 300 câu trắc nghiệm".

> Mã nguồn Flutter nằm trong thư mục [`on_tap_trac_nghiem/`](on_tap_trac_nghiem).

## 1. Mục đích

QuizMaster giúp sinh viên ôn tập 20 khối kiến thức Flutter bằng bộ **300 câu trắc nghiệm song ngữ Việt – Anh**. Ứng dụng chạy hoàn toàn trên máy, **không cần mạng và không cần tài khoản**.

### Tính năng

| Nhóm | Tính năng | Loại theo đề |
|---|---|---|
| Dữ liệu | Nạp 300 câu từ JSON, kiểm tra câu thiếu dữ liệu hoặc trùng mã, nhóm theo 20 khối | Tối thiểu |
| Luyện tập | Luyện tập nhanh hoặc theo từng khối, chọn đáp án, xem đáp án đúng và lời giải song ngữ ngay | Tối thiểu |
| Thi thử | Chọn khối và số câu, sinh đề ngẫu nhiên, nộp bài, tự chấm điểm thang 10 | Tối thiểu |
| Thống kê | Số bài thi, điểm trung bình, kết quả theo từng khối, lịch sử thi, xoá lịch sử | Tối thiểu |
| Ôn câu sai | Lưu câu trả lời sai (kể cả câu bỏ trống), làm lại câu sai, câu ôn đúng thì được gỡ khỏi danh sách | Tối thiểu |
| Ngôn ngữ | Chọn hiển thị Tiếng Việt / English / Song ngữ | Mở rộng |
| Đồng hồ | Đếm ngược thời gian khi thi thử | Mở rộng |
| Giao diện | Có đủ trạng thái đang tải, lỗi (có nút thử lại), chưa có dữ liệu; tìm khối không dấu | Bổ sung |

## 2. Yêu cầu và cài đặt

Cần có:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) bản **stable** mới (dự án yêu cầu Dart SDK `^3.11.0`; kiểm tra bằng `flutter --version`)
- Android Studio hoặc Android SDK, và một điện thoại Android thật (bật Gỡ lỗi USB) hoặc máy ảo
- Git

```bash
git clone https://github.com/NgManhDung234/app.git
cd app/on_tap_trac_nghiem
flutter pub get
flutter doctor        # kiểm tra môi trường, sửa các mục báo lỗi nếu có
```

## 3. Cấu hình

**Không cần cấu hình gì thêm.** Ứng dụng:

- không dùng khoá API, mật khẩu hay biến môi trường nào;
- không gọi mạng; toàn bộ dữ liệu nằm trong `assets/data/questions.json` và được đóng gói sẵn vào app;
- không có tệp `.env` hay `google-services.json` cần tạo.

## 4. Cách chạy

```bash
cd on_tap_trac_nghiem
flutter devices                 # xem thiết bị đang kết nối
flutter run                     # chạy trên thiết bị / máy ảo đang chọn
flutter run -d <device_id>      # chọn thiết bị cụ thể
```

Tạo APK cài thử:

```bash
flutter build apk --release
# Tệp tạo ra: build/app/outputs/flutter-apk/app-release.apk
```

## 5. Cách chạy test

```bash
cd on_tap_trac_nghiem
flutter analyze        # phân tích tĩnh
flutter test           # chạy toàn bộ unit test và widget test
```

Bộ test nằm ở `test/widget_test.dart` gồm **18 test**:

- **13 unit test**: tách tên khối song ngữ, ánh xạ đáp án đúng, nhóm và đếm câu theo khối, bỏ qua câu hỏng hoặc trùng mã, bộ nhớ đệm, giả lập lỗi / dữ liệu trống, đổi ngôn ngữ hiển thị.
- **5 widget test**: trang chủ và đổi ngôn ngữ, tìm khối, trạng thái lỗi / trống có nút khôi phục, luồng luyện tập từ chọn đáp án đến kết quả, hiển thị code mẫu và đáp án song ngữ.

Hai lệnh trên cũng tự chạy trên GitHub Actions mỗi lần đẩy hoặc mở pull request vào `main` (xem `.github/workflows/flutter_ci.yml`).

## 6. Dữ liệu lưu ở đâu

| Dữ liệu | Nơi lưu | Ghi chú |
|---|---|---|
| Ngân hàng 300 câu hỏi | `assets/data/questions.json`, đóng gói trong app | Chỉ đọc. Có thể sinh lại từ Word bằng `scripts/convert_to_json.py` |
| Lịch sử các bài thi (điểm, đáp án đã chọn, khối) | Bộ nhớ cục bộ của app qua `shared_preferences`, khoá `exam_results` | Chỉ nằm trên máy người dùng |
| Danh sách câu sai đã ôn đúng | `shared_preferences`, khoá `resolved_wrong_questions` | Dùng để loại câu đó khỏi danh sách ôn |
| Ngôn ngữ hiển thị | Bộ nhớ tạm trong phiên chạy | Không lưu lại sau khi tắt app |

- Dữ liệu **không được gửi đi đâu**, không có máy chủ hay dịch vụ đám mây.
- Dữ liệu lịch sử bị hỏng sẽ bị bỏ qua, app không bị dừng.
- Muốn xoá toàn bộ dữ liệu: dùng nút **Xoá lịch sử** trong màn hình *Thống kê*, hoặc xoá dữ liệu / gỡ cài đặt app.

## 7. Quyền và bảo mật

- **Quyền Android:** app không xin quyền nào (không camera, không vị trí, không bộ nhớ, không thông báo). Quyền `INTERNET` chỉ có trong bản debug để hot reload; bản release không có.
- **Khoá và bí mật:** repo không chứa khoá API, mật khẩu hay token. Nếu giải nén APK, chỉ thấy mã ứng dụng và bộ câu hỏi (vốn là nội dung công khai).
- **Quyền riêng tư:** không thu thập hay gửi dữ liệu cá nhân.

## 8. Kiến trúc

```
on_tap_trac_nghiem/
├── assets/data/questions.json        # 300 câu song ngữ, 20 khối
├── scripts/convert_to_json.py        # Word -> JSON
├── test/widget_test.dart             # unit test và widget test
└── lib/
    ├── main.dart                     # khởi động app, theme
    ├── models/
    │   ├── question.dart             # Question, KnowledgeBlock, BilingualText
    │   └── exam_result.dart          # ExamResult (kết quả một bài thi)
    ├── services/
    │   ├── question_service.dart     # đọc JSON, kiểm tra dữ liệu, truy vấn theo khối
    │   ├── quiz_repository.dart      # cầu nối dữ liệu -> giao diện, hỗ trợ đồ giả khi test
    │   └── result_service.dart       # lưu lịch sử thi, câu sai (shared_preferences)
    ├── screens/                      # home, topic, practice, exam, result, statistics, wrong_questions
    └── widgets/                      # question_card, answer_option
```

Giao diện (`screens`, `widgets`) chỉ gọi `QuizRepository` và `ResultService`; việc đọc dữ liệu nằm ở `services`. `QuizRepository` nhận được `customLoader` để thay dữ liệu thật bằng dữ liệu giả khi test.

## 9. Thành viên và phân công

| Thành viên | MSSV | Phụ trách | Tệp chính |
|---|---|---|---|
| Thành viên 1: `Nguyễn Huy Phước` | `B24DCCC230` | Dữ liệu và ngân hàng câu hỏi | `models/question.dart`, `services/question_service.dart`, `assets/data/questions.json`, `scripts/` |
| Thành viên 2: `Lương Lê Chí Thanh` | `B24DCCC248` | Giao diện và chế độ luyện tập | `screens/home_screen.dart`, `topic_screen.dart`, `practice_screen.dart`, `widgets/`, `services/quiz_repository.dart` |
| Thành viên 3: `Nguyễn Mạnh Dũng` | `B24DCCC082` | Thi thử, thống kê, lưu kết quả, ôn câu sai | `screens/exam_screen.dart`, `result_screen.dart`, `statistics_screen.dart`, `wrong_questions_screen.dart`, `services/result_service.dart`, `models/exam_result.dart` |

Phần trăm đóng góp chi tiết nằm trong bảng phân công nộp kèm bài.

## 10. Ghi nhận sử dụng trợ lý AI

Nhóm sử dụng trợ lý AI như công cụ hỗ trợ viết mã nguồn mẫu, phân tích cấu trúc dữ liệu, gỡ lỗi môi trường và biên soạn tài liệu. Toàn bộ mã nguồn được các thành viên trực tiếp chạy thử, kiểm tra đối chiếu trên thiết bị thật hoặc máy ảo và nắm rõ để giải trình khi vấn đáp. Các prompt tiêu biểu và nhật ký kiểm chứng được lưu tại thư mục [`docs/ai/`](docs/ai).

| Thành viên | Công cụ AI | Nội dung hỗ trợ và kiểm chứng của sinh viên | Nhật ký chi tiết |
|---|---|---|---|
| Nguyễn Huy Phước (TV1) | Gemini | Phân tích cấu trúc tài liệu Word nguồn, viết và tinh chỉnh script `scripts/convert_to_json.py`, đề xuất model `Question` và `QuestionService`. Sinh viên trực tiếp chạy chuyển đổi và đối chiếu đủ 300 câu hỏi thuộc 20 khối kiến thức trong `assets/data/questions.json`. | [`docs/ai/tv1_phuoc_ai_notes.md`](docs/ai/tv1_phuoc_ai_notes.md) |
| Lương Lê Chí Thanh (TV2) | Gemini | Thiết kế giao diện Material 3 cho `HomeScreen`, `TopicScreen`, `PracticeScreen` và các widget dùng lại (`QuestionCard`, `AnswerOption`). Xây dựng lớp cầu nối `QuizRepository` (tích hợp dữ liệu của TV1, hỗ trợ `customLoader`). Viết bộ 18 unit/widget test trong `test/widget_test.dart` và xử lý cấu hình `pubspec.yaml`. | [`docs/ai/tv2_thanh_ai_notes.md`](docs/ai/tv2_thanh_ai_notes.md) |
| Nguyễn Mạnh Dũng (TV3) | ChatGPT, Gemini | Thiết kế model `ExamResult` và `ResultService` (lưu trữ offline qua `shared_preferences`). Xây dựng luồng thi thử tính giờ đếm ngược (`ExamScreen`), màn hình kết quả (`ResultScreen`), thống kê (`StatisticsScreen`) và ôn câu sai (`WrongQuestionsScreen`). Rà soát đồng bộ đa ngôn ngữ, xử lý lỗi tràn giao diện trên thiết bị thật. Thiết lập GitHub Actions CI, tạo keystore ký số và phát hành `app-release.apk` lên GitHub Releases. | [`docs/ai/tv3_dung_ai_notes.md`](docs/ai/tv3_dung_ai_notes.md) |

## 11. Hạn chế còn lại

- Chưa có đồng bộ đám mây hay tài khoản: lịch sử thi chỉ nằm trên một máy.
- Ngôn ngữ hiển thị không được nhớ sau khi tắt app.
- Mới đóng gói và thử trên Android; chưa kiểm thử trên iOS.
