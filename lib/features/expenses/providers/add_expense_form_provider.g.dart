// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_expense_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddExpenseForm)
final addExpenseFormProvider = AddExpenseFormFamily._();

final class AddExpenseFormProvider
    extends $NotifierProvider<AddExpenseForm, AddExpenseFormState> {
  AddExpenseFormProvider._(
      {required AddExpenseFormFamily super.from,
      required (
        String,
        Transaction?,
      )
          super.argument})
      : super(
          retry: null,
          name: r'addExpenseFormProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addExpenseFormHash();

  @override
  String toString() {
    return r'addExpenseFormProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  AddExpenseForm create() => AddExpenseForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddExpenseFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddExpenseFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddExpenseFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addExpenseFormHash() => r'4741b9a1c94c56fb4026a3da8b6a170bffae7bf6';

final class AddExpenseFormFamily extends $Family
    with
        $ClassFamilyOverride<
            AddExpenseForm,
            AddExpenseFormState,
            AddExpenseFormState,
            AddExpenseFormState,
            (
              String,
              Transaction?,
            )> {
  AddExpenseFormFamily._()
      : super(
          retry: null,
          name: r'addExpenseFormProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AddExpenseFormProvider call(
    String groupId,
    Transaction? transaction,
  ) =>
      AddExpenseFormProvider._(argument: (
        groupId,
        transaction,
      ), from: this);

  @override
  String toString() => r'addExpenseFormProvider';
}

abstract class _$AddExpenseForm extends $Notifier<AddExpenseFormState> {
  late final _$args = ref.$arg as (
    String,
    Transaction?,
  );
  String get groupId => _$args.$1;
  Transaction? get transaction => _$args.$2;

  AddExpenseFormState build(
    String groupId,
    Transaction? transaction,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AddExpenseFormState, AddExpenseFormState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AddExpenseFormState, AddExpenseFormState>,
        AddExpenseFormState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args.$1,
              _$args.$2,
            ));
  }
}
