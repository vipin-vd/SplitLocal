import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/expense_category.dart';
import '../../groups/models/user.dart';
import '../../../shared/utils/formatters.dart';

/// A reusable list tile for displaying transaction information.
///
/// Displays transaction with:
/// - Leading: Category icon in colored CircleAvatar
/// - Title: Transaction description
/// - Subtitle: Payer name and formatted date
/// - Trailing: Formatted amount with currency
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final List<User> users;
  final String currency;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.users,
    required this.currency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      title: Text(transaction.description),
      subtitle: Text(
        '${payer.name} • ${DateFormatter.formatShort(transaction.timestamp)}',
      ),
      trailing: Text(
        CurrencyFormatter.format(
          transaction.totalAmount,
          currencyCode: currency,
        ),
      ),
      onTap: onTap,
    );
  }
}
