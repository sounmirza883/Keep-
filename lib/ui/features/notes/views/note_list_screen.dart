import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/adaptive_nav_scaffold.dart';
import '../../../core/sync_status_indicator.dart';
import '../view_models/note_list_view_model.dart';
import '../view_models/note_view_model_providers.dart';

class NoteListScreen extends ConsumerWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(noteListViewModelProvider);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return AdaptiveNavScaffold(
          currentIndex: 0,
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
            _ => Column(
                children: [
                  if (vm.allTags.isNotEmpty)
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: FilterChip(
                              label: const Text('All'),
                              selected: vm.selectedTag == null,
                              onSelected: (_) => vm.filterByTag(null),
                            ),
                          ),
                          for (final tag in vm.allTags)
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: FilterChip(
                                label: Text(tag.name),
                                selected: vm.selectedTag?.id == tag.id,
                                onSelected: (selected) =>
                                    vm.filterByTag(selected ? tag : null),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(child: _buildNoteList(context, vm)),
                ],
              ),
          },
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final note = await vm.createNote();
              if (context.mounted) context.go('/notes/${note.id}/edit');
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildNoteList(BuildContext context, NoteListViewModel vm) {
    if (vm.notes.isEmpty) {
      return const Center(child: Text('No notes match this tag'));
    }
    return ListView.builder(
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
              );
  }
}
