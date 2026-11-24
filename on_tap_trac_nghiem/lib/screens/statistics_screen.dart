import 'package:flutter/material.dart';

import '../models/exam_result.dart';
import '../services/quiz_repository.dart';
import '../services/result_service.dart';

class StatisticsScreen extends StatefulWidget {
  final ResultService resultService;
  final QuizRepository quizRepository;
  final DisplayLanguage initialLanguage;

  const StatisticsScreen({
    super.key,
    required this.resultService,
    required this.quizRepository,
    this.initialLanguage = DisplayLanguage.bilingual,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;

  List<ExamResult> _results = [];
  List<TopicItem> _topics = [];

  // Mỗi khối lưu tổng số lượt làm câu hỏi và số lượt đúng.
  final Map<String, _TopicStats> _topicStats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
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

  Future<void> _loadStatistics() async {
    try {
      final results = await widget.resultService.getAllResults();
      final topics = await widget.quizRepository.getTopics();

      final stats = <String, _TopicStats>{};

      for (final topic in topics) {
        stats[topic.id] = _TopicStats();
      }

      for (final result in results) {
        for (final entry in result.questionTopicIds.entries) {
          final topicId = entry.value;

          stats.putIfAbsent(topicId, () => _TopicStats());

          stats[topicId]!.total++;

          if (result.correctQuestionIds.contains(entry.key)) {
            stats[topicId]!.correct++;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _results = results;
        _topics = topics;
        _topicStats
          ..clear()
          ..addAll(stats);
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
              vi: 'Không thể tải thống kê: $e',
              en: 'Unable to load statistics: $e',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _text(
              vi: 'Xóa lịch sử thi?',
              en: 'Clear exam history?',
            ),
          ),
          content: Text(
            _resolveText(
              'Toàn bộ lịch sử và dữ liệu thống kê sẽ bị xóa. Bạn có chắc chắn không?',
              'All exam history and statistics will be deleted. Are you sure?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                _text(
                  vi: 'Hủy',
                  en: 'Cancel',
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                _text(
                  vi: 'Xóa',
                  en: 'Clear',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await widget.resultService.clearHistory();
    await _loadStatistics();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            vi: 'Thống kê học tập',
            en: 'Study Statistics',
          ),
        ),
        actions: [
          IconButton(
            tooltip: _text(
              vi: 'Xóa lịch sử',
              en: 'Clear history',
            ),
            onPressed: _results.isEmpty ? null : _clearHistory,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildOverview(),
                  const SizedBox(height: 24),
                  Text(
                    _text(
                      vi: 'KẾT QUẢ THEO KHỐI KIẾN THỨC',
                      en: 'RESULTS BY TOPIC',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_topics.isEmpty)
                    Text(
                      _text(
                        vi: 'Chưa có dữ liệu khối kiến thức.',
                        en: 'No topic data available.',
                      ),
                    )
                  else
                    ..._topics.map(_buildTopicCard),
                  const SizedBox(height: 24),
                  Text(
                    _text(
                      vi: 'LỊCH SỬ THI',
                      en: 'EXAM HISTORY',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_results.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _resolveText(
                            'Bạn chưa hoàn thành bài thi nào.',
                            'You have not completed any exams yet.',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._results.map(_buildHistoryCard),
                ],
              ),
            ),
    );
  }

  Widget _buildOverview() {
    final totalExams = _results.length;

    final averageScore = totalExams == 0
        ? 0.0
        : _results.fold<double>(
              0,
              (sum, result) => sum + result.score,
            ) /
            totalExams;

    final totalQuestions = _results.fold<int>(
      0,
      (sum, result) => sum + result.totalQuestions,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _text(
              vi: 'TỔNG QUAN HỌC TẬP',
              en: 'STUDY OVERVIEW',
            ),
            style: const TextStyle(
              color: Color(0xFF3F51B5),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  _text(
                    vi: 'Số bài thi',
                    en: 'Exams',
                  ),
                  '$totalExams',
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  _text(
                    vi: 'Điểm trung bình',
                    en: 'Average Score',
                  ),
                  averageScore.toStringAsFixed(2),
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  _text(
                    vi: 'Lượt câu hỏi',
                    en: 'Questions',
                  ),
                  '$totalQuestions',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3F51B5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTopicCard(TopicItem topic) {
    final stats = _topicStats[topic.id] ?? _TopicStats();

    final percentage = stats.total == 0
        ? 0.0
        : stats.correct / stats.total;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _topicName(topic.nameVi, topic.nameEn),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _text(
                    vi: 'Đúng ${stats.correct}/${stats.total} lượt',
                    en: '${stats.correct}/${stats.total} correct',
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: const Color(0xFFE2E8F0),
              color: const Color(0xFF3F51B5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ExamResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.assignment_turned_in_rounded),
        ),
        title: Text(
          _text(
            vi: '${result.score.toStringAsFixed(2)}/10 điểm',
            en: '${result.score.toStringAsFixed(2)}/10 pts',
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_formatDate(result.completedAt)}\n'
          '${_text(
            vi: '${result.correctAnswers}/${result.totalQuestions} câu đúng',
            en: '${result.correctAnswers}/${result.totalQuestions} correct',
          )}',
        ),
        isThreeLine: true,
        trailing: Text(
          '${result.percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3F51B5),
          ),
        ),
      ),
    );
  }
}

class _TopicStats {
  int total = 0;
  int correct = 0;
}