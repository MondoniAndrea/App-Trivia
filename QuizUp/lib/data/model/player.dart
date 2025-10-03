import 'dart:convert';

class Player {
  final String id;
  final String? email;
  int level;
  int bestScore;
  int multiplayerWins;
  int hintsTime;
  int hints50;

  Player({
    required this.id,
    this.email,
    required this.level,
    required this.bestScore,
    required this.multiplayerWins,
    required this.hintsTime,
    required this.hints50
  });
  // Metodo per convertire il Player in una mappa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (email != null) 'email': email,
      'level': level,
      'bestScore': bestScore,
      'multiplayerWins': multiplayerWins,
      'hintsTime': hintsTime,
      'hints50': hints50
    };
  }
  // Metodo per creare un Player da una mappa, distinguendo i casi in cui l'utente è autenticato oppure no
  factory Player.fromMap(Map<String, dynamic> map) {
    var player = Player(
        id: map['id'] as String,
        level: map['level'] as int,
        bestScore: map['bestScore'] as int,
        multiplayerWins: map['multiplayerWins'] as int,
        hintsTime: map['hintsTime'] as int,
        hints50: map['hints50'] as int
    );
    if (map.containsKey('email')) {
      player = Player(
          id: player.id,
          email: map['email'] as String?,
          level: player.level,
          bestScore: player.bestScore,
          multiplayerWins: player.multiplayerWins,
          hintsTime: map['hintsTime'] as int,
          hints50: map['hints50'] as int
      );
    }
    return player;
  }
  // Metodo per convertire il Player da JSON
  factory Player.fromJson(String source) {
    final Map<String, dynamic> jsonData = jsonDecode(source);
    return Player.fromMap(jsonData);
  }

  String toJson() => jsonEncode(toMap());
}
