import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/features/expenses/widgets/add_expense_entry.dart';
import 'package:splitlocal/features/expenses/widgets/transaction_tile.dart';
import 'package:splitlocal/features/expenses/widgets/expense_details_sheet.dart';
import 'package:splitlocal/features/friends/providers/friend_balance_provider.dart';
import 'package:splitlocal/features/friends/providers/friend_group_provider.dart';
import 'package:splitlocal/features/friends/providers/group_balance_with_friend_provider.dart';
import 'package:splitlocal/features/friends/screens/friend_settings_screen.dart';
import 'package:splitlocal/features/groups/models/group.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/features/groups/screens/group_detail_screen.dart';
import 'package:splitlocal/features/expenses/screens/settle_up_screen.dart';
import 'package:splitlocal/shared/ui/buttons/settle_up_button.dart';
import 'package:splitlocal/shared/ui/dialogs/choose_group_dialog.dart';
import 'package:splitlocal/shared/utils/formatters.dart';

class FriendDetailScreen extends ConsumerWidget {
  final User friend;

  const FriendDetailScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(friendBalanceProvider(friend.id));
    final me = ref.watch(deviceOwnerProvider);
    final allGroups = ref.watch(groupsProvider);
    final sharedGroups = allGroups
        .where((g) =>
            !g.isFriendGroup &&
            g.memberIds.contains(me!.id) &&
            g.memberIds.contains(friend.id))
        .toList();
    final friendGroup = ref.watch(friendGroupProvider(friend.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(friend.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Friend Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendSettingsScreen(friend: friend),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BalanceSummary(balance: balance),
          const SizedBox(height: 24),
          _SharedGroups(
            friend: friend,
            sharedGroups: sharedGroups,
          ),
          const SizedBox(height: 24),
          friendGroup.when(
            data: (group) => _IndividualTransactions(group: group),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      floatingActionButton: _FloatingActionButtons(
        friend: friend,
        sharedGroups: sharedGroups,
        friendGroup: friendGroup.value,
      ),
    );
  }
}

class _FloatingActionButtons extends ConsumerWidget {
  final User friend;
  final List<Group> sharedGroups;
  final Group? friendGroup;

  const _FloatingActionButtons({
    required this.friend,
    required this.sharedGroups,
    this.friendGroup,
  });

  Future<void> _handleSettleUp(BuildContext context, WidgetRef ref) async {
    // Build a list of all groups where settle-up is possible
    final allSettleableGroups = <Group>[];

    // Add shared groups (non-friend groups)
    allSettleableGroups.addAll(sharedGroups);

    // Add friend group if it exists
    if (friendGroup != null) {
      allSettleableGroups.add(friendGroup!);
    }

    if (allSettleableGroups.isEmpty) {
      // No groups at all - shouldn't happen but handle gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add this friend to a group first to settle up'),
        ),
      );
      return;
    }

    if (allSettleableGroups.length == 1) {
      // Single group - navigate directly
      final deviceOwner = ref.read(deviceOwnerProvider);
      final balance = ref.read(groupBalanceWithFriendProvider(
        allSettleableGroups.first.id,
        friend.id,
      ));

      // If balance > 0, friend owes you (you receive payment)
      // If balance < 0, you owe friend (you pay)
      final String? payer;
      final String? recipient;
      if (balance > 0) {
        // Friend owes you - friend pays, you receive
        payer = friend.id;
        recipient = deviceOwner?.id;
      } else {
        // You owe friend - you pay, friend receives
        payer = deviceOwner?.id;
        recipient = friend.id;
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettleUpScreen(
              groupId: allSettleableGroups.first.id,
              prePopulatePayer: payer,
              prePopulateRecipient: recipient,
              prePopulateAmount: balance,
            ),
          ),
        );
      }
      return;
    }

    // Multiple groups - show chooser
    final selectedGroup = await showChooseGroupDialog(
      context: context,
      groups: allSettleableGroups,
      title: 'Settle Up In',
      subtitle: 'Choose which group to settle debts in',
    );

    if (selectedGroup != null && context.mounted) {
      final deviceOwner = ref.read(deviceOwnerProvider);
      final balance = ref.read(groupBalanceWithFriendProvider(
        selectedGroup.id,
        friend.id,
      ));

      // If balance > 0, friend owes you (you receive payment)
      // If balance < 0, you owe friend (you pay)
      final String? payer;
      final String? recipient;
      if (balance > 0) {
        // Friend owes you - friend pays, you receive
        payer = friend.id;
        recipient = deviceOwner?.id;
      } else {
        // You owe friend - you pay, friend receives
        payer = deviceOwner?.id;
        recipient = friend.id;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SettleUpScreen(
            groupId: selectedGroup.id,
            prePopulatePayer: payer,
            prePopulateRecipient: recipient,
            prePopulateAmount: balance,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show settle-up if there are shared groups OR if friendGroup exists
    final showSettleUp = sharedGroups.isNotEmpty || friendGroup != null;

    if (!showSettleUp) {
      return AddExpenseEntry(friendId: friend.id);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'settle',
          onPressed: () => _handleSettleUp(context, ref),
          backgroundColor: Colors.green,
          tooltip: 'Settle Up',
          child: const Icon(Icons.payments),
        ),
        const SizedBox(height: 12),
        AddExpenseEntry(
          friendId: friend.id,
          heroTag: 'expense',
        ),
      ],
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  final double balance;

  const _BalanceSummary({required this.balance});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPositive = balance > 0;
    final isZero = balance.abs() < 0.01;
    // Keep a soothing, neutral background and only color the amount text.
    final containerColor = scheme.surfaceVariant;
    final onContainerColor = scheme.onSurfaceVariant;

    return Card(
      elevation: 1,
      color: containerColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Balance',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: onContainerColor),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: onContainerColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isZero
                        ? 'Settled'
                        : isPositive
                            ? 'They owe you'
                            : 'You owe them',
                    style: TextStyle(color: onContainerColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.format(balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isZero
                        ? onContainerColor
                        : (isPositive ? Colors.green : Colors.red),
                  ),
            ),
            // Status wording is already conveyed by the chip; avoid duplication.
          ],
        ),
      ),
    );
  }
}

class _SharedGroups extends ConsumerWidget {
  final User friend;
  final List<Group> sharedGroups;

  const _SharedGroups({required this.friend, required this.sharedGroups});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceOwner = ref.watch(deviceOwnerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shared Groups',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (sharedGroups.isEmpty)
          const Text('No shared groups yet.')
        else
          ...sharedGroups.map(
            (group) {
              final balance = ref
                  .watch(groupBalanceWithFriendProvider(group.id, friend.id));

              // If balance > 0, friend owes you (you receive payment)
              // If balance < 0, you owe friend (you pay)
              final String? payer;
              final String? recipient;
              if (balance > 0) {
                // Friend owes you - friend pays, you receive
                payer = friend.id;
                recipient = deviceOwner?.id;
              } else {
                // You owe friend - you pay, friend receives
                payer = deviceOwner?.id;
                recipient = friend.id;
              }

              return ListTile(
                title: Text(group.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.format(balance),
                      style: TextStyle(
                        color: balance > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SettleUpIconButton(
                      groupId: group.id,
                      iconSize: 20,
                      prePopulatePayer: payer,
                      prePopulateRecipient: recipient,
                      prePopulateAmount: balance,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupDetailScreen(groupId: group.id),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _IndividualTransactions extends ConsumerWidget {
  final Group group;

  const _IndividualTransactions({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(groupTransactionsProvider(group.id));
    final users = ref.watch(usersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Individual Transactions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          const Text('No individual transactions yet.')
        else
          ...transactions.map(
            (transaction) => TransactionTile(
              transaction: transaction,
              users: users,
              currency: group.currency,
              onTap: () => showExpenseDetailsSheet(
                context: context,
                transaction: transaction,
                users: users,
                currency: group.currency,
              ),
            ),
          ),
      ],
    );
  }
}
