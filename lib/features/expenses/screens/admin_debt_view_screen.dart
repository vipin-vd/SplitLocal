import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/groups/models/user.dart';
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
          body: const Center(child: Text('Group not found')),);
    }

    if (deviceOwner == null || !deviceOwner.isDeviceOwner) {
      return Scaffold(
          appBar: AppBar(title: const Text('Admin View')),
          body: const Center(child: Text('Admin Only')),);
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

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.info, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Removal blocked: Outstanding debts exist. Please settle up before removing or leaving.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],),
            const SizedBox(height: 12),
            Row(children: [
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
                        final group = ref.read(selectedGroupProvider(groupId));
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
            ],),
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
    return Card(
      color: Colors.orange.shade50,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.admin_panel_settings),
            SizedBox(width: 12),
            Expanded(
                child: Text('Admin View: Only you can see this information'),),
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
    final debtCalculator = ref.watch(debtCalculatorServiceProvider);
    final transactions = ref.watch(groupTransactionsProvider(groupId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Who Paid What',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ...members.map((member) {
              final totalPaid =
                  debtCalculator.getUserTotalPaid(member.id, transactions);
              return _MemberSummaryRow(
                  member: member, value: totalPaid, currency: group.currency,);
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
    final debtCalculator = ref.watch(debtCalculatorServiceProvider);
    final transactions = ref.watch(groupTransactionsProvider(groupId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Each Member\'s Share',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ...members.map((member) {
              final totalShare =
                  debtCalculator.getUserTotalShare(member.id, transactions);
              return _MemberSummaryRow(
                  member: member, value: totalShare, currency: group.currency,);
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
    final netBalances = ref.watch(groupNetBalancesProvider(groupId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Net Balances',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ...members.map((member) {
              final balance = netBalances[member.id] ?? 0.0;
              return _BalanceRow(
                  member: member, balance: balance, currency: group.currency,);
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
    final simplifiedDebts = debtCalculator.simplifyDebts(transactions);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How to Settle Up',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            if (simplifiedDebts.isEmpty)
              const Text('All Settled Up!')
            else
              ...simplifiedDebts
                  // Filter out any debts that reference users no longer in the group
                  .where((debt) =>
                      members.any((u) => u.id == debt.fromUserId) &&
                      members.any((u) => u.id == debt.toUserId),)
                  .map((debt) {
                // Safe resolution of users; avoids StateError: No element
                final fromUser = members.firstWhere(
                    (u) => u.id == debt.fromUserId,
                    orElse: () =>
                        // Fallback should never hit due to the where() above
                        members.first,);
                final toUser = members.firstWhere((u) => u.id == debt.toUserId,
                    orElse: () => members.first,);
                return _DebtRow(
                  from: fromUser,
                  to: toUser,
                  amount: debt.amount,
                  currency: group.currency,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _MemberSummaryRow extends StatelessWidget {
  final User member;
  final double value;
  final String currency;

  const _MemberSummaryRow(
      {required this.member, required this.value, required this.currency,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(child: Text(member.name[0])),
          const SizedBox(width: 8),
          Expanded(child: Text(member.name)),
          Text(CurrencyFormatter.format(value, currencyCode: currency)),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final User member;
  final double balance;
  final String currency;

  const _BalanceRow(
      {required this.member, required this.balance, required this.currency,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(child: Text(member.name[0])),
          const SizedBox(width: 8),
          Expanded(child: Text(member.name)),
          Text(
            CurrencyFormatter.format(balance, currencyCode: currency),
            style: TextStyle(
                color: balance > 0
                    ? Colors.green
                    : (balance < 0 ? Colors.red : Colors.grey),),
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

  const _DebtRow(
      {required this.from,
      required this.to,
      required this.amount,
      required this.currency,});

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
