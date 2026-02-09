import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/expenses/providers/split_method_provider.dart';
import '../models/split_mode.dart';
import '../../groups/models/user.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/currency.dart';

class SplitMethodScreen extends ConsumerWidget {
  final List<User> members;
  final SplitMode initialMode;
  final Map<String, double> initialSplits;
  final double totalAmount;
  final String deviceOwnerId;
  final String currencyCode;

  const SplitMethodScreen({
    super.key,
    required this.members,
    required this.initialMode,
    required this.initialSplits,
    required this.totalAmount,
    required this.deviceOwnerId,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        splitMethodProvider(members, initialMode, initialSplits, totalAmount);
    final notifier = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Method'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final result = notifier.onSave();
              if (result != null) {
                Navigator.pop(context, result);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid split')),
                );
              }
            },
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SplitModeSelector(provider: provider),
          const Divider(),
          _MemberList(
            provider: provider,
            members: members,
            deviceOwnerId: deviceOwnerId,
            currencyCode: currencyCode,
          ),
          const Divider(),
          _Summary(
            provider: provider,
            currencyCode: currencyCode,
          ),
        ],
      ),
    );
  }
}

class _SplitModeSelector extends ConsumerWidget {
  final SplitMethodProvider provider;
  const _SplitModeSelector({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          for (final mode in SplitMode.values) ...[
            ChoiceChip(
              label: Text(mode.name),
              selected: state.splitMode == mode,
              onSelected: (selected) {
                if (selected) notifier.setSplitMode(mode);
              },
            ),
            if (mode != SplitMode.values.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _MemberList extends ConsumerWidget {
  final SplitMethodProvider provider;
  final List<User> members;
  final String deviceOwnerId;
  final String currencyCode;

  const _MemberList({
    required this.provider,
    required this.members,
    required this.deviceOwnerId,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return Expanded(
      child: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final isDeviceOwner = member.id == deviceOwnerId;

          if (state.splitMode == SplitMode.equal) {
            return CheckboxListTile(
              value: state.selectedMembers.contains(member.id),
              onChanged: (_) => notifier.toggleMember(member.id),
              title: Text(isDeviceOwner ? 'You' : member.name),
            );
          }
          final showCalculatedAmount = (state.splitMode == SplitMode.percent ||
              state.splitMode == SplitMode.shares);
          final calculatedAmount = state.calculatedAmounts[member.id] ?? 0;

          return ListTile(
            title: Text(isDeviceOwner ? 'You' : member.name),
            subtitle: showCalculatedAmount
                ? Text(
                    CurrencyFormatter.format(
                      calculatedAmount,
                      currencyCode: currencyCode,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
            trailing: SizedBox(
              width: 120,
              child: TextFormField(
                controller: state.controllers[member.id],
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  hintText: state.splitMode == SplitMode.percent
                      ? '0'
                      : (state.splitMode == SplitMode.shares ? '1' : '0.00'),
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.5),
                  ),
                  suffixText: state.splitMode == SplitMode.percent
                      ? '%'
                      : (state.splitMode == SplitMode.shares
                          ? ' shares'
                          : null),
                  prefixText: state.splitMode == SplitMode.unequal
                      ? '${CurrencyHelper.getSymbol(currencyCode)} '
                      : null,
                ),
                keyboardType: (state.splitMode == SplitMode.percent ||
                        state.splitMode == SplitMode.shares)
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: (state.splitMode == SplitMode.percent ||
                        state.splitMode == SplitMode.shares)
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                onChanged: (value) => notifier.updateSplit(member.id, value),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Summary extends ConsumerWidget {
  final SplitMethodProvider provider;
  final String currencyCode;

  const _Summary({
    required this.provider,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final totalSplitValue =
        state.splits.values.fold(0.0, (sum, val) => sum + val);

    if (state.splitMode == SplitMode.equal) {
      final amountPerPerson = state.selectedMembers.isEmpty
          ? 0.0
          : state.totalAmount / state.selectedMembers.length;
      return ListTile(
        title: Text(
          '${CurrencyFormatter.format(amountPerPerson, currencyCode: currencyCode)}/person',
        ),
        trailing: Text('${state.selectedMembers.length} people'),
      );
    }

    String totalLabel;
    String totalValue;
    String? subtitleText;
    Color? valueColor;

    switch (state.splitMode) {
      case SplitMode.percent:
        totalLabel = 'Total Percentage:';
        totalValue = '${totalSplitValue.toStringAsFixed(2)}%';
        final remaining = 100.0 - totalSplitValue;
        if (remaining.abs() > 0.01) {
          valueColor = remaining < 0 ? Colors.red : Colors.orange;
          subtitleText = remaining < 0
              ? 'Over by ${(remaining.abs()).toStringAsFixed(2)}%'
              : 'Remaining: ${remaining.toStringAsFixed(2)}%';
        } else {
          valueColor = Colors.green;
          subtitleText = 'Perfectly split';
        }
        break;

      case SplitMode.shares:
        totalLabel = 'Total Shares:';
        totalValue = totalSplitValue.toStringAsFixed(0);
        if (totalSplitValue > 0) {
          final oneShareVal = state.totalAmount / totalSplitValue;
          subtitleText =
              '1 share = ${CurrencyFormatter.format(oneShareVal, currencyCode: currencyCode)}';
        }
        break;

      default:
        totalLabel = 'Total Amount:';
        totalValue = CurrencyFormatter.format(
          totalSplitValue,
          currencyCode: currencyCode,
        );
        final remaining = state.totalAmount - totalSplitValue;
        if (remaining.abs() > 0.01) {
          valueColor = remaining < 0 ? Colors.red : Colors.orange;
          subtitleText = remaining < 0
              ? 'Over by ${CurrencyFormatter.format(remaining.abs(), currencyCode: currencyCode)}'
              : 'Remaining: ${CurrencyFormatter.format(remaining, currencyCode: currencyCode)}';
        } else {
          valueColor = Colors.green;
          subtitleText = 'Perfectly split';
        }
    }

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(totalLabel),
          Text(
            totalValue,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
    );
  }
}
