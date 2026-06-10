import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

enum TaskStatus {
  todo('todo'),
  inProgress('in_progress'),
  done('done');

  const TaskStatus(this.dbValue);
  final String dbValue;

  static TaskStatus fromDb(String? value) => TaskStatus.values.firstWhere(
        (s) => s.dbValue == value,
        orElse: () => TaskStatus.todo,
      );
}

enum TaskPriority {
  none('none'),
  low('low'),
  medium('medium'),
  high('high');

  const TaskPriority(this.dbValue);
  final String dbValue;

  static TaskPriority fromDb(String? value) => TaskPriority.values.firstWhere(
        (p) => p.dbValue == value,
        orElse: () => TaskPriority.none,
      );
}

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String userId,
    String? noteId,
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required String position,
    DateTime? dueDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;

  const Task._();

  factory Task.fromRow(Map<String, Object?> row) => Task(
        id: row['id'] as String,
        userId: row['user_id'] as String? ?? '',
        noteId: row['note_id'] as String?,
        title: row['title'] as String? ?? '',
        description: row['description'] as String? ?? '',
        status: TaskStatus.fromDb(row['status'] as String?),
        priority: TaskPriority.fromDb(row['priority'] as String?),
        position: row['position'] as String? ?? 'a0',
        dueDate: _parseDate(row['due_date']),
        createdAt: _parseDate(row['created_at']) ?? DateTime.now(),
        updatedAt: _parseDate(row['updated_at']) ?? DateTime.now(),
      );
}

DateTime? _parseDate(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
