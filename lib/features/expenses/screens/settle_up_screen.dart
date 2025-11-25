import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/split_mode.dart';
import '../providers/transactions_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../shared/providers/services_provider.dart';
import '../../../shared/utils/dialogs.dart';
import '../../../shared/utils/formatters.dart';

class SettleUpScreen extends ConsumerStatefulWidget {
  final String groupId;

  const SettleUpScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends ConsumerState<SettleUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _payerId;
  String? _recipientId;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_payerId == null || _recipientId == null) {
      if (mounted) {
        showSnackBar(context, 'Please select payer and recipient', isError: true);
      }
      return;
    }

    if (_payerId == _recipientId) {
      if (mounted) {
        showSnackBar(
          context,
          'Payer and recipient cannot be the same',
          isError: true,
        );
      }
      return;
    }

    final deviceOwner = ref.read(deviceOwnerProvider);
    if (deviceOwner == null) {
      if (mounted) {
        showSnackBar(context, 'Device owner not found', isError: true);
      }
      return;
    }

    final amount = CurrencyFormatter.parse(_amountController.text);

    final transaction = Transaction(
      id: const Uuid().v4(),
      groupId: widget.groupId,
      type: TransactionType.payment,
      description: 'Settlement',
      totalAmount: amount,
      payers: {_payerId!: amount},
      splits: {_recipientId!: amount},
      splitMode: SplitMode.unequal,
      timestamp: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdBy: deviceOwner.id,
    );

    await ref.read(transactionsProvider.notifier).addTransaction(transaction);

    if (mounted) {
      showSnackBar(context, 'Payment recorded successfully');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider(widget.groupId));
    final users = ref.watch(usersProvider);
    final netBalances = ref.watch(groupNetBalancesProvider(widget.groupId));

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settle Up')),
        body: const Center(child: Text('Group not found')),
      );
    }

    final members = users.where((u) => group.memberIds.contains(u.id)).toList();
    final debtCalculator = ref.read(debtCalculatorServiceProvider);
    final transactions = ref.watch(groupTransactionsProvider(widget.groupId));
    final simplifiedDebts = debtCalculator.simplifyDebts(transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settle Up'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Suggested Settlements
            if (simplifiedDebts.isNotEmpty) ...[
              const Text(
                'Suggested Settlements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: simplifiedDebts.map((debt) {
                      final payer = members.firstWhere(
                        (u) => u.id == debt.fromUserId,
                      );
                      final recipient = members.firstWhere(
                        (u) => u.id == debt.toUserId,
                      );
                      return ListTile(
                        leading: const Icon(Icons.trending_flat, color: Colors.green),
                        title: Text(
                          '${payer.name} → ${recipient.name}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(debt.amount, currencyCode: group.currency),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _payerId = debt.fromUserId;
                            _recipientId = debt.toUserId;
                            _amountController.text =
                                debt.amount.toStringAsFixed(2);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text(
              'Record Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Payer Dropdown
            DropdownButtonFormField<String>(
              initialValue: _payerId,
              decoration: const InputDecoration(
                labelText: 'Payer (Who paid?)',
                prefixIcon: Icon(Icons.person),
              ),
              items: members.map((member) {
                final balance = netBalances[member.id] ?? 0.0;
                return DropdownMenuItem(
                  value: member.id,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(member.name),
                      if (balance != 0)
                        Text(
                          balance > 0 ? 'Owed' : 'Owes',
                          style: TextStyle(
                            fontSize: 12,
                            color: balance > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _payerId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select who paid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Recipient Dropdown
            DropdownButtonFormField<String>(
              initialValue: _recipientId,
              decoration: const InputDecoration(
                labelText: 'Recipient (Who received?)',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: members.map((member) {
                final balance = netBalances[member.id] ?? 0.0;
                return DropdownMenuItem(
                  value: member.id,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(member.name),
                      if (balance != 0)
                        Text(
                          balance > 0 ? 'Owed' : 'Owes',
                          style: TextStyle(
                            fontSize: 12,
                            color: balance > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _recipientId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select who received';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = CurrencyFormatter.parse(value);
                if (amount <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g., Cash payment, Bank transfer',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Recording a payment will update balances but won\'t affect total group spending.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _savePayment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
            ),
            child: const Text('Record Payment'),
          ),
        ),
      ),
    );
  }
}
