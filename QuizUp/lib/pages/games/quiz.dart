import 'package:flutter/material.dart';
import 'package:quiz_up/pages/games/quiz_result.dart';
import 'package:quiz_up/widgets/quiz_template.dart';
import 'dart:async';

import '../../data/model/domanda.dart';
import '../../viewModel/game_view_model.dart';

class QuizLevel extends StatefulWidget {
  final List<Domanda> questions;
  final String sourcePage;
  final int level;
  final GameViewModel gameViewModel = GameViewModel();

  QuizLevel({super.key, required this.questions, required this.sourcePage, required this.level});

  @override
  _QuizLevelState createState() => _QuizLevelState();
}

class _QuizLevelState extends State<QuizLevel> {
  int _currentQuestionIndex = 0;
  double _progress = 1.0;
  late Timer _timer;
  int _totalTime = 120; // 20 secondi per domanda
  bool _answerSelected = false;
  String? _selectedAnswer;
  late List<String> _orderedAnswers;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  final int _maxWrongAnswers = 6;

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResults(
          correctAnswers: _correctAnswers,
          wrongAnswers: _wrongAnswers,
          totalTime: 0,  // Tempo totale impiegato
          fromMapLevel: widget.sourcePage,
          level: widget.level,
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
      if (_wrongAnswers > _maxWrongAnswers) {
        _timer.cancel();
        _showResults();
        return;
      }
    }

    if(widget.questions.length ==3 && _currentQuestionIndex == 2){
      final domande = await widget.gameViewModel.fetchSecondPartGameByLevel(widget.level);
      widget.questions.addAll(domande);
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
    );
  }
}
