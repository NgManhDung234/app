import 'package:flutter/material.dart';
import '../services/quiz_repository.dart';
import 'topic_screen.dart';
import 'practice_screen.dart';

class HomeScreen extends StatefulWidget {
  final QuizRepository quizRepository;

  const HomeScreen({super.key, required this.quizRepository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _bgColor = Color(0xFFF8F9FC);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _dividerColor = Color(0xFFF1F5F9);
  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _primaryDark = Color(0xFF303F9F);
  static const Color _primarySoft = Color(0xFFEEF2FF);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  DisplayLanguage _selectedLanguage = DisplayLanguage.bilingual;
  int _questionCount = 300;
  int _topicCount = 20;

  @override
  void initState() {
    super.initState();
    _loadSummaryStats();
  }

  Future<void> _loadSummaryStats() async {
    try {
      final stats = await widget.quizRepository.getSummaryStats();
      if (!mounted) return;
      if (stats.questionCount > 0 && stats.topicCount > 0) {
        setState(() {
          _questionCount = stats.questionCount;
          _topicCount = stats.topicCount;
        });
      }
    } catch (_) {
      // Giữ giá trị tổng quan mặc định nếu tệp chưa sẵn sàng
    }
  }

  String _text({
    required String vi,
    required String en,
    String? bilingual,
  }) {
    switch (_selectedLanguage) {
      case DisplayLanguage.vi:
        return vi;
      case DisplayLanguage.en:
        return en;
      case DisplayLanguage.bilingual:
        return bilingual ?? vi;
    }
  }

  String _languageLabel(DisplayLanguage lang) {
    switch (lang) {
      case DisplayLanguage.vi:
        return 'Tiếng Việt';
      case DisplayLanguage.en:
        return 'English';
      case DisplayLanguage.bilingual:
        return 'Song ngữ';
    }
  }

  void _showIntegrationNotice(String featureName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            _text(
              vi: 'Chức năng "$featureName" đang sẵn sàng để tích hợp.',
              en: '"$featureName" is ready for module integration.',
              bilingual: 'Chức năng "$featureName" đang sẵn sàng để tích hợp.',
            ),
          ),
        ),
      );
  }

  void _openQuickPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeScreen(
          quizRepository: widget.quizRepository,
          topic: null,
          initialLanguage: _selectedLanguage,
        ),
      ),
    );
  }

  void _openTopicScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopicScreen(
          quizRepository: widget.quizRepository,
          initialLanguage: _selectedLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildIntroBanner(),
              const SizedBox(height: 16),
              _buildOverviewSection(),
              const SizedBox(height: 28),
              _buildSectionTitle(
                _text(
                  vi: 'HỌC TẬP & KIỂM TRA',
                  en: 'LEARN & PRACTICE',
                  bilingual: 'HỌC TẬP & KIỂM TRA',
                ),
              ),
              const SizedBox(height: 12),
              _buildFeaturedPracticeCard(),
              const SizedBox(height: 12),
              _buildCoreGrid(),
              const SizedBox(height: 28),
              _buildSectionTitle(
                _text(
                  vi: 'ÔN TẬP & THEO DÕI',
                  en: 'REVIEW & INSIGHTS',
                  bilingual: 'ÔN TẬP & THEO DÕI',
                ),
              ),
              const SizedBox(height: 12),
              _buildReviewGroupCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _text(
                  vi: 'Xin chào,',
                  en: 'Welcome back,',
                  bilingual: 'Xin chào · Welcome,',
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'QuizMaster',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<DisplayLanguage>(
          tooltip: _text(
            vi: 'Chọn ngôn ngữ hiển thị',
            en: 'Select display language',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          color: _surfaceColor,
          onSelected: (lang) {
            setState(() {
              _selectedLanguage = lang;
            });
          },
          itemBuilder: (context) => [
            _buildLanguageMenuItem(
              DisplayLanguage.vi,
              'Tiếng Việt',
            ),
            _buildLanguageMenuItem(
              DisplayLanguage.en,
              'English',
            ),
            _buildLanguageMenuItem(
              DisplayLanguage.bilingual,
              'Song ngữ (VI – EN)',
            ),
          ],
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.translate_rounded,
                    size: 18,
                    color: _primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _languageLabel(_selectedLanguage),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<DisplayLanguage> _buildLanguageMenuItem(
    DisplayLanguage value,
    String label,
  ) {
    final isSelected = _selectedLanguage == value;
    return PopupMenuItem<DisplayLanguage>(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            size: 18,
            color: isSelected ? _primaryColor : _textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryColor, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _text(
                      vi: 'Việt – Anh • Flutter',
                      en: 'VI – EN • Flutter',
                      bilingual: 'Song ngữ Việt – Anh',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _text(
                    vi: 'Ôn tập trắc nghiệm\nhiệu quả mỗi ngày',
                    en: 'Master Flutter\nbilingual quizzes',
                    bilingual: 'Ôn tập trắc nghiệm\nsong ngữ Flutter',
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _text(
                    vi: 'Hệ thống kiến thức bài bản kèm giải thích chi tiết.',
                    en: 'Structured modules with bilingual explanations.',
                    bilingual: 'Hệ thống kiến thức bài bản kèm lời giải song ngữ.',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.quiz_rounded,
            value: '$_questionCount',
            label: _text(
              vi: 'Câu hỏi',
              en: 'Questions',
              bilingual: 'Câu hỏi',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.layers_rounded,
            value: '$_topicCount',
            label: _text(
              vi: 'Chủ đề',
              en: 'Topics',
              bilingual: 'Chủ đề',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildFeaturedPracticeCard() {
    return Material(
      color: _surfaceColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: _openQuickPractice,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 80),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _primaryColor.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(
                          vi: 'Luyện tập nhanh',
                          en: 'Quick Practice',
                          bilingual: 'Luyện tập nhanh',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _text(
                          vi: 'Làm câu hỏi kèm lời giải song ngữ ngay lập tức',
                          en: 'Practice questions with instant bilingual notes',
                          bilingual: 'Quick Practice • Kèm lời giải song ngữ',
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: _primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoreGrid() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildGridFeatureCard(
              icon: Icons.grid_view_rounded,
              title: _text(
                vi: 'Chọn chủ đề',
                en: 'Select Topic',
                bilingual: 'Chọn chủ đề',
              ),
              subtitle: _text(
                vi: '$_topicCount khối kiến thức',
                en: '$_topicCount Flutter modules',
                bilingual: 'Select Topic • $_topicCount khối',
              ),
              onTap: _openTopicScreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildGridFeatureCard(
              icon: Icons.timer_rounded,
              title: _text(
                vi: 'Thi thử',
                en: 'Mock Exam',
                bilingual: 'Thi thử',
              ),
              subtitle: _text(
                vi: 'Đề thi giới hạn giờ',
                en: 'Timed exam mode',
                bilingual: 'Mock Exam • Tính giờ',
              ),
              onTap: () => _showIntegrationNotice(
                _text(vi: 'Thi thử', en: 'Mock Exam'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _surfaceColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 124),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _primaryColor, size: 22),
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewGroupCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            _buildReviewListTile(
              icon: Icons.history_rounded,
              title: _text(
                vi: 'Ôn tập câu trả lời sai',
                en: 'Review Wrong Answers',
                bilingual: 'Ôn tập câu trả lời sai',
              ),
              subtitle: _text(
                vi: 'Làm lại các câu bạn từng trả lời nhầm',
                en: 'Practice questions you missed before',
                bilingual: 'Review Wrong Answers',
              ),
              onTap: () => _showIntegrationNotice(
                _text(
                  vi: 'Ôn tập câu trả lời sai',
                  en: 'Review Wrong Answers',
                ),
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              indent: 68,
              color: _dividerColor,
            ),
            _buildReviewListTile(
              icon: Icons.favorite_outline_rounded,
              title: _text(
                vi: 'Câu hỏi yêu thích',
                en: 'Favorite Questions',
                bilingual: 'Câu hỏi yêu thích',
              ),
              subtitle: _text(
                vi: 'Xem lại các câu hỏi đã đánh dấu',
                en: 'Access your bookmarked questions',
                bilingual: 'Favorite Questions',
              ),
              onTap: () => _showIntegrationNotice(
                _text(
                  vi: 'Câu hỏi yêu thích',
                  en: 'Favorite Questions',
                ),
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              indent: 68,
              color: _dividerColor,
            ),
            _buildReviewListTile(
              icon: Icons.bar_chart_rounded,
              title: _text(
                vi: 'Thống kê kết quả',
                en: 'Result Statistics',
                bilingual: 'Thống kê kết quả',
              ),
              subtitle: _text(
                vi: 'Xem tổng hợp kết quả theo từng chủ đề',
                en: 'View results grouped by knowledge topic',
                bilingual: 'Result Statistics',
              ),
              onTap: () => _showIntegrationNotice(
                _text(
                  vi: 'Thống kê kết quả',
                  en: 'Result Statistics',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _primaryColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: _textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
