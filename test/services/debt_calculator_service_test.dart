import 'package:flutter_test/flutter_test.dart';
import 'package:splitlocal/services/debt_calculator_service.dart';
import 'package:splitlocal/features/expenses/models/transaction.dart';
import 'package:splitlocal/features/expenses/models/transaction_type.dart';
import 'package:splitlocal/features/expenses/models/split_mode.dart';

void main() {
  group('DebtCalculatorService', () {
    late DebtCalculatorService calculator;

    setUp(() {
      calculator = DebtCalculatorService();
    });

    test('computeNetBalances - simple expense with single payer', () {
      final transactions = [
        Transaction(
          id: '1',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Dinner',
          totalAmount: 90.0,
          payers: {'A': 90.0},
          splits: {'A': 30.0, 'B': 30.0, 'C': 30.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
      ];

      final balances = calculator.computeNetBalances(transactions);

      expect(balances['A'], equals(60.0)); // Paid 90, owes 30 = +60
      expect(balances['B'], equals(-30.0)); // Paid 0, owes 30 = -30
      expect(balances['C'], equals(-30.0)); // Paid 0, owes 30 = -30
    });

    test('computeNetBalances - multi-payer expense', () {
      final transactions = [
        Transaction(
          id: '1',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Shopping',
          totalAmount: 150.0,
          payers: {'A': 100.0, 'B': 50.0},
          splits: {'A': 50.0, 'B': 50.0, 'C': 50.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
      ];

      final balances = calculator.computeNetBalances(transactions);

      expect(balances['A'], equals(50.0)); // Paid 100, owes 50 = +50
      expect(balances['B'], equals(0.0)); // Paid 50, owes 50 = 0
      expect(balances['C'], equals(-50.0)); // Paid 0, owes 50 = -50
    });

    test('computeNetBalances - payment settlement', () {
      final transactions = [
        Transaction(
          id: '1',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Dinner',
          totalAmount: 90.0,
          payers: {'A': 90.0},
          splits: {'A': 30.0, 'B': 30.0, 'C': 30.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
        Transaction(
          id: '2',
          groupId: 'group1',
          type: TransactionType.payment,
          description: 'Settlement',
          totalAmount: 30.0,
          payers: {'B': 30.0},
          splits: {'A': 30.0},
          splitMode: SplitMode.unequal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
      ];

      final balances = calculator.computeNetBalances(transactions);

      expect(balances['A'], equals(30.0)); // 60 - 30 (payment received) = 30
      expect(balances['B'], equals(0.0)); // -30 + 30 (payment made) = 0
      expect(balances['C'], equals(-30.0)); // Still owes 30
    });

    test('simplifyDebts - basic scenario', () {
      final transactions = [
        Transaction(
          id: '1',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Expense',
          totalAmount: 90.0,
          payers: {'A': 90.0},
          splits: {'A': 30.0, 'B': 30.0, 'C': 30.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
      ];

      final simplified = calculator.simplifyDebts(transactions);

      // Should have 2 transfers: B->A (30) and C->A (30)
      expect(simplified.length, equals(2));

      final bToA = simplified.firstWhere(
        (d) => d.fromUserId == 'B' && d.toUserId == 'A',
      );
      expect(bToA.amount, equals(30.0));

      final cToA = simplified.firstWhere(
        (d) => d.fromUserId == 'C' && d.toUserId == 'A',
      );
      expect(cToA.amount, equals(30.0));
    });

    test('simplifyDebts - complex scenario', () {
      final transactions = [
        Transaction(
          id: '1',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Expense 1',
          totalAmount: 100.0,
          payers: {'A': 100.0},
          splits: {'A': 25.0, 'B': 25.0, 'C': 25.0, 'D': 25.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
        Transaction(
          id: '2',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Expense 2',
          totalAmount: 100.0,
          payers: {'B': 100.0},
          splits: {'A': 25.0, 'B': 25.0, 'C': 25.0, 'D': 25.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'B',
        ),
      ];

      final simplified = calculator.simplifyDebts(transactions);

      // A owes 0 (paid 100, owes 50 = +50)
      // B owes 0 (paid 100, owes 50 = +50)
      // C owes 50 (paid 0, owes 50 = -50)
      // D owes 50 (paid 0, owes 50 = -50)

      // Simplified should be: C->A (25), C->B (25), D->A (25), D->B (25)
      // OR more simplified: C->A (50), D->B (50)
      expect(simplified.length, lessThanOrEqualTo(4));
    });

    test('calculateTotalGroupSpend - excludes payments', () {
      final transactions = [
        Transaction(
          id: '1',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Expense 1',
          totalAmount: 100.0,
          payers: {'A': 100.0},
          splits: {'A': 50.0, 'B': 50.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
        Transaction(
          id: '2',
          groupId: 'group1',
          type: TransactionType.payment,
          description: 'Settlement',
          totalAmount: 50.0,
          payers: {'B': 50.0},
          splits: {'A': 50.0},
          splitMode: SplitMode.unequal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
      ];

      final totalSpend = calculator.calculateTotalGroupSpend(transactions);

      // Should only count the expense, not the payment
      expect(totalSpend, equals(100.0));
    });

    test('getUserTotalPaid', () {
      final transactions = [
        Transaction(
          id: '1',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Expense 1',
          totalAmount: 100.0,
          payers: {'A': 100.0},
          splits: {'A': 50.0, 'B': 50.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
        Transaction(
          id: '2',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Expense 2',
          totalAmount: 60.0,
          payers: {'A': 40.0, 'B': 20.0},
          splits: {'A': 30.0, 'B': 30.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
      ];

      final aPaid = calculator.getUserTotalPaid('A', transactions);
      final bPaid = calculator.getUserTotalPaid('B', transactions);

      expect(aPaid, equals(140.0)); // 100 + 40
      expect(bPaid, equals(20.0)); // 20
    });

    test('getUserTotalShare', () {
      final transactions = [
        Transaction(
          id: '1',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Expense 1',
          totalAmount: 100.0,
          payers: {'A': 100.0},
          splits: {'A': 50.0, 'B': 50.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
        Transaction(
          id: '2',
          groupId: 'group1',
          type: TransactionType.expense,
          description: 'Expense 2',
          totalAmount: 60.0,
          payers: {'A': 60.0},
          splits: {'A': 30.0, 'B': 30.0},
          splitMode: SplitMode.equal,
          timestamp: DateTime.now(),
          createdBy: 'A',
        ),
      ];

      final aShare = calculator.getUserTotalShare('A', transactions);
      final bShare = calculator.getUserTotalShare('B', transactions);

      expect(aShare, equals(80.0)); // 50 + 30
      expect(bShare, equals(80.0)); // 50 + 30
    });
  });
}
