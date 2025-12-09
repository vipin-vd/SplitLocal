import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../groups/models/user.dart';
import '../providers/friend_balance_provider.dart';
import '../providers/friends_provider.dart';
import '../providers/show_settled_up_friends_provider.dart';

/// Overlay widget that reveals a curtain showing settled & zero-balance friends.
class SettledFriendsCurtain extends ConsumerWidget {
  const SettledFriendsCurtain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSettledUp = ref.watch(showSettledUpFriendsProvider);
    final allFriends = ref.watch(friendsProvider);
    final zeroBalanceIds = ref.watch(zeroBalanceFriendIdsProvider);

    // Filter friends by zero balance IDs
    final zeroBalanceFriends = allFriends
        .where((friend) => zeroBalanceIds.contains(friend.id))
        .toList();

    return Stack(
      children: [
        // Scrim fades in/out
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          opacity: showSettledUp ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !showSettledUp,
            child: GestureDetector(
              onTap: () {
                ref.read(showSettledUpFriendsProvider.notifier).toggle();
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        // Curtain drops from top
        AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          offset: showSettledUp ? Offset.zero : const Offset(0, -1),
          child: SafeArea(
            top: true,
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              snap: true,
              snapSizes: const [0.5, 0.9],
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Settled & Zero-Balance Friends',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${zeroBalanceFriends.length} friend${zeroBalanceFriends.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () {
                                ref
                                    .read(showSettledUpFriendsProvider.notifier)
                                    .toggle();
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Re-hide'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: zeroBalanceFriends.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 64,
                                      color: Colors.green[300],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No settled or zero-balance friends',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: zeroBalanceFriends.length,
                                itemBuilder: (context, index) {
                                  final friend = zeroBalanceFriends[index];
                                  return _ZeroBalanceFriendTile(friend: friend);
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ZeroBalanceFriendTile extends StatelessWidget {
  final User friend;
  const _ZeroBalanceFriendTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        child: Text(
          friend.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ),
      title: Text(friend.name),
      subtitle: const Text('No current balance'),
      trailing: Icon(Icons.check_circle, color: Colors.green[500]),
    );
  }
}
