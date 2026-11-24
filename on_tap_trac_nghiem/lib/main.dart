import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/quiz_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(QuizMasterApp(quizRepository: QuizRepository()));
}

class QuizMasterApp extends StatelessWidget {
  final QuizRepository quizRepository;

  const QuizMasterApp({
    super.key,
    required this.quizRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FC),
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
      ),
      home: HomeScreen(quizRepository: quizRepository),
    );
  }
}
