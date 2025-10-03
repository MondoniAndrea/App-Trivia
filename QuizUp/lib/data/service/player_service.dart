import 'package:shared_preferences/shared_preferences.dart';
import '../model/player.dart';
import '../repository/player_repository.dart';


class PlayerService {
  final PlayerRepository repository = PlayerRepository();
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> _init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  Future<void> initializePlayer() async {
    await _init();
    String? playerId = _prefs!.getString('player_id');
    if (playerId == null) {
      // Se l'ID non esiste, crea un nuovo giocatore e salva nella cache
      Player newPlayer = await repository.createPlayer();
      await _prefs!.setString('player_id', newPlayer.id);
      await _prefs!.setInt('player_level', newPlayer.level);
      await _prefs!.setInt('player_score', newPlayer.bestScore);
      await _prefs!.setInt('player_hintsTime', newPlayer.hintsTime);
      await _prefs!.setInt('player_hints50', newPlayer.hints50);
    } //TODO: mettere il valore nella cache se è loggato
  }


  Future<void> addEmailToPlayer(String id, String email) => repository.addEmailToPlayer(id, email);

  Future<void> updateLevel(String id, int level) async {
    await _init();
    await _prefs!.setInt('player_level', level);
    repository.updateLevel(id, level);
  }

  Future<void> updateBestScore(String id, int score) async {
    await _init();
    await _prefs!.setInt('player_score', score);
    repository.updateBestScore(id, score);
  }
  Future<void> updateHintsTime(String id, int hintsTime) async {
    await _init();
    await _prefs!.setInt('player_hintsTime', hintsTime);
    repository.updateHintsTime(id,hintsTime);
  }
  Future<void> updateHints50(String id, int hints50) async {
    await _init();
    await _prefs!.setInt('player_hints50', hints50);
    repository.updateHints50(id, hints50);
  }

  Future<void> updateMultiplayerWins(String id, int wins) => repository.updateMultiplayerWins(id, wins);

  Future<int?> getLevel(String id) async {
    await _init();
    final level = _prefs!.getInt('player_level');
    return level;
  }

  Future<int?> getHintsTime(String id) async {
    await _init();
    final hints = _prefs!.getInt('player_hintsTime');
    return hints;
  }
  Future<int?> getHints50(String id) async {
    await _init();
    final hints = _prefs!.getInt('player_hints50');
    return hints;
  }

  Future<int?> getBestScore(String id) async {
    await _init();
    final score = _prefs!.getInt('player_score');
    return score;
  }



  Future<Player?> getPlayer(String id) => repository.getPlayer(id);

  Future<Player?> getPlayerByEmail(String email) => repository.getPlayerByEmail(email);

  Future<List<Player>> getLeaderboardByScore() => repository.getLeaderboardByScore();

  Future<List<Player>> getLeaderboardByLevel() => repository.getLeaderboardByLevel();

  Future<void> createFriendship(String id1, String id2) => repository.createFriendship(id1, id2);

  Future<List<Player>> getFriendsLeaderboardByScore(String id) => repository.getFriendsLeaderboardByScore(id);

  Future<List<Player>>getFriendsLeaderboardByLevel(String id) => repository.getFriendsLeaderboardByLevel(id);

}
