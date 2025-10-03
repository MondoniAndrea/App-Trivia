import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:quiz_up/widgets/animazioni.dart';
import 'package:quiz_up/data/service/player_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class QuizResults extends StatefulWidget {
  final int correctAnswers;
  final int wrongAnswers; // Per 'levels_mode'
  final int totalTime; // Tempo totale impiegato
  final String fromMapLevel; // Determina se la modalità è 'levels_mode' o 'sfida_mode'
  final int? level;

  const QuizResults({
    super.key,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalTime,
    required this.fromMapLevel,
    this.level,

  });

  @override
  _QuizResultsState createState() => _QuizResultsState();
}

class _QuizResultsState extends State<QuizResults> {
  late ConfettiController _confettiController; // Animazione vittoria
  late ConfettiController _sadController; // Animazione triste
  late PlayerService _playerService;
  late SharedPreferences _preferences;
  int bestScore = 0;
  int level = 1;

  @override
  void initState() {
    
    super.initState();

    _playerService = PlayerService();
    _confettiController = ConfettiController();
    _sadController = ConfettiController();

    _initAsync();
  }

  Future<void> _initAsync() async {
    _preferences = await SharedPreferences.getInstance();

    String? id = _preferences.getString('player_id');
    final score = (await _playerService.getBestScore(id!))!;
    final currentLevel = await _playerService.getLevel(id);
    setState(() {
      bestScore = score;
      level = currentLevel!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.fromMapLevel == 'countdown_sfida' && widget.correctAnswers > bestScore) {
          showConfetti(context, _confettiController);
          _playerService.updateBestScore(id, widget.correctAnswers);
          bestScore = widget.correctAnswers;
        }
        else if (widget.fromMapLevel == 'map_level' && widget.correctAnswers >= 4) {
          showConfetti(context, _confettiController);
          if(widget.level == level) {
            level = level + 1;
            _playerService.updateLevel(id, level);
          }
        } else{
          showSadEffect(context, _sadController);
        }
      }
      );
    }
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _sadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
        canPop: false, //disabilita back
        child:
      Scaffold(
      body: Stack(
        children: [
          ConfettiEffect(confettiController: _confettiController), // Mostra i coriandoli e coppa sopra lo sfondo
          SadEffect(confettiController: _sadController), // Effetto triste
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.fromMapLevel == 'map_level') ...[
                    Text(
                      'Correct Answer: ${widget.correctAnswers}',
                      style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Wrong Answer: ${widget.wrongAnswers}',
                      style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      widget.correctAnswers>=4
                          ? 'Congratulations! You passed the level!'
                          : "Sorry, you failed the level!",
                      style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  Text(
                    '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenWidth * 0.1, fontWeight: FontWeight.bold),
                  ),
                  if (widget.fromMapLevel == 'countdown_sfida') ...[
                    Text(
                      'Total time: ${_formatTime(widget.totalTime)}',
                      style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Correct Answer: ${widget.correctAnswers}',
                      style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    if (widget.correctAnswers > bestScore) ...[
                      Text(
                        'Your new record in Endless Mode:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.correctAnswers}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: screenWidth * 0.1, fontWeight: FontWeight.bold),
                      ),
                    ],
                    Text(
                      '',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: screenWidth * 0.1, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  // Funzione per formattare il tempo in MM:SS
  String _formatTime(int timeInSeconds) {
    int minutes = timeInSeconds ~/ 60;
    int seconds = timeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
