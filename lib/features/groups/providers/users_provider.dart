import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../../../shared/providers/services_provider.dart';

part 'users_provider.g.dart';

@riverpod
class Users extends _$Users {
  @override
  List<User> build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.getAllUsers();
  }

  Future<void> addUser(User user) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveUser(user);
    ref.invalidateSelf();
  }

  Future<void> updateUser(User user) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveUser(user);
    ref.invalidateSelf();
  }

  Future<void> deleteUser(String userId) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.deleteUser(userId);
    ref.invalidateSelf();
  }

  User? getUser(String userId) {
    return state.firstWhere(
      (user) => user.id == userId,
      orElse: () => throw Exception('User not found'),
    );
  }

  User? getDeviceOwner() {
    try {
      return state.firstWhere((user) => user.isDeviceOwner);
    } catch (e) {
      return null;
    }
  }

  Future<User> createUserFromContact(Map<String, String?> contactData) async {
    final storage = ref.read(localStorageServiceProvider);
    
    final name = contactData['name'];
    final phoneNumber = contactData['phoneNumber'];
    
    if (name == null || name.isEmpty) {
      throw Exception('Contact name is required');
    }
    
    // Check if user already exists by phone number
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final existing = state.where((u) => u.phoneNumber == phoneNumber).firstOrNull;
      if (existing != null) {
        return existing;
      }
    }
    
    // Create new user
    final user = User(
      id: const Uuid().v4(),
      name: name,
      phoneNumber: phoneNumber,
      isDeviceOwner: false,
      createdAt: DateTime.now(),
    );
    
    await storage.saveUser(user);
    ref.invalidateSelf();
    return user;
  }
}

@riverpod
User? deviceOwner(DeviceOwnerRef ref) {
  final users = ref.watch(usersProvider);
  try {
    return users.firstWhere((user) => user.isDeviceOwner);
  } catch (e) {
    return null;
  }
}
