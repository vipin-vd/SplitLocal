import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/features/friends/providers/friends_provider.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/services/debt_calculator_service.dart';

part 'friend_balance_provider.g.dart';

@riverpod
double friendBalance(Ref ref, String friendId) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return 0.0;

  final allGroups = ref.watch(groupsProvider);
  final sharedGroups = allGroups
      .where(
        (g) => g.memberIds.contains(me.id) && g.memberIds.contains(friendId),
      )
      .toList();

  if (sharedGroups.isEmpty) return 0.0;

  final allTransactions = sharedGroups
      .expand((g) => ref.watch(groupTransactionsProvider(g.id)))
      .toList();

  final debtCalculator = DebtCalculatorService();
  final simplifiedDebts = debtCalculator.simplifyDebts(allTransactions);

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

/// Returns friend balance grouped by currency code.
/// Positive values mean friend owes you, negative means you owe them.
@riverpod
Map<String, double> friendBalanceByCurrency(
  Ref ref,
  String friendId,
) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return {};

  final allGroups = ref.watch(groupsProvider);

  final sharedGroups = allGroups
      .where(
        (g) => g.memberIds.contains(me.id) && g.memberIds.contains(friendId),
      )
      .toList();

  if (sharedGroups.isEmpty) return {};

  // Group transactions by currency
  final transactionsByCurrency = <String, List<dynamic>>{};

  for (final group in sharedGroups) {
    final transactions = ref.watch(groupTransactionsProvider(group.id));
    for (final t in transactions) {
      final currency = t.currency ?? group.currency;
      transactionsByCurrency.putIfAbsent(currency, () => []).add(t);
    }
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

/// Provides a map of all friend balances to avoid per-item watches during filtering
@riverpod
Map<String, double> allFriendBalances(Ref ref) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return {};

  final allGroups = ref.watch(groupsProvider);
  final friends = ref.watch(friendsProvider);

  final balances = <String, double>{};

  for (final friend in friends) {
    final sharedGroups = allGroups
        .where(
          (g) => g.memberIds.contains(me.id) && g.memberIds.contains(friend.id),
        )
        .toList();

    if (sharedGroups.isEmpty) {
      balances[friend.id] = 0.0;
      continue;
    }

    final allTransactions = sharedGroups
        .expand((g) => ref.watch(groupTransactionsProvider(g.id)))
        .toList();

    final debtCalculator = DebtCalculatorService();
    final simplifiedDebts = debtCalculator.simplifyDebts(allTransactions);

    double balance = 0.0;

    for (final debt in simplifiedDebts) {
      if (debt.fromUserId == me.id && debt.toUserId == friend.id) {
        balance -= debt.amount;
      } else if (debt.fromUserId == friend.id && debt.toUserId == me.id) {
        balance += debt.amount;
      }
    }

    balances[friend.id] = balance;
  }

  return balances;
}

/// Provides a map of all friend balances grouped by currency
/// Map<FriendId, Map<CurrencyCode, Balance>>
@riverpod
Map<String, Map<String, double>> allFriendBalancesByCurrency(
  Ref ref,
) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return {};

  final allGroups = ref.watch(groupsProvider);
  final friends = ref.watch(friendsProvider);

  final balances = <String, Map<String, double>>{};

  for (final friend in friends) {
    final sharedGroups = allGroups
        .where(
          (g) => g.memberIds.contains(me.id) && g.memberIds.contains(friend.id),
        )
        .toList();

    if (sharedGroups.isEmpty) {
      balances[friend.id] = {};
      continue;
    }

    final friendBalances = <String, double>{};

    // Calculate balance per currency across all shared groups
    for (final group in sharedGroups) {
      final transactions = ref.watch(groupTransactionsProvider(group.id));

      // Group transactions by currency
      final transactionsByCurrency = <String, List<dynamic>>{};
      for (final t in transactions) {
        final currency = t.currency ?? group.currency ?? 'INR';
        transactionsByCurrency.putIfAbsent(currency, () => []).add(t);
      }

      final debtCalculator = DebtCalculatorService();

      for (final entry in transactionsByCurrency.entries) {
        final currency = entry.key;
        final currencyTransactions = entry.value.cast<dynamic>();

        final simplifiedDebts =
            debtCalculator.simplifyDebts(currencyTransactions.cast());

        double balance = 0.0;
        for (final debt in simplifiedDebts) {
          if (debt.fromUserId == me.id && debt.toUserId == friend.id) {
            balance -= debt.amount;
          } else if (debt.fromUserId == friend.id && debt.toUserId == me.id) {
            balance += debt.amount;
          }
        }

        if (balance.abs() >= 0.01) {
          friendBalances[currency] =
              (friendBalances[currency] ?? 0.0) + balance;
        }
      }
    }

    balances[friend.id] = friendBalances;
  }

  return balances;
}

/// Provides list of friend IDs with zero balances (settled up or new friends)
@riverpod
List<String> zeroBalanceFriendIds(Ref ref) {
  final balances = ref.watch(allFriendBalancesProvider);
  return balances.entries
      .where((entry) => entry.value.abs() < 0.01)
      .map((entry) => entry.key)
      .toList();
}

/// Total amount the user is owed by all friends (sum of positive balances)
@riverpod
double totalOwedToUser(Ref ref) {
  final balances = ref.watch(allFriendBalancesProvider);
  double total = 0.0;
  for (final amount in balances.values) {
    if (amount > 0.01) total += amount;
  }
  return total;
}

/// Total amount the user owes to all friends (sum of negative balances, returned positive)
@riverpod
double totalUserOwes(Ref ref) {
  final balances = ref.watch(allFriendBalancesProvider);
  double total = 0.0;
  for (final amount in balances.values) {
    if (amount < -0.01) total += -amount; // accumulate as positive
  }
  return total;
}

/// Net balance across all friends (positive => friends owe user, negative => user owes)
@riverpod
double netFriendBalance(Ref ref) {
  final owedToUser = ref.watch(totalOwedToUserProvider);
  final userOwes = ref.watch(totalUserOwesProvider);
  final net = owedToUser - userOwes;
  return net.abs() < 0.01 ? 0.0 : net;
}
