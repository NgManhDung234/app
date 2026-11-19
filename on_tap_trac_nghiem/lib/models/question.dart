class BilingualText {
  final String vi;
  final String en;

  const BilingualText({required this.vi, required this.en});

  factory BilingualText.fromJson(Map<String, dynamic> json) {
    final viText = (json['vi'] ?? '') as String;
    final enText = (json['en'] ?? '') as String;
    return BilingualText(
      vi: viText,
      en: enText.isNotEmpty ? enText : viText,
    );
  }

  String resolve(bool isEnglish) => isEnglish ? en : vi;
}

class QuestionOption {
  final String key; // 'A', 'B', 'C', 'D'
  final BilingualText text;

  const QuestionOption({required this.key, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      key: (json['key'] ?? '') as String,
      text: BilingualText.fromJson(json['text'] as Map<String, dynamic>),
    );
  }
}

class Question {
  final String id;
  final int number;
  final String tier;
  final String blockId;
  final String blockName;
  final String difficulty;
  final BilingualText question;
  final String codeSnippet;
  final List<QuestionOption> options;
  final String correctAnswer;
  final BilingualText explanation;
  final String referenceUrl;

  const Question({
    required this.id,
    required this.number,
    required this.tier,
    required this.blockId,
    required this.blockName,
    required this.difficulty,
    required this.question,
    required this.codeSnippet,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.referenceUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: (json['id'] ?? '') as String,
      number: (json['number'] ?? 0) as int,
      tier: (json['tier'] ?? '') as String,
      blockId: (json['blockId'] ?? '') as String,
      blockName: (json['blockName'] ?? '') as String,
      difficulty: (json['difficulty'] ?? 'Hiểu') as String,
      question: BilingualText.fromJson(json['question'] as Map<String, dynamic>),
      codeSnippet: (json['codeSnippet'] ?? '') as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctAnswer: (json['correctAnswer'] ?? 'A') as String,
      explanation:
          BilingualText.fromJson(json['explanation'] as Map<String, dynamic>),
      referenceUrl: (json['referenceUrl'] ?? '') as String,
    );
  }

  /// Kiểm tra đáp án người dùng chọn (dùng cho TV2 & TV3)
  bool isCorrect(String selectedKey) =>
      selectedKey.trim().toUpperCase() == correctAnswer.toUpperCase();

  /// Kiểm tra câu hỏi có bị thiếu dữ liệu hay sai định dạng không
  bool get isValid =>
      id.isNotEmpty &&
      blockId.isNotEmpty &&
      question.vi.isNotEmpty &&
      options.length == 4 &&
      options.every((o) => o.text.vi.isNotEmpty) &&
      const ['A', 'B', 'C', 'D'].contains(correctAnswer);
}

class KnowledgeBlock {
  final String blockId;
  final String blockName;
  final String tier;
  final int questionCount;

  const KnowledgeBlock({
    required this.blockId,
    required this.blockName,
    required this.tier,
    required this.questionCount,
  });
}