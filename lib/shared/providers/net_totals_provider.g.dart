// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_totals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allNetBalancesHash() => r'1a77cb81901df3c118551e7e857df11413ec3417';

/// Computes the device owner's net balances against all other users
/// from all transactions across the app (friend groups + regular groups).
///
/// Copied from [allNetBalances].
@ProviderFor(allNetBalances)
final allNetBalancesProvider =
    AutoDisposeProvider<Map<String, double>>.internal(
  allNetBalances,
  name: r'allNetBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allNetBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllNetBalancesRef = AutoDisposeProviderRef<Map<String, double>>;
String _$totalOwedToUserGlobalHash() =>
    r'b5ba6964124c2e42ba12ca1c90dbe802e0b7f410';

/// Total amount the user is owed globally (sum of positive balances)
///
/// Copied from [totalOwedToUserGlobal].
@ProviderFor(totalOwedToUserGlobal)
final totalOwedToUserGlobalProvider = AutoDisposeProvider<double>.internal(
  totalOwedToUserGlobal,
  name: r'totalOwedToUserGlobalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalOwedToUserGlobalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalOwedToUserGlobalRef = AutoDisposeProviderRef<double>;
String _$totalUserOwesGlobalHash() =>
    r'5712febd82c097f7608969e4039b0717cb71b7ce';

/// Total amount the user owes globally (sum of negative balances, returned positive)
///
/// Copied from [totalUserOwesGlobal].
@ProviderFor(totalUserOwesGlobal)
final totalUserOwesGlobalProvider = AutoDisposeProvider<double>.internal(
  totalUserOwesGlobal,
  name: r'totalUserOwesGlobalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalUserOwesGlobalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalUserOwesGlobalRef = AutoDisposeProviderRef<double>;
String _$netBalanceGlobalHash() => r'71a3ac16c8ea50eb28f8524b024560da71244712';

/// Net global balance (positive => others owe user, negative => user owes)
///
/// Copied from [netBalanceGlobal].
@ProviderFor(netBalanceGlobal)
final netBalanceGlobalProvider = AutoDisposeProvider<double>.internal(
  netBalanceGlobal,
  name: r'netBalanceGlobalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$netBalanceGlobalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NetBalanceGlobalRef = AutoDisposeProviderRef<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
