import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/providers.dart';
import '../../auth/view_models/auth_view_model_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(supabaseProvider).auth.currentUser;
    final aiAvailable = ref.watch(aiAvailableProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/notes')),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Account'),
            subtitle: Text(user?.email ?? 'Not signed in'),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('On-device AI'),
            subtitle: Text(aiAvailable
                ? 'Available — summaries and auto-tagging run locally'
                : 'Not available on this device'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              await ref.read(authViewModelProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'Slate',
            applicationVersion: '0.1.0',
            aboutBoxChildren: [
              Text('Offline-first workspace. Your data syncs privately; '
                  'AI runs entirely on your device.'),
            ],
          ),
        ],
      ),
    );
  }
}
