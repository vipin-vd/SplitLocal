// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeleteGroupDialog)
final deleteGroupDialogProvider = DeleteGroupDialogProvider._();

final class DeleteGroupDialogProvider extends $NotifierProvider<
    DeleteGroupDialog,
    (
      TextEditingController,
      bool,
    )> {
  DeleteGroupDialogProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deleteGroupDialogProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteGroupDialogHash();

  @$internal
  @override
  DeleteGroupDialog create() => DeleteGroupDialog();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
      (
        TextEditingController,
        bool,
      ) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<
          (
            TextEditingController,
            bool,
          )>(value),
    );
  }
}

String _$deleteGroupDialogHash() => r'6332691045d24aa8a12ae22aa5b5c19f7d723b47';

abstract class _$DeleteGroupDialog extends $Notifier<
    (
      TextEditingController,
      bool,
    )> {
  (
    TextEditingController,
    bool,
  ) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<
        (
          TextEditingController,
          bool,
        ),
        (
          TextEditingController,
          bool,
        )>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<
            (
              TextEditingController,
              bool,
            ),
            (
              TextEditingController,
              bool,
            )>,
        (
          TextEditingController,
          bool,
        ),
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(GroupSettingsScreenLogic)
final groupSettingsScreenLogicProvider = GroupSettingsScreenLogicProvider._();

final class GroupSettingsScreenLogicProvider
    extends $NotifierProvider<GroupSettingsScreenLogic, void> {
  GroupSettingsScreenLogicProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'groupSettingsScreenLogicProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupSettingsScreenLogicHash();

  @$internal
  @override
  GroupSettingsScreenLogic create() => GroupSettingsScreenLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$groupSettingsScreenLogicHash() =>
    r'2eac8271e78971922200df134ce1b9118c4604cc';

abstract class _$GroupSettingsScreenLogic extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
