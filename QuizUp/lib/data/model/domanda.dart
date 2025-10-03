import 'package:html/parser.dart' as html_parser;

// Modello dati per una domanda.
// Contiene informazioni sulla categoria, il testo della domanda, la risposta corretta, le risposte errate, il tipo e la difficoltà.
class Domanda {
  final String categoria;
  final String domanda;
  final String rispostaCorretta;
  final List<String> risposteErrate;
  final String tipo;
  final String difficolta;

  Domanda({
    required this.categoria,
    required this.domanda,
    required this.rispostaCorretta,
    required this.risposteErrate,
    required this.tipo,
    required this.difficolta,
  });

  // Metodo factory per creare un oggetto Domanda a partire da un JSON ricevuto dall'API.
  factory Domanda.fromJson(Map<String, dynamic> json) {
    return Domanda(
      categoria: _decodeHtmlString(json['category']),
      domanda: _decodeHtmlString(json['question']),
      rispostaCorretta: _decodeHtmlString(json['correct_answer']),
      risposteErrate: (json['incorrect_answers'] as List<dynamic>).map((risposta) => _decodeHtmlString(risposta as String)).toList(),
      tipo: json['type'],
      difficolta: json['difficulty'],
    );
  }
  //Metodo per convertire l'istanza in una mappa necessario per quando aggiungo le domande su firestore
  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'domanda': domanda,
      'rispostaCorretta': rispostaCorretta,
      'risposteErrate': risposteErrate,
      'tipo': tipo,
      'difficolta': difficolta,
    };
  }
 //mappa il Json, che tipo Map<String, dynamic>, nell'instanza di Domanda
  factory Domanda.fromMap(Map<String, dynamic> map) {
    var domanda = Domanda(
      categoria: map['categoria'] as String,
      domanda: map['domanda'] as String,
      rispostaCorretta: map['rispostaCorretta'] as String,
      risposteErrate: List<String>.from(map['risposteErrate']),
      tipo: map['tipo'] as String,
      difficolta: map['difficolta'] as String,
    );
    return domanda;
  }

  // Funzione per decodificare stringhe HTML.
  // Converte caratteri HTML speciali (es. &quot; → ") in testo normale.
  static String _decodeHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }
}