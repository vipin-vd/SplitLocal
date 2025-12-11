import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/expenses/providers/split_method_provider.dart';
import '../models/split_mode.dart';
import '../../groups/models/user.dart';
import '../../../shared/utils/formatters.dart';

class SplitMethodScreen extends ConsumerWidget {
  final List<User> members;
  final SplitMode initialMode;
  final Map<String, double> initialSplits;
  final double totalAmount;
  final String deviceOwnerId;

  const SplitMethodScreen({
    super.key,
    required this.members,
    required this.initialMode,
    required this.initialSplits,
    required this.totalAmount,
    required this.deviceOwnerId,
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
            onPressed: () => Navigator.pop(context),),
        actions: [
          TextButton(
            onPressed: () {
              final result = notifier.onSave();
              if (result != null) {
                Navigator.pop(context, result);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid split')),);
              }
            },
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.green,
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
              deviceOwnerId: deviceOwnerId,),
          const Divider(),
          _Summary(provider: provider),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: SplitMode.values
            .map((mode) => ChoiceChip(
                  label: Text(mode.name),
                  selected: state.splitMode == mode,
                  onSelected: (selected) =>
                      {if (selected) notifier.setSplitMode(mode)},
                ),)
            .toList(),
      ),
    );
  }
}

class _MemberList extends ConsumerWidget {
  final SplitMethodProvider provider;
  final List<User> members;
  final String deviceOwnerId;

  const _MemberList(
      {required this.provider,
      required this.members,
      required this.deviceOwnerId,});

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
          return ListTile(
            title: Text(isDeviceOwner ? 'You' : member.name),
            trailing: SizedBox(
              width: 120,
              child: TextFormField(
                controller: state.controllers[member.id],
                decoration: InputDecoration(
                  suffixText: state.splitMode == SplitMode.percent
                      ? '%'
                      : (state.splitMode == SplitMode.shares ? 'shares' : null),
                  prefixText:
                      state.splitMode == SplitMode.unequal ? '\$ ' : null,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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

  const _Summary({required this.provider});

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
          title: Text('${CurrencyFormatter.format(amountPerPerson)}/person'),
          trailing: Text('${state.selectedMembers.length} people'),);
    }

    String totalLabel;
    String totalValue;
    switch (state.splitMode) {
      case SplitMode.percent:
        totalLabel = 'Total Percentage:';
        totalValue = '${totalSplitValue.toStringAsFixed(2)}%';
        break;
      case SplitMode.shares:
        totalLabel = 'Total Shares:';
        totalValue = totalSplitValue.toStringAsFixed(0);
        break;
      default:
        totalLabel = 'Total Amount:';
        totalValue = CurrencyFormatter.format(totalSplitValue);
    }
    return ListTile(title: Text(totalLabel), trailing: Text(totalValue));
  }
}
