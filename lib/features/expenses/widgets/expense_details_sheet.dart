import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/expense_category.dart';
import '../../groups/models/user.dart';
import '../providers/transactions_provider.dart';
import '../screens/add_expense_screen.dart';
import '../../../shared/utils/formatters.dart';

/// Shows the expense details bottom sheet.
///
/// This is a helper function to ensure consistent bottom sheet presentation
/// across the app when displaying transaction details.
void showExpenseDetailsSheet({
  required BuildContext context,
  required Transaction transaction,
  required List<User> users,
  required String currency,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => ExpenseDetailsSheet(
      transaction: transaction,
      users: users,
      currency: currency,
    ),
  );
}

/// A bottom sheet displaying detailed information about an expense transaction.
///
/// Shows:
/// - Transaction description and category
/// - Total amount and date
/// - Who paid and how much
/// - Split breakdown across participants
/// - Notes (if any)
/// - Recurring information (if applicable)
/// - Delete and Edit actions
class ExpenseDetailsSheet extends ConsumerWidget {
  final Transaction transaction;
  final List<User> users;
  final String currency;

  const ExpenseDetailsSheet({
    super.key,
    required this.transaction,
    required this.users,
    required this.currency,
  });

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Transactions notifier,
    String transactionId,
  ) async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.deleteTransaction(transactionId);
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsNotifier = ref.read(transactionsProvider.notifier);

    return DraggableScrollableSheet(
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
                  backgroundColor:
                      transaction.category.color.withValues(alpha: 0.2),
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
              CurrencyFormatter.format(
                transaction.totalAmount,
                currencyCode: currency,
              ),
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
                      _showDeleteConfirmation(
                        context,
                        transactionsNotifier,
                        transaction.id,
                      );
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
    );
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
