// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredExpensesHash() => r'8f5a3a85206973d3b955ce155414eae864106998';

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

/// See also [filteredExpenses].
@ProviderFor(filteredExpenses)
const filteredExpensesProvider = FilteredExpensesFamily();

/// See also [filteredExpenses].
class FilteredExpensesFamily extends Family<List<Transaction>> {
  /// See also [filteredExpenses].
  const FilteredExpensesFamily();

  /// See also [filteredExpenses].
  FilteredExpensesProvider call(
    String groupId,
  ) {
    return FilteredExpensesProvider(
      groupId,
    );
  }

  @override
  FilteredExpensesProvider getProviderOverride(
    covariant FilteredExpensesProvider provider,
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
  String? get name => r'filteredExpensesProvider';
}

/// See also [filteredExpenses].
class FilteredExpensesProvider extends AutoDisposeProvider<List<Transaction>> {
  /// See also [filteredExpenses].
  FilteredExpensesProvider(
    String groupId,
  ) : this._internal(
          (ref) => filteredExpenses(
            ref as FilteredExpensesRef,
            groupId,
          ),
          from: filteredExpensesProvider,
          name: r'filteredExpensesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredExpensesHash,
          dependencies: FilteredExpensesFamily._dependencies,
          allTransitiveDependencies:
              FilteredExpensesFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  FilteredExpensesProvider._internal(
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
    List<Transaction> Function(FilteredExpensesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredExpensesProvider._internal(
        (ref) => create(ref as FilteredExpensesRef),
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
    return _FilteredExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredExpensesProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FilteredExpensesRef on AutoDisposeProviderRef<List<Transaction>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _FilteredExpensesProviderElement
    extends AutoDisposeProviderElement<List<Transaction>>
    with FilteredExpensesRef {
  _FilteredExpensesProviderElement(super.provider);

  @override
  String get groupId => (origin as FilteredExpensesProvider).groupId;
}

String _$categoryTotalsHash() => r'07da6f2ef171a5ce2200d78d31638a7eb4d1b871';

/// See also [categoryTotals].
@ProviderFor(categoryTotals)
const categoryTotalsProvider = CategoryTotalsFamily();

/// See also [categoryTotals].
class CategoryTotalsFamily extends Family<Map<ExpenseCategory, double>> {
  /// See also [categoryTotals].
  const CategoryTotalsFamily();

  /// See also [categoryTotals].
  CategoryTotalsProvider call(
    String groupId,
  ) {
    return CategoryTotalsProvider(
      groupId,
    );
  }

  @override
  CategoryTotalsProvider getProviderOverride(
    covariant CategoryTotalsProvider provider,
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
  String? get name => r'categoryTotalsProvider';
}

/// See also [categoryTotals].
class CategoryTotalsProvider
    extends AutoDisposeProvider<Map<ExpenseCategory, double>> {
  /// See also [categoryTotals].
  CategoryTotalsProvider(
    String groupId,
  ) : this._internal(
          (ref) => categoryTotals(
            ref as CategoryTotalsRef,
            groupId,
          ),
          from: categoryTotalsProvider,
          name: r'categoryTotalsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryTotalsHash,
          dependencies: CategoryTotalsFamily._dependencies,
          allTransitiveDependencies:
              CategoryTotalsFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  CategoryTotalsProvider._internal(
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
    Map<ExpenseCategory, double> Function(CategoryTotalsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryTotalsProvider._internal(
        (ref) => create(ref as CategoryTotalsRef),
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
  AutoDisposeProviderElement<Map<ExpenseCategory, double>> createElement() {
    return _CategoryTotalsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryTotalsProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryTotalsRef
    on AutoDisposeProviderRef<Map<ExpenseCategory, double>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _CategoryTotalsProviderElement
    extends AutoDisposeProviderElement<Map<ExpenseCategory, double>>
    with CategoryTotalsRef {
  _CategoryTotalsProviderElement(super.provider);

  @override
  String get groupId => (origin as CategoryTotalsProvider).groupId;
}

String _$expenseListFilterHash() => r'0b01e65d0bffa97319d3a13767b5697b7359f19d';

/// See also [ExpenseListFilter].
@ProviderFor(ExpenseListFilter)
final expenseListFilterProvider =
    AutoDisposeNotifierProvider<ExpenseListFilter, ExpenseFilter>.internal(
  ExpenseListFilter.new,
  name: r'expenseListFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseListFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseListFilter = AutoDisposeNotifier<ExpenseFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
