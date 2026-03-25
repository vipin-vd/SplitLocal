// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(friendBalance)
final friendBalanceProvider = FriendBalanceFamily._();

final class FriendBalanceProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  FriendBalanceProvider._(
      {required FriendBalanceFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'friendBalanceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$friendBalanceHash();

  @override
  String toString() {
    return r'friendBalanceProvider'
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
    return friendBalance(
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
    return other is FriendBalanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$friendBalanceHash() => r'4e206764c560ab7483e753e96ceff9c665ccf5ce';

final class FriendBalanceFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  FriendBalanceFamily._()
      : super(
          retry: null,
          name: r'friendBalanceProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FriendBalanceProvider call(
    String friendId,
  ) =>
      FriendBalanceProvider._(argument: friendId, from: this);

  @override
  String toString() => r'friendBalanceProvider';
}

/// Returns friend balance grouped by currency code.
/// Positive values mean friend owes you, negative means you owe them.

@ProviderFor(friendBalanceByCurrency)
final friendBalanceByCurrencyProvider = FriendBalanceByCurrencyFamily._();

/// Returns friend balance grouped by currency code.
/// Positive values mean friend owes you, negative means you owe them.

final class FriendBalanceByCurrencyProvider extends $FunctionalProvider<
    Map<String, double>,
    Map<String, double>,
    Map<String, double>> with $Provider<Map<String, double>> {
  /// Returns friend balance grouped by currency code.
  /// Positive values mean friend owes you, negative means you owe them.
  FriendBalanceByCurrencyProvider._(
      {required FriendBalanceByCurrencyFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'friendBalanceByCurrencyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$friendBalanceByCurrencyHash();

  @override
  String toString() {
    return r'friendBalanceByCurrencyProvider'
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
    return friendBalanceByCurrency(
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
    return other is FriendBalanceByCurrencyProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$friendBalanceByCurrencyHash() =>
    r'27cd530de675dced4b88370b20365f3baf72f783';

/// Returns friend balance grouped by currency code.
/// Positive values mean friend owes you, negative means you owe them.

final class FriendBalanceByCurrencyFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, double>, String> {
  FriendBalanceByCurrencyFamily._()
      : super(
          retry: null,
          name: r'friendBalanceByCurrencyProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Returns friend balance grouped by currency code.
  /// Positive values mean friend owes you, negative means you owe them.

  FriendBalanceByCurrencyProvider call(
    String friendId,
  ) =>
      FriendBalanceByCurrencyProvider._(argument: friendId, from: this);

  @override
  String toString() => r'friendBalanceByCurrencyProvider';
}

/// Provides a map of all friend balances to avoid per-item watches during filtering

@ProviderFor(allFriendBalances)
final allFriendBalancesProvider = AllFriendBalancesProvider._();

/// Provides a map of all friend balances to avoid per-item watches during filtering

final class AllFriendBalancesProvider extends $FunctionalProvider<
    Map<String, double>,
    Map<String, double>,
    Map<String, double>> with $Provider<Map<String, double>> {
  /// Provides a map of all friend balances to avoid per-item watches during filtering
  AllFriendBalancesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allFriendBalancesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allFriendBalancesHash();

  @$internal
  @override
  $ProviderElement<Map<String, double>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, double> create(Ref ref) {
    return allFriendBalances(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$allFriendBalancesHash() => r'd99e37b03ec6e0f916c32fe06f22c01d08a66e84';

/// Provides a map of all friend balances grouped by currency
/// Map<FriendId, Map<CurrencyCode, Balance>>

@ProviderFor(allFriendBalancesByCurrency)
final allFriendBalancesByCurrencyProvider =
    AllFriendBalancesByCurrencyProvider._();

/// Provides a map of all friend balances grouped by currency
/// Map<FriendId, Map<CurrencyCode, Balance>>

final class AllFriendBalancesByCurrencyProvider extends $FunctionalProvider<
        Map<String, Map<String, double>>,
        Map<String, Map<String, double>>,
        Map<String, Map<String, double>>>
    with $Provider<Map<String, Map<String, double>>> {
  /// Provides a map of all friend balances grouped by currency
  /// Map<FriendId, Map<CurrencyCode, Balance>>
  AllFriendBalancesByCurrencyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allFriendBalancesByCurrencyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allFriendBalancesByCurrencyHash();

  @$internal
  @override
  $ProviderElement<Map<String, Map<String, double>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, Map<String, double>> create(Ref ref) {
    return allFriendBalancesByCurrency(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Map<String, double>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, Map<String, double>>>(value),
    );
  }
}

String _$allFriendBalancesByCurrencyHash() =>
    r'4b8e7bd3f7e5a1a20c45be547e33aed113a2b2c1';

/// Provides list of friend IDs with zero balances (settled up or new friends)

@ProviderFor(zeroBalanceFriendIds)
final zeroBalanceFriendIdsProvider = ZeroBalanceFriendIdsProvider._();

/// Provides list of friend IDs with zero balances (settled up or new friends)

final class ZeroBalanceFriendIdsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// Provides list of friend IDs with zero balances (settled up or new friends)
  ZeroBalanceFriendIdsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'zeroBalanceFriendIdsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$zeroBalanceFriendIdsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return zeroBalanceFriendIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$zeroBalanceFriendIdsHash() =>
    r'0c964f75270de06890889cece27bfe8ea33299d7';

/// Total amount the user is owed by all friends (sum of positive balances)

@ProviderFor(totalOwedToUser)
final totalOwedToUserProvider = TotalOwedToUserProvider._();

/// Total amount the user is owed by all friends (sum of positive balances)

final class TotalOwedToUserProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Total amount the user is owed by all friends (sum of positive balances)
  TotalOwedToUserProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'totalOwedToUserProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$totalOwedToUserHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalOwedToUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalOwedToUserHash() => r'8591f5a69d1c6797d151797230721f76ccae4ec0';

/// Total amount the user owes to all friends (sum of negative balances, returned positive)

@ProviderFor(totalUserOwes)
final totalUserOwesProvider = TotalUserOwesProvider._();

/// Total amount the user owes to all friends (sum of negative balances, returned positive)

final class TotalUserOwesProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Total amount the user owes to all friends (sum of negative balances, returned positive)
  TotalUserOwesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'totalUserOwesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$totalUserOwesHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalUserOwes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalUserOwesHash() => r'f8a651526bba514e48811445a69a861e317fc974';

/// Net balance across all friends (positive => friends owe user, negative => user owes)

@ProviderFor(netFriendBalance)
final netFriendBalanceProvider = NetFriendBalanceProvider._();

/// Net balance across all friends (positive => friends owe user, negative => user owes)

final class NetFriendBalanceProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Net balance across all friends (positive => friends owe user, negative => user owes)
  NetFriendBalanceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'netFriendBalanceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$netFriendBalanceHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return netFriendBalance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$netFriendBalanceHash() => r'73570694a92e829959cdb9d67dd02e1404b16e5f';
