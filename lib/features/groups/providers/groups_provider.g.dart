// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Groups)
final groupsProvider = GroupsProvider._();

final class GroupsProvider extends $NotifierProvider<Groups, List<Group>> {
  GroupsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'groupsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupsHash();

  @$internal
  @override
  Groups create() => Groups();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Group> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Group>>(value),
    );
  }
}

String _$groupsHash() => r'27458968e620a6802a915fbe048fc33f5ee8fd3f';

abstract class _$Groups extends $Notifier<List<Group>> {
  List<Group> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Group>, List<Group>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Group>, List<Group>>, List<Group>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(selectedGroup)
final selectedGroupProvider = SelectedGroupFamily._();

final class SelectedGroupProvider
    extends $FunctionalProvider<Group?, Group?, Group?> with $Provider<Group?> {
  SelectedGroupProvider._(
      {required SelectedGroupFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'selectedGroupProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedGroupHash();

  @override
  String toString() {
    return r'selectedGroupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Group?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Group? create(Ref ref) {
    final argument = this.argument as String;
    return selectedGroup(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Group? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Group?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedGroupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedGroupHash() => r'6bb80a5317b8580332501a3b4172da733386012d';

final class SelectedGroupFamily extends $Family
    with $FunctionalFamilyOverride<Group?, String> {
  SelectedGroupFamily._()
      : super(
          retry: null,
          name: r'selectedGroupProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  SelectedGroupProvider call(
    String groupId,
  ) =>
      SelectedGroupProvider._(argument: groupId, from: this);

  @override
  String toString() => r'selectedGroupProvider';
}
