import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';

class ResultScreen extends StatelessWidget {
  final QuizResult result;
  final List<Question> questions;
  const ResultScreen({
    super.key,
    required this.result,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Your Score: ${result.totalScore}/${result.maxScore}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
