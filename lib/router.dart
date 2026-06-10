import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/providers.dart';
import 'ui/features/auth/views/login_screen.dart';
import 'ui/features/auth/views/magic_link_screen.dart';
import 'ui/features/auth/views/register_screen.dart';
import 'ui/features/notes/views/note_editor_screen.dart';
import 'ui/features/notes/views/note_list_screen.dart';
import 'ui/features/tasks/views/task_board_screen.dart';
import 'ui/features/tasks/views/task_form_screen.dart';
import 'ui/features/tasks/views/task_list_screen.dart';

part 'router.g.dart';

const _authRoutes = {'/login', '/register', '/magic-link'};

@riverpod
GoRouter router(Ref ref) {
  final supabase = ref.watch(supabaseProvider);

  return GoRouter(
    initialLocation: '/notes',
    refreshListenable: _AuthRefreshNotifier(supabase.auth.onAuthStateChange),
    redirect: (context, state) {
      final loggedIn = supabase.auth.currentSession != null;
      final onAuthRoute = _authRoutes.contains(state.matchedLocation);

      if (!loggedIn && !onAuthRoute) return '/login';
      if (loggedIn && onAuthRoute) return '/notes';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/magic-link', builder: (_, __) => const MagicLinkScreen()),
      GoRoute(path: '/notes', builder: (_, __) => const NoteListScreen()),
      GoRoute(
        path: '/notes/:noteId/edit',
        builder: (_, state) =>
            NoteEditorScreen(noteId: state.pathParameters['noteId']!),
      ),
      GoRoute(path: '/tasks', builder: (_, __) => const TaskListScreen()),
      GoRoute(path: '/tasks/board', builder: (_, __) => const TaskBoardScreen()),
      GoRoute(path: '/tasks/new', builder: (_, __) => const TaskFormScreen()),
      GoRoute(
        path: '/tasks/:taskId/edit',
        builder: (_, state) =>
            TaskFormScreen(taskId: state.pathParameters['taskId']),
      ),
    ],
  );
}

/// Re-evaluates router redirects whenever Supabase auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<AuthState> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
