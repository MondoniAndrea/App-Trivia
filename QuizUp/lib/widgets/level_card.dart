import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final String title;
  final Color color1;
  final Color color2;
  final IconData icon;
  final Widget nextPage;
  final double? fontSize;

  const LevelCard({
    required this.title,
    required this.color1,
    required this.color2,
    required this.icon,
    required this.nextPage,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.08),
        padding: EdgeInsets.all(screenWidth * 0.08), //grandezza bottoni
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: screenWidth * 0.12,
            ), // grandezza icona adattiva
            SizedBox(width: screenWidth * 0.05),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize:  fontSize ?? 28, //grandezza del testo adattiva
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
