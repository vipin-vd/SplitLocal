import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceOwner = ref.watch(deviceOwnerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (deviceOwner != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(deviceOwner.name),
              subtitle: Text(deviceOwner.phoneNumber ?? 'No phone number'),
            ),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Notification Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SwitchListTile(
            // TODO: Make it look disabled for now
            title: Text('Mobile Notifications'),
            value: false, // This will be managed by a provider later
            onChanged: null,
          ),
          const SwitchListTile(
            title: Text('Email Notifications'),
            value: false, // This will be managed by a provider later
            onChanged: null,
          ),
          Text('Notifications feature coming soon!',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),),
        ],
      ),
    );
  }
}
