# Nhật ký sử dụng trợ lý AI – Thành viên 3 (Nguyễn Mạnh Dũng)

## 1. Thiết kế model kết quả và tầng lưu trữ lịch sử offline (`ExamResult`, `ResultService`)
- **Công cụ:** ChatGPT
- **Phạm vi file:** `lib/models/exam_result.dart`, `lib/services/result_service.dart`
- **Prompt tiêu biểu:**
  > "Trong dự án Flutter ôn tập trắc nghiệm có sẵn model `Question` và `QuizRepository`, hãy hướng dẫn viết model `ExamResult` (gồm `id`, `completedAt`, `topicIds`, `totalQuestions`, `correctAnswers`, `selectedAnswers`, `correctQuestionIds`, `questionTopicIds`) với getter tính điểm thang 10, phần trăm đúng và lọc ra `wrongQuestionIds` (bao gồm cả câu chọn sai lẫn câu bỏ trống). Sau đó viết `ResultService` dùng `shared_preferences` để lưu danh sách bài thi dưới dạng JSON string list (`exam_results`), có hàm tính thống kê tỷ lệ đúng theo từng `topicId` và lưu tập `resolved_wrong_questions` để tự động loại bỏ các câu sai sau khi người dùng đã ôn lại đúng."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Tự kiểm thử luồng lưu/đọc JSON trong `SharedPreferences`, bổ sung khối `try-catch` bỏ qua bản ghi lỗi định dạng để tránh crash app khi dữ liệu cục bộ bị hỏng, và viết thêm chức năng xóa toàn bộ lịch sử thi.

## 2. Xây dựng luồng thi thử tính giờ và màn hình chấm điểm (`ExamScreen`, `ResultScreen`)
- **Công cụ:** ChatGPT
- **Phạm vi file:** `lib/screens/exam_screen.dart`, `lib/screens/result_screen.dart`
- **Prompt tiêu biểu:**
  > "Hướng dẫn xây dựng màn hình thi thử `ExamScreen` nhận `QuizRepository` và `initialLanguage`: cho phép chọn nhiều khối kiến thức (`topicIds`) và số lượng câu hỏi (10, 20, 30, 50, 100), dùng `Timer.periodic` đếm ngược thời gian và tự động nộp bài khi hết giờ (nhớ `cancel()` timer trong `dispose()`). Trước khi nộp thủ công thì hiển thị `AlertDialog` cảnh báo nếu còn câu chưa chọn đáp án. Khi nộp bài sẽ tạo `ExamResult`, lưu qua `ResultService` và điều hướng sang `ResultScreen` để hiển thị điểm thang 10, phân tích theo từng khối và xem chi tiết từng câu đúng/sai."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Kiểm tra kỹ vòng đời `Timer` khi thoát màn hình giữa chừng để tránh rò rỉ bộ nhớ, tinh chỉnh lại logic xáo trộn ngẫu nhiên danh sách câu hỏi theo các khối đã chọn.

## 3. Xây dựng màn hình thống kê và ôn tập câu trả lời sai (`StatisticsScreen`, `WrongQuestionsScreen`)
- **Công cụ:** ChatGPT
- **Phạm vi file:** `lib/screens/statistics_screen.dart`, `lib/screens/wrong_questions_screen.dart`
- **Prompt tiêu biểu:**
  > "Hướng dẫn viết 2 màn hình đọc dữ liệu từ `ResultService`: (1) `StatisticsScreen` hiển thị tổng số bài đã thi, điểm trung bình, thanh tiến độ tỷ lệ đúng theo từng khối kiến thức và danh sách lịch sử các lần thi; (2) `WrongQuestionsScreen` lấy danh sách ID câu sai chưa được giải quyết từ `ResultService`, ánh xạ sang `QuestionItem` qua `QuizRepository` để người dùng làm lại, nếu chọn đúng thì gọi `markWrongQuestionResolved()` để gỡ khỏi danh sách. Cả hai màn hình đều phải có đủ trạng thái đang tải (`CircularProgressIndicator`) và trạng thái trống (Empty state) rõ ràng."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Chạy thử trên thiết bị thật để kiểm tra tính đồng bộ dữ liệu ngay sau khi làm bài thi thử xong và khi xóa lịch sử.

## 4. Đồng bộ hóa đa ngôn ngữ (VI / EN / Song ngữ) và sửa lỗi tràn giao diện
- **Công cụ:** Gemini
- **Phạm vi file:** `home_screen.dart`, `exam_screen.dart`, `result_screen.dart`, `statistics_screen.dart`, `wrong_questions_screen.dart`
- **Prompt tiêu biểu:**
  > "Rà soát toàn bộ các màn hình thi thử, kết quả, thống kê và ôn câu sai xem còn chuỗi văn bản nào cố định tiếng Việt chưa chuyển đổi theo `DisplayLanguage` (`vi`, `en`, `bilingual`) không, đồng thời xử lý lỗi tràn chiều ngang (`RenderFlex overflow`) khi bật chế độ Song ngữ trên màn hình điện thoại nhỏ."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Bổ sung hàm helper `_text(vi, en)` trên các màn hình, bọc `Expanded` / `Flexible` cho các nhãn tiêu đề dài và chạy kiểm thử lại toàn bộ giao diện.

## 5. Hướng dẫn cấu hình GitHub Actions CI và phát hành APK Release
- **Công cụ:** Gemini
- **Phạm vi file:** `.github/workflows/flutter_ci.yml`, `test/widget_test.dart`, `android/app/build.gradle.kts`, `.gitignore`
- **Prompt tiêu biểu:**
  > "Hướng dẫn từng bước tạo workflow GitHub Actions tự động chạy `flutter analyze` và `flutter test` khi push lên nhánh `main` (xử lý lỗi xung đột phiên bản Dart SDK ^3.11.0 trên Ubuntu). Sau đó hướng dẫn tạo file khóa `.jks` bằng `keytool`, cấu hình `key.properties` và `build.gradle.kts` để ký bản `app-release.apk`, chặn file khóa trong `.gitignore` và phát hành lên GitHub Releases."
- **Kiểm tra & Chỉnh sửa của sinh viên:** Cấu hình workflow chạy đạt tích xanh 18/18 test cases (cập nhật lại 5 assertion trong `widget_test.dart` cho khớp tiêu đề song ngữ mới), tạo keystore riêng, kiểm tra chứng chỉ bằng `apksigner` và đăng tải bản phát hành `v1.0.0`.