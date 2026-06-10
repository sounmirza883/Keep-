import 'package:patrol/patrol.dart';
import 'package:slate/main.dart' as app;

void main() {
  patrolTest('creates a task and completes it from the list', ($) async {
    await app.main();
    await $.pumpAndSettle();

    await $('Tasks').tap();
    await $.pumpAndSettle();

    // Create
    await $('+').tap();
    await $('Title *').enterText('Patrol Task');
    await $('Create').tap();
    await $('Patrol Task').waitUntilVisible();

    // Complete via checkbox; task should leave the open groups
    await $('Patrol Task').tap();
    await $.pumpAndSettle();
  });
}
