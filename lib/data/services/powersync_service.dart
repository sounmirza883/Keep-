import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';

const Schema appSchema = Schema([]);

class SlateDatabase extends PowerSyncDatabase {
  SlateDatabase()
      : super(
          schema: appSchema,
          path: 'slate.db',
        );
}

/// Bridges PowerSync auth with Supabase JWT sessions.
class SupabasePowerSyncConnector extends PowerSyncBackendConnector {
  final SupabaseClient _supabase;

  SupabasePowerSyncConnector(this._supabase);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    return PowerSyncCredentials(
      endpoint: Env.powerSyncUrl,
      token: session.accessToken,
      expiresAt: session.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
          : null,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final tx = await database.getNextCrudTransaction();
    if (tx == null) return;

    for (final entry in tx.crud) {
      switch (entry.op) {
        case UpdateType.put:
          await _supabase.from(entry.table).upsert({'id': entry.id, ...entry.opData!});
        case UpdateType.patch:
          await _supabase.from(entry.table).update(entry.opData!).eq('id', entry.id);
        case UpdateType.delete:
          await _supabase.from(entry.table).delete().eq('id', entry.id);
      }
    }

    await tx.complete();
  }
}
