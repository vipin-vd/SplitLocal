import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/groups_provider.dart';
import '../providers/users_provider.dart';
import '../../expenses/providers/transactions_provider.dart';
import '../../expenses/models/expense_category.dart';
import '../../../shared/utils/formatters.dart';
import '../../expenses/screens/add_expense_screen.dart';
import '../../expenses/screens/settle_up_screen.dart';
import '../../expenses/screens/expense_list_screen.dart';
import '../../expenses/screens/group_insights_screen.dart';
import 'group_settings_screen.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  bool _showSimplifiedDebts = false;

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider(widget.groupId));
    final transactions = ref.watch(groupTransactionsProvider(widget.groupId));
    final netBalances = ref.watch(groupNetBalancesProvider(widget.groupId));
    final totalSpend = ref.watch(groupTotalSpendProvider(widget.groupId));
    final users = ref.watch(usersProvider);
    final deviceOwner = ref.watch(deviceOwnerProvider);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group')),
        body: const Center(child: Text('Group not found')),
      );
    }

    final members = users.where((u) => group.memberIds.contains(u.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'Insights',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupInsightsScreen(groupId: widget.groupId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsScreen(group: group),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share group summary
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Group Stats Card
          Card(
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
                        CurrencyFormatter.format(totalSpend, currencyCode: group.currency),
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
          ),
          const SizedBox(height: 16),

          // Balances Section
          Card(
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _showSimplifiedDebts ? 'Simplified' : 'Actual',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Switch(
                            value: _showSimplifiedDebts,
                            onChanged: (value) {
                              setState(() {
                                _showSimplifiedDebts = value;
                              });
                            },
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
                                    ? CurrencyFormatter.format(balance, currencyCode: group.currency)
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
          ),
          const SizedBox(height: 16),

          // Recent Transactions
          Card(
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExpenseListScreen(groupId: widget.groupId),
                            ),
                          );
                        },
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
                              ? transaction.category.color.withOpacity(0.8)
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
                              const Icon(
                                Icons.repeat,
                                size: 16,
                                color: Colors.blue,
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${payer.name} • ${transaction.category.displayName} • ${DateFormatter.formatRelative(transaction.timestamp)}',
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(transaction.totalAmount, currencyCode: group.currency),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'settle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettleUpScreen(groupId: widget.groupId),
                ),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.payments),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'expense',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(groupId: widget.groupId),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
