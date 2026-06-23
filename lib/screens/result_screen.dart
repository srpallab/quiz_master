import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../theme/app_theme.dart';
import '../widgets/review_card.dart';

class ResultScreen extends StatefulWidget {
  final QuizResult result;
  final List<Question> questions;
  const ResultScreen({
    super.key,
    required this.result,
    required this.questions,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnim;
  late final Animation<int> _countAnim;
  bool _showReview = false;

  // ── Share ────────────────────────────────────────────────────────────────

  void _shareResult() {
    final r = widget.result;
    final text =
        '🎯 Quiz Master Result\n'
        '${r.gradeMessage}  I scored ${r.totalScore}/${r.maxScore} '
        '(${r.percentage.toStringAsFixed(0)}%) — Grade ${r.grade}.\n'
        '✅ ${r.correctAnswers}/${r.totalQuestions} correct answers.';
    SharePlus.instance.share(ShareParams(text: text));
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'S':
        return const Color(0xFF7C3AED);
      case 'A':
        return AppTheme.successGreen;
      case 'B':
        return const Color(0xFF0284C7);
      case 'C':
        return AppTheme.warningAmber;
      case 'D':
        return const Color(0xFFF97316);
      default:
        return AppTheme.errorRed;
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _countAnim = IntTween(
      begin: 0,
      end: widget.result.totalScore,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _customResultAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  spacing: 20,
                  children: [
                    // Hero Card
                    _heroCard(r),
                    // States
                    _buildStatsRow(r),
                    // Actions Buttons
                    _buildActionButtons(context),
                    // Review
                    _buildReviewSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customResultAppBar(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlue,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            icon: const Icon(Icons.home_rounded, color: Colors.white),
          ),

          const Expanded(
            child: Text(
              'Quiz Result',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          IconButton(
            onPressed: _shareResult,
            icon: const Icon(Icons.share_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(QuizResult r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EDF8)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        spacing: 20,
        children: [
          // Grade message badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _gradeColor(r.grade).withAlpha(31), // 0.12 * 255
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _gradeColor(r.grade).withAlpha(102),
              ), // 0.4 * 255
            ),
            child: Text(
              r.gradeMessage,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _gradeColor(r.grade),
                fontFamily: 'Nunito',
              ),
            ),
          ),

          // Animated Ring + Score Counter
          AnimatedBuilder(
            animation: _controller,
            builder: (_, _) {
              return SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: _ScoreRingPainter(
                    progress: _progressAnim.value * (r.percentage / 100),
                    color: _gradeColor(r.grade),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_countAnim.value}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D1B2A),
                            fontFamily: 'Nunito',
                          ),
                        ),
                        Text(
                          'pts',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neutralGrey,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Grade letter
          Text(
            'Grade  ${r.grade}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _gradeColor(r.grade),
              fontFamily: 'Nunito',
            ),
          ),

          Text(
            '${r.percentage.toStringAsFixed(0)}% accuracy',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.neutralGrey,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(QuizResult r) {
    return Row(
      children: [
        _StatChip(
          label: 'Correct',
          value: '${r.correctAnswers}',
          icon: Icons.check_circle_rounded,
          color: AppTheme.successGreen,
        ),
        const SizedBox(width: 10),
        _StatChip(
          label: 'Wrong',
          value: '${r.totalQuestions - r.correctAnswers}',
          icon: Icons.cancel_rounded,
          color: AppTheme.errorRed,
        ),
        const SizedBox(width: 10),
        _StatChip(
          label: 'Score',
          value: '${r.totalScore}/${r.maxScore}',
          icon: Icons.star_rounded,
          color: AppTheme.warningAmber,
        ),
      ],
    );
  }

  // ── Action buttons ───────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => setState(() => _showReview = !_showReview),
          icon: Icon(
            _showReview
                ? Icons.keyboard_arrow_up_rounded
                : Icons.list_alt_rounded,
          ),
          label: Text(_showReview ? 'Hide Review' : 'Review Answers'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          icon: const Icon(Icons.home_rounded),
          label: const Text('Back to Home'),
        ),
      ],
    );
  }

  // ── Review section ───────────────────────────────────────────────────────

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Answer Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1B2A),
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(widget.result.answers.length, (i) {
          final record = widget.result.answers[i];
          final question = widget.questions.firstWhere(
            (q) => q.id == record.questionId,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ReviewCard(index: i, question: question, record: record),
          );
        }),
      ],
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScoreRingPainter({
    super.repaint,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = const Color(0xFFE8EDF8)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.progress != progress;
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutralGrey,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
