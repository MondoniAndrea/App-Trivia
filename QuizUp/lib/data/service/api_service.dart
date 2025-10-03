import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/domanda.dart';

// Classe per gestire le chiamate API e recuperare le domande.
class APIService {
  static const String _baseUrl = 'https://opentdb.com/api.php';

  // Metodo per ottenere le domande dal server.
  // - amount: numero di domande richieste.
  // - difficulty: difficoltà della domanda (opzionale, se null verranno restituite domande di difficoltà miste).
  // - type: tipo di domanda (default: multiple).
  Future<List<Domanda>> fetchDomande({
    required int amount,
    String? difficulty,
    String? type,
  }) async {
    try {
      // Costruzione dinamica dell'URL con i parametri passati.
      final queryParams = {
        'amount': amount.toString(),
      };

      // Aggiunge la difficoltà solo se non è null.
      if (difficulty != null) {
        queryParams['difficulty'] = difficulty;
      }

      // Aggiunge il tipo solo se non è null.
      if (type != null) {
        queryParams['type'] = type;
      }

      final Uri url = Uri.parse("$_baseUrl?${_encodeQueryParameters(queryParams)}");
      final response = await http.get(url);

      // Controlla se la richiesta è andata a buon fine.
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('results') && data['results'].isNotEmpty) {
          return (data['results'] as List<dynamic>)
              .map((json) => Domanda.fromJson(json))
              .toList();
        } else {
          throw Exception('Nessuna domanda trovata');
        }
      } else {
        throw Exception('Errore HTTP: codice ${response.statusCode}');
      }
    } catch (e) {
      print('Errore nel recupero delle domande: $e');
      throw Exception('Errore nel recupero delle domande');
    }
  }

  // Metodo per codificare i parametri della query, evitando valori null.
  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
  }
}

// Esempio di utilizzo:
// APIService apiService = APIService();
// List<Domanda> domande = await apiService.fetchDomande(amount: 5, difficulty: 'hard', type: 'boolean');


// main.dart
// import 'api_service.dart';  // Importa la classe APIService dal file api_service.dart
// import 'domanda.dart';  // Importa la classe Domanda dal file domanda.dart

