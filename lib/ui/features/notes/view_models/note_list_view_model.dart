import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/models/note.dart';
import '../../../../data/repositories/note_repository.dart';

class NoteListViewModel extends ChangeNotifier {
  NoteListViewModel({
    required NoteRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId {
    _subscription = _repository.watchAllNotes(_userId).listen(
      (notes) {
        this.notes = notes;
        isLoading = false;
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        error = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  final NoteRepository _repository;
  final String _userId;
  late final StreamSubscription<List<Note>> _subscription;

  List<Note> notes = [];
  bool isLoading = true;
  String? error;

  Future<Note> createNote() =>
      _repository.createNote(userId: _userId, title: '');

  Future<void> deleteNote(String id) => _repository.softDeleteNote(id);

  Future<void> togglePin(Note note) =>
      _repository.updateNote(id: note.id, isPinned: !note.isPinned);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
