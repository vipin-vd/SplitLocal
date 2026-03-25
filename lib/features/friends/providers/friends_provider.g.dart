// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Friends)
final friendsProvider = FriendsProvider._();

final class FriendsProvider extends $NotifierProvider<Friends, List<User>> {
  FriendsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'friendsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$friendsHash();

  @$internal
  @override
  Friends create() => Friends();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<User> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<User>>(value),
    );
  }
}

String _$friendsHash() => r'253d8b92d9846fc0f826a760918709c73f51c465';

abstract class _$Friends extends $Notifier<List<User>> {
  List<User> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<User>, List<User>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<User>, List<User>>, List<User>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
