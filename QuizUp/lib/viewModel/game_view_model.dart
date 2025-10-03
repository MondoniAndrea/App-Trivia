import '../data/model/domanda.dart';
import '../data/service/api_service.dart';

class GameViewModel {
  late APIService apiService = APIService();
  final int amountSfidaInfinita = 15;
  final int amountLevel = 6;
  final int amountPartPrivata = 45;

  GameViewModel();

  Future<List<Domanda>> fetchGame() async {

    try {
      final domande = await apiService.fetchDomande(amount: amountSfidaInfinita);
      return domande;
    } catch (e) {
      print('Errore durante il recupero delle domande: $e');
      return [];
    }
  }

  Future<List<Domanda>> fetchSecondPartGameByLevel(int level) async {
    try {
      List<Domanda> domande = [];
      if (level % 10 >= 4 && level % 10 <= 5) {
        domande = await apiService.fetchDomande(
            amount: (amountLevel - amountLevel ~/ 2), difficulty: 'medium');
      }else if (level % 10 >= 8 && level % 10 <= 9) {
        domande = await apiService.fetchDomande(
            amount: (amountLevel - amountLevel ~/ 2), difficulty: 'hard');
      }

      return domande;
    } catch (e) {
      print('Errore durante il recupero delle domande: $e');
      return [];
    }
  }

  Future<List<Domanda>> fetchGameByLevel(int level) async {

    try {
      List<Domanda> domande = [];
      if (level % 10 <= 3) {
        domande = await apiService.fetchDomande(amount: amountLevel, difficulty: 'easy');
      } else if (level % 10 >= 4 && level % 10 <= 5) {
        domande = await apiService.fetchDomande(amount: (amountLevel ~/ 2), difficulty: 'easy');
      } else if (level % 10 >= 6 && level % 10 <= 7) {
        domande = await apiService.fetchDomande(amount: amountLevel, difficulty: 'medium');
      } else if (level % 10 >= 8 && level % 10 <= 9) {
        domande = await apiService.fetchDomande(amount: (amountLevel ~/ 2), difficulty: 'medium');
      } else if (level % 10 == 0) {
        domande = await apiService.fetchDomande(amount: amountLevel, difficulty: 'hard');
      }
  print(domande[1].difficolta);
      return domande;
    } catch (e) {
      print('Errore durante il recupero delle domande: $e');
      return [];
    }
    }

    Future<List<Domanda>> fetchGameForMultiplayer() async{
      try {
        final domande = await apiService.fetchDomande(amount: amountPartPrivata);
        return domande;
      } catch (e) {
        print('Errore durante il recupero delle domande: $e');
        return [];
      }
    }
  }
