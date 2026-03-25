// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Transactions)
final transactionsProvider = TransactionsProvider._();

final class TransactionsProvider
    extends $NotifierProvider<Transactions, List<Transaction>> {
  TransactionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionsHash();

  @$internal
  @override
  Transactions create() => Transactions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }
}

String _$transactionsHash() => r'14853d94cb08788c2867c39a7a414d8c09aece7e';

abstract class _$Transactions extends $Notifier<List<Transaction>> {
  List<Transaction> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Transaction>, List<Transaction>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Transaction>, List<Transaction>>,
        List<Transaction>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(groupTransactions)
final groupTransactionsProvider = GroupTransactionsFamily._();

final class GroupTransactionsProvider extends $FunctionalProvider<
    List<Transaction>,
    List<Transaction>,
    List<Transaction>> with $Provider<List<Transaction>> {
  GroupTransactionsProvider._(
      {required GroupTransactionsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'groupTransactionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupTransactionsHash();

  @override
  String toString() {
    return r'groupTransactionsProvider'
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
    return groupTransactions(
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
    return other is GroupTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupTransactionsHash() => r'2f5ad8866df6fbbeac9c46b45945acca33146658';

final class GroupTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<List<Transaction>, String> {
  GroupTransactionsFamily._()
      : super(
          retry: null,
          name: r'groupTransactionsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GroupTransactionsProvider call(
    String groupId,
  ) =>
      GroupTransactionsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupTransactionsProvider';
}

@ProviderFor(groupNetBalances)
final groupNetBalancesProvider = GroupNetBalancesFamily._();

final class GroupNetBalancesProvider extends $FunctionalProvider<
    Map<String, double>,
    Map<String, double>,
    Map<String, double>> with $Provider<Map<String, double>> {
  GroupNetBalancesProvider._(
      {required GroupNetBalancesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'groupNetBalancesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupNetBalancesHash();

  @override
  String toString() {
    return r'groupNetBalancesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, double>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, double> create(Ref ref) {
    final argument = this.argument as String;
    return groupNetBalances(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupNetBalancesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupNetBalancesHash() => r'f96edaa3f10c1afa5b95369ac72c8ff52a8369c6';

final class GroupNetBalancesFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, double>, String> {
  GroupNetBalancesFamily._()
      : super(
          retry: null,
          name: r'groupNetBalancesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GroupNetBalancesProvider call(
    String groupId,
  ) =>
      GroupNetBalancesProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupNetBalancesProvider';
}

@ProviderFor(groupTotalSpend)
final groupTotalSpendProvider = GroupTotalSpendFamily._();

final class GroupTotalSpendProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  GroupTotalSpendProvider._(
      {required GroupTotalSpendFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'groupTotalSpendProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupTotalSpendHash();

  @override
  String toString() {
    return r'groupTotalSpendProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String;
    return groupTotalSpend(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupTotalSpendProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupTotalSpendHash() => r'fe720d953fa680a17d9e1edda6056afef8ff41e3';

final class GroupTotalSpendFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  GroupTotalSpendFamily._()
      : super(
          retry: null,
          name: r'groupTotalSpendProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GroupTotalSpendProvider call(
    String groupId,
  ) =>
      GroupTotalSpendProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupTotalSpendProvider';
}

@ProviderFor(groupTotalSpendByCurrency)
final groupTotalSpendByCurrencyProvider = GroupTotalSpendByCurrencyFamily._();

final class GroupTotalSpendByCurrencyProvider extends $FunctionalProvider<
    Map<String, double>,
    Map<String, double>,
    Map<String, double>> with $Provider<Map<String, double>> {
  GroupTotalSpendByCurrencyProvider._(
      {required GroupTotalSpendByCurrencyFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'groupTotalSpendByCurrencyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupTotalSpendByCurrencyHash();

  @override
  String toString() {
    return r'groupTotalSpendByCurrencyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, double>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, double> create(Ref ref) {
    final argument = this.argument as String;
    return groupTotalSpendByCurrency(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupTotalSpendByCurrencyProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupTotalSpendByCurrencyHash() =>
    r'a69be2b4026f2a5dbc38aa8ce9966fc74baa7fa7';

final class GroupTotalSpendByCurrencyFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, double>, String> {
  GroupTotalSpendByCurrencyFamily._()
      : super(
          retry: null,
          name: r'groupTotalSpendByCurrencyProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GroupTotalSpendByCurrencyProvider call(
    String groupId,
  ) =>
      GroupTotalSpendByCurrencyProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupTotalSpendByCurrencyProvider';
}

@ProviderFor(groupNetBalancesByCurrency)
final groupNetBalancesByCurrencyProvider = GroupNetBalancesByCurrencyFamily._();

final class GroupNetBalancesByCurrencyProvider extends $FunctionalProvider<
        Map<String, Map<String, double>>,
        Map<String, Map<String, double>>,
        Map<String, Map<String, double>>>
    with $Provider<Map<String, Map<String, double>>> {
  GroupNetBalancesByCurrencyProvider._(
      {required GroupNetBalancesByCurrencyFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'groupNetBalancesByCurrencyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupNetBalancesByCurrencyHash();

  @override
  String toString() {
    return r'groupNetBalancesByCurrencyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, Map<String, double>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, Map<String, double>> create(Ref ref) {
    final argument = this.argument as String;
    return groupNetBalancesByCurrency(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Map<String, double>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, Map<String, double>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupNetBalancesByCurrencyProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupNetBalancesByCurrencyHash() =>
    r'cca08093ecb0972c4625493ecadf66f06ea12f73';

final class GroupNetBalancesByCurrencyFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, Map<String, double>>, String> {
  GroupNetBalancesByCurrencyFamily._()
      : super(
          retry: null,
          name: r'groupNetBalancesByCurrencyProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GroupNetBalancesByCurrencyProvider call(
    String groupId,
  ) =>
      GroupNetBalancesByCurrencyProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupNetBalancesByCurrencyProvider';
}

@ProviderFor(groupCategorySpending)
final groupCategorySpendingProvider = GroupCategorySpendingFamily._();

final class GroupCategorySpendingProvider extends $FunctionalProvider<
    Map<ExpenseCategory, double>,
    Map<ExpenseCategory, double>,
    Map<ExpenseCategory, double>> with $Provider<Map<ExpenseCategory, double>> {
  GroupCategorySpendingProvider._(
      {required GroupCategorySpendingFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'groupCategorySpendingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupCategorySpendingHash();

  @override
  String toString() {
    return r'groupCategorySpendingProvider'
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
    return groupCategorySpending(
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
    return other is GroupCategorySpendingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategorySpendingHash() =>
    r'804abb3b7e37fb491181f6d35e16e4f5264344fb';

final class GroupCategorySpendingFamily extends $Family
    with $FunctionalFamilyOverride<Map<ExpenseCategory, double>, String> {
  GroupCategorySpendingFamily._()
      : super(
          retry: null,
          name: r'groupCategorySpendingProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GroupCategorySpendingProvider call(
    String groupId,
  ) =>
      GroupCategorySpendingProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupCategorySpendingProvider';
}

@ProviderFor(recurringExpenses)
final recurringExpensesProvider = RecurringExpensesFamily._();

final class RecurringExpensesProvider extends $FunctionalProvider<
    List<Transaction>,
    List<Transaction>,
    List<Transaction>> with $Provider<List<Transaction>> {
  RecurringExpensesProvider._(
      {required RecurringExpensesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'recurringExpensesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recurringExpensesHash();

  @override
  String toString() {
    return r'recurringExpensesProvider'
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
    return recurringExpenses(
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
    return other is RecurringExpensesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringExpensesHash() => r'49b04c65972010aeb68b6ddc1b93e0174a108283';

final class RecurringExpensesFamily extends $Family
    with $FunctionalFamilyOverride<List<Transaction>, String> {
  RecurringExpensesFamily._()
      : super(
          retry: null,
          name: r'recurringExpensesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  RecurringExpensesProvider call(
    String groupId,
  ) =>
      RecurringExpensesProvider._(argument: groupId, from: this);

  @override
  String toString() => r'recurringExpensesProvider';
}
