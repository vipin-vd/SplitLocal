// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferred_currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferredCurrency)
final preferredCurrencyProvider = PreferredCurrencyProvider._();

final class PreferredCurrencyProvider
    extends $NotifierProvider<PreferredCurrency, String> {
  PreferredCurrencyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'preferredCurrencyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$preferredCurrencyHash();

  @$internal
  @override
  PreferredCurrency create() => PreferredCurrency();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$preferredCurrencyHash() => r'970ac23e9f896e3b7ee01a256cdce85929103ce2';

abstract class _$PreferredCurrency extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DashboardCurrency)
final dashboardCurrencyProvider = DashboardCurrencyProvider._();

final class DashboardCurrencyProvider
    extends $NotifierProvider<DashboardCurrency, String> {
  DashboardCurrencyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardCurrencyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardCurrencyHash();

  @$internal
  @override
  DashboardCurrency create() => DashboardCurrency();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$dashboardCurrencyHash() => r'0c757233353895acd730331ec90349b945c1b4ed';

abstract class _$DashboardCurrency extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Returns a list of currency codes that are actually used in groups or transactions.

@ProviderFor(usedCurrencies)
final usedCurrenciesProvider = UsedCurrenciesProvider._();

/// Returns a list of currency codes that are actually used in groups or transactions.

final class UsedCurrenciesProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// Returns a list of currency codes that are actually used in groups or transactions.
  UsedCurrenciesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'usedCurrenciesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$usedCurrenciesHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return usedCurrencies(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$usedCurrenciesHash() => r'71572fbe3b7915d83a65f93adff611d7b1175b88';
