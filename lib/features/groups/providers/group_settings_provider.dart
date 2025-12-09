import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/groups/models/group.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';
import 'package:splitlocal/shared/utils/currency.dart';
import 'package:uuid/uuid.dart';

part 'group_settings_provider.g.dart';

@riverpod
class DeleteGroupDialog extends _$DeleteGroupDialog {
  @override
  (TextEditingController, bool) build() {
    final controller = TextEditingController();
    controller.addListener(() {
      state = (controller, controller.text.trim().toLowerCase() == 'delete');
    });
    ref.onDispose(() {
      controller.dispose();
    });
    return (controller, false);
  }
}

@riverpod
class GroupSettingsScreenLogic extends _$GroupSettingsScreenLogic {
  @override
  void build() {}

  Future<void> addMemberManually(Group group, User user) async {
    final usersNotifier = ref.read(usersProvider.notifier);
    final groupsNotifier = ref.read(groupsProvider.notifier);

    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      final existing = ref
          .read(usersProvider)
          .where((u) => u.phoneNumber == user.phoneNumber)
          .firstOrNull;
      if (existing != null) {
        if (!group.memberIds.contains(existing.id)) {
          final updatedGroup =
              group.copyWith(memberIds: [...group.memberIds, existing.id]);
          await groupsNotifier.updateGroup(updatedGroup);
        }
        return;
      }
    }

    await usersNotifier.addUser(user);
    final updatedGroup =
        group.copyWith(memberIds: [...group.memberIds, user.id]);
    await groupsNotifier.updateGroup(updatedGroup);
  }

  Future<void> addMemberFromContacts(Group group) async {
    final contactsService = ref.read(contactsServiceProvider);
    final contactData = await contactsService.pickContact();
    if (contactData == null) return;

    final name = contactData['name'] ?? 'Unknown';
    final phoneNumber = contactData['phoneNumber'];

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final existing = ref
          .read(usersProvider)
          .where((u) => u.phoneNumber == phoneNumber)
          .firstOrNull;
      if (existing != null) {
        if (!group.memberIds.contains(existing.id)) {
          final updatedGroup =
              group.copyWith(memberIds: [...group.memberIds, existing.id]);
          await ref.read(groupsProvider.notifier).updateGroup(updatedGroup);
        }
        return;
      }
    }

    final newUser = User(
      id: const Uuid().v4(),
      name: name,
      phoneNumber: phoneNumber,
      isDeviceOwner: false,
      createdAt: DateTime.now(),
    );
    await ref.read(usersProvider.notifier).addUser(newUser);
    final updatedGroup =
        group.copyWith(memberIds: [...group.memberIds, newUser.id]);
    await ref.read(groupsProvider.notifier).updateGroup(updatedGroup);
  }

  Future<bool> removeMember(Group group, String userId) async {
    final netBalances = ref.read(groupNetBalancesProvider(group.id));
    final userBalance = netBalances[userId] ?? 0.0;
    final balanceThreshold = 0.01;

    // Check if user has outstanding balance
    if (userBalance.abs() >= balanceThreshold) {
      return false; // Block removal; caller will show dialog
    }

    final updatedGroup = group.copyWith(
        memberIds: group.memberIds.where((id) => id != userId).toList());
    await ref.read(groupsProvider.notifier).updateGroup(updatedGroup);
    return true; // Removal successful
  }

  Future<void> updateUser(User user) async {
    await ref.read(usersProvider.notifier).updateUser(user);
  }

  Future<void> updateGroup(Group group) async {
    await ref.read(groupsProvider.notifier).updateGroup(group);
  }

  Future<bool> deleteGroup(String groupId) async {
    final group = ref.read(selectedGroupProvider(groupId));
    if (group == null) return false;

    final netBalances = ref.read(groupNetBalancesProvider(groupId));
    final balanceThreshold = 0.01;

    // Check if any member has outstanding balance
    for (final balance in netBalances.values) {
      if (balance.abs() >= balanceThreshold) {
        return false; // Block deletion; caller will show dialog
      }
    }

    await ref.read(groupsProvider.notifier).deleteGroup(groupId);
    return true; // Deletion successful
  }

  Future<bool> exportGroup(String groupId) async {
    final exportService = ref.read(exportImportServiceProvider);
    return await exportService.exportGroup(groupId);
  }

  /// Helper to get formatted member balance info for debt settlement dialogs
  String getMemberBalanceInfo(User user, double balance, String currency) {
    final currencySymbol = CurrencyHelper.getCurrency(currency).symbol;
    final absBalance = balance.abs();
    if (balance > 0) {
      return '$currencySymbol${absBalance.toStringAsFixed(2)} owed to ${user.name}';
    } else if (balance < 0) {
      return '$currencySymbol${absBalance.toStringAsFixed(2)} owed by ${user.name}';
    }
    return '${user.name} has no outstanding balance';
  }
}
