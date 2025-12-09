import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../friends/providers/friends_provider.dart';
import '../../friends/providers/friend_group_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/models/user.dart';
import '../../groups/models/group.dart';
import '../screens/add_expense_screen.dart';

enum ExpenseTargetTab { groups, friends }

/// Bottom sheet for selecting a group or friend to add an expense to.
class AddExpenseTargetSelector extends ConsumerStatefulWidget {
  final ExpenseTargetTab? defaultTab;

  const AddExpenseTargetSelector({super.key, this.defaultTab});

  @override
  ConsumerState<AddExpenseTargetSelector> createState() =>
      _AddExpenseTargetSelectorState();
}

class _AddExpenseTargetSelectorState
    extends ConsumerState<AddExpenseTargetSelector> {
  late ExpenseTargetTab _selectedTab;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.defaultTab ?? ExpenseTargetTab.groups;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildSearchBar(),
            Expanded(
              child: _selectedTab == ExpenseTargetTab.groups
                  ? _buildGroupsList(scrollController)
                  : _buildFriendsList(scrollController),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Add Expense To',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<ExpenseTargetTab>(
        segments: const [
          ButtonSegment(
            value: ExpenseTargetTab.groups,
            label: Text('Groups'),
            icon: Icon(Icons.group),
          ),
          ButtonSegment(
            value: ExpenseTargetTab.friends,
            label: Text('Friends'),
            icon: Icon(Icons.person),
          ),
        ],
        selected: {_selectedTab},
        onSelectionChanged: (Set<ExpenseTargetTab> newSelection) {
          setState(() {
            _selectedTab = newSelection.first;
            _searchQuery = '';
            _searchController.clear();
          });
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText:
              'Search ${_selectedTab == ExpenseTargetTab.groups ? 'groups' : 'friends'}...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildGroupsList(ScrollController scrollController) {
    final allGroups = ref.watch(groupsProvider);
    // Filter out friend groups and apply search
    final groups = allGroups
        .where((g) =>
            !g.isFriendGroup && g.name.toLowerCase().contains(_searchQuery))
        .toList();

    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No groups yet' : 'No groups found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _GroupListItem(group: group);
      },
    );
  }

  Widget _buildFriendsList(ScrollController scrollController) {
    final friends = ref.watch(friendsProvider);
    final filteredFriends = friends
        .where((f) => f.name.toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredFriends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No friends yet' : 'No friends found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = filteredFriends[index];
        return _FriendListItem(friend: friend);
      },
    );
  }
}

class _GroupListItem extends StatelessWidget {
  final Group group;

  const _GroupListItem({required this.group});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          group.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(group.name),
      subtitle: Text(
        '${group.memberIds.length} member${group.memberIds.length != 1 ? 's' : ''}',
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddExpenseScreen(groupId: group.id),
          ),
        );
      },
    );
  }
}

class _FriendListItem extends ConsumerWidget {
  final User friend;

  const _FriendListItem({required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendGroup = ref.watch(friendGroupProvider(friend.id));

    return friendGroup.when(
      data: (group) => ListTile(
        leading: CircleAvatar(
          child: Text(
            friend.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(friend.name),
        subtitle: const Text('Individual expense'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(groupId: group.id),
            ),
          );
        },
      ),
      loading: () => ListTile(
        leading: CircleAvatar(
          child: Text(
            friend.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(friend.name),
        subtitle: const Text('Loading...'),
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => ListTile(
        leading: CircleAvatar(
          child: Text(
            friend.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(friend.name),
        subtitle: const Text('Error loading'),
        trailing: const Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }
}
