import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';

import 'package:splitlocal/shared/utils/currency.dart';

part 'preferred_currency_provider.g.dart';

@riverpod
class PreferredCurrency extends _$PreferredCurrency {
  @override
  String build() {
    // Default to most frequent currency in groups, or INR
    final groups = ref.read(groupsProvider);
    if (groups.isEmpty) return AppCurrency.INR.code;

    final currencies = groups.map((g) => g.currency).toList();
    if (currencies.isEmpty) return AppCurrency.INR.code;

    final frequencyMap = <String, int>{};
    for (final c in currencies) {
      frequencyMap[c] = (frequencyMap[c] ?? 0) + 1;
    }

    // Find the currency with the highest frequency
    var mostFrequent = currencies.first;
    var maxCount = 0;

    frequencyMap.forEach((currency, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = currency;
      }
    });

    return mostFrequent;
  }

  void setCurrency(String code) {
    state = code;
  }
}

@riverpod
class DashboardCurrency extends _$DashboardCurrency {
  @override
  String build() {
    return ref.watch(preferredCurrencyProvider);
  }

  void setCurrency(String code) {
    state = code;
  }
}

/// Returns a list of currency codes that are actually used in groups or transactions.
@riverpod
List<String> usedCurrencies(UsedCurrenciesRef ref) {
  final groups = ref.watch(groupsProvider);
  final transactions = ref.watch(transactionsProvider);

  final usedSet = <String>{};

  // Collect currencies from groups
  for (final group in groups) {
    usedSet.add(group.currency);
  }

  // Collect currencies from transactions
  for (final tx in transactions) {
    if (tx.currency != null && tx.currency!.isNotEmpty) {
      usedSet.add(tx.currency!);
    }
  }

  // If no currencies found, default to INR
  if (usedSet.isEmpty) {
    usedSet.add(AppCurrency.INR.code);
  }

  return usedSet.toList()..sort();
}
