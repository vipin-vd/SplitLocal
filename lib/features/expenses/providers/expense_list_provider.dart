import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/expense_category.dart';
import '../models/transaction.dart';
import 'transactions_provider.dart';

part 'expense_list_provider.g.dart';

class ExpenseFilter {
  final ExpenseCategory? category;
  final String searchQuery;
  final DateTimeRange? dateRange;
  final bool sortLatestFirst;

  ExpenseFilter({
    this.category,
    this.searchQuery = '',
    this.dateRange,
    this.sortLatestFirst = true,
  });

  ExpenseFilter copyWith({
    ExpenseCategory? category,
    bool clearCategory = false,
    String? searchQuery,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    bool? sortLatestFirst,
  }) {
    return ExpenseFilter(
      category: clearCategory ? null : category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: clearDateRange ? null : dateRange ?? this.dateRange,
      sortLatestFirst: sortLatestFirst ?? this.sortLatestFirst,
    );
  }
}

@riverpod
class ExpenseListFilter extends _$ExpenseListFilter {
  @override
  ExpenseFilter build() {
    return ExpenseFilter();
  }

  void setCategory(ExpenseCategory? category) {
    state = state.copyWith(category: category, clearCategory: category == null);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range, clearDateRange: range == null);
  }

  void setSortOrder({required bool latestFirst}) {
    state = state.copyWith(sortLatestFirst: latestFirst);
  }
}

@riverpod
List<Transaction> filteredExpenses(FilteredExpensesRef ref, String groupId) {
  final transactions = ref.watch(groupTransactionsProvider(groupId));
  final filter = ref.watch(expenseListFilterProvider);

  final filtered = transactions.where((transaction) {
    if (filter.searchQuery.isNotEmpty &&
        !transaction.description
            .toLowerCase()
            .contains(filter.searchQuery.toLowerCase())) {
      return false;
    }
    if (filter.category != null && transaction.category != filter.category) {
      return false;
    }
    if (filter.dateRange != null &&
        (transaction.timestamp.isBefore(filter.dateRange!.start) ||
            transaction.timestamp.isAfter(filter.dateRange!.end))) {
      return false;
    }
    return true;
  }).toList();

  filtered.sort((a, b) {
    return filter.sortLatestFirst
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp);
  });

  return filtered;
}

@riverpod
Map<ExpenseCategory, double> categoryTotals(
    CategoryTotalsRef ref, String groupId) {
  final transactions = ref.watch(groupTransactionsProvider(groupId));
  final totals = <ExpenseCategory, double>{};
  for (var t in transactions) {
    if (t.type.name == 'expense') {
      totals[t.category] = (totals[t.category] ?? 0.0) + t.totalAmount;
    }
  }
  return totals;
}
