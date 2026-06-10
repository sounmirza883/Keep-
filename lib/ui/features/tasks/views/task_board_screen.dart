import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/task.dart';
import '../view_models/task_list_view_model.dart';
import '../view_models/task_view_model_providers.dart';

class TaskBoardScreen extends ConsumerWidget {
  const TaskBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(taskListViewModelProvider);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.go('/tasks')),
            title: const Text('Board'),
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    for (final status in TaskStatus.values)
                      Expanded(child: _BoardColumn(status: status, vm: vm)),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.go('/tasks/new'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({required this.status, required this.vm});

  final TaskStatus status;
  final TaskListViewModel vm;

  String get _label => switch (status) {
        TaskStatus.todo => 'To do',
        TaskStatus.inProgress => 'In progress',
        TaskStatus.done => 'Done',
      };

  @override
  Widget build(BuildContext context) {
    final tasks = vm.tasksByStatus(status);

    return DragTarget<Task>(
      onAcceptWithDetails: (details) =>
          vm.moveToColumn(details.data, status, tasks.length),
      builder: (context, candidates, _) {
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: candidates.isNotEmpty
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '$_label (${tasks.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final card = _TaskCard(task: task);
                    return LongPressDraggable<Task>(
                      data: task,
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(width: 200, child: card),
                      ),
                      childWhenDragging: Opacity(opacity: 0.4, child: card),
                      child: DragTarget<Task>(
                        onAcceptWithDetails: (details) =>
                            vm.moveToColumn(details.data, status, index),
                        builder: (context, _, __) => card,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go('/tasks/${task.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: Theme.of(context).textTheme.bodyMedium),
              if (task.dueDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  MaterialLocalizations.of(context).formatShortDate(task.dueDate!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
