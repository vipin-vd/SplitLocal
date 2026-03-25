// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paid_by_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaidBy)
final paidByProvider = PaidByFamily._();

final class PaidByProvider extends $NotifierProvider<PaidBy, PaidByState> {
  PaidByProvider._(
      {required PaidByFamily super.from,
      required (
        List<User>,
        Map<String, double>,
        double,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'paidByProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$paidByHash();

  @override
  String toString() {
    return r'paidByProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  PaidBy create() => PaidBy();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaidByState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaidByState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PaidByProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paidByHash() => r'4510d4684396abd9cafe4b4c23470fdb1bd0f814';

final class PaidByFamily extends $Family
    with
        $ClassFamilyOverride<
            PaidBy,
            PaidByState,
            PaidByState,
            PaidByState,
            (
              List<User>,
              Map<String, double>,
              double,
              String,
            )> {
  PaidByFamily._()
      : super(
          retry: null,
          name: r'paidByProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PaidByProvider call(
    List<User> members,
    Map<String, double> initialPayers,
    double totalAmount,
    String deviceOwnerId,
  ) =>
      PaidByProvider._(argument: (
        members,
        initialPayers,
        totalAmount,
        deviceOwnerId,
      ), from: this);

  @override
  String toString() => r'paidByProvider';
}

abstract class _$PaidBy extends $Notifier<PaidByState> {
  late final _$args = ref.$arg as (
    List<User>,
    Map<String, double>,
    double,
    String,
  );
  List<User> get members => _$args.$1;
  Map<String, double> get initialPayers => _$args.$2;
  double get totalAmount => _$args.$3;
  String get deviceOwnerId => _$args.$4;

  PaidByState build(
    List<User> members,
    Map<String, double> initialPayers,
    double totalAmount,
    String deviceOwnerId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PaidByState, PaidByState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PaidByState, PaidByState>, PaidByState, Object?, Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args.$1,
              _$args.$2,
              _$args.$3,
              _$args.$4,
            ));
  }
}
