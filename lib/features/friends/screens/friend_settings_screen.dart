import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/utils/dialogs.dart';
import '../../groups/models/user.dart';
import '../../groups/widgets/edit_member_dialog.dart';
import '../providers/friends_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../friends/providers/group_balance_with_friend_provider.dart';
import '../../expenses/providers/transactions_provider.dart';
import '../../groups/screens/group_detail_screen.dart';

class FriendSettingsScreen extends ConsumerWidget {
  final User friend;

  const FriendSettingsScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Settings')),
      body: ListView(
        children: [
          _FriendInfoSection(friend: friend),
          _ActionsSection(friend: friend),
          _DangerZoneSection(friend: friend),
        ],
      ),
    );
  }
}

class _FriendInfoSection extends ConsumerWidget {
  final User friend;
  const _FriendInfoSection({required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ListTile(
            title: Text('Friend Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            subtitle: Text(friend.name),
          ),
          if (friend.phoneNumber != null)
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Number'),
              subtitle: Text(friend.phoneNumber!),
            ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Added On'),
            subtitle: Text(
              '${friend.createdAt.day}/${friend.createdAt.month}/${friend.createdAt.year}',
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsSection extends ConsumerWidget {
  final User friend;
  const _ActionsSection({required this.friend});

  Future<void> _editFriend(BuildContext context, WidgetRef ref) async {
    final updatedUser = await showDialog<User>(
      context: context,
      builder: (context) => EditMemberDialog(user: friend),
    );

    if (updatedUser != null && context.mounted) {
      final usersNotifier = ref.read(usersProvider.notifier);
      await usersNotifier.updateUser(updatedUser);
      if (context.mounted) {
        showSnackBar(context, 'Friend updated successfully');
      }
    }
  }

  Future<void> _sendInvite(BuildContext context) async {
    if (friend.phoneNumber == null || friend.phoneNumber!.isEmpty) {
      if (context.mounted) {
        showSnackBar(
          context,
          'No phone number available for this friend',
          isError: true,
        );
      }
      return;
    }

    final message =
        'Hey ${friend.name}! Let\'s use SplitLocal to track our shared expenses easily.';
    final whatsappUrl = Uri.parse(
        'https://wa.me/${friend.phoneNumber!.replaceAll(RegExp(r'\D'), '')}?text=${Uri.encodeComponent(message)}',);

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        showSnackBar(
          context,
          'Could not open WhatsApp',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Friend Info'),
            onTap: () => _editFriend(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text('Send Invite'),
            subtitle: friend.phoneNumber == null
                ? const Text('No phone number available',
                    style: TextStyle(fontSize: 12, color: Colors.grey),)
                : null,
            onTap: () => _sendInvite(context),
          ),
        ],
      ),
    );
  }
}

class _DangerZoneSection extends ConsumerWidget {
  final User friend;
  const _DangerZoneSection({required this.friend});

  Future<void> _deleteFriend(BuildContext context, WidgetRef ref) async {
    // Guard: block deletion if friend is in any group with outstanding balances
    // and provide a meaningful guidance dialog.
    final groups = ref.read(groupsProvider);
    final memberGroupIds = groups
        .where((g) => g.memberIds.contains(friend.id))
        .map((g) => g.id)
        .toList();

    // Check per-group net balance with this friend; if any non-zero, block.
    bool hasOutstanding = false;
    final blockingGroups = <BlockingGroup>[];
    for (final groupId in memberGroupIds) {
      final balance =
          ref.read(groupBalanceWithFriendProvider(groupId, friend.id));
      if (balance.abs() > 0.01) {
        hasOutstanding = true;
        final group = groups.firstWhere((g) => g.id == groupId);
        final deviceOwner = ref.read(deviceOwnerProvider);
        final netBalances = ref.read(groupNetBalancesProvider(groupId));
        final canLeave = deviceOwner == null
            ? false
            : (netBalances[deviceOwner.id] ?? 0.0).abs() < 0.01;
        blockingGroups.add(BlockingGroup(
          id: group.id,
          name: group.name,
          canLeave: canLeave,
        ),);
      }
    }

    if (hasOutstanding) {
      await showCannotRemoveFriendDialog(
        context,
        friendName: friend.name,
        groups: blockingGroups,
        onOpenGroup: (gid) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupDetailScreen(groupId: gid),
            ),
          );
        },
        onLeaveGroup: (gid) async {
          final group = groups.firstWhere((g) => g.id == gid);
          final owner = ref.read(deviceOwnerProvider);
          if (owner == null) return;
          final updated = group.copyWith(
            memberIds: group.memberIds.where((id) => id != owner.id).toList(),
            updatedAt: DateTime.now(),
          );
          await ref.read(groupsProvider.notifier).updateGroup(updated);
        },
      );
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Friend',
      message:
          'Are you sure you want to remove ${friend.name} from your friends? This will not delete shared expenses or groups.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed == true && context.mounted) {
      final friendsNotifier = ref.read(friendsProvider.notifier);
      await friendsNotifier.removeFriend(friend.id);
      if (context.mounted) {
        Navigator.of(context).pop(); // Go back to friend detail
        Navigator.of(context).pop(); // Go back to friends list
        showSnackBar(context, '${friend.name} removed from friends');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: Colors.red.shade50,
      child: Column(
        children: [
          const ListTile(
            title: Text('Danger Zone',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,),),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Friend',
                style: TextStyle(color: Colors.red),),
            subtitle: const Text(
                'Remove from friends list (shared data preserved).\nIf balances exist in any group, you must settle or remove them from the group first.',
                style: TextStyle(fontSize: 12),),
            onTap: () => _deleteFriend(context, ref),
          ),
        ],
      ),
    );
  }
}
