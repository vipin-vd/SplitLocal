import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:splitlocal/features/friends/providers/friends_provider.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/features/groups/models/group.dart';
import 'package:splitlocal/services/storage/local_storage_service.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';
import 'package:splitlocal/shared/providers/initialization_provider.dart';

// Mock MockLocalStorageService
class MockLocalStorageService extends Mock implements LocalStorageService {
  final _friendIds = <String>[];
  final _hiddenFriendIds = <String>[];
  final _users = <String, User>{};
  final _groups = <String, Group>{};

  @override
  Future<void> saveUser(User user) async {
    _users[user.id] = user;
  }

  @override
  Future<void> addFriendId(String userId) async {
    if (!_friendIds.contains(userId)) {
      _friendIds.add(userId);
    }
  }

  @override
  Future<void> deleteFriendId(String userId) async {
    _friendIds.remove(userId);
  }

  @override
  Future<void> addHiddenFriendId(String userId) async {
    if (!_hiddenFriendIds.contains(userId)) {
      _hiddenFriendIds.add(userId);
    }
  }

  @override
  Future<void> removeHiddenFriendId(String userId) async {
    _hiddenFriendIds.remove(userId);
  }

  @override
  List<String> getAllFriendIds() => _friendIds;

  @override
  List<String> getAllHiddenFriendIds() => _hiddenFriendIds;

  @override
  List<Group> getAllGroups() => _groups.values.toList();

  @override
  Future<void> saveGroup(Group group) async {
    _groups[group.id] = group;
  }

  @override
  Future<void> deleteGroup(String id) async {
    _groups.remove(id);
  }

  @override
  Future<void> deleteUser(String id) async {
    _users.remove(id);
  }

  // verify method helpers
  bool containsFriend(String id) => _friendIds.contains(id);
  bool containsHiddenFriend(String id) => _hiddenFriendIds.contains(id);
  bool containsGroup(String id) => _groups.containsKey(id);
  bool containsUser(String id) => _users.containsKey(id);
}

// Helper for overriding Groups
class _FakeGroups extends Groups {
  @override
  List<Group> build() => [];
}

// Helper for overriding Users
class _FakeUsers extends Users {
  @override
  List<User> build() => [];
}

void main() {
  group('Friend Deletion Reproduction Logic', () {
    late ProviderContainer container;
    late MockLocalStorageService mockStorage;

    setUp(() async {
      mockStorage = MockLocalStorageService();

      container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          initializationProvider.overrideWith((ref) => true),
          groupsProvider.overrideWith(() => _FakeGroups()),
          usersProvider.overrideWith(() => _FakeUsers()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('removeFriend should remove friend from BOTH active and hidden lists',
        () async {
      const friendId = 'friend-123';
      final friendUser =
          User(id: friendId, name: 'Test Friend', createdAt: DateTime.now());

      // 1. Setup: Add friend
      await mockStorage.saveUser(friendUser);
      await mockStorage.addFriendId(friendId);

      // Simulate that this friend was previously hidden (or soft deleted behavior)
      await mockStorage.addHiddenFriendId(friendId);

      expect(
        mockStorage.containsFriend(friendId),
        isTrue,
        reason: 'Friend should be in valid list',
      );
      expect(
        mockStorage.containsHiddenFriend(friendId),
        isTrue,
        reason: 'Friend should be in hidden list (simulating previous state)',
      );

      // 2. Action: Remove Friend
      final notifier = container.read(friendsProvider.notifier);
      await notifier.removeFriend(friendId);

      // 3. Verify
      expect(
        mockStorage.containsFriend(friendId),
        isFalse,
        reason: 'Friend should be removed from valid list',
      );
      expect(
        mockStorage.containsHiddenFriend(friendId),
        isFalse,
        reason: 'Friend should be removed from hidden list',
      );
    });

    test('removeFriend should NOT add to hidden list if not present', () async {
      const friendId = 'friend-456';

      // 1. Setup: Add friend
      await mockStorage.addFriendId(friendId);
      expect(mockStorage.containsHiddenFriend(friendId), isFalse);

      // 2. Action: Remove Friend
      final notifier = container.read(friendsProvider.notifier);
      await notifier.removeFriend(friendId);

      // 3. Verify
      expect(mockStorage.containsFriend(friendId), isFalse);
      expect(
        mockStorage.containsHiddenFriend(friendId),
        isFalse,
        reason: 'Should not have added friend to hidden list',
      );
    });

    test(
        'removeFriend should ALSO delete associated "Individual Expenses" groups',
        () async {
      const friendId = 'friend-999';
      const myId = 'me-1';
      const groupId = 'group-friend-999';

      // 1. Setup: Create a "Friend Group"
      final friendGroup = Group(
        id: groupId,
        name: 'Individual Expenses',
        memberIds: [myId, friendId],
        createdAt: DateTime.now(),
        createdBy: myId,
        currency: 'USD',
        isFriendGroup: true,
      );

      await mockStorage.saveGroup(friendGroup);
      await mockStorage.addFriendId(friendId);

      expect(
        mockStorage.containsGroup(groupId),
        isTrue,
        reason: 'Friend group should exist initially',
      );

      // 2. Action: Remove Friend
      final notifier = container.read(friendsProvider.notifier);
      await notifier.removeFriend(friendId);

      // 3. Verify
      expect(
        mockStorage.containsGroup(groupId),
        isFalse,
        reason: 'Friend group should be auto-deleted',
      );
      expect(
        mockStorage.containsFriend(friendId),
        isFalse,
        reason: 'Friend should be removed',
      );
    });

    test(
        'removeFriend should delete ANY 2-member group (regardless of isFriendGroup flag)',
        () async {
      const friendId = 'friend-888';
      const myId = 'me-1';
      const groupId = 'group-regular-888';

      // 1. Setup: Create a REGULAR group (isFriendGroup = false) with only 2 members
      final regularGroup = Group(
        id: groupId,
        name: 'Shared Expenses',
        memberIds: [myId, friendId],
        createdAt: DateTime.now(),
        createdBy: myId,
        currency: 'USD',
        isFriendGroup: false, // NOT a friend group!
      );

      await mockStorage.saveGroup(regularGroup);
      await mockStorage.addFriendId(friendId);

      expect(
        mockStorage.containsGroup(groupId),
        isTrue,
        reason: 'Regular 2-member group should exist initially',
      );

      // 2. Action: Remove Friend
      final notifier = container.read(friendsProvider.notifier);
      await notifier.removeFriend(friendId);

      // 3. Verify
      expect(
        mockStorage.containsGroup(groupId),
        isFalse,
        reason: 'Regular 2-member group should ALSO be auto-deleted',
      );
      expect(
        mockStorage.containsFriend(friendId),
        isFalse,
        reason: 'Friend should be removed',
      );
    });

    test('removeFriend should also delete the User record', () async {
      const friendId = 'friend-777';
      final friendUser =
          User(id: friendId, name: 'To Be Deleted', createdAt: DateTime.now());

      // 1. Setup: Add friend
      await mockStorage.saveUser(friendUser);
      await mockStorage.addFriendId(friendId);

      expect(
        mockStorage.containsUser(friendId),
        isTrue,
        reason: 'User record should exist initially',
      );

      // 2. Action: Remove Friend
      final notifier = container.read(friendsProvider.notifier);
      await notifier.removeFriend(friendId);

      // 3. Verify
      expect(
        mockStorage.containsUser(friendId),
        isFalse,
        reason: 'User record should be deleted',
      );
    });
  });
}
