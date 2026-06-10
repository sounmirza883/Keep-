import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import '../../data/providers.dart';

/// Synced ✓ / Pending ↑ / Offline ○ badge driven by PowerSync status.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(slateDbProvider);

    return StreamBuilder<SyncStatus>(
      stream: db.statusStream,
      initialData: db.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final (icon, color, label, key) = switch (status) {
          SyncStatus(connected: false) => (
              Icons.cloud_off_outlined,
              Theme.of(context).colorScheme.outline,
              'Offline',
              'sync_status_offline',
            ),
          SyncStatus(uploading: true) || SyncStatus(downloading: true) => (
              Icons.cloud_upload_outlined,
              Colors.amber,
              'Syncing',
              'sync_status_pending',
            ),
          _ => (
              Icons.cloud_done_outlined,
              Colors.green,
              'Synced',
              'sync_status_synced',
            ),
        };

        return Tooltip(
          message: label,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(icon, color: color, key: Key(key), size: 20),
          ),
        );
      },
    );
  }
}
