import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/models/note.dart';
import '../../../../data/repositories/note_repository.dart';
import '../../../../domain/use_cases/auto_tag_use_case.dart';
import '../../../../domain/use_cases/summarize_note_use_case.dart';

class NoteEditorViewModel extends ChangeNotifier {
  NoteEditorViewModel({
    required NoteRepository repository,
    required String noteId,
    SummarizeNoteUseCase? summarizeUseCase,
    AutoTagUseCase? autoTagUseCase,
  })  : _repository = repository,
        _noteId = noteId,
        _summarize = summarizeUseCase,
        _autoTag = autoTagUseCase {
    _load();
  }

  final NoteRepository _repository;
  final String _noteId;
  final SummarizeNoteUseCase? _summarize;
  final AutoTagUseCase? _autoTag;

  Note? note;
  bool isLoading = true;
  String? error;
  bool hasUnsavedChanges = false;

  // AI state
  bool isAiRunning = false;
  String? aiSummary;
  List<String> aiSuggestedTags = [];

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

  Future<void> runSummarize() async {
    if (_summarize == null || isAiRunning) return;
    isAiRunning = true;
    notifyListeners();
    try {
      aiSummary = await _summarize(_content);
    } finally {
      isAiRunning = false;
      notifyListeners();
    }
  }

  Future<void> runAutoTag() async {
    if (_autoTag == null || isAiRunning) return;
    isAiRunning = true;
    notifyListeners();
    try {
      aiSuggestedTags = await _autoTag(_content);
    } finally {
      isAiRunning = false;
      notifyListeners();
    }
  }

  /// AI actions are offered once there is enough text to work with.
  bool get canUseAi => _content.trim().length >= SummarizeNoteUseCase.minLength;

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
