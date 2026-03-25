// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settle_up_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettleUpForm)
final settleUpFormProvider = SettleUpFormProvider._();

final class SettleUpFormProvider
    extends $NotifierProvider<SettleUpForm, SettleUpState> {
  SettleUpFormProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settleUpFormProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settleUpFormHash();

  @$internal
  @override
  SettleUpForm create() => SettleUpForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettleUpState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettleUpState>(value),
    );
  }
}

String _$settleUpFormHash() => r'56816bcbd09d70787a8b5052e7a4daf713c311e4';

abstract class _$SettleUpForm extends $Notifier<SettleUpState> {
  SettleUpState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SettleUpState, SettleUpState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SettleUpState, SettleUpState>,
        SettleUpState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
