import '../../features/expenses/models/transaction.dart';
import '../../features/expenses/models/transaction_type.dart';

/// Represents a debt from one user to another
class DebtDetail {
  final String fromUserId;
  final String toUserId;
  final double amount;

  DebtDetail({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  @override
  String toString() =>
      'DebtDetail(from: $fromUserId, to: $toUserId, amount: $amount)';
}

/// Represents the net balance for a user (positive = they are owed, negative = they owe)
class NetBalance {
  final String userId;
  final double balance;

  NetBalance({
    required this.userId,
    required this.balance,
  });

  @override
  String toString() => 'NetBalance(user: $userId, balance: $balance)';
}

class DebtCalculatorService {
  /// Calculate net balances for all members in a group
  /// Handles multi-payer scenarios correctly
  ///
  /// Logic:
  /// 1. For each transaction, calculate what each person paid vs. what they owe
  /// 2. Net balance = (total paid) - (total owed)
  /// 3. Positive balance = person is owed money
  /// 4. Negative balance = person owes money
  Map<String, double> computeNetBalances(List<Transaction> transactions) {
    final Map<String, double> netBalances = {};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        // Process expense: payers vs splits

        // Add what each person paid
        transaction.payers.forEach((userId, amountPaid) {
          netBalances[userId] = (netBalances[userId] ?? 0.0) + amountPaid;
        });

        // Subtract what each person owes
        transaction.splits.forEach((userId, amountOwed) {
          netBalances[userId] = (netBalances[userId] ?? 0.0) - amountOwed;
        });
      } else if (transaction.type == TransactionType.payment) {
        // Process payment: reduces debt directly
        // Payer gives money (negative for them)
        // Recipient receives money (positive for them)

        transaction.payers.forEach((payerId, amount) {
          netBalances[payerId] = (netBalances[payerId] ?? 0.0) - amount;
        });

        transaction.splits.forEach((recipientId, amount) {
          netBalances[recipientId] = (netBalances[recipientId] ?? 0.0) + amount;
        });
      }
    }

    return netBalances;
  }

  /// Get actual debts from net balances (who owes whom)
  /// This shows the graph-based view of all debts
  List<DebtDetail> getActualDebts(List<Transaction> transactions) {
    final debts = <DebtDetail>[];

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        // For each split, calculate debt to each payer
        transaction.splits.forEach((owerId, owedAmount) {
          transaction.payers.forEach((payerId, paidAmount) {
            if (owerId != payerId) {
              // Calculate proportional share of what this ower owes to this payer
              final payerShare = paidAmount / transaction.totalAmount;
              final debtAmount = owedAmount * payerShare;

              debts.add(DebtDetail(
                fromUserId: owerId,
                toUserId: payerId,
                amount: debtAmount,
              ),);
            }
          });
        });
      } else if (transaction.type == TransactionType.payment) {
        // Payment reduces debt (record as negative debt or skip in actual view)
        transaction.payers.forEach((payerId, amount) {
          transaction.splits.forEach((recipientId, _) {
            debts.add(DebtDetail(
              fromUserId: recipientId,
              toUserId: payerId,
              amount: -amount, // Negative to show debt reduction
            ),);
          });
        });
      }
    }

    return debts;
  }

  /// Simplify debts using greedy algorithm
  /// Minimizes the number of transactions needed to settle all debts
  ///
  /// Algorithm:
  /// 1. Calculate net balance for each user
  /// 2. Separate into debtors (negative) and creditors (positive)
  /// 3. Sort both by magnitude (largest first)
  /// 4. Match largest debtor with largest creditor
  /// 5. Transfer min(|debtor|, creditor) amount
  /// 6. Update balances and repeat until all settled
  List<DebtDetail> simplifyDebts(List<Transaction> transactions) {
    final netBalances = computeNetBalances(transactions);

    // Separate into debtors and creditors
    final List<NetBalance> debtors = [];
    final List<NetBalance> creditors = [];

    netBalances.forEach((userId, balance) {
      if (balance < -0.01) {
        // Owes money (debtor)
        debtors.add(NetBalance(userId: userId, balance: balance.abs()));
      } else if (balance > 0.01) {
        // Is owed money (creditor)
        creditors.add(NetBalance(userId: userId, balance: balance));
      }
      // Skip if balance is ~0 (within rounding error)
    });

    // Sort by magnitude (largest first)
    debtors.sort((a, b) => b.balance.compareTo(a.balance));
    creditors.sort((a, b) => b.balance.compareTo(a.balance));

    final List<DebtDetail> simplifiedDebts = [];
    int debtorIndex = 0;
    int creditorIndex = 0;

    while (debtorIndex < debtors.length && creditorIndex < creditors.length) {
      final debtor = debtors[debtorIndex];
      final creditor = creditors[creditorIndex];

      // Transfer minimum of what debtor owes and what creditor is owed
      final transferAmount =
          debtor.balance < creditor.balance ? debtor.balance : creditor.balance;

      simplifiedDebts.add(DebtDetail(
        fromUserId: debtor.userId,
        toUserId: creditor.userId,
        amount: transferAmount,
      ),);

      // Update balances
      debtors[debtorIndex] = NetBalance(
        userId: debtor.userId,
        balance: debtor.balance - transferAmount,
      );
      creditors[creditorIndex] = NetBalance(
        userId: creditor.userId,
        balance: creditor.balance - transferAmount,
      );

      // Move to next debtor/creditor if current is settled
      if (debtors[debtorIndex].balance < 0.01) {
        debtorIndex++;
      }
      if (creditors[creditorIndex].balance < 0.01) {
        creditorIndex++;
      }
    }

    return simplifiedDebts;
  }

  /// Calculate total group spending (only expenses, not payments)
  double calculateTotalGroupSpend(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  /// Get individual's total contribution (what they paid)
  double getUserTotalPaid(String userId, List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, t) {
      return sum + (t.payers[userId] ?? 0.0);
    });
  }

  /// Get individual's total share (what they owe)
  double getUserTotalShare(String userId, List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) {
      return sum + (t.splits[userId] ?? 0.0);
    });
  }
}
