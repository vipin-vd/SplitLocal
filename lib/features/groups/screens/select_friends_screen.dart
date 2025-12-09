import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/friends/providers/friends_provider.dart';
import 'package:splitlocal/features/groups/models/user.dart';

class SelectFriendsScreen extends ConsumerStatefulWidget {
  const SelectFriendsScreen({super.key});

  @override
  ConsumerState<SelectFriendsScreen> createState() =>
      _SelectFriendsScreenState();
}

class _SelectFriendsScreenState extends ConsumerState<SelectFriendsScreen> {
  final List<User> _selectedFriends = [];

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_selectedFriends);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          final isSelected = _selectedFriends.contains(friend);
          return CheckboxListTile(
            title: Text(friend.name),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedFriends.add(friend);
                } else {
                  _selectedFriends.remove(friend);
                }
              });
            },
          );
        },
      ),
    );
  }
}
