import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/task.dart';
import '../view_models/task_view_model_providers.dart';

class TaskFormScreen extends ConsumerWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(taskFormViewModelProvider(taskId));

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.go('/tasks')),
            title: Text(vm.isEditing ? 'Edit task' : 'New task'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                initialValue: vm.title,
                onChanged: (v) => vm.title = v,
                decoration: const InputDecoration(labelText: 'Title *'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: vm.description,
                onChanged: (v) => vm.description = v,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Text('Priority', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: const [
                  ButtonSegment(value: TaskPriority.none, label: Text('None')),
                  ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                  ButtonSegment(value: TaskPriority.medium, label: Text('Med')),
                  ButtonSegment(value: TaskPriority.high, label: Text('High')),
                ],
                selected: {vm.priority},
                onSelectionChanged: (s) => vm.setPriority(s.first),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(
                  vm.dueDate == null
                      ? 'No due date'
                      : MaterialLocalizations.of(context).formatShortDate(vm.dueDate!),
                ),
                trailing: vm.dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => vm.setDueDate(null),
                      )
                    : null,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: vm.dueDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) vm.setDueDate(picked);
                },
              ),
              if (vm.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  vm.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final ok = await vm.submit();
                  if (ok && context.mounted) context.go('/tasks');
                },
                child: Text(vm.isEditing ? 'Save' : 'Create'),
              ),
            ],
          ),
        );
      },
    );
  }
}
