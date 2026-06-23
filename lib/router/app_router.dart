import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/questions_data.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../provider/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/result_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const quiz = '/quiz/:title';
  static const result = '/result';
  // static const profile = '/profile'

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: AppRouter.splash,
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final status = authProvider.status;

        final location = state.uri.toString();

        // Still initializing — stay on splash
        if (status == AuthStatus.unknown) {
          return location == splash ? null : splash;
        }

        final isAuthenticated = status == AuthStatus.authenticated;
        final isOnAuthPage = location == login;

        // Authenticated users should not see auth pages
        if (isAuthenticated && (isOnAuthPage || location == splash)) {
          return home;
        }

        // Unauthenticated users can only access auth pages
        if (!isAuthenticated && !isOnAuthPage) {
          return login;
        }

        return null; // no redirect needed
      },
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(path: home, builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: quiz,
          builder: (context, state) {
            final String title = state.extra as String;
            return QuizScreen(
              questions: QuestionsData.flutterQuestions,
              title: title,
            );
          },
        ),

        GoRoute(
          path: result,
          builder: (ctx, state) {
            final Map<String, dynamic> extra =
                state.extra as Map<String, dynamic>;
            return ResultScreen(
              result: extra['result'] as QuizResult,
              questions: extra['questions'] as List<Question>,
            );
          },
        ),
      ],
      errorBuilder: (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
    );
  }
}
