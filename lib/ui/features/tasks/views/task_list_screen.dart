import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/task.dart';
import '../../../core/slate_nav_bar.dart';
import '../../../core/sync_status_indicator.dart';
import '../view_models/task_list_view_model.dart';
import '../view_models/task_view_model_providers.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(taskListViewModelProvider);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks'),
            actions: [
              const SyncStatusIndicator(),
              IconButton(
                icon: const Icon(Icons.view_kanban_outlined),
                tooltip: 'Board view',
                onPressed: () => context.go('/tasks/board'),
              ),
            ],
          ),
          body: switch ((vm.isLoading, vm.error)) {
            (true, _) => const Center(child: CircularProgressIndicator()),
            (_, final String error) => Center(child: Text(error)),
            _ => _buildGroups(context, vm),
          },
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.go('/tasks/new'),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const SlateNavBar(currentIndex: 1),
        );
      },
    );
  }

  Widget _buildGroups(BuildContext context, TaskListViewModel vm) {
    final groups = [
      ('Today', vm.todayTasks),
      ('Upcoming', vm.upcomingTasks),
      ('No date', vm.noDateTasks),
    ];
    final nonEmpty = groups.where((g) => g.$2.isNotEmpty).toList();

    if (nonEmpty.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64),
            SizedBox(height: 16),
            Text('All clear'),
            SizedBox(height: 8),
            Text('Tap + to add a task'),
          ],
        ),
      );
    }

    return ListView(
      children: [
        for (final (label, tasks) in nonEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
          for (final task in tasks) _TaskTile(task: task, vm: vm),
        ],
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.vm});

  final Task task;
  final TaskListViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.status == TaskStatus.done,
        onChanged: (_) => vm.toggleDone(task),
      ),
      title: Text(task.title),
      subtitle: task.dueDate != null
          ? Text(MaterialLocalizations.of(context).formatShortDate(task.dueDate!))
          : null,
      trailing: task.priority != TaskPriority.none
          ? _PriorityDot(priority: task.priority)
          : null,
      onTap: () => context.go('/tasks/${task.id}/edit'),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      TaskPriority.high => Colors.red,
      TaskPriority.medium => Colors.orange,
      TaskPriority.low => Colors.blue,
      TaskPriority.none => Colors.transparent,
    };
    return Icon(Icons.flag, color: color, size: 18);
  }
}
