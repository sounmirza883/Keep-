import 'package:flutter/material.dart';

import 'slate_nav_bar.dart';

/// Responsive shell: bottom NavigationBar on phones, NavigationRail on
/// tablet/desktop widths (>= 800dp).
class AdaptiveNavScaffold extends StatelessWidget {
  const AdaptiveNavScaffold({
    super.key,
    required this.currentIndex,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  final int currentIndex;
  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget? floatingActionButton;

  static const _railBreakpoint = 800.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= _railBreakpoint;

        if (!useRail) {
          return Scaffold(
            appBar: appBar,
            body: body,
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: SlateNavBar(currentIndex: currentIndex),
          );
        }

        return Scaffold(
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: currentIndex,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (index) =>
                    SlateNavBar.navigateTo(context, index),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.note_outlined),
                    label: Text('Notes'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.check_circle_outline),
                    label: Text('Tasks'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
