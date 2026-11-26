# Nhật ký sử dụng trợ lý AI – Thành viên 2 (Lương Lê Chí Thanh)

## 1. Thiết kế giao diện Modern Minimal cho màn hình Trang chủ và Chọn chủ đề (`HomeScreen`, `TopicScreen`)
- **Công cụ:** Gemini
- **Phạm vi file:** `lib/main.dart`, `lib/screens/home_screen.dart`, `lib/screens/topic_screen.dart`
- **Prompt tiêu biểu:**
    - "Thiết kế giao diện ứng dụng Flutter ôn tập trắc nghiệm song ngữ QuizMaster theo phong cách Modern Minimal (Material 3, màu chủ đạo Indigo `#3F51B5`, nền `#F8F9FC`). Xây dựng `HomeScreen` hiển thị tổng quan số câu hỏi/chủ đề, nút chuyển đổi 3 chế độ ngôn ngữ (`DisplayLanguage`: `vi`, `en`, `bilingual`) và bố trí sẵn các điểm điều hướng cho Luyện tập nhanh, Chọn chủ đề, Thi thử, Ôn câu sai và Thống kê. Xây dựng `TopicScreen` hiển thị danh sách 20 khối kiến thức `K01`–`K20`, có thanh tìm kiếm hỗ trợ tiếng Việt không dấu, đủ 3 trạng thái Đang tải (`CircularProgressIndicator`), Lỗi (có nút Thử lại), Trống (Empty state) và menu giả lập trạng thái Lỗi/Trống để kiểm thử."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Chạy thử trên máy ảo Android Pixel 8, kiểm tra chuyển đổi mượt mà 3 chế độ ngôn ngữ trên giao diện, kiểm thử tìm kiếm theo mã khối, tiếng Việt không dấu và tiếng Anh, đồng thời xác nhận nút khôi phục từ trạng thái Lỗi và Trống hoạt động ổn định.

## 2. Xây dựng màn hình luyện tập song ngữ và các widget tái sử dụng (`PracticeScreen`, `QuestionCard`, `AnswerOption`)
- **Công cụ:** Gemini
- **Phạm vi file:** `lib/screens/practice_screen.dart`, `lib/widgets/question_card.dart`, `lib/widgets/answer_option.dart`
- **Prompt tiêu biểu:**
    - "Hướng dẫn xây dựng màn hình `PracticeScreen` nhận `QuizRepository`, `topic` (có thể null khi luyện tập nhanh) và `initialLanguage`, tách thành 2 widget tái sử dụng là `QuestionCard` và `AnswerOption`. `QuestionCard` hiển thị thứ tự câu, mã khối, độ khó, nội dung câu hỏi theo chế độ ngôn ngữ và khung mã nguồn tối màu cuộn ngang cho `codeSnippet`. `AnswerOption` có vùng chạm tối thiểu `48dp`, tự gộp còn một dòng nếu đáp án tiếng Việt trùng tiếng Anh, đổi màu xanh/đỏ khi chọn đáp án và khóa lựa chọn. Sau khi trả lời, hiển thị thẻ giải thích song ngữ Việt – Anh và hiện `AlertDialog` tổng kết điểm, độ chính xác cùng nút Làm lại / Hoàn tất ở câu cuối."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Kiểm tra trực tiếp luồng luyện tập từ câu đầu tới hộp thoại tổng kết, kiểm thử cuộn ngang với các câu hỏi có đoạn code Dart/Flutter, đảm bảo tự cuộn về đầu màn hình khi chuyển sang câu tiếp theo và giữ nguyên trạng thái tiến độ khi đổi ngôn ngữ giữa chừng.

## 3. Xây dựng lớp cầu nối dữ liệu tích hợp 300 câu JSON thật (`QuizRepository`)
- **Công cụ:** Gemini
- **Phạm vi file:** `lib/services/quiz_repository.dart`
- **Prompt tiêu biểu:**
    - "Trong dự án `on_tap_trac_nghiem` đã có sẵn model `Question`, `QuestionService` và `assets/data/questions.json` (300 câu hỏi, 20 khối kiến thức) của Thành viên 1. Hãy viết lớp cầu nối `QuizRepository` (mẫu Adapter) bọc lấy `QuestionService` mà không chỉnh sửa file gốc của TV1: ánh xạ `Question` sang `QuestionItem`, tự tách tên khối song ngữ (dạng `K01: Ngôn ngữ Dart · The Dart language`), chuyển đáp án `A..D` sang `correctIndex`, lọc bỏ câu hỏi lỗi định dạng hoặc trùng mã mà không làm dừng app, có bộ nhớ đệm (cache), nhận `customLoader` (Dependency Injection) để thay dữ liệu giả khi test và có cờ `simulateError` / `simulateEmpty`."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Giữ nguyên 100% mã nguồn của Thành viên 1 (`question.dart`, `question_service.dart`, `questions.json`), kiểm chứng thực tế trên máy ảo Android ứng dụng nạp đủ 300 câu hỏi và 20 chủ đề từ tệp JSON thật mà không phát sinh xung đột.

## 4. Xây dựng bộ 18 bài kiểm thử tự động (`widget_test.dart`)
- **Công cụ:** Gemini
- **Phạm vi file:** `test/widget_test.dart`
- **Prompt tiêu biểu:**
    - "Hướng dẫn viết bộ kiểm thử tự động gồm cả unit test và widget test trong `test/widget_test.dart` sử dụng `customLoader` giả lập dữ liệu cho `QuizRepository`: (1) Unit test cho tách tên khối song ngữ, lấy số thứ tự `K01`–`K20`, ánh xạ `correctIndex`, kiểm tra đáp án không phân biệt hoa thường, nhóm/lọc câu hỏi theo khối, bỏ qua câu hỏng hoặc trùng mã, bộ nhớ đệm, giả lập lỗi/trống và thống kê tổng; (2) Widget test cho luồng đổi ngôn ngữ trên `HomeScreen`, tìm kiếm không dấu và khôi phục trạng thái lỗi/trống trên `TopicScreen`, luồng làm bài tới hộp thoại kết quả và hiển thị `codeSnippet` trên `PracticeScreen`."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Tự chạy `flutter analyze` (đạt `No issues found!`) và `flutter test` vượt qua 18/18 test cases (13 unit test và 5 widget test) trước khi đóng gói commit.

## 5. Xử lý cấu hình `pubspec.yaml`, môi trường chạy và quy trình Git nhóm
- **Công cụ:** Gemini
- **Phạm vi file:** `pubspec.yaml`, quy trình nhánh `TV2` và Pull Request `#1`
- **Prompt tiêu biểu:**
    - "Hướng dẫn sửa lỗi `flutter pub get` báo lệch phiên bản Dart SDK (`^3.14.0` so với `3.13.5` trên máy), lỗi thụt lề YAML ở mục `assets/data/questions.json`, lỗi Android Studio biên dịch nhầm sang thiết bị `Windows (desktop)` thay vì máy ảo Android, và quy trình đẩy code lên nhánh riêng `TV2`, dọn thư mục tạm `quiz_master` rồi tạo Pull Request gộp vào `main` an toàn."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Cập nhật `sdk: ^3.11.0` và căn lề 4 dấu cách cho đường dẫn `assets/data/questions.json` trong `pubspec.yaml`, chạy `flutter pub get` thành công, kiểm thử chạy thật trên máy ảo Pixel 8 và gộp hoàn chỉnh PR `#1` lên nhánh `main` không xung đột.
  '@ | Set-Content -Path "D:\app\docs\ai\tv2_thanh_ai_notes.md" -Encoding UTF8