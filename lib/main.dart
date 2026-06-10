import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env.dart';
import 'data/providers.dart';
import 'data/services/powersync_service.dart';
import 'router.dart';
import 'ui/core/slate_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  final db = SlateDatabase();
  await db.initialize();

  // Connect in background; offline-first means the app must not block on this.
  final connector = SupabasePowerSyncConnector(Supabase.instance.client);
  db.connect(connector: connector);

  runApp(
    ProviderScope(
      overrides: [
        slateDbProvider.overrideWithValue(db),
      ],
      child: const SlateApp(),
    ),
  );
}

class SlateApp extends ConsumerWidget {
  const SlateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Slate',
      theme: SlateTheme.light,
      darkTheme: SlateTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
