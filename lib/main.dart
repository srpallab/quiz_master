import 'package:flutter/material.dart';
import 'package:quiz_master/providers/theme_provider.dart';
import 'package:quiz_master/router/app_router.dart';
import 'package:quiz_master/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeProvider.themeMode,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Quiz Master',
          themeMode: ThemeProvider.themeMode.value,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: appRouter,
        );
      },
    );
  }
}
