import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitlocal/features/expenses/models/expense_category.dart';
import 'package:splitlocal/features/expenses/models/transaction.dart';
import 'package:splitlocal/features/expenses/widgets/expense_details_sheet.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';
import 'package:mockito/mockito.dart';

// Mock simple transaction provider override if needed,
// but for this UI test we might just need to prevent the provider from throwing.
// The widget reads the notifier in build, so we need a valid provider.
// We can override the implementation of build in Transactions to return empty list.

class MockTransactions extends Transactions {
  @override
  List<Transaction> build() => [];
}

void main() {
  testWidgets(
      'ExpenseDetailsSheet throws error when user is missing from users list',
      (tester) async {
    // 1. Setup Data
    final presentUser = User(id: 'u1', name: 'Alice');
    final missingUserId = 'u2';

    final transaction = Transaction(
      id: 't1',
      groupId: 'g1',
      description: 'Dinner',
      totalAmount: 100.0,
      timestamp: DateTime.now(),
      category: ExpenseCategory.food,
      payers: {
        presentUser.id: 50.0,
        missingUserId: 50.0
      }, // u2 is paying but not in users list
      splits: {presentUser.id: 50.0, missingUserId: 50.0},
      type: TransactionType.expense, creatorId: 'u1',
    );

    // 2. Pump Widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionsProvider.overrideWith(() => MockTransactions()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ExpenseDetailsSheet(
              transaction: transaction,
              users: [presentUser], // missing u2
              currency: 'USD',
            ),
          ),
        ),
      ),
    );

    // 3. verifying that it throws is tricky with pumpWidget as it catches exceptions,
    // usually we expect tester.takeException()

    expect(tester.takeException(), isInstanceOf<StateError>());
  });
}
