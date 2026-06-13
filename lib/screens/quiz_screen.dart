import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_buttons.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String title;

  const QuizScreen({super.key, required this.questions, required this.title});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _answered = false;
  final List<AnswerRecord> _records = [];

  static const int _totalTime = 30;
  int _timeLeft = 30;
  Timer? _timer;
  bool _timedOut = false;

  Question get _currentQuestion => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _totalTime;
    _timedOut = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 0) {
        timer.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    if (_answered) return;
    setState(() {
      _answered = true;
      _timedOut = true;
    });
    _records.add(
      AnswerRecord(
        questionId: _currentQuestion.id,
        selectedIndex: null,
        correctIndex: _currentQuestion.correctIndex,
        isCorrect: false,
        pointsEarned: 0,
      ),
    );
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    _timer?.cancel();

    final isCorrect = index == _currentQuestion.correctIndex;
    final timeBonus = isCorrect ? _timeLeft * 2 : 0;
    final points = isCorrect
        ? _currentQuestion.difficulty.points + timeBonus
        : 0;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      _score += points;
    });

    _records.add(
      AnswerRecord(
        questionId: _currentQuestion.id,
        selectedIndex: index,
        correctIndex: _currentQuestion.correctIndex,
        isCorrect: isCorrect,
        pointsEarned: points,
      ),
    );
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    final maxScore = widget.questions.fold<int>(
      0,
      (sum, q) => sum + q.difficulty.points,
    );

    final result = QuizResult(
      totalQuestions: widget.questions.length,
      correctAnswers: _records.where((r) => r.isCorrect).length,
      totalScore: _score,
      maxScore: maxScore,
      answers: _records,
    );

    context.go(
      '/result',
      extra: {'result': result, 'questions': widget.questions},
    );
  }

  AnswerState _stateForOption(int index) {
    if (!_answered) return AnswerState.neutral;
    if (index == _currentQuestion.correctIndex) {
      return _selectedIndex == index
          ? AnswerState.correct
          : AnswerState.revealed;
    }
    if (index == _selectedIndex) return AnswerState.wrong;
    return AnswerState.neutral;
  }

  static const List<String> _letters = ['A', 'B', 'C', 'D'];

  Color _timerBarColor() {
    final ratio = _timeLeft / _totalTime;
    if (ratio > 0.5) return AppTheme.successGreen;
    if (ratio > 0.25) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == widget.questions.length - 1;
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar with progress ──
            Container(
              color: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                      Text(
                        '${_currentIndex + 1}/${widget.questions.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // Timer bar
            if (!_answered)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1, end: 0),
                duration: const Duration(seconds: 30),
                builder: (context, value, _) {
                  return Container(
                    height: 4,
                    color: _timerBarColor().withAlpha((value * 255).toInt()),
                  );
                },
              )
            else
              Container(height: 4, color: Colors.transparent),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2C3E50)
                          : const Color(0xFFE8EDF8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+${_currentQuestion.difficulty.points} pts',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBlue,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _currentQuestion.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBlue,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                          if (!_answered) ...[
                            const Spacer(),
                            Text(
                              '${_timeLeft}s',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _timeLeft <= 5
                                    ? AppTheme.errorRed
                                    : AppTheme.primaryBlue,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Question text
                      Text(
                        'Q${_currentIndex + 1}. ${_currentQuestion.text}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFE8EDF8)
                              : const Color(0xFF0D1B2A),
                          fontFamily: 'Nunito',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Answer options
                      ...List.generate(
                        _currentQuestion.options.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AnswerButton(
                            label: _currentQuestion.options[i],
                            optionLetter: _letters[i],
                            state: _stateForOption(i),
                            onTap: () => _selectAnswer(i),
                          ),
                        ),
                      ),

                      // Explanation (shown after answering)
                      if (_answered && _currentQuestion.explanation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _timedOut
                                  ? AppTheme.wrongBg.withAlpha(180)
                                  : (_selectedIndex != null &&
                                            _selectedIndex ==
                                                _currentQuestion.correctIndex
                                        ? AppTheme.correctBg.withAlpha(180)
                                        : AppTheme.wrongBg.withAlpha(180)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _timedOut
                                    ? AppTheme.wrongBorder.withAlpha(120)
                                    : (_selectedIndex != null &&
                                              _selectedIndex ==
                                                  _currentQuestion.correctIndex
                                          ? AppTheme.correctBorder.withAlpha(
                                              120,
                                            )
                                          : AppTheme.wrongBorder.withAlpha(
                                              120,
                                            )),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _timedOut
                                          ? Icons.timer_off_rounded
                                          : (_selectedIndex != null &&
                                                    _selectedIndex ==
                                                        _currentQuestion
                                                            .correctIndex
                                                ? Icons.check_circle_rounded
                                                : Icons.cancel_rounded),
                                      size: 18,
                                      color: _timedOut
                                          ? AppTheme.errorRed
                                          : (_selectedIndex != null &&
                                                    _selectedIndex ==
                                                        _currentQuestion
                                                            .correctIndex
                                                ? AppTheme.successGreen
                                                : AppTheme.errorRed),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _timedOut
                                          ? 'Time\'s up!'
                                          : (_selectedIndex != null &&
                                                    _selectedIndex ==
                                                        _currentQuestion
                                                            .correctIndex
                                                ? 'Correct!'
                                                : 'Incorrect'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _timedOut
                                            ? AppTheme.errorRed
                                            : (_selectedIndex != null &&
                                                      _selectedIndex ==
                                                          _currentQuestion
                                                              .correctIndex
                                                  ? AppTheme.successGreen
                                                  : AppTheme.errorRed),
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _currentQuestion.explanation!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2C3E50),
                                    fontFamily: 'Nunito',
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Next button
                      if (_answered)
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(isLast ? 'See Results' : 'Next Question'),
                              const SizedBox(width: 8),
                              Icon(
                                isLast
                                    ? Icons.emoji_events_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
