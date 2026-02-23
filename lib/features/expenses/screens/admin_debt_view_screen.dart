import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/shared/widgets/multi_currency_amount_text.dart';
import '../providers/transactions_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../shared/providers/services_provider.dart';
import '../../../shared/utils/formatters.dart';
import 'settle_up_screen.dart';

class AdminDebtViewScreen extends ConsumerWidget {
  final String groupId;
  final bool showRemovalBlockedBanner;

  const AdminDebtViewScreen({
    super.key,
    required this.groupId,
    this.showRemovalBlockedBanner = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId));
    final deviceOwner = ref.watch(deviceOwnerProvider);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin View')),
        body: const Center(child: Text('Group not found')),
      );
    }

    if (deviceOwner == null || !deviceOwner.isDeviceOwner) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin View')),
        body: const Center(child: Text('Admin Only')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Debt View')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (showRemovalBlockedBanner) _RemovalBlockedBanner(groupId: groupId),
          const _AdminNoticeCard(),
          const SizedBox(height: 16),
          _WhoPaidWhatCard(groupId: groupId),
          const SizedBox(height: 16),
          _MemberShareCard(groupId: groupId),
          const SizedBox(height: 16),
          _NetBalancesCard(groupId: groupId),
          const SizedBox(height: 16),
          _SettleUpCard(groupId: groupId),
        ],
      ),
    );
  }
}

class _RemovalBlockedBanner extends ConsumerWidget {
  final String groupId;
  const _RemovalBlockedBanner({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netBalances = ref.watch(groupNetBalancesProvider(groupId));
    final deviceOwner = ref.watch(deviceOwnerProvider);
    final myBalance =
        deviceOwner == null ? 0.0 : (netBalances[deviceOwner.id] ?? 0.0);
    final canLeave = myBalance.abs() < 0.01;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark
          ? Colors.red.shade900.withValues(alpha: 0.3)
          : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info,
                    color: isDark ? Colors.red.shade200 : Colors.red,),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Removal blocked: Outstanding debts exist. Please settle up before removing or leaving.',
                    style: TextStyle(
                        color: isDark ? Colors.red.shade200 : Colors.red,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.payments),
                  label: const Text('Open Settle Up'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettleUpScreen(groupId: groupId),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Leave Group'),
                  onPressed: canLeave
                      ? () async {
                          final group =
                              ref.read(selectedGroupProvider(groupId));
                          final owner = ref.read(deviceOwnerProvider);
                          if (group == null || owner == null) return;
                          final updated = group.copyWith(
                            memberIds: group.memberIds
                                .where((id) => id != owner.id)
                                .toList(),
                            updatedAt: DateTime.now(),
                          );
                          await ref
                              .read(groupsProvider.notifier)
                              .updateGroup(updated);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminNoticeCard extends StatelessWidget {
  const _AdminNoticeCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark
          ? Colors.orange.shade900.withValues(alpha: 0.3)
          : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.admin_panel_settings,
              color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Admin View: Only you can see this information',
                style: TextStyle(
                  color:
                      isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhoPaidWhatCard extends ConsumerWidget {
  final String groupId;
  const _WhoPaidWhatCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId))!;
    // Materialize members list to avoid multiple lazy iterations
    final members = ref
        .watch(usersProvider)
        .where((u) => group.memberIds.contains(u.id))
        .toList();
    final transactions = ref.watch(groupTransactionsProvider(groupId));

    // Calculate total paid by each user, grouped by currency
    final paidByUserByCurrency = <String, Map<String, double>>{};
    for (final member in members) {
      paidByUserByCurrency[member.id] = <String, double>{};
    }
    for (final t in transactions) {
      final currency = t.currency ?? group.currency;
      t.payers.forEach((userId, amount) {
        if (paidByUserByCurrency.containsKey(userId)) {
          paidByUserByCurrency[userId]![currency] =
              (paidByUserByCurrency[userId]![currency] ?? 0.0) + amount;
        }
      });
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who Paid What',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...members.map((member) {
              return _MemberSummaryRow(
                member: member,
                valuesByCurrency: paidByUserByCurrency[member.id] ?? {},
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MemberShareCard extends ConsumerWidget {
  final String groupId;
  const _MemberShareCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId))!;
    final members =
        ref.watch(usersProvider).where((u) => group.memberIds.contains(u.id));
    final transactions = ref.watch(groupTransactionsProvider(groupId));

    // Calculate share by each user, grouped by currency
    final shareByUserByCurrency = <String, Map<String, double>>{};
    for (final member in members) {
      shareByUserByCurrency[member.id] = <String, double>{};
    }
    for (final t in transactions) {
      final currency = t.currency ?? group.currency;
      t.splits.forEach((userId, amount) {
        if (shareByUserByCurrency.containsKey(userId)) {
          shareByUserByCurrency[userId]![currency] =
              (shareByUserByCurrency[userId]![currency] ?? 0.0) + amount;
        }
      });
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Each Member\'s Share',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...members.map((member) {
              return _MemberSummaryRow(
                member: member,
                valuesByCurrency: shareByUserByCurrency[member.id] ?? {},
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _NetBalancesCard extends ConsumerWidget {
  final String groupId;
  const _NetBalancesCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId))!;
    final members =
        ref.watch(usersProvider).where((u) => group.memberIds.contains(u.id));
    final transactions = ref.watch(groupTransactionsProvider(groupId));

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Net Balances',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...members.map((member) {
              return _BalanceRow(
                member: member,
                balancesByCurrency: netBalancesByCurrency[member.id] ?? {},
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SettleUpCard extends ConsumerWidget {
  final String groupId;
  const _SettleUpCard({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId))!;
    final members =
        ref.watch(usersProvider).where((u) => group.memberIds.contains(u.id));
    final debtCalculator = ref.watch(debtCalculatorServiceProvider);
    final transactions = ref.watch(groupTransactionsProvider(groupId));

    // Group transactions by currency
    final transactionsByCurrency = <String, List<dynamic>>{};
    for (final t in transactions) {
      final currency = t.currency ?? group.currency;
      transactionsByCurrency.putIfAbsent(currency, () => []).add(t);
    }

    // Calculate simplified debts per currency
    final debtsByCurrency = <String, List<dynamic>>{};
    for (final entry in transactionsByCurrency.entries) {
      final currency = entry.key;
      final currencyTransactions = entry.value.cast<dynamic>();
      final simplifiedDebts =
          debtCalculator.simplifyDebts(currencyTransactions.cast());
      if (simplifiedDebts.isNotEmpty) {
        debtsByCurrency[currency] = simplifiedDebts;
      }
    }

    final allSettled = debtsByCurrency.isEmpty ||
        debtsByCurrency.values.every((debts) => debts.isEmpty);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to Settle Up',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (allSettled)
              const Text('All Settled Up!')
            else
              ...debtsByCurrency.entries.expand((entry) {
                final currency = entry.key;
                final debts = entry.value;
                return [
                  if (debtsByCurrency.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Text(
                        currency,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ...debts
                      .where(
                    (debt) =>
                        members.any((u) => u.id == debt.fromUserId) &&
                        members.any((u) => u.id == debt.toUserId),
                  )
                      .map((debt) {
                    final fromUser = members.firstWhere(
                      (u) => u.id == debt.fromUserId,
                      orElse: () => members.first,
                    );
                    final toUser = members.firstWhere(
                      (u) => u.id == debt.toUserId,
                      orElse: () => members.first,
                    );
                    return _DebtRow(
                      from: fromUser,
                      to: toUser,
                      amount: debt.amount,
                      currency: currency,
                    );
                  }),
                ];
              }),
          ],
        ),
      ),
    );
  }
}

class _MemberSummaryRow extends StatelessWidget {
  final User member;
  final Map<String, double> valuesByCurrency;

  const _MemberSummaryRow({
    required this.member,
    required this.valuesByCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(child: Text(member.name[0])),
          const SizedBox(width: 8),
          Expanded(child: Text(member.name)),
          MultiCurrencyAmountText(amounts: valuesByCurrency),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final User member;
  final Map<String, double> balancesByCurrency;

  const _BalanceRow({
    required this.member,
    required this.balancesByCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(child: Text(member.name[0])),
          const SizedBox(width: 8),
          Expanded(child: Text(member.name)),
          MultiCurrencyAmountText(
            amounts: balancesByCurrency,
            positiveColor: Colors.green,
            negativeColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _DebtRow extends StatelessWidget {
  final User from;
  final User to;
  final double amount;
  final String currency;

  const _DebtRow({
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(from.name),
          const Icon(Icons.arrow_forward),
          Text(to.name),
          const Spacer(),
          Text(CurrencyFormatter.format(amount, currencyCode: currency)),
        ],
      ),
    );
  }
}
