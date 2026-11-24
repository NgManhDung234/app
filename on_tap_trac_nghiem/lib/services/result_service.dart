import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exam_result.dart';

class ResultService {
  static const String _resultsKey = 'exam_results';
  static const String _resolvedWrongKey = 'resolved_wrong_questions';

  // Lưu một kết quả thi
  Future<void> saveResult(ExamResult result) async {
    final prefs = await SharedPreferences.getInstance();

    final results = await getAllResults();

    // Tránh lưu trùng một lần thi
    results.removeWhere((item) => item.id == result.id);
    results.add(result);

    final jsonList = results.map((item) => item.toJson()).toList();

    await prefs.setString(_resultsKey, jsonEncode(jsonList));

    // Nếu một câu đã ôn đúng nhưng sau đó lại làm sai trong bài thi mới,
    // câu đó cần xuất hiện trở lại trong danh sách ôn tập.
    final resolvedIds = prefs.getStringList(_resolvedWrongKey) ?? [];
    resolvedIds.removeWhere(
      (id) => result.wrongQuestionIds.contains(id),
    );
    await prefs.setStringList(_resolvedWrongKey, resolvedIds);
  }

  // Lấy toàn bộ lịch sử thi
  Future<List<ExamResult>> getAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_resultsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final results = <ExamResult>[];

      for (final item in jsonList) {
        try {
          results.add(
            ExamResult.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          // Bỏ qua bản ghi lỗi định dạng
        }
      }

      results.sort(
        (a, b) => b.completedAt.compareTo(a.completedAt),
      );

      return results;
    } catch (_) {
      return [];
    }
  }

  // Lấy danh sách câu sai chưa được ôn đúng
  Future<List<String>> getWrongQuestionIds() async {
    final results = await getAllResults();
    final prefs = await SharedPreferences.getInstance();

    final wrongIds = <String>{};

    for (final result in results) {
      wrongIds.addAll(result.wrongQuestionIds);
    }

    final resolvedIds =
        prefs.getStringList(_resolvedWrongKey) ?? [];

    wrongIds.removeAll(resolvedIds);

    return wrongIds.toList();
  }

  // Đánh dấu một câu đã được ôn đúng
  Future<void> markQuestionCorrect(String questionId) async {
    final prefs = await SharedPreferences.getInstance();

    final resolvedIds =
        prefs.getStringList(_resolvedWrongKey) ?? [];

    if (!resolvedIds.contains(questionId)) {
      resolvedIds.add(questionId);
      await prefs.setStringList(_resolvedWrongKey, resolvedIds);
    }
  }

  // Xóa toàn bộ lịch sử thi và trạng thái ôn tập
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_resultsKey);
    await prefs.remove(_resolvedWrongKey);
  }
}