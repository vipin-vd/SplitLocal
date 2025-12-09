import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/expenses/providers/settle_up_provider.dart';
import '../providers/transactions_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../shared/providers/services_provider.dart';
import '../../../shared/utils/dialogs.dart';
import '../../../shared/utils/formatters.dart';

class SettleUpScreen extends ConsumerWidget {
  final String groupId;
  final String? prePopulatePayer;
  final String? prePopulateRecipient;
  final double? prePopulateAmount;

  const SettleUpScreen({
    super.key,
    required this.groupId,
    this.prePopulatePayer,
    this.prePopulateRecipient,
    this.prePopulateAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider(groupId));
    final formNotifier = ref.read(settleUpFormProvider.notifier);

    // Pre-populate payer and recipient if provided
    if (prePopulatePayer != null ||
        prePopulateRecipient != null ||
        prePopulateAmount != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (prePopulatePayer != null &&
            ref.read(settleUpFormProvider).payerId == null) {
          formNotifier.setPayer(prePopulatePayer);
        }
        if (prePopulateRecipient != null &&
            ref.read(settleUpFormProvider).recipientId == null) {
          formNotifier.setRecipient(prePopulateRecipient);
        }
        if (prePopulateAmount != null &&
            ref.read(settleUpFormProvider).amountController.text.isEmpty) {
          ref.read(settleUpFormProvider).amountController.text =
              prePopulateAmount!.abs().toStringAsFixed(2);
        }
      });
    }

    ref.listen(settleUpFormProvider.select((s) => s.errorMessage),
        (prev, next) {
      if (next != null) {
        showSnackBar(context, next, isError: true);
        formNotifier.clearErrorMessage();
      }
    });

    ref.listen(settleUpFormProvider.select((s) => s.isSaving),
        (prev, isSaving) {
      if (!isSaving &&
          prev == true &&
          ref.read(settleUpFormProvider).errorMessage == null) {
        showSnackBar(context, 'Payment recorded');
        Navigator.pop(context);
      }
    });

    if (group == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Settle Up')),
          body: const Center(child: Text('Group not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settle Up')),
      body: Form(
        key: ref.watch(settleUpFormProvider).formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SuggestedSettlements(groupId: groupId),
            const SizedBox(height: 24),
            _RecordPaymentForm(groupId: groupId),
          ],
        ),
      ),
      bottomNavigationBar: _SavePaymentButton(groupId: groupId),
    );
  }
}

class _SuggestedSettlements extends ConsumerWidget {
  final String groupId;
  const _SuggestedSettlements({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtCalculator = ref.watch(debtCalculatorServiceProvider);
    final transactions = ref.watch(groupTransactionsProvider(groupId));
    final simplifiedDebts = debtCalculator.simplifyDebts(transactions);
    final members = ref.watch(usersProvider);
    final group = ref.watch(selectedGroupProvider(groupId))!;

    return simplifiedDebts.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Suggested Settlements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ...simplifiedDebts.map((debt) {
                final payer =
                    members.firstWhere((u) => u.id == debt.fromUserId);
                final recipient =
                    members.firstWhere((u) => u.id == debt.toUserId);
                return ListTile(
                  title: Text('${payer.name} → ${recipient.name}'),
                  trailing: Text(CurrencyFormatter.format(debt.amount,
                      currencyCode: group.currency)),
                  onTap: () => ref
                      .read(settleUpFormProvider.notifier)
                      .setFromSuggestion(
                          debt.fromUserId, debt.toUserId, debt.amount),
                );
              })
            ],
          );
  }
}

class _RecordPaymentForm extends ConsumerWidget {
  final String groupId;
  const _RecordPaymentForm({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settleUpFormProvider);
    final notifier = ref.read(settleUpFormProvider.notifier);
    final members = ref.watch(usersProvider).where((u) =>
        ref.watch(selectedGroupProvider(groupId))!.memberIds.contains(u.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Record Payment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: state.payerId,
          decoration: const InputDecoration(labelText: 'Payer'),
          items: members
              .map((member) =>
                  DropdownMenuItem(value: member.id, child: Text(member.name)))
              .toList(),
          onChanged: (value) => notifier.setPayer(value),
          validator: (value) => value == null ? 'Please select a payer' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: state.recipientId,
          decoration: const InputDecoration(labelText: 'Recipient'),
          items: members
              .map((member) =>
                  DropdownMenuItem(value: member.id, child: Text(member.name)))
              .toList(),
          onChanged: (value) => notifier.setRecipient(value),
          validator: (value) =>
              value == null ? 'Please select a recipient' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.amountController,
          decoration: const InputDecoration(labelText: 'Amount'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter an amount';
            if (double.tryParse(value) == null) return 'Invalid number';
            if (double.parse(value) <= 0) return 'Amount must be positive';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.notesController,
          decoration: const InputDecoration(labelText: 'Notes (Optional)'),
        ),
      ],
    );
  }
}

class _SavePaymentButton extends ConsumerWidget {
  final String groupId;
  const _SavePaymentButton({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settleUpFormProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: state.isSaving
            ? null
            : () =>
                ref.read(settleUpFormProvider.notifier).savePayment(groupId),
        child: state.isSaving
            ? const CircularProgressIndicator()
            : const Text('Record Payment'),
      ),
    );
  }
}
