import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/providers.dart';
import 'task_form_view_model.dart';
import 'task_list_view_model.dart';

part 'task_view_model_providers.g.dart';

@riverpod
TaskListViewModel taskListViewModel(Ref ref) {
  final vm = TaskListViewModel(
    repository: ref.watch(taskRepositoryProvider),
    userId: ref.watch(currentUserIdProvider) ?? '',
  );
  ref.onDispose(vm.dispose);
  return vm;
}

@riverpod
TaskFormViewModel taskFormViewModel(Ref ref, String? taskId) {
  return TaskFormViewModel(
    repository: ref.watch(taskRepositoryProvider),
    userId: ref.watch(currentUserIdProvider) ?? '',
    taskId: taskId,
  );
}
