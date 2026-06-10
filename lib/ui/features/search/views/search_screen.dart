import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/search_view_model_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(searchViewModelProvider);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.go('/notes')),
            title: TextField(
              autofocus: true,
              onChanged: vm.onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'Search notes…',
                border: InputBorder.none,
              ),
            ),
          ),
          body: switch ((vm.isSearching, vm.error, vm.results.isEmpty)) {
            (true, _, _) => const Center(child: CircularProgressIndicator()),
            (_, final String error, _) => Center(child: Text(error)),
            (_, _, true) => const Center(child: Text('No results')),
            _ => ListView.builder(
                itemCount: vm.results.length,
                itemBuilder: (context, index) {
                  final note = vm.results[index];
                  return ListTile(
                    title: Text(note.title.isEmpty ? 'Untitled' : note.title),
                    subtitle: note.content.isEmpty
                        ? null
                        : Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: () => context.go('/notes/${note.id}/edit'),
                  );
                },
              ),
          },
        );
      },
    );
  }
}
