import 'package:hive_flutter/hive_flutter.dart';
import '../../features/groups/models/user.dart';
import '../../features/groups/models/group.dart';
import '../../features/expenses/models/transaction.dart';

class LocalStorageService {
  static const String usersBoxName = 'users';
  static const String groupsBoxName = 'groups';
  static const String transactionsBoxName = 'transactions';
  static const String settingsBoxName = 'settings';
  static const String friendsBoxName = 'friends';
  static const String hiddenFriendsBoxName = 'hidden_friends';

  // Box getters - boxes are already opened in main.dart
  Box<User> get _usersBox => Hive.box<User>(usersBoxName);
  Box<Group> get _groupsBox => Hive.box<Group>(groupsBoxName);
  Box<Transaction> get _transactionsBox =>
      Hive.box<Transaction>(transactionsBoxName);
  Box<dynamic> get _settingsBox => Hive.box(settingsBoxName);
  Box<String> get _friendsBox => Hive.box<String>(friendsBoxName);
  Box<String> get _hiddenFriendsBox => Hive.box<String>(hiddenFriendsBoxName);

  /// Initialize is no longer needed as boxes are opened in main.dart
  /// Kept for backward compatibility but does nothing
  Future<void> initialize() async {
    // Boxes already initialized in main.dart
  }

  // ==================== USERS ====================

  Future<void> saveUser(User user) async {
    await _usersBox.put(user.id, user);
  }

  User? getUser(String id) {
    return _usersBox.get(id);
  }

  List<User> getAllUsers() {
    return _usersBox.values.toList();
  }

  User? getDeviceOwner() {
    return _usersBox.values.firstWhere(
      (user) => user.isDeviceOwner,
      orElse: () => throw Exception('No device owner found'),
    );
  }

  Future<void> deleteUser(String id) async {
    await _usersBox.delete(id);
  }

  // ==================== FRIENDS ====================

  Future<void> addFriendId(String userId) async {
    await _friendsBox.put(userId, userId);
  }

  List<String> getAllFriendIds() {
    return _friendsBox.values.toList();
  }

  Future<void> deleteFriendId(String userId) async {
    await _friendsBox.delete(userId);
  }

  Future<void> addHiddenFriendId(String userId) async {
    if (!Hive.isBoxOpen(hiddenFriendsBoxName)) {
      await Hive.openBox<String>(hiddenFriendsBoxName);
    }
    await _hiddenFriendsBox.put(userId, userId);
  }

  List<String> getAllHiddenFriendIds() {
    if (!Hive.isBoxOpen(hiddenFriendsBoxName)) {
      return [];
    }
    return _hiddenFriendsBox.values.toList();
  }

  Future<void> removeHiddenFriendId(String userId) async {
    if (!Hive.isBoxOpen(hiddenFriendsBoxName)) {
      return;
    }
    await _hiddenFriendsBox.delete(userId);
  }

  // ==================== GROUPS ====================

  Future<void> saveGroup(Group group) async {
    await _groupsBox.put(group.id, group);
  }

  Group? getGroup(String id) {
    return _groupsBox.get(id);
  }

  List<Group> getAllGroups() {
    return _groupsBox.values.toList();
  }

  Future<void> deleteGroup(String id) async {
    await _groupsBox.delete(id);
    // Also delete all transactions for this group
    final transactions = getTransactionsByGroup(id);
    for (final transaction in transactions) {
      await deleteTransaction(transaction.id);
    }
  }

  // ==================== TRANSACTIONS ====================

  Future<void> saveTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  Transaction? getTransaction(String id) {
    return _transactionsBox.get(id);
  }

  List<Transaction> getAllTransactions() {
    return _transactionsBox.values.toList();
  }

  List<Transaction> getTransactionsByGroup(String groupId) {
    return _transactionsBox.values.where((t) => t.groupId == groupId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  // ==================== SETTINGS ====================

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  bool get isOnboardingComplete {
    return _settingsBox.get('onboarding_complete', defaultValue: false) as bool;
  }

  Future<void> setOnboardingComplete() async {
    await _settingsBox.put('onboarding_complete', true);
  }

  // ==================== BACKUP & RESTORE ====================

  /// Export entire database to JSON
  Map<String, dynamic> exportToJson() {
    return {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'users': _usersBox.values.map((u) => u.toJson()).toList(),
      'groups': _groupsBox.values.map((g) => g.toJson()).toList(),
      'transactions': _transactionsBox.values.map((t) => t.toJson()).toList(),
    };
  }

  /// Import and restore database from JSON
  Future<void> importFromJson(Map<String, dynamic> json,
      {bool merge = false,}) async {
    // Validate schema
    if (!json.containsKey('users') ||
        !json.containsKey('groups') ||
        !json.containsKey('transactions')) {
      throw Exception('Invalid JSON format: missing required keys');
    }

    if (!merge) {
      // Clear existing data
      await _usersBox.clear();
      await _groupsBox.clear();
      await _transactionsBox.clear();
    }

    // Import users
    final users = (json['users'] as List)
        .map((userJson) => User.fromJson(userJson as Map<String, dynamic>))
        .toList();
    for (final user in users) {
      await saveUser(user);
    }

    // Import groups
    final groups = (json['groups'] as List)
        .map((groupJson) => Group.fromJson(groupJson as Map<String, dynamic>))
        .toList();
    for (final group in groups) {
      await saveGroup(group);
    }

    // Import transactions
    final transactions = (json['transactions'] as List)
        .map((txJson) => Transaction.fromJson(txJson as Map<String, dynamic>))
        .toList();
    for (final transaction in transactions) {
      await saveTransaction(transaction);
    }
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await _usersBox.clear();
    await _groupsBox.clear();
    await _transactionsBox.clear();
    await _settingsBox.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _usersBox.close();
    await _groupsBox.close();
    await _transactionsBox.close();
    await _settingsBox.close();
  }
}
