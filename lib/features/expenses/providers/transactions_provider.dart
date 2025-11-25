import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/transaction.dart';
import '../models/expense_category.dart';
import '../../../../shared/providers/services_provider.dart';

part 'transactions_provider.g.dart';

@riverpod
class Transactions extends _$Transactions {
  @override
  List<Transaction> build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.getAllTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveTransaction(transaction);
    ref.invalidateSelf();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveTransaction(transaction);
    ref.invalidateSelf();
  }

  Future<void> deleteTransaction(String transactionId) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.deleteTransaction(transactionId);
    ref.invalidateSelf();
  }
}

@riverpod
List<Transaction> groupTransactions(
  GroupTransactionsRef ref,
  String groupId,
) {
  final allTransactions = ref.watch(transactionsProvider);
  return allTransactions.where((t) => t.groupId == groupId).toList();
}

@riverpod
Map<String, double> groupNetBalances(
  GroupNetBalancesRef ref,
  String groupId,
) {
  final transactions = ref.watch(groupTransactionsProvider(groupId));
  final debtCalculator = ref.watch(debtCalculatorServiceProvider);
  return debtCalculator.computeNetBalances(transactions);
}

@riverpod
double groupTotalSpend(GroupTotalSpendRef ref, String groupId) {
  final transactions = ref.watch(groupTransactionsProvider(groupId));
  final debtCalculator = ref.watch(debtCalculatorServiceProvider);
  return debtCalculator.calculateTotalGroupSpend(transactions);
}

@riverpod
Map<ExpenseCategory, double> groupCategorySpending(
  GroupCategorySpendingRef ref,
  String groupId,
) {
  final transactions = ref.watch(groupTransactionsProvider(groupId));
  final categoryTotals = <ExpenseCategory, double>{};
  
  for (var transaction in transactions) {
    if (transaction.type.name == 'expense') {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0.0) + transaction.totalAmount;
    }
  }
  
  return categoryTotals;
}

@riverpod
List<Transaction> recurringExpenses(
  RecurringExpensesRef ref,
  String groupId,
) {
  final transactions = ref.watch(groupTransactionsProvider(groupId));
  return transactions.where((t) => t.isRecurring && t.type.name == 'expense').toList();
}
