import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:slate/data/models/task.dart';
import 'package:slate/data/repositories/task_repository.dart';
import 'package:slate/ui/features/tasks/view_models/task_list_view_model.dart';

class FakeTaskRepository implements TaskRepository {
  final controller = StreamController<List<Task>>.broadcast();
  final List<({String id, TaskStatus? status, String? position})> updates = [];

  @override
  Stream<List<Task>> watchAllTasks(String userId) => controller.stream;

  @override
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
    updates.add((id: id, status: status, position: position));
  }

  @override
  Future<void> moveTask({
    required String id,
    required TaskStatus status,
    String? before,
    String? after,
  }) async {
    updates.add((id: id, status: status, position: '$before|$after'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

Task _task(
  String id, {
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.none,
  DateTime? dueDate,
  String position = 'a0',
}) =>
    Task(
      id: id,
      userId: 'u1',
      title: id,
      description: '',
      status: status,
      priority: priority,
      position: position,
      dueDate: dueDate,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  late FakeTaskRepository repo;
  late TaskListViewModel vm;

  setUp(() {
    repo = FakeTaskRepository();
    vm = TaskListViewModel(repository: repo, userId: 'u1');
  });

  tearDown(() {
    vm.dispose();
    repo.controller.close();
  });

  test('groups tasks into today / upcoming / no date', () async {
    final now = DateTime.now();
    repo.controller.add([
      _task('today', dueDate: now),
      _task('overdue', dueDate: now.subtract(const Duration(days: 2))),
      _task('upcoming', dueDate: now.add(const Duration(days: 3))),
      _task('nodate'),
      _task('done', status: TaskStatus.done, dueDate: now),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(vm.todayTasks.map((t) => t.id), containsAll(['today', 'overdue']));
    expect(vm.upcomingTasks.map((t) => t.id), ['upcoming']);
    expect(vm.noDateTasks.map((t) => t.id), ['nodate']);
    // Done tasks are excluded from all list groups
    expect(vm.todayTasks.map((t) => t.id), isNot(contains('done')));
  });

  test('sorts groups by priority then due date', () async {
    final now = DateTime.now();
    repo.controller.add([
      _task('low', priority: TaskPriority.low, dueDate: now),
      _task('high', priority: TaskPriority.high, dueDate: now),
      _task('med', priority: TaskPriority.medium, dueDate: now),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(vm.todayTasks.map((t) => t.id), ['high', 'med', 'low']);
  });

  test('toggleDone flips status both ways', () async {
    await vm.toggleDone(_task('t1'));
    await vm.toggleDone(_task('t2', status: TaskStatus.done));

    expect(repo.updates[0].status, TaskStatus.done);
    expect(repo.updates[1].status, TaskStatus.todo);
  });

  test('moveToColumn computes neighbours from target column', () async {
    repo.controller.add([
      _task('a', status: TaskStatus.inProgress, position: 'a1'),
      _task('b', status: TaskStatus.inProgress, position: 'a2'),
      _task('moving', status: TaskStatus.todo, position: 'a0'),
    ]);
    await Future<void>.delayed(Duration.zero);

    await vm.moveToColumn(
      vm.tasks.firstWhere((t) => t.id == 'moving'),
      TaskStatus.inProgress,
      1,
    );

    expect(repo.updates.single.status, TaskStatus.inProgress);
    expect(repo.updates.single.position, 'a1|a2');
  });
}
