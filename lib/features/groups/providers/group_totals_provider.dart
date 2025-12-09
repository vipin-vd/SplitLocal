import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'groups_provider.dart';
import 'users_provider.dart';
import '../../expenses/providers/transactions_provider.dart';

part 'group_totals_provider.g.dart';

/// Total amount the user is owed across all non-friend groups
@riverpod
double totalOwedToUserAcrossGroups(TotalOwedToUserAcrossGroupsRef ref) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return 0.0;

  final groups =
      ref.watch(groupsProvider).where((g) => !g.isFriendGroup).toList();

  double total = 0.0;
  for (final g in groups) {
    final balances = ref.watch(groupNetBalancesProvider(g.id));
    final my = balances[me.id] ?? 0.0;
    if (my > 0.01) total += my;
  }
  return total;
}

/// Total amount the user owes across all non-friend groups (returned positive)
@riverpod
double totalUserOwesAcrossGroups(TotalUserOwesAcrossGroupsRef ref) {
  final me = ref.watch(deviceOwnerProvider);
  if (me == null) return 0.0;

  final groups =
      ref.watch(groupsProvider).where((g) => !g.isFriendGroup).toList();

  double total = 0.0;
  for (final g in groups) {
    final balances = ref.watch(groupNetBalancesProvider(g.id));
    final my = balances[me.id] ?? 0.0;
    if (my < -0.01) total += -my;
  }
  return total;
}

/// Net balance across all non-friend groups
@riverpod
double netBalanceAcrossGroups(NetBalanceAcrossGroupsRef ref) {
  final owed = ref.watch(totalOwedToUserAcrossGroupsProvider);
  final owes = ref.watch(totalUserOwesAcrossGroupsProvider);
  final net = owed - owes;
  return net.abs() < 0.01 ? 0.0 : net;
}
