import 'package:flutter/material.dart';
import 'package:quiz_up/data/model/domanda.dart';

class QuizTemplate extends StatelessWidget {
  final Domanda currentQuestion;
  final List<String> orderedAnswers;
  final double progress;
  final bool answerSelected;
  final String? selectedAnswer;
  final Function(String) selectAnswer;
  final String? sourcePage;

  QuizTemplate({
    super.key,
    required this.currentQuestion,
    required this.orderedAnswers,
    required this.progress,
    required this.answerSelected,
    required this.selectedAnswer,
    required this.selectAnswer,
    this.sourcePage,
  });

  Widget _buildAnswerButton(BuildContext context, String text) {
    Color borderColor = Colors.black12;
    if (answerSelected) {
      if (currentQuestion.rispostaCorretta == text) {
        borderColor = Colors.green;
      } else if (text == selectedAnswer) {
        borderColor = Colors.red;
      }
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: borderColor, width: 2),
          ),
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          elevation: 4,
          shadowColor: Colors.black26,
        ),
        onPressed: () => selectAnswer(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;
    double verticalPadding = MediaQuery.of(context).size.height * 0.02;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Text(
            currentQuestion.categoria,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 10,
                              width: (constraints.maxWidth * progress).clamp(0.0, constraints.maxWidth),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + verticalPadding * 4,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: verticalPadding * 3 + 70, // spazio per il bottom bar
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(horizontalPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              currentQuestion.domanda,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.055,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: verticalPadding),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                  vertical: verticalPadding * 1.5),
                              itemCount: orderedAnswers.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: verticalPadding * 1.8),
                              itemBuilder: (context, index) =>
                                  _buildAnswerButton(context, orderedAnswers[index]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: sourcePage == null ? Padding(
          padding: EdgeInsets.only(bottom: verticalPadding * 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.045,
                  ),
                  shape: CircleBorder(),
                  elevation: 5,
                  shadowColor: Colors.black38,
                ),
                onPressed: () {},
                child: Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.height * 0.04,
                ),
              ),
              SizedBox(width: horizontalPadding * 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.045,
                  ),
                  shape: CircleBorder(),
                  elevation: 5,
                  shadowColor: Colors.black38,
                ),
                onPressed: () {},
                child: Icon(
                  Icons.content_cut,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.height * 0.04,
                ),
              ),
            ],
          ),
        ) : null,
      ),
    );
  }
}
