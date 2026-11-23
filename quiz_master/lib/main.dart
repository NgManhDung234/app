import 'package:flutter/material.dart';
import 'services/question_service.dart';
import 'screens/home_screen.dart';

void main() {
  final questionService = QuestionService();
  runApp(QuizMasterApp(questionService: questionService));
}

class QuizMasterApp extends StatelessWidget {
  final QuestionService questionService;

  const QuizMasterApp({super.key, required this.questionService});

  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _bgColor = Color(0xFFF8F9FC);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _dividerColor = Color(0xFFF1F5F9);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizMaster - Ôn tập song ngữ',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: _buildLightTheme(),
      home: HomeScreen(questionService: questionService),
    );
  }

  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: _primaryColor,
      surface: _surfaceColor,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      outline: _borderColor,
      outlineVariant: _dividerColor,
    );

    final baseTextTheme = ThemeData.light(useMaterial3: true).textTheme.apply(
      bodyColor: _textPrimary,
      displayColor: _textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _bgColor,
      textTheme: baseTextTheme.copyWith(
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: _textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: _textPrimary,
          height: 1.45,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: _textPrimary,
          height: 1.45,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: _textSecondary,
          height: 1.4,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _bgColor,
        foregroundColor: _textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _borderColor),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: _borderColor),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _dividerColor,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}