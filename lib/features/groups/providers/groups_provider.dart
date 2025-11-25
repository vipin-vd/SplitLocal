import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/group.dart';
import '../../../../shared/providers/services_provider.dart';

part 'groups_provider.g.dart';

@riverpod
class Groups extends _$Groups {
  @override
  List<Group> build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.getAllGroups();
  }

  Future<void> addGroup(Group group) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveGroup(group);
    ref.invalidateSelf();
  }

  Future<void> updateGroup(Group group) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveGroup(group);
    ref.invalidateSelf();
  }

  Future<void> deleteGroup(String groupId) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.deleteGroup(groupId);
    ref.invalidateSelf();
  }

  Group? getGroup(String groupId) {
    try {
      return state.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return null;
    }
  }
}

@riverpod
Group? selectedGroup(SelectedGroupRef ref, String groupId) {
  final groups = ref.watch(groupsProvider);
  try {
    return groups.firstWhere((group) => group.id == groupId);
  } catch (e) {
    return null;
  }
}
