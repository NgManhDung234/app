# Nhật ký sử dụng trợ lý AI – Thành viên 1 (Nguyễn Huy Phước)

**Phạm vi phụ trách:** Dữ liệu và ngân hàng câu hỏi của ứng dụng ôn tập trắc nghiệm song ngữ.

**Nguồn nhật ký:** Bản xuất cuộc trò chuyện Gemini `Gemini_Hướng-dẫn-Thành-viên-1-Quản-lý-Dữ-liệu_20261126-1402.pdf` (113 trang; các trao đổi được ghi nhận ngày 19/11/2026). Các prompt dưới đây là trích đoạn từ cuộc trò chuyện; đã nối lại các dòng bị ngắt khi xuất PDF. Tên và trạng thái tệp hiện tại được đối chiếu với mã nguồn dự án. Nội dung AI đề xuất không mặc nhiên là nội dung đã triển khai hoặc đã kiểm thử thành công.

## 1. Phân tích nhiệm vụ và chuẩn bị môi trường

- **Công cụ:** Gemini.
- **Phạm vi:** Phân công TV1, cấu trúc dự án Flutter, môi trường phát triển và cách phối hợp dữ liệu với TV2, TV3.
- **Prompt tiêu biểu:**
  > "tôi đc phân công nhiệm vụ của thành viên 1, hãy phân tích đề bài cùng những yêu cầu để hướng dẫn tôi thực hiện tv1 sao cho phù hợp với các tv còn lại, trong quá trình thực hiện có những công cụ hay những gói mở rộng gì đó cần đc thêm hay tải xuống thì hãy đề cập đến để tránh gây lỗi"
- **AI hỗ trợ:** Phân tích vai trò quản lý ngân hàng câu hỏi, đề xuất cấu trúc model/service, hướng dẫn chuẩn bị Flutter, Android SDK và môi trường viết mã. Gemini cũng gợi ý một số cách tổ chức dữ liệu và thư viện để phối hợp giữa các thành viên.
- **Đối chiếu và lưu ý:** Những gợi ý ban đầu chỉ là phương án tham khảo. Sau khi nhận thông tin về bộ tài liệu Word, Gemini đã chuyển sang phân tích bộ câu hỏi thực tế gồm 20 khối kiến thức. Một số đề xuất ban đầu, như cách hiểu khối 8/11/12 hoặc thêm `provider`, không nên được xem là mô tả phiên bản cuối của dự án. Khi gặp lỗi dùng `mkdir -p` trong PowerShell, TV1 gửi ảnh lỗi và nhận hướng dẫn điều chỉnh lệnh cho môi trường Windows. (PDF tr. 3–11.)

## 2. Chuyển bộ câu hỏi và lời giải từ Word sang JSON

- **Công cụ:** Gemini.
- **Phạm vi file:** `scripts/convert_to_json.py`, `assets/data/questions.json`, khai báo asset trong `pubspec.yaml`.
- **Prompt tiêu biểu:**
  > "2 file trên là tài liệu về bộ câu hỏi mà tôi sử dụng để làm dự án lần này"
  >
  > "bắt đầu thực hiện dự án với những dữ liệu tôi đã gửi đi"
- **AI hỗ trợ:** Đề xuất script Python đọc tài liệu câu hỏi và tài liệu lời giải, ghép theo mã câu, sau đó xuất dữ liệu JSON gồm câu hỏi, bốn phương án, đáp án, giải thích Việt – Anh, đoạn mã và thông tin khối kiến thức. AI cũng hướng dẫn khai báo tệp JSON là asset của Flutter.
- **Kiểm tra & xử lý theo cuộc trò chuyện:** TV1 chạy script và gửi lại lỗi `FileNotFoundError` đối với tệp lời giải tại `scripts/input/dap_an_chi_tiet.docx`; Gemini hướng dẫn kiểm tra tên và đường dẫn tệp đầu vào. Log ghi nhận nhiều phiên bản script đã được thử, nên thông báo xuất tệp không đủ để kết luận dữ liệu đúng; cần kiểm tra số câu và nội dung sau khi chuyển đổi. (PDF tr. 9–29.)

## 3. Rà cấu trúc Word và sửa lỗi chuyển đổi không nhận câu hỏi

- **Công cụ:** Gemini.
- **Phạm vi file:** `scripts/convert_to_json.py`, dữ liệu nguồn Word và `assets/data/questions.json`.
- **Prompt tiêu biểu:**
  > "Đã khớp 300 đáp án và xuất thành công 0 câu hỏi ra assets\data\questions.json"
  >
  > "nghiên cứu sâu cấu trúc của file trước khi nghĩ code để thực hiện"
- **AI hỗ trợ:** Xem lại cấu trúc tài liệu và đề xuất sửa quy tắc nhận diện tiêu đề câu, mã câu và các phần trong tài liệu. Cuộc trao đổi lần lượt xem xét vị trí bắt đầu phần câu hỏi, dạng dấu gạch nối trong mã và ảnh hưởng của việc không phân biệt chữ hoa/thường khi nhận diện tiêu đề phần.
- **Kiểm tra & phản hồi của sinh viên:** TV1 gửi kết quả chạy thực tế: đã khớp 300 đáp án nhưng xuất 0 câu; cung cấp thêm các dòng trích từ tài liệu để đối chiếu và yêu cầu AI nghiên cứu cấu trúc thật trước khi viết tiếp. Đây là quá trình sửa nhiều lần, không phải lần đầu AI đưa ra script đã chạy đúng. Script hiện tại trong dự án đọc nội dung Word/XML, nhận diện các phần và kiểm tra thêm số phương án, độ khó và đáp án đối chiếu; không suy ra rằng mọi lần chạy trong lịch sử đều thành công. (PDF tr. 29–63.)
- **Đối chiếu dữ liệu hiện tại:** Tệp JSON trong dự án có 300 bản ghi, 300 mã duy nhất và 20 mã khối; phân bố độ khó là 103 câu Nhớ, 120 câu Hiểu và 77 câu Vận dụng. Đây là kiểm tra trên tệp hiện có, chưa phải xác minh thủ công nội dung từng câu so với tài liệu gốc.

## 4. Xây dựng model và dịch vụ dữ liệu cho ứng dụng

- **Công cụ:** Gemini.
- **Phạm vi file:** `lib/models/question.dart`, `lib/services/question_service.dart`, `assets/data/questions.json`.
- **Prompt tiêu biểu:**
  > "bắt đầu tiếp tục các bước tiếp theo sau bước 2 lại đi do bước 2 phải sửa nhiều quá"
- **AI hỗ trợ:** Đề xuất model Dart đọc dữ liệu câu hỏi song ngữ, phương án và đáp án; hướng dẫn nạp asset JSON, lưu dữ liệu trong bộ nhớ, lọc hoặc tra câu hỏi để các phần giao diện và nghiệp vụ sử dụng.
- **Đối chiếu với mã hiện tại:** `question.dart` có `BilingualText`, `QuestionOption`, `Question` và `KnowledgeBlock`, cùng kiểm tra đáp án và điều kiện hợp lệ cơ bản. `QuestionService` nạp JSON, ghi nhận câu trùng mã hoặc không hợp lệ trong danh sách lỗi, cung cấp các hàm nhóm/lọc theo khối, độ khó và tra ID. Phần service hiện tại vẫn thêm bản ghi vào danh sách sau khi ghi nhận lỗi; không khẳng định ở đây rằng service tự loại mọi câu lỗi. (PDF tr. 63–85; tên file trong các phương án đầu của cuộc trò chuyện từng khác tên file hiện tại.)

## 5. Rà lại phạm vi TV1 và phối hợp với nhóm

- **Công cụ:** Gemini.
- **Phạm vi:** Các file dữ liệu, model và service; ranh giới với `screens/` và `widgets/`.
- **Prompt tiêu biểu:**
  > "đây có phải là toàn bộ dự án ko hay chỉ là của tv1 tại tôi thấy có cả code screén"
  >
  > "tôi đã làm convert_to_json.py, question_model.dart và quiz_service.dart bây h những cái nào của tôi có thể giữ nguyên và những cái nào cần chỉnh sửa cái j"
- **AI hỗ trợ:** Sau khi TV1 đặt câu hỏi về phạm vi, Gemini xác nhận một phương án trước đó đã bao gồm cả giao diện và nghiệp vụ của các thành viên khác; sau khi nhận lại bảng phân công, AI hướng dẫn tập trung vào dữ liệu, model và service, đồng thời điều chỉnh tên file cho phù hợp cấu trúc nhóm.
- **Kiểm tra & phản hồi của sinh viên:** TV1 chủ động đối chiếu câu trả lời với phân công ba thành viên và hỏi cách xử lý các file đã tạo. Việc AI gợi ý giao diện hoặc chức năng ngoài phạm vi không có nghĩa TV1 đã triển khai hay chịu trách nhiệm các phần đó. (PDF tr. 85–104.)

## 6. Kiểm tra dữ liệu, chuẩn bị bàn giao qua GitHub

- **Công cụ:** Gemini.
- **Phạm vi:** `scripts/convert_to_json.py`, `assets/data/questions.json`, model/service và quy trình Git.
- **Prompt tiêu biểu:**
  > "làm thế nào để tôi kiểm tra xem code có hoạt động trơn tru hay ko và nếu tôi chạy python scripts/convert_to_json.py nhiều lần trong termianl của dự án thì file question.json có bị ghi thêm vào nhiều lần ko hay chỉ nhận 1 lần"
  >
  > "tôi đã hoàn thành phần của mình bây h tôi muốn push lên git hub"
- **AI hỗ trợ:** Giải thích rằng script ghi đè tệp đầu ra thay vì nối thêm dữ liệu; gợi ý chạy `flutter analyze`, viết unit test cho dữ liệu và service, kiểm tra trước khi commit và dùng nhánh riêng để đẩy phần việc lên repository nhóm.
- **Giới hạn xác nhận:** Log thể hiện TV1 hỏi cách kiểm thử, tự thông báo đã hoàn thành phần việc và xin hướng dẫn push. Log không cung cấp đầy đủ kết quả chạy các lệnh kiểm thử hay bằng chứng push thành công, vì vậy không ghi nhận các việc đó là đã hoàn tất chỉ dựa trên hướng dẫn của AI. Ở mã hiện tại, script dùng `write_text` để ghi lại toàn bộ tệp JSON khi chạy. (PDF tr. 104–113.)

## Ghi chú về việc sử dụng AI

Nhật ký này tổng hợp một cuộc trò chuyện Gemini được cung cấp; không loại trừ việc sử dụng công cụ hoặc cuộc trò chuyện khác ngoài nguồn này. Một số câu trả lời của AI có giả định hoặc mã chưa phù hợp ở thời điểm đưa ra, vì vậy TV1 đã cung cấp lỗi, hỏi lại và yêu cầu phân tích tài liệu trước khi tiếp tục. Kết quả cuối cùng cần được đánh giá theo dữ liệu, mã nguồn và kết quả kiểm thử thực tế của dự án.
