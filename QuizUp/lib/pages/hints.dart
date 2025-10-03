import 'package:flutter/material.dart';
import 'package:quiz_up/data/service/player_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HintsPage extends StatefulWidget {
  const HintsPage({super.key});

  @override
  State<HintsPage> createState() => _HintsPageState();
}

class _HintsPageState extends State<HintsPage> {
  late PlayerService _playerService;
  late SharedPreferences _preferences;


  int hintsTimeExtra = 0;
  int hints5050 = 0;
  String? playerId;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _initAsync();
  }

  Future<void> _initAsync() async {
    _preferences = await SharedPreferences.getInstance();
    String? playerId = _preferences.getString('player_id');
    if (playerId != null) {
      await _preferences!.setInt('player_hintsTime', 3);
      await _preferences!.setInt('player_hints50', 2);
      final time = (await _playerService.getHintsTime(playerId))!;
      final fifty = (await _playerService.getHints50(playerId))!;
      setState(() {
        hintsTimeExtra = time ?? 0;
        hints5050 = fifty ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Limito i valori
    hintsTimeExtra = hintsTimeExtra.clamp(0, 5);
    hints5050 = hints5050.clamp(0, 5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Hints",
          style: TextStyle(
            color: Colors.pink,
            fontSize: width * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.02),
            _buildHintCard(
              icon: Icons.timer,
              label: "Tempo-Extra",
              count: hintsTimeExtra,
              iconSize: width * 0.115,
              indicatorSize: width * 0.05,
              fontSize: width * 0.045,
              padding: width * 0.04,
            ),
            SizedBox(height: height * 0.02),
            _buildHintCard(
              icon: Icons.content_cut,
              label: "50-50",
              count: hints5050,
              iconSize: width * 0.115,
              indicatorSize: width * 0.05,
              fontSize: width * 0.045,
              padding: width * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintCard({
    required IconData icon,
    required String label,
    required int count,
    required double iconSize,
    required double indicatorSize,
    required double fontSize,
    required double padding,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.orange, size: iconSize),
            SizedBox(height: padding * 0.5),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: padding * 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: indicatorSize * 0.1,
                  ),
                  child: Icon(
                    icon,
                    color: index < count ? Colors.orange : Colors.grey.shade400,
                    size: indicatorSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
