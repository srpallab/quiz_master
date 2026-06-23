import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../theme/app_theme.dart';

class ReviewCard extends StatelessWidget {
  final int index;
  final Question question;
  final AnswerRecord record;

  const ReviewCard({
    super.key,
    required this.index,
    required this.question,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = record.isCorrect;
    final wasSkipped = record.selectedIndex == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect
              ? AppTheme.correctBorder.withOpacity(0.4)
              : AppTheme.wrongBorder.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? AppTheme.successGreen : AppTheme.errorRed)
                .withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppTheme.correctBorder
                      : AppTheme.wrongBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Q${index + 1}  ·  ${question.category}  ·  ${question.difficulty.label}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neutralGrey,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              if (isCorrect)
                Text(
                  '+${record.pointsEarned} pts',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.successGreen,
                    fontFamily: 'Nunito',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Question text ────────────────────────────────────────
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B2A),
              fontFamily: 'Nunito',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // ── Answer rows ──────────────────────────────────────────
          if (!wasSkipped && !isCorrect) ...[
            _AnswerRow(
              label: 'Your answer',
              text: question.options[record.selectedIndex!],
              isCorrect: false,
            ),
            const SizedBox(height: 6),
          ],
          _AnswerRow(
            label: 'Correct answer',
            text: question.options[record.correctIndex],
            isCorrect: true,
          ),
          if (wasSkipped) ...[
            const SizedBox(height: 6),
            const Text(
              'Not answered',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.neutralGrey,
                fontStyle: FontStyle.italic,
                fontFamily: 'Nunito',
              ),
            ),
          ],

          // ── Explanation ──────────────────────────────────────────
          if (question.explanation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1A2340),
                        fontFamily: 'Nunito',
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Private answer row ────────────────────────────────────────────────────────

class _AnswerRow extends StatelessWidget {
  final String label;
  final String text;
  final bool isCorrect;

  const _AnswerRow({
    required this.label,
    required this.text,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppTheme.successGreen : AppTheme.errorRed;
    final bg = isCorrect ? AppTheme.correctBg : AppTheme.wrongBg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$label:  ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Nunito',
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
