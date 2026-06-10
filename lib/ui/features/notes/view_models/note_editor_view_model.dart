import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/models/note.dart';
import '../../../../data/repositories/note_repository.dart';

class NoteEditorViewModel extends ChangeNotifier {
  NoteEditorViewModel({
    required NoteRepository repository,
    required String noteId,
  })  : _repository = repository,
        _noteId = noteId {
    _load();
  }

  final NoteRepository _repository;
  final String _noteId;

  Note? note;
  bool isLoading = true;
  String? error;
  bool hasUnsavedChanges = false;

  String _title = '';
  String _content = '';
  Timer? _autoSaveTimer;

  Future<void> _load() async {
    try {
      note = await _repository.getNoteById(_noteId);
      if (note == null) {
        error = 'Note not found';
      } else {
        _title = note!.title;
        _content = note!.content;
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  void onTitleChanged(String value) {
    _title = value;
    _markDirty();
  }

  void onContentChanged(String value) {
    _content = value;
    _markDirty();
  }

  void _markDirty() {
    hasUnsavedChanges = true;
    // Auto-save 3 seconds after the last edit.
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), save);
    notifyListeners();
  }

  Future<void> save() async {
    _autoSaveTimer?.cancel();
    if (!hasUnsavedChanges) return;
    await _repository.updateNote(id: _noteId, title: _title, content: _content);
    hasUnsavedChanges = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
