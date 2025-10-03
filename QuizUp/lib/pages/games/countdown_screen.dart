import 'package:flutter/material.dart';
import 'dart:async';
import '../../viewModel/game_view_model.dart';
import 'package:quiz_up/pages/games/quizSfidaInf.dart';

class CountDown extends StatefulWidget {
  final int? level;
  final String sourcePage;
  const CountDown({super.key, this.level, required this.sourcePage});

  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> with SingleTickerProviderStateMixin {
  int _countdownSfid = 3;
  late AnimationController _controller;
  Timer? _timer;
  final GameViewModel _gameViewModel = GameViewModel();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1))..repeat();
    _startCountdownSfid();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startCountdownSfid() async {
    final questions = await _gameViewModel.fetchGame();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdownSfid > 0) {
        setState(() {
          _countdownSfid--;
        });
      } else {
        timer.cancel();
        if (questions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore nel caricamento delle domande.')),
          );
          Navigator.pop(context); // oppure rimani nella stessa pagina
        }
        else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Quiz(questions: questions, sourcePage: widget.sourcePage),
            ),
          );
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double loaderSize = screenWidth * 0.35;
    final double strokeWidth = loaderSize * 0.08;
    final double fontSize = screenWidth * 0.12;

    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: SizedBox(
                width: loaderSize,
                height: loaderSize,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Colors.blue, Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: CircularProgressIndicator(
                    strokeWidth: strokeWidth,
                    value: 1.0,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
            Text(
              '$_countdownSfid',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
