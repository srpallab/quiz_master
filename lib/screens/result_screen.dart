import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/questions_data.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final QuizResult result;
  final List<Question> questions;
  const ResultScreen({
    super.key,
    required this.result,
    required this.questions,
  });

  Map<String, CategoryStat> _categoryStats() {
    final stats = <String, CategoryStat>{};
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final record = result.answers.length > i ? result.answers[i] : null;
      stats.putIfAbsent(q.category, () => CategoryStat());
      stats[q.category]!.total++;
      if (record != null && record.isCorrect) {
        stats[q.category]!.correct++;
      }
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = result.percentage;
    final incorrect = result.totalQuestions - result.correctAnswers;
    final categoryStats = _categoryStats();
    final incorrectRecords = <int>[];
    for (var i = 0; i < result.answers.length; i++) {
      if (!result.answers[i].isCorrect) {
        incorrectRecords.add(i);
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Score card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E4DA4), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Quiz Complete!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Circular percentage
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 10,
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${percentage.round()}%',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                Text(
                                  result.grade,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.gradeMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.totalScore} / ${result.maxScore} points',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(200),
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  _StatCard(
                    icon: Icons.check_circle_rounded,
                    value: '${result.correctAnswers}',
                    label: 'Correct',
                    color: AppTheme.successGreen,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.cancel_rounded,
                    value: '$incorrect',
                    label: 'Incorrect',
                    color: AppTheme.errorRed,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.quiz_rounded,
                    value: '${result.totalQuestions}',
                    label: 'Total',
                    color: AppTheme.primaryBlue,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category breakdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2838) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE8EDF8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...categoryStats.entries.map((entry) {
                      final cat = entry.value;
                      final catPct = cat.total > 0 ? cat.correct / cat.total : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFB0BEC5)
                                        : const Color(0xFF2C3E50),
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                Text(
                                  '${cat.correct}/${cat.total}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFFE8EDF8)
                                        : const Color(0xFF0D1B2A),
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: catPct,
                                backgroundColor: isDark
                                    ? const Color(0xFF2C3E50)
                                    : const Color(0xFFE8EDF8),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  catPct >= 0.7
                                      ? AppTheme.successGreen
                                      : catPct >= 0.4
                                          ? AppTheme.warningAmber
                                          : AppTheme.errorRed,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Answer review
              if (incorrectRecords.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B2838) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C3E50)
                          : const Color(0xFFE8EDF8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Review Incorrect Answers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...incorrectRecords.map((i) {
                        final q = questions[i];
                        final record = result.answers[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q${i + 1}. ${q.text}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFE8EDF8)
                                      : const Color(0xFF0D1B2A),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.close_rounded,
                                      size: 16, color: AppTheme.errorRed),
                                  const SizedBox(width: 4),
                                  Text(
                                    record.selectedIndex != null
                                        ? q.options[record.selectedIndex!]
                                        : '(timed out)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.errorRed,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.check_rounded,
                                      size: 16, color: AppTheme.successGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    q.correctAnswer,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.successGreen,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                ],
                              ),
                              if (q.explanation != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  q.explanation!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? const Color(0xFF78909C)
                                        : const Color(0xFF546E7A),
                                    fontFamily: 'Nunito',
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final questions = QuestionsData.prepareShuffled();
                        context.go(
                          '/quiz/Try Again',
                          extra: {
                            'questions': questions,
                            'title': 'Flutter Quiz',
                          },
                        );
                      },
                      icon: const Icon(Icons.replay_rounded, size: 20),
                      label: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryStat {
  int total = 0;
  int correct = 0;
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B2838) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE8EDF8),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFFE8EDF8) : const Color(0xFF0D1B2A),
                fontFamily: 'Nunito',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF78909C) : const Color(0xFF546E7A),
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
