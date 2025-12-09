import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/groups/models/group.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:uuid/uuid.dart';

part 'friend_group_provider.g.dart';

@riverpod
Future<Group> friendGroup(FriendGroupRef ref, String friendId) async {
  final groups = ref.watch(groupsProvider);
  final me = ref.watch(deviceOwnerProvider);
  final users = ref.watch(usersProvider);

  final friend = users.firstWhere((u) => u.id == friendId);

  // Find a group with only me and the friend
  try {
    final friendGroup = groups.firstWhere(
      (g) =>
          g.isFriendGroup &&
          g.memberIds.length == 2 &&
          g.memberIds.contains(me!.id) &&
          g.memberIds.contains(friendId),
    );
    return friendGroup;
  } catch (e) {
    // If no group is found, create a new one
    final lastGroup = groups.isNotEmpty ? groups.last : null;
    final newGroup = Group(
      id: const Uuid().v4(),
      name: 'Friend Group', // This name won't be displayed
      memberIds: [me!.id, friend.id],
      createdAt: DateTime.now(),
      isFriendGroup: true, // Custom flag to identify this group
      currency: lastGroup?.currency ?? 'USD',
      createdBy: me.id,
    );
    await ref.read(groupsProvider.notifier).addGroup(newGroup);
    return newGroup;
  }
}
