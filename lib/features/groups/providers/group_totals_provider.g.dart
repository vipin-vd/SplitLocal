// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_totals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Total amount the user is owed across all non-friend groups

@ProviderFor(totalOwedToUserAcrossGroups)
final totalOwedToUserAcrossGroupsProvider =
    TotalOwedToUserAcrossGroupsProvider._();

/// Total amount the user is owed across all non-friend groups

final class TotalOwedToUserAcrossGroupsProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Total amount the user is owed across all non-friend groups
  TotalOwedToUserAcrossGroupsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'totalOwedToUserAcrossGroupsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$totalOwedToUserAcrossGroupsHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalOwedToUserAcrossGroups(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalOwedToUserAcrossGroupsHash() =>
    r'445e7acdb9da2bd35f5b704e70e2a8a24b9b6eff';

/// Total amount the user owes across all non-friend groups (returned positive)

@ProviderFor(totalUserOwesAcrossGroups)
final totalUserOwesAcrossGroupsProvider = TotalUserOwesAcrossGroupsProvider._();

/// Total amount the user owes across all non-friend groups (returned positive)

final class TotalUserOwesAcrossGroupsProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Total amount the user owes across all non-friend groups (returned positive)
  TotalUserOwesAcrossGroupsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'totalUserOwesAcrossGroupsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$totalUserOwesAcrossGroupsHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalUserOwesAcrossGroups(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalUserOwesAcrossGroupsHash() =>
    r'8e065bc82563611695663c99bb2cbafe1defc1f3';

/// Net balance across all non-friend groups

@ProviderFor(netBalanceAcrossGroups)
final netBalanceAcrossGroupsProvider = NetBalanceAcrossGroupsProvider._();

/// Net balance across all non-friend groups

final class NetBalanceAcrossGroupsProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Net balance across all non-friend groups
  NetBalanceAcrossGroupsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'netBalanceAcrossGroupsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$netBalanceAcrossGroupsHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return netBalanceAcrossGroups(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$netBalanceAcrossGroupsHash() =>
    r'ba000ecb150d231ab54cf3ab26b8ab030d2731ed';
