import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/services/debt_calculator_service.dart';

part 'group_balance_with_friend_provider.g.dart';

@riverpod
double groupBalanceWithFriend(
    GroupBalanceWithFriendRef ref, String groupId, String friendId,) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return 0.0;

  final groupTransactions = ref.watch(groupTransactionsProvider(groupId));
  final debtCalculator = DebtCalculatorService();
  final simplifiedDebts = debtCalculator.simplifyDebts(groupTransactions);

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
