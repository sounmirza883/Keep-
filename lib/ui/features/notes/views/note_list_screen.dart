import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/slate_nav_bar.dart';
import '../../../core/sync_status_indicator.dart';
import '../view_models/note_view_model_providers.dart';

class NoteListScreen extends ConsumerWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(noteListViewModelProvider);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notes'),
            actions: [
              const SyncStatusIndicator(),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () => context.go('/search'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),
          body: switch ((vm.isLoading, vm.error, vm.notes.isEmpty)) {
            (true, _, _) => const Center(child: CircularProgressIndicator()),
            (_, final String error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 8),
                    Text(error),
                  ],
                ),
              ),
            (_, _, true) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_outlined, size: 64),
                    SizedBox(height: 16),
                    Text('No notes yet'),
                    SizedBox(height: 8),
                    Text('Tap + to create your first note'),
                  ],
                ),
              ),
            _ => ListView.builder(
                itemCount: vm.notes.length,
                itemBuilder: (context, index) {
                  final note = vm.notes[index];
                  return Dismissible(
                    key: ValueKey(note.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Theme.of(context).colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => vm.deleteNote(note.id),
                    child: ListTile(
                      leading: note.isPinned
                          ? const Icon(Icons.push_pin, size: 18)
                          : null,
                      title: Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: note.content.isEmpty
                          ? null
                          : Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () => context.go('/notes/${note.id}/edit'),
                      onLongPress: () => vm.togglePin(note),
                    ),
                  );
                },
              ),
          },
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final note = await vm.createNote();
              if (context.mounted) context.go('/notes/${note.id}/edit');
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const SlateNavBar(currentIndex: 0),
        );
      },
    );
  }
}
