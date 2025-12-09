import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/shared/utils/formatters.dart';
import 'groups_provider.dart';
import 'users_provider.dart';
import '../../expenses/providers/transactions_provider.dart';
import '../../../shared/providers/services_provider.dart';

part 'group_detail_provider.g.dart';

@riverpod
class ShowSimplifiedDebts extends _$ShowSimplifiedDebts {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

class GroupDetailScreenLogic {
  GroupDetailScreenLogic(this.ref);
  final GroupDetailScreenLogicRef ref;

  String generateGroupSummaryText(String groupId) {
    final group = ref.read(selectedGroupProvider(groupId));
    final netBalances = ref.read(groupNetBalancesProvider(groupId));
    final totalSpend = ref.read(groupTotalSpendProvider(groupId));
    final users = ref.read(usersProvider);
    final transactions = ref.read(groupTransactionsProvider(groupId));
    final debtCalculator = ref.read(debtCalculatorServiceProvider);

    if (group == null) return 'Group not found';

    final members = users.where((u) => group.memberIds.contains(u.id)).toList();

    final totalPaidByUser = <String, double>{};
    for (final member in members) {
      totalPaidByUser[member.id] =
          debtCalculator.getUserTotalPaid(member.id, transactions);
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 Group Summary: ${group.name}');
    buffer.writeln('');
    buffer.writeln(
        'Total Group Spend: ${CurrencyFormatter.format(totalSpend, currencyCode: group.currency)}');
    buffer.writeln('');
    buffer.writeln('Payments Made:');
    buffer.writeln('─────────────');

    for (final member in members) {
      final paid = totalPaidByUser[member.id] ?? 0.0;
      buffer.writeln(
          '${member.name} paid ${CurrencyFormatter.format(paid, currencyCode: group.currency)}');
    }

    buffer.writeln('');
    buffer.writeln('Current Balances:');
    buffer.writeln('─────────────');

    for (final member in members) {
      final balance = netBalances[member.id] ?? 0.0;
      if (balance > 0.01) {
        buffer.writeln(
            '${member.name} is owed ${CurrencyFormatter.format(balance.abs(), currencyCode: group.currency)}');
      } else if (balance < -0.01) {
        buffer.writeln(
            '${member.name} owes ${CurrencyFormatter.format(balance.abs(), currencyCode: group.currency)}');
      } else {
        buffer.writeln('${member.name} is settled up ✓');
      }
    }

    buffer.writeln('');
    buffer.writeln('Check the SplitLocal app for detailed breakdown!');

    return buffer.toString();
  }
}

@riverpod
GroupDetailScreenLogic groupDetailScreenLogic(GroupDetailScreenLogicRef ref) {
  return GroupDetailScreenLogic(ref);
}
