import 'package:powersync/powersync.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

import '../models/tag.dart';

class TagRepository {
  TagRepository(this._db);

  final PowerSyncDatabase _db;

  Stream<List<Tag>> watchAllTags(String userId) {
    return _db
        .watch(
          'SELECT * FROM tags WHERE user_id = ? ORDER BY name ASC',
          parameters: [userId],
        )
        .map(_mapRows);
  }

  Stream<List<Tag>> watchTagsForNote(String noteId) {
    return _db
        .watch(
          'SELECT t.* FROM tags t JOIN note_tags nt ON nt.tag_id = t.id '
          'WHERE nt.note_id = ? ORDER BY t.name ASC',
          parameters: [noteId],
        )
        .map(_mapRows);
  }

  Stream<Set<String>> watchNoteIdsWithTag(String tagId) {
    return _db
        .watch(
          'SELECT note_id FROM note_tags WHERE tag_id = ?',
          parameters: [tagId],
        )
        .map((rows) => rows.map((r) => r['note_id'] as String).toSet());
  }

  Future<Tag> createTag({
    required String userId,
    required String name,
    String colorHex = '#6366f1',
  }) async {
    final normalized = name.trim().toLowerCase();

    // Tag names are unique per user — reuse an existing tag if present.
    final existing = await _db.getAll(
      'SELECT * FROM tags WHERE user_id = ? AND name = ?',
      [userId, normalized],
    );
    if (existing.isNotEmpty) return Tag.fromRow(existing.first);

    final id = uuid.v4();
    await _db.execute(
      'INSERT INTO tags (id, user_id, name, color_hex, created_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [id, userId, normalized, colorHex, DateTime.now().toUtc().toIso8601String()],
    );
    final rows = await _db.getAll('SELECT * FROM tags WHERE id = ?', [id]);
    return Tag.fromRow(rows.first);
  }

  Future<void> addTagToNote(String noteId, String tagId) async {
    await _db.execute(
      'INSERT OR IGNORE INTO note_tags (id, note_id, tag_id) VALUES (?, ?, ?)',
      ['$noteId:$tagId', noteId, tagId],
    );
  }

  Future<void> removeTagFromNote(String noteId, String tagId) async {
    await _db.execute(
      'DELETE FROM note_tags WHERE note_id = ? AND tag_id = ?',
      [noteId, tagId],
    );
  }

  Future<void> deleteTag(String id) async {
    await _db.execute('DELETE FROM note_tags WHERE tag_id = ?', [id]);
    await _db.execute('DELETE FROM tags WHERE id = ?', [id]);
  }

  List<Tag> _mapRows(sqlite.ResultSet rows) =>
      rows.map((row) => Tag.fromRow(row)).toList();
}
