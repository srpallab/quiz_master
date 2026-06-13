import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_master/screens/home_screen.dart';
import 'package:quiz_master/screens/quiz_screen.dart';
import 'package:quiz_master/screens/result_screen.dart';
import 'package:quiz_master/screens/splash_screen.dart';

import '../data/questions_data.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';

class AppRouter {
  static const splash = '/';
  static const home = '/home';
  static const quiz = '/quiz/:title';
  static const result = '/result';
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
        final extra = state.extra;
        if (extra is Map) {
          final questions = extra['questions'] as List<Question>;
          final title = extra['title'] as String;
          return QuizScreen(questions: questions, title: title);
        }
        final String title = extra as String;
        return QuizScreen(
          questions: QuestionsData.flutterQuestions,
          title: title,
        );
      },
    ),
    GoRoute(
      path: AppRouter.result,
      pageBuilder: (context, state) {
        final extra = state.extra as Map;
        final result = extra['result'] as QuizResult;
        final questions = extra['questions'] as List<Question>;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ResultScreen(result: result, questions: questions),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
      },
    ),
  ],
);
