// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_expense_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addExpenseFormHash() => r'c9739a824aca2d33e82705b69ced1e815742a1f8';

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

abstract class _$AddExpenseForm
    extends BuildlessAutoDisposeNotifier<AddExpenseFormState> {
  late final String groupId;
  late final Transaction? transaction;

  AddExpenseFormState build(
    String groupId,
    Transaction? transaction,
  );
}

/// See also [AddExpenseForm].
@ProviderFor(AddExpenseForm)
const addExpenseFormProvider = AddExpenseFormFamily();

/// See also [AddExpenseForm].
class AddExpenseFormFamily extends Family<AddExpenseFormState> {
  /// See also [AddExpenseForm].
  const AddExpenseFormFamily();

  /// See also [AddExpenseForm].
  AddExpenseFormProvider call(
    String groupId,
    Transaction? transaction,
  ) {
    return AddExpenseFormProvider(
      groupId,
      transaction,
    );
  }

  @override
  AddExpenseFormProvider getProviderOverride(
    covariant AddExpenseFormProvider provider,
  ) {
    return call(
      provider.groupId,
      provider.transaction,
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
  String? get name => r'addExpenseFormProvider';
}

/// See also [AddExpenseForm].
class AddExpenseFormProvider extends AutoDisposeNotifierProviderImpl<
    AddExpenseForm, AddExpenseFormState> {
  /// See also [AddExpenseForm].
  AddExpenseFormProvider(
    String groupId,
    Transaction? transaction,
  ) : this._internal(
          () => AddExpenseForm()
            ..groupId = groupId
            ..transaction = transaction,
          from: addExpenseFormProvider,
          name: r'addExpenseFormProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$addExpenseFormHash,
          dependencies: AddExpenseFormFamily._dependencies,
          allTransitiveDependencies:
              AddExpenseFormFamily._allTransitiveDependencies,
          groupId: groupId,
          transaction: transaction,
        );

  AddExpenseFormProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
    required this.transaction,
  }) : super.internal();

  final String groupId;
  final Transaction? transaction;

  @override
  AddExpenseFormState runNotifierBuild(
    covariant AddExpenseForm notifier,
  ) {
    return notifier.build(
      groupId,
      transaction,
    );
  }

  @override
  Override overrideWith(AddExpenseForm Function() create) {
    return ProviderOverride(
      origin: this,
      override: AddExpenseFormProvider._internal(
        () => create()
          ..groupId = groupId
          ..transaction = transaction,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
        transaction: transaction,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AddExpenseForm, AddExpenseFormState>
      createElement() {
    return _AddExpenseFormProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddExpenseFormProvider &&
        other.groupId == groupId &&
        other.transaction == transaction;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);
    hash = _SystemHash.combine(hash, transaction.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AddExpenseFormRef on AutoDisposeNotifierProviderRef<AddExpenseFormState> {
  /// The parameter `groupId` of this provider.
  String get groupId;

  /// The parameter `transaction` of this provider.
  Transaction? get transaction;
}

class _AddExpenseFormProviderElement extends AutoDisposeNotifierProviderElement<
    AddExpenseForm, AddExpenseFormState> with AddExpenseFormRef {
  _AddExpenseFormProviderElement(super.provider);

  @override
  String get groupId => (origin as AddExpenseFormProvider).groupId;
  @override
  Transaction? get transaction =>
      (origin as AddExpenseFormProvider).transaction;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
