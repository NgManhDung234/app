import 'package:flutter/material.dart';

import '../services/quiz_repository.dart';
import '../services/result_service.dart';

class WrongQuestionsScreen extends StatefulWidget {
  final QuizRepository quizRepository;
  final DisplayLanguage initialLanguage;

  const WrongQuestionsScreen({
    super.key,
    required this.quizRepository,
    this.initialLanguage = DisplayLanguage.bilingual,
  });

  @override
  State<WrongQuestionsScreen> createState() =>
      _WrongQuestionsScreenState();
}

class _WrongQuestionsScreenState extends State<WrongQuestionsScreen> {
  final ResultService _resultService = ResultService();

  List<QuestionItem> _questions = [];

  int _currentIndex = 0;
  int? _selectedAnswerIndex;

  bool _isLoading = true;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadWrongQuestions();
  }

  String _text({
    required String vi,
    required String en,
    String? bilingual,
  }) {
    switch (widget.initialLanguage) {
      case DisplayLanguage.vi:
        return vi;
      case DisplayLanguage.en:
        return en;
      case DisplayLanguage.bilingual:
        return bilingual ?? '$vi · $en';
    }
  }

  String _resolveText(String vi, String en) {
    switch (widget.initialLanguage) {
      case DisplayLanguage.vi:
        return vi;
      case DisplayLanguage.en:
        return en;
      case DisplayLanguage.bilingual:
        return '$vi\n$en';
    }
  }

  String _topicName(String nameVi, String nameEn) {
    final en = nameEn.isNotEmpty ? nameEn : nameVi;
    switch (widget.initialLanguage) {
      case DisplayLanguage.vi:
        return nameVi;
      case DisplayLanguage.en:
        return en;
      case DisplayLanguage.bilingual:
        return en == nameVi ? nameVi : '$nameVi · $en';
    }
  }

  Future<void> _loadWrongQuestions() async {
    try {
      // Bước 1: Lấy ID các câu sai chưa được ôn đúng.
      final wrongIds = await _resultService.getWrongQuestionIds();

      // Không còn câu sai để ôn tập.
      if (wrongIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          _questions = [];
          _isLoading = false;
        });
        return;
      }

      // Bước 2: Lấy ngân hàng câu hỏi.
      final allQuestions =
          await widget.quizRepository.getQuestionsByTopic(null);

      // Bước 3: Chỉ giữ lại những câu có ID nằm trong danh sách sai.
      final wrongQuestions = allQuestions
          .where((question) => wrongIds.contains(question.id))
          .toList();

      // Sắp xếp theo số thứ tự câu hỏi trong ngân hàng.
      wrongQuestions.sort(
        (a, b) => a.number.compareTo(b.number),
      );

      if (!mounted) return;

      setState(() {
        _questions = wrongQuestions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              vi: 'Không thể tải câu hỏi sai: $e',
              en: 'Unable to load wrong questions: $e',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _selectAnswer(int answerIndex) async {
    if (_isCorrect) return;

    final question = _questions[_currentIndex];

    setState(() {
      _selectedAnswerIndex = answerIndex;
    });

    if (answerIndex == question.correctIndex) {
      // Người dùng đã trả lời đúng.
      try {
        await _resultService.markQuestionCorrect(question.id);

        if (!mounted) return;

        setState(() {
          _isCorrect = true;
        });
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _text(
                vi: 'Không thể cập nhật trạng thái câu hỏi: $e',
                en: 'Unable to update question status: $e',
              ),
            ),
          ),
        );
      }
    }
  }

  void _nextQuestion() {
    if (!_isCorrect) return;

    setState(() {
      _currentIndex++;
      _selectedAnswerIndex = null;
      _isCorrect = false;
    });
  }

  String _optionLabel(int index) {
    return String.fromCharCode(65 + index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _text(
              vi: 'Ôn tập câu trả lời sai',
              en: 'Review Wrong Answers',
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return _buildEmptyScreen();
    }

    if (_currentIndex >= _questions.length) {
      return _buildCompletedScreen();
    }

    return _buildQuestionScreen();
  }

  Widget _buildQuestionScreen() {
    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            vi: 'Ôn tập câu trả lời sai',
            en: 'Review Wrong Answers',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            minHeight: 5,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  _topicName(question.topicNameVi, question.topicNameEn),
                  style: const TextStyle(
                    color: Color(0xFF3F51B5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _text(
                    vi: 'Câu hỏi số ${question.number}',
                    en: 'Question #${question.number}',
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // Nội dung câu hỏi
                Text(
                  _resolveText(
                    question.questionVi,
                    question.questionEn,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),

                // Đoạn code nếu có
                if (question.codeSnippet.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      question.codeSnippet,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                Text(
                  _text(
                    vi: 'CHỌN ĐÁP ÁN',
                    en: 'SELECT AN ANSWER',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 12),

                // Danh sách đáp án
                ...List.generate(question.optionsVi.length, (index) {
                  final isSelected = _selectedAnswerIndex == index;
                  final isCorrectOption =
                      index == question.correctIndex;
                  final optionEn = index < question.optionsEn.length
                      ? question.optionsEn[index]
                      : question.optionsVi[index];

                  Color? backgroundColor;
                  Color? borderColor;

                  if (_isCorrect && isCorrectOption) {
                    backgroundColor = Colors.green.shade50;
                    borderColor = Colors.green;
                  } else if (isSelected && !_isCorrect) {
                    backgroundColor = Colors.red.shade50;
                    borderColor = Colors.red;
                  }

                  return Card(
                    color: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: borderColor ?? Colors.grey.shade300,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      enabled: !_isCorrect,
                      onTap: () => _selectAnswer(index),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: isSelected
                            ? (isCorrectOption
                                ? Colors.green
                                : Colors.red)
                            : Colors.grey.shade200,
                        child: Text(
                          _optionLabel(index),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        _resolveText(
                          question.optionsVi[index],
                          optionEn,
                        ),
                      ),
                      trailing: _isCorrect && isCorrectOption
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Phản hồi sau khi chọn đáp án
                if (_selectedAnswerIndex != null)
                  _buildFeedback(question),
              ],
            ),
          ),

          // Nút chuyển câu
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isCorrect ? _nextQuestion : null,
                  child: Text(
                    _currentIndex < _questions.length - 1
                        ? _text(
                            vi: 'Câu tiếp theo',
                            en: 'Next Question',
                          )
                        : _text(
                            vi: 'Hoàn thành ôn tập',
                            en: 'Finish Review',
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(QuestionItem question) {
    if (_isCorrect) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _text(
                      vi: 'Chính xác!',
                      en: 'Correct!',
                    ),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (question.explanationVi.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _text(
                  vi: 'Giải thích:',
                  en: 'Explanation:',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _resolveText(
                  question.explanationVi,
                  question.explanationEn,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _text(
                    vi: 'Chưa chính xác! Hãy thử lại.',
                    en: 'Incorrect! Please try again.',
                  ),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _text(
              vi: 'Đáp án đúng: ${_optionLabel(question.correctIndex)}',
              en: 'Correct answer: ${_optionLabel(question.correctIndex)}',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            vi: 'Ôn tập câu trả lời sai',
            en: 'Review Wrong Answers',
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 76,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                _resolveText(
                  'Bạn không có câu trả lời sai nào cần ôn tập!',
                  'You have no wrong answers to review!',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _resolveText(
                  'Hãy tiếp tục làm bài thi để kiểm tra kiến thức nhé.',
                  'Keep taking exams to test your knowledge.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  _text(
                    vi: 'Quay lại trang chủ',
                    en: 'Back to Home',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            vi: 'Hoàn thành ôn tập',
            en: 'Review Completed',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                _resolveText(
                  'Bạn đã hoàn thành lượt ôn tập!',
                  'You have completed this review session!',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _resolveText(
                  'Bạn đã ôn đúng ${_questions.length} câu hỏi.',
                  'You correctly reviewed ${_questions.length} questions.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    _text(
                      vi: 'Về trang chủ',
                      en: 'Back to Home',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}