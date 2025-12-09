import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:splitlocal/features/groups/models/group.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';

part 'create_group_form_provider.g.dart';

class CreateGroupFormState {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<User> selectedMembers;
  final bool isSaving;
  final String? errorMessage;

  CreateGroupFormState({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    this.selectedMembers = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  CreateGroupFormState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? nameController,
    TextEditingController? descriptionController,
    List<User>? selectedMembers,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CreateGroupFormState(
      formKey: formKey ?? this.formKey,
      nameController: nameController ?? this.nameController,
      descriptionController:
          descriptionController ?? this.descriptionController,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      isSaving: isSaving ?? this.isSaving,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class CreateGroupForm extends _$CreateGroupForm {
  @override
  CreateGroupFormState build() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    ref.onDispose(() {
      nameController.dispose();
      descriptionController.dispose();
    });

    return CreateGroupFormState(
      formKey: GlobalKey<FormState>(),
      nameController: nameController,
      descriptionController: descriptionController,
    );
  }

  void addMember(User member) {
    if (!state.selectedMembers.any((m) => m.id == member.id)) {
      state =
          state.copyWith(selectedMembers: [...state.selectedMembers, member]);
    }
  }

  void removeMember(User member) {
    state = state.copyWith(
      selectedMembers:
          state.selectedMembers.where((m) => m.id != member.id).toList(),
    );
  }

  Future<void> addMemberFromContacts() async {
    final contactsService = ref.read(contactsServiceProvider);
    try {
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
          addMember(existing);
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
      addMember(newUser);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to pick contact: $e');
    }
  }

  Future<void> createGroup() async {
    if (!state.formKey.currentState!.validate()) {
      return;
    }
    state = state.copyWith(isSaving: true, clearErrorMessage: true);

    final deviceOwner = ref.read(deviceOwnerProvider);
    if (deviceOwner == null) {
      state = state.copyWith(
          isSaving: false, errorMessage: 'Device owner not found');
      return;
    }

    final memberIds = [
      deviceOwner.id,
      ...state.selectedMembers.map((m) => m.id)
    ];

    final group = Group(
      id: const Uuid().v4(),
      name: state.nameController.text.trim(),
      description: state.descriptionController.text.trim().isEmpty
          ? null
          : state.descriptionController.text.trim(),
      memberIds: memberIds.toSet().toList(), // Ensure unique members
      createdBy: deviceOwner.id,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(groupsProvider.notifier).addGroup(group);
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
          isSaving: false, errorMessage: 'Failed to create group: $e');
    }
  }

  void clearErrorMessage() {
    state = state.copyWith(clearErrorMessage: true);
  }
}
