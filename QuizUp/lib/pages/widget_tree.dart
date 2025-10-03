import 'package:flutter/material.dart';
import 'package:quiz_up/data/notifier.dart';
import 'package:quiz_up/pages/friends.dart';
import 'package:quiz_up/pages/hints.dart';
import 'package:quiz_up/pages/play_mode.dart';
import 'package:quiz_up/pages/rank.dart';
import 'package:quiz_up/pages/profile.dart';
import 'package:quiz_up/widgets/Bottom_Nav_Bar.dart';

List<Widget> pages = [
  ProfilePage(),
  HintsPage(),
  PlaymodePage(),
  RankPage(),
  FriendsPage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier, //ValueNotifier
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
