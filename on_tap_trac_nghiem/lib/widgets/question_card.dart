import 'package:flutter/material.dart';
import '../services/quiz_repository.dart';

class QuestionCard extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final QuestionItem question;
  final DisplayLanguage language;

  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _primarySoft = Color(0xFFEEF2FF);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _codeBg = Color(0xFF0F172A);
  static const Color _codeText = Color(0xFFE2E8F0);

  const QuestionCard({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.question,
    required this.language,
  });

  String _questionHeaderLabel() {
    switch (language) {
      case DisplayLanguage.vi:
        return 'Câu ${currentIndex + 1} / $totalQuestions';
      case DisplayLanguage.en:
        return 'Question ${currentIndex + 1} / $totalQuestions';
      case DisplayLanguage.bilingual:
        return 'Câu ${currentIndex + 1} / $totalQuestions';
    }
  }

  @override
  Widget build(BuildContext context) {
    final showVi =
        language == DisplayLanguage.vi || language == DisplayLanguage.bilingual;
    final showEn =
        language == DisplayLanguage.en ||
        (language == DisplayLanguage.bilingual &&
            question.questionEn.isNotEmpty &&
            question.questionEn != question.questionVi);
    final hasCode = question.codeSnippet.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.help_outline_rounded,
                      size: 15,
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _questionHeaderLabel(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (question.topicId.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Text(
                    question.topicId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textSecondary,
                    ),
                  ),
                ),
              if (question.difficulty.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Text(
                    question.difficulty,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (showVi)
            Text(
              question.questionVi,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                height: 1.45,
              ),
            ),
          if (showVi && showEn) const SizedBox(height: 10),
          if (showEn)
            Text(
              question.questionEn,
              style: TextStyle(
                fontSize: showVi ? 14.5 : 17,
                fontWeight: showVi ? FontWeight.w500 : FontWeight.w700,
                fontStyle: showVi ? FontStyle.italic : FontStyle.normal,
                color: showVi ? _textSecondary : _textPrimary,
                height: 1.45,
              ),
            ),
          if (hasCode) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _codeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  question.codeSnippet,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: _codeText,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
