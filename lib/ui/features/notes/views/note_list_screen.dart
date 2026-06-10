import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/view_models/auth_view_model_provider.dart';

/// Phase 1 shell — notes CRUD lands in Phase 2.
class NoteListScreen extends ConsumerWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authViewModelProvider).signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 64),
            SizedBox(height: 16),
            Text('No notes yet'),
            SizedBox(height: 8),
            Text('Tap + to create your first note'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Note editor ships in Phase 2.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note editor coming in Phase 2')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
