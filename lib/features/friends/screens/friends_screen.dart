import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/expenses/widgets/add_expense_entry.dart';
import 'package:splitlocal/features/expenses/widgets/add_expense_target_selector.dart';
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
import 'package:splitlocal/shared/widgets/currency_selector.dart';
import 'package:splitlocal/services/contacts_service.dart';
import 'package:splitlocal/shared/providers/preferred_currency_provider.dart';
import 'package:splitlocal/shared/widgets/multi_currency_amount_text.dart';
import 'package:uuid/uuid.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFriends = ref.watch(friendsProvider);
    final showSettledUp = ref.watch(showSettledUpFriendsProvider);
    final filter = ref.watch(friendListFilterProvider);
    final balances = ref.watch(allFriendBalancesProvider);
    final balancesByCurrency = ref.watch(allFriendBalancesByCurrencyProvider);
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
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'manual') {
                final newUser = await showDialog<User>(
                  context: context,
                  builder: (context) => const AddFriendManuallyDialog(),
                );
                if (newUser != null) {
                  final currentFriends = ref.read(friendsProvider);
                  // Check for duplicate phone number
                  if (newUser.phoneNumber != null &&
                      newUser.phoneNumber!.isNotEmpty) {
                    final isDuplicate = currentFriends.any(
                      (f) => f.phoneNumber == newUser.phoneNumber,
                    );
                    if (isDuplicate) {
                      if (context.mounted) {
                        showSnackBar(
                          context,
                          'A friend with this phone number already exists.',
                          isError: true,
                        );
                      }
                      return;
                    }
                  }

                  await ref.read(friendsProvider.notifier).addFriend(newUser);
                  if (context.mounted) {
                    showSnackBar(
                      context,
                      '${newUser.name} added to friends!',
                    );
                  }
                }
              } else if (value == 'contacts') {
                // The new logic for adding from contacts
                final contactsService = ContactsService();
                final contactData = await contactsService.pickContact();
                if (contactData != null && context.mounted) {
                  final name = contactData['name'] as String;
                  final phone = contactData['phoneNumber'] as String?;
                  final currentFriends = ref.read(friendsProvider);

                  // Check if friend with the same phone number already exists
                  User? existingFriend;
                  if (phone != null) {
                    existingFriend = currentFriends.cast<User?>().firstWhere(
                          (f) => f?.phoneNumber == phone,
                          orElse: () => null,
                        );
                  }

                  if (existingFriend != null) {
                    if (context.mounted) {
                      showSnackBar(
                        context,
                        '${existingFriend.name} is already your friend.',
                        isError: true,
                      );
                    }
                    return;
                  }

                  // Use a fresh UUID for the new user
                  final newUser = User(
                    id: const Uuid().v4(),
                    name: name,
                    phoneNumber: phone,
                    createdAt: DateTime.now(),
                  );

                  await ref.read(friendsProvider.notifier).addFriend(newUser);

                  if (context.mounted) {
                    showSnackBar(
                      context,
                      '$name added to friends!',
                    );
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
            tooltip: 'Add Friend',
            icon: Icon(
              Icons.person_add_alt_1,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(100),
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
                      balancesByCurrency:
                          balancesByCurrency[searchResults[index].id] ?? {},
                    );
                  }

                  // Handle Active Friends Section
                  if (index < activeFriends.length) {
                    return _FriendListTile(
                      friend: activeFriends[index],
                      balance: balances[activeFriends[index].id] ?? 0.0,
                      balancesByCurrency:
                          balancesByCurrency[activeFriends[index].id] ?? {},
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
                    balancesByCurrency: const {},
                    isSettled: true,
                  );
                },
              ),
            ),
      floatingActionButton: const AddExpenseEntry(
        heroTag: 'friends_add_expense',
        defaultTab: ExpenseTargetTab.friends,
      ),
    );
  }
}

class _FriendListTile extends StatelessWidget {
  final User friend;
  final double balance;
  final Map<String, double> balancesByCurrency;
  final bool isSettled;

  const _FriendListTile({
    required this.friend,
    required this.balance,
    required this.balancesByCurrency,
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
          : AbbreviatedMultiCurrencyAmountText(
              amounts: _absoluteBalances(balancesByCurrency),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: balanceColor,
              ),
              positiveColor: isPositive ? Colors.green : null,
              negativeColor: !isPositive ? Colors.red : null,
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

  Map<String, double> _absoluteBalances(Map<String, double> balances) {
    return balances.map((k, v) => MapEntry(k, v.abs()));
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
    final currency = ref.watch(dashboardCurrencyProvider);

    Color netColor;
    if (net.abs() < 0.01) {
      netColor = scheme.onSurfaceVariant;
    } else {
      netColor = net > 0 ? Colors.green : Colors.red;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CurrencySelector(
                selectedCurrency: currency,
                availableCurrencies: ref.watch(usedCurrenciesProvider),
                onChanged: (val) {
                  ref.read(dashboardCurrencyProvider.notifier).setCurrency(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TotalItem(
                  label: 'Balance',
                  amount: net,
                  color: netColor,
                  semanticsLabel: 'Overall balance',
                  currency: currency,
                  showInfoIcon: true,
                  infoTooltip: 'Balance = You\'re owed − You owe',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TotalItem(
                  label: "You're owed",
                  amount: owedToUser,
                  color: owedToUser > 0.01
                      ? Colors.green
                      : scheme.onSurfaceVariant,
                  semanticsLabel: "You're owed total",
                  currency: currency,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TotalItem(
                  label: 'You owe',
                  amount: userOwes,
                  color: userOwes > 0.01 ? Colors.red : scheme.onSurfaceVariant,
                  semanticsLabel: 'You owe total',
                  currency: currency,
                ),
              ),
            ],
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
    required this.currency,
    this.showInfoIcon = false,
    this.infoTooltip,
  });

  final String label;
  final double amount;
  final Color color;
  final String semanticsLabel;
  final String currency;
  final bool showInfoIcon;
  final String? infoTooltip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (showInfoIcon && infoTooltip != null) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: infoTooltip!,
                  child: Icon(
                    Icons.info_outline,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          AnimatedBalanceText(
            amount: amount,
            color: color,
            currencyCode: currency,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
