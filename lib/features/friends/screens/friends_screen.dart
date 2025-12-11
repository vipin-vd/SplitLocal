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
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/shared/utils/dialogs.dart';
import 'package:splitlocal/shared/widgets/animated_balance_text.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter friends
    final activeFriends = <User>[];
    final settledFriends = <User>[];
    final searchResults = <User>[];

    final isSearching = filter.searchQuery.isNotEmpty;

    if (isSearching) {
      searchResults.addAll(
        allFriends.where(
          (friend) => friend.name.toLowerCase().contains(filter.searchQuery),
        ),
      );
    } else {
      for (final friend in allFriends) {
        final balance = balances[friend.id] ?? 0.0;
        if (balance.abs() > 0.01) {
          activeFriends.add(friend);
        } else {
          settledFriends.add(friend);
        }
      }
    }

    // Determine total item count
    int itemCount;
    if (isSearching) {
      itemCount = searchResults.length;
    } else {
      itemCount = activeFriends.length; // Active friends
      if (settledFriends.isNotEmpty) {
        itemCount += 1; // Header/Divider
        if (showSettledUp) {
          itemCount += settledFriends.length; // Settled friends
        }
      }
    }

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
      body: itemCount == 0 && isSearching
          ? const Center(
              child: Text(
                'No friends found',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 400));
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  // Handle Search Results
                  if (isSearching) {
                    return _FriendListTile(
                      friend: searchResults[index],
                      balance: balances[searchResults[index].id] ?? 0.0,
                    );
                  }

                  // Handle Active Friends Section
                  if (index < activeFriends.length) {
                    return _FriendListTile(
                      friend: activeFriends[index],
                      balance: balances[activeFriends[index].id] ?? 0.0,
                    );
                  }

                  // Handle Header/Divider
                  if (index == activeFriends.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              const SizedBox(width: 16),
                              TextButton.icon(
                                onPressed: () {
                                  ref
                                      .read(
                                        showSettledUpFriendsProvider.notifier,
                                      )
                                      .toggle();
                                },
                                icon: Icon(
                                  showSettledUp
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 18,
                                ),
                                label: Text(
                                  showSettledUp
                                      ? 'Hide Settled Friends'
                                      : 'Show ${settledFriends.length} Settled Friends',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // Handle Settled Friends Section
                  final settledIndex = index - activeFriends.length - 1;
                  return _FriendListTile(
                    friend: settledFriends[settledIndex],
                    balance: 0.0, // Settled friends have 0 balance
                    isSettled: true,
                  );
                },
              ),
            ),
      floatingActionButton: const AddExpenseEntry(),
    );
  }
}

class _FriendListTile extends StatelessWidget {
  final User friend;
  final double balance;
  final bool isSettled;

  const _FriendListTile({
    required this.friend,
    required this.balance,
    this.isSettled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isPositive = balance > 0;

    // Style for settled friends (more muted)
    final textColor =
        isSettled ? scheme.onSurface.withValues(alpha: 0.6) : scheme.onSurface;
    final balanceColor = isSettled
        ? scheme.onSurfaceVariant
        : (isPositive ? Colors.green : Colors.red);

    return ListTile(
      key: ValueKey(friend.id),
      leading: CircleAvatar(
        backgroundColor: isSettled
            ? scheme.surfaceContainerHighest
            : scheme.secondaryContainer,
        child: Text(
          friend.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: isSettled
                ? scheme.onSurfaceVariant
                : scheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        friend.name,
        style: TextStyle(
          color: textColor,
          decoration: isSettled ? TextDecoration.none : null,
        ),
      ),
      trailing: isSettled
          ? Icon(
              Icons.check_circle_outline,
              size: 16,
              color: scheme.onSurfaceVariant,
            )
          : AnimatedBalanceText(
              amount: balance,
              color: balanceColor,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendDetailScreen(friend: friend),
          ),
        );
      },
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
              amount: net,
              color: netColor,
              semanticsLabel: 'Overall balance',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TotalItem(
              label: "You're owed",
              amount: owedToUser,
              color: owedToUser > 0.01 ? Colors.green : scheme.onSurfaceVariant,
              semanticsLabel: "You're owed total",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TotalItem(
              label: 'You owe',
              amount: userOwes,
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
    required this.amount,
    required this.color,
    required this.semanticsLabel,
  });

  final String label;
  final double amount;
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
          AnimatedBalanceText(
            amount: amount,
            color: color,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
