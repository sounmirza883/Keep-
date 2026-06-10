import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/providers.dart';
import 'auth_view_model.dart';

part 'auth_view_model_provider.g.dart';

@riverpod
AuthViewModel authViewModel(Ref ref) {
  return AuthViewModel(ref.watch(supabaseProvider));
}
