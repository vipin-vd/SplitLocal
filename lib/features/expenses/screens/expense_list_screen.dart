import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_category.dart';
import '../models/transaction.dart';
import '../providers/transactions_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../shared/utils/formatters.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  final String groupId;

  const ExpenseListScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  ExpenseCategory? _selectedCategory;
  String _searchQuery = '';
  DateTimeRange? _dateRange;
  bool _sortLatestFirst = true; // true = latest first, false = oldest first

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider(widget.groupId));
    final allTransactions = ref.watch(groupTransactionsProvider(widget.groupId));
    final users = ref.watch(usersProvider);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expenses')),
        body: const Center(child: Text('Group not found')),
      );
    }

    // Filter transactions
    final filteredTransactions = allTransactions.where((transaction) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!transaction.description.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && transaction.category != _selectedCategory) {
        return false;
      }

      // Date range filter
      if (_dateRange != null) {
        if (transaction.timestamp.isBefore(_dateRange!.start) ||
            transaction.timestamp.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort transactions based on selected order
    filteredTransactions.sort((a, b) {
      if (_sortLatestFirst) {
        return b.timestamp.compareTo(a.timestamp); // Latest first
      } else {
        return a.timestamp.compareTo(b.timestamp); // Oldest first
      }
    });

    // Calculate category breakdown
    final categoryTotals = <ExpenseCategory, double>{};
    for (var transaction in allTransactions) {
      if (transaction.type.name == 'expense') {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0.0) + transaction.totalAmount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          PopupMenuButton<bool>(
            icon: Icon(_sortLatestFirst ? Icons.arrow_downward : Icons.arrow_upward),
            tooltip: 'Sort',
            onSelected: (value) {
              setState(() {
                _sortLatestFirst = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: true,
                child: Row(
                  children: [
                    const Icon(Icons.arrow_downward, size: 20),
                    const SizedBox(width: 12),
                    const Text('Latest First'),
                    if (_sortLatestFirst) ...[  
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.green, size: 20),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: false,
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward, size: 20),
                    const SizedBox(width: 12),
                    const Text('Oldest First'),
                    if (!_sortLatestFirst) ...[  
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.green, size: 20),
                    ],
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              _showCategoryBreakdown(context, categoryTotals, group.currency);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: Text(_dateRange == null
                      ? 'All Time'
                      : '${DateFormatter.formatShort(_dateRange!.start)} - ${DateFormatter.formatShort(_dateRange!.end)}'),
                  selected: _dateRange != null,
                  onSelected: (_) async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateRange,
                    );
                    if (picked != null) {
                      setState(() {
                        _dateRange = picked;
                      });
                    }
                  },
                  deleteIcon: _dateRange != null ? const Icon(Icons.close, size: 18) : null,
                  onDeleted: _dateRange != null
                      ? () {
                          setState(() {
                            _dateRange = null;
                          });
                        }
                      : null,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('All Categories'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                ...ExpenseCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(category.icon, size: 16),
                      label: Text(category.displayName),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTransactions.length} expenses',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (filteredTransactions.isNotEmpty)
                  Text(
                    'Total: ${CurrencyFormatter.format(
                      filteredTransactions.fold(0.0, (sum, t) => sum + t.totalAmount),
                      currencyCode: group.currency,
                    )}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          const Divider(),

          // Expense List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      final payer = users.firstWhere(
                        (u) => transaction.payers.keys.first == u.id,
                        orElse: () => users.first,
                      );

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.category.color.withOpacity(0.2),
                          child: Icon(
                            transaction.category.icon,
                            color: transaction.category.color,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(transaction.description)),
                            if (transaction.isRecurring)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.repeat,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${payer.name} • ${DateFormatter.formatShort(transaction.timestamp)}',
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(
                            transaction.totalAmount,
                            currencyCode: group.currency,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          _showExpenseDetails(context, transaction, users, group.currency);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCategoryBreakdown(
    BuildContext context,
    Map<ExpenseCategory, double> categoryTotals,
    String currency,
  ) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (sortedCategories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No expenses yet'),
                ),
              )
            else
              ...sortedCategories.map((entry) {
                final percentage = (entry.value / total * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(entry.key.icon, color: entry.key.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key.displayName),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: entry.value / total,
                              backgroundColor: Colors.grey.shade200,
                              color: entry.key.color,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(entry.value, currencyCode: currency),
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showExpenseDetails(
    BuildContext context,
    Transaction transaction,
    List users,
    String currency,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: transaction.category.color.withOpacity(0.2),
                    radius: 24,
                    child: Icon(
                      transaction.category.icon,
                      color: transaction.category.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          transaction.category.displayName,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                'Amount',
                CurrencyFormatter.format(transaction.totalAmount, currencyCode: currency),
              ),
              _buildDetailRow(
                'Date',
                DateFormatter.formatFull(transaction.timestamp),
              ),
              const Divider(height: 32),
              const Text(
                'Paid By',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...transaction.payers.entries.map((entry) {
                final user = users.firstWhere((u) => u.id == entry.key);
                return _buildDetailRow(
                  user.name,
                  CurrencyFormatter.format(entry.value, currencyCode: currency),
                );
              }),
              const Divider(height: 32),
              const Text(
                'Split Between',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...transaction.splits.entries.map((entry) {
                final user = users.firstWhere((u) => u.id == entry.key);
                return _buildDetailRow(
                  user.name,
                  CurrencyFormatter.format(entry.value, currencyCode: currency),
                );
              }),
              if (transaction.notes != null) ...[
                const Divider(height: 32),
                const Text(
                  'Notes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(transaction.notes!),
              ],
              if (transaction.isRecurring) ...[
                const Divider(height: 32),
                _buildDetailRow(
                  'Recurring',
                  transaction.recurringFrequency?.toUpperCase() ?? 'Yes',
                ),
              ],
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context, transaction);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddExpenseScreen(
                              groupId: transaction.groupId,
                              transaction: transaction,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Transaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Are you sure you want to delete "${transaction.description}"?\\n\\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(transactionsProvider.notifier).deleteTransaction(transaction.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
