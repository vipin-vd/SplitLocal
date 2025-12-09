// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$friendBalanceHash() => r'4e206764c560ab7483e753e96ceff9c665ccf5ce';

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

/// See also [friendBalance].
@ProviderFor(friendBalance)
const friendBalanceProvider = FriendBalanceFamily();

/// See also [friendBalance].
class FriendBalanceFamily extends Family<double> {
  /// See also [friendBalance].
  const FriendBalanceFamily();

  /// See also [friendBalance].
  FriendBalanceProvider call(
    String friendId,
  ) {
    return FriendBalanceProvider(
      friendId,
    );
  }

  @override
  FriendBalanceProvider getProviderOverride(
    covariant FriendBalanceProvider provider,
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
  String? get name => r'friendBalanceProvider';
}

/// See also [friendBalance].
class FriendBalanceProvider extends AutoDisposeProvider<double> {
  /// See also [friendBalance].
  FriendBalanceProvider(
    String friendId,
  ) : this._internal(
          (ref) => friendBalance(
            ref as FriendBalanceRef,
            friendId,
          ),
          from: friendBalanceProvider,
          name: r'friendBalanceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$friendBalanceHash,
          dependencies: FriendBalanceFamily._dependencies,
          allTransitiveDependencies:
              FriendBalanceFamily._allTransitiveDependencies,
          friendId: friendId,
        );

  FriendBalanceProvider._internal(
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
    double Function(FriendBalanceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FriendBalanceProvider._internal(
        (ref) => create(ref as FriendBalanceRef),
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
  AutoDisposeProviderElement<double> createElement() {
    return _FriendBalanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FriendBalanceProvider && other.friendId == friendId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, friendId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FriendBalanceRef on AutoDisposeProviderRef<double> {
  /// The parameter `friendId` of this provider.
  String get friendId;
}

class _FriendBalanceProviderElement extends AutoDisposeProviderElement<double>
    with FriendBalanceRef {
  _FriendBalanceProviderElement(super.provider);

  @override
  String get friendId => (origin as FriendBalanceProvider).friendId;
}

String _$allFriendBalancesHash() => r'd99e37b03ec6e0f916c32fe06f22c01d08a66e84';

/// Provides a map of all friend balances to avoid per-item watches during filtering
///
/// Copied from [allFriendBalances].
@ProviderFor(allFriendBalances)
final allFriendBalancesProvider =
    AutoDisposeProvider<Map<String, double>>.internal(
  allFriendBalances,
  name: r'allFriendBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allFriendBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllFriendBalancesRef = AutoDisposeProviderRef<Map<String, double>>;
String _$zeroBalanceFriendIdsHash() =>
    r'0c964f75270de06890889cece27bfe8ea33299d7';

/// Provides list of friend IDs with zero balances (settled up or new friends)
///
/// Copied from [zeroBalanceFriendIds].
@ProviderFor(zeroBalanceFriendIds)
final zeroBalanceFriendIdsProvider = AutoDisposeProvider<List<String>>.internal(
  zeroBalanceFriendIds,
  name: r'zeroBalanceFriendIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$zeroBalanceFriendIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ZeroBalanceFriendIdsRef = AutoDisposeProviderRef<List<String>>;
String _$totalOwedToUserHash() => r'8591f5a69d1c6797d151797230721f76ccae4ec0';

/// Total amount the user is owed by all friends (sum of positive balances)
///
/// Copied from [totalOwedToUser].
@ProviderFor(totalOwedToUser)
final totalOwedToUserProvider = AutoDisposeProvider<double>.internal(
  totalOwedToUser,
  name: r'totalOwedToUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalOwedToUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalOwedToUserRef = AutoDisposeProviderRef<double>;
String _$totalUserOwesHash() => r'f8a651526bba514e48811445a69a861e317fc974';

/// Total amount the user owes to all friends (sum of negative balances, returned positive)
///
/// Copied from [totalUserOwes].
@ProviderFor(totalUserOwes)
final totalUserOwesProvider = AutoDisposeProvider<double>.internal(
  totalUserOwes,
  name: r'totalUserOwesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalUserOwesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalUserOwesRef = AutoDisposeProviderRef<double>;
String _$netFriendBalanceHash() => r'73570694a92e829959cdb9d67dd02e1404b16e5f';

/// Net balance across all friends (positive => friends owe user, negative => user owes)
///
/// Copied from [netFriendBalance].
@ProviderFor(netFriendBalance)
final netFriendBalanceProvider = AutoDisposeProvider<double>.internal(
  netFriendBalance,
  name: r'netFriendBalanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$netFriendBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NetFriendBalanceRef = AutoDisposeProviderRef<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
