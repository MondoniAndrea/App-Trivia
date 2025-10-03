import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../model/player.dart';

class PlayerRepository {
  final String neo4jUrl = dotenv.env['NEO4J_URI']!;
  final String username = dotenv.env['NEO4J_USERNAME']!;
  final String password = dotenv.env['NEO4J_PASSWORD']!;
  final _uuid = Uuid(); // Istanza per generare ID

  String get _authHeader =>
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  //esegue la query con query api di neo4j
  Future<http.Response> executeQuery(String statement) async {
    final uri = Uri.parse('$neo4jUrl');

    return await http.post(
      uri,
      headers: {
        'Authorization': _authHeader,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
          {'statement': statement}
      ),
    );
  }

  //crea un nuovo giocatore
  Future<Player> createPlayer() async {
    String id = _uuid.v4();
    String query =
    """CREATE (p:Player {id: '$id', level: 1,bestScore: 0,multiplayerWins: 0, hintsTime: 5, hints50: 5})""";
    final response = await executeQuery(query);
    print(response.body);
    return Player(id: id, level: 1, bestScore: 0, multiplayerWins: 0, hintsTime: 5, hints50: 5);
  }

  //se autenticato viene aggiunto la email
  Future<void> addEmailToPlayer(String id, String email) async {
    String query = """MATCH (p:Player {id: '$id'})SET p.email = '$email'
    """;
    await executeQuery(query);
  }

  //metodo per aggiornare il livello raggiunto
  Future<void> updateLevel(String id, int newLevel) async {
    String query = """MATCH (p:Player {id: '$id'})SET p.level = $newLevel""";
    await executeQuery(query);
  }
  Future<void> updateHintsTime(String id, int hintsTime) async {
    String query = """MATCH (p:Player {id: '$id'})SET p.hintsTime = $hintsTime""";
    await executeQuery(query);
  }
  Future<void> updateHints50(String id, int hints50) async {
    String query = """MATCH (p:Player {id: '$id'})SET p.hints50 = $hints50""";
    await executeQuery(query);
  }

  //metodo per aggiornare il record in Sfida Infinita
  Future<void> updateBestScore(String id, int newScore) async {
    String query = """MATCH (p:Player {id: '$id'})SET p.bestScore = $newScore""";
    await executeQuery(query);
  }

  //metodo per aggiornare il numero di vittorie di partite multi-player
  Future<void> updateMultiplayerWins(String id, int wins) async {
    String query = """MATCH (p:Player {id: '$id'})SET p.multiplayerWins = $wins""";
    await executeQuery(query);
  }

  //metodo per ottenere il livello di un giocatore
  Future<int?> getLevel(String id) async {
    String query = """MATCH (p:Player {id: '$id'})RETURN p.level AS level""";
    final response = await executeQuery(query);
    if (response.statusCode ~/ 100 == 2) {
      final data = jsonDecode(response.body);
      if (data["data"]["values"].isNotEmpty) {
        return data["data"]["values"][0][0];
      }
    }
    return 0;
  }
  Future<int?> getHintsTime(String id) async {
    String query = """MATCH (p:Player {id: '$id'})RETURN p.hintsTIme as hintsTime""";
    final response = await executeQuery(query);
    if (response.statusCode ~/ 100 == 2) {
      final data = jsonDecode(response.body);
      if (data["data"]["values"].isNotEmpty) {
        return data["data"]["values"][0][0];
      }
    }
    return 0;
  }
  Future<int?> getHints50(String id) async {
    String query = """MATCH (p:Player {id: '$id'})RETURN p.hints50 AS hints50""";
    final response = await executeQuery(query);
    if (response.statusCode ~/ 100 == 2) {
      final data = jsonDecode(response.body);
      if (data["data"]["values"].isNotEmpty) {
        return data["data"]["values"][0][0];
      }
    }
    return 0;
  }
  //metodo per ottenere i dati del giocatore
  Future<Player?> getPlayer(String id) async {
    String query = """MATCH (p:Player {id: '$id'})RETURN p""";
    final response = await executeQuery(query);
    if (response.statusCode ~/ 100 == 2) {
      final data = jsonDecode(response.body);
      if (data["data"]["values"].isNotEmpty) {
        return Player.fromJson(data["data"]["values"][0][0]["properties"]);
      }
    }
    return null;
  }

  //metodo per ottenere la classifica in base al livello
  Future<List<Player>> getLeaderboardByLevel() async {
    String query = """MATCH (p:Player)RETURN p ORDER BY p.level DESC LIMIT 100""";
    final response = await executeQuery(query);
    if (response.statusCode ~/ 100 == 2) {
      final data = jsonDecode(response.body);
      if (data["data"]["values"].isNotEmpty) {
        return data["data"]["values"][0]
            .map<Player>((item) => Player.fromJson(item["properties"]))
            .toList();
      }
    }
    return [];
  }

  //metodo per ottenere la classifica in base al record di Sfida Infinita
  Future<List<Player>> getLeaderboardByScore() async {
    String query = """MATCH (p:Player)RETURN p ORDER BY p.bestScore DESC LIMIT 100""";
    final response = await executeQuery(query);
    if (response.statusCode ~/ 100 == 2) {
      final data = jsonDecode(response.body);
      if (data["data"]["values"].isNotEmpty) {
        return data["data"]["values"][0]
            .map<Player>((item) => Player.fromJson(item["properties"]))
            .toList();
      }
    }
    return [];
  }

  //metodo per creare le amicizie tra due utenti
  Future<void> createFriendship(String id1, String id2) async {
    String query = """MATCH (p1:Player {id: '$id1'}), (p2:Player {id: '$id2'})CREATE (p1)-[:FRIENDS_WITH]-(p2)""";
    await executeQuery(query);
  }

  // metodo per ottenere la classifica tra un utente e i suoi amici in base al livello
  Future<List<Player>> getFriendsLeaderboardByLevel(String id) async {
    String query = """MATCH (p:Player {id: '$id'})-[:FRIENDS_WITH]-(friend:Player) RETURN friend ORDER BY friend.level DESC""";
    final response = await executeQuery(query);
    if (response.statusCode ~/ 100 == 2) {
      final data = jsonDecode(response.body);
      if (data["data"]["values"].isNotEmpty) {
        return data["data"]["values"][0]
            .map<Player>((item) => Player.fromJson(item["properties"]))
            .toList();
      }
    }
    return [];
  }

  // metodo per ottenere la classifica tra un utente e i suoi amici in base al punteggio migliore
  Future<List<Player>> getFriendsLeaderboardByScore(String id) async {
    String query = """MATCH (p:Player {id: '$id'})-[:FRIENDS_WITH]-(friend:Player) RETURN friend ORDER BY friend.bestScore DESC""";
    final response = await executeQuery(query);
    if (response.statusCode ~/ 100 == 2) {
      final data = jsonDecode(response.body);
      if (data["data"]["values"].isNotEmpty) {
        return data["data"]["values"][0]
            .map<Player>((item) => Player.fromJson(item["properties"]))
            .toList();
      }
    }
    return [];
  }

  Future<Player?> getPlayerByEmail(String email) async{
    String query = """MATCH (p:Player {email: '$email'})RETURN p""";
    final response = await executeQuery(query);
    if (response.statusCode ~/ 100 == 2) {
      final data = jsonDecode(response.body);
      if (data["data"]["values"].isNotEmpty) {
        return Player.fromJson(data["data"]["values"][0][0]["properties"]);
      }
    }
    return null;
  }
}

