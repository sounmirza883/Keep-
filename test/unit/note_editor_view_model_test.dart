import 'package:flutter_test/flutter_test.dart';
import 'package:slate/data/models/note.dart';
import 'package:slate/data/repositories/note_repository.dart';
import 'package:slate/ui/features/notes/view_models/note_editor_view_model.dart';

class FakeNoteRepository implements NoteRepository {
  final Map<String, Note> store = {};
  int updateCalls = 0;

  @override
  Future<Note?> getNoteById(String id) async => store[id];

  @override
  Future<void> updateNote({
    required String id,
    String? title,
    String? content,
    bool? isPinned,
  }) async {
    updateCalls++;
    final existing = store[id]!;
    store[id] = existing.copyWith(
      title: title ?? existing.title,
      content: content ?? existing.content,
      isPinned: isPinned ?? existing.isPinned,
      updatedAt: DateTime.now(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

Note _note(String id) => Note(
      id: id,
      userId: 'user-1',
      title: 'Original',
      content: 'Body',
      contentType: 'markdown',
      isPinned: false,
      isDeleted: false,
      createdAt: DateTime(2026, 6, 10),
      updatedAt: DateTime(2026, 6, 10),
    );

void main() {
  late FakeNoteRepository repo;

  setUp(() {
    repo = FakeNoteRepository();
    repo.store['n1'] = _note('n1');
  });

  test('loads note on construction', () async {
    final vm = NoteEditorViewModel(repository: repo, noteId: 'n1');
    await Future<void>.delayed(Duration.zero);

    expect(vm.isLoading, false);
    expect(vm.error, isNull);
    expect(vm.note!.title, 'Original');
  });

  test('reports error when note missing', () async {
    final vm = NoteEditorViewModel(repository: repo, noteId: 'missing');
    await Future<void>.delayed(Duration.zero);

    expect(vm.error, 'Note not found');
  });

  test('save persists edited title and content', () async {
    final vm = NoteEditorViewModel(repository: repo, noteId: 'n1');
    await Future<void>.delayed(Duration.zero);

    vm.onTitleChanged('New title');
    vm.onContentChanged('New content');
    expect(vm.hasUnsavedChanges, true);

    await vm.save();

    expect(vm.hasUnsavedChanges, false);
    expect(repo.store['n1']!.title, 'New title');
    expect(repo.store['n1']!.content, 'New content');
    vm.dispose();
  });

  test('save is a no-op when nothing changed', () async {
    final vm = NoteEditorViewModel(repository: repo, noteId: 'n1');
    await Future<void>.delayed(Duration.zero);

    await vm.save();

    expect(repo.updateCalls, 0);
    vm.dispose();
  });
}
