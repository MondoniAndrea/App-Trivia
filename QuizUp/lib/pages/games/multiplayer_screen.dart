import 'package:flutter/material.dart';
import 'package:quiz_up/pages/games/countdown_screen.dart';
import 'package:quiz_up/pages/games/levels_screen.dart';
import 'package:quiz_up/pages/games/multiplayer/multiplayer.dart';
import 'package:quiz_up/pages/games/multiplayer/invite_friends_screen.dart';
import 'package:quiz_up/widgets/level_card.dart';

class MultiPlayerScreen extends StatelessWidget {
  const MultiPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    double getFontSize(double ratio) => width * ratio; //per rendere la scritta adattiva
    return Scaffold(
      backgroundColor: Colors.white, //colore
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Challenge Time!",
          style: TextStyle(
            color: Colors.purple,
            fontSize: getFontSize(0.06),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
            size.width * 0.08, // Padding adattivo rispetto alla larghezza
            vertical:
            size.height * 0.05, // Padding adattivo rispetto all'altezza
          ), //distanza bordi
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LevelCard(
                title: 'Generate Private Room',
                color1: Colors.lightBlue,
                color2: Colors.green.shade700,
                icon: Icons.lock_rounded,
                nextPage: InviteFriendsScreen(),
                fontSize: getFontSize(0.07),
              ),
              SizedBox(height: size.height * 0.05),
              LevelCard(
                title: 'MultiPlayer Mode',
                color1: Colors.pink,
                color2: Colors.purple.shade700,
                icon: Icons.group_rounded,
                nextPage: Multiplayer(),
                fontSize: getFontSize(0.07),
              ),
              SizedBox(height: size.height * 0.015)
            ],
          ),
        ),
      ),
    );
  }
}
