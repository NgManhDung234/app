import 'package:flutter/material.dart';
import '../services/quiz_repository.dart';

class AnswerOption extends StatelessWidget {
  final int index;
  final String textVi;
  final String textEn;
  final DisplayLanguage language;
  final bool isSelected;
  final bool isSubmitted;
  final bool isCorrect;
  final VoidCallback onTap;

  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _primarySoft = Color(0xFFEEF2FF);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  static const Color _successColor = Color(0xFF15803D);
  static const Color _successSoft = Color(0xFFF0FDF4);
  static const Color _successBorder = Color(0xFF86EFAC);

  static const Color _errorColor = Color(0xFFDC2626);
  static const Color _errorSoft = Color(0xFFFEF2F2);
  static const Color _errorBorder = Color(0xFFFCA5A5);

  const AnswerOption({
    super.key,
    required this.index,
    required this.textVi,
    required this.textEn,
    required this.language,
    required this.isSelected,
    required this.isSubmitted,
    required this.isCorrect,
    required this.onTap,
  });

  String _letterLabel() {
    if (index >= 0 && index < 26) {
      return String.fromCharCode(65 + index);
    }
    return '${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _surfaceColor;
    Color borderColor = _borderColor;
    Color badgeBg = const Color(0xFFF8F9FC);
    Color badgeText = _textSecondary;
    double borderWidth = 1.0;
    Widget? trailingIcon;

    if (isSubmitted) {
      if (isCorrect) {
        backgroundColor = _successSoft;
        borderColor = _successBorder;
        badgeBg = _successColor;
        badgeText = Colors.white;
        borderWidth = 1.5;
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: _successColor,
          size: 22,
        );
      } else if (isSelected) {
        backgroundColor = _errorSoft;
        borderColor = _errorBorder;
        badgeBg = _errorColor;
        badgeText = Colors.white;
        borderWidth = 1.5;
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: _errorColor,
          size: 22,
        );
      }
    } else if (isSelected) {
      backgroundColor = _primarySoft;
      borderColor = _primaryColor;
      badgeBg = _primaryColor;
      badgeText = Colors.white;
      borderWidth = 1.5;
    }

    final showVi =
        language == DisplayLanguage.vi || language == DisplayLanguage.bilingual;
    final showEn =
        language == DisplayLanguage.en ||
        (language == DisplayLanguage.bilingual &&
            textEn.trim().isNotEmpty &&
            textEn.trim() != textVi.trim());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isSubmitted ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: _primaryColor.withValues(alpha: 0.08),
          highlightColor: _primaryColor.withValues(alpha: 0.04),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                      border: (!isSubmitted && !isSelected)
                          ? Border.all(color: _borderColor)
                          : null,
                    ),
                    child: Text(
                      _letterLabel(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: badgeText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showVi)
                          Text(
                            textVi,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                              height: 1.35,
                            ),
                          ),
                        if (showVi && showEn) const SizedBox(height: 3),
                        if (showEn)
                          Text(
                            textEn,
                            style: TextStyle(
                              fontSize: showVi ? 13 : 15,
                              fontWeight:
                                  showVi ? FontWeight.w400 : FontWeight.w600,
                              color: showVi ? _textSecondary : _textPrimary,
                              height: 1.35,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 10),
                    trailingIcon,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
