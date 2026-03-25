// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_settled_up_friends_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShowSettledUpFriends)
final showSettledUpFriendsProvider = ShowSettledUpFriendsProvider._();

final class ShowSettledUpFriendsProvider
    extends $NotifierProvider<ShowSettledUpFriends, bool> {
  ShowSettledUpFriendsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'showSettledUpFriendsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$showSettledUpFriendsHash();

  @$internal
  @override
  ShowSettledUpFriends create() => ShowSettledUpFriends();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showSettledUpFriendsHash() =>
    r'7c178079c76feccea087c18021e622f2a90c699e';

abstract class _$ShowSettledUpFriends extends $Notifier<bool> {
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
