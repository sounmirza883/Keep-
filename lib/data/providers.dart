import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/use_cases/auto_tag_use_case.dart';
import '../domain/use_cases/smart_search_use_case.dart';
import '../domain/use_cases/summarize_note_use_case.dart';
import 'repositories/attachment_repository.dart';
import 'repositories/note_repository.dart';
import 'repositories/tag_repository.dart';
import 'repositories/task_repository.dart';
import 'services/native_ai_service.dart';
import 'services/powersync_service.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
SlateDatabase slateDb(Ref ref) {
  throw UnimplementedError('slateDbProvider must be overridden in main.dart');
}

@Riverpod(keepAlive: true)
SupabaseClient supabase(Ref ref) => Supabase.instance.client;

@Riverpod(keepAlive: true)
NativeAiService nativeAi(Ref ref) => NativeAiService();

/// Emits the current Supabase auth state, used by the router redirect logic.
@Riverpod(keepAlive: true)
Stream<AuthState> authStateChanges(Ref ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
}

/// Current authenticated user id, or null when signed out.
@riverpod
String? currentUserId(Ref ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(supabaseProvider).auth.currentUser?.id;
}

@riverpod
NoteRepository noteRepository(Ref ref) =>
    NoteRepository(ref.watch(slateDbProvider));

@riverpod
TaskRepository taskRepository(Ref ref) =>
    TaskRepository(ref.watch(slateDbProvider));

@riverpod
TagRepository tagRepository(Ref ref) =>
    TagRepository(ref.watch(slateDbProvider));

@riverpod
AttachmentRepository attachmentRepository(Ref ref) => AttachmentRepository(
      db: ref.watch(slateDbProvider),
      supabase: ref.watch(supabaseProvider),
    );

@riverpod
SummarizeNoteUseCase summarizeNoteUseCase(Ref ref) =>
    SummarizeNoteUseCase(ref.watch(nativeAiProvider));

@riverpod
AutoTagUseCase autoTagUseCase(Ref ref) =>
    AutoTagUseCase(ref.watch(nativeAiProvider));

@riverpod
SmartSearchUseCase smartSearchUseCase(Ref ref) => SmartSearchUseCase(
      notes: ref.watch(noteRepositoryProvider),
      ai: ref.watch(nativeAiProvider),
    );

/// Whether on-device AI is available on this hardware (cached per app run).
@Riverpod(keepAlive: true)
Future<bool> aiAvailable(Ref ref) => ref.watch(nativeAiProvider).isAvailable;
