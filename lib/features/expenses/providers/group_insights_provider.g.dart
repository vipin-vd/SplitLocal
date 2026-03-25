// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_insights_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userTotalPaid)
final userTotalPaidProvider = UserTotalPaidFamily._();

final class UserTotalPaidProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  UserTotalPaidProvider._(
      {required UserTotalPaidFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userTotalPaidProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userTotalPaidHash();

  @override
  String toString() {
    return r'userTotalPaidProvider'
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
    return userTotalPaid(
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
    return other is UserTotalPaidProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userTotalPaidHash() => r'eda998898daf4f70c67f453448609c36919ab1e7';

final class UserTotalPaidFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  UserTotalPaidFamily._()
      : super(
          retry: null,
          name: r'userTotalPaidProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserTotalPaidProvider call(
    String groupId,
  ) =>
      UserTotalPaidProvider._(argument: groupId, from: this);

  @override
  String toString() => r'userTotalPaidProvider';
}

@ProviderFor(userTotalShare)
final userTotalShareProvider = UserTotalShareFamily._();

final class UserTotalShareProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  UserTotalShareProvider._(
      {required UserTotalShareFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userTotalShareProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userTotalShareHash();

  @override
  String toString() {
    return r'userTotalShareProvider'
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
    return userTotalShare(
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
    return other is UserTotalShareProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userTotalShareHash() => r'09e89f2630544a8817b7c2c92926aa1c440f9a0e';

final class UserTotalShareFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  UserTotalShareFamily._()
      : super(
          retry: null,
          name: r'userTotalShareProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserTotalShareProvider call(
    String groupId,
  ) =>
      UserTotalShareProvider._(argument: groupId, from: this);

  @override
  String toString() => r'userTotalShareProvider';
}
