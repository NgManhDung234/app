import 'package:flutter/material.dart';

import '../models/exam_result.dart';
import '../services/quiz_repository.dart';
import '../services/result_service.dart';
import 'statistics_screen.dart';

class ResultScreen extends StatelessWidget {
  final ExamResult result;
  final ResultService resultService;
  final QuizRepository quizRepository;
  final DisplayLanguage initialLanguage;

  const ResultScreen({
    super.key,
    required this.result,
    required this.resultService,
    required this.quizRepository,
    this.initialLanguage = DisplayLanguage.bilingual,
  });

  String _text({
    required String vi,
    required String en,
    String? bilingual,
  }) {
    switch (initialLanguage) {
      case DisplayLanguage.vi:
        return vi;
      case DisplayLanguage.en:
        return en;
      case DisplayLanguage.bilingual:
        return bilingual ?? '$vi · $en';
    }
  }

  String _resolveText(String vi, String en) {
    switch (initialLanguage) {
      case DisplayLanguage.vi:
        return vi;
      case DisplayLanguage.en:
        return en;
      case DisplayLanguage.bilingual:
        return '$vi\n$en';
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = result.percentage;
    final wrongCount = result.totalQuestions - result.correctAnswers;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            vi: 'Kết quả thi',
            en: 'Exam Result',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 76,
            color: Color(0xFFFFB300),
          ),
          const SizedBox(height: 12),
          Text(
            _text(
              vi: 'Hoàn thành bài thi!',
              en: 'Exam Completed!',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Điểm số
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  _text(
                    vi: 'ĐIỂM SỐ',
                    en: 'SCORE',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.score.toStringAsFixed(2)}/10',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5),
                  ),
                ),
                Text(
                  _text(
                    vi: '${percentage.toStringAsFixed(1)}% chính xác',
                    en: '${percentage.toStringAsFixed(1)}% accuracy',
                  ),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Thống kê số câu
          Row(
            children: [
              Expanded(
                child: _buildCountCard(
                  _text(
                    vi: 'Tổng câu',
                    en: 'Total',
                  ),
                  result.totalQuestions,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCountCard(
                  _text(
                    vi: 'Câu đúng',
                    en: 'Correct',
                  ),
                  result.correctAnswers,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCountCard(
                  _text(
                    vi: 'Câu sai',
                    en: 'Wrong',
                  ),
                  wrongCount,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            _text(
              vi: 'CÂU TRẢ LỜI SAI HOẶC BỎ TRỐNG',
              en: 'WRONG OR UNANSWERED QUESTIONS',
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (result.wrongQuestionIds.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _resolveText(
                    'Tuyệt vời! Bạn không có câu trả lời sai.',
                    'Great job! You have no wrong answers.',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...result.wrongQuestionIds.map(
              (id) => Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                  ),
                  title: Text(
                    _text(
                      vi: 'Mã câu hỏi: $id',
                      en: 'Question ID: $id',
                    ),
                  ),
                  subtitle: Text(
                    result.selectedAnswers.containsKey(id)
                        ? _resolveText(
                            'Bạn đã chọn đáp án nhưng chưa chính xác.',
                            'You selected an incorrect answer.',
                          )
                        : _resolveText(
                            'Bạn chưa trả lời câu hỏi này.',
                            'You did not answer this question.',
                          ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StatisticsScreen(
                      resultService: resultService,
                      quizRepository: quizRepository,
                      initialLanguage: initialLanguage,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart_rounded),
              label: Text(
                _text(
                  vi: 'Xem thống kê học tập',
                  en: 'View Study Statistics',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home_rounded),
            label: Text(
              _text(
                vi: 'Về trang chủ',
                en: 'Back to Home',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}