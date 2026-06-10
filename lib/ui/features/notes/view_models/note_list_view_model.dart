import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/models/note.dart';
import '../../../../data/models/tag.dart';
import '../../../../data/repositories/note_repository.dart';
import '../../../../data/repositories/tag_repository.dart';

class NoteListViewModel extends ChangeNotifier {
  NoteListViewModel({
    required NoteRepository repository,
    required TagRepository tagRepository,
    required String userId,
  })  : _repository = repository,
        _tagRepository = tagRepository,
        _userId = userId {
    _subscription = _repository.watchAllNotes(_userId).listen(
      (notes) {
        _allNotes = notes;
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
    _tagsSubscription = _tagRepository.watchAllTags(_userId).listen((tags) {
      allTags = tags;
      notifyListeners();
    });
  }

  final NoteRepository _repository;
  final TagRepository _tagRepository;
  final String _userId;
  late final StreamSubscription<List<Note>> _subscription;
  late final StreamSubscription<List<Tag>> _tagsSubscription;
  StreamSubscription<Set<String>>? _filterSubscription;

  List<Note> _allNotes = [];
  Set<String>? _filteredNoteIds; // null = no tag filter active
  List<Tag> allTags = [];
  Tag? selectedTag;
  bool isLoading = true;
  String? error;

  List<Note> get notes => _filteredNoteIds == null
      ? _allNotes
      : _allNotes.where((n) => _filteredNoteIds!.contains(n.id)).toList();

  void filterByTag(Tag? tag) {
    selectedTag = tag;
    _filterSubscription?.cancel();
    if (tag == null) {
      _filteredNoteIds = null;
      _filterSubscription = null;
      notifyListeners();
      return;
    }
    _filterSubscription =
        _tagRepository.watchNoteIdsWithTag(tag.id).listen((ids) {
      _filteredNoteIds = ids;
      notifyListeners();
    });
  }

  Future<Note> createNote() =>
      _repository.createNote(userId: _userId, title: '');

  Future<void> deleteNote(String id) => _repository.softDeleteNote(id);

  Future<void> togglePin(Note note) =>
      _repository.updateNote(id: note.id, isPinned: !note.isPinned);

  @override
  void dispose() {
    _subscription.cancel();
    _tagsSubscription.cancel();
    _filterSubscription?.cancel();
    super.dispose();
  }
}
