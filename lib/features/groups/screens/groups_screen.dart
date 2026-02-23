import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/groups/models/group.dart';
import '../providers/groups_provider.dart';
import '../providers/users_provider.dart';
import '../providers/group_filter_provider.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/animated_balance_text.dart';
import '../../../shared/widgets/app_bar_search.dart';
import '../../../shared/widgets/currency_selector.dart';
import '../../expenses/providers/transactions_provider.dart';
import '../../expenses/widgets/add_expense_entry.dart';
import '../../expenses/widgets/add_expense_target_selector.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import '../../../shared/providers/net_totals_provider.dart';
import '../../../shared/providers/preferred_currency_provider.dart';
import '../../../shared/widgets/multi_currency_amount_text.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGroups = ref.watch(groupsProvider);
    final filter = ref.watch(groupListFilterProvider);

    // Filter out friend groups and apply search query
    final groups = allGroups.where((g) {
      if (g.isFriendGroup) return false;
      if (filter.searchQuery.isNotEmpty &&
          !g.name.toLowerCase().contains(filter.searchQuery)) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: AppBarSearch<GroupListFilter>(
          getNotifier: (ref) => ref.read(groupListFilterProvider.notifier),
          queryProvider: groupListFilterProvider.select((s) => s.searchQuery),
          hintText: 'Search groups...',
          semanticsLabel: 'Search groups',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Group',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _GroupsTotalsSummary(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: groups.isEmpty
                ? (filter.searchQuery.isEmpty
                    ? const _EmptyGroupsView()
                    : const Center(child: Text('No groups found')))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groups.length,
                    itemBuilder: (context, index) =>
                        _GroupListItem(group: groups[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: const AddExpenseEntry(
        heroTag: 'groups_add_expense',
        defaultTab: ExpenseTargetTab.groups,
      ),
    );
  }
}

class _GroupsTotalsSummary extends ConsumerWidget {
  const _GroupsTotalsSummary();

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
        color: Theme.of(context).brightness == Brightness.dark
            ? scheme.surfaceContainerHigh
            : scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: scheme.outlineVariant)
            : null,
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
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
                  semanticsLabel: 'Overall group balance',
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
                  semanticsLabel: "You're owed across groups",
                  currency: currency,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TotalItem(
                  label: 'You owe',
                  amount: userOwes,
                  color: userOwes > 0.01 ? Colors.red : scheme.onSurfaceVariant,
                  semanticsLabel: 'You owe across groups',
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

class _EmptyGroupsView extends StatelessWidget {
  const _EmptyGroupsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated container with icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ready to split expenses?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create a group for your next trip, shared apartment, or any expense you want to split with friends.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Group'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupListItem extends ConsumerWidget {
  final Group group;

  const _GroupListItem({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSpendByCurrency =
        ref.watch(groupTotalSpendByCurrencyProvider(group.id));
    final netBalancesByCurrency =
        ref.watch(groupNetBalancesByCurrencyProvider(group.id));
    final deviceOwner = ref.watch(deviceOwnerProvider);

    // Get my balances by currency
    final Map<String, double> myBalancesByCurrency = deviceOwner != null
        ? (netBalancesByCurrency[deviceOwner.id] ?? <String, double>{})
            .cast<String, double>()
        : <String, double>{};

    // Calculate overall net position across all currencies for status text
    final totalPositive = myBalancesByCurrency.values
        .where((v) => v > 0.01)
        .fold(0.0, (sum, v) => sum + v);
    final totalNegative = myBalancesByCurrency.values
        .where((v) => v < -0.01)
        .fold(0.0, (sum, v) => sum + v);
    final overallNet = totalPositive + totalNegative;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6C63FF),
          child: Text(
            group.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${group.memberIds.length} members'),
            _buildTotalSpendText(totalSpendByCurrency),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              overallNet > 0.01
                  ? 'You\'re owed'
                  : overallNet < -0.01
                      ? 'You owe'
                      : 'Settled',
              style: const TextStyle(fontSize: 11),
            ),
            AbbreviatedMultiCurrencyAmountText(
              amounts: _absoluteBalances(myBalancesByCurrency),
              primaryCurrency: group.currency,
              positiveColor: overallNet > 0.01 ? Colors.green : null,
              negativeColor: overallNet < -0.01 ? Colors.red : null,
              style: TextStyle(
                color: overallNet > 0.01
                    ? Colors.green
                    : overallNet < -0.01
                        ? Colors.red
                        : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupDetailScreen(groupId: group.id),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSpendText(Map<String, double> spendByCurrency) {
    if (spendByCurrency.isEmpty) {
      return Text(
        'Total spend: ${CurrencyFormatter.format(0, currencyCode: group.currency)}',
        style: const TextStyle(fontSize: 12),
      );
    }

    if (spendByCurrency.length == 1) {
      final entry = spendByCurrency.entries.first;
      return Text(
        'Total spend: ${CurrencyFormatter.format(entry.value, currencyCode: entry.key)}',
        style: const TextStyle(fontSize: 12),
      );
    }

    // Multiple currencies - show abbreviated
    final sorted = spendByCurrency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final primary = sorted.first;
    final remaining = spendByCurrency.length - 1;

    return Text(
      'Total spend: ${CurrencyFormatter.format(primary.value, currencyCode: primary.key)} +$remaining more',
      style: const TextStyle(fontSize: 12),
    );
  }

  Map<String, double> _absoluteBalances(Map<String, double> balances) {
    return balances.map((k, v) => MapEntry(k, v.abs()));
  }
}
