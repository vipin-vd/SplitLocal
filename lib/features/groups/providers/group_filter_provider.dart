import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/shared/widgets/app_bar_search.dart';

part 'group_filter_provider.g.dart';

class GroupFilter {
  final String searchQuery;

  GroupFilter({
    this.searchQuery = '',
  });

  GroupFilter copyWith({
    String? searchQuery,
  }) {
    return GroupFilter(
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

@riverpod
class GroupListFilter extends _$GroupListFilter
    implements SearchFilterNotifier<GroupFilter> {
  @override
  GroupFilter build() {
    return GroupFilter();
  }

  @override
  String get searchQuery => state.searchQuery;

  @override
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim().toLowerCase());
  }
}
