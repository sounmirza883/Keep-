import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:slate/main.dart' as app;

void main() {
  patrolTest('creates a note offline and syncs on reconnect', ($) async {
    await app.main();
    await $.pumpAndSettle();

    // Go offline
    await $.native.disableWifi();
    await $.native.disableCellular();

    // Create a note while offline — write must succeed locally
    await $(FloatingActionButton).tap();
    await $('Title').enterText('Offline Note');
    await $(const Key('save_button')).tap();
    await $(BackButton).tap();
    await $('Offline Note').waitUntilVisible();

    // Reconnect and verify the sync indicator returns to Synced
    await $.native.enableWifi();
    await $(const Key('sync_status_synced'))
        .waitUntilVisible(timeout: const Duration(seconds: 10));
  });
}
