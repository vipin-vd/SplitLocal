import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/expenses/widgets/add_expense_entry.dart';
import 'package:splitlocal/features/friends/providers/friend_balance_provider.dart';
import 'package:splitlocal/shared/providers/net_totals_provider.dart';
import 'package:splitlocal/features/friends/providers/friends_provider.dart';
import 'package:splitlocal/features/friends/providers/show_settled_up_friends_provider.dart';
import 'package:splitlocal/features/friends/providers/friend_filter_provider.dart';
import 'package:splitlocal/features/friends/screens/friend_detail_screen.dart';
import 'package:splitlocal/features/friends/widgets/add_friend_manually_dialog.dart';
import 'package:splitlocal/features/friends/widgets/settled_friends_curtain.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/shared/utils/dialogs.dart';
import 'package:splitlocal/shared/utils/formatters.dart';
import 'package:splitlocal/shared/widgets/app_bar_search.dart';
import 'package:splitlocal/services/contacts_service.dart';
import 'package:uuid/uuid.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFriends = ref.watch(friendsProvider);
    final showSettledUp = ref.watch(showSettledUpFriendsProvider);
    final filter = ref.watch(friendListFilterProvider);
    final balances = ref.watch(allFriendBalancesProvider);
    final zeroBalanceIds = ref.watch(zeroBalanceFriendIdsProvider);

    final friends = allFriends.where((friend) {
      // Search filter - query is already normalized (trimmed + lowercased)
      if (filter.searchQuery.isNotEmpty) {
        return friend.name.toLowerCase().contains(filter.searchQuery);
      }

      if (showSettledUp) return true;
      final balance = balances[friend.id] ?? 0.0;
      return balance.abs() > 0.01;
    }).toList();

    // Calculate settled up friends count
    final settledUpFriendsCount = zeroBalanceIds.length;

    return Scaffold(
      appBar: AppBar(
        title: AppBarSearch<FriendListFilter>(
          getNotifier: (ref) => ref.read(friendListFilterProvider.notifier),
          queryProvider: friendListFilterProvider.select((s) => s.searchQuery),
          hintText: 'Search friends...',
          semanticsLabel: 'Search friends',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'manual') {
                  final newUser = await showDialog<User>(
                    context: context,
                    builder: (context) => const AddFriendManuallyDialog(),
                  );
                  if (newUser != null) {
                    await ref.read(friendsProvider.notifier).addFriend(newUser);
                    if (context.mounted) {
                      showSnackBar(
                        context,
                        '${newUser.name} added to friends!',
                      );
                    }
                  }
                } else if (value == 'contacts') {
                  final contactsService = ContactsService();
                  final contactData = await contactsService.pickContact();
                  if (contactData != null && context.mounted) {
                    final name = contactData['name'] ?? '';
                    final phoneNumber = contactData['phoneNumber'];

                    if (name.isNotEmpty) {
                      final user = User(
                        id: const Uuid().v4(),
                        name: name,
                        phoneNumber: phoneNumber,
                        isDeviceOwner: false,
                        createdAt: DateTime.now(),
                      );
                      await ref.read(friendsProvider.notifier).addFriend(user);
                      if (context.mounted) {
                        showSnackBar(
                          context,
                          '$name added to friends!',
                        );
                      }
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'manual',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 12),
                      Text('Add Manually'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'contacts',
                  child: Row(
                    children: [
                      Icon(Icons.contacts),
                      SizedBox(width: 12),
                      Text('Add From Contacts'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Friend',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(64),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _TotalsSummary(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Main content: friends list with RefreshIndicator and avatars
                friends.isEmpty && filter.searchQuery.isNotEmpty
                    ? const Center(
                        child: Text(
                          'No friends found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Trigger a provider refresh if needed
                          // In absence of a remote source, just a small delay to show feedback
                          await Future<void>.delayed(
                              const Duration(milliseconds: 400));
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            final balance = balances[friend.id] ?? 0.0;
                            final isPositive = balance > 0;
                            final isZero = balance.abs() < 0.01;
                            final scheme = Theme.of(context).colorScheme;
                            final amountColor = isZero
                                ? scheme.onSurfaceVariant
                                : (isPositive ? Colors.green : Colors.red);
                            return ListTile(
                              key: ValueKey(friend.id),
                              leading: CircleAvatar(
                                backgroundColor: scheme.secondaryContainer,
                                child: Text(
                                  friend.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                      color: scheme.onSecondaryContainer),
                                ),
                              ),
                              title: Text(friend.name),
                              trailing: Text(
                                CurrencyFormatter.format(balance),
                                style: TextStyle(color: amountColor),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FriendDetailScreen(friend: friend),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                // Centered reveal button (hidden when curtain is open or when searching)
                if (!showSettledUp && filter.searchQuery.isEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${allFriends.length} ${allFriends.length == 1 ? 'Friend' : 'Friends'}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () {
                              ref
                                  .read(showSettledUpFriendsProvider.notifier)
                                  .toggle();
                            },
                            icon: const Icon(Icons.visibility),
                            label: Text(
                              '$settledUpFriendsCount Show Settled & New Friends',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Previously settled or with no current balance',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Overlay curtain (hidden when searching)
                if (filter.searchQuery.isEmpty) const SettledFriendsCurtain(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const AddExpenseEntry(),
    );
  }
}

class _TotalsSummary extends ConsumerWidget {
  const _TotalsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final net = ref.watch(netBalanceGlobalProvider);
    final owedToUser = ref.watch(totalOwedToUserGlobalProvider);
    final userOwes = ref.watch(totalUserOwesGlobalProvider);

    Color netColor;
    if (net.abs() < 0.01) {
      netColor = scheme.onSurfaceVariant;
    } else {
      netColor = net > 0 ? Colors.green : Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TotalItem(
              label: 'Net',
              value: CurrencyFormatter.format(net),
              color: netColor,
              semanticsLabel: 'Overall balance',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TotalItem(
              label: "You're owed",
              value: CurrencyFormatter.format(owedToUser),
              color: owedToUser > 0.01 ? Colors.green : scheme.onSurfaceVariant,
              semanticsLabel: "You're owed total",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TotalItem(
              label: 'You owe',
              value: CurrencyFormatter.format(userOwes),
              color: userOwes > 0.01 ? Colors.red : scheme.onSurfaceVariant,
              semanticsLabel: 'You owe total',
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({
    required this.label,
    required this.value,
    required this.color,
    required this.semanticsLabel,
  });

  final String label;
  final String value;
  final Color color;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
