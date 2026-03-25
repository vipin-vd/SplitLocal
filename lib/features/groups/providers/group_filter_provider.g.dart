// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GroupListFilter)
final groupListFilterProvider = GroupListFilterProvider._();

final class GroupListFilterProvider
    extends $NotifierProvider<GroupListFilter, GroupFilter> {
  GroupListFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'groupListFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupListFilterHash();

  @$internal
  @override
  GroupListFilter create() => GroupListFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupFilter>(value),
    );
  }
}

String _$groupListFilterHash() => r'a504dd78eb2d484ee6d51bdd768d37b6d9c1fe15';

abstract class _$GroupListFilter extends $Notifier<GroupFilter> {
  GroupFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GroupFilter, GroupFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<GroupFilter, GroupFilter>, GroupFilter, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
