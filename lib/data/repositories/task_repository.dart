import 'package:powersync/powersync.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

import '../../core/fractional_index.dart';
import '../models/task.dart';

class TaskRepository {
  TaskRepository(this._db);

  final PowerSyncDatabase _db;

  Stream<List<Task>> watchAllTasks(String userId) {
    return _db
        .watch(
          'SELECT * FROM tasks WHERE user_id = ? AND is_deleted = 0 '
          'ORDER BY position ASC',
          parameters: [userId],
        )
        .map(_mapRows);
  }

  Future<Task?> getTaskById(String id) async {
    final rows = await _db.getAll('SELECT * FROM tasks WHERE id = ?', [id]);
    if (rows.isEmpty) return null;
    return Task.fromRow(rows.first);
  }

  Future<Task> createTask({
    required String userId,
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.none,
    DateTime? dueDate,
    String? noteId,
  }) async {
    final id = uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    final position = await _positionAtEnd(userId, TaskStatus.todo);
    await _db.execute(
      'INSERT INTO tasks (id, user_id, note_id, title, description, status, '
      'priority, position, due_date, is_deleted, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?)',
      [
        id,
        userId,
        noteId,
        title,
        description,
        TaskStatus.todo.dbValue,
        priority.dbValue,
        position,
        dueDate?.toUtc().toIso8601String(),
        now,
        now,
      ],
    );
    return (await getTaskById(id))!;
  }

  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? noteId,
    String? position,
  }) async {
    final sets = <String>['updated_at = ?'];
    final params = <Object?>[DateTime.now().toUtc().toIso8601String()];
    void set(String column, Object? value) {
      sets.add('$column = ?');
      params.add(value);
    }

    if (title != null) set('title', title);
    if (description != null) set('description', description);
    if (status != null) set('status', status.dbValue);
    if (priority != null) set('priority', priority.dbValue);
    if (dueDate != null) set('due_date', dueDate.toUtc().toIso8601String());
    if (clearDueDate) set('due_date', null);
    if (noteId != null) set('note_id', noteId);
    if (position != null) set('position', position);

    params.add(id);
    await _db.execute('UPDATE tasks SET ${sets.join(', ')} WHERE id = ?', params);
  }

  /// Moves a task to [status], placing it between [before] and [after]
  /// (existing position keys of its new neighbours).
  Future<void> moveTask({
    required String id,
    required TaskStatus status,
    String? before,
    String? after,
  }) {
    return updateTask(
      id: id,
      status: status,
      position: generateKeyBetween(before, after),
    );
  }

  Future<void> softDeleteTask(String id) async {
    await _db.execute(
      'UPDATE tasks SET is_deleted = 1, updated_at = ? WHERE id = ?',
      [DateTime.now().toUtc().toIso8601String(), id],
    );
  }

  Future<String> _positionAtEnd(String userId, TaskStatus status) async {
    final rows = await _db.getAll(
      'SELECT MAX(position) as max_pos FROM tasks '
      'WHERE user_id = ? AND status = ? AND is_deleted = 0',
      [userId, status.dbValue],
    );
    final maxPos = rows.first['max_pos'] as String?;
    return generateKeyBetween(maxPos, null);
  }

  List<Task> _mapRows(sqlite.ResultSet rows) =>
      rows.map((row) => Task.fromRow(row)).toList();
}
