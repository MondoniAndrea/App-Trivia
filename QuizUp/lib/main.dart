import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quiz_up/pages/widget_tree.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/service/player_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final playerService = PlayerService();
  await playerService.initializePlayer();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Solo verticale
  ]).then((_) {
    runApp(MyApp(playerService: playerService));
  });
}

class MyApp extends StatelessWidget {
  final PlayerService playerService;
  const MyApp({super.key, required this.playerService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuizUp!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const WidgetTree(),
    );
  }
}
