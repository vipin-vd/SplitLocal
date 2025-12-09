import 'dart:async';

import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/services/storage/local_storage_service.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';

part 'friends_provider.g.dart';

@riverpod
class Friends extends _$Friends {
  @override
  List<User> build() {
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

    // Remove hidden friends
    allFriendIds.removeAll(hiddenFriendIds);

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
    await storage.deleteFriendId(friendId);
    await storage.addHiddenFriendId(friendId);
  }
}
