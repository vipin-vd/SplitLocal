// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_balance_with_friend_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupBalanceWithFriend)
final groupBalanceWithFriendProvider = GroupBalanceWithFriendFamily._();

final class GroupBalanceWithFriendProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  GroupBalanceWithFriendProvider._(
      {required GroupBalanceWithFriendFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'groupBalanceWithFriendProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupBalanceWithFriendHash();

  @override
  String toString() {
    return r'groupBalanceWithFriendProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return groupBalanceWithFriend(
      ref,
      argument.$1,
      argument.$2,
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
    return other is GroupBalanceWithFriendProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupBalanceWithFriendHash() =>
    r'2128b26abf1422290009fd2149e40da46636d931';

final class GroupBalanceWithFriendFamily extends $Family
    with
        $FunctionalFamilyOverride<
            double,
            (
              String,
              String,
            )> {
  GroupBalanceWithFriendFamily._()
      : super(
          retry: null,
          name: r'groupBalanceWithFriendProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GroupBalanceWithFriendProvider call(
    String groupId,
    String friendId,
  ) =>
      GroupBalanceWithFriendProvider._(argument: (
        groupId,
        friendId,
      ), from: this);

  @override
  String toString() => r'groupBalanceWithFriendProvider';
}

/// Returns friend balance within a specific group, grouped by currency.
/// Positive values mean friend owes you, negative means you owe them.

@ProviderFor(groupBalanceWithFriendByCurrency)
final groupBalanceWithFriendByCurrencyProvider =
    GroupBalanceWithFriendByCurrencyFamily._();

/// Returns friend balance within a specific group, grouped by currency.
/// Positive values mean friend owes you, negative means you owe them.

final class GroupBalanceWithFriendByCurrencyProvider
    extends $FunctionalProvider<Map<String, double>, Map<String, double>,
        Map<String, double>> with $Provider<Map<String, double>> {
  /// Returns friend balance within a specific group, grouped by currency.
  /// Positive values mean friend owes you, negative means you owe them.
  GroupBalanceWithFriendByCurrencyProvider._(
      {required GroupBalanceWithFriendByCurrencyFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'groupBalanceWithFriendByCurrencyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupBalanceWithFriendByCurrencyHash();

  @override
  String toString() {
    return r'groupBalanceWithFriendByCurrencyProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<Map<String, double>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, double> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return groupBalanceWithFriendByCurrency(
      ref,
      argument.$1,
      argument.$2,
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
    return other is GroupBalanceWithFriendByCurrencyProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupBalanceWithFriendByCurrencyHash() =>
    r'74730aa1d7ee9a281483d382119a0a37d2968103';

/// Returns friend balance within a specific group, grouped by currency.
/// Positive values mean friend owes you, negative means you owe them.

final class GroupBalanceWithFriendByCurrencyFamily extends $Family
    with
        $FunctionalFamilyOverride<
            Map<String, double>,
            (
              String,
              String,
            )> {
  GroupBalanceWithFriendByCurrencyFamily._()
      : super(
          retry: null,
          name: r'groupBalanceWithFriendByCurrencyProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Returns friend balance within a specific group, grouped by currency.
  /// Positive values mean friend owes you, negative means you owe them.

  GroupBalanceWithFriendByCurrencyProvider call(
    String groupId,
    String friendId,
  ) =>
      GroupBalanceWithFriendByCurrencyProvider._(argument: (
        groupId,
        friendId,
      ), from: this);

  @override
  String toString() => r'groupBalanceWithFriendByCurrencyProvider';
}
