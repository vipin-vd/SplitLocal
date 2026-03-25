// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShowSimplifiedDebts)
final showSimplifiedDebtsProvider = ShowSimplifiedDebtsProvider._();

final class ShowSimplifiedDebtsProvider
    extends $NotifierProvider<ShowSimplifiedDebts, bool> {
  ShowSimplifiedDebtsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'showSimplifiedDebtsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$showSimplifiedDebtsHash();

  @$internal
  @override
  ShowSimplifiedDebts create() => ShowSimplifiedDebts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showSimplifiedDebtsHash() =>
    r'b43121e5f4a1a3664f27ed3cc38ae2fae5d5c4a3';

abstract class _$ShowSimplifiedDebts extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(groupDetailScreenLogic)
final groupDetailScreenLogicProvider = GroupDetailScreenLogicProvider._();

final class GroupDetailScreenLogicProvider extends $FunctionalProvider<
    GroupDetailScreenLogic,
    GroupDetailScreenLogic,
    GroupDetailScreenLogic> with $Provider<GroupDetailScreenLogic> {
  GroupDetailScreenLogicProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'groupDetailScreenLogicProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupDetailScreenLogicHash();

  @$internal
  @override
  $ProviderElement<GroupDetailScreenLogic> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupDetailScreenLogic create(Ref ref) {
    return groupDetailScreenLogic(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupDetailScreenLogic value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupDetailScreenLogic>(value),
    );
  }
}

String _$groupDetailScreenLogicHash() =>
    r'cae91cb3224e49fda784fdd21cfcbe8e4edecb0a';
