import 'package:flutter/material.dart';
import 'package:quiz_up/pages/games/quiz_result.dart';
import 'dart:async';

import '../../data/model/domanda.dart';
import '../../widgets/quiz_template.dart';

class Quiz extends StatefulWidget {
  final List<Domanda> questions;
  final String sourcePage;

  const Quiz({super.key, required this.questions, required this.sourcePage});

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int _currentQuestionIndex = 0;
  double _progress = 1.0;
  late Timer _timer;
  int _timeLeft = 20; // 20 secondi per ogni domanda
  int _totalTimeSpent = 0; // Tempo totale impiegato
  bool _answerSelected = false;
  String? _selectedAnswer;
  late List<String> _orderedAnswers;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  @override
  void initState() {
    super.initState();
    _setOrderedAnswers();
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 20; // Reset timer
    _progress = 1.0; // Reset progress bar

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          _totalTimeSpent++;
          _progress = _timeLeft / 20; // Aggiorna la barra di progresso
        } else {
          _timer.cancel();
          _moveToNextQuestion(false);
        }
      });
    });
  }
  void _setOrderedAnswers() {
    _orderedAnswers = [widget.questions[_currentQuestionIndex].rispostaCorretta, ...widget.questions[_currentQuestionIndex].risposteErrate];
    _orderedAnswers.shuffle();
  }

  void _showResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResults(
          correctAnswers: _correctAnswers,
          wrongAnswers: _wrongAnswers,
          totalTime: _totalTimeSpent,  // Tempo totale impiegato
          fromMapLevel: widget.sourcePage,
        ),
      ),
    );
  }

  void _selectAnswer(String answer) {
    if (_answerSelected) return;
    _timer.cancel();  // Ferma il timer una volta selezionata una risposta
    _answerSelected = true;
    _selectedAnswer = answer;

    bool isCorrect = widget.questions[_currentQuestionIndex].rispostaCorretta == answer;
    if (isCorrect) {
      _correctAnswers++;
    } else {
      _wrongAnswers++;
    }

    setState(() {}); // Aggiorna immediatamente il bordo del pulsante

    Future.delayed(Duration(seconds: 1), () {
      _moveToNextQuestion(isCorrect);
    });
  }

  void _moveToNextQuestion(bool answeredCorrectly) {
    if (!answeredCorrectly) {
      Future.delayed(Duration(seconds: 1), () {
        if (!mounted) return;
        _showResults();
      });
      return;
    }

    // Passa alla prossima domanda
    setState(() {
      _answerSelected = false;
      _selectedAnswer = null;

      if (_currentQuestionIndex < widget.questions.length - 1) {
        _currentQuestionIndex++;
        _setOrderedAnswers();
        _startTimer();
      } else {
        _showResults();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return QuizTemplate(
      currentQuestion: widget.questions[_currentQuestionIndex],
      orderedAnswers: _orderedAnswers,
      progress: _progress,
      answerSelected: _answerSelected,
      selectedAnswer: _selectedAnswer,
      selectAnswer: _selectAnswer,
    );
  }
}
