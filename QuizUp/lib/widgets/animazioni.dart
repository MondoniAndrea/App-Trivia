import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:quiz_up/pages/widget_tree.dart';

import 'dart:math';

class ConfettiEffect extends StatefulWidget {
  final ConfettiController confettiController;

  const ConfettiEffect({Key? key, required this.confettiController}) : super(key: key);

  @override
  _ConfettiEffectState createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.confettiController.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = widget.confettiController.state == ConfettiControllerState.playing;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0, // Posiziona il ConfettiWidget in alto
          child: ConfettiWidget(
            confettiController: widget.confettiController,
            blastDirection: pi / 2, // 90°: Spara verso il basso
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: true,
            colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
            gravity: 0.3, // Simula una discesa lenta
            emissionFrequency: 0.05, // Flusso costante di coriandoli
            numberOfParticles: 100, // Aumenta il numero di coriandoli
          ),
        ),
        if (_isPlaying)  // Ora lo stato cambia quando confettiController.play() viene chiamato
          Align(
            alignment: Alignment.center,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenHeight = constraints.maxHeight;
                return Transform.translate(
                  offset: Offset(0, -screenHeight * 0.1), // Sposta l'icona in alto del 10% dello schermo
                  child: Icon(
                    Icons.emoji_events,
                    size: 250,
                    color: Colors.amber,
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}

void showConfetti(BuildContext context, ConfettiController confettiController) {
  confettiController.play();
  OverlayState? overlayState = Overlay.of(context);
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).size.height * 0.3, // Regola la posizione
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // Pulsante più grande
          height: 80, //  Aumenta l'altezza del pulsante
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // Rimuove il padding predefinito
              elevation: 0, // Rimuove l'elevazione
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Arrotonda gli angoli
              ),
            ),
            onPressed: () {
              overlayEntry.remove(); // Rimuove il pulsante quando premuto
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WidgetTree()),
                    (route) => false, // Rimuove tutte le pagine precedenti
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple], // I colori del gradiente
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(35), // Arrotonda gli angoli del gradiente
              ),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Back to Home",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.065,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Colore del testo
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlayState.insert(overlayEntry);
}

class SadEffect extends StatefulWidget {
  final ConfettiController confettiController;

  const SadEffect({Key? key, required this.confettiController}) : super(key: key);

  @override
  _SadEffectState createState() => _SadEffectState();
}

class _SadEffectState extends State<SadEffect> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.confettiController.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = widget.confettiController.state == ConfettiControllerState.playing;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isPlaying)  // Mostra solo un'emoji triste quando viene attivato
          Align(
            alignment: Alignment.center,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenHeight = constraints.maxHeight;
                return Transform.translate(
                  offset: Offset(0, -screenHeight * 0.1), // Sposta l'icona in alto del 10% dello schermo
                child: Stack(
                children: [
                // Icona nera leggermente più grande (bordo)
                Icon(
                Icons.circle,
                size: 250, // Dimensione leggermente maggiore per il bordo
                color: Colors.amber,
                ),
                // Icona ambra sopra, più piccola
                Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 250,
                color: Colors.black,
                ),
                ],
                ),
                );
              },
            ),
          )
      ],
    );
  }
}

void showSadEffect(BuildContext context, ConfettiController confettiController) {
  confettiController.play();

    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.3, // Regola la posizione
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Pulsante più grande
            height: 80, //  Aumenta l'altezza del pulsante
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero, // Rimuove il padding predefinito
                elevation: 0, // Rimuove l'elevazione
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // Arrotonda gli angoli
                ),
              ),
              onPressed: () {
                overlayEntry.remove(); // Rimuove il pulsante quando premuto
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WidgetTree()),
                      (route) => false, // Rimuove tutte le pagine precedenti
                );
              },
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple], // I colori del gradiente
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(35), // Arrotonda gli angoli del gradiente
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Back to Home",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.065,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Colore del testo
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  overlayState.insert(overlayEntry);

}