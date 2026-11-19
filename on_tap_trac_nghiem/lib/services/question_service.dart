import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';

class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  List<Question> _allQuestions = [];
  List<String> _dataErrors = [];

  bool get isLoaded => _allQuestions.isNotEmpty;
  List<Question> get allQuestions => List.unmodifiable(_allQuestions);
  List<String> get dataErrors => List.unmodifiable(_dataErrors);

  Future<void> loadQuestions() async {
    if (_allQuestions.isNotEmpty) return;
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final List<dynamic> list = json.decode(raw) as List<dynamic>;

    final loaded = <Question>[];
    final errors = <String>[];
    final seenIds = <String>{};

    for (final item in list) {
      final q = Question.fromJson(item as Map<String, dynamic>);
      if (!seenIds.add(q.id)) {
        errors.add('Trùng mã câu hỏi: ${q.id}');
      }
      if (!q.isValid) {
        errors.add('Dữ liệu thiếu hoặc sai định dạng tại câu: ${q.id}');
      }
      loaded.add(q);
    }

    _allQuestions = loaded;
    _dataErrors = errors;
  }

  List<String> getTiers() {
    return _allQuestions.map((q) => q.tier).toSet().toList();
  }

  List<KnowledgeBlock> getBlocks({String? tier}) {
    final source = tier == null
        ? _allQuestions
        : _allQuestions.where((q) => q.tier == tier);

    final Map<String, List<Question>> grouped = {};
    for (final q in source) {
      grouped.putIfAbsent(q.blockId, () => []).add(q);
    }

    final result = grouped.entries.map((e) {
      final first = e.value.first;
      return KnowledgeBlock(
        blockId: first.blockId,
        blockName: first.blockName,
        tier: first.tier,
        questionCount: e.value.length,
      );
    }).toList();

    result.sort((a, b) => a.blockId.compareTo(b.blockId));
    return result;
  }

  List<Question> getQuestionsByFilter({
    String? blockId,
    String? difficulty,
    bool shuffle = false,
  }) {
    final result = _allQuestions.where((q) {
      final matchBlock = blockId == null || q.blockId == blockId;
      final matchDiff = difficulty == null || q.difficulty == difficulty;
      return matchBlock && matchDiff;
    }).toList();

    if (shuffle) {
      result.shuffle(Random());
    }
    return result;
  }

  /// Lấy danh sách câu hỏi theo danh sách ID (hỗ trợ TV3 làm lại câu sai)
  List<Question> getQuestionsByIds(List<String> ids) {
    final idSet = ids.toSet();
    return _allQuestions.where((q) => idSet.contains(q.id)).toList();
  }

  /// Sinh đề thi theo số lượng câu hỏi và các khối được chọn (hỗ trợ TV3)
  List<Question> generateExam({
    int questionCount = 30,
    List<String>? blockIds,
  }) {
    final pool = (blockIds == null || blockIds.isEmpty)
        ? _allQuestions
        : _allQuestions.where((q) => blockIds.contains(q.blockId)).toList();

    if (pool.isEmpty) return [];
    final random = Random();

    if (pool.length <= questionCount) {
      return List<Question>.from(pool)..shuffle(random);
    }

    final Map<String, List<Question>> byBlock = {};
    for (final q in pool) {
      byBlock.putIfAbsent(q.blockId, () => []).add(q);
    }

    final int poolSize = pool.length;
    final List<_BlockQuota> quotas = [];
    int allocated = 0;

    byBlock.forEach((_, items) {
      final exact = (items.length * questionCount) / poolSize;
      final base = exact.floor();
      quotas.add(
        _BlockQuota(
          questions: List<Question>.from(items)..shuffle(random),
          quota: base,
          remainder: exact - base,
        ),
      );
      allocated += base;
    });

    quotas.sort((a, b) => b.remainder.compareTo(a.remainder));
    int remaining = questionCount - allocated;
    for (int i = 0; i < quotas.length && remaining > 0; i++) {
      if (quotas[i].quota < quotas[i].questions.length) {
        quotas[i].quota++;
        remaining--;
      }
    }

    final List<Question> exam = [];
    for (final q in quotas) {
      exam.addAll(q.questions.take(q.quota));
    }

    exam.shuffle(random);
    return exam;
  }
}

class _BlockQuota {
  final List<Question> questions;
  int quota;
  final double remainder;

  _BlockQuota({
    required this.questions,
    required this.quota,
    required this.remainder,
  });
}