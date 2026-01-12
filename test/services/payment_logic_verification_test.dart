import 'package:flutter_test/flutter_test.dart';
import 'package:splitlocal/services/debt_calculator_service.dart';
import 'package:splitlocal/features/expenses/models/transaction.dart';
import 'package:splitlocal/features/expenses/models/transaction_type.dart';
import 'package:splitlocal/features/expenses/models/split_mode.dart';

void main() {
  test('Verify payment logic correctness - Partial and Full Settlement', () {
    final calculator = DebtCalculatorService();

    // Setup: Alice owes Bob 50
    // Bob paid 100, split 50/50.
    final expense = Transaction(
      id: '1',
      groupId: 'g1',
      type: TransactionType.expense,
      description: 'Dinner',
      totalAmount: 100.0,
      payers: {'Bob': 100.0},
      splits: {'Alice': 50.0, 'Bob': 50.0},
      splitMode: SplitMode.equal,
      timestamp: DateTime.now(),
      createdBy: 'Bob',
    );

    // Setup: Alice pays Bob 50 to settle
    final payment = Transaction(
      id: '2',
      groupId: 'g1',
      type: TransactionType.payment,
      description: 'Settlement',
      totalAmount: 50.0,
      payers: {'Alice': 50.0},
      splits: {'Bob': 50.0},
      splitMode: SplitMode.unequal,
      timestamp: DateTime.now(),
      createdBy: 'Alice',
    );

    final balances = calculator.computeNetBalances([expense, payment]);

    // Alice Start: -50. Paid 50. End: 0.
    // Bob Start: +50. Received 50. End: 0.
    expect(balances['Alice'], closeTo(0.0, 0.01),
        reason: 'Alice should have settled her debt');
    expect(balances['Bob'], closeTo(0.0, 0.01),
        reason: 'Bob should have been paid back');
  });
}
