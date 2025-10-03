import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:quiz_up/data/controller/multiplayer_controller.dart';
import 'package:quiz_up/widgets/animazioni.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResultsPartitaPrivata extends StatefulWidget {
  final int correctAnswers;
  final String id;
  final String code;

  const QuizResultsPartitaPrivata({
    super.key,
    required this.correctAnswers, required this.id, required this.code,
  });

  @override
  _QuizResultsPartitaPrivataState createState() => _QuizResultsPartitaPrivataState();
}

class _QuizResultsPartitaPrivataState extends State<QuizResultsPartitaPrivata> {
  late ConfettiController _confettiController;
  late ConfettiController _sadController;
  late MultiplayerController _controller;

  bool _effectPlayed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController();
    _sadController = ConfettiController();
    _controller = MultiplayerController();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _sadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _controller.listenToRoom(widget.code),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final roomData = snapshot.data!.data();

            if (roomData == null) {
              if (_effectPlayed) {
                // Mostra solo l’ultima schermata con animazione già fatta
                return const Center(child: Text('Match result finalized.'));
              } else {
                // Altrimenti, mostra solo un loader
                return const Center(child: CircularProgressIndicator());
              }
            }

            final status = roomData['status'];
            if (status != 'done') {
              return const Center(child: CircularProgressIndicator());
            }

            final players = roomData['players'] as Map<String, dynamic>;
            final player1 = players['player1'];
            final player2 = players['player2'];

            final isPlayer1 = player1['id'] == widget.id;
            final myScore = isPlayer1 ? player1['score'] : player2['score'];
            final opponentScore = isPlayer1 ? player2['score'] : player1['score'];
            final youWin = myScore >= opponentScore;

            if (!_effectPlayed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (youWin) {
                  showConfetti(context, _confettiController);
                } else {
                  showSadEffect(context, _sadController);
                }
              });
              _effectPlayed = true;
            }

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            return Stack(
              children: [
                ConfettiEffect(confettiController: _confettiController),
                SadEffect(confettiController: _sadController),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Correct Answer: ${widget.correctAnswers}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          youWin
                              ? 'Congratulations! You win the game!'
                              : "Sorry, you lost the game!",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.1),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
