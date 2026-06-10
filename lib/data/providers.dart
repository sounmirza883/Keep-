import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
