// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceOwnerHash() => r'e8f74e850655cb9f246007a9282ca57dbdd0806f';

/// See also [deviceOwner].
@ProviderFor(deviceOwner)
final deviceOwnerProvider = AutoDisposeProvider<User?>.internal(
  deviceOwner,
  name: r'deviceOwnerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deviceOwnerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceOwnerRef = AutoDisposeProviderRef<User?>;
String _$usersHash() => r'b04bacee4d89186e0c7db557526bf6a755041b2a';

/// See also [Users].
@ProviderFor(Users)
final usersProvider = AutoDisposeNotifierProvider<Users, List<User>>.internal(
  Users.new,
  name: r'usersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$usersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Users = AutoDisposeNotifier<List<User>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
