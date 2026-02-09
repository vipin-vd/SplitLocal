// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferred_currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$usedCurrenciesHash() => r'71572fbe3b7915d83a65f93adff611d7b1175b88';

/// Returns a list of currency codes that are actually used in groups or transactions.
///
/// Copied from [usedCurrencies].
@ProviderFor(usedCurrencies)
final usedCurrenciesProvider = AutoDisposeProvider<List<String>>.internal(
  usedCurrencies,
  name: r'usedCurrenciesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$usedCurrenciesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UsedCurrenciesRef = AutoDisposeProviderRef<List<String>>;
String _$preferredCurrencyHash() => r'164c8347065115051e714ae7908045e2abe30ef3';

/// See also [PreferredCurrency].
@ProviderFor(PreferredCurrency)
final preferredCurrencyProvider =
    AutoDisposeNotifierProvider<PreferredCurrency, String>.internal(
  PreferredCurrency.new,
  name: r'preferredCurrencyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$preferredCurrencyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PreferredCurrency = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
