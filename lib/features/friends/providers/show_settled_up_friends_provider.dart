import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'show_settled_up_friends_provider.g.dart';

@riverpod
class ShowSettledUpFriends extends _$ShowSettledUpFriends {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }
}
