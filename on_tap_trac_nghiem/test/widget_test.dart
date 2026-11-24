import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_tap_trac_nghiem/main.dart';
import 'package:on_tap_trac_nghiem/models/question.dart';
import 'package:on_tap_trac_nghiem/services/quiz_repository.dart';

List<Question> _buildSampleQuestions() {
  return const [
    Question(
      id: 'K01-001',
      number: 1,
      tier: 'Tầng 1: Nền tảng',
      blockId: 'K01',
      blockName: 'K01: Ngôn ngữ Dart · The Dart language',
      difficulty: 'Nhớ',
      question: BilingualText(
        vi: 'Từ khóa nào tạo hằng số thời điểm biên dịch trong Dart?',
        en: 'Which keyword creates a compile-time constant in Dart?',
      ),
      codeSnippet: 'const double pi = 3.14;',
      options: [
        QuestionOption(key: 'A', text: BilingualText(vi: 'final', en: 'final')),
        QuestionOption(key: 'B', text: BilingualText(vi: 'var', en: 'var')),
        QuestionOption(key: 'C', text: BilingualText(vi: 'const', en: 'const')),
        QuestionOption(key: 'D', text: BilingualText(vi: 'late', en: 'late')),
      ],
      correctAnswer: 'C',
      explanation: BilingualText(
        vi: 'const khai báo giá trị hằng số ngay lúc biên dịch.',
        en: 'const declares a compile-time constant value.',
      ),
      referenceUrl: '',
    ),
    Question(
      id: 'K01-002',
      number: 2,
      tier: 'Tầng 1: Nền tảng',
      blockId: 'K01',
      blockName: 'K01: Ngôn ngữ Dart · The Dart language',
      difficulty: 'Hiểu',
      question: BilingualText(
        vi: 'Kiểu dữ liệu nào đại diện cho danh sách có thứ tự trong Dart?',
        en: 'Which data type represents an ordered collection in Dart?',
      ),
      codeSnippet: '',
      options: [
        QuestionOption(key: 'A', text: BilingualText(vi: 'List', en: 'List')),
        QuestionOption(key: 'B', text: BilingualText(vi: 'Set', en: 'Set')),
        QuestionOption(key: 'C', text: BilingualText(vi: 'Map', en: 'Map')),
        QuestionOption(key: 'D', text: BilingualText(vi: 'Runes', en: 'Runes')),
      ],
      correctAnswer: 'A',
      explanation: BilingualText(
        vi: 'List lưu trữ các phần tử theo thứ tự chỉ số.',
        en: 'List stores elements in indexed order.',
      ),
      referenceUrl: '',
    ),
    Question(
      id: 'K04-001',
      number: 3,
      tier: 'Tầng 2: Giao diện',
      blockId: 'K04',
      blockName: 'K04: Bố cục · Layout',
      difficulty: 'Hiểu',
      question: BilingualText(
        vi: 'Widget nào sắp xếp các widget con theo chiều dọc?',
        en: 'Which widget arranges its children vertically?',
      ),
      codeSnippet: '',
      options: [
        QuestionOption(key: 'A', text: BilingualText(vi: 'Hàng ngang', en: 'Row')),
        QuestionOption(key: 'B', text: BilingualText(vi: 'Cột dọc', en: 'Column')),
        QuestionOption(key: 'C', text: BilingualText(vi: 'Chồng lớp', en: 'Stack')),
        QuestionOption(key: 'D', text: BilingualText(vi: 'Lưới', en: 'GridView')),
      ],
      correctAnswer: 'B',
      explanation: BilingualText(
        vi: 'Column hiển thị danh sách widget con theo trục dọc.',
        en: 'Column displays its children in a vertical array.',
      ),
      referenceUrl: '',
    ),
  ];
}

QuizRepository _createFakeRepository({List<Question>? data}) {
  final source = data ?? _buildSampleQuestions();
  return QuizRepository(
    customLoader: () async => source,
  );
}

void main() {
  group('Unit Tests — Question & QuizRepository', () {
    test('1. parseBilingualBlockName tách đúng tên Việt và Anh', () {
      final parsed = QuizRepository.parseBilingualBlockName(
        'K01',
        'K01: Ngôn ngữ Dart · The Dart language',
      );
      expect(parsed.vi, 'Ngôn ngữ Dart');
      expect(parsed.en, 'The Dart language');
    });

    test('2. parseBilingualBlockName giữ nguyên fallback khi thiếu dấu phân cách', () {
      final parsed = QuizRepository.parseBilingualBlockName(
        'K02',
        'K02: Công cụ phát triển',
      );
      expect(parsed.vi, 'Công cụ phát triển');
      expect(parsed.en, 'Công cụ phát triển');
    });

    test('3. parseBlockOrder trích xuất đúng số thứ tự từ K01..K20', () {
      expect(QuizRepository.parseBlockOrder('K01'), 1);
      expect(QuizRepository.parseBlockOrder('K12'), 12);
      expect(QuizRepository.parseBlockOrder('INVALID'), 999);
    });

    test('4. fromQuestion ánh xạ chính xác correctIndex và codeSnippet', () {
      final q = _buildSampleQuestions().first;
      final item = QuizRepository.fromQuestion(q);
      expect(item.topicId, 'K01');
      expect(item.correctIndex, 2); // C -> index 2
      expect(item.codeSnippet, 'const double pi = 3.14;');
      expect(item.optionsVi.length, 4);
    });

    test('5. Question.isCorrect kiểm tra không phân biệt chữ hoa thường', () {
      final q = _buildSampleQuestions().first;
      expect(q.isCorrect('c'), isTrue);
      expect(q.isCorrect(' C '), isTrue);
      expect(q.isCorrect('A'), isFalse);
    });

    test('6. getTopics nhóm đúng khối kiến thức, sắp xếp tăng dần và đếm đủ số câu', () async {
      final repo = _createFakeRepository();
      final topics = await repo.getTopics();
      expect(topics.length, 2);
      expect(topics[0].id, 'K01');
      expect(topics[0].questionCount, 2);
      expect(topics[1].id, 'K04');
      expect(topics[1].questionCount, 1);
    });

    test('7. Bỏ qua câu hỏi hỏng định dạng và câu trùng ID mà không làm app dừng', () async {
      const corrupted = Question(
        id: 'BAD-1',
        number: 99,
        tier: 'Tầng 1',
        blockId: 'K01',
        blockName: 'K01: Ngôn ngữ Dart · The Dart language',
        difficulty: 'Nhớ',
        question: BilingualText(vi: '', en: ''),
        codeSnippet: '',
        options: [],
        correctAnswer: 'Z',
        explanation: BilingualText(vi: '', en: ''),
        referenceUrl: '',
      );
      final sample = _buildSampleQuestions();
      final repo = _createFakeRepository(
        data: [sample[0], sample[0], corrupted, sample[2]],
      );

      final questions = await repo.getQuestionsByTopic(null);
      expect(questions.length, 2);
      expect(questions.map((e) => e.id), ['K01-001', 'K04-001']);
    });

    test('8. getQuestionsByTopic lọc chính xác theo blockId', () async {
      final repo = _createFakeRepository();
      final k01 = await repo.getQuestionsByTopic('K01');
      final k04 = await repo.getQuestionsByTopic('K04');
      final missing = await repo.getQuestionsByTopic('K99');

      expect(k01.length, 2);
      expect(k04.length, 1);
      expect(missing, isEmpty);
    });

    test('9. Cơ chế cache tránh gọi loader lặp lại nhiều lần', () async {
      var loadCalls = 0;
      final repo = QuizRepository(
        customLoader: () async {
          loadCalls++;
          return _buildSampleQuestions();
        },
      );

      await repo.getTopics();
      await repo.getQuestionsByTopic('K01');
      expect(loadCalls, 1);

      repo.clearCache();
      await repo.getTopics();
      expect(loadCalls, 2);
    });

    test('10. simulateError ném ngoại lệ tiếng Việt dễ hiểu', () async {
      final repo = _createFakeRepository()..simulateError = true;
      await expectLater(
        repo.getTopics(),
        throwsA(isA<Exception>()),
      );
    });

    test('11. simulateEmpty trả về danh sách rỗng cho cả topics và questions', () async {
      final repo = _createFakeRepository()..simulateEmpty = true;
      expect(await repo.getTopics(), isEmpty);
      expect(await repo.getQuestionsByTopic(null), isEmpty);
    });

    test('12. getSummaryStats trả về đúng tổng số câu hỏi và tổng số chủ đề', () async {
      final repo = _createFakeRepository();
      final stats = await repo.getSummaryStats();
      expect(stats.questionCount, 3);
      expect(stats.topicCount, 2);
    });

    test('13. TopicItem.displayName trả về đúng chuỗi theo từng DisplayLanguage', () async {
      final repo = _createFakeRepository();
      final topic = (await repo.getTopics()).first;
      expect(topic.displayName(DisplayLanguage.vi), 'Ngôn ngữ Dart');
      expect(topic.displayName(DisplayLanguage.en), 'The Dart language');
      expect(
        topic.displayName(DisplayLanguage.bilingual),
        'Ngôn ngữ Dart · The Dart language',
      );
    });
  });

  group('Widget Tests — Luồng giao diện chính', () {
    testWidgets('14. HomeScreen hiển thị đầy đủ thành phần và đổi ngôn ngữ mượt mà',
        (WidgetTester tester) async {
      final repo = _createFakeRepository();
      await tester.pumpWidget(QuizMasterApp(quizRepository: repo));
      await tester.pumpAndSettle();

      expect(find.text('QuizMaster'), findsOneWidget);
      expect(find.text('Luyện tập nhanh · Quick Practice'), findsOneWidget);
      expect(find.text('Chọn chủ đề · Select Topic'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('Song ngữ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Quick Practice'), findsOneWidget);
      expect(find.text('Select Topic'), findsOneWidget);
    });

    testWidgets('15. TopicScreen tìm kiếm tiếng Việt không dấu và xóa từ khóa',
        (WidgetTester tester) async {
      final repo = _createFakeRepository();
      await tester.pumpWidget(QuizMasterApp(quizRepository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chọn chủ đề · Select Topic'));
      await tester.pumpAndSettle();

      expect(find.text('Ngôn ngữ Dart'), findsOneWidget);
      expect(find.text('Bố cục'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'bo cuc');
      await tester.pumpAndSettle();

      expect(find.text('Bố cục'), findsOneWidget);
      expect(find.text('Ngôn ngữ Dart'), findsNothing);

      await tester.enterText(find.byType(TextField), 'khongtontai');
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy chủ đề phù hợp'), findsOneWidget);

      final clearBtn = find.text('Xóa tìm kiếm (Clear)');
      await tester.ensureVisible(clearBtn);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      expect(find.text('Ngôn ngữ Dart'), findsOneWidget);
      expect(find.text('Bố cục'), findsOneWidget);
    });

    testWidgets('16. TopicScreen xử lý đầy đủ trạng thái Lỗi và Trống có nút khôi phục',
        (WidgetTester tester) async {
      final repo = _createFakeRepository();
      await tester.pumpWidget(QuizMasterApp(quizRepository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chọn chủ đề · Select Topic'));
      await tester.pumpAndSettle();

      // Giả lập Lỗi
      await tester.tap(find.byIcon(Icons.bug_report_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Giả lập Lỗi (Error)'));
      await tester.pumpAndSettle();

      expect(find.text('Không thể tải danh sách chủ đề'), findsOneWidget);

      await tester.tap(find.text('Thử lại (Retry)'));
      await tester.pumpAndSettle();
      expect(find.text('Ngôn ngữ Dart'), findsOneWidget);

      // Giả lập Trống
      await tester.tap(find.byIcon(Icons.bug_report_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Giả lập Trống (Empty)'));
      await tester.pumpAndSettle();

      expect(find.text('Chưa có chủ đề nào (No topics yet)'), findsOneWidget);

      await tester.tap(find.text('Nạp lại dữ liệu (Reload)'));
      await tester.pumpAndSettle();
      expect(find.text('Ngôn ngữ Dart'), findsOneWidget);
    });

    testWidgets('17. Luồng PracticeScreen: hiện code snippet, chọn đáp án, hiện giải thích và tổng kết',
        (WidgetTester tester) async {
      final repo = _createFakeRepository();
      await tester.pumpWidget(QuizMasterApp(quizRepository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chọn chủ đề · Select Topic'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bố cục'));
      await tester.pumpAndSettle();

      expect(find.text('Widget nào sắp xếp các widget con theo chiều dọc?'), findsOneWidget);

      final correctOption = find.text('Cột dọc');
      await tester.ensureVisible(correctOption);
      await tester.tap(correctOption);
      await tester.pumpAndSettle();

      expect(find.text('Chính xác! · Correct!'), findsOneWidget);
      expect(find.text('1 đúng'), findsOneWidget);

      await tester.tap(find.text('Xem kết quả'));
      await tester.pumpAndSettle();

      expect(find.text('Hoàn thành luyện tập'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('18. PracticeScreen hiển thị codeSnippet và không lặp đáp án khi VI trùng EN',
        (WidgetTester tester) async {
      final repo = _createFakeRepository();
      await tester.pumpWidget(QuizMasterApp(quizRepository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Luyện tập nhanh · Quick Practice'));
      await tester.pumpAndSettle();

      expect(find.text('const double pi = 3.14;'), findsOneWidget);
      // Ở chế độ Song ngữ, đáp án 'const' có VI == EN nên chỉ hiển thị đúng 1 lần
      expect(find.text('const'), findsOneWidget);

      // Đổi ngôn ngữ trực tiếp trong PracticeScreen sang English
      await tester.tap(find.text('Song ngữ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(
        find.text('Which keyword creates a compile-time constant in Dart?'),
        findsOneWidget,
      );
    });
  });
}
