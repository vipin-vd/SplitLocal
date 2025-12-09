import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:splitlocal/features/expenses/models/transaction.dart';
import 'package:splitlocal/features/expenses/models/transaction_type.dart';
import 'package:splitlocal/features/expenses/models/split_mode.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/features/friends/providers/friend_balance_provider.dart';
import 'package:splitlocal/features/friends/providers/friends_provider.dart';
import 'package:splitlocal/features/groups/models/group.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';

// Helper classes for provider overrides
class _FakeTransactions extends Transactions {
  _FakeTransactions(this._txs);
  final List<Transaction> _txs;
  @override
  List<Transaction> build() => _txs;
}

class _FakeGroups extends Groups {
  _FakeGroups(this._groups);
  final List<Group> _groups;
  @override
  List<Group> build() => _groups;
}

class _FakeFriends extends Friends {
  _FakeFriends(this._friends);
  final List<User> _friends;
  @override
  List<User> build() => _friends;
}

class _EmptyTransactions extends Transactions {
  @override
  List<Transaction> build() => <Transaction>[];
}

void main() {
  group('Friend balances providers', () {
    late ProviderContainer container;

    const meId = 'me-1';
    const friendId = 'f-1';

    setUp(() {
      // Shared group and friend
      final groups = [
        Group(
          id: 'g1',
          name: 'Trip',
          description: null,
          memberIds: const [meId, friendId],
          createdBy: meId,
          createdAt: DateTime(2024, 01, 02),
          updatedAt: null,
          currency: 'USD',
          isFriendGroup: false,
        ),
      ];
      final friends = [
        User(
          id: friendId,
          name: 'Alice',
          phoneNumber: null,
          isDeviceOwner: false,
          createdAt: DateTime(  2024, 01, 01),
        ),
      ];

      // Transactions in the shared group
      final txs = <Transaction>[
        Transaction(
          id: 't1',
          groupId: 'g1',
          type: TransactionType.expense,
          description: 'Dinner',
          totalAmount: 40,
          payers: {friendId: 40},
          splits: {meId: 20, friendId: 20},
          splitMode: SplitMode.equal,
          timestamp: DateTime(2024, 01, 03),
          createdBy: friendId,
        ),
        Transaction(
          id: 't2',
          groupId: 'g1',
          type: TransactionType.expense,
          description: 'Taxi',
          totalAmount: 30,
          payers: {meId: 30},
          splits: {meId: 15, friendId: 15},
          splitMode: SplitMode.equal,
          timestamp: DateTime(2024, 01, 04),
          createdBy: meId,
        ),
      ];

      container = ProviderContainer(overrides: [
        deviceOwnerProvider.overrideWith((ref) => User(
              id: meId,
              name: 'Me',
              phoneNumber: null,
              isDeviceOwner: true,
              createdAt: DateTime(2024, 01, 01),
            )),
        groupsProvider.overrideWith(() => _FakeGroups(groups)),
        friendsProvider.overrideWith(() => _FakeFriends(friends)),
        transactionsProvider.overrideWith(() => _FakeTransactions(txs)),
      ]);
    });

    tearDown(() => container.dispose());

    test('friendBalanceProvider computes net vs friend', () {
      final bal = container.read(friendBalanceProvider(friendId));
      // Me owes 20, friend owes 15 => net -5 (I owe 5)
      expect(bal.toStringAsFixed(2), '-5.00');
    });

    test('allFriendBalancesProvider aggregates and zeroBalanceFriendIds', () {
      final all = container.read(allFriendBalancesProvider);
      expect(all[friendId]?.toStringAsFixed(2), '-5.00');
      final zeroIds = container.read(zeroBalanceFriendIdsProvider);
      expect(zeroIds, isEmpty);
    });

    test('no shared groups => zero balance', () {
      final groups2 = [
        Group(
          id: 'g2',
          name: 'Other',
          description: null,
          memberIds: const [meId],
          createdBy: meId,
          createdAt: DateTime(2024, 01, 05),
          updatedAt: null,
          currency: 'USD',
          isFriendGroup: false,
        ),
      ];
      final friends2 = [
        User(
          id: friendId,
          name: 'Alice',
          phoneNumber: null,
          isDeviceOwner: false,
          createdAt: DateTime(  2024, 01, 01),
        ),
      ];
      final isolated = ProviderContainer(overrides: [
        deviceOwnerProvider.overrideWith((ref) => User(
              id: meId,
              name: 'Me',
              phoneNumber: null,
              isDeviceOwner: true,
              createdAt: DateTime(  2024, 01, 01),
            )),
        groupsProvider.overrideWith(() => _FakeGroups(groups2)),
        friendsProvider.overrideWith(() => _FakeFriends(friends2)),
        transactionsProvider.overrideWith(() => _EmptyTransactions()),
      ]);

      expect(isolated.read(friendBalanceProvider(friendId)), 0);
      expect(isolated.read(allFriendBalancesProvider)[friendId], 0);
      expect(isolated.read(zeroBalanceFriendIdsProvider), [friendId]);

      isolated.dispose();
    });
  });
}
