import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:slate/main.dart' as app;

// Assumes an authenticated session (run after auth_test or with a cached
// session in the test harness).
void main() {
  patrolTest('creates a note and sees it in the list', ($) async {
    await app.main();
    await $.pumpAndSettle();

    await $(FloatingActionButton).tap();
    await $('Title').enterText('Patrol Test Note');
    await $('Start writing…').enterText('Created by an integration test.');
    await $(const Key('save_button')).tap();
    await $(BackButton).tap();

    await $('Patrol Test Note').waitUntilVisible();
  });
}
