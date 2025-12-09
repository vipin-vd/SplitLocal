import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/expenses/providers/group_insights_provider.dart';
import '../models/expense_category.dart';
import '../providers/transactions_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../shared/utils/formatters.dart';

class GroupInsightsScreen extends ConsumerWidget {
  final String groupId;

  const GroupInsightsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId));
    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insights')),
        body: const Center(child: Text('Group not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _UserStatsCard(groupId: groupId),
          const SizedBox(height: 16),
          _TotalSpendingCard(groupId: groupId),
          const SizedBox(height: 16),
          _CategoryBreakdownCard(groupId: groupId),
          const SizedBox(height: 16),
          _RecurringExpensesCard(groupId: groupId),
          const SizedBox(height: 16),
          _QuickStatsCard(groupId: groupId),
        ],
      ),
    );
  }
}

class _UserStatsCard extends ConsumerWidget {
  final String groupId;
  const _UserStatsCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId))!;
    final userTotalPaid = ref.watch(userTotalPaidProvider(groupId));
    final userTotalShare = ref.watch(userTotalShareProvider(groupId));
    final netBalances = ref.watch(groupNetBalancesProvider(groupId));
    final deviceOwner = ref.watch(deviceOwnerProvider);
    final userBalance =
        deviceOwner != null ? (netBalances[deviceOwner.id] ?? 0.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _StatItem(
                        label: 'You Paid',
                        value: userTotalPaid,
                        currency: group.currency)),
                Expanded(
                    child: _StatItem(
                        label: 'Your Share',
                        value: userTotalShare,
                        currency: group.currency)),
              ],
            ),
            const SizedBox(height: 16),
            _BalanceIndicator(balance: userBalance, currency: group.currency),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double value;
  final String currency;
  const _StatItem(
      {required this.label, required this.value, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(CurrencyFormatter.format(value, currencyCode: currency),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _BalanceIndicator extends StatelessWidget {
  final double balance;
  final String currency;
  const _BalanceIndicator({required this.balance, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: balance > 0
            ? Colors.green.shade50
            : balance < 0
                ? Colors.red.shade50
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(balance > 0
              ? 'You are owed'
              : balance < 0
                  ? 'You owe'
                  : 'You are settled up'),
          if (balance != 0)
            Text(
                CurrencyFormatter.format(balance.abs(), currencyCode: currency),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: balance > 0 ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}

class _TotalSpendingCard extends ConsumerWidget {
  final String groupId;
  const _TotalSpendingCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSpend = ref.watch(groupTotalSpendProvider(groupId));
    final group = ref.watch(selectedGroupProvider(groupId))!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Total Group Spending',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
                CurrencyFormatter.format(totalSpend,
                    currencyCode: group.currency),
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdownCard extends ConsumerWidget {
  final String groupId;
  const _CategoryBreakdownCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySpending = ref.watch(groupCategorySpendingProvider(groupId));
    final totalSpend = ref.watch(groupTotalSpendProvider(groupId));
    final group = ref.watch(selectedGroupProvider(groupId))!;
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spending by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (sortedCategories.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No expenses yet',
                          style: TextStyle(color: Colors.grey))))
            else
              ...sortedCategories.map((entry) {
                final percentage = totalSpend > 0
                    ? (entry.value / totalSpend * 100).toStringAsFixed(1)
                    : '0.0';
                return _CategorySpendItem(
                  category: entry.key,
                  value: entry.value,
                  percentage: percentage,
                  currency: group.currency,
                  totalSpend: totalSpend,
                );
              })
          ],
        ),
      ),
    );
  }
}

class _CategorySpendItem extends StatelessWidget {
  final ExpenseCategory category;
  final double value;
  final String percentage;
  final String currency;
  final double totalSpend;

  const _CategorySpendItem(
      {required this.category,
      required this.value,
      required this.percentage,
      required this.currency,
      required this.totalSpend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(category.icon, color: category.color),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(category.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.format(value, currencyCode: currency),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('$percentage%',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: totalSpend > 0 ? value / totalSpend : 0,
              color: category.color),
        ],
      ),
    );
  }
}

class _RecurringExpensesCard extends ConsumerWidget {
  final String groupId;
  const _RecurringExpensesCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringExpenses = ref.watch(recurringExpensesProvider(groupId));
    final group = ref.watch(selectedGroupProvider(groupId))!;

    return recurringExpenses.isEmpty
        ? const SizedBox.shrink()
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recurring Expenses',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...recurringExpenses.map((expense) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            CircleAvatar(child: Icon(expense.category.icon)),
                        title: Text(expense.description),
                        subtitle: Text(
                            '${expense.recurringFrequency?.toUpperCase() ?? 'Regular'} • ${expense.category.displayName}'),
                        trailing: Text(
                            CurrencyFormatter.format(expense.totalAmount,
                                currencyCode: group.currency),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      )),
                ],
              ),
            ),
          );
  }
}

class _QuickStatsCard extends ConsumerWidget {
  final String groupId;
  const _QuickStatsCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySpending = ref.watch(groupCategorySpendingProvider(groupId));
    final recurringExpenses = ref.watch(recurringExpensesProvider(groupId));
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCategories.isEmpty
        ? const SizedBox.shrink()
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Stats',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatRow(
                      'Top Category',
                      sortedCategories.first.key.displayName,
                      sortedCategories.first.key.icon,
                      sortedCategories.first.key.color),
                  const Divider(height: 24),
                  _buildStatRow(
                      'Total Categories',
                      '${categorySpending.length}',
                      Icons.category,
                      Colors.blue),
                  const Divider(height: 24),
                  _buildStatRow(
                      'Recurring Expenses',
                      '${recurringExpenses.length}',
                      Icons.repeat,
                      Colors.green),
                ],
              ),
            ),
          );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }
}
