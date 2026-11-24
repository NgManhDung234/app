import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import 'question_service.dart';

enum DisplayLanguage { vi, en, bilingual }

class TopicItem {
  final String id;
  final int order;
  final String nameVi;
  final String nameEn;
  final String tier;
  final int questionCount;

  const TopicItem({
    required this.id,
    required this.order,
    required this.nameVi,
    required this.nameEn,
    required this.tier,
    required this.questionCount,
  });

  String displayName(DisplayLanguage language) {
    switch (language) {
      case DisplayLanguage.vi:
        return nameVi;
      case DisplayLanguage.en:
        return nameEn;
      case DisplayLanguage.bilingual:
        if (nameEn.isEmpty || nameEn == nameVi) return nameVi;
        return '$nameVi · $nameEn';
    }
  }
}

class QuestionItem {
  final String id;
  final int number;
  final String topicId;
  final String topicNameVi;
  final String topicNameEn;
  final String difficulty;
  final String questionVi;
  final String questionEn;
  final String codeSnippet;
  final List<String> optionsVi;
  final List<String> optionsEn;
  final int correctIndex;
  final String explanationVi;
  final String explanationEn;
  final String referenceUrl;

  const QuestionItem({
    required this.id,
    required this.number,
    required this.topicId,
    required this.topicNameVi,
    required this.topicNameEn,
    required this.difficulty,
    required this.questionVi,
    required this.questionEn,
    required this.codeSnippet,
    required this.optionsVi,
    required this.optionsEn,
    required this.correctIndex,
    required this.explanationVi,
    required this.explanationEn,
    required this.referenceUrl,
  });
}

class QuizSummaryStats {
  final int questionCount;
  final int topicCount;

  const QuizSummaryStats({
    required this.questionCount,
    required this.topicCount,
  });
}

/// Lớp cầu nối (Adapter/Repository) giữa tầng dữ liệu của TV1 (`QuestionService`,
/// `Question`) và giao diện Modern Minimal của TV2.
///
/// - Giữ nguyên 100% mã nguồn của TV1 để không gây xung đột với TV1 & TV3.
/// - Hỗ trợ Dependency Injection (`customLoader`) để thay bằng dữ liệu giả khi test.
/// - Hỗ trợ cờ `simulateError` / `simulateEmpty` để demo trạng thái Lỗi / Trống.
class QuizRepository {
  final QuestionService _questionService;
  final Future<List<Question>> Function()? _customLoader;
  final Duration simulatedDelay;

  bool simulateError = false;
  bool simulateEmpty = false;

  List<QuestionItem>? _cachedQuestions;
  List<TopicItem>? _cachedTopics;
  Future<void>? _inFlightLoad;
  int _cacheVersion = 0;

  QuizRepository({
    QuestionService? questionService,
    Future<List<Question>> Function()? customLoader,
    this.simulatedDelay = Duration.zero,
  })  : _questionService = questionService ?? QuestionService(),
        _customLoader = customLoader;

  /// Tách tên khối song ngữ dạng `"K01: Ngôn ngữ Dart · The Dart language"`
  static ({String vi, String en}) parseBilingualBlockName(
    String blockId,
    String rawBlockName,
  ) {
    var cleaned = rawBlockName.trim();
    final idPrefix = '${blockId.trim()}:';
    if (cleaned.toUpperCase().startsWith(idPrefix.toUpperCase())) {
      cleaned = cleaned.substring(idPrefix.length).trim();
    } else {
      final colonIdx = cleaned.indexOf(':');
      if (colonIdx > 0 && colonIdx <= 6) {
        cleaned = cleaned.substring(colonIdx + 1).trim();
      }
    }

    if (cleaned.isEmpty) {
      return (vi: blockId, en: blockId);
    }

    final separators = ['·', '•', '|'];
    for (final sep in separators) {
      if (cleaned.contains(sep)) {
        final parts = cleaned.split(sep);
        final vi = parts.first.trim();
        final en = parts.sublist(1).join(sep).trim();
        return (
          vi: vi.isNotEmpty ? vi : cleaned,
          en: en.isNotEmpty ? en : vi,
        );
      }
    }

    return (vi: cleaned, en: cleaned);
  }

  /// Trích xuất số thứ tự từ mã khối (`K01` -> `1`, `K20` -> `20`)
  static int parseBlockOrder(String blockId) {
    final match = RegExp(r'\d+').firstMatch(blockId);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 999;
    }
    return 999;
  }

  /// Chuyển đổi model `Question` của TV1 sang `QuestionItem` cho UI của TV2
  static QuestionItem fromQuestion(Question q) {
    final blockNames = parseBilingualBlockName(q.blockId, q.blockName);
    final optionsVi = q.options.map((o) => o.text.vi.trim()).toList();
    final optionsEn = q.options
        .map((o) => o.text.en.trim().isNotEmpty ? o.text.en.trim() : o.text.vi.trim())
        .toList();

    final normalizedAnswer = q.correctAnswer.trim().toUpperCase();
    var correctIdx = q.options.indexWhere(
      (o) => o.key.trim().toUpperCase() == normalizedAnswer,
    );
    if (correctIdx < 0) {
      correctIdx = const ['A', 'B', 'C', 'D'].indexOf(normalizedAnswer);
    }
    if (correctIdx < 0 || correctIdx >= optionsVi.length) {
      correctIdx = 0;
    }

    return QuestionItem(
      id: q.id,
      number: q.number,
      topicId: q.blockId,
      topicNameVi: blockNames.vi,
      topicNameEn: blockNames.en,
      difficulty: q.difficulty.trim(),
      questionVi: q.question.vi.trim(),
      questionEn: q.question.en.trim().isNotEmpty
          ? q.question.en.trim()
          : q.question.vi.trim(),
      codeSnippet: q.codeSnippet.trim(),
      optionsVi: optionsVi,
      optionsEn: optionsEn,
      correctIndex: correctIdx,
      explanationVi: q.explanation.vi.trim(),
      explanationEn: q.explanation.en.trim().isNotEmpty
          ? q.explanation.en.trim()
          : q.explanation.vi.trim(),
      referenceUrl: q.referenceUrl.trim(),
    );
  }

  void clearCache() {
    _cacheVersion++;
    _cachedQuestions = null;
    _cachedTopics = null;
    _inFlightLoad = null;
  }

  Future<void> _ensureLoaded() async {
    if (_cachedQuestions != null && _cachedTopics != null) return;
    if (_inFlightLoad != null) {
      await _inFlightLoad;
      return;
    }

    final version = _cacheVersion;
    final loadFuture = _loadInternal(version);
    _inFlightLoad = loadFuture;

    try {
      await loadFuture;
    } finally {
      if (identical(_inFlightLoad, loadFuture)) {
        _inFlightLoad = null;
      }
    }
  }

  Future<void> _loadInternal(int version) async {
    List<Question> rawQuestions;
    try {
      if (_customLoader != null) {
        rawQuestions = await _customLoader();
      } else {
        await _questionService.loadQuestions();
        rawQuestions = _questionService.allQuestions;
      }
    } catch (e) {
      throw Exception(
        'Không thể đọc tệp dữ liệu câu hỏi. Vui lòng kiểm tra assets/data/questions.json ($e)',
      );
    }

    final validQuestions = <QuestionItem>[];
    final groupedBlocks = <String, List<Question>>{};
    final seenIds = <String>{};

    for (final q in rawQuestions) {
      if (!q.isValid) {
        debugPrint('[QuizRepository] Bỏ qua câu hỏi lỗi định dạng: ${q.id}');
        continue;
      }
      if (!seenIds.add(q.id)) {
        debugPrint('[QuizRepository] Bỏ qua câu hỏi trùng mã: ${q.id}');
        continue;
      }
      validQuestions.add(fromQuestion(q));
      groupedBlocks.putIfAbsent(q.blockId, () => []).add(q);
    }

    final topics = groupedBlocks.entries.map((entry) {
      final first = entry.value.first;
      final parsedNames = parseBilingualBlockName(first.blockId, first.blockName);
      return TopicItem(
        id: first.blockId,
        order: parseBlockOrder(first.blockId),
        nameVi: parsedNames.vi,
        nameEn: parsedNames.en,
        tier: first.tier,
        questionCount: entry.value.length,
      );
    }).toList()
      ..sort((a, b) {
        final orderCmp = a.order.compareTo(b.order);
        return orderCmp != 0 ? orderCmp : a.id.compareTo(b.id);
      });

    if (version == _cacheVersion) {
      _cachedQuestions = List<QuestionItem>.unmodifiable(validQuestions);
      _cachedTopics = List<TopicItem>.unmodifiable(topics);
    }
  }

  Future<void> _applySimulationIfNeeded() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    if (simulateError) {
      throw Exception(
        'Không thể tải dữ liệu câu hỏi (Chế độ giả lập lỗi mạng/tệp). Vui lòng thử lại.',
      );
    }
  }

  Future<List<TopicItem>> getTopics() async {
    await _applySimulationIfNeeded();
    if (simulateEmpty) return const [];

    await _ensureLoaded();
    return _cachedTopics ?? const [];
  }

  Future<List<QuestionItem>> getQuestionsByTopic(
    String? topicId, {
    bool shuffle = false,
  }) async {
    await _applySimulationIfNeeded();
    if (simulateEmpty) return const [];

    await _ensureLoaded();
    final source = _cachedQuestions ?? const [];

    final filtered = topicId == null
        ? List<QuestionItem>.from(source)
        : source.where((q) => q.topicId == topicId).toList();

    if (shuffle) {
      filtered.shuffle(Random());
    }
    return filtered;
  }

  Future<QuizSummaryStats> getSummaryStats() async {
    await _ensureLoaded();
    return QuizSummaryStats(
      questionCount: _cachedQuestions?.length ?? 0,
      topicCount: _cachedTopics?.length ?? 0,
    );
  }
}
