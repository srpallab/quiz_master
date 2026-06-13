import 'package:flutter/material.dart';

import '../data/questions_data.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'home_header_stat.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  const HomeHeader({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 28),
      child: Column(
        mainAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'Good morning! 👋',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(220),
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Ready to learn?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: ThemeProvider.toggle,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha(77)),
                      ),
                      child: ListenableBuilder(
                        listenable: ThemeProvider.themeMode,
                        builder: (context, _) {
                          final isDark = ThemeProvider.themeMode.value ==
                              ThemeMode.dark;
                          return Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            color: Colors.white,
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha(77)),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              HomeHeaderStat(
                icon: Icons.quiz_outlined,
                value: '${QuestionsData.flutterQuestions.length}',
                label: 'Questions',
              ),

              HomeHeaderStat(
                icon: Icons.category_outlined,
                value: '4',
                label: 'Categories',
              ),

              HomeHeaderStat(
                icon: Icons.emoji_events_outlined,
                value: '160',
                label: 'Max Score',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
