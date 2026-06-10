import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/providers.dart';
import 'note_editor_view_model.dart';
import 'note_list_view_model.dart';

part 'note_view_model_providers.g.dart';

@riverpod
NoteListViewModel noteListViewModel(Ref ref) {
  final userId = ref.watch(currentUserIdProvider);
  final vm = NoteListViewModel(
    repository: ref.watch(noteRepositoryProvider),
    userId: userId ?? '',
  );
  ref.onDispose(vm.dispose);
  return vm;
}

@riverpod
NoteEditorViewModel noteEditorViewModel(Ref ref, String noteId) {
  final vm = NoteEditorViewModel(
    repository: ref.watch(noteRepositoryProvider),
    noteId: noteId,
  );
  ref.onDispose(vm.dispose);
  return vm;
}
