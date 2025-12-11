import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/groups_provider.dart';
import '../providers/users_provider.dart';
import '../providers/group_detail_provider.dart';
import '../../expenses/providers/transactions_provider.dart';
import '../../expenses/models/expense_category.dart';
import '../../../shared/ui/buttons/settle_up_button.dart';
import '../../../shared/utils/formatters.dart';
import '../../expenses/screens/expense_list_screen.dart';
import '../../expenses/screens/group_insights_screen.dart';
import '../../expenses/screens/admin_debt_view_screen.dart';
import '../../expenses/widgets/add_expense_entry.dart';
import 'group_settings_screen.dart';

class GroupDetailScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId));

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group')),
        body: const Center(child: Text('Group not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          _AppBarActions(groupId: groupId),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GroupStatsCard(groupId: groupId),
          const SizedBox(height: 16),
          _BalancesSection(groupId: groupId),
          const SizedBox(height: 16),
          _RecentTransactions(groupId: groupId),
        ],
      ),
      floatingActionButton: _FloatingActionButtons(groupId: groupId),
    );
  }
}

class _AppBarActions extends ConsumerWidget {
  final String groupId;

  const _AppBarActions({required this.groupId});

  void _shareGroupSummary(BuildContext context, WidgetRef ref) {
    final logic = ref.read(groupDetailScreenLogicProvider);
    final summaryText = logic.generateGroupSummaryText(groupId);
    final group = ref.read(selectedGroupProvider(groupId));
    final users = ref.read(usersProvider);
    final members =
        users.where((u) => group!.memberIds.contains(u.id)).toList();
    final membersWithPhone = members
        .where((m) => m.phoneNumber != null && m.phoneNumber!.isNotEmpty)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Group Summary'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(summaryText),
              if (membersWithPhone.isNotEmpty) ...[
                const Divider(),
                ...membersWithPhone.map(
                  (member) => OutlinedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: Text(member.name),
                    onPressed: () async {
                      final cleanPhone =
                          member.phoneNumber!.replaceAll(RegExp(r'\D'), '');
                      final encodedMessage = Uri.encodeComponent(summaryText);
                      final url =
                          'https://wa.me/$cleanPhone?text=$encodedMessage';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: summaryText));
              Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
    // End of share dialog
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceOwner = ref.watch(deviceOwnerProvider);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () => _shareGroupSummary(context, ref),
        ),
        IconButton(
          icon: const Icon(Icons.insights),
          tooltip: 'Insights',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupInsightsScreen(groupId: groupId),
            ),
          ),
        ),
        if (deviceOwner != null && deviceOwner.isDeviceOwner)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Report',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminDebtViewScreen(groupId: groupId),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () {
            final group = ref.read(selectedGroupProvider(groupId));
            if (group != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupSettingsScreen(group: group),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _GroupStatsCard extends ConsumerWidget {
  final String groupId;

  const _GroupStatsCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId))!;
    final totalSpend = ref.watch(groupTotalSpendProvider(groupId));
    final members =
        ref.watch(usersProvider).where((u) => group.memberIds.contains(u.id));
    final deviceOwner = ref.watch(deviceOwnerProvider);
    final netBalances = ref.watch(groupNetBalancesProvider(groupId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Group Spend:'),
                Text(
                  CurrencyFormatter.format(
                    totalSpend,
                    currencyCode: group.currency,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Members:'),
                Text('${members.length}'),
              ],
            ),
            if (deviceOwner != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Balance:'),
                  Text(
                    CurrencyFormatter.format(
                      (netBalances[deviceOwner.id] ?? 0.0).abs(),
                      currencyCode: group.currency,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: (netBalances[deviceOwner.id] ?? 0.0) > 0
                          ? Colors.green
                          : (netBalances[deviceOwner.id] ?? 0.0) < 0
                              ? Colors.red
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                (netBalances[deviceOwner.id] ?? 0.0) > 0
                    ? 'You are owed'
                    : (netBalances[deviceOwner.id] ?? 0.0) < 0
                        ? 'You owe'
                        : 'You are settled up',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Removed per UX request: leave action should live in Group Settings

class _BalancesSection extends ConsumerWidget {
  final String groupId;

  const _BalancesSection({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId))!;
    final netBalances = ref.watch(groupNetBalancesProvider(groupId));
    final members =
        ref.watch(usersProvider).where((u) => group.memberIds.contains(u.id));
    final showSimplifiedDebts = ref.watch(showSimplifiedDebtsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balances',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      showSimplifiedDebts ? 'Simplified' : 'Actual',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Switch(
                      value: showSimplifiedDebts,
                      onChanged: (_) => ref
                          .read(showSimplifiedDebtsProvider.notifier)
                          .toggle(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...members.map((member) {
              final balance = netBalances[member.id] ?? 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        member.isDeviceOwner
                            ? '${member.name} (You)'
                            : member.name,
                      ),
                    ),
                    Text(
                      balance > 0
                          ? '+${CurrencyFormatter.format(balance, currencyCode: group.currency)}'
                          : balance < 0
                              ? CurrencyFormatter.format(
                                  balance,
                                  currencyCode: group.currency,
                                )
                              : 'Settled',
                      style: TextStyle(
                        color: balance > 0
                            ? Colors.green
                            : balance < 0
                                ? Colors.red
                                : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactions extends ConsumerWidget {
  final String groupId;

  const _RecentTransactions({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId))!;
    final transactions = ref.watch(groupTransactionsProvider(groupId));
    final users = ref.watch(usersProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExpenseListScreen(groupId: groupId),
                    ),
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...transactions.take(5).map((transaction) {
                final payer = users.firstWhere(
                  (u) => transaction.payers.keys.first == u.id,
                  orElse: () => users.first,
                );
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: transaction.type.name == 'expense'
                        ? transaction.category.color.withValues(alpha: 0.8)
                        : Colors.green,
                    child: Icon(
                      transaction.type.name == 'expense'
                          ? transaction.category.icon
                          : Icons.payments,
                      color: Colors.white,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(transaction.description)),
                      if (transaction.isRecurring)
                        const Icon(Icons.repeat, size: 16, color: Colors.blue),
                    ],
                  ),
                  subtitle: Text(
                    '${payer.name} • ${transaction.category.displayName} • ${DateFormatter.formatRelative(transaction.timestamp)}',
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(
                      transaction.totalAmount,
                      currencyCode: group.currency,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _FloatingActionButtons extends StatelessWidget {
  final String groupId;

  const _FloatingActionButtons({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SettleUpButton(
          groupId: groupId,
          heroTag: 'settle',
        ),
        const SizedBox(height: 12),
        AddExpenseEntry(
          groupId: groupId,
          heroTag: 'expense',
        ),
      ],
    );
  }
}
