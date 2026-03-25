// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(friendGroup)
final friendGroupProvider = FriendGroupFamily._();

final class FriendGroupProvider
    extends $FunctionalProvider<AsyncValue<Group>, Group, FutureOr<Group>>
    with $FutureModifier<Group>, $FutureProvider<Group> {
  FriendGroupProvider._(
      {required FriendGroupFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'friendGroupProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$friendGroupHash();

  @override
  String toString() {
    return r'friendGroupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Group> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Group> create(Ref ref) {
    final argument = this.argument as String;
    return friendGroup(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FriendGroupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$friendGroupHash() => r'714ed74da5de7d2fb3c7397d790bf7ef646c43bc';

final class FriendGroupFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Group>, String> {
  FriendGroupFamily._()
      : super(
          retry: null,
          name: r'friendGroupProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FriendGroupProvider call(
    String friendId,
  ) =>
      FriendGroupProvider._(argument: friendId, from: this);

  @override
  String toString() => r'friendGroupProvider';
}
