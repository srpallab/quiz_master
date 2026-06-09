import 'package:go_router/go_router.dart';
import 'package:quiz_master/models/quiz_result.dart';
import 'package:quiz_master/screens/home_screen.dart';
import 'package:quiz_master/screens/quiz_screen.dart';
import 'package:quiz_master/screens/result_screen.dart';
import 'package:quiz_master/screens/splash_screen.dart';

import '../data/questions_data.dart';

class AppRouter {
  static const splash = '/';
  static const home = '/home';
  static const quiz = '/quiz/:title';
  static const result = '/result';
  // static const profile = '/profile'
}

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRouter.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRouter.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRouter.quiz,
      builder: (context, state) {
        final String title = state.extra as String;
        return QuizScreen(
          questions: QuestionsData.flutterQuestions,
          title: title,
        );
      },
    ),
    GoRoute(
      path: AppRouter.result,
      builder: (context, state) {
        final stateTotalScore = state.pathParameters['totalScore']!;

        return ResultScreen(
          questions: [],
          result: QuizResult(
            totalQuestions: 0,
            totalScore: int.parse(stateTotalScore),
            correctAnswers: 0,
            maxScore: 0,
            answers: [],
          ),
        );
      },
    ),
  ],
);
