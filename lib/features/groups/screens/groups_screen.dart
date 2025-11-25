import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/groups_provider.dart';
import '../providers/users_provider.dart';
import '../../../shared/utils/formatters.dart';
import '../../expenses/providers/transactions_provider.dart';
import '../../settings/screens/backup_restore_screen.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final deviceOwner = ref.watch(deviceOwnerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Backup & Restore',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BackupRestoreScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: groups.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.group_add,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No groups yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first group to start tracking expenses',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final totalSpend = ref.watch(groupTotalSpendProvider(group.id));
                final netBalances = ref.watch(groupNetBalancesProvider(group.id));
                final myBalance = deviceOwner != null
                    ? netBalances[deviceOwner.id] ?? 0.0
                    : 0.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF6C63FF),
                      child: Text(
                        group.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${group.memberIds.length} members'),
                        Text(
                          'Total spend: ${CurrencyFormatter.format(totalSpend, currencyCode: group.currency)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          myBalance > 0 ? 'You\'re owed' : 'You owe',
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          CurrencyFormatter.format(myBalance.abs(), currencyCode: group.currency),
                          style: TextStyle(
                            color: myBalance > 0
                                ? Colors.green
                                : myBalance < 0
                                    ? Colors.red
                                    : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDetailScreen(groupId: group.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
