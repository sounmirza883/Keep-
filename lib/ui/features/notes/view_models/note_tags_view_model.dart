import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/models/tag.dart';
import '../../../../data/repositories/tag_repository.dart';

/// Manages tag chips for a single note: assigned tags, autocomplete
/// suggestions from the user's existing tags, and create-new.
class NoteTagsViewModel extends ChangeNotifier {
  NoteTagsViewModel({
    required TagRepository repository,
    required String userId,
    required String noteId,
  })  : _repository = repository,
        _userId = userId,
        _noteId = noteId {
    _noteTagsSub = _repository.watchTagsForNote(_noteId).listen((tags) {
      noteTags = tags;
      notifyListeners();
    });
    _allTagsSub = _repository.watchAllTags(_userId).listen((tags) {
      allTags = tags;
      notifyListeners();
    });
  }

  final TagRepository _repository;
  final String _userId;
  final String _noteId;
  late final StreamSubscription<List<Tag>> _noteTagsSub;
  late final StreamSubscription<List<Tag>> _allTagsSub;

  List<Tag> noteTags = [];
  List<Tag> allTags = [];

  /// Existing tags matching [query] that aren't already on the note.
  List<Tag> suggestions(String query) {
    final q = query.trim().toLowerCase();
    final assigned = noteTags.map((t) => t.id).toSet();
    return allTags
        .where((t) => !assigned.contains(t.id) && (q.isEmpty || t.name.contains(q)))
        .toList();
  }

  Future<void> addTag(String name) async {
    if (name.trim().isEmpty) return;
    final tag = await _repository.createTag(userId: _userId, name: name);
    await _repository.addTagToNote(_noteId, tag.id);
  }

  Future<void> addExistingTag(Tag tag) =>
      _repository.addTagToNote(_noteId, tag.id);

  Future<void> removeTag(Tag tag) =>
      _repository.removeTagFromNote(_noteId, tag.id);

  @override
  void dispose() {
    _noteTagsSub.cancel();
    _allTagsSub.cancel();
    super.dispose();
  }
}
