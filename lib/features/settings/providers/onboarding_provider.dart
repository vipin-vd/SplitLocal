import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';

part 'onboarding_provider.g.dart';

class OnboardingState {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool isSaving;

  OnboardingState({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    this.isSaving = false,
  });

  OnboardingState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? nameController,
    TextEditingController? phoneController,
    bool? isSaving,
  }) {
    return OnboardingState(
      formKey: formKey ?? this.formKey,
      nameController: nameController ?? this.nameController,
      phoneController: phoneController ?? this.phoneController,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

@riverpod
class Onboarding extends _$Onboarding {
  @override
  OnboardingState build() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    ref.onDispose(() {
      nameController.dispose();
      phoneController.dispose();
    });

    return OnboardingState(
      formKey: GlobalKey<FormState>(),
      nameController: nameController,
      phoneController: phoneController,
    );
  }

  Future<bool> completeOnboarding() async {
    if (!state.formKey.currentState!.validate()) {
      return false;
    }
    state = state.copyWith(isSaving: true);

    final user = User(
      id: const Uuid().v4(),
      name: state.nameController.text.trim(),
      phoneNumber: state.phoneController.text.trim().isEmpty
          ? null
          : state.phoneController.text.trim(),
      isDeviceOwner: true,
      createdAt: DateTime.now(),
    );

    await ref.read(usersProvider.notifier).addUser(user);
    await ref.read(localStorageServiceProvider).setOnboardingComplete();

    state = state.copyWith(isSaving: false);
    return true;
  }
}
