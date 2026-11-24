import 'package:flutter/material.dart';
import '../services/quiz_repository.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_option.dart';

class PracticeScreen extends StatefulWidget {
  final QuizRepository quizRepository;
  final TopicItem? topic;
  final DisplayLanguage initialLanguage;

  const PracticeScreen({
    super.key,
    required this.quizRepository,
    this.topic,
    this.initialLanguage = DisplayLanguage.bilingual,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  static const Color _bgColor = Color(0xFFF8F9FC);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _dividerColor = Color(0xFFF1F5F9);
  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _primarySoft = Color(0xFFEEF2FF);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  static const Color _successColor = Color(0xFF15803D);
  static const Color _successSoft = Color(0xFFF0FDF4);
  static const Color _successBorder = Color(0xFFBBF7D0);

  static const Color _warningColor = Color(0xFFC2410C);
  static const Color _warningSoft = Color(0xFFFFF7ED);
  static const Color _warningBorder = Color(0xFFFED7AA);

  static const Color _errorColor = Color(0xFFDC2626);
  static const Color _errorSoft = Color(0xFFFEF2F2);

  late Future<List<QuestionItem>> _questionsFuture;
  late DisplayLanguage _language;
  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _isSubmitted = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _loadQuestions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadQuestions() {
    final future =
        widget.quizRepository.getQuestionsByTopic(widget.topic?.id);
    future.then<void>((_) {}, onError: (_) {});
    setState(() {
      _currentIndex = 0;
      _selectedAnswerIndex = null;
      _isSubmitted = false;
      _correctCount = 0;
      _questionsFuture = future;
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  String _text({
    required String vi,
    required String en,
    String? bilingual,
  }) {
    switch (_language) {
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

  String _optionLabel(int index) {
    if (index >= 0 && index < 26) {
      return String.fromCharCode(65 + index);
    }
    return '${index + 1}';
  }

  String _formatCorrectAnswer(QuestionItem question) {
    final idx = question.correctIndex;
    final letter = _optionLabel(idx);
    final viOption =
        (idx >= 0 && idx < question.optionsVi.length) ? question.optionsVi[idx] : '';
    final enOption =
        (idx >= 0 && idx < question.optionsEn.length) ? question.optionsEn[idx] : viOption;

    switch (_language) {
      case DisplayLanguage.vi:
        return '$letter. $viOption';
      case DisplayLanguage.en:
        return '$letter. $enOption';
      case DisplayLanguage.bilingual:
        if (viOption == enOption || enOption.isEmpty) {
          return '$letter. $viOption';
        }
        return '$letter. $viOption ($enOption)';
    }
  }

  void _selectAnswer(int index, int correctIndex) {
    if (_isSubmitted) return;
    setState(() {
      _selectedAnswerIndex = index;
      _isSubmitted = true;
      if (index == correctIndex) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentIndex < totalQuestions - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isSubmitted = false;
      });
      _scrollToTop();
    } else {
      _showResultDialog(totalQuestions);
    }
  }

  void _showResultDialog(int totalQuestions) {
    final percentage = totalQuestions > 0
        ? ((_correctCount / totalQuestions) * 100).round()
        : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
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
                Icons.emoji_events_rounded,
                color: _primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _text(
                vi: 'Hoàn thành luyện tập',
                en: 'Practice Completed',
                bilingual: 'Hoàn thành luyện tập',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _text(
                vi: 'Bạn đã trả lời đúng $_correctCount / $totalQuestions câu hỏi.',
                en: 'You answered $_correctCount / $totalQuestions questions correctly.',
                bilingual:
                    'Bạn đã trả lời đúng $_correctCount / $totalQuestions câu hỏi.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                color: _textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogMetric(
                    value: '$_correctCount/$totalQuestions',
                    label: _text(
                      vi: 'Câu đúng',
                      en: 'Correct',
                      bilingual: 'Câu đúng',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: _borderColor,
                  ),
                  _buildDialogMetric(
                    value: '$percentage%',
                    label: _text(
                      vi: 'Độ chính xác',
                      en: 'Accuracy',
                      bilingual: 'Độ chính xác',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _loadQuestions();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryColor,
                        side: const BorderSide(color: _borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _text(
                          vi: 'Làm lại',
                          en: 'Retry',
                          bilingual: 'Làm lại',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _text(
                          vi: 'Hoàn tất',
                          en: 'Finish',
                          bilingual: 'Hoàn tất',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogMetric({
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarTitle() {
    final topic = widget.topic;
    if (topic == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _text(
              vi: 'Luyện tập tổng hợp',
              en: 'Quick Practice',
              bilingual: 'Luyện tập tổng hợp',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          if (_language == DisplayLanguage.bilingual)
            const Text(
              'Quick Practice',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _language == DisplayLanguage.en ? topic.nameEn : topic.nameVi,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        if (_language == DisplayLanguage.bilingual &&
            topic.nameEn.isNotEmpty &&
            topic.nameEn != topic.nameVi)
          Text(
            topic.nameEn,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildLanguagePillButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Center(
        child: PopupMenuButton<DisplayLanguage>(
          tooltip: _text(
            vi: 'Chọn ngôn ngữ hiển thị',
            en: 'Select display language',
            bilingual: 'Chọn ngôn ngữ hiển thị',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          color: _surfaceColor,
          onSelected: (lang) {
            setState(() {
              _language = lang;
            });
          },
          itemBuilder: (context) => [
            _buildLanguageMenuItem(DisplayLanguage.vi, 'Tiếng Việt'),
            _buildLanguageMenuItem(DisplayLanguage.en, 'English'),
            _buildLanguageMenuItem(
              DisplayLanguage.bilingual,
              'Song ngữ (VI – EN)',
            ),
          ],
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    size: 16,
                    color: _primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _languageLabel(_language),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<DisplayLanguage> _buildLanguageMenuItem(
    DisplayLanguage value,
    String label,
  ) {
    final isSelected = _language == value;
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
        title: _buildAppBarTitle(),
        actions: [
          _buildLanguagePillButton(),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<QuestionItem>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error);
            }

            final questions = snapshot.data ?? [];
            if (questions.isEmpty) {
              return _buildEmptyState();
            }

            final safeIndex = _currentIndex.clamp(0, questions.length - 1);
            final currentQuestion = questions[safeIndex];
            final isCorrectAnswer =
                _selectedAnswerIndex == currentQuestion.correctIndex;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProgressCard(
                          currentIndex: safeIndex,
                          totalQuestions: questions.length,
                        ),
                        const SizedBox(height: 16),
                        QuestionCard(
                          currentIndex: safeIndex,
                          totalQuestions: questions.length,
                          question: currentQuestion,
                          language: _language,
                        ),
                        const SizedBox(height: 20),
                        _buildAnswersHeader(),
                        const SizedBox(height: 10),
                        ...List.generate(currentQuestion.optionsVi.length, (index) {
                          final textEn = index < currentQuestion.optionsEn.length
                              ? currentQuestion.optionsEn[index]
                              : currentQuestion.optionsVi[index];
                          return AnswerOption(
                            index: index,
                            textVi: currentQuestion.optionsVi[index],
                            textEn: textEn,
                            language: _language,
                            isSelected: _selectedAnswerIndex == index,
                            isSubmitted: _isSubmitted,
                            isCorrect: index == currentQuestion.correctIndex,
                            onTap: () => _selectAnswer(
                              index,
                              currentQuestion.correctIndex,
                            ),
                          );
                        }),
                        if (_isSubmitted) ...[
                          const SizedBox(height: 8),
                          _buildExplanationCard(
                            question: currentQuestion,
                            isCorrectAnswer: isCorrectAnswer,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildBottomNavigationBar(
                  currentIndex: safeIndex,
                  totalQuestions: questions.length,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required int currentIndex,
    required int totalQuestions,
  }) {
    final answeredCount = _isSubmitted ? currentIndex + 1 : currentIndex;
    final unansweredCount = (totalQuestions - answeredCount).clamp(0, totalQuestions);
    final progressValue =
        totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _text(
                        vi: 'Câu ${currentIndex + 1} / $totalQuestions',
                        en: 'Question ${currentIndex + 1} / $totalQuestions',
                        bilingual: 'Câu ${currentIndex + 1} / $totalQuestions',
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _isSubmitted ? _primarySoft : _bgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isSubmitted
                              ? _primaryColor.withValues(alpha: 0.25)
                              : _borderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSubmitted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 13,
                            color: _isSubmitted ? _primaryColor : _textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isSubmitted
                                ? _text(
                                    vi: 'Đã trả lời',
                                    en: 'Answered',
                                    bilingual: 'Đã trả lời',
                                  )
                                : _text(
                                    vi: 'Chưa trả lời',
                                    en: 'Unanswered',
                                    bilingual: 'Chưa trả lời',
                                  ),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color:
                                  _isSubmitted ? _primaryColor : _textSecondary,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _successSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _successBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: _successColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _text(
                        vi: '$_correctCount đúng',
                        en: '$_correctCount correct',
                        bilingual: '$_correctCount đúng',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 7,
              backgroundColor: _primarySoft,
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _text(
                  vi: 'Đã hoàn thành: $answeredCount',
                  en: 'Answered: $answeredCount',
                  bilingual: 'Đã trả lời: $answeredCount',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _text(
                  vi: 'Chưa trả lời: $unansweredCount',
                  en: 'Remaining: $unansweredCount',
                  bilingual: 'Chưa trả lời: $unansweredCount',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _text(
            vi: 'CHỌN ĐÁP ÁN',
            en: 'SELECT AN ANSWER',
            bilingual: 'CHỌN ĐÁP ÁN · OPTIONS',
          ),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        if (_isSubmitted)
          Text(
            _text(
              vi: 'Đã khóa lựa chọn',
              en: 'Answer locked',
              bilingual: 'Đã khóa đáp án',
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildExplanationCard({
    required QuestionItem question,
    required bool isCorrectAnswer,
  }) {
    final accentColor = isCorrectAnswer ? _successColor : _warningColor;
    final cardBg = isCorrectAnswer ? _successSoft : _warningSoft;
    final cardBorder = isCorrectAnswer ? _successBorder : _warningBorder;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCorrectAnswer
                      ? Icons.check_circle_rounded
                      : Icons.info_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrectAnswer
                          ? _text(
                              vi: 'Chính xác!',
                              en: 'Correct!',
                              bilingual: 'Chính xác! · Correct!',
                            )
                          : _text(
                              vi: 'Chưa chính xác',
                              en: 'Not quite right',
                              bilingual: 'Chưa chính xác · Incorrect',
                            ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCorrectAnswer
                          ? _text(
                              vi: 'Bạn đã chọn đúng đáp án của câu hỏi này.',
                              en: 'You selected the right answer.',
                              bilingual: 'Bạn đã chọn đúng đáp án.',
                            )
                          : _text(
                              vi: 'Hãy xem đáp án đúng và giải thích bên dưới.',
                              en: 'Review the correct answer and explanation below.',
                              bilingual: 'Xem đáp án đúng và giải thích bên dưới.',
                            ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(
                    vi: 'ĐÁP ÁN ĐÚNG',
                    en: 'CORRECT ANSWER',
                    bilingual: 'ĐÁP ÁN ĐÚNG · CORRECT ANSWER',
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCorrectAnswer(question),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: cardBorder),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                _text(
                  vi: 'Giải thích song ngữ',
                  en: 'Bilingual Explanation',
                  bilingual: 'Giải thích song ngữ · Explanation',
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (question.explanationVi.isNotEmpty)
            _buildExplanationItem(
              badgeText: 'Tiếng Việt',
              content: question.explanationVi,
            ),
          if (question.explanationVi.isNotEmpty &&
              question.explanationEn.isNotEmpty)
            const SizedBox(height: 10),
          if (question.explanationEn.isNotEmpty)
            _buildExplanationItem(
              badgeText: 'English',
              content: question.explanationEn,
              isItalic: true,
            ),
        ],
      ),
    );
  }

  Widget _buildExplanationItem({
    required String badgeText,
    required String content,
    bool isItalic = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: isItalic ? _textSecondary : _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar({
    required int currentIndex,
    required int totalQuestions,
  }) {
    final isLastQuestion = currentIndex >= totalQuestions - 1;
    final buttonText = isLastQuestion
        ? _text(
            vi: 'Xem kết quả',
            en: 'View Results',
            bilingual: 'Xem kết quả',
          )
        : _text(
            vi: 'Câu tiếp theo',
            en: 'Next Question',
            bilingual: 'Câu tiếp theo',
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: _surfaceColor,
        border: Border(
          top: BorderSide(color: _borderColor),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed:
              _isSubmitted ? () => _nextQuestion(totalQuestions) : null,
          icon: Icon(
            isLastQuestion
                ? Icons.flag_rounded
                : Icons.arrow_forward_rounded,
            size: 20,
          ),
          label: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _borderColor,
            disabledForegroundColor: _textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
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
                vi: 'Đang nạp danh sách câu hỏi...',
                en: 'Loading questions...',
                bilingual: 'Đang nạp câu hỏi (Loading questions)...',
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
                  vi: 'Không thể tải danh sách câu hỏi',
                  en: 'Unable to load questions',
                  bilingual: 'Không thể tải câu hỏi',
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
                  onPressed: _loadQuestions,
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
                  Icons.quiz_outlined,
                  size: 32,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _text(
                  vi: 'Chưa có câu hỏi nào',
                  en: 'No questions available',
                  bilingual: 'Chưa có câu hỏi nào',
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
                  vi: 'Chủ đề này hiện chưa có câu hỏi nào để luyện tập.',
                  en: 'This topic does not have any practice questions yet.',
                  bilingual: 'Chủ đề này hiện chưa có câu hỏi luyện tập.',
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
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  label: Text(
                    _text(
                      vi: 'Quay lại chọn chủ đề',
                      en: 'Back to topics',
                      bilingual: 'Quay lại chọn chủ đề',
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
