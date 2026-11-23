import 'package:flutter/material.dart';
import '../services/question_service.dart';

class QuestionCard extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final QuestionItem question;
  final DisplayLanguage language;

  const QuestionCard({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.question,
    required this.language,
  });

  static const Color _surfaceColor = Colors.white;
  static const Color _softBgColor = Color(0xFFF8F9FC);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _dividerColor = Color(0xFFF1F5F9);
  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _primarySoft = Color(0xFFEEF2FF);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF475569);
  static const Color _textMuted = Color(0xFF64748B);

  String _formatQuestionCounter() {
    final safeCurrent = (currentIndex + 1).clamp(
      1,
      totalQuestions > 0 ? totalQuestions : 1,
    );
    final safeTotal = totalQuestions > 0 ? totalQuestions : safeCurrent;
    final currentText = safeCurrent.toString().padLeft(2, '0');
    final totalText = safeTotal.toString().padLeft(2, '0');

    if (language == DisplayLanguage.en) {
      return 'QUESTION $currentText / $totalText';
    }
    return 'CÂU $currentText / $totalText';
  }

  @override
  Widget build(BuildContext context) {
    final questionId = question.id.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(questionId),
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            thickness: 1,
            color: _dividerColor,
          ),
          const SizedBox(height: 16),
          _buildQuestionContent(),
        ],
      ),
    );
  }

  Widget _buildHeader(String questionId) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _primarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 15,
                color: _primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                _formatQuestionCounter(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        if (questionId.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _softBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.tag_rounded,
                  size: 13,
                  color: _textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  questionId,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionContent() {
    switch (language) {
      case DisplayLanguage.vi:
        return _buildPrimaryQuestionBlock(
          langBadge: 'VI',
          text: question.questionVi,
        );
      case DisplayLanguage.en:
        return _buildPrimaryQuestionBlock(
          langBadge: 'EN',
          text: question.questionEn,
        );
      case DisplayLanguage.bilingual:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPrimaryQuestionBlock(
              langBadge: 'VI',
              text: question.questionVi,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _softBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLanguageTag(
                    label: 'EN',
                    isPrimary: false,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.questionEn,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildPrimaryQuestionBlock({
    required String langBadge,
    required String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLanguageTag(
          label: langBadge,
          isPrimary: true,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTag({
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isPrimary ? _primarySoft : _surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: isPrimary ? null : Border.all(color: _borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: isPrimary ? _primaryColor : _textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}