import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz_up/data/controller/multiplayer_controller.dart';
import 'package:quiz_up/pages/games/multiplayer/quiz_result_partita_privata.dart';

import '../../../data/model/domanda.dart';
import '../../../widgets/quiz_template.dart';
import '../quiz_result.dart';

class QuizPartitaPrivata extends StatefulWidget {
  final List<Domanda> questions;
  final String id;
  final String code;

  QuizPartitaPrivata({super.key, required this.questions, required this.id, required this.code});

  @override
  _QuizPartitaPrivataState createState() => _QuizPartitaPrivataState();
}

class _QuizPartitaPrivataState extends State<QuizPartitaPrivata> {
  int _currentQuestionIndex = 0;
  double _progress = 1.0;
  late Timer _timer;
  int _totalTime = 15;
  bool _answerSelected = false;
  String? _selectedAnswer;
  late List<String> _orderedAnswers;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  final MultiplayerController _controller = MultiplayerController();

  @override
  void initState() {
    super.initState();
    _startTimer();
    _setOrderedAnswers();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        if (_progress > 0) {
          _progress -= 1 / _totalTime;
        } else {
          _timer.cancel();
          _showResults();
        }
      });
    });
  }

  void _setOrderedAnswers() {
    _orderedAnswers = [widget.questions[_currentQuestionIndex].rispostaCorretta, ...widget.questions[_currentQuestionIndex].risposteErrate];
    _orderedAnswers.shuffle();
  }

  void _showResults() {
    _controller.updateScorePlayer(widget.code, widget.id, _correctAnswers);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsPartitaPrivata(
          correctAnswers: _correctAnswers,
          id: widget.id,
          code: widget.code,
        ),
      ),
    );
  }

  Future<void> _selectAnswer(String answer) async {
    if (_answerSelected) return;
    setState(() {
      _selectedAnswer = answer;
      _answerSelected = true;
    });

    bool isCorrect = widget.questions[_currentQuestionIndex].rispostaCorretta == answer;
    if (isCorrect) {
      _correctAnswers++;
    } else {
      _wrongAnswers++;
    }

    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        widget.questions;
        if (_currentQuestionIndex < widget.questions.length - 1) {
          _currentQuestionIndex++;
          _answerSelected = false;
          _selectedAnswer = null;
          _setOrderedAnswers();
        }

        else {
          _timer.cancel();
          _showResults();
        }
      });
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
      sourcePage: 'partitaPrivata',
    );
  }
}
