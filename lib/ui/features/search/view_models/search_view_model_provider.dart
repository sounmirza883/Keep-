import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/providers.dart';
import 'search_view_model.dart';

part 'search_view_model_provider.g.dart';

@riverpod
SearchViewModel searchViewModel(Ref ref) {
  final vm = SearchViewModel(
    searchUseCase: ref.watch(smartSearchUseCaseProvider),
    userId: ref.watch(currentUserIdProvider) ?? '',
  );
  ref.onDispose(vm.dispose);
  return vm;
}
