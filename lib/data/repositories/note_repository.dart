import 'package:powersync/powersync.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

import '../models/note.dart';

/// All note reads/writes go through the local PowerSync database.
/// PowerSync queues writes and uploads them to Supabase when online.
class NoteRepository {
  NoteRepository(this._db);

  final PowerSyncDatabase _db;

  Stream<List<Note>> watchAllNotes(String userId) {
    return _db
        .watch(
          'SELECT * FROM notes WHERE user_id = ? AND is_deleted = 0 '
          'ORDER BY is_pinned DESC, updated_at DESC',
          parameters: [userId],
        )
        .map(_mapRows);
  }

  Future<Note?> getNoteById(String id) async {
    final rows = await _db.getAll('SELECT * FROM notes WHERE id = ?', [id]);
    if (rows.isEmpty) return null;
    return Note.fromRow(rows.first);
  }

  Future<Note> createNote({
    required String userId,
    required String title,
    String content = '',
    String contentType = 'markdown',
  }) async {
    final id = uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.execute(
      'INSERT INTO notes (id, user_id, title, content, content_type, '
      'is_pinned, is_deleted, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?, 0, 0, ?, ?)',
      [id, userId, title, content, contentType, now, now],
    );
    return (await getNoteById(id))!;
  }

  Future<void> updateNote({
    required String id,
    String? title,
    String? content,
    bool? isPinned,
  }) async {
    final sets = <String>['updated_at = ?'];
    final params = <Object?>[DateTime.now().toUtc().toIso8601String()];
    if (title != null) {
      sets.add('title = ?');
      params.add(title);
    }
    if (content != null) {
      sets.add('content = ?');
      params.add(content);
    }
    if (isPinned != null) {
      sets.add('is_pinned = ?');
      params.add(isPinned ? 1 : 0);
    }
    params.add(id);
    await _db.execute('UPDATE notes SET ${sets.join(', ')} WHERE id = ?', params);
  }

  Future<void> softDeleteNote(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.execute(
      'UPDATE notes SET is_deleted = 1, deleted_at = ?, updated_at = ? WHERE id = ?',
      [now, now, id],
    );
  }

  Future<List<Note>> searchNotes(String userId, String query) async {
    final ftsQuery = _toFtsQuery(query);
    if (ftsQuery == null) {
      final rows = await _db.getAll(
        'SELECT * FROM notes WHERE user_id = ? AND is_deleted = 0 '
        'AND (title LIKE ? OR content LIKE ?) ORDER BY updated_at DESC',
        [userId, '%$query%', '%$query%'],
      );
      return _mapRows(rows);
    }

    try {
      final rows = await _db.getAll(
        'SELECT n.* FROM notes n '
        'JOIN notes_fts f ON f.id = n.id '
        'WHERE n.user_id = ? AND n.is_deleted = 0 AND notes_fts MATCH ? '
        'ORDER BY rank',
        [userId, ftsQuery],
      );
      return _mapRows(rows);
    } on Exception {
      // notes_fts may not exist yet (e.g. before setupFullTextSearch runs).
      final rows = await _db.getAll(
        'SELECT * FROM notes WHERE user_id = ? AND is_deleted = 0 '
        'AND (title LIKE ? OR content LIKE ?) ORDER BY updated_at DESC',
        [userId, '%$query%', '%$query%'],
      );
      return _mapRows(rows);
    }
  }

  /// Builds an FTS5 MATCH expression that treats the query as a prefix
  /// search over each whitespace-separated term, e.g. "proj plan" ->
  /// `"proj"* "plan"*`. Returns null for empty/whitespace-only input.
  String? _toFtsQuery(String query) {
    final terms = query
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => t.replaceAll('"', ''))
        .where((t) => t.isNotEmpty)
        .toList();
    if (terms.isEmpty) return null;
    return terms.map((t) => '"$t"*').join(' ');
  }

  List<Note> _mapRows(sqlite.ResultSet rows) =>
      rows.map((row) => Note.fromRow(row)).toList();
}
