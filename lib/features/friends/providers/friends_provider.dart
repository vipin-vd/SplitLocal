import 'dart:async';

import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/services/storage/local_storage_service.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';
import 'package:splitlocal/shared/providers/initialization_provider.dart';

part 'friends_provider.g.dart';

@riverpod
class Friends extends _$Friends {
  @override
  List<User> build() {
    // Ensure initialization is complete before trying to access boxes
    final init = ref.watch(initializationProvider);
    if (!init.hasValue) return [];

    final storage = ref.watch(localStorageServiceProvider);

    // Safely get boxes, checking if they're open
    if (!Hive.isBoxOpen(LocalStorageService.friendsBoxName)) {
      return [];
    }

    final friendsBox = Hive.box<String>(LocalStorageService.friendsBoxName);

    final friendsSubscription = friendsBox.watch().listen((event) {
      ref.invalidateSelf();
    });

    // Also watch hidden friends box for changes
    StreamSubscription<BoxEvent>? hiddenSubscription;
    if (Hive.isBoxOpen(LocalStorageService.hiddenFriendsBoxName)) {
      final hiddenFriendsBox =
          Hive.box<String>(LocalStorageService.hiddenFriendsBoxName);
      hiddenSubscription = hiddenFriendsBox.watch().listen((event) {
        ref.invalidateSelf();
      });
    }

    ref.onDispose(() {
      friendsSubscription.cancel();
      hiddenSubscription?.cancel();
    });

    final friendIds = storage.getAllFriendIds();
    final allUsers = ref.watch(usersProvider);
    final allGroups = ref.watch(groupsProvider);
    final deviceOwner = ref.watch(deviceOwnerProvider);

    // Get hidden friends if the box is open
    final hiddenFriendIds =
        Hive.isBoxOpen(LocalStorageService.hiddenFriendsBoxName)
            ? storage.getAllHiddenFriendIds()
            : <String>[];

    // Include both explicitly added friends and group members
    final groupMemberIds = allGroups.expand((group) => group.memberIds).toSet();
    final allFriendIds = {...friendIds, ...groupMemberIds};

    if (deviceOwner != null) {
      allFriendIds.remove(deviceOwner.id);
    }

    // Remove hidden friends, but only if they were explicitly hidden
    // We filter out any hidden IDs that are also current group members
    // This allows a previously hidden friend to "re-appear" if added to a group
    final explicitlyHiddenFriends =
        hiddenFriendIds.where((id) => !groupMemberIds.contains(id));
    allFriendIds.removeAll(explicitlyHiddenFriends);

    return allUsers.where((user) => allFriendIds.contains(user.id)).toList();
  }

  // A method to add a friend.
  Future<void> addFriend(User friend) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveUser(friend);
    await storage.addFriendId(friend.id);
  }

  // A method to remove a friend.
  Future<void> removeFriend(String friendId) async {
    final storage = ref.read(localStorageServiceProvider);

    // Aggressively delete any groups where this friend is a member
    // and the group only has 2 members (the device owner and the friend).
    // This handles both "Individual Expenses" groups and any mis-flagged groups.
    final allGroups = storage.getAllGroups();
    final groupsToDelete = allGroups
        .where((g) => g.memberIds.contains(friendId) && g.memberIds.length == 2)
        .toList();

    for (final group in groupsToDelete) {
      await storage.deleteGroup(group.id);
    }

    await storage.deleteFriendId(friendId);
    await storage.removeHiddenFriendId(friendId);

    // Delete the User record itself to fully purge the friend from storage
    await storage.deleteUser(friendId);
  }
}
