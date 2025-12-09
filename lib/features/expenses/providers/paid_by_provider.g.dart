// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paid_by_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paidByHash() => r'4510d4684396abd9cafe4b4c23470fdb1bd0f814';

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

abstract class _$PaidBy extends BuildlessAutoDisposeNotifier<PaidByState> {
  late final List<User> members;
  late final Map<String, double> initialPayers;
  late final double totalAmount;
  late final String deviceOwnerId;

  PaidByState build(
    List<User> members,
    Map<String, double> initialPayers,
    double totalAmount,
    String deviceOwnerId,
  );
}

/// See also [PaidBy].
@ProviderFor(PaidBy)
const paidByProvider = PaidByFamily();

/// See also [PaidBy].
class PaidByFamily extends Family<PaidByState> {
  /// See also [PaidBy].
  const PaidByFamily();

  /// See also [PaidBy].
  PaidByProvider call(
    List<User> members,
    Map<String, double> initialPayers,
    double totalAmount,
    String deviceOwnerId,
  ) {
    return PaidByProvider(
      members,
      initialPayers,
      totalAmount,
      deviceOwnerId,
    );
  }

  @override
  PaidByProvider getProviderOverride(
    covariant PaidByProvider provider,
  ) {
    return call(
      provider.members,
      provider.initialPayers,
      provider.totalAmount,
      provider.deviceOwnerId,
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
  String? get name => r'paidByProvider';
}

/// See also [PaidBy].
class PaidByProvider
    extends AutoDisposeNotifierProviderImpl<PaidBy, PaidByState> {
  /// See also [PaidBy].
  PaidByProvider(
    List<User> members,
    Map<String, double> initialPayers,
    double totalAmount,
    String deviceOwnerId,
  ) : this._internal(
          () => PaidBy()
            ..members = members
            ..initialPayers = initialPayers
            ..totalAmount = totalAmount
            ..deviceOwnerId = deviceOwnerId,
          from: paidByProvider,
          name: r'paidByProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$paidByHash,
          dependencies: PaidByFamily._dependencies,
          allTransitiveDependencies: PaidByFamily._allTransitiveDependencies,
          members: members,
          initialPayers: initialPayers,
          totalAmount: totalAmount,
          deviceOwnerId: deviceOwnerId,
        );

  PaidByProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.members,
    required this.initialPayers,
    required this.totalAmount,
    required this.deviceOwnerId,
  }) : super.internal();

  final List<User> members;
  final Map<String, double> initialPayers;
  final double totalAmount;
  final String deviceOwnerId;

  @override
  PaidByState runNotifierBuild(
    covariant PaidBy notifier,
  ) {
    return notifier.build(
      members,
      initialPayers,
      totalAmount,
      deviceOwnerId,
    );
  }

  @override
  Override overrideWith(PaidBy Function() create) {
    return ProviderOverride(
      origin: this,
      override: PaidByProvider._internal(
        () => create()
          ..members = members
          ..initialPayers = initialPayers
          ..totalAmount = totalAmount
          ..deviceOwnerId = deviceOwnerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        members: members,
        initialPayers: initialPayers,
        totalAmount: totalAmount,
        deviceOwnerId: deviceOwnerId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PaidBy, PaidByState> createElement() {
    return _PaidByProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaidByProvider &&
        other.members == members &&
        other.initialPayers == initialPayers &&
        other.totalAmount == totalAmount &&
        other.deviceOwnerId == deviceOwnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, members.hashCode);
    hash = _SystemHash.combine(hash, initialPayers.hashCode);
    hash = _SystemHash.combine(hash, totalAmount.hashCode);
    hash = _SystemHash.combine(hash, deviceOwnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PaidByRef on AutoDisposeNotifierProviderRef<PaidByState> {
  /// The parameter `members` of this provider.
  List<User> get members;

  /// The parameter `initialPayers` of this provider.
  Map<String, double> get initialPayers;

  /// The parameter `totalAmount` of this provider.
  double get totalAmount;

  /// The parameter `deviceOwnerId` of this provider.
  String get deviceOwnerId;
}

class _PaidByProviderElement
    extends AutoDisposeNotifierProviderElement<PaidBy, PaidByState>
    with PaidByRef {
  _PaidByProviderElement(super.provider);

  @override
  List<User> get members => (origin as PaidByProvider).members;
  @override
  Map<String, double> get initialPayers =>
      (origin as PaidByProvider).initialPayers;
  @override
  double get totalAmount => (origin as PaidByProvider).totalAmount;
  @override
  String get deviceOwnerId => (origin as PaidByProvider).deviceOwnerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
