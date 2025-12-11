import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:splitlocal/features/expenses/models/transaction.dart';
import 'package:splitlocal/features/expenses/models/transaction_type.dart';
import 'package:splitlocal/features/expenses/models/split_mode.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/shared/providers/net_totals_provider.dart';

// Helper classes for provider overrides
class _FakeTransactions extends Transactions {
  _FakeTransactions(this._txs);
  final List<Transaction> _txs;
  @override
  List<Transaction> build() => _txs;
}

class _EmptyTransactions extends Transactions {
  @override
  List<Transaction> build() => <Transaction>[];
}

void main() {
  group('Global net totals providers', () {
    late ProviderContainer container;

    // Test users
    const meId = 'me-1';
    const aId = 'a-1';
    const bId = 'b-1';

    setUp(() {
      // Build valid transactions
      final txs = <Transaction>[
        // Me owes A: 10 (A paid 20 split equally)
        Transaction(
          id: 't1',
          groupId: 'g1',
          type: TransactionType.expense,
          description: 'Dinner',
          totalAmount: 20,
          payers: {aId: 20},
          splits: {meId: 10, aId: 10},
          splitMode: SplitMode.equal,
          timestamp: DateTime(2024, 01, 02),
          createdBy: aId,
        ),
        // B owes Me: 15 (Me paid 30 split equally)
        Transaction(
          id: 't2',
          groupId: 'g2',
          type: TransactionType.expense,
          description: 'Cab',
          totalAmount: 30,
          payers: {meId: 30},
          splits: {meId: 15, bId: 15},
          splitMode: SplitMode.equal,
          timestamp: DateTime(2024, 01, 03),
          createdBy: meId,
        ),
        // Tiny noise below threshold: Me owes A: 0.005 (A paid 0.01 split equally)
        Transaction(
          id: 't3',
          groupId: 'g3',
          type: TransactionType.expense,
          description: 'Water',
          totalAmount: 0.01,
          payers: {aId: 0.01},
          splits: {meId: 0.005, aId: 0.005},
          splitMode: SplitMode.equal,
          timestamp: DateTime(2024, 01, 04),
          createdBy: aId,
        ),
      ];

      container = ProviderContainer(
        overrides: [
          deviceOwnerProvider.overrideWith(
            (ref) => User(
              id: meId,
              name: 'Me',
              phoneNumber: null,
              isDeviceOwner: true,
              createdAt: DateTime(2024, 1, 1),
            ),
          ),
          transactionsProvider.overrideWith(() => _FakeTransactions(txs)),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('allNetBalancesProvider builds map of net vs others', () {
      final net = container.read(allNetBalancesProvider);
      // Me owes A: 10 + 0.005 = 10.005
      expect((net[aId] ?? 0).toStringAsFixed(3), (-10.005).toStringAsFixed(3));
      // B owes Me: 15
      expect((net[bId] ?? 0).toStringAsFixed(3), (15.0).toStringAsFixed(3));
    });

    test('totals respect 0.01 threshold and compute net', () {
      final owed = container.read(totalOwedToUserGlobalProvider);
      final owes = container.read(totalUserOwesGlobalProvider);
      final net = container.read(netBalanceGlobalProvider);

      // owed: 15 (from B)
      expect(owed.toStringAsFixed(2), '15.00');
      // owes: 10.005 (to A)
      expect(owes.toStringAsFixed(3), '10.005');
      // net: 15 - 10.005 = 4.995
      expect(net.toStringAsFixed(3), '4.995');
    });

    test('empty transactions => all zeros', () {
      final empty = ProviderContainer(
        overrides: [
          deviceOwnerProvider.overrideWith(
            (ref) => User(
              id: meId,
              name: 'Me',
              phoneNumber: null,
              isDeviceOwner: true,
              createdAt: DateTime(2024, 1, 1),
            ),
          ),
          transactionsProvider.overrideWith(() => _EmptyTransactions()),
        ],
      );

      expect(empty.read(allNetBalancesProvider), isEmpty);
      expect(empty.read(totalOwedToUserGlobalProvider), 0);
      expect(empty.read(totalUserOwesGlobalProvider), 0);
      expect(empty.read(netBalanceGlobalProvider), 0);

      empty.dispose();
    });

    test('no device owner => zeros', () {
      final noOwner = ProviderContainer(overrides: [
        deviceOwnerProvider.overrideWith((ref) => null),
        transactionsProvider.overrideWith(() => _EmptyTransactions()),
      ],);
      expect(noOwner.read(totalOwedToUserGlobalProvider), 0);
      expect(noOwner.read(totalUserOwesGlobalProvider), 0);
      expect(noOwner.read(netBalanceGlobalProvider), 0);
      noOwner.dispose();
    });
  });
}
