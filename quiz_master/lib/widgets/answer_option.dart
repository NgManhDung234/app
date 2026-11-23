import 'package:flutter/material.dart';
import '../services/question_service.dart';

class AnswerOption extends StatelessWidget {
  final int index;
  final String textVi;
  final String textEn;
  final DisplayLanguage language;
  final bool isSelected;
  final bool isSubmitted;
  final bool isCorrect;
  final VoidCallback onTap;

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

  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _neutralSoft = Color(0xFFF1F5F9);
  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _primarySoft = Color(0xFFEEF2FF);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _textMuted = Color(0xFF94A3B8);

  static const Color _successColor = Color(0xFF15803D);
  static const Color _successBorder = Color(0xFF16A34A);
  static const Color _successSoft = Color(0xFFF0FDF4);

  static const Color _errorColor = Color(0xFFDC2626);
  static const Color _errorSoft = Color(0xFFFEF2F2);

  String _optionLabel() {
    if (index >= 0 && index < 26) {
      return String.fromCharCode(65 + index);
    }
    return '${index + 1}';
  }

  _OptionVisualStyle _resolveStyle() {
    if (isSubmitted) {
      if (isCorrect) {
        return const _OptionVisualStyle(
          backgroundColor: _successSoft,
          borderColor: _successBorder,
          borderWidth: 1.6,
          badgeBgColor: _successColor,
          badgeTextColor: Colors.white,
          primaryTextColor: _textPrimary,
          secondaryTextColor: _textSecondary,
          trailingIcon: Icons.check_circle_rounded,
          trailingIconColor: _successColor,
        );
      }

      if (isSelected) {
        return const _OptionVisualStyle(
          backgroundColor: _errorSoft,
          borderColor: _errorColor,
          borderWidth: 1.6,
          badgeBgColor: _errorColor,
          badgeTextColor: Colors.white,
          primaryTextColor: _textPrimary,
          secondaryTextColor: _textSecondary,
          trailingIcon: Icons.cancel_rounded,
          trailingIconColor: _errorColor,
        );
      }

      return const _OptionVisualStyle(
        backgroundColor: _surfaceColor,
        borderColor: _borderColor,
        borderWidth: 1.0,
        badgeBgColor: _neutralSoft,
        badgeTextColor: _textSecondary,
        primaryTextColor: _textSecondary,
        secondaryTextColor: _textMuted,
      );
    }

    if (isSelected) {
      return const _OptionVisualStyle(
        backgroundColor: _primarySoft,
        borderColor: _primaryColor,
        borderWidth: 1.8,
        badgeBgColor: _primaryColor,
        badgeTextColor: Colors.white,
        primaryTextColor: _textPrimary,
        secondaryTextColor: _textSecondary,
      );
    }

    return const _OptionVisualStyle(
      backgroundColor: _surfaceColor,
      borderColor: _borderColor,
      borderWidth: 1.0,
      badgeBgColor: _primarySoft,
      badgeTextColor: _primaryColor,
      primaryTextColor: _textPrimary,
      secondaryTextColor: _textSecondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle();
    final label = _optionLabel();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: style.backgroundColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: style.borderColor,
            width: style.borderWidth,
          ),
        ),
        child: InkWell(
          onTap: isSubmitted ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: _primaryColor.withValues(alpha: 0.08),
          highlightColor: _primaryColor.withValues(alpha: 0.04),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: style.badgeBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: style.badgeTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildOptionContent(style),
                  ),
                  if (style.trailingIcon != null) ...[
                    const SizedBox(width: 10),
                    Icon(
                      style.trailingIcon,
                      color: style.trailingIconColor,
                      size: 22,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionContent(_OptionVisualStyle style) {
    final trimmedVi = textVi.trim();
    final trimmedEn = textEn.trim();

    switch (language) {
      case DisplayLanguage.vi:
        return Text(
          textVi,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: style.primaryTextColor,
            height: 1.4,
          ),
        );
      case DisplayLanguage.en:
        return Text(
          trimmedEn.isNotEmpty ? textEn : textVi,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: style.primaryTextColor,
            height: 1.4,
          ),
        );
      case DisplayLanguage.bilingual:
        final hasDistinctEnglish =
            trimmedEn.isNotEmpty && trimmedEn != trimmedVi;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textVi,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: style.primaryTextColor,
                height: 1.4,
              ),
            ),
            if (hasDistinctEnglish) ...[
              const SizedBox(height: 3),
              Text(
                textEn,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: style.secondaryTextColor,
                  height: 1.35,
                ),
              ),
            ],
          ],
        );
    }
  }
}

class _OptionVisualStyle {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final IconData? trailingIcon;
  final Color? trailingIconColor;

  const _OptionVisualStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    this.trailingIcon,
    this.trailingIconColor,
  });
}