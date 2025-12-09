import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/expenses/providers/expense_list_provider.dart';
import '../models/expense_category.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../shared/utils/formatters.dart';
import 'add_expense_screen.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/expense_details_sheet.dart';

class ExpenseListScreen extends ConsumerWidget {
  final String groupId;

  const ExpenseListScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId));

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expenses')),
        body: const Center(child: Text('Group not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          const _SortButton(),
          _CategoryBreakdownButton(groupId: groupId),
        ],
      ),
      body: Column(
        children: [
          const _SearchBar(),
          const _FilterChips(),
          _ResultsCount(groupId: groupId),
          const Divider(),
          _ExpenseListView(groupId: groupId),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(groupId: groupId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SortButton extends ConsumerWidget {
  const _SortButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortLatestFirst =
        ref.watch(expenseListFilterProvider).sortLatestFirst;
    return PopupMenuButton<bool>(
      icon: Icon(sortLatestFirst ? Icons.arrow_downward : Icons.arrow_upward),
      tooltip: 'Sort',
      onSelected: (value) => ref
          .read(expenseListFilterProvider.notifier)
          .setSortOrder(latestFirst: value),
      itemBuilder: (context) => [
        PopupMenuItem(
            value: true,
            child: Text('Latest First',
                style: TextStyle(color: sortLatestFirst ? Colors.blue : null))),
        PopupMenuItem(
            value: false,
            child: Text('Oldest First',
                style:
                    TextStyle(color: !sortLatestFirst ? Colors.blue : null))),
      ],
    );
  }
}

class _CategoryBreakdownButton extends ConsumerWidget {
  final String groupId;
  const _CategoryBreakdownButton({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.pie_chart),
      onPressed: () {
        final totals = ref.read(categoryTotalsProvider(groupId));
        final group = ref.read(selectedGroupProvider(groupId));
        showModalBottomSheet(
          context: context,
          builder: (context) => _CategoryBreakdown(
              categoryTotals: totals, currency: group!.currency),
        );
      },
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.watch(expenseListFilterProvider).searchQuery,
    );
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search expenses...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              ref.watch(expenseListFilterProvider).searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => ref
                          .read(expenseListFilterProvider.notifier)
                          .setSearchQuery(''))
                  : null,
        ),
        onChanged: (value) =>
            ref.read(expenseListFilterProvider.notifier).setSearchQuery(value),
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(expenseListFilterProvider);
    final notifier = ref.read(expenseListFilterProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: Text(filter.dateRange == null
                ? 'All Time'
                : '${DateFormatter.formatShort(filter.dateRange!.start)} - ${DateFormatter.formatShort(filter.dateRange!.end)}'),
            selected: filter.dateRange != null,
            onSelected: (_) async {
              final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now());
              if (picked != null) notifier.setDateRange(picked);
            },
            onDeleted: filter.dateRange != null
                ? () => notifier.setDateRange(null)
                : null,
          ),
          ...ExpenseCategory.values.map((category) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: FilterChip(
                  label: Text(category.displayName),
                  selected: filter.category == category,
                  onSelected: (selected) =>
                      notifier.setCategory(selected ? category : null),
                ),
              )),
        ],
      ),
    );
  }
}

class _ResultsCount extends ConsumerWidget {
  final String groupId;
  const _ResultsCount({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(filteredExpensesProvider(groupId));
    final group = ref.watch(selectedGroupProvider(groupId));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${expenses.length} expenses'),
          Text(
              'Total: ${CurrencyFormatter.format(expenses.fold(0.0, (sum, t) => sum + t.totalAmount), currencyCode: group!.currency)}'),
        ],
      ),
    );
  }
}

class _ExpenseListView extends ConsumerWidget {
  final String groupId;
  const _ExpenseListView({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(filteredExpensesProvider(groupId));
    final users = ref.watch(usersProvider);
    final group = ref.watch(selectedGroupProvider(groupId));

    return Expanded(
      child: expenses.isEmpty
          ? const Center(child: Text('No expenses found'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final transaction = expenses[index];
                return TransactionTile(
                  transaction: transaction,
                  users: users,
                  currency: group!.currency,
                  onTap: () => showExpenseDetailsSheet(
                    context: context,
                    transaction: transaction,
                    users: users,
                    currency: group.currency,
                  ),
                );
              },
            ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;
  final String currency;

  const _CategoryBreakdown(
      {required this.categoryTotals, required this.currency});

  @override
  Widget build(BuildContext context) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total =
        categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Category Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...sortedCategories.map((entry) {
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            return Row(
              children: [
                Icon(entry.key.icon),
                Expanded(child: Text(entry.key.displayName)),
                Text(CurrencyFormatter.format(entry.value,
                    currencyCode: currency)),
                Text('$percentage%'),
              ],
            );
          }),
        ],
      ),
    );
  }
}
