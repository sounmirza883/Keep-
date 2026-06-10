import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shared by the top-level Notes and Tasks screens.
class SlateNavBar extends StatelessWidget {
  const SlateNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  static void navigateTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/notes');
      case 1:
        context.go('/tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => navigateTo(context, index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.note_outlined), label: 'Notes'),
        NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
      ],
    );
  }
}
