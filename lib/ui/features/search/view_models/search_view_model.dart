import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/models/note.dart';
import '../../../../domain/use_cases/smart_search_use_case.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required SmartSearchUseCase searchUseCase,
    required String userId,
  })  : _search = searchUseCase,
        _userId = userId;

  final SmartSearchUseCase _search;
  final String _userId;

  static const debounce = Duration(milliseconds: 300);

  List<Note> results = [];
  bool isSearching = false;
  String? error;
  String _query = '';
  Timer? _debounceTimer;
  int _searchEpoch = 0;

  void onQueryChanged(String query) {
    _query = query;
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      results = [];
      isSearching = false;
      notifyListeners();
      return;
    }
    isSearching = true;
    notifyListeners();
    _debounceTimer = Timer(debounce, _runSearch);
  }

  Future<void> _runSearch() async {
    final epoch = ++_searchEpoch;
    try {
      final found = await _search(_userId, _query.trim());
      if (epoch != _searchEpoch) return; // stale response, a newer search ran
      results = found;
      error = null;
    } catch (e) {
      if (epoch != _searchEpoch) return;
      error = e.toString();
    }
    isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
