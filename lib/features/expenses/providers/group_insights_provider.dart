import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';
import 'transactions_provider.dart';

part 'group_insights_provider.g.dart';

@riverpod
double userTotalPaid(UserTotalPaidRef ref, String groupId) {
  final deviceOwner = ref.watch(deviceOwnerProvider);
  final transactions = ref.watch(groupTransactionsProvider(groupId));
  final debtCalculator = ref.watch(debtCalculatorServiceProvider);
  if (deviceOwner == null) return 0.0;
  return debtCalculator.getUserTotalPaid(deviceOwner.id, transactions);
}

@riverpod
double userTotalShare(UserTotalShareRef ref, String groupId) {
  final deviceOwner = ref.watch(deviceOwnerProvider);
  final transactions = ref.watch(groupTransactionsProvider(groupId));
  final debtCalculator = ref.watch(debtCalculatorServiceProvider);
  if (deviceOwner == null) return 0.0;
  return debtCalculator.getUserTotalShare(deviceOwner.id, transactions);
}
