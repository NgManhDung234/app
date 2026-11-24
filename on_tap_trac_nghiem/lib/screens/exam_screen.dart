import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/exam_result.dart';
import '../services/quiz_repository.dart';
import '../services/result_service.dart';
import 'result_screen.dart';

class ExamScreen extends StatefulWidget {
  final QuizRepository quizRepository;
  final DisplayLanguage initialLanguage;

  const ExamScreen({
    super.key,
    required this.quizRepository,
    this.initialLanguage = DisplayLanguage.bilingual,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final ResultService _resultService = ResultService();

  List<TopicItem> _topics = [];
  List<QuestionItem> _questions = [];

  final Set<String> _selectedTopicIds = {};

  int _questionCount = 30;
  int _currentIndex = 0;

  // ID câu hỏi -> chỉ số đáp án được chọn
  final Map<String, int> _selectedAnswers = {};

  bool _isLoading = true;
  bool _isExamStarted = false;
  bool _isSubmitted = false;

  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  Future<void> _loadTopics() async {
    try {
      final topics = await widget.quizRepository.getTopics();

      if (!mounted) return;

      setState(() {
        _topics = topics;
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
              vi: 'Không thể tải danh sách khối: $e',
              en: 'Unable to load topics: $e',
            ),
          ),
        ),
      );
    }
  }

  void _toggleTopic(String topicId, bool selected) {
    setState(() {
      if (selected) {
        _selectedTopicIds.add(topicId);
      } else {
        _selectedTopicIds.remove(topicId);
      }
    });
  }

  Future<void> _startExam() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allQuestions =
          await widget.quizRepository.getQuestionsByTopic(null);

      final filteredQuestions = _selectedTopicIds.isEmpty
          ? allQuestions
          : allQuestions
              .where((q) => _selectedTopicIds.contains(q.topicId))
              .toList();

      if (filteredQuestions.isEmpty) {
        throw Exception(
          _text(
            vi: 'Không tìm thấy câu hỏi trong khối đã chọn.',
            en: 'No questions found in the selected topics.',
          ),
        );
      }

      filteredQuestions.shuffle(Random());

      final examQuestions = filteredQuestions
          .take(min(_questionCount, filteredQuestions.length))
          .toList();

      if (!mounted) return;

      setState(() {
        _questions = examQuestions;
        _currentIndex = 0;
        _selectedAnswers.clear();
        _isExamStarted = true;
        _isSubmitted = false;

        // Mỗi câu có khoảng 1 phút làm bài, tối thiểu 10 phút.
        _remainingSeconds = max(600, examQuestions.length * 60);
        _isLoading = false;
      });

      _startTimer();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              vi: 'Không thể tạo đề thi: $e',
              en: 'Unable to create exam: $e',
            ),
          ),
        ),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        _submitExam(isTimeUp: true);
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(int answerIndex) {
    if (_isSubmitted) return;

    final question = _questions[_currentIndex];

    setState(() {
      _selectedAnswers[question.id] = answerIndex;
    });
  }

  void _goToQuestion(int index) {
    if (index < 0 || index >= _questions.length) return;

    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _confirmSubmit() async {
    final unansweredCount =
        _questions.length - _selectedAnswers.length;

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _text(
              vi: 'Nộp bài thi?',
              en: 'Submit exam?',
            ),
          ),
          content: Text(
            unansweredCount > 0
                ? _resolveText(
                    'Bạn còn $unansweredCount câu chưa trả lời. Bạn có chắc chắn muốn nộp bài không?',
                    'You have $unansweredCount unanswered questions. Are you sure you want to submit?',
                  )
                : _resolveText(
                    'Bạn đã trả lời tất cả câu hỏi. Bạn có chắc chắn muốn nộp bài không?',
                    'You have answered all questions. Are you sure you want to submit?',
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                _text(
                  vi: 'Tiếp tục làm bài',
                  en: 'Continue',
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                _text(
                  vi: 'Nộp bài',
                  en: 'Submit',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSubmit == true) {
      _submitExam();
    }
  }

  Future<void> _submitExam({bool isTimeUp = false}) async {
    if (_isSubmitted || _questions.isEmpty) return;

    _timer?.cancel();

    final correctQuestionIds = <String>[];
    final questionTopicIds = <String, String>{};

    for (final question in _questions) {
      questionTopicIds[question.id] = question.topicId;

      final selectedIndex = _selectedAnswers[question.id];

      if (selectedIndex != null &&
          selectedIndex == question.correctIndex) {
        correctQuestionIds.add(question.id);
      }
    }

    final topicIds = _questions
        .map((question) => question.topicId)
        .toSet()
        .toList();

    final result = ExamResult(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      completedAt: DateTime.now(),
      topicIds: topicIds,
      totalQuestions: _questions.length,
      correctAnswers: correctQuestionIds.length,
      selectedAnswers: Map<String, int>.from(_selectedAnswers),
      correctQuestionIds: correctQuestionIds,
      questionTopicIds: questionTopicIds,
    );

    setState(() {
      _isSubmitted = true;
    });

    try {
      await _resultService.saveResult(result);

      if (!mounted) return;

      if (isTimeUp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _text(
                vi: 'Đã hết giờ. Bài thi được tự động nộp.',
                en: 'Time is up. Exam submitted automatically.',
              ),
            ),
          ),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            resultService: _resultService,
            quizRepository: widget.quizRepository,
            initialLanguage: widget.initialLanguage,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              vi: 'Không thể lưu kết quả: $e',
              en: 'Unable to save result: $e',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isExamStarted) {
      return _buildSetupScreen();
    }

    return _buildExamScreen();
  }

  Widget _buildSetupScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_text(
          vi: 'Thi thử',
          en: 'Mock Exam',
          bilingual: 'Thi thử · Mock Exam',
        )),
      ),
      body: _topics.isEmpty
          ? Center(
              child: Text(
                _text(
                  vi: 'Không có khối kiến thức nào.',
                  en: 'No topics available.',
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(
                  Icons.assignment_rounded,
                  size: 64,
                  color: Color(0xFF3F51B5),
                ),
                const SizedBox(height: 12),
                Text(
                  _text(
                    vi: 'Thi thử kiến thức Flutter',
                    en: 'Flutter Mock Exam',
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
                    'Chọn khối kiến thức và số lượng câu hỏi.',
                    'Choose topics and the number of questions.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Text(
                  _text(
                    vi: 'KHỐI KIẾN THỨC',
                    en: 'TOPICS',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _resolveText(
                    'Không chọn khối nào nghĩa là lấy câu hỏi từ tất cả các khối.',
                    'Leaving all unselected means questions are picked from all topics.',
                  ),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ..._topics.map((topic) {
                  final selected =
                      _selectedTopicIds.contains(topic.id);

                  return CheckboxListTile(
                    value: selected,
                    onChanged: (value) {
                      _toggleTopic(topic.id, value ?? false);
                    },
                    title: Text(_topicName(topic.nameVi, topic.nameEn)),
                    subtitle: Text(
                      _text(
                        vi: '${topic.questionCount} câu hỏi',
                        en: '${topic.questionCount} questions',
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                const SizedBox(height: 20),
                Text(
                  _text(
                    vi: 'SỐ LƯỢNG CÂU HỎI',
                    en: 'NUMBER OF QUESTIONS',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _questionCount,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.quiz_outlined),
                  ),
                  items: [10, 20, 30, 50, 100]
                      .map(
                        (count) => DropdownMenuItem(
                          value: count,
                          child: Text(
                            _text(
                              vi: '$count câu',
                              en: '$count questions',
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _questionCount = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _startExam,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      _text(
                        vi: 'Bắt đầu thi',
                        en: 'Start Exam',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildExamScreen() {
    final question = _questions[_currentIndex];
    final selectedIndex = _selectedAnswers[question.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            vi: 'Câu ${_currentIndex + 1}/${_questions.length}',
            en: 'Question ${_currentIndex + 1}/${_questions.length}',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    _formatTime(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds < 60
                          ? Colors.red
                          : null,
                    ),
                  ),
                ],
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 20),
                ...List.generate(question.optionsVi.length, (index) {
                  final isSelected = selectedIndex == index;
                  final optionLabel = String.fromCharCode(65 + index);
                  final optionEn = index < question.optionsEn.length
                      ? question.optionsEn[index]
                      : question.optionsVi[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: RadioListTile<int>(
                      value: index,
                      groupValue: selectedIndex,
                      onChanged: _isSubmitted
                          ? null
                          : (value) {
                              if (value != null) {
                                _selectAnswer(value);
                              }
                            },
                      title: Text(
                        '$optionLabel. ${_resolveText(
                          question.optionsVi[index],
                          optionEn,
                        )}',
                      ),
                      selected: isSelected,
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  _text(
                    vi: 'DANH SÁCH CÂU HỎI',
                    en: 'QUESTION LIST',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_questions.length, (index) {
                    final answered = _selectedAnswers
                        .containsKey(_questions[index].id);

                    return SizedBox(
                      width: 42,
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () => _goToQuestion(index),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: index == _currentIndex
                              ? const Color(0xFF3F51B5)
                              : answered
                                  ? const Color(0xFFE0E7FF)
                                  : null,
                          foregroundColor: index == _currentIndex
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        child: Text('${index + 1}'),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentIndex > 0
                          ? () => _goToQuestion(_currentIndex - 1)
                          : null,
                      child: Text(
                        _text(
                          vi: 'Câu trước',
                          en: 'Previous',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _currentIndex < _questions.length - 1
                          ? () => _goToQuestion(_currentIndex + 1)
                          : _confirmSubmit,
                      child: Text(
                        _currentIndex < _questions.length - 1
                            ? _text(
                                vi: 'Câu tiếp',
                                en: 'Next',
                              )
                            : _text(
                                vi: 'Nộp bài',
                                en: 'Submit',
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}