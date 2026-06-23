import 'package:flutter/material.dart';

import '../data/result_mapper.dart';
import '../models/question.dart';
import '../services/quiz_service.dart';

enum QuizFetchStatus { idle, loading, loaded, error }

class QuizProvider with ChangeNotifier {
  final QuizService _service;

  QuizProvider({QuizService? service}) : _service = service ?? QuizService();

  QuizFetchStatus _status = QuizFetchStatus.idle;
  List<Question> _questions = [];
  String? _errorMessage;

  QuizFetchStatus get status => _status;
  List<Question> get questions => _questions;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == QuizFetchStatus.loading;
  bool get hasError => _status == QuizFetchStatus.error;
  bool get hasQuestions => _questions.isNotEmpty;

  Future<void> fetchQuestions({int amount = 10}) async {
    if (_status == QuizFetchStatus.loading) return; // guard double-tap

    _status = QuizFetchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.fetchQuestions(amount: amount);
      _questions = ResultMapper.toQuestions(response.results ?? []);
      _status = QuizFetchStatus.loaded;
    } on QuizServiceException catch (e) {
      _errorMessage = e.message;
      _status = QuizFetchStatus.error;
    } catch (_) {
      _errorMessage = 'An unexpected error occurred.';
      _status = QuizFetchStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = QuizFetchStatus.idle;
    _questions = [];
    _errorMessage = null;
    notifyListeners();
  }
}
