import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/models/task.dart';
import '../../../../data/repositories/task_repository.dart';

class TaskListViewModel extends ChangeNotifier {
  TaskListViewModel({
    required TaskRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId {
    _subscription = _repository.watchAllTasks(_userId).listen(
      (tasks) {
        this.tasks = tasks;
        isLoading = false;
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        error = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  final TaskRepository _repository;
  final String _userId;
  late final StreamSubscription<List<Task>> _subscription;

  List<Task> tasks = [];
  bool isLoading = true;
  String? error;

  static int _byPriorityThenDue(Task a, Task b) {
    final p = b.priority.index.compareTo(a.priority.index);
    if (p != 0) return p;
    if (a.dueDate == null) return b.dueDate == null ? 0 : 1;
    if (b.dueDate == null) return -1;
    return a.dueDate!.compareTo(b.dueDate!);
  }

  List<Task> get _open =>
      tasks.where((t) => t.status != TaskStatus.done).toList();

  List<Task> get todayTasks {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day + 1);
    return _open
        .where((t) => t.dueDate != null && t.dueDate!.isBefore(endOfDay))
        .toList()
      ..sort(_byPriorityThenDue);
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day + 1);
    return _open
        .where((t) => t.dueDate != null && !t.dueDate!.isBefore(endOfDay))
        .toList()
      ..sort(_byPriorityThenDue);
  }

  List<Task> get noDateTasks =>
      _open.where((t) => t.dueDate == null).toList()..sort(_byPriorityThenDue);

  List<Task> tasksByStatus(TaskStatus status) =>
      tasks.where((t) => t.status == status).toList();

  Future<void> toggleDone(Task task) => _repository.updateTask(
        id: task.id,
        status:
            task.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done,
      );

  /// Drag-and-drop: drop [task] into [status] at [index] within that column.
  Future<void> moveToColumn(Task task, TaskStatus status, int index) {
    final column =
        tasksByStatus(status).where((t) => t.id != task.id).toList();
    final before = index > 0 && index - 1 < column.length
        ? column[index - 1].position
        : null;
    final after = index < column.length ? column[index].position : null;
    return _repository.moveTask(
      id: task.id,
      status: status,
      before: before,
      after: after,
    );
  }

  Future<void> deleteTask(String id) => _repository.softDeleteTask(id);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
