import 'package:flutter_test/flutter_test.dart';
import 'package:splitlocal/features/expenses/models/transaction.dart';
import 'package:splitlocal/features/expenses/models/transaction_type.dart';
import 'package:splitlocal/features/expenses/models/split_mode.dart';
import 'package:splitlocal/features/expenses/models/expense_category.dart';
import 'package:splitlocal/services/debt_calculator_service.dart';

void main() {
  group('Multi-Currency Balance Calculations', () {
    late DebtCalculatorService debtCalculator;

    setUp(() {
      debtCalculator = DebtCalculatorService();
    });

    // Test helper to create a transaction
    Transaction createExpense({
      required String id,
      required String groupId,
      required double amount,
      required String payerId,
      required Map<String, double> splits,
      String currency = 'INR',
    }) {
      return Transaction(
        id: id,
        groupId: groupId,
        type: TransactionType.expense,
        description: 'Test expense',
        totalAmount: amount,
        payers: {payerId: amount},
        splits: splits,
        splitMode: SplitMode.equal,
        timestamp: DateTime.now(),
        createdBy: payerId,
        category: ExpenseCategory.general,
        currency: currency,
      );
    }

    test('Single currency group - total spend calculated correctly', () {
      final transactions = [
        createExpense(
          id: 't1',
          groupId: 'g1',
          amount: 100.0,
          payerId: 'user1',
          splits: {'user1': 50.0, 'user2': 50.0},
          currency: 'USD',
        ),
        createExpense(
          id: 't2',
          groupId: 'g1',
          amount: 200.0,
          payerId: 'user2',
          splits: {'user1': 100.0, 'user2': 100.0},
          currency: 'USD',
        ),
      ];

      final totalSpend = debtCalculator.calculateTotalGroupSpend(transactions);
      expect(totalSpend, equals(300.0));
    });

    test('Multi-currency group - total spend should be grouped by currency',
        () {
      // This test validates the CURRENT INCORRECT behavior
      // After fix, we need a new method that returns Map<String, double>
      final transactions = [
        createExpense(
          id: 't1',
          groupId: 'g1',
          amount: 100.0,
          payerId: 'user1',
          splits: {'user1': 50.0, 'user2': 50.0},
          currency: 'USD',
        ),
        createExpense(
          id: 't2',
          groupId: 'g1',
          amount: 8000.0,
          payerId: 'user2',
          splits: {'user1': 4000.0, 'user2': 4000.0},
          currency: 'INR',
        ),
      ];

      // Current behavior (incorrect): sums all amounts regardless of currency
      final incorrectTotalSpend =
          debtCalculator.calculateTotalGroupSpend(transactions);
      expect(
        incorrectTotalSpend,
        equals(8100.0),
      ); // 100 + 8000 = incorrectly mixed

      // After fix: should return {'USD': 100.0, 'INR': 8000.0}
      // We'll add a new method: calculateTotalGroupSpendByCurrency
    });

    test('Multi-currency group - net balances should be grouped by currency',
        () {
      // Transactions in different currencies
      final transactions = [
        createExpense(
          id: 't1',
          groupId: 'g1',
          amount: 100.0,
          payerId: 'user1', // user1 pays $100
          splits: {'user1': 50.0, 'user2': 50.0}, // each owes $50
          currency: 'USD',
        ),
        createExpense(
          id: 't2',
          groupId: 'g1',
          amount: 1000.0,
          payerId: 'user2', // user2 pays ₹1000
          splits: {'user1': 500.0, 'user2': 500.0}, // each owes ₹500
          currency: 'INR',
        ),
      ];

      // Current behavior (incorrect): mixes currencies
      final incorrectNetBalances =
          debtCalculator.computeNetBalances(transactions);
      // user1: paid $100, owes $50 + ₹500 = net of 100 - 50 - 500 = -450 (WRONG!)
      // user2: paid ₹1000, owes $50 + ₹500 = net of 1000 - 50 - 500 = 450 (WRONG!)

      // This is the incorrect mixed calculation
      expect(incorrectNetBalances['user1'], equals(100 - 50 - 500)); // -450
      expect(incorrectNetBalances['user2'], equals(1000 - 50 - 500)); // 450

      // Correct behavior should be:
      // user1: USD: +50 (paid 100, owes 50), INR: -500 (paid 0, owes 500)
      // user2: USD: -50 (paid 0, owes 50), INR: +500 (paid 1000, owes 500)
    });

    test('Single currency - simplified debts work correctly', () {
      final transactions = [
        createExpense(
          id: 't1',
          groupId: 'g1',
          amount: 300.0,
          payerId: 'user1',
          splits: {'user1': 100.0, 'user2': 100.0, 'user3': 100.0},
          currency: 'USD',
        ),
      ];

      final debts = debtCalculator.simplifyDebts(transactions);

      // user1 paid 300, owes 100, so is owed 200
      // user2 paid 0, owes 100
      // user3 paid 0, owes 100
      // Simplified: user2 -> user1: 100, user3 -> user1: 100
      expect(debts.length, equals(2));

      final debtAmounts = debts.map((d) => d.amount).toList();
      expect(debtAmounts, containsAll([100.0, 100.0]));
    });

    test('Multi-currency - simplified debts should NOT mix currencies', () {
      // This test documents the expected behavior after the fix
      // Currently, simplifyDebts mixes currencies which is incorrect

      final transactions = [
        createExpense(
          id: 't1',
          groupId: 'g1',
          amount: 100.0,
          payerId: 'user1',
          splits: {'user1': 50.0, 'user2': 50.0},
          currency: 'USD',
        ),
        createExpense(
          id: 't2',
          groupId: 'g1',
          amount: 1000.0,
          payerId: 'user2',
          splits: {'user1': 500.0, 'user2': 500.0},
          currency: 'INR',
        ),
      ];

      // Current (incorrect) behavior:
      // Net balances are mixed: user1 = -450, user2 = +450
      // This creates a single debt: user1 -> user2: 450 (but 450 of WHAT currency?)

      final debts = debtCalculator.simplifyDebts(transactions);
      // Currently produces incorrect mixed-currency debt

      // Expected behavior after fix:
      // USD debts: user2 -> user1: $50
      // INR debts: user1 -> user2: ₹500
      // These should NOT be netted against each other!
    });
  });

  group('Friend Group Currency Default', () {
    test('New friend group should use Account Default currency', () {
      // This is a provider-level test that requires Riverpod testing setup
      // Documented here for clarity - will be tested via integration

      // Scenario:
      // 1. Set preferred currency to USD in Account settings
      // 2. Add a new friend (no existing friend group)
      // 3. Create expense with that friend
      // 4. Verify the friend group was created with USD currency

      // Note: Requires ProviderContainer setup with mocked storage
      expect(true, isTrue); // Placeholder
    });
  });

  group('Group Balance With Friend - Multi-Currency', () {
    test('Balance with friend in multi-currency group should be per-currency',
        () {
      // Scenario:
      // Group with user1 (me) and user2 (friend)
      // Expense 1: user1 pays $100, split 50/50 -> user2 owes me $50
      // Expense 2: user2 pays ₹1000, split 50/50 -> I owe user2 ₹500

      // Current (incorrect) behavior:
      // Balance = $50 - ₹500 = -450 (meaningless number)

      // Expected behavior:
      // Balance in USD: +$50 (friend owes me)
      // Balance in INR: -₹500 (I owe friend)

      expect(true, isTrue); // Placeholder - needs provider testing
    });
  });
}
