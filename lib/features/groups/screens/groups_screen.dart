import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/groups/models/group.dart';
import '../providers/groups_provider.dart';
import '../providers/users_provider.dart';
import '../providers/group_filter_provider.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/app_bar_search.dart';
import '../../expenses/providers/transactions_provider.dart';
import '../../expenses/widgets/add_expense_target_selector.dart';
import '../../settings/screens/backup_restore_screen.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import '../../../shared/providers/net_totals_provider.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGroups = ref.watch(groupsProvider);
    final filter = ref.watch(groupListFilterProvider);

    // Filter out friend groups and apply search query
    final groups = allGroups.where((g) {
      if (g.isFriendGroup) return false;
      if (filter.searchQuery.isNotEmpty &&
          !g.name.toLowerCase().contains(filter.searchQuery)) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: AppBarSearch<GroupListFilter>(
          getNotifier: (ref) => ref.read(groupListFilterProvider.notifier),
          queryProvider: groupListFilterProvider.select((s) => s.searchQuery),
          hintText: 'Search groups...',
          semanticsLabel: 'Search groups',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Expense',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: false,
              builder: (context) => const AddExpenseTargetSelector(
                defaultTab: ExpenseTargetTab.groups,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Backup & Restore',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BackupRestoreScreen())),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(64),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _GroupsTotalsSummary(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: groups.isEmpty
                ? (filter.searchQuery.isEmpty
                    ? const _EmptyGroupsView()
                    : const Center(child: Text('No groups found')))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groups.length,
                    itemBuilder: (context, index) =>
                        _GroupListItem(group: groups[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GroupsTotalsSummary extends ConsumerWidget {
  const _GroupsTotalsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final net = ref.watch(netBalanceGlobalProvider);
    final owedToUser = ref.watch(totalOwedToUserGlobalProvider);
    final userOwes = ref.watch(totalUserOwesGlobalProvider);

    Color netColor;
    if (net.abs() < 0.01) {
      netColor = scheme.onSurfaceVariant;
    } else {
      netColor = net > 0 ? Colors.green : Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TotalItem(
              label: 'Net',
              value: CurrencyFormatter.format(net),
              color: netColor,
              semanticsLabel: 'Overall group balance',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TotalItem(
              label: "You're owed",
              value: CurrencyFormatter.format(owedToUser),
              color: owedToUser > 0.01 ? Colors.green : scheme.onSurfaceVariant,
              semanticsLabel: "You're owed across groups",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TotalItem(
              label: 'You owe',
              value: CurrencyFormatter.format(userOwes),
              color: userOwes > 0.01 ? Colors.red : scheme.onSurfaceVariant,
              semanticsLabel: 'You owe across groups',
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({
    required this.label,
    required this.value,
    required this.color,
    required this.semanticsLabel,
  });

  final String label;
  final String value;
  final Color color;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroupsView extends StatelessWidget {
  const _EmptyGroupsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_add, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No groups yet',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Create your first group to start tracking expenses',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _GroupListItem extends ConsumerWidget {
  final Group group;

  const _GroupListItem({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSpend = ref.watch(groupTotalSpendProvider(group.id));
    final netBalances = ref.watch(groupNetBalancesProvider(group.id));
    final deviceOwner = ref.watch(deviceOwnerProvider);
    final myBalance =
        deviceOwner != null ? netBalances[deviceOwner.id] ?? 0.0 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6C63FF),
          child: Text(group.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(group.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${group.memberIds.length} members'),
            Text(
                'Total spend: ${CurrencyFormatter.format(totalSpend, currencyCode: group.currency)}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(myBalance > 0 ? 'You\'re owed' : 'You owe',
                style: const TextStyle(fontSize: 11)),
            Text(
              CurrencyFormatter.format(myBalance.abs(),
                  currencyCode: group.currency),
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
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => GroupDetailScreen(groupId: group.id))),
      ),
    );
  }
}
