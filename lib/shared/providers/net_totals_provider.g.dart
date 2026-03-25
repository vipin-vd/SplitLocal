// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_totals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Computes the device owner's net balances against all other users
/// from all transactions across the app (friend groups + regular groups).

@ProviderFor(allNetBalances)
final allNetBalancesProvider = AllNetBalancesProvider._();

/// Computes the device owner's net balances against all other users
/// from all transactions across the app (friend groups + regular groups).

final class AllNetBalancesProvider extends $FunctionalProvider<
    Map<String, double>,
    Map<String, double>,
    Map<String, double>> with $Provider<Map<String, double>> {
  /// Computes the device owner's net balances against all other users
  /// from all transactions across the app (friend groups + regular groups).
  AllNetBalancesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allNetBalancesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allNetBalancesHash();

  @$internal
  @override
  $ProviderElement<Map<String, double>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, double> create(Ref ref) {
    return allNetBalances(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$allNetBalancesHash() => r'ef2d332bb2ef223b355c501fd1615ce2f0fe305b';

/// Total amount the user is owed globally (sum of positive balances)

@ProviderFor(totalOwedToUserGlobal)
final totalOwedToUserGlobalProvider = TotalOwedToUserGlobalProvider._();

/// Total amount the user is owed globally (sum of positive balances)

final class TotalOwedToUserGlobalProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Total amount the user is owed globally (sum of positive balances)
  TotalOwedToUserGlobalProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'totalOwedToUserGlobalProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$totalOwedToUserGlobalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalOwedToUserGlobal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalOwedToUserGlobalHash() =>
    r'b5ba6964124c2e42ba12ca1c90dbe802e0b7f410';

/// Total amount the user owes globally (sum of negative balances, returned positive)

@ProviderFor(totalUserOwesGlobal)
final totalUserOwesGlobalProvider = TotalUserOwesGlobalProvider._();

/// Total amount the user owes globally (sum of negative balances, returned positive)

final class TotalUserOwesGlobalProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Total amount the user owes globally (sum of negative balances, returned positive)
  TotalUserOwesGlobalProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'totalUserOwesGlobalProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$totalUserOwesGlobalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalUserOwesGlobal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalUserOwesGlobalHash() =>
    r'5712febd82c097f7608969e4039b0717cb71b7ce';

/// Net global balance (positive => others owe user, negative => user owes)

@ProviderFor(netBalanceGlobal)
final netBalanceGlobalProvider = NetBalanceGlobalProvider._();

/// Net global balance (positive => others owe user, negative => user owes)

final class NetBalanceGlobalProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Net global balance (positive => others owe user, negative => user owes)
  NetBalanceGlobalProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'netBalanceGlobalProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$netBalanceGlobalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return netBalanceGlobal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$netBalanceGlobalHash() => r'71a3ac16c8ea50eb28f8524b024560da71244712';
