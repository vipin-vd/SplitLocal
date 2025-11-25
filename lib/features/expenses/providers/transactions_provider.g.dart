// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupTransactionsHash() => r'2f5ad8866df6fbbeac9c46b45945acca33146658';

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

/// See also [groupTransactions].
@ProviderFor(groupTransactions)
const groupTransactionsProvider = GroupTransactionsFamily();

/// See also [groupTransactions].
class GroupTransactionsFamily extends Family<List<Transaction>> {
  /// See also [groupTransactions].
  const GroupTransactionsFamily();

  /// See also [groupTransactions].
  GroupTransactionsProvider call(
    String groupId,
  ) {
    return GroupTransactionsProvider(
      groupId,
    );
  }

  @override
  GroupTransactionsProvider getProviderOverride(
    covariant GroupTransactionsProvider provider,
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
  String? get name => r'groupTransactionsProvider';
}

/// See also [groupTransactions].
class GroupTransactionsProvider extends AutoDisposeProvider<List<Transaction>> {
  /// See also [groupTransactions].
  GroupTransactionsProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupTransactions(
            ref as GroupTransactionsRef,
            groupId,
          ),
          from: groupTransactionsProvider,
          name: r'groupTransactionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupTransactionsHash,
          dependencies: GroupTransactionsFamily._dependencies,
          allTransitiveDependencies:
              GroupTransactionsFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupTransactionsProvider._internal(
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
    List<Transaction> Function(GroupTransactionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupTransactionsProvider._internal(
        (ref) => create(ref as GroupTransactionsRef),
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
  AutoDisposeProviderElement<List<Transaction>> createElement() {
    return _GroupTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupTransactionsProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupTransactionsRef on AutoDisposeProviderRef<List<Transaction>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupTransactionsProviderElement
    extends AutoDisposeProviderElement<List<Transaction>>
    with GroupTransactionsRef {
  _GroupTransactionsProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupTransactionsProvider).groupId;
}

String _$groupNetBalancesHash() => r'f96edaa3f10c1afa5b95369ac72c8ff52a8369c6';

/// See also [groupNetBalances].
@ProviderFor(groupNetBalances)
const groupNetBalancesProvider = GroupNetBalancesFamily();

/// See also [groupNetBalances].
class GroupNetBalancesFamily extends Family<Map<String, double>> {
  /// See also [groupNetBalances].
  const GroupNetBalancesFamily();

  /// See also [groupNetBalances].
  GroupNetBalancesProvider call(
    String groupId,
  ) {
    return GroupNetBalancesProvider(
      groupId,
    );
  }

  @override
  GroupNetBalancesProvider getProviderOverride(
    covariant GroupNetBalancesProvider provider,
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
  String? get name => r'groupNetBalancesProvider';
}

/// See also [groupNetBalances].
class GroupNetBalancesProvider
    extends AutoDisposeProvider<Map<String, double>> {
  /// See also [groupNetBalances].
  GroupNetBalancesProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupNetBalances(
            ref as GroupNetBalancesRef,
            groupId,
          ),
          from: groupNetBalancesProvider,
          name: r'groupNetBalancesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupNetBalancesHash,
          dependencies: GroupNetBalancesFamily._dependencies,
          allTransitiveDependencies:
              GroupNetBalancesFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupNetBalancesProvider._internal(
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
    Map<String, double> Function(GroupNetBalancesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupNetBalancesProvider._internal(
        (ref) => create(ref as GroupNetBalancesRef),
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
  AutoDisposeProviderElement<Map<String, double>> createElement() {
    return _GroupNetBalancesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupNetBalancesProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupNetBalancesRef on AutoDisposeProviderRef<Map<String, double>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupNetBalancesProviderElement
    extends AutoDisposeProviderElement<Map<String, double>>
    with GroupNetBalancesRef {
  _GroupNetBalancesProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupNetBalancesProvider).groupId;
}

String _$groupTotalSpendHash() => r'fe720d953fa680a17d9e1edda6056afef8ff41e3';

/// See also [groupTotalSpend].
@ProviderFor(groupTotalSpend)
const groupTotalSpendProvider = GroupTotalSpendFamily();

/// See also [groupTotalSpend].
class GroupTotalSpendFamily extends Family<double> {
  /// See also [groupTotalSpend].
  const GroupTotalSpendFamily();

  /// See also [groupTotalSpend].
  GroupTotalSpendProvider call(
    String groupId,
  ) {
    return GroupTotalSpendProvider(
      groupId,
    );
  }

  @override
  GroupTotalSpendProvider getProviderOverride(
    covariant GroupTotalSpendProvider provider,
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
  String? get name => r'groupTotalSpendProvider';
}

/// See also [groupTotalSpend].
class GroupTotalSpendProvider extends AutoDisposeProvider<double> {
  /// See also [groupTotalSpend].
  GroupTotalSpendProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupTotalSpend(
            ref as GroupTotalSpendRef,
            groupId,
          ),
          from: groupTotalSpendProvider,
          name: r'groupTotalSpendProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupTotalSpendHash,
          dependencies: GroupTotalSpendFamily._dependencies,
          allTransitiveDependencies:
              GroupTotalSpendFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupTotalSpendProvider._internal(
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
    double Function(GroupTotalSpendRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupTotalSpendProvider._internal(
        (ref) => create(ref as GroupTotalSpendRef),
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
    return _GroupTotalSpendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupTotalSpendProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupTotalSpendRef on AutoDisposeProviderRef<double> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupTotalSpendProviderElement extends AutoDisposeProviderElement<double>
    with GroupTotalSpendRef {
  _GroupTotalSpendProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupTotalSpendProvider).groupId;
}

String _$transactionsHash() => r'14853d94cb08788c2867c39a7a414d8c09aece7e';

/// See also [Transactions].
@ProviderFor(Transactions)
final transactionsProvider =
    AutoDisposeNotifierProvider<Transactions, List<Transaction>>.internal(
  Transactions.new,
  name: r'transactionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$transactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Transactions = AutoDisposeNotifier<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
