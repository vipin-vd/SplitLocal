// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_method_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SplitMethod)
final splitMethodProvider = SplitMethodFamily._();

final class SplitMethodProvider
    extends $NotifierProvider<SplitMethod, SplitMethodState> {
  SplitMethodProvider._(
      {required SplitMethodFamily super.from,
      required (
        List<User>,
        SplitMode,
        Map<String, double>,
        double,
      )
          super.argument})
      : super(
          retry: null,
          name: r'splitMethodProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$splitMethodHash();

  @override
  String toString() {
    return r'splitMethodProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SplitMethod create() => SplitMethod();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplitMethodState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplitMethodState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SplitMethodProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$splitMethodHash() => r'f200c93d83092d031f7c3d053fe29e282fa34029';

final class SplitMethodFamily extends $Family
    with
        $ClassFamilyOverride<
            SplitMethod,
            SplitMethodState,
            SplitMethodState,
            SplitMethodState,
            (
              List<User>,
              SplitMode,
              Map<String, double>,
              double,
            )> {
  SplitMethodFamily._()
      : super(
          retry: null,
          name: r'splitMethodProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  SplitMethodProvider call(
    List<User> members,
    SplitMode initialMode,
    Map<String, double> initialSplits,
    double totalAmount,
  ) =>
      SplitMethodProvider._(argument: (
        members,
        initialMode,
        initialSplits,
        totalAmount,
      ), from: this);

  @override
  String toString() => r'splitMethodProvider';
}

abstract class _$SplitMethod extends $Notifier<SplitMethodState> {
  late final _$args = ref.$arg as (
    List<User>,
    SplitMode,
    Map<String, double>,
    double,
  );
  List<User> get members => _$args.$1;
  SplitMode get initialMode => _$args.$2;
  Map<String, double> get initialSplits => _$args.$3;
  double get totalAmount => _$args.$4;

  SplitMethodState build(
    List<User> members,
    SplitMode initialMode,
    Map<String, double> initialSplits,
    double totalAmount,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SplitMethodState, SplitMethodState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SplitMethodState, SplitMethodState>,
        SplitMethodState,
        Object?,
        Object?>;
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
