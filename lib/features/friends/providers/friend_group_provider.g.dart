// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$friendGroupHash() => r'5b5c221a531f629c1ac9a8a360f6a4c5b278248e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [friendGroup].
@ProviderFor(friendGroup)
const friendGroupProvider = FriendGroupFamily();

/// See also [friendGroup].
class FriendGroupFamily extends Family<AsyncValue<Group>> {
  /// See also [friendGroup].
  const FriendGroupFamily();

  /// See also [friendGroup].
  FriendGroupProvider call(
    String friendId,
  ) {
    return FriendGroupProvider(
      friendId,
    );
  }

  @override
  FriendGroupProvider getProviderOverride(
    covariant FriendGroupProvider provider,
  ) {
    return call(
      provider.friendId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'friendGroupProvider';
}

/// See also [friendGroup].
class FriendGroupProvider extends AutoDisposeFutureProvider<Group> {
  /// See also [friendGroup].
  FriendGroupProvider(
    String friendId,
  ) : this._internal(
          (ref) => friendGroup(
            ref as FriendGroupRef,
            friendId,
          ),
          from: friendGroupProvider,
          name: r'friendGroupProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$friendGroupHash,
          dependencies: FriendGroupFamily._dependencies,
          allTransitiveDependencies:
              FriendGroupFamily._allTransitiveDependencies,
          friendId: friendId,
        );

  FriendGroupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.friendId,
  }) : super.internal();

  final String friendId;

  @override
  Override overrideWith(
    FutureOr<Group> Function(FriendGroupRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FriendGroupProvider._internal(
        (ref) => create(ref as FriendGroupRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        friendId: friendId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Group> createElement() {
    return _FriendGroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FriendGroupProvider && other.friendId == friendId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, friendId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FriendGroupRef on AutoDisposeFutureProviderRef<Group> {
  /// The parameter `friendId` of this provider.
  String get friendId;
}

class _FriendGroupProviderElement
    extends AutoDisposeFutureProviderElement<Group> with FriendGroupRef {
  _FriendGroupProviderElement(super.provider);

  @override
  String get friendId => (origin as FriendGroupProvider).friendId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
