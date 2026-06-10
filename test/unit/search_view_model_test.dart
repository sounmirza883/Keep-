import 'package:flutter_test/flutter_test.dart';
import 'package:slate/data/models/note.dart';
import 'package:slate/domain/use_cases/smart_search_use_case.dart';
import 'package:slate/ui/features/search/view_models/search_view_model.dart';

class FakeSmartSearch implements SmartSearchUseCase {
  int calls = 0;
  String? lastQuery;

  @override
  Future<List<Note>> call(String userId, String query) async {
    calls++;
    lastQuery = query;
    return [
      Note(
        id: 'n1',
        userId: userId,
        title: 'Match for $query',
        content: '',
        contentType: 'markdown',
        isPinned: false,
        isDeleted: false,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  test('debounces rapid keystrokes into a single search', () async {
    final search = FakeSmartSearch();
    final vm = SearchViewModel(searchUseCase: search, userId: 'u1');

    vm.onQueryChanged('f');
    vm.onQueryChanged('fl');
    vm.onQueryChanged('flutter');
    expect(vm.isSearching, true);

    await Future<void>.delayed(SearchViewModel.debounce * 2);

    expect(search.calls, 1);
    expect(search.lastQuery, 'flutter');
    expect(vm.results.single.title, 'Match for flutter');
    expect(vm.isSearching, false);
    vm.dispose();
  });

  test('empty query clears results without searching', () async {
    final search = FakeSmartSearch();
    final vm = SearchViewModel(searchUseCase: search, userId: 'u1');

    vm.onQueryChanged('flutter');
    await Future<void>.delayed(SearchViewModel.debounce * 2);
    expect(vm.results, isNotEmpty);

    vm.onQueryChanged('');
    expect(vm.results, isEmpty);
    expect(vm.isSearching, false);
    expect(search.calls, 1);
    vm.dispose();
  });
}
