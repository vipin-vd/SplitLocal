// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExpenseListFilter)
final expenseListFilterProvider = ExpenseListFilterProvider._();

final class ExpenseListFilterProvider
    extends $NotifierProvider<ExpenseListFilter, ExpenseFilter> {
  ExpenseListFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expenseListFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expenseListFilterHash();

  @$internal
  @override
  ExpenseListFilter create() => ExpenseListFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseFilter>(value),
    );
  }
}

String _$expenseListFilterHash() => r'0b01e65d0bffa97319d3a13767b5697b7359f19d';

abstract class _$ExpenseListFilter extends $Notifier<ExpenseFilter> {
  ExpenseFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ExpenseFilter, ExpenseFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ExpenseFilter, ExpenseFilter>,
        ExpenseFilter,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredExpenses)
final filteredExpensesProvider = FilteredExpensesFamily._();

final class FilteredExpensesProvider extends $FunctionalProvider<
    List<Transaction>,
    List<Transaction>,
    List<Transaction>> with $Provider<List<Transaction>> {
  FilteredExpensesProvider._(
      {required FilteredExpensesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'filteredExpensesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredExpensesHash();

  @override
  String toString() {
    return r'filteredExpensesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Transaction>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Transaction> create(Ref ref) {
    final argument = this.argument as String;
    return filteredExpenses(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredExpensesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredExpensesHash() => r'8f5a3a85206973d3b955ce155414eae864106998';

final class FilteredExpensesFamily extends $Family
    with $FunctionalFamilyOverride<List<Transaction>, String> {
  FilteredExpensesFamily._()
      : super(
          retry: null,
          name: r'filteredExpensesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FilteredExpensesProvider call(
    String groupId,
  ) =>
      FilteredExpensesProvider._(argument: groupId, from: this);

  @override
  String toString() => r'filteredExpensesProvider';
}

@ProviderFor(categoryTotals)
final categoryTotalsProvider = CategoryTotalsFamily._();

final class CategoryTotalsProvider extends $FunctionalProvider<
    Map<ExpenseCategory, double>,
    Map<ExpenseCategory, double>,
    Map<ExpenseCategory, double>> with $Provider<Map<ExpenseCategory, double>> {
  CategoryTotalsProvider._(
      {required CategoryTotalsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'categoryTotalsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryTotalsHash();

  @override
  String toString() {
    return r'categoryTotalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<ExpenseCategory, double>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<ExpenseCategory, double> create(Ref ref) {
    final argument = this.argument as String;
    return categoryTotals(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<ExpenseCategory, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<ExpenseCategory, double>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryTotalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryTotalsHash() => r'07da6f2ef171a5ce2200d78d31638a7eb4d1b871';

final class CategoryTotalsFamily extends $Family
    with $FunctionalFamilyOverride<Map<ExpenseCategory, double>, String> {
  CategoryTotalsFamily._()
      : super(
          retry: null,
          name: r'categoryTotalsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CategoryTotalsProvider call(
    String groupId,
  ) =>
      CategoryTotalsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'categoryTotalsProvider';
}
