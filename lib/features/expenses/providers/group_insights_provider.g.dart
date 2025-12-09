// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_insights_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userTotalPaidHash() => r'eda998898daf4f70c67f453448609c36919ab1e7';

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

/// See also [userTotalPaid].
@ProviderFor(userTotalPaid)
const userTotalPaidProvider = UserTotalPaidFamily();

/// See also [userTotalPaid].
class UserTotalPaidFamily extends Family<double> {
  /// See also [userTotalPaid].
  const UserTotalPaidFamily();

  /// See also [userTotalPaid].
  UserTotalPaidProvider call(
    String groupId,
  ) {
    return UserTotalPaidProvider(
      groupId,
    );
  }

  @override
  UserTotalPaidProvider getProviderOverride(
    covariant UserTotalPaidProvider provider,
  ) {
    return call(
      provider.groupId,
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
  String? get name => r'userTotalPaidProvider';
}

/// See also [userTotalPaid].
class UserTotalPaidProvider extends AutoDisposeProvider<double> {
  /// See also [userTotalPaid].
  UserTotalPaidProvider(
    String groupId,
  ) : this._internal(
          (ref) => userTotalPaid(
            ref as UserTotalPaidRef,
            groupId,
          ),
          from: userTotalPaidProvider,
          name: r'userTotalPaidProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userTotalPaidHash,
          dependencies: UserTotalPaidFamily._dependencies,
          allTransitiveDependencies:
              UserTotalPaidFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  UserTotalPaidProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    double Function(UserTotalPaidRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserTotalPaidProvider._internal(
        (ref) => create(ref as UserTotalPaidRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _UserTotalPaidProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserTotalPaidProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UserTotalPaidRef on AutoDisposeProviderRef<double> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _UserTotalPaidProviderElement extends AutoDisposeProviderElement<double>
    with UserTotalPaidRef {
  _UserTotalPaidProviderElement(super.provider);

  @override
  String get groupId => (origin as UserTotalPaidProvider).groupId;
}

String _$userTotalShareHash() => r'09e89f2630544a8817b7c2c92926aa1c440f9a0e';

/// See also [userTotalShare].
@ProviderFor(userTotalShare)
const userTotalShareProvider = UserTotalShareFamily();

/// See also [userTotalShare].
class UserTotalShareFamily extends Family<double> {
  /// See also [userTotalShare].
  const UserTotalShareFamily();

  /// See also [userTotalShare].
  UserTotalShareProvider call(
    String groupId,
  ) {
    return UserTotalShareProvider(
      groupId,
    );
  }

  @override
  UserTotalShareProvider getProviderOverride(
    covariant UserTotalShareProvider provider,
  ) {
    return call(
      provider.groupId,
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
  String? get name => r'userTotalShareProvider';
}

/// See also [userTotalShare].
class UserTotalShareProvider extends AutoDisposeProvider<double> {
  /// See also [userTotalShare].
  UserTotalShareProvider(
    String groupId,
  ) : this._internal(
          (ref) => userTotalShare(
            ref as UserTotalShareRef,
            groupId,
          ),
          from: userTotalShareProvider,
          name: r'userTotalShareProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userTotalShareHash,
          dependencies: UserTotalShareFamily._dependencies,
          allTransitiveDependencies:
              UserTotalShareFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  UserTotalShareProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    double Function(UserTotalShareRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserTotalShareProvider._internal(
        (ref) => create(ref as UserTotalShareRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _UserTotalShareProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserTotalShareProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UserTotalShareRef on AutoDisposeProviderRef<double> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _UserTotalShareProviderElement extends AutoDisposeProviderElement<double>
    with UserTotalShareRef {
  _UserTotalShareProviderElement(super.provider);

  @override
  String get groupId => (origin as UserTotalShareProvider).groupId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
