import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:slate/main.dart' as app;

// Requires TEST_EMAIL / TEST_PASSWORD env vars pointing at a seeded
// Supabase test user. Run: patrol test -t integration_test/auth_test.dart
void main() {
  patrolTest('email login lands on notes list', ($) async {
    await app.main();
    await $.pumpAndSettle();

    await $(const Key('email_field'))
        .enterText(const String.fromEnvironment('TEST_EMAIL'));
    await $(const Key('password_field'))
        .enterText(const String.fromEnvironment('TEST_PASSWORD'));
    await $('Log in').tap();

    await $('Notes').waitUntilVisible(timeout: const Duration(seconds: 15));
  });
}
