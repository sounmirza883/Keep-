import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';
import '../drift/schema.dart';

class SlateDatabase extends PowerSyncDatabase {
  SlateDatabase()
      : super(
          schema: appSchema,
          path: 'slate.db',
        );

  /// Creates a local-only FTS5 index over notes, kept in sync via triggers
  /// on the PowerSync-managed `notes` table. Not part of [appSchema] since
  /// virtual tables aren't supported by the PowerSync schema builder.
  Future<void> setupFullTextSearch() async {
    await execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
        id UNINDEXED,
        title,
        content
      )
    ''');

    await execute('''
      CREATE TRIGGER IF NOT EXISTS notes_fts_insert AFTER INSERT ON notes
      WHEN NEW.is_deleted = 0
      BEGIN
        INSERT INTO notes_fts (id, title, content) VALUES (NEW.id, NEW.title, NEW.content);
      END
    ''');

    await execute('''
      CREATE TRIGGER IF NOT EXISTS notes_fts_delete AFTER DELETE ON notes
      BEGIN
        DELETE FROM notes_fts WHERE id = OLD.id;
      END
    ''');

    await execute('''
      CREATE TRIGGER IF NOT EXISTS notes_fts_update AFTER UPDATE ON notes
      BEGIN
        DELETE FROM notes_fts WHERE id = OLD.id;
        INSERT INTO notes_fts (id, title, content)
          SELECT NEW.id, NEW.title, NEW.content WHERE NEW.is_deleted = 0;
      END
    ''');

    // Backfill rows that existed (or were synced down) before the index
    // and its triggers were created.
    await execute('''
      INSERT INTO notes_fts (id, title, content)
      SELECT id, title, content FROM notes
      WHERE is_deleted = 0 AND id NOT IN (SELECT id FROM notes_fts)
    ''');
  }
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
