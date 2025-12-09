import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/expenses/providers/paid_by_provider.dart';
import '../../groups/models/user.dart';
import '../../../shared/utils/formatters.dart';

class PaidByScreen extends ConsumerWidget {
  final List<User> members;
  final Map<String, double> initialPayers;
  final double totalAmount;
  final String deviceOwnerId;

  const PaidByScreen({
    super.key,
    required this.members,
    required this.initialPayers,
    required this.totalAmount,
    required this.deviceOwnerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        paidByProvider(members, initialPayers, totalAmount, deviceOwnerId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Who Paid?'),
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: () {
              final result = notifier.onSave();
              if (result != null) {
                Navigator.pop(context, result);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Payers total must equal total amount')));
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
          _PayerModeToggle(provider: provider),
          if (state.isMultiplePayers) _RemainingAmountIndicator(state: state),
          _MemberList(
              provider: provider,
              members: members,
              deviceOwnerId: deviceOwnerId),
        ],
      ),
    );
  }
}

class _PayerModeToggle extends ConsumerWidget {
  final PaidByProvider provider;
  const _PayerModeToggle({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('Single Person')),
          ButtonSegment(value: true, label: Text('Multiple People')),
        ],
        selected: {state.isMultiplePayers},
        onSelectionChanged: (selection) =>
            notifier.setMultiplePayers(selection.first),
      ),
    );
  }
}

class _RemainingAmountIndicator extends StatelessWidget {
  final PaidByState state;
  const _RemainingAmountIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    final currentTotal =
        state.payers.values.fold(0.0, (sum, amount) => sum + amount);
    final remaining = state.totalAmount - currentTotal;
    final isValid = remaining.abs() < 0.01;

    return Container(
      padding: const EdgeInsets.all(16),
      color: isValid
          ? Colors.green.withOpacity(0.1)
          : Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          Text(isValid
              ? 'All set!'
              : 'Remaining: ${CurrencyFormatter.format(remaining)}'),
        ],
      ),
    );
  }
}

class _MemberList extends ConsumerWidget {
  final PaidByProvider provider;
  final List<User> members;
  final String deviceOwnerId;

  const _MemberList(
      {required this.provider,
      required this.members,
      required this.deviceOwnerId});

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

          return state.isMultiplePayers
              ? _MultiplePayerItem(
                  controller: state.controllers[member.id]!,
                  member: member,
                  isDeviceOwner: isDeviceOwner)
              : _SinglePayerItem(
                  member: member,
                  isDeviceOwner: isDeviceOwner,
                  groupValue: state.selectedSinglePayer,
                  onChanged: (value) => notifier.setSinglePayer(value!),
                );
        },
      ),
    );
  }
}

class _MultiplePayerItem extends StatelessWidget {
  final TextEditingController controller;
  final User member;
  final bool isDeviceOwner;

  const _MultiplePayerItem(
      {required this.controller,
      required this.member,
      required this.isDeviceOwner});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(member.name[0])),
      title: Text(isDeviceOwner ? 'You' : member.name),
      trailing: SizedBox(
        width: 120,
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '0.00'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
    );
  }
}

class _SinglePayerItem extends StatelessWidget {
  final User member;
  final bool isDeviceOwner;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _SinglePayerItem(
      {required this.member,
      required this.isDeviceOwner,
      required this.groupValue,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(isDeviceOwner ? 'You' : member.name),
      value: member.id,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
