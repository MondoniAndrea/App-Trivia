import 'package:flutter/material.dart';

class Multiplayer extends StatelessWidget {
  const Multiplayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("multi mode"),
        automaticallyImplyLeading: false, //rimuove freccia back
      ),
      body: Center(child: Text("Benvenuto nella modalità Level!")),
    );
  }
}
