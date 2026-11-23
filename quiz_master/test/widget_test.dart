import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_master/main.dart';
import 'package:quiz_master/services/question_service.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  final Future<String> Function(String key) onLoadString;

  _FakeAssetBundle(this.onLoadString);

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return onLoadString(key);
  }
}

void main() {
  group('QuestionService - Unit Tests', () {
    test('getTopics trả về đủ 20 chủ đề và đếm questionCount theo dữ liệu thật',
            () async {
          final service = QuestionService(
            loadFromAssets: false,
            simulatedDelay: Duration.zero,
          );

          final topics = await service.getTopics();

          expect(topics.length, 20);
          expect(service.isUsingFallbackData, isTrue);
          expect(topics.firstWhere((t) => t.id == 1).questionCount, 1);
          expect(topics.firstWhere((t) => t.id == 8).questionCount, 1);
          expect(topics.firstWhere((t) => t.id == 12).questionCount, 1);
          expect(topics.firstWhere((t) => t.id == 2).questionCount, 0);

          final totalQuestions =
          topics.fold<int>(0, (sum, item) => sum + item.questionCount);
          expect(totalQuestions, 3);
        });

    test('getQuestionsByTopic(null) trả về toàn bộ câu hỏi hợp lệ', () async {
      final service = QuestionService(
        loadFromAssets: false,
        simulatedDelay: Duration.zero,
      );

      final questions = await service.getQuestionsByTopic(null);

      expect(questions.length, 3);
      expect(questions.map((q) => q.id), containsAll(['Q01', 'Q02', 'Q03']));
    });

    test('getQuestionsByTopic(topicId) lọc chính xác theo chủ đề', () async {
      final service = QuestionService(
        loadFromAssets: false,
        simulatedDelay: Duration.zero,
      );

      final topic1 = await service.getQuestionsByTopic(1);
      final topic12 = await service.getQuestionsByTopic(12);
      final topic2 = await service.getQuestionsByTopic(2);
      final invalidTopic = await service.getQuestionsByTopic(99);

      expect(topic1.length, 1);
      expect(topic1.first.id, 'Q01');
      expect(topic1.first.topicId, 1);

      expect(topic12.length, 1);
      expect(topic12.first.id, 'Q02');
      expect(topic12.first.topicId, 12);

      expect(topic2, isEmpty);
      expect(invalidTopic, isEmpty);
    });

    test('simulateError ném ngoại lệ ở getTopics và getQuestionsByTopic',
            () async {
          final service = QuestionService(
            loadFromAssets: false,
            simulatedDelay: Duration.zero,
          )..simulateError = true;

          await expectLater(service.getTopics(), throwsException);
          await expectLater(service.getQuestionsByTopic(1), throwsException);
        });

    test('simulateEmpty trả về danh sách rỗng', () async {
      final service = QuestionService(
        loadFromAssets: false,
        simulatedDelay: Duration.zero,
      )..simulateEmpty = true;

      expect(await service.getTopics(), isEmpty);
      expect(await service.getQuestionsByTopic(null), isEmpty);
    });

    test('Đọc JSON hợp lệ từ AssetBundle với cả camelCase và snake_case',
            () async {
          const sampleJson = '''
      {
        "questions": [
          {
            "id": "Q101",
            "topicId": 1,
            "questionVi": "Câu hỏi 1",
            "questionEn": "Question 1",
            "optionsVi": ["A1", "B1"],
            "optionsEn": ["A1 EN", "B1 EN"],
            "correctIndex": 0,
            "explanationVi": "Giải thích 1",
            "explanationEn": "Explanation 1"
          },
          {
            "id": "Q102",
            "topic_id": 2,
            "question_vi": "Câu hỏi 2",
            "question_en": "Question 2",
            "options_vi": ["A2", "B2", "C2"],
            "options_en": ["A2 EN", "B2 EN", "C2 EN"],
            "correct_index": 2,
            "explanation_vi": "Giải thích 2",
            "explanation_en": "Explanation 2"
          }
        ]
      }
      ''';

          final service = QuestionService(
            assetBundle: _FakeAssetBundle((_) async => sampleJson),
            simulatedDelay: Duration.zero,
          );

          final topics = await service.getTopics();
          final allQuestions = await service.getQuestionsByTopic(null);

          expect(service.isUsingFallbackData, isFalse);
          expect(service.skippedQuestionCount, 0);
          expect(service.lastLoadWarnings, isEmpty);
          expect(allQuestions.length, 2);
          expect(topics.firstWhere((t) => t.id == 1).questionCount, 1);
          expect(topics.firstWhere((t) => t.id == 2).questionCount, 1);
        });

    test('Fallback sang dữ liệu mẫu khi không tìm thấy tệp asset', () async {
      final service = QuestionService(
        assetBundle: _FakeAssetBundle((key) async {
          throw FlutterError('Unable to load asset: "$key".');
        }),
        simulatedDelay: Duration.zero,
      );

      final questions = await service.getQuestionsByTopic(null);

      expect(questions.length, 3);
      expect(service.isUsingFallbackData, isTrue);
    });

    test('JSON sai cú pháp báo lỗi rõ ràng và không fallback sang dữ liệu mẫu',
            () async {
          final service = QuestionService(
            assetBundle: _FakeAssetBundle((_) async => '{ invalid json'),
            simulatedDelay: Duration.zero,
          );

          await expectLater(service.getQuestionsByTopic(null), throwsException);
          expect(service.isUsingFallbackData, isFalse);
        });

    test('JSON hợp lệ nhưng mảng rỗng trả về rỗng và không dùng dữ liệu mẫu',
            () async {
          final service = QuestionService(
            assetBundle: _FakeAssetBundle((_) async => '{"questions": []}'),
            simulatedDelay: Duration.zero,
          );

          final questions = await service.getQuestionsByTopic(null);

          expect(questions, isEmpty);
          expect(service.isUsingFallbackData, isFalse);
          expect(service.skippedQuestionCount, 0);
        });

    test('Bỏ qua câu hỏi lỗi cục bộ nhưng ghi nhận cảnh báo đầy đủ', () async {
      const mixedJson = '''
      [
        {
          "id": "Q01",
          "topicId": 1,
          "questionVi": "Hợp lệ",
          "questionEn": "Valid",
          "optionsVi": ["A", "B"],
          "optionsEn": ["A", "B"],
          "correctIndex": 1
        },
        {
          "id": "q01",
          "topicId": 1,
          "questionVi": "Trùng ID không phân biệt hoa thường",
          "questionEn": "Duplicate ID",
          "optionsVi": ["A", "B"],
          "optionsEn": ["A", "B"],
          "correctIndex": 0
        },
        {
          "id": "Q02",
          "topicId": 25,
          "questionVi": "Sai topicId",
          "questionEn": "Invalid topicId",
          "optionsVi": ["A", "B"],
          "optionsEn": ["A", "B"],
          "correctIndex": 0
        },
        {
          "id": "Q03",
          "topicId": 1,
          "questionVi": "Lệch số đáp án",
          "questionEn": "Option count mismatch",
          "optionsVi": ["A", "B", "C"],
          "optionsEn": ["A", "B"],
          "correctIndex": 0
        },
        {
          "id": "Q04",
          "topicId": 1,
          "questionVi": "Sai correctIndex",
          "questionEn": "Out of range",
          "optionsVi": ["A", "B"],
          "optionsEn": ["A", "B"],
          "correctIndex": 5
        }
      ]
      ''';

      final service = QuestionService(
        assetBundle: _FakeAssetBundle((_) async => mixedJson),
        simulatedDelay: Duration.zero,
      );

      final questions = await service.getQuestionsByTopic(null);

      expect(questions.length, 1);
      expect(questions.first.id, 'Q01');
      expect(service.skippedQuestionCount, 4);
      expect(service.lastLoadWarnings.length, 4);
    });

    test('JSON có phần tử nhưng 100% sai định dạng phải báo lỗi nghiêm trọng',
            () async {
          const allInvalidJson = '''
      [
        {
          "id": "Q_BAD",
          "topicId": 99,
          "questionVi": "Sai",
          "questionEn": "Invalid",
          "optionsVi": ["A", "B"],
          "optionsEn": ["A", "B"],
          "correctIndex": 0
        }
      ]
      ''';

          final service = QuestionService(
            assetBundle: _FakeAssetBundle((_) async => allInvalidJson),
            simulatedDelay: Duration.zero,
          );

          await expectLater(service.getQuestionsByTopic(null), throwsException);
          expect(service.skippedQuestionCount, 1);
          expect(service.lastLoadWarnings, isNotEmpty);
        });

    test('Chống đọc JSON lặp khi gọi đồng thời và clearCache nạp lại đúng',
            () async {
          var loadCalls = 0;
          const validJson = '''
      [
        {
          "id": "Q01",
          "topicId": 1,
          "questionVi": "Câu 1",
          "questionEn": "Question 1",
          "optionsVi": ["A", "B"],
          "optionsEn": ["A", "B"],
          "correctIndex": 0
        }
      ]
      ''';

          final service = QuestionService(
            assetBundle: _FakeAssetBundle((_) async {
              loadCalls++;
              await Future<void>.delayed(const Duration(milliseconds: 10));
              return validJson;
            }),
            simulatedDelay: Duration.zero,
          );

          await Future.wait([
            service.getTopics(),
            service.getQuestionsByTopic(null),
          ]);
          expect(loadCalls, 1);

          service.clearCache();
          await service.getTopics();
          expect(loadCalls, 2);
        });

    test('_cacheVersion ngăn tác vụ cũ ghi đè cache và trạng thái sau clearCache',
            () async {
          final firstLoadCompleter = Completer<String>();
          var callNumber = 0;

          const freshJson = '''
      [
        {
          "id": "Q_NEW",
          "topicId": 3,
          "questionVi": "Dữ liệu mới",
          "questionEn": "Fresh data",
          "optionsVi": ["A", "B"],
          "optionsEn": ["A", "B"],
          "correctIndex": 1
        }
      ]
      ''';

          final service = QuestionService(
            assetBundle: _FakeAssetBundle((_) {
              callNumber++;
              if (callNumber == 1) {
                return firstLoadCompleter.future;
              }
              return Future<String>.value(freshJson);
            }),
            simulatedDelay: Duration.zero,
          );

          final staleRequest = service.getQuestionsByTopic(null);
          service.clearCache();
          final freshResult = await service.getQuestionsByTopic(null);

          // Hoàn tất tác vụ cũ bằng lỗi thiếu asset sau khi phiên mới đã nạp xong
          firstLoadCompleter.completeError(
            FlutterError('Unable to load asset: "assets/data/questions.json".'),
          );
          await staleRequest;

          expect(freshResult.length, 1);
          expect(freshResult.first.id, 'Q_NEW');
          expect(service.isUsingFallbackData, isFalse);

          final cachedAfterStale = await service.getQuestionsByTopic(null);
          expect(cachedAfterStale.length, 1);
          expect(cachedAfterStale.first.id, 'Q_NEW');
        });
  });

  group('QuizMaster - Widget Tests (Luồng chính)', () {
    QuestionService createTestService() {
      return QuestionService(
        loadFromAssets: false,
        simulatedDelay: Duration.zero,
      );
    }

    testWidgets('HomeScreen hiển thị tổng quan và chuyển đổi 3 chế độ ngôn ngữ',
            (tester) async {
          await tester.pumpWidget(
            QuizMasterApp(questionService: createTestService()),
          );

          expect(find.text('QuizMaster'), findsOneWidget);
          expect(find.text('300'), findsOneWidget);
          expect(find.text('20'), findsOneWidget);
          expect(find.text('Luyện tập nhanh'), findsOneWidget);
          expect(find.text('Chọn chủ đề'), findsOneWidget);

          await tester.tap(find.text('Song ngữ'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('English'));
          await tester.pumpAndSettle();

          expect(find.text('Quick Practice'), findsOneWidget);
          expect(find.text('Select Topic'), findsOneWidget);
        });

    testWidgets('TopicScreen hiển thị danh sách chủ đề và lọc tìm kiếm song ngữ',
            (tester) async {
          await tester.pumpWidget(
            QuizMasterApp(questionService: createTestService()),
          );

          await tester.ensureVisible(find.text('Chọn chủ đề'));
          await tester.tap(find.text('Chọn chủ đề'));
          await tester.pumpAndSettle();

          expect(find.text('Khám phá kiến thức'), findsOneWidget);
          expect(find.text('Khối 1: Dart cơ bản'), findsOneWidget);

          // Lọc theo tiếng Anh
          await tester.enterText(find.byType(TextField), 'State Management');
          await tester.pumpAndSettle();
          expect(find.text('Khối 12: Quản lý trạng thái'), findsOneWidget);
          expect(find.text('Khối 1: Dart cơ bản'), findsNothing);

          // Lọc không có kết quả và bấm xóa tìm kiếm
          await tester.enterText(find.byType(TextField), 'khong ton tai xyz');
          await tester.pumpAndSettle();
          expect(find.text('Không tìm thấy chủ đề phù hợp'), findsOneWidget);

          await tester.ensureVisible(find.text('Xóa tìm kiếm (Clear)'));
          await tester.tap(find.text('Xóa tìm kiếm (Clear)'));
          await tester.pumpAndSettle();
          expect(find.text('Khối 1: Dart cơ bản'), findsOneWidget);
        });

    testWidgets('TopicScreen xử lý trạng thái Error và Empty kèm nút lối ra',
            (tester) async {
          await tester.pumpWidget(
            QuizMasterApp(questionService: createTestService()),
          );

          await tester.ensureVisible(find.text('Chọn chủ đề'));
          await tester.tap(find.text('Chọn chủ đề'));
          await tester.pumpAndSettle();

          // Giả lập trạng thái Error
          await tester.tap(find.byIcon(Icons.bug_report_rounded));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Giả lập Lỗi (Error)'));
          await tester.pumpAndSettle();

          expect(find.text('Không thể tải danh sách chủ đề'), findsOneWidget);
          await tester.ensureVisible(find.text('Thử lại (Retry)'));
          await tester.tap(find.text('Thử lại (Retry)'));
          await tester.pumpAndSettle();
          expect(find.text('Khối 1: Dart cơ bản'), findsOneWidget);

          // Giả lập trạng thái Empty
          await tester.tap(find.byIcon(Icons.bug_report_rounded));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Giả lập Trống (Empty)'));
          await tester.pumpAndSettle();

          expect(find.text('Chưa có chủ đề nào (No topics yet)'), findsOneWidget);
          await tester.ensureVisible(find.text('Nạp lại dữ liệu (Reload)'));
          await tester.tap(find.text('Nạp lại dữ liệu (Reload)'));
          await tester.pumpAndSettle();
          expect(find.text('Khối 1: Dart cơ bản'), findsOneWidget);
        });

    testWidgets(
        'PracticeScreen chọn đáp án, khóa chọn lại, hiện giải thích và chuyển câu',
            (tester) async {
          await tester.pumpWidget(
            QuizMasterApp(questionService: createTestService()),
          );

          await tester.ensureVisible(find.text('Luyện tập nhanh'));
          await tester.tap(find.text('Luyện tập nhanh'));
          await tester.pumpAndSettle();

          expect(find.text('CÂU 01 / 03'), findsOneWidget);

          // Trước khi chọn đáp án, nút Câu tiếp theo bị vô hiệu hóa
          await tester.tap(find.text('Câu tiếp theo'));
          await tester.pumpAndSettle();
          expect(find.text('CÂU 01 / 03'), findsOneWidget);

          // Chọn đáp án đúng cho Q01
          await tester.ensureVisible(find.text('main()'));
          await tester.tap(find.text('main()'));
          await tester.pumpAndSettle();

          expect(find.text('Chính xác! · Correct!'), findsOneWidget);
          expect(find.text('1 đúng'), findsOneWidget);

          // Sau khi nộp không cho phép đổi đáp án
          await tester.ensureVisible(find.text('startApp()'));
          await tester.tap(find.text('startApp()'));
          await tester.pumpAndSettle();
          expect(find.text('Chính xác! · Correct!'), findsOneWidget);
          expect(find.text('1 đúng'), findsOneWidget);

          // Chuyển sang câu tiếp theo
          await tester.tap(find.text('Câu tiếp theo'));
          await tester.pumpAndSettle();
          expect(find.text('CÂU 02 / 03'), findsOneWidget);
        });
  });
}