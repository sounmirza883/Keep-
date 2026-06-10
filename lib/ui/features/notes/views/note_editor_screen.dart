import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/providers.dart';
import '../view_models/note_editor_view_model.dart';
import '../view_models/note_view_model_providers.dart';
import 'note_tag_chips.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  TextEditingController? _titleController;
  TextEditingController? _contentController;

  @override
  void dispose() {
    _titleController?.dispose();
    _contentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(noteEditorViewModelProvider(widget.noteId));

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (vm.error != null) {
          return Scaffold(
            appBar: AppBar(leading: BackButton(onPressed: () => context.go('/notes'))),
            body: Center(child: Text(vm.error!)),
          );
        }

        _titleController ??= TextEditingController(text: vm.note!.title);
        _contentController ??= TextEditingController(text: vm.note!.content);

        return PopScope(
          canPop: !vm.hasUnsavedChanges,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) {
              await vm.save();
              if (context.mounted) context.go('/notes');
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () async {
                  await vm.save();
                  if (context.mounted) context.go('/notes');
                },
              ),
              actions: [
                _AiActions(vm: vm),
                if (vm.hasUnsavedChanges)
                  IconButton(
                    key: const Key('save_button'),
                    icon: const Icon(Icons.check),
                    tooltip: 'Save',
                    onPressed: vm.save,
                  ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    onChanged: vm.onTitleChanged,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                  ),
                  NoteTagChips(noteId: widget.noteId),
                  const Divider(height: 1),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      onChanged: vm.onContentChanged,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: 'Start writing…',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "Summarize" / "Auto-tag" menu — only shown when on-device AI is
/// available and the note has enough content.
class _AiActions extends ConsumerWidget {
  const _AiActions({required this.vm});

  final NoteEditorViewModel vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiAvailable = ref.watch(aiAvailableProvider).value ?? false;
    if (!aiAvailable || !vm.canUseAi) return const SizedBox.shrink();

    if (vm.isAiRunning) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.auto_awesome),
      tooltip: 'AI actions',
      onSelected: (action) async {
        switch (action) {
          case 'summarize':
            await vm.runSummarize();
            if (context.mounted && vm.aiSummary != null) {
              showModalBottomSheet<void>(
                context: context,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Summary', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Text(vm.aiSummary!),
                    ],
                  ),
                ),
              );
            }
          case 'autoTag':
            await vm.runAutoTag();
            if (context.mounted && vm.aiSuggestedTags.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Suggested tags: ${vm.aiSuggestedTags.join(', ')}')),
              );
            }
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'summarize', child: Text('Summarize')),
        PopupMenuItem(value: 'autoTag', child: Text('Auto-tag')),
      ],
    );
  }
}
