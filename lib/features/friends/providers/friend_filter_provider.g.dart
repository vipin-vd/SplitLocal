// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FriendListFilter)
final friendListFilterProvider = FriendListFilterProvider._();

final class FriendListFilterProvider
    extends $NotifierProvider<FriendListFilter, FriendFilter> {
  FriendListFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'friendListFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$friendListFilterHash();

  @$internal
  @override
  FriendListFilter create() => FriendListFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FriendFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FriendFilter>(value),
    );
  }
}

String _$friendListFilterHash() => r'd574a63a693470203a86b0f22ff8564e330d03bb';

abstract class _$FriendListFilter extends $Notifier<FriendFilter> {
  FriendFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FriendFilter, FriendFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FriendFilter, FriendFilter>,
        FriendFilter,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
