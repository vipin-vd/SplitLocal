// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_balance_with_friend_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupBalanceWithFriendHash() =>
    r'2128b26abf1422290009fd2149e40da46636d931';

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

/// See also [groupBalanceWithFriend].
@ProviderFor(groupBalanceWithFriend)
const groupBalanceWithFriendProvider = GroupBalanceWithFriendFamily();

/// See also [groupBalanceWithFriend].
class GroupBalanceWithFriendFamily extends Family<double> {
  /// See also [groupBalanceWithFriend].
  const GroupBalanceWithFriendFamily();

  /// See also [groupBalanceWithFriend].
  GroupBalanceWithFriendProvider call(
    String groupId,
    String friendId,
  ) {
    return GroupBalanceWithFriendProvider(
      groupId,
      friendId,
    );
  }

  @override
  GroupBalanceWithFriendProvider getProviderOverride(
    covariant GroupBalanceWithFriendProvider provider,
  ) {
    return call(
      provider.groupId,
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
  String? get name => r'groupBalanceWithFriendProvider';
}

/// See also [groupBalanceWithFriend].
class GroupBalanceWithFriendProvider extends AutoDisposeProvider<double> {
  /// See also [groupBalanceWithFriend].
  GroupBalanceWithFriendProvider(
    String groupId,
    String friendId,
  ) : this._internal(
          (ref) => groupBalanceWithFriend(
            ref as GroupBalanceWithFriendRef,
            groupId,
            friendId,
          ),
          from: groupBalanceWithFriendProvider,
          name: r'groupBalanceWithFriendProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupBalanceWithFriendHash,
          dependencies: GroupBalanceWithFriendFamily._dependencies,
          allTransitiveDependencies:
              GroupBalanceWithFriendFamily._allTransitiveDependencies,
          groupId: groupId,
          friendId: friendId,
        );

  GroupBalanceWithFriendProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
    required this.friendId,
  }) : super.internal();

  final String groupId;
  final String friendId;

  @override
  Override overrideWith(
    double Function(GroupBalanceWithFriendRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupBalanceWithFriendProvider._internal(
        (ref) => create(ref as GroupBalanceWithFriendRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
        friendId: friendId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _GroupBalanceWithFriendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupBalanceWithFriendProvider &&
        other.groupId == groupId &&
        other.friendId == friendId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);
    hash = _SystemHash.combine(hash, friendId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupBalanceWithFriendRef on AutoDisposeProviderRef<double> {
  /// The parameter `groupId` of this provider.
  String get groupId;

  /// The parameter `friendId` of this provider.
  String get friendId;
}

class _GroupBalanceWithFriendProviderElement
    extends AutoDisposeProviderElement<double> with GroupBalanceWithFriendRef {
  _GroupBalanceWithFriendProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupBalanceWithFriendProvider).groupId;
  @override
  String get friendId => (origin as GroupBalanceWithFriendProvider).friendId;
}

String _$groupBalanceWithFriendByCurrencyHash() =>
    r'74730aa1d7ee9a281483d382119a0a37d2968103';

/// Returns friend balance within a specific group, grouped by currency.
/// Positive values mean friend owes you, negative means you owe them.
///
/// Copied from [groupBalanceWithFriendByCurrency].
@ProviderFor(groupBalanceWithFriendByCurrency)
const groupBalanceWithFriendByCurrencyProvider =
    GroupBalanceWithFriendByCurrencyFamily();

/// Returns friend balance within a specific group, grouped by currency.
/// Positive values mean friend owes you, negative means you owe them.
///
/// Copied from [groupBalanceWithFriendByCurrency].
class GroupBalanceWithFriendByCurrencyFamily
    extends Family<Map<String, double>> {
  /// Returns friend balance within a specific group, grouped by currency.
  /// Positive values mean friend owes you, negative means you owe them.
  ///
  /// Copied from [groupBalanceWithFriendByCurrency].
  const GroupBalanceWithFriendByCurrencyFamily();

  /// Returns friend balance within a specific group, grouped by currency.
  /// Positive values mean friend owes you, negative means you owe them.
  ///
  /// Copied from [groupBalanceWithFriendByCurrency].
  GroupBalanceWithFriendByCurrencyProvider call(
    String groupId,
    String friendId,
  ) {
    return GroupBalanceWithFriendByCurrencyProvider(
      groupId,
      friendId,
    );
  }

  @override
  GroupBalanceWithFriendByCurrencyProvider getProviderOverride(
    covariant GroupBalanceWithFriendByCurrencyProvider provider,
  ) {
    return call(
      provider.groupId,
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
  String? get name => r'groupBalanceWithFriendByCurrencyProvider';
}

/// Returns friend balance within a specific group, grouped by currency.
/// Positive values mean friend owes you, negative means you owe them.
///
/// Copied from [groupBalanceWithFriendByCurrency].
class GroupBalanceWithFriendByCurrencyProvider
    extends AutoDisposeProvider<Map<String, double>> {
  /// Returns friend balance within a specific group, grouped by currency.
  /// Positive values mean friend owes you, negative means you owe them.
  ///
  /// Copied from [groupBalanceWithFriendByCurrency].
  GroupBalanceWithFriendByCurrencyProvider(
    String groupId,
    String friendId,
  ) : this._internal(
          (ref) => groupBalanceWithFriendByCurrency(
            ref as GroupBalanceWithFriendByCurrencyRef,
            groupId,
            friendId,
          ),
          from: groupBalanceWithFriendByCurrencyProvider,
          name: r'groupBalanceWithFriendByCurrencyProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupBalanceWithFriendByCurrencyHash,
          dependencies: GroupBalanceWithFriendByCurrencyFamily._dependencies,
          allTransitiveDependencies:
              GroupBalanceWithFriendByCurrencyFamily._allTransitiveDependencies,
          groupId: groupId,
          friendId: friendId,
        );

  GroupBalanceWithFriendByCurrencyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
    required this.friendId,
  }) : super.internal();

  final String groupId;
  final String friendId;

  @override
  Override overrideWith(
    Map<String, double> Function(GroupBalanceWithFriendByCurrencyRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupBalanceWithFriendByCurrencyProvider._internal(
        (ref) => create(ref as GroupBalanceWithFriendByCurrencyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
        friendId: friendId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Map<String, double>> createElement() {
    return _GroupBalanceWithFriendByCurrencyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupBalanceWithFriendByCurrencyProvider &&
        other.groupId == groupId &&
        other.friendId == friendId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);
    hash = _SystemHash.combine(hash, friendId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupBalanceWithFriendByCurrencyRef
    on AutoDisposeProviderRef<Map<String, double>> {
  /// The parameter `groupId` of this provider.
  String get groupId;

  /// The parameter `friendId` of this provider.
  String get friendId;
}

class _GroupBalanceWithFriendByCurrencyProviderElement
    extends AutoDisposeProviderElement<Map<String, double>>
    with GroupBalanceWithFriendByCurrencyRef {
  _GroupBalanceWithFriendByCurrencyProviderElement(super.provider);

  @override
  String get groupId =>
      (origin as GroupBalanceWithFriendByCurrencyProvider).groupId;
  @override
  String get friendId =>
      (origin as GroupBalanceWithFriendByCurrencyProvider).friendId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
