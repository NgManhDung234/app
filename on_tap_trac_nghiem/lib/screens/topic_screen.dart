import 'package:flutter/material.dart';
import '../services/quiz_repository.dart';
import 'practice_screen.dart';

class TopicScreen extends StatefulWidget {
  final QuizRepository quizRepository;
  final DisplayLanguage initialLanguage;

  const TopicScreen({
    super.key,
    required this.quizRepository,
    this.initialLanguage = DisplayLanguage.bilingual,
  });

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  static const Color _bgColor = Color(0xFFF8F9FC);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _primarySoft = Color(0xFFEEF2FF);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _errorColor = Color(0xFFDC2626);
  static const Color _errorSoft = Color(0xFFFEF2F2);

  late Future<List<TopicItem>> _topicsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTopics() {
    final future = widget.quizRepository.getTopics();
    future.then<void>((_) {}, onError: (_) {});
    setState(() {
      _topicsFuture = future;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
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

  String _normalize(String input) {
    const withDiacritics =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const withoutDiacritics =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

    final lower = input.toLowerCase().trim();
    final buffer = StringBuffer();
    for (int i = 0; i < lower.length; i++) {
      final char = lower[i];
      final index = withDiacritics.indexOf(char);
      buffer.write(index >= 0 ? withoutDiacritics[index] : char);
    }
    return buffer.toString();
  }

  List<TopicItem> _filterTopics(List<TopicItem> topics) {
    final query = _searchQuery.trim();
    if (query.isEmpty) return topics;

    final normalizedQuery = _normalize(query);
    return topics.where((topic) {
      final idNormalized = _normalize(topic.id);
      final viNormalized = _normalize(topic.nameVi);
      final enNormalized = _normalize(topic.nameEn);
      final tierNormalized = _normalize(topic.tier);
      return idNormalized.contains(normalizedQuery) ||
          viNormalized.contains(normalizedQuery) ||
          enNormalized.contains(normalizedQuery) ||
          tierNormalized.contains(normalizedQuery);
    }).toList();
  }

  void _openTopicPractice(TopicItem topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeScreen(
          quizRepository: widget.quizRepository,
          topic: topic,
          initialLanguage: widget.initialLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _textPrimary,
        titleSpacing: 0,
        title: Text(
          _text(
            vi: 'Khám phá kiến thức',
            en: 'Explore Knowledge',
            bilingual: 'Khám phá kiến thức',
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.bug_report_rounded,
              color: _textSecondary,
            ),
            tooltip: _text(
              vi: 'Chế độ kiểm thử trạng thái',
              en: 'State testing mode',
              bilingual: 'Kiểm thử trạng thái (State Test)',
            ),
            color: _surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (mode) {
              widget.quizRepository.simulateError = (mode == 'error');
              widget.quizRepository.simulateEmpty = (mode == 'empty');
              _clearSearch();
              _loadTopics();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'normal',
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _text(
                          vi: 'Trạng thái bình thường',
                          en: 'Normal state',
                          bilingual: 'Bình thường (Normal)',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'error',
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: _errorColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _text(
                          vi: 'Giả lập trạng thái Lỗi',
                          en: 'Simulate Error state',
                          bilingual: 'Giả lập Lỗi (Error)',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'empty',
                child: Row(
                  children: [
                    const Icon(
                      Icons.inbox_rounded,
                      size: 18,
                      color: _textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _text(
                          vi: 'Giả lập Chưa có dữ liệu',
                          en: 'Simulate Empty state',
                          bilingual: 'Giả lập Trống (Empty)',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<TopicItem>>(
          future: _topicsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error);
            }

            final topics = snapshot.data ?? [];
            if (topics.isEmpty) {
              return _buildEmptyState();
            }

            final totalQuestions = topics.fold<int>(
              0,
              (sum, topic) => sum + topic.questionCount,
            );
            final filteredTopics = _filterTopics(topics);

            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeaderIntro(),
                      const SizedBox(height: 18),
                      _buildSearchBar(),
                      const SizedBox(height: 14),
                      _buildOverviewRow(
                        topicCount: topics.length,
                        totalQuestions: totalQuestions,
                      ),
                      const SizedBox(height: 22),
                      _buildListSectionHeader(
                        filteredCount: filteredTopics.length,
                        totalCount: topics.length,
                      ),
                      const SizedBox(height: 12),
                      if (filteredTopics.isEmpty)
                        _buildNoSearchResultCard()
                      else
                        ...List.generate(filteredTopics.length, (index) {
                          final topic = filteredTopics[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == filteredTopics.length - 1 ? 0 : 12,
                            ),
                            child: _buildTopicCard(topic),
                          );
                        }),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _text(
            vi: 'Chủ đề ôn tập Flutter',
            en: 'Flutter Study Topics',
            bilingual: 'Chủ đề ôn tập Flutter',
          ),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _text(
            vi: 'Chọn một khối kiến thức bên dưới để bắt đầu luyện tập trắc nghiệm chuyên sâu.',
            en: 'Choose a knowledge module below to start focused quiz practice.',
            bilingual:
                'Chọn khối kiến thức để luyện tập chuyên sâu (Select a module to start).',
          ),
          style: const TextStyle(
            fontSize: 14,
            color: _textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 15, color: _textPrimary),
        decoration: InputDecoration(
          hintText: _text(
            vi: 'Tìm chủ đề theo mã khối, tiếng Việt hoặc tiếng Anh...',
            en: 'Search topics by ID, English, or Vietnamese...',
            bilingual: 'Tìm chủ đề Việt – Anh (Search topics)...',
          ),
          hintStyle: const TextStyle(fontSize: 14, color: _textSecondary),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _primaryColor,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  tooltip: _text(
                    vi: 'Xóa tìm kiếm',
                    en: 'Clear search',
                    bilingual: 'Xóa (Clear)',
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _textSecondary,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewRow({
    required int topicCount,
    required int totalQuestions,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.layers_rounded,
            value: '$topicCount',
            label: _text(
              vi: 'Chủ đề',
              en: 'Topics',
              bilingual: 'Chủ đề',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.quiz_rounded,
            value: '$totalQuestions',
            label: _text(
              vi: 'Câu hỏi',
              en: 'Questions',
              bilingual: 'Câu hỏi',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
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

  Widget _buildListSectionHeader({
    required int filteredCount,
    required int totalCount,
  }) {
    final isFiltering = _searchQuery.trim().isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _text(
              vi: 'DANH SÁCH CHỦ ĐỀ',
              en: 'TOPIC LIST',
              bilingual: 'DANH SÁCH CHỦ ĐỀ · TOPICS',
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        if (isFiltering)
          Text(
            _text(
              vi: '$filteredCount / $totalCount kết quả',
              en: '$filteredCount / $totalCount results',
              bilingual: '$filteredCount / $totalCount',
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildTopicCard(TopicItem topic) {
    final isEn = widget.initialLanguage == DisplayLanguage.en;
    final isBilingual = widget.initialLanguage == DisplayLanguage.bilingual;

    final primaryTitle = isEn ? topic.nameEn : topic.nameVi;
    final showSubtitleEn =
        isBilingual && topic.nameEn.isNotEmpty && topic.nameEn != topic.nameVi;
    final questionLabel = _text(
      vi: '${topic.questionCount} câu hỏi',
      en: '${topic.questionCount} questions',
      bilingual: '${topic.questionCount} câu hỏi',
    );

    return Material(
      color: _surfaceColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _openTopicPractice(topic),
        borderRadius: BorderRadius.circular(18),
        splashColor: _primaryColor.withValues(alpha: 0.08),
        highlightColor: _primaryColor.withValues(alpha: 0.04),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    topic.id,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primaryTitle,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          height: 1.3,
                        ),
                      ),
                      if (showSubtitleEn) ...[
                        const SizedBox(height: 3),
                        Text(
                          topic.nameEn,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.help_outline_rounded,
                              size: 13,
                              color: _primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              questionLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResultCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 28,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _text(
              vi: 'Không tìm thấy chủ đề phù hợp',
              en: 'No matching topics found',
              bilingual: 'Không tìm thấy chủ đề phù hợp',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _text(
              vi: 'Không có chủ đề nào khớp với "$_searchQuery". Hãy thử từ khóa khác.',
              en: 'No topics matched "$_searchQuery". Try a different keyword.',
              bilingual:
                  'Không có kết quả cho "$_searchQuery" (No topics matched).',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                _text(
                  vi: 'Xóa từ khóa tìm kiếm',
                  en: 'Clear search keyword',
                  bilingual: 'Xóa tìm kiếm (Clear)',
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: const BorderSide(color: _primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _text(
                vi: 'Đang nạp danh sách chủ đề kiến thức...',
                en: 'Loading knowledge topics...',
                bilingual: 'Đang nạp danh sách chủ đề (Loading topics)...',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _errorSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 32,
                  color: _errorColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _text(
                  vi: 'Không thể tải danh sách chủ đề',
                  en: 'Unable to load topics',
                  bilingual: 'Không thể tải danh sách chủ đề',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    widget.quizRepository.simulateError = false;
                    _loadTopics();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    _text(
                      vi: 'Thử lại',
                      en: 'Try again',
                      bilingual: 'Thử lại (Retry)',
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  size: 32,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _text(
                  vi: 'Chưa có chủ đề nào',
                  en: 'No topics available yet',
                  bilingual: 'Chưa có chủ đề nào (No topics yet)',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _text(
                  vi: 'Ngân hàng câu hỏi hiện chưa có dữ liệu chủ đề để hiển thị.',
                  en: 'The question bank currently has no topic data to display.',
                  bilingual:
                      'Ngân hàng câu hỏi hiện đang trống (No topic data available).',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    widget.quizRepository.simulateEmpty = false;
                    _loadTopics();
                  },
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _text(
                      vi: 'Nạp lại bộ dữ liệu gốc',
                      en: 'Reload original dataset',
                      bilingual: 'Nạp lại dữ liệu (Reload)',
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
