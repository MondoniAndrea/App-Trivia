import 'package:flutter/material.dart';
import 'package:quiz_up/pages/games/countdown_screen.dart';
import 'package:quiz_up/pages/games/levels_screen.dart';
import 'package:quiz_up/pages/games/multiplayer/multiplayer.dart';
import 'package:quiz_up/pages/games/multiplayer/invite_friends_screen.dart';
import 'package:quiz_up/pages/games/multiplayer_screen.dart';
import 'package:quiz_up/widgets/level_card.dart';

class PlaymodePage extends StatelessWidget {
  const PlaymodePage({super.key});

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
          "Let's Play",
          style: TextStyle(
            color: Colors.pink,
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
                title: 'Levels',
                color1: Colors.pinkAccent,
                color2: Colors.orange,
                icon: Icons.bolt,
                nextPage: LevelsScreen(),
                fontSize: getFontSize(0.07),
              ),
              SizedBox(height: size.height * 0.015),
              LevelCard(
                title: 'Endless Mode',
                color1: Colors.blue,
                color2: Colors.purple,
                icon: Icons.play_circle_fill,
                nextPage: CountDown(sourcePage: 'countdown_sfida'),
                fontSize: getFontSize(0.07),
              ),
              SizedBox(height: size.height * 0.015),
              LevelCard(
                title: 'MultiPlayer',
                color1: Colors.purple,
                color2: Colors.deepPurple,
                icon: Icons.sports_esports,
                nextPage: MultiPlayerScreen(),
                fontSize: getFontSize(0.07),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
