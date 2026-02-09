import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/shared/utils/formatters.dart';
import 'groups_provider.dart';
import 'users_provider.dart';
import '../../expenses/providers/transactions_provider.dart';

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
    final users = ref.read(usersProvider);
    final transactions = ref.read(groupTransactionsProvider(groupId));

    if (group == null) return 'Group not found';

    final members = users.where((u) => group.memberIds.contains(u.id)).toList();

    // Calculate total spend grouped by currency
    final totalSpendByCurrency = <String, double>{};
    for (final t in transactions) {
      if (t.type.name == 'expense') {
        final currency = t.currency ?? group.currency;
        totalSpendByCurrency[currency] =
            (totalSpendByCurrency[currency] ?? 0.0) + t.totalAmount;
      }
    }

    // Calculate total paid by each user, grouped by currency
    final totalPaidByUserByCurrency = <String, Map<String, double>>{};
    for (final member in members) {
      totalPaidByUserByCurrency[member.id] = <String, double>{};
    }
    for (final t in transactions) {
      final currency = t.currency ?? group.currency;
      t.payers.forEach((userId, amount) {
        if (totalPaidByUserByCurrency.containsKey(userId)) {
          totalPaidByUserByCurrency[userId]![currency] =
              (totalPaidByUserByCurrency[userId]![currency] ?? 0.0) + amount;
        }
      });
    }

    // Calculate net balances grouped by currency
    final netBalancesByCurrency = <String, Map<String, double>>{};
    for (final member in members) {
      netBalancesByCurrency[member.id] = <String, double>{};
    }
    for (final t in transactions) {
      final currency = t.currency ?? group.currency;
      // Add what each payer paid
      t.payers.forEach((userId, amount) {
        if (netBalancesByCurrency.containsKey(userId)) {
          netBalancesByCurrency[userId]![currency] =
              (netBalancesByCurrency[userId]![currency] ?? 0.0) + amount;
        }
      });
      // Subtract what each person owes
      t.splits.forEach((userId, amount) {
        if (netBalancesByCurrency.containsKey(userId)) {
          netBalancesByCurrency[userId]![currency] =
              (netBalancesByCurrency[userId]![currency] ?? 0.0) - amount;
        }
      });
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 Group Summary: ${group.name}');
    buffer.writeln('');

    // Format total spend with multiple currencies
    if (totalSpendByCurrency.isEmpty) {
      buffer.writeln(
        'Total Group Spend: ${CurrencyFormatter.format(0, currencyCode: group.currency)}',
      );
    } else if (totalSpendByCurrency.length == 1) {
      final entry = totalSpendByCurrency.entries.first;
      buffer.writeln(
        'Total Group Spend: ${CurrencyFormatter.format(entry.value, currencyCode: entry.key)}',
      );
    } else {
      buffer.write('Total Group Spend: ');
      final parts = totalSpendByCurrency.entries
          .map((e) => CurrencyFormatter.format(e.value, currencyCode: e.key))
          .join(' + ');
      buffer.writeln(parts);
    }

    buffer.writeln('');
    buffer.writeln('Payments Made:');
    buffer.writeln('─────────────');

    for (final member in members) {
      final paidByCurrency = totalPaidByUserByCurrency[member.id] ?? {};
      if (paidByCurrency.isEmpty ||
          paidByCurrency.values.every((v) => v.abs() < 0.01)) {
        buffer.writeln(
          '${member.name} paid ${CurrencyFormatter.format(0, currencyCode: group.currency)}',
        );
      } else {
        final parts = paidByCurrency.entries
            .where((e) => e.value.abs() >= 0.01)
            .map((e) => CurrencyFormatter.format(e.value, currencyCode: e.key))
            .join(' + ');
        buffer.writeln('${member.name} paid $parts');
      }
    }

    buffer.writeln('');
    buffer.writeln('Current Balances:');
    buffer.writeln('─────────────');

    for (final member in members) {
      final balanceByCurrency = netBalancesByCurrency[member.id] ?? {};
      final nonZeroBalances = balanceByCurrency.entries
          .where((e) => e.value.abs() >= 0.01)
          .toList();

      if (nonZeroBalances.isEmpty) {
        buffer.writeln('${member.name} is settled up ✓');
      } else {
        // Group by positive (owed) and negative (owes)
        final owed = nonZeroBalances.where((e) => e.value > 0.01).toList();
        final owes = nonZeroBalances.where((e) => e.value < -0.01).toList();

        if (owed.isNotEmpty && owes.isEmpty) {
          final parts = owed
              .map(
                (e) => CurrencyFormatter.format(e.value, currencyCode: e.key),
              )
              .join(' + ');
          buffer.writeln('${member.name} is owed $parts');
        } else if (owes.isNotEmpty && owed.isEmpty) {
          final parts = owes
              .map(
                (e) => CurrencyFormatter.format(
                  e.value.abs(),
                  currencyCode: e.key,
                ),
              )
              .join(' + ');
          buffer.writeln('${member.name} owes $parts');
        } else {
          // Mixed - show both
          final owedParts = owed.isNotEmpty
              ? 'owed ${owed.map((e) => CurrencyFormatter.format(e.value, currencyCode: e.key)).join(' + ')}'
              : '';
          final owesParts = owes.isNotEmpty
              ? 'owes ${owes.map((e) => CurrencyFormatter.format(e.value.abs(), currencyCode: e.key)).join(' + ')}'
              : '';
          buffer.writeln(
            '${member.name}: $owedParts${owedParts.isNotEmpty && owesParts.isNotEmpty ? ', ' : ''}$owesParts',
          );
        }
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
