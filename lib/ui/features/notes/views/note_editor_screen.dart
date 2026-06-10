import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/note_view_model_providers.dart';

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
