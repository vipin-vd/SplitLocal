import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/split_mode.dart';
import '../providers/transactions_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../../shared/utils/dialogs.dart';
import '../../../../shared/utils/formatters.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String groupId;

  const AddExpenseScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  SplitMode _splitMode = SplitMode.equal;
  final Map<String, double> _payers = {};
  final Map<String, double> _splits = {};
  final Map<String, TextEditingController> _splitControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeDefaultPayer();
  }

  void _initializeDefaultPayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceOwner = ref.read(deviceOwnerProvider);
      if (deviceOwner != null) {
        setState(() {
          _payers[deviceOwner.id] = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _splitControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _calculateSplits() {
    final totalAmount = CurrencyFormatter.parse(_amountController.text);
    final group = ref.read(selectedGroupProvider(widget.groupId));
    
    if (group == null || totalAmount <= 0) return;

    _splits.clear();

    switch (_splitMode) {
      case SplitMode.equal:
        final perPerson = totalAmount / group.memberIds.length;
        for (final memberId in group.memberIds) {
          _splits[memberId] = perPerson;
        }
        break;

      case SplitMode.unequal:
      case SplitMode.percent:
      case SplitMode.shares:
        // For these modes, splits are manually entered
        // Just validate that they sum to totalAmount
        break;
    }

    setState(() {});
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final deviceOwner = ref.read(deviceOwnerProvider);
    if (deviceOwner == null) {
      if (mounted) {
        showSnackBar(context, 'Device owner not found', isError: true);
      }
      return;
    }

    final totalAmount = CurrencyFormatter.parse(_amountController.text);

    // Validate payers total matches amount
    final payersTotal = _payers.values.fold(0.0, (sum, amount) => sum + amount);
    if ((payersTotal - totalAmount).abs() > 0.01) {
      if (mounted) {
        showSnackBar(
          context,
          'Payers total must equal total amount',
          isError: true,
        );
      }
      return;
    }

    // Validate splits total matches amount
    _calculateSplits();
    final splitsTotal = _splits.values.fold(0.0, (sum, amount) => sum + amount);
    if ((splitsTotal - totalAmount).abs() > 0.01) {
      if (mounted) {
        showSnackBar(
          context,
          'Splits must add up to total amount',
          isError: true,
        );
      }
      return;
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      groupId: widget.groupId,
      type: TransactionType.expense,
      description: _descriptionController.text.trim(),
      totalAmount: totalAmount,
      payers: Map.from(_payers),
      splits: Map.from(_splits),
      splitMode: _splitMode,
      timestamp: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdBy: deviceOwner.id,
    );

    await ref.read(transactionsProvider.notifier).addTransaction(transaction);

    if (mounted) {
      showSnackBar(context, 'Expense added successfully');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider(widget.groupId));
    final users = ref.watch(usersProvider);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Expense')),
        body: const Center(child: Text('Group not found')),
      );
    }

    final members = users.where((u) => group.memberIds.contains(u.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Dinner at restaurant',
                prefixIcon: Icon(Icons.description),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Total Amount',
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
              onChanged: (_) => _calculateSplits(),
            ),
            const SizedBox(height: 24),

            // Paid By Section
            const Text(
              'Paid By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...members.map((member) {
              final isPayer = _payers.containsKey(member.id);
              return CheckboxListTile(
                title: Text(member.name),
                value: isPayer,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _payers[member.id] = 0.0;
                    } else {
                      _payers.remove(member.id);
                    }
                  });
                },
                secondary: isPayer
                    ? SizedBox(
                        width: 100,
                        child: TextFormField(
                          initialValue: _payers[member.id]?.toString() ?? '0',
                          decoration: const InputDecoration(
                            prefix: Text('\$ '),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            _payers[member.id] = CurrencyFormatter.parse(value);
                          },
                        ),
                      )
                    : null,
              );
            }),
            const SizedBox(height: 24),

            // Split Mode Section
            const Text(
              'Split Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<SplitMode>(
              segments: const [
                ButtonSegment(
                  value: SplitMode.equal,
                  label: Text('Equal'),
                  icon: Icon(Icons.people),
                ),
                ButtonSegment(
                  value: SplitMode.unequal,
                  label: Text('Exact'),
                ),
                ButtonSegment(
                  value: SplitMode.percent,
                  label: Text('%'),
                ),
                ButtonSegment(
                  value: SplitMode.shares,
                  label: Text('Shares'),
                ),
              ],
              selected: {_splitMode},
              onSelectionChanged: (Set<SplitMode> selection) {
                setState(() {
                  _splitMode = selection.first;
                  _calculateSplits();
                });
              },
            ),
            const SizedBox(height: 16),

            // Split Details
            if (_splitMode == SplitMode.equal) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: members.map((member) {
                      final share = _splits[member.id] ?? 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(member.name),
                            Text(
                              CurrencyFormatter.format(share, currencyCode: group.currency),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional details',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveExpense,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Add Expense'),
          ),
        ),
      ),
    );
  }
}
