// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Users)
final usersProvider = UsersProvider._();

final class UsersProvider extends $NotifierProvider<Users, List<User>> {
  UsersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'usersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$usersHash();

  @$internal
  @override
  Users create() => Users();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<User> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<User>>(value),
    );
  }
}

String _$usersHash() => r'e23377476e50c30c1ace2b4d1bf2171b08fe930f';

abstract class _$Users extends $Notifier<List<User>> {
  List<User> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<User>, List<User>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<User>, List<User>>, List<User>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(deviceOwner)
final deviceOwnerProvider = DeviceOwnerProvider._();

final class DeviceOwnerProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  DeviceOwnerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deviceOwnerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deviceOwnerHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return deviceOwner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$deviceOwnerHash() => r'e8f74e850655cb9f246007a9282ca57dbdd0806f';
