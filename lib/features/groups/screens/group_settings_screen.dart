import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/groups/screens/select_friends_screen.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../providers/groups_provider.dart';
import '../providers/users_provider.dart';
import '../providers/group_settings_provider.dart';
import '../../expenses/providers/transactions_provider.dart';
import '../../../shared/utils/dialogs.dart';
import '../../../shared/utils/currency.dart';
import '../widgets/add_member_manually_dialog.dart';
import '../widgets/edit_member_dialog.dart';

class GroupSettingsScreen extends ConsumerWidget {
  final Group group;

  const GroupSettingsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGroup = ref.watch(selectedGroupProvider(group.id));

    if (currentGroup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group Settings')),
        body: const Center(child: Text('Group not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Group Settings')),
      body: ListView(
        children: [
          _CurrencySection(group: currentGroup),
          _MembersSection(group: currentGroup),
          _GroupInfoSection(group: currentGroup),
          _DataManagementSection(group: currentGroup),
          _LeaveGroupSection(group: currentGroup),
          _DangerZoneSection(group: currentGroup),
        ],
      ),
    );
  }
}

class _CurrencySection extends ConsumerWidget {
  final Group group;
  const _CurrencySection({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        title: const Text('Group Currency'),
        subtitle:
            Text('Current: ${CurrencyHelper.getCurrency(group.currency).name}'),
        trailing: DropdownButton<String>(
          value: group.currency,
          items: CurrencyHelper.supportedCurrencies.map((currency) {
            return DropdownMenuItem(
              value: currency.code,
              child: Text('${currency.symbol} ${currency.code}'),
            );
          }).toList(),
          onChanged: (value) async {
            if (value != null && value != group.currency) {
              final confirmed = await showConfirmDialog(context,
                  title: 'Change Currency',
                  message:
                      'Changing currency will not convert existing amounts. Are you sure?');
              if (confirmed == true) {
                final logic =
                    ref.read(groupSettingsScreenLogicProvider.notifier);
                await logic.updateGroup(group.copyWith(currency: value));
              }
            }
          },
        ),
      ),
    );
  }
}

class _MembersSection extends ConsumerWidget {
  final Group group;
  const _MembersSection({required this.group});

  Future<void> _addMembers(BuildContext context, WidgetRef ref) async {
    final logic = ref.read(groupSettingsScreenLogicProvider.notifier);
    final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add Member'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, 'manual'),
                    child: const Text('Enter Manually')),
                TextButton(
                    onPressed: () => Navigator.pop(context, 'contacts'),
                    child: const Text('From Contacts')),
                TextButton(
                    onPressed: () => Navigator.pop(context, 'friends'),
                    child: const Text('From Friends')),
              ],
            ));

    if (choice == 'manual') {
      final user = await showDialog<User>(
          context: context,
          builder: (context) => const AddMemberManuallyDialog());
      if (user != null) await logic.addMemberManually(group, user);
    } else if (choice == 'contacts') {
      await logic.addMemberFromContacts(group);
    } else if (choice == 'friends') {
      final selectedFriends = await Navigator.push<List<User>>(
        context,
        MaterialPageRoute(
          builder: (context) => const SelectFriendsScreen(),
        ),
      );
      if (selectedFriends != null) {
        for (final friend in selectedFriends) {
          await logic.addMemberManually(group, friend);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref
        .watch(usersProvider)
        .where((u) => group.memberIds.contains(u.id))
        .toList();
    final deviceOwner = ref.watch(deviceOwnerProvider);
    final netBalances = ref.watch(groupNetBalancesProvider(group.id));
    final isCreator = deviceOwner != null && group.createdBy == deviceOwner.id;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          ListTile(
            title: const Text('Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            trailing: isCreator
                ? TextButton.icon(
                    onPressed: () => _addMembers(context, ref),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add'))
                : null,
          ),
          ...members.map((user) => ListTile(
                title: Text(user.name),
                trailing: user.isDeviceOwner
                    ? const Chip(label: Text('You'))
                    : isCreator
                        ? Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final updatedUser = await showDialog<User>(
                                      context: context,
                                      builder: (context) =>
                                          EditMemberDialog(user: user));
                                  if (updatedUser != null) {
                                    ref
                                        .read(groupSettingsScreenLogicProvider
                                            .notifier)
                                        .updateUser(updatedUser);
                                  }
                                }),
                            _RemoveButtonWithGuard(
                              user: user,
                              group: group,
                              balance: netBalances[user.id] ?? 0.0,
                            ),
                          ])
                        : null,
              )),
        ],
      ),
    );
  }
}

class _RemoveButtonWithGuard extends ConsumerWidget {
  final User user;
  final Group group;
  final double balance;

  const _RemoveButtonWithGuard({
    required this.user,
    required this.group,
    required this.balance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDebt = balance.abs() >= 0.01;

    if (hasDebt) {
      return Tooltip(
        message: 'Outstanding debts must be settled before removing',
        child: IconButton(
          icon: const Icon(Icons.remove_circle),
          onPressed: () => _showDebtDialog(context, ref),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.remove_circle),
      onPressed: () => _showRemoveConfirmation(context, ref),
    );
  }

  Future<void> _showDebtDialog(BuildContext context, WidgetRef ref) async {
    final logic = ref.read(groupSettingsScreenLogicProvider.notifier);
    final balanceInfo =
        logic.getMemberBalanceInfo(user, balance, group.currency);

    final suggestions = [
      'Add a payment transaction between ${user.name} and another group member',
      'Adjust or delete related expenses to settle the balance',
      'Have ${user.name} settle their outstanding amount',
    ];

    await showSettleDebtsDialog(
      context,
      title: 'Cannot Remove Member',
      memberName: user.name,
      debtInfo: balanceInfo,
      suggestions: suggestions,
      actionText: 'Back',
    );
  }

  Future<void> _showRemoveConfirmation(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove member?',
      message: 'Are you sure you want to remove ${user.name}?',
    );

    if (confirmed == true && context.mounted) {
      final logic = ref.read(groupSettingsScreenLogicProvider.notifier);
      final success = await logic.removeMember(group, user.id);
      if (success && context.mounted) {
        showSnackBar(context, '${user.name} has been removed from the group');
      }
    }
  }
}

class _GroupInfoSection extends StatelessWidget {
  final Group group;
  const _GroupInfoSection({required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Group Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ListTile(title: const Text('Group Name'), subtitle: Text(group.name)),
          if (group.description != null)
            ListTile(
                title: const Text('Description'),
                subtitle: Text(group.description!)),
          ListTile(
              title: const Text('Created'),
              subtitle: Text(group.createdAt.toString().split('.')[0])),
        ],
      ),
    );
  }
}

class _DataManagementSection extends ConsumerWidget {
  final Group group;
  const _DataManagementSection({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ListTile(
        leading: const Icon(Icons.share),
        title: const Text('Export Group Data'),
        onTap: () async {
          final success = await ref
              .read(groupSettingsScreenLogicProvider.notifier)
              .exportGroup(group.id);
          if (success) showSnackBar(context, 'Group data exported');
        },
      ),
    );
  }
}

class _DangerZoneSection extends ConsumerWidget {
  final Group group;
  const _DangerZoneSection({required this.group});

  Future<void> _deleteGroup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => const _DeleteGroupDialog());
    if (confirmed == true && context.mounted) {
      final logic = ref.read(groupSettingsScreenLogicProvider.notifier);
      final success = await logic.deleteGroup(group.id);
      if (success && context.mounted) {
        Navigator.of(context)
          ..pop()
          ..pop();
        showSnackBar(context, 'Group deleted');
      } else if (context.mounted) {
        // Show debt warning dialog
        _showDeleteBlockedDialog(context, ref);
      }
    }
  }

  Future<void> _showDeleteBlockedDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final netBalances = ref.read(groupNetBalancesProvider(group.id));
    final users = ref.read(usersProvider);
    final outstandingMembers = <String>[];

    for (final entry in netBalances.entries) {
      if (entry.value.abs() >= 0.01) {
        final member = users.firstWhere(
          (u) => u.id == entry.key,
          orElse: () => null as User,
        );
        if (member != null) {
          final logic = ref.read(groupSettingsScreenLogicProvider.notifier);
          outstandingMembers.add(
            logic.getMemberBalanceInfo(member, entry.value, group.currency),
          );
        }
      }
    }

    await showSettleDebtsDialog(
      context,
      title: 'Cannot Delete Group',
      memberName: 'This group',
      debtInfo: 'Outstanding balances:\n• ${outstandingMembers.join('\n• ')}',
      suggestions: [
        'Settle all outstanding member balances',
        'Add payment transactions to clear debts',
        'Adjust or delete expenses as needed',
      ],
      actionText: 'Back',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceOwner = ref.watch(deviceOwnerProvider);
    final isCreator = deviceOwner != null && group.createdBy == deviceOwner.id;

    if (!isCreator) {
      return const SizedBox.shrink(); // Only show for group creator
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: Colors.red.shade50,
      child: ListTile(
        leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
        title:
            Text('Delete Group', style: TextStyle(color: Colors.red.shade900)),
        onTap: () => _deleteGroup(context, ref),
      ),
    );
  }
}

class _LeaveGroupSection extends ConsumerWidget {
  final Group group;
  const _LeaveGroupSection({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceOwner = ref.watch(deviceOwnerProvider);
    final netBalances = ref.watch(groupNetBalancesProvider(group.id));
    final myBalance =
        deviceOwner == null ? 0.0 : (netBalances[deviceOwner.id] ?? 0.0);
    final canLeave = myBalance.abs() < 0.01;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: canLeave ? null : Colors.grey.shade200,
      child: ListTile(
        leading: const Icon(Icons.exit_to_app),
        title: const Text('Leave Group'),
        subtitle: canLeave
            ? null
            : Text(
                'You have outstanding debts (${CurrencyHelper.getCurrency(group.currency).symbol}${myBalance.abs().toStringAsFixed(2)}) that must be settled before leaving',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
        enabled: canLeave && deviceOwner != null,
        onTap: canLeave && deviceOwner != null
            ? () => _showLeaveConfirmation(context, ref, deviceOwner!)
            : !canLeave && deviceOwner != null
                ? () => _showDebtDialog(context, ref, deviceOwner!, myBalance)
                : null,
      ),
    );
  }

  Future<void> _showLeaveConfirmation(
    BuildContext context,
    WidgetRef ref,
    User deviceOwner,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Leave Group?',
      message: 'Are you sure you want to leave "${group.name}"?',
      confirmText: 'Leave',
    );

    if (confirmed == true && context.mounted) {
      final logic = ref.read(groupSettingsScreenLogicProvider.notifier);
      final success = await logic.removeMember(group, deviceOwner.id);
      if (success && context.mounted) {
        Navigator.of(context).pop();
        showSnackBar(context, 'You left the group');
      }
    }
  }

  Future<void> _showDebtDialog(
    BuildContext context,
    WidgetRef ref,
    User deviceOwner,
    double myBalance,
  ) async {
    final logic = ref.read(groupSettingsScreenLogicProvider.notifier);
    final balanceInfo =
        logic.getMemberBalanceInfo(deviceOwner, myBalance, group.currency);

    final suggestions = [
      'Add a payment transaction to settle your balance',
      'Adjust or delete related expenses to settle your balance',
      'Ask other members for assistance in settling the account',
    ];

    await showSettleDebtsDialog(
      context,
      title: 'Cannot Leave Group',
      memberName: 'You',
      debtInfo: balanceInfo,
      suggestions: suggestions,
      actionText: 'Back',
    );
  }
}

class _DeleteGroupDialog extends ConsumerWidget {
  const _DeleteGroupDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(deleteGroupDialogProvider);
    final controller = provider.$1;
    final isValid = provider.$2;

    return AlertDialog(
      title: const Text('Delete Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'This action cannot be undone. All data will be lost. Type "delete" to confirm.'),
          TextField(controller: controller, autofocus: true),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: isValid ? () => Navigator.pop(context, true) : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
