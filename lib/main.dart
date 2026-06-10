import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env.dart';
import 'data/providers.dart';
import 'data/services/powersync_service.dart';
import 'router.dart';
import 'ui/core/slate_theme.dart';

// Passed at build time: flutter build --dart-define=SENTRY_DSN=...
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

Future<void> main() async {
  if (_sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;
        options.tracesSampleRate = 0.2;
      },
      appRunner: _run,
    );
  } else {
    await _run();
  }
}

Future<void> _run() async {
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
      builder: (context, child) {
        // Desktop/web keyboard shortcuts. Cmd on macOS, Ctrl elsewhere —
        // both registered so the same build works everywhere.
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyK, control: true):
                () => router.go('/search'),
            const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
                () => router.go('/search'),
            const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                () => router.go('/notes'),
            const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
                () => router.go('/notes'),
          },
          child: Focus(autofocus: true, child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
