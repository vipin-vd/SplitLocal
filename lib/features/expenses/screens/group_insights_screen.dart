import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_category.dart';
import '../providers/transactions_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../shared/providers/services_provider.dart';
import '../../../shared/utils/formatters.dart';

class GroupInsightsScreen extends ConsumerWidget {
  final String groupId;

  const GroupInsightsScreen({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId));
    final categorySpending = ref.watch(groupCategorySpendingProvider(groupId));
    final totalSpend = ref.watch(groupTotalSpendProvider(groupId));
    final recurringExpenses = ref.watch(recurringExpensesProvider(groupId));
    final deviceOwner = ref.watch(deviceOwnerProvider);
    final transactions = ref.watch(groupTransactionsProvider(groupId));
    final debtCalculator = ref.watch(debtCalculatorServiceProvider);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insights')),
        body: const Center(child: Text('Group not found')),
      );
    }

    // Calculate user's personal stats
    final userTotalPaid = deviceOwner != null 
        ? debtCalculator.getUserTotalPaid(deviceOwner.id, transactions)
        : 0.0;
    final userTotalShare = deviceOwner != null
        ? debtCalculator.getUserTotalShare(deviceOwner.id, transactions)
        : 0.0;
    final netBalances = ref.watch(groupNetBalancesProvider(groupId));
    final userBalance = deviceOwner != null
        ? (netBalances[deviceOwner.id] ?? 0.0)
        : 0.0;

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insights')),
        body: const Center(child: Text('Group not found')),
      );
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Insights'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User's Personal Stats
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Your Stats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You Paid',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(userTotalPaid, currencyCode: group.currency),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Share',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(userTotalShare, currencyCode: group.currency),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: userBalance > 0
                          ? Colors.green.shade50
                          : userBalance < 0
                              ? Colors.red.shade50
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: userBalance > 0
                            ? Colors.green.shade200
                            : userBalance < 0
                                ? Colors.red.shade200
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userBalance > 0
                              ? 'You are owed'
                              : userBalance < 0
                                  ? 'You owe'
                                  : 'You are settled up',
                          style: TextStyle(
                            color: userBalance > 0
                                ? Colors.green.shade700
                                : userBalance < 0
                                    ? Colors.red.shade700
                                    : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (userBalance != 0)
                          Text(
                            CurrencyFormatter.format(userBalance.abs(), currencyCode: group.currency),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: userBalance > 0
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Total Spending Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Total Group Spending',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(totalSpend, currencyCode: group.currency),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spending by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (sortedCategories.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No expenses yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...sortedCategories.map((entry) {
                      final percentage = totalSpend > 0
                          ? (entry.value / totalSpend * 100).toStringAsFixed(1)
                          : '0.0';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: entry.key.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    entry.key.icon,
                                    color: entry.key.color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.key.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(
                                        entry.value,
                                        currencyCode: group.currency,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$percentage%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: totalSpend > 0 ? entry.value / totalSpend : 0,
                                backgroundColor: Colors.grey.shade200,
                                color: entry.key.color,
                                minHeight: 8,
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

          // Recurring Expenses
          if (recurringExpenses.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.repeat, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Recurring Expenses',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...recurringExpenses.map((expense) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: expense.category.color.withOpacity(0.2),
                          child: Icon(
                            expense.category.icon,
                            color: expense.category.color,
                          ),
                        ),
                        title: Text(expense.description),
                        subtitle: Text(
                          '${expense.recurringFrequency?.toUpperCase() ?? 'Regular'} • ${expense.category.displayName}',
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(
                            expense.totalAmount,
                            currencyCode: group.currency,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Top Categories
          if (sortedCategories.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Stats',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'Top Category',
                      sortedCategories.first.key.displayName,
                      sortedCategories.first.key.icon,
                      sortedCategories.first.key.color,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      'Total Categories',
                      '${categorySpending.length}',
                      Icons.category,
                      Colors.blue,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      'Recurring Expenses',
                      '${recurringExpenses.length}',
                      Icons.repeat,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
