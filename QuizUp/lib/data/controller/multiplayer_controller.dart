import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_up/data/model/domanda.dart';
import 'package:quiz_up/viewModel/game_view_model.dart';
import 'package:uuid/uuid.dart';

class MultiplayerController {
  final FirebaseFirestore _firestore;
  late GameViewModel gameViewModel = GameViewModel();

  MultiplayerController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createRoom(String id) async {
    String code = _generateRoomCode();
    String docId = Uuid().v4();

    await _firestore.collection('rooms').doc(docId).set({
      'createdAt': FieldValue.serverTimestamp(),
      'code': code,
      'players': {'player1': {'id': id, 'score': -1},
                  'player2': {'id': null, 'score': -1}
      },
      'status': 'waiting',
      'questions': [],
    });
    return code;
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
    Random rand = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
  }

  Future<List<Domanda>?> joinRoom(String code, String id) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('rooms')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null; // room non trovata
      }

      DocumentSnapshot roomDoc = snapshot.docs.first;
      Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;

      // Controlla che lo stato sia 'waiting' e che l'id sia diverso da player1
      final players = roomData['players'] as Map<String, dynamic>;
      if (roomData['status'] == 'waiting' &&
          players['player1']['id'] != id &&
          players['player2']['id'] == null) {
        final questions = await gameViewModel.fetchGameForMultiplayer();
        if (questions.isNotEmpty) {
          await roomDoc.reference.update({
            'players.player2': {'id': id, 'score': 0},
            'status': 'ready',
            'questions' : questions.map((q) => q.toMap()).toList()
          });
          return questions;
        }
        return null;
      }else {
        return null; // room non in attesa o stesso utente
      }
    } catch (e) {
      print('Errore nel joinRoom: $e');
      return null;
    }
  }
  //fa uno stream dei contenuti del documento per rimanere in ascolto
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToRoom(String code) {
    return _firestore
        .collection('rooms')
        .where('code', isEqualTo: code)
        .limit(1)
        .snapshots()
        .asyncExpand((snapshot) async* {
      if (snapshot.docs.isNotEmpty) {
        yield* snapshot.docs.first.reference.snapshots();
      }
    });
  }

  //Aggiorno i punteggi di un giocatore
  Future<void> updateScorePlayer(String code, String playerId, int score) async {
    try {
      String playerKey= '';
      QuerySnapshot snapshot = await _firestore
          .collection('rooms')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot roomDoc = snapshot.docs.first;

        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        final players = roomData['players'] as Map<String, dynamic>;
        if(players['player1']['id'] == playerId) {
          playerKey = 'player1';
        } else {
          playerKey='player2';
        }

        await roomDoc.reference.update({
          'players.$playerKey.score': score,
          'status': 'done'
        });
      }

    } catch (e) {
      print('Errore nel joinRoom: $e');
    }
  }

  //cancella il documento, se non serve
  Future<void> cancelRoom(String code) async {
    QuerySnapshot snapshot = await _firestore
        .collection('rooms')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    if(snapshot.docs.isNotEmpty) {
      final roomDoc = snapshot.docs.first;
      Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
      if (roomData['status'] == 'waiting'){
        await roomDoc.reference.delete();
      }
    }
  }


}
