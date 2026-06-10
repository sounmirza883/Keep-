import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/note_view_model_providers.dart';

/// Tag chip row for the note editor: shows assigned tags with remove,
/// plus an "Add tag" chip opening autocomplete + create-new.
class NoteTagChips extends ConsumerWidget {
  const NoteTagChips({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(noteTagsViewModelProvider(noteId));

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final tag in vm.noteTags)
                InputChip(
                  label: Text(tag.name),
                  onDeleted: () => vm.removeTag(tag),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Add tag'),
                onPressed: () => _showAddTagSheet(context, vm),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTagSheet(BuildContext context, dynamic vm) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final matches = vm.suggestions(controller.text) as List;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Tag name',
                      hintText: 'Type to search or create',
                    ),
                    onChanged: (_) => setSheetState(() {}),
                    onSubmitted: (value) async {
                      await vm.addTag(value);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 8),
                  for (final tag in matches.take(5))
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.label_outline, size: 18),
                      title: Text(tag.name as String),
                      onTap: () async {
                        await vm.addExistingTag(tag);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                    ),
                  if (controller.text.trim().isNotEmpty)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.add, size: 18),
                      title: Text('Create "${controller.text.trim().toLowerCase()}"'),
                      onTap: () async {
                        await vm.addTag(controller.text);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
