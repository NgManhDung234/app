import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum DisplayLanguage { vi, en, bilingual }

class TopicItem {
  final int id;
  final String nameVi;
  final String nameEn;
  final int questionCount;

  const TopicItem({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.questionCount,
  });

  TopicItem copyWith({
    int? id,
    String? nameVi,
    String? nameEn,
    int? questionCount,
  }) {
    return TopicItem(
      id: id ?? this.id,
      nameVi: nameVi ?? this.nameVi,
      nameEn: nameEn ?? this.nameEn,
      questionCount: questionCount ?? this.questionCount,
    );
  }
}

class QuestionItem {
  final String id;
  final int topicId;
  final String questionVi;
  final String questionEn;
  final List<String> optionsVi;
  final List<String> optionsEn;
  final int correctIndex;
  final String explanationVi;
  final String explanationEn;

  const QuestionItem({
    required this.id,
    required this.topicId,
    required this.questionVi,
    required this.questionEn,
    required this.optionsVi,
    required this.optionsEn,
    required this.correctIndex,
    required this.explanationVi,
    required this.explanationEn,
  });

  /// Kiểm tra tính hợp lệ của câu hỏi đối với bộ [validTopicIds].
  bool isValid({Set<int>? validTopicIds}) {
    return validate(validTopicIds: validTopicIds) == null;
  }

  /// Trả về thông báo lỗi cụ thể nếu câu hỏi không hợp lệ, hoặc `null` nếu hợp lệ.
  String? validate({Set<int>? validTopicIds}) {
    if (id.trim().isEmpty) {
      return 'mã câu hỏi (id) bị trống';
    }

    if (validTopicIds != null) {
      if (!validTopicIds.contains(topicId)) {
        return 'topicId=$topicId không thuộc 20 chủ đề hợp lệ';
      }
    } else if (topicId <= 0) {
      return 'topicId=$topicId phải là số nguyên dương';
    }

    if (questionVi.trim().isEmpty || questionEn.trim().isEmpty) {
      return 'nội dung câu hỏi tiếng Việt hoặc tiếng Anh bị trống';
    }

    if (optionsVi.length < 2) {
      return 'danh sách đáp án phải có ít nhất 2 phương án';
    }

    if (optionsVi.length != optionsEn.length) {
      return 'số lượng đáp án optionsVi (${optionsVi.length}) và optionsEn (${optionsEn.length}) không bằng nhau';
    }

    if (optionsVi.any((opt) => opt.trim().isEmpty) ||
        optionsEn.any((opt) => opt.trim().isEmpty)) {
      return 'có phương án trả lời bị rỗng';
    }

    if (correctIndex < 0 || correctIndex >= optionsVi.length) {
      return 'correctIndex=$correctIndex nằm ngoài phạm vi đáp án (0..${optionsVi.length - 1})';
    }

    return null;
  }

  /// Chuyển đổi an toàn một đối tượng JSON sang [QuestionItem].
  /// Trả về `null` nếu thiếu trường bắt buộc hoặc dữ liệu sai định dạng.
  static QuestionItem? tryFromJson(
      Map<String, dynamic> json, {
        Set<int>? validTopicIds,
      }) {
    return _parseFromJsonWithError(
      json,
      validTopicIds: validTopicIds,
    ).item;
  }

  static _QuestionParseResult _parseFromJsonWithError(
      Map<String, dynamic> json, {
        Set<int>? validTopicIds,
      }) {
    final id = _readRequiredString(json, const ['id']);
    if (id == null) {
      return const _QuestionParseResult.error(
        'thiếu hoặc sai kiểu trường "id" (cần chuỗi không rỗng)',
      );
    }

    final topicId = _readRequiredInt(json, const ['topicId', 'topic_id']);
    if (topicId == null) {
      return _QuestionParseResult.error(
        'id="$id": thiếu hoặc sai kiểu trường "topicId"',
      );
    }

    final questionVi =
    _readRequiredString(json, const ['questionVi', 'question_vi']);
    final questionEn =
    _readRequiredString(json, const ['questionEn', 'question_en']);
    if (questionVi == null || questionEn == null) {
      return _QuestionParseResult.error(
        'id="$id": thiếu hoặc sai kiểu trường "questionVi"/"questionEn"',
      );
    }

    final optionsVi =
    _readRequiredStringList(json, const ['optionsVi', 'options_vi']);
    final optionsEn =
    _readRequiredStringList(json, const ['optionsEn', 'options_en']);
    if (optionsVi == null || optionsEn == null) {
      return _QuestionParseResult.error(
        'id="$id": thiếu hoặc sai kiểu danh sách "optionsVi"/"optionsEn"',
      );
    }

    final correctIndex =
    _readRequiredInt(json, const ['correctIndex', 'correct_index']);
    if (correctIndex == null) {
      return _QuestionParseResult.error(
        'id="$id": thiếu hoặc sai kiểu trường "correctIndex"',
      );
    }

    final explanationViResult =
    _readOptionalString(json, const ['explanationVi', 'explanation_vi']);
    if (explanationViResult.hasTypeError) {
      return _QuestionParseResult.error(
        'id="$id": trường "explanationVi" sai kiểu dữ liệu (cần chuỗi văn bản)',
      );
    }

    final explanationEnResult =
    _readOptionalString(json, const ['explanationEn', 'explanation_en']);
    if (explanationEnResult.hasTypeError) {
      return _QuestionParseResult.error(
        'id="$id": trường "explanationEn" sai kiểu dữ liệu (cần chuỗi văn bản)',
      );
    }

    final item = QuestionItem(
      id: id,
      topicId: topicId,
      questionVi: questionVi,
      questionEn: questionEn,
      optionsVi: List<String>.unmodifiable(
        optionsVi.map((option) => option.trim()),
      ),
      optionsEn: List<String>.unmodifiable(
        optionsEn.map((option) => option.trim()),
      ),
      correctIndex: correctIndex,
      explanationVi: explanationViResult.value,
      explanationEn: explanationEnResult.value,
    );

    final validationError = item.validate(validTopicIds: validTopicIds);
    if (validationError != null) {
      return _QuestionParseResult.error('id="$id": $validationError');
    }

    return _QuestionParseResult.valid(item);
  }

  static String? _readRequiredString(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      return null;
    }
    return null;
  }

  static _OptionalStringResult _readOptionalString(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (value == null) {
        return const _OptionalStringResult(value: '', hasTypeError: false);
      }
      if (value is String) {
        return _OptionalStringResult(
          value: value.trim(),
          hasTypeError: false,
        );
      }
      return const _OptionalStringResult(value: '', hasTypeError: true);
    }
    return const _OptionalStringResult(value: '', hasTypeError: false);
  }

  static int? _readRequiredInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (value is int) return value;
      if (value is num && value == value.toInt()) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
      return null;
    }
    return null;
  }

  static List<String>? _readRequiredStringList(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (value is! List) return null;

      final result = <String>[];
      for (final element in value) {
        if (element is! String) return null;
        result.add(element);
      }
      return result;
    }
    return null;
  }
}

class _QuestionParseResult {
  final QuestionItem? item;
  final String? error;

  const _QuestionParseResult.valid(this.item) : error = null;
  const _QuestionParseResult.error(this.error) : item = null;
}

class _OptionalStringResult {
  final String value;
  final bool hasTypeError;

  const _OptionalStringResult({
    required this.value,
    required this.hasTypeError,
  });
}

class _QuestionLoadResult {
  final List<QuestionItem> questions;
  final bool isUsingFallbackData;
  final List<String> warnings;
  final int skippedCount;

  const _QuestionLoadResult({
    required this.questions,
    required this.isUsingFallbackData,
    required this.warnings,
    required this.skippedCount,
  });
}

class _QuestionValidationException implements Exception {
  final String message;
  final List<String> warnings;
  final int skippedCount;

  const _QuestionValidationException({
    required this.message,
    required this.warnings,
    required this.skippedCount,
  });

  @override
  String toString() => message;
}

class QuestionService {
  /// Đường dẫn mặc định tới tệp ngân hàng 300 câu hỏi trong thư mục assets.
  static const String defaultAssetPath = 'assets/data/questions.json';

  /// Khung 20 khối kiến thức Flutter chuẩn của đề tài.
  static const List<TopicItem> _topicCatalog = [
    TopicItem(
      id: 1,
      nameVi: 'Khối 1: Dart cơ bản',
      nameEn: 'Module 1: Dart Basics',
      questionCount: 0,
    ),
    TopicItem(
      id: 2,
      nameVi: 'Khối 2: Công cụ phát triển',
      nameEn: 'Module 2: Development Tools',
      questionCount: 0,
    ),
    TopicItem(
      id: 3,
      nameVi: 'Khối 3: Cách Flutter hoạt động',
      nameEn: 'Module 3: How Flutter Works',
      questionCount: 0,
    ),
    TopicItem(
      id: 4,
      nameVi: 'Khối 4: Bố cục (Layout)',
      nameEn: 'Module 4: Layouts',
      questionCount: 0,
    ),
    TopicItem(
      id: 5,
      nameVi: 'Khối 5: Thiết kế (Design & Theming)',
      nameEn: 'Module 5: Design & Theming',
      questionCount: 0,
    ),
    TopicItem(
      id: 6,
      nameVi: 'Khối 6: Giao diện thích ứng',
      nameEn: 'Module 6: Adaptive UI',
      questionCount: 0,
    ),
    TopicItem(
      id: 7,
      nameVi: 'Khối 7: Tương tác người dùng',
      nameEn: 'Module 7: User Interaction',
      questionCount: 0,
    ),
    TopicItem(
      id: 8,
      nameVi: 'Khối 8: Tài nguyên & Assets',
      nameEn: 'Module 8: Assets & Resources',
      questionCount: 0,
    ),
    TopicItem(
      id: 9,
      nameVi: 'Khối 9: Điều hướng (Navigation)',
      nameEn: 'Module 9: Navigation & Routing',
      questionCount: 0,
    ),
    TopicItem(
      id: 10,
      nameVi: 'Khối 10: Hoạt ảnh (Animations)',
      nameEn: 'Module 10: Animations',
      questionCount: 0,
    ),
    TopicItem(
      id: 11,
      nameVi: 'Khối 11: Trợ năng & Đa ngôn ngữ',
      nameEn: 'Module 11: Accessibility & i18n',
      questionCount: 0,
    ),
    TopicItem(
      id: 12,
      nameVi: 'Khối 12: Quản lý trạng thái',
      nameEn: 'Module 12: State Management',
      questionCount: 0,
    ),
    TopicItem(
      id: 13,
      nameVi: 'Khối 13: Dữ liệu & Backend',
      nameEn: 'Module 13: Data & Backend',
      questionCount: 0,
    ),
    TopicItem(
      id: 14,
      nameVi: 'Khối 14: Kiến trúc ứng dụng',
      nameEn: 'Module 14: App Architecture',
      questionCount: 0,
    ),
    TopicItem(
      id: 15,
      nameVi: 'Khối 15: Gói & Thư viện (Packages)',
      nameEn: 'Module 15: Packages & Plugins',
      questionCount: 0,
    ),
    TopicItem(
      id: 16,
      nameVi: 'Khối 16: Kiểm thử (Testing)',
      nameEn: 'Module 16: Testing',
      questionCount: 0,
    ),
    TopicItem(
      id: 17,
      nameVi: 'Khối 17: Hiệu năng (Performance)',
      nameEn: 'Module 17: Performance',
      questionCount: 0,
    ),
    TopicItem(
      id: 18,
      nameVi: 'Khối 18: Tích hợp nền tảng',
      nameEn: 'Module 18: Platform Integration',
      questionCount: 0,
    ),
    TopicItem(
      id: 19,
      nameVi: 'Khối 19: Triển khai (Deployment)',
      nameEn: 'Module 19: Deployment',
      questionCount: 0,
    ),
    TopicItem(
      id: 20,
      nameVi: 'Khối 20: Trí tuệ nhân tạo (AI)',
      nameEn: 'Module 20: AI in Flutter',
      questionCount: 0,
    ),
  ];

  static final Set<int> _validTopicIds = Set<int>.unmodifiable(
    _topicCatalog.map((topic) => topic.id),
  );

  /// Dữ liệu mẫu tạm thời dùng khi dự án chưa tích hợp tệp JSON 300 câu thực tế.
  /// Mỗi câu hỏi giữ nguyên đúng topicId thật của nó (1, 12, 8).
  static const List<QuestionItem> _sampleQuestions = [
    QuestionItem(
      id: 'Q01',
      topicId: 1,
      questionVi:
      'Hàm nào là điểm bắt đầu (entry point) của mọi ứng dụng Flutter?',
      questionEn:
      'Which function serves as the entry point of every Flutter application?',
      optionsVi: ['startApp()', 'main()', 'initState()', 'build()'],
      optionsEn: ['startApp()', 'main()', 'initState()', 'build()'],
      correctIndex: 1,
      explanationVi:
      'Trong Dart và Flutter, hàm main() luôn là điểm khởi đầu thực thi chương trình, bên trong thường gọi runApp().',
      explanationEn:
      'In Dart and Flutter, the main() function is always the execution entry point, which typically calls runApp().',
    ),
    QuestionItem(
      id: 'Q02',
      topicId: 12,
      questionVi:
      'Khi dữ liệu nội bộ thay đổi trong StatefulWidget, ta gọi hàm nào để vẽ lại giao diện?',
      questionEn:
      'When internal data changes in a StatefulWidget, which method triggers a UI rebuild?',
      optionsVi: ['rebuild()', 'updateUI()', 'setState()', 'notifyListeners()'],
      optionsEn: ['rebuild()', 'updateUI()', 'setState()', 'notifyListeners()'],
      correctIndex: 2,
      explanationVi:
      'setState() báo cho Flutter framework biết trạng thái nội bộ đã thay đổi và cần gọi lại hàm build() của State đó.',
      explanationEn:
      'setState() notifies the Flutter framework that the internal state has changed and schedules a build() for that State object.',
    ),
    QuestionItem(
      id: 'Q03',
      topicId: 8,
      questionVi:
      'Để khai báo tệp dữ liệu JSON hoặc hình ảnh trong dự án Flutter, ta cấu hình ở tệp nào?',
      questionEn:
      'Which file is used to declare JSON data files or images in a Flutter project?',
      optionsVi: [
        'AndroidManifest.xml',
        'pubspec.yaml',
        'main.dart',
        'config.json',
      ],
      optionsEn: [
        'AndroidManifest.xml',
        'pubspec.yaml',
        'main.dart',
        'config.json',
      ],
      correctIndex: 1,
      explanationVi:
      'Mọi tài nguyên đóng gói kèm ứng dụng (như bộ 300 câu hỏi JSON) phải được khai báo dưới mục flutter -> assets trong tệp pubspec.yaml.',
      explanationEn:
      'All bundled assets (such as the 300-question JSON file) must be declared under the flutter -> assets section in pubspec.yaml.',
    ),
  ];

  // Cờ giả lập lỗi và rỗng phục vụ kiểm thử & Demo Rubric
  bool simulateError = false;
  bool simulateEmpty = false;

  final String assetPath;
  final AssetBundle? _assetBundle;
  final bool loadFromAssets;
  final Duration simulatedDelay;

  List<QuestionItem>? _cachedQuestions;
  Future<List<QuestionItem>>? _inFlightLoad;
  int _cacheVersion = 0;

  bool _usingFallbackData = false;
  List<String> _lastLoadWarnings = const [];
  int _skippedQuestionCount = 0;

  QuestionService({
    this.assetPath = defaultAssetPath,
    this._assetBundle,
    this.loadFromAssets = true,
    this.simulatedDelay = const Duration(milliseconds: 300),
  });
  /// Cho biết hiện tại service đang dùng dữ liệu mẫu dự phòng (chưa có tệp JSON thật).
  bool get isUsingFallbackData => _usingFallbackData;

  /// Danh sách cảnh báo của các câu hỏi bị bỏ qua trong lần nạp gần nhất.
  List<String> get lastLoadWarnings => _lastLoadWarnings;

  /// Số lượng mục dữ liệu bị loại do không hợp lệ trong lần nạp gần nhất.
  int get skippedQuestionCount => _skippedQuestionCount;

  /// Xóa bộ nhớ đệm và tăng phiên cache để các tác vụ cũ đang chạy không thể ghi đè.
  void clearCache() {
    _cacheVersion++;
    _cachedQuestions = null;
    _inFlightLoad = null;
    _usingFallbackData = false;
    _lastLoadWarnings = const [];
    _skippedQuestionCount = 0;
  }

  /// Lấy danh sách 20 chủ đề kiến thức kèm số lượng câu hỏi thực tế của từng chủ đề.
  Future<List<TopicItem>> getTopics() async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }

    if (simulateError) {
      throw Exception(
        'Không thể đọc tệp dữ liệu JSON. Vui lòng kiểm tra lại tài nguyên.',
      );
    }
    if (simulateEmpty) {
      return const [];
    }

    final questions = await _loadAllValidQuestions();
    final countsByTopic = <int, int>{};
    for (final question in questions) {
      countsByTopic[question.topicId] =
          (countsByTopic[question.topicId] ?? 0) + 1;
    }

    return List<TopicItem>.unmodifiable(
      _topicCatalog.map(
            (topic) => topic.copyWith(
          questionCount: countsByTopic[topic.id] ?? 0,
        ),
      ),
    );
  }

  /// Lấy danh sách câu hỏi theo [topicId]:
  /// - Nếu [topicId] == `null`: trả về toàn bộ câu hỏi hợp lệ (Luyện tập tổng hợp).
  /// - Nếu [topicId] != `null`: chỉ trả về các câu thuộc đúng [topicId].
  /// - Nếu [topicId] không hợp lệ hoặc không có câu hỏi: trả về danh sách rỗng `[]`.
  Future<List<QuestionItem>> getQuestionsByTopic(int? topicId) async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }

    if (simulateError) {
      throw Exception('Lỗi nạp danh sách câu hỏi từ bộ nhớ cục bộ.');
    }
    if (simulateEmpty) {
      return const [];
    }

    final allQuestions = await _loadAllValidQuestions();

    if (topicId == null) {
      return List<QuestionItem>.unmodifiable(allQuestions);
    }

    if (!_validTopicIds.contains(topicId)) {
      return const [];
    }

    final filtered = allQuestions
        .where((question) => question.topicId == topicId)
        .toList(growable: false);

    return List<QuestionItem>.unmodifiable(filtered);
  }

  /// Phân tích chuỗi JSON sang danh sách [QuestionItem] hợp lệ.
  /// Hỗ trợ cả định dạng gốc là mảng JSON `[...]` lẫn đối tượng `{ "questions": [...] }`.
  static List<QuestionItem> parseQuestionsJson(String rawJson) {
    final result = _parseQuestionsJsonWithReport(rawJson);
    return result.questions;
  }

  static _QuestionLoadResult _parseQuestionsJsonWithReport(String rawJson) {
    if (rawJson.trim().isEmpty) {
      throw const FormatException(
        'Tệp JSON bị trống, không có nội dung dữ liệu.',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException catch (e) {
      throw FormatException('Cú pháp JSON không hợp lệ (${e.message}).');
    }

    final List<dynamic> rawList;
    if (decoded is List<dynamic>) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic> &&
        decoded['questions'] is List<dynamic>) {
      rawList = decoded['questions'] as List<dynamic>;
    } else {
      throw const FormatException(
        'Cấu trúc JSON không hợp lệ: cần mảng danh sách câu hỏi hoặc đối tượng chứa trường "questions" dạng mảng.',
      );
    }

    // JSON hợp lệ nhưng chưa có câu hỏi nào -> trả về danh sách rỗng (không báo lỗi)
    if (rawList.isEmpty) {
      return const _QuestionLoadResult(
        questions: [],
        isUsingFallbackData: false,
        warnings: [],
        skippedCount: 0,
      );
    }

    final validQuestions = <QuestionItem>[];
    final warnings = <String>[];
    final seenIdsNormalized = <String>{};

    for (int i = 0; i < rawList.length; i++) {
      final entry = rawList[i];
      final itemNumber = i + 1;

      if (entry is! Map<String, dynamic>) {
        warnings.add(
          'Mục #$itemNumber: không phải đối tượng JSON hợp lệ.',
        );
        continue;
      }

      final parseResult = QuestionItem._parseFromJsonWithError(
        entry,
        validTopicIds: _validTopicIds,
      );

      final question = parseResult.item;
      if (question == null) {
        warnings.add(
          'Mục #$itemNumber: ${parseResult.error ?? "dữ liệu không hợp lệ"}.',
        );
        continue;
      }

      final normalizedId = question.id.toLowerCase();
      if (!seenIdsNormalized.add(normalizedId)) {
        warnings.add(
          'Mục #$itemNumber: trùng mã câu hỏi id="${question.id}".',
        );
        continue;
      }

      validQuestions.add(question);
    }

    // Nếu tệp có dữ liệu nhưng 100% mục đều sai định dạng -> báo lỗi rõ ràng thay vì im lặng trả về rỗng
    if (validQuestions.isEmpty) {
      final firstReason =
      warnings.isNotEmpty ? warnings.first : 'dữ liệu sai cấu trúc.';
      throw _QuestionValidationException(
        message:
        'Dữ liệu JSON câu hỏi bị lỗi định dạng: không có câu hỏi hợp lệ nào trong ${rawList.length} mục ($firstReason)',
        warnings: List<String>.unmodifiable(warnings),
        skippedCount: warnings.length,
      );
    }

    return _QuestionLoadResult(
      questions: List<QuestionItem>.unmodifiable(validQuestions),
      isUsingFallbackData: false,
      warnings: List<String>.unmodifiable(warnings),
      skippedCount: warnings.length,
    );
  }

  Future<List<QuestionItem>> _loadAllValidQuestions() {
    if (_cachedQuestions != null) {
      return Future<List<QuestionItem>>.value(_cachedQuestions!);
    }

    if (_inFlightLoad != null) {
      return _inFlightLoad!;
    }

    final loadVersion = _cacheVersion;
    final future = _fetchAndValidateQuestions(loadVersion);
    _inFlightLoad = future;
    return future;
  }

  Future<List<QuestionItem>> _fetchAndValidateQuestions(
      int loadVersion,
      ) async {
    try {
      final loadResult = await _readQuestionsFromSource();

      // Bảo đảm tác vụ cũ không ghi đè cache, cảnh báo hay cờ fallback của phiên mới
      if (loadVersion == _cacheVersion) {
        _cachedQuestions = loadResult.questions;
        _usingFallbackData = loadResult.isUsingFallbackData;
        _lastLoadWarnings = loadResult.warnings;
        _skippedQuestionCount = loadResult.skippedCount;
        _logLoadSummary(loadResult);
      }

      return loadResult.questions;
    } on _QuestionValidationException catch (e) {
      if (loadVersion == _cacheVersion) {
        _usingFallbackData = false;
        _lastLoadWarnings = e.warnings;
        _skippedQuestionCount = e.skippedCount;
        _logValidationWarnings(e.warnings, totalSkipped: e.skippedCount);
      }
      throw Exception(e.message);
    } on FormatException catch (e) {
      if (loadVersion == _cacheVersion) {
        _usingFallbackData = false;
        _lastLoadWarnings = const [];
        _skippedQuestionCount = 0;
      }
      throw Exception('Dữ liệu JSON câu hỏi bị lỗi định dạng: ${e.message}');
    } finally {
      if (loadVersion == _cacheVersion) {
        _inFlightLoad = null;
      }
    }
  }

  Future<_QuestionLoadResult> _readQuestionsFromSource() async {
    if (!loadFromAssets) {
      return _buildFallbackSampleResult();
    }

    final bundle = _assetBundle ?? rootBundle;
    final String rawJson;
    try {
      rawJson = await bundle.loadString(assetPath);
    } on FlutterError catch (e) {
      if (_isMissingAssetError(e)) {
        return _buildFallbackSampleResult();
      }
      throw Exception(
        'Không thể truy cập tài nguyên "$assetPath": ${e.message}',
      );
    }

    return _parseQuestionsJsonWithReport(rawJson);
  }

  bool _isMissingAssetError(FlutterError error) {
    final lowerMessage = error.message.toLowerCase();
    return lowerMessage.contains('unable to load asset');
  }

  _QuestionLoadResult _buildFallbackSampleResult() {
    final validSamples = <QuestionItem>[];
    final warnings = <String>[];
    final seenIds = <String>{};

    for (int i = 0; i < _sampleQuestions.length; i++) {
      final sample = _sampleQuestions[i];
      final error = sample.validate(validTopicIds: _validTopicIds);
      if (error != null) {
        warnings.add('Câu mẫu #${i + 1}: $error.');
        continue;
      }
      if (!seenIds.add(sample.id.toLowerCase())) {
        warnings.add('Câu mẫu #${i + 1}: trùng mã câu hỏi id="${sample.id}".');
        continue;
      }
      validSamples.add(sample);
    }

    return _QuestionLoadResult(
      questions: List<QuestionItem>.unmodifiable(validSamples),
      isUsingFallbackData: true,
      warnings: List<String>.unmodifiable(warnings),
      skippedCount: warnings.length,
    );
  }

  void _logLoadSummary(_QuestionLoadResult result) {
    if (!kDebugMode) return;

    if (result.isUsingFallbackData) {
      debugPrint(
        '[QuestionService] Không tìm thấy tệp "$assetPath". '
            'Đang sử dụng ${result.questions.length} câu hỏi mẫu dự phòng.',
      );
    }

    if (result.skippedCount > 0) {
      _logValidationWarnings(
        result.warnings,
        totalSkipped: result.skippedCount,
      );
    }
  }

  void _logValidationWarnings(
      List<String> warnings, {
        required int totalSkipped,
      }) {
    if (!kDebugMode || warnings.isEmpty) return;

    const maxPreview = 5;
    debugPrint(
      '[QuestionService] Cảnh báo dữ liệu: đã bỏ qua $totalSkipped câu hỏi không hợp lệ.',
    );
    final previewCount =
    warnings.length < maxPreview ? warnings.length : maxPreview;
    for (int i = 0; i < previewCount; i++) {
      debugPrint('  - ${warnings[i]}');
    }
    if (warnings.length > maxPreview) {
      debugPrint(
        '  ... và còn ${warnings.length - maxPreview} cảnh báo khác (xem lastLoadWarnings).',
      );
    }
  }
}