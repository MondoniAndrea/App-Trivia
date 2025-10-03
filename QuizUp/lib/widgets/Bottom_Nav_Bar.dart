import 'package:flutter/material.dart';
import 'package:quiz_up/data/notifier.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.person, color: Colors.grey, size: 35),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.lightbulb, color: Colors.yellow, size: 35),
              label: 'Hints',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_arrow, color: Colors.black, size: 35),
              label: 'Play',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events, color: Colors.amber, size: 35),
              label: 'Rank',
            ),
            NavigationDestination(
              icon: Icon(Icons.people, color: Colors.blue, size: 35),
              label: 'Friends',
            ),
          ],
          onDestinationSelected: (int value) {
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
