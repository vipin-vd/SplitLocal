import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/shared/widgets/app_bar_search.dart';

part 'friend_filter_provider.g.dart';

class FriendFilter {
  final String searchQuery;

  FriendFilter({
    this.searchQuery = '',
  });

  FriendFilter copyWith({
    String? searchQuery,
  }) {
    return FriendFilter(
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

@riverpod
class FriendListFilter extends _$FriendListFilter
    implements SearchFilterNotifier<FriendFilter> {
  @override
  FriendFilter build() {
    return FriendFilter();
  }

  @override
  String get searchQuery => state.searchQuery;

  @override
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim().toLowerCase());
  }
}
