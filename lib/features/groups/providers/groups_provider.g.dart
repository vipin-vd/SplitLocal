// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedGroupHash() => r'6bb80a5317b8580332501a3b4172da733386012d';

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

/// See also [selectedGroup].
@ProviderFor(selectedGroup)
const selectedGroupProvider = SelectedGroupFamily();

/// See also [selectedGroup].
class SelectedGroupFamily extends Family<Group?> {
  /// See also [selectedGroup].
  const SelectedGroupFamily();

  /// See also [selectedGroup].
  SelectedGroupProvider call(
    String groupId,
  ) {
    return SelectedGroupProvider(
      groupId,
    );
  }

  @override
  SelectedGroupProvider getProviderOverride(
    covariant SelectedGroupProvider provider,
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
  String? get name => r'selectedGroupProvider';
}

/// See also [selectedGroup].
class SelectedGroupProvider extends AutoDisposeProvider<Group?> {
  /// See also [selectedGroup].
  SelectedGroupProvider(
    String groupId,
  ) : this._internal(
          (ref) => selectedGroup(
            ref as SelectedGroupRef,
            groupId,
          ),
          from: selectedGroupProvider,
          name: r'selectedGroupProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectedGroupHash,
          dependencies: SelectedGroupFamily._dependencies,
          allTransitiveDependencies:
              SelectedGroupFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  SelectedGroupProvider._internal(
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
    Group? Function(SelectedGroupRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SelectedGroupProvider._internal(
        (ref) => create(ref as SelectedGroupRef),
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
  AutoDisposeProviderElement<Group?> createElement() {
    return _SelectedGroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedGroupProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SelectedGroupRef on AutoDisposeProviderRef<Group?> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _SelectedGroupProviderElement extends AutoDisposeProviderElement<Group?>
    with SelectedGroupRef {
  _SelectedGroupProviderElement(super.provider);

  @override
  String get groupId => (origin as SelectedGroupProvider).groupId;
}

String _$groupsHash() => r'27458968e620a6802a915fbe048fc33f5ee8fd3f';

/// See also [Groups].
@ProviderFor(Groups)
final groupsProvider =
    AutoDisposeNotifierProvider<Groups, List<Group>>.internal(
  Groups.new,
  name: r'groupsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$groupsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Groups = AutoDisposeNotifier<List<Group>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
