import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/services/debt_calculator_service.dart';

part 'group_balance_with_friend_provider.g.dart';

@riverpod
double groupBalanceWithFriend(
  GroupBalanceWithFriendRef ref,
  String groupId,
  String friendId,
) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return 0.0;

  final groupTransactions = ref.watch(groupTransactionsProvider(groupId));
  final debtCalculator = DebtCalculatorService();
  final simplifiedDebts = debtCalculator.simplifyDebts(groupTransactions);

  double balance = 0.0;

  for (final debt in simplifiedDebts) {
    if (debt.fromUserId == me.id && debt.toUserId == friendId) {
      balance -= debt.amount; // I owe the friend
    } else if (debt.fromUserId == friendId && debt.toUserId == me.id) {
      balance += debt.amount; // Friend owes me
    }
  }

  return balance;
}

/// Returns friend balance within a specific group, grouped by currency.
/// Positive values mean friend owes you, negative means you owe them.
@riverpod
Map<String, double> groupBalanceWithFriendByCurrency(
  GroupBalanceWithFriendByCurrencyRef ref,
  String groupId,
  String friendId,
) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return {};

  final group =
      ref.watch(groupsProvider).where((g) => g.id == groupId).firstOrNull;
  final groupTransactions = ref.watch(groupTransactionsProvider(groupId));

  // Group transactions by currency
  final transactionsByCurrency = <String, List<dynamic>>{};

  for (final t in groupTransactions) {
    final currency = t.currency ?? group?.currency ?? 'INR';
    transactionsByCurrency.putIfAbsent(currency, () => []).add(t);
  }

  final debtCalculator = DebtCalculatorService();
  final balanceByCurrency = <String, double>{};

  for (final entry in transactionsByCurrency.entries) {
    final currency = entry.key;
    final transactions = entry.value.cast<dynamic>();

    // Calculate simplified debts for this currency's transactions
    final simplifiedDebts = debtCalculator.simplifyDebts(transactions.cast());

    double balance = 0.0;
    for (final debt in simplifiedDebts) {
      if (debt.fromUserId == me.id && debt.toUserId == friendId) {
        balance -= debt.amount;
      } else if (debt.fromUserId == friendId && debt.toUserId == me.id) {
        balance += debt.amount;
      }
    }

    if (balance.abs() >= 0.01) {
      balanceByCurrency[currency] = balance;
    }
  }

  return balanceByCurrency;
}
