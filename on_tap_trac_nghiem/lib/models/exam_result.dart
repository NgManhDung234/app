
class ExamResult {
  final String id;
  final DateTime completedAt;

  // Các khối kiến thức có trong đề thi
  final List<String> topicIds;

  // Tổng số câu và số câu trả lời đúng
  final int totalQuestions;
  final int correctAnswers;

  // ID câu hỏi -> chỉ số đáp án đã chọn (A = 0, B = 1...)
  final Map<String, int> selectedAnswers;

  // Danh sách ID những câu trả lời đúng
  final List<String> correctQuestionIds;

  // ID câu hỏi -> ID khối kiến thức
  final Map<String, String> questionTopicIds;

  const ExamResult({
    required this.id,
    required this.completedAt,
    required this.topicIds,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.selectedAnswers,
    required this.correctQuestionIds,
    required this.questionTopicIds,
  });

  // Tính điểm theo thang 10
  double get score {
    if (totalQuestions == 0) return 0;
    return correctAnswers / totalQuestions * 10;
  }

  // Tính phần trăm câu trả lời đúng
  double get percentage {
    if (totalQuestions == 0) return 0;
    return correctAnswers / totalQuestions * 100;
  }

  // Lấy danh sách câu sai, bao gồm cả câu bỏ trống
  List<String> get wrongQuestionIds {
    return questionTopicIds.keys
        .where((id) => !correctQuestionIds.contains(id))
        .toList();
  }

  // Chuyển đối tượng thành JSON để lưu
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'topicIds': topicIds,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'selectedAnswers': selectedAnswers,
      'correctQuestionIds': correctQuestionIds,
      'questionTopicIds': questionTopicIds,
    };
  }

  // Đọc JSON và chuyển thành đối tượng ExamResult
  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      topicIds: List<String>.from(json['topicIds'] ?? []),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      selectedAnswers: (json['selectedAnswers'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toInt())),
      correctQuestionIds:
          List<String>.from(json['correctQuestionIds'] ?? []),
      questionTopicIds:
          Map<String, String>.from(json['questionTopicIds'] ?? {}),
    );
  }
}
