// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_method_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$splitMethodHash() => r'86973d983894d7498491d09bcf8520c3ff948227';

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

abstract class _$SplitMethod
    extends BuildlessAutoDisposeNotifier<SplitMethodState> {
  late final List<User> members;
  late final SplitMode initialMode;
  late final Map<String, double> initialSplits;
  late final double totalAmount;

  SplitMethodState build(
    List<User> members,
    SplitMode initialMode,
    Map<String, double> initialSplits,
    double totalAmount,
  );
}

/// See also [SplitMethod].
@ProviderFor(SplitMethod)
const splitMethodProvider = SplitMethodFamily();

/// See also [SplitMethod].
class SplitMethodFamily extends Family<SplitMethodState> {
  /// See also [SplitMethod].
  const SplitMethodFamily();

  /// See also [SplitMethod].
  SplitMethodProvider call(
    List<User> members,
    SplitMode initialMode,
    Map<String, double> initialSplits,
    double totalAmount,
  ) {
    return SplitMethodProvider(
      members,
      initialMode,
      initialSplits,
      totalAmount,
    );
  }

  @override
  SplitMethodProvider getProviderOverride(
    covariant SplitMethodProvider provider,
  ) {
    return call(
      provider.members,
      provider.initialMode,
      provider.initialSplits,
      provider.totalAmount,
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
  String? get name => r'splitMethodProvider';
}

/// See also [SplitMethod].
class SplitMethodProvider
    extends AutoDisposeNotifierProviderImpl<SplitMethod, SplitMethodState> {
  /// See also [SplitMethod].
  SplitMethodProvider(
    List<User> members,
    SplitMode initialMode,
    Map<String, double> initialSplits,
    double totalAmount,
  ) : this._internal(
          () => SplitMethod()
            ..members = members
            ..initialMode = initialMode
            ..initialSplits = initialSplits
            ..totalAmount = totalAmount,
          from: splitMethodProvider,
          name: r'splitMethodProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$splitMethodHash,
          dependencies: SplitMethodFamily._dependencies,
          allTransitiveDependencies:
              SplitMethodFamily._allTransitiveDependencies,
          members: members,
          initialMode: initialMode,
          initialSplits: initialSplits,
          totalAmount: totalAmount,
        );

  SplitMethodProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.members,
    required this.initialMode,
    required this.initialSplits,
    required this.totalAmount,
  }) : super.internal();

  final List<User> members;
  final SplitMode initialMode;
  final Map<String, double> initialSplits;
  final double totalAmount;

  @override
  SplitMethodState runNotifierBuild(
    covariant SplitMethod notifier,
  ) {
    return notifier.build(
      members,
      initialMode,
      initialSplits,
      totalAmount,
    );
  }

  @override
  Override overrideWith(SplitMethod Function() create) {
    return ProviderOverride(
      origin: this,
      override: SplitMethodProvider._internal(
        () => create()
          ..members = members
          ..initialMode = initialMode
          ..initialSplits = initialSplits
          ..totalAmount = totalAmount,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        members: members,
        initialMode: initialMode,
        initialSplits: initialSplits,
        totalAmount: totalAmount,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SplitMethod, SplitMethodState>
      createElement() {
    return _SplitMethodProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SplitMethodProvider &&
        other.members == members &&
        other.initialMode == initialMode &&
        other.initialSplits == initialSplits &&
        other.totalAmount == totalAmount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, members.hashCode);
    hash = _SystemHash.combine(hash, initialMode.hashCode);
    hash = _SystemHash.combine(hash, initialSplits.hashCode);
    hash = _SystemHash.combine(hash, totalAmount.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SplitMethodRef on AutoDisposeNotifierProviderRef<SplitMethodState> {
  /// The parameter `members` of this provider.
  List<User> get members;

  /// The parameter `initialMode` of this provider.
  SplitMode get initialMode;

  /// The parameter `initialSplits` of this provider.
  Map<String, double> get initialSplits;

  /// The parameter `totalAmount` of this provider.
  double get totalAmount;
}

class _SplitMethodProviderElement
    extends AutoDisposeNotifierProviderElement<SplitMethod, SplitMethodState>
    with SplitMethodRef {
  _SplitMethodProviderElement(super.provider);

  @override
  List<User> get members => (origin as SplitMethodProvider).members;
  @override
  SplitMode get initialMode => (origin as SplitMethodProvider).initialMode;
  @override
  Map<String, double> get initialSplits =>
      (origin as SplitMethodProvider).initialSplits;
  @override
  double get totalAmount => (origin as SplitMethodProvider).totalAmount;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
