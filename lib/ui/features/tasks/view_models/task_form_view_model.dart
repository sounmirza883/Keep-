import 'package:flutter/foundation.dart';

import '../../../../data/models/task.dart';
import '../../../../data/repositories/task_repository.dart';

class TaskFormViewModel extends ChangeNotifier {
  TaskFormViewModel({
    required TaskRepository repository,
    required String userId,
    this.taskId,
  })  : _repository = repository,
        _userId = userId {
    if (taskId != null) _load();
  }

  final TaskRepository _repository;
  final String _userId;
  final String? taskId;

  bool isLoading = false;
  String? error;

  String title = '';
  String description = '';
  TaskPriority priority = TaskPriority.none;
  DateTime? dueDate;
  String? noteId;

  bool get isEditing => taskId != null;

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    final task = await _repository.getTaskById(taskId!);
    if (task == null) {
      error = 'Task not found';
    } else {
      title = task.title;
      description = task.description;
      priority = task.priority;
      dueDate = task.dueDate;
      noteId = task.noteId;
    }
    isLoading = false;
    notifyListeners();
  }

  void setPriority(TaskPriority value) {
    priority = value;
    notifyListeners();
  }

  void setDueDate(DateTime? value) {
    dueDate = value;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (title.trim().isEmpty) {
      error = 'Title is required';
      notifyListeners();
      return false;
    }
    error = null;
    if (isEditing) {
      await _repository.updateTask(
        id: taskId!,
        title: title.trim(),
        description: description,
        priority: priority,
        dueDate: dueDate,
        clearDueDate: dueDate == null,
        noteId: noteId,
      );
    } else {
      await _repository.createTask(
        userId: _userId,
        title: title.trim(),
        description: description,
        priority: priority,
        dueDate: dueDate,
        noteId: noteId,
      );
    }
    return true;
  }
}
