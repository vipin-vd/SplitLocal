import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/services/debt_calculator_service.dart';
import 'package:splitlocal/shared/providers/preferred_currency_provider.dart';

part 'net_totals_provider.g.dart';

/// Computes the device owner's net balances against all other users
/// from all transactions across the app (friend groups + regular groups).
@riverpod
@riverpod
Map<String, double> allNetBalances(AllNetBalancesRef ref) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return {};

  final selectedCurrency = ref.watch(dashboardCurrencyProvider);
  final groups = ref.watch(groupsProvider);

  final allTransactions = ref.watch(transactionsProvider);
  final groupMap = {for (var g in groups) g.id: g};

  // Filter transactions that match selected currency
  // Either explicit transaction currency matches, OR fallback to group currency matches
  final filteredTransactions = allTransactions.where((t) {
    final transactionCurrency = t.currency;
    if (transactionCurrency != null) {
      return transactionCurrency == selectedCurrency;
    }
    final group = groupMap[t.groupId];
    return group?.currency == selectedCurrency;
  }).toList();

  final debtCalculator = DebtCalculatorService();
  final actualDebts = debtCalculator.getActualDebts(filteredTransactions);

  // Build net balances relative to device owner (bilateral)
  final net = <String, double>{};
  for (final debt in actualDebts) {
    if (debt.fromUserId == me.id) {
      // I owe to someone
      net[debt.toUserId] = (net[debt.toUserId] ?? 0.0) - debt.amount;
    } else if (debt.toUserId == me.id) {
      // Someone owes me
      net[debt.fromUserId] = (net[debt.fromUserId] ?? 0.0) + debt.amount;
    }
  }

  return net;
}

/// Total amount the user is owed globally (sum of positive balances)
@riverpod
double totalOwedToUserGlobal(TotalOwedToUserGlobalRef ref) {
  final net = ref.watch(allNetBalancesProvider);
  double total = 0.0;
  for (final amount in net.values) {
    if (amount > 0.01) total += amount;
  }
  return total;
}

/// Total amount the user owes globally (sum of negative balances, returned positive)
@riverpod
double totalUserOwesGlobal(TotalUserOwesGlobalRef ref) {
  final net = ref.watch(allNetBalancesProvider);
  double total = 0.0;
  for (final amount in net.values) {
    if (amount < -0.01) total += -amount;
  }
  return total;
}

/// Net global balance (positive => others owe user, negative => user owes)
@riverpod
double netBalanceGlobal(NetBalanceGlobalRef ref) {
  final owed = ref.watch(totalOwedToUserGlobalProvider);
  final owes = ref.watch(totalUserOwesGlobalProvider);
  final net = owed - owes;
  return net.abs() < 0.01 ? 0.0 : net;
}
