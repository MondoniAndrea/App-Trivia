import 'package:flutter/material.dart';
import 'package:quiz_up/pages/games/quiz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/service/player_service.dart';
import '../../viewModel/game_view_model.dart';

class LevelsScreen extends StatefulWidget {
  final GameViewModel gameViewModel = GameViewModel();
  @override
  _LevelsScreenState createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  final int totalLevels = 100;
  int unlockedLevels = 1;
  final ScrollController _scrollController = ScrollController();
  late PlayerService _playerService;
  late SharedPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    _preferences = await SharedPreferences.getInstance();
    _playerService = PlayerService();
    String? id = _preferences.getString('player_id');
    final level = (await _playerService.getLevel(id!))!;
    setState(() {
      unlockedLevels = level;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUnlockedLevel();
    });
  }

  void _scrollToUnlockedLevel() {
    if (!_scrollController.hasClients || !_scrollController.position.hasContentDimensions) return;

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    double buttonSizeBase = width * 0.25;
    double buttonSizeLarge = width * 0.30;
    double lineHeight = height * 0.06;

    // Calcolo medio del blocco (bottoni + linea) — puoi affinare se vuoi precisione millimetrica
    double itemHeight = buttonSizeBase  + lineHeight;

    int index = totalLevels - unlockedLevels;
    double scrollPosition = index * itemHeight;

    // Centra lo scroll
    double offsetToCenter = scrollPosition - (height / 2);


    _scrollController.animateTo(
      offsetToCenter,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }
  void _showLockedMessage(BuildContext context, Offset position) {//per scrivere il messaggio nei bottoni bloccati
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 60,
        top: position.dy + 30,
        child: Material(
          color: Colors.transparent,
          child: Card(
            color: Colors.grey.withOpacity(0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                "Keep playing to unlock this level",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Funzioni adattive
    double fontSize(double ratio) => width * ratio;
    double buttonSizeBase = width * 0.25;
    double buttonSizeLarge = width * 0.30;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        elevation: 0, // <-- Rimuove l'ombra
        shadowColor: Colors.transparent, // Assicura che non ci sia ombra
      ),

      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Levels list
          Center(
            child: Container(
              width: width * 0.38, // Adattivo: larghezza colonna livelli
              child: ListView.builder(
                controller: _scrollController,
                itemCount: totalLevels,
                reverse: false,
                padding: EdgeInsets.only(top: height * 0.10, bottom: height * 0.18), // Extra padding sopra e sotto
                itemBuilder: (context, index) {
                  int level = totalLevels - index;
                  bool isUnlocked = level <= unlockedLevels;
                  bool isLastUnlocked = level == unlockedLevels; // L'ultimo livello sbloccato

                  double buttonSize = isLastUnlocked ? buttonSizeLarge : buttonSizeBase; // Più grande se è l'ultimo sbloccato

                  return Column(
                    children: [
                      if (index != 0)
                        Container(
                          width: width * 0.015,
                          height: height * 0.06,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      GestureDetector(
                        onTapDown: (details) {
                          if (!isUnlocked) {
                            _showLockedMessage(context, details.globalPosition);
                          }
                        },
                        onTap: isUnlocked ? () async {
                          final questions = await widget.gameViewModel.fetchGameByLevel(level);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizLevel(questions: questions, sourcePage: 'map_level', level: level),
                            ),
                          );

                        }
                        : null,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: buttonSize,
                              height: buttonSize,
                              decoration: BoxDecoration(
                                color: isUnlocked ? Colors.blueAccent : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  "$level",
                                  style: TextStyle(
                                    fontSize: isLastUnlocked
                                        ? fontSize(0.09)
                                        : fontSize(0.075), // Testo più grande per l'ultimo sbloccato
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            if (!isUnlocked)
                              Positioned(
                                bottom: height * -0.006,
                                left: width * 0.015,
                                child: Icon(
                                  Icons.lock,
                                  size: width * 0.08,
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (level == 1) // Padding extra sotto il livello 1
                        SizedBox(height: height * 0.05),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
