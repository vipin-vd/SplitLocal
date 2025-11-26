import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/split_mode.dart';
import '../models/expense_category.dart';
import '../providers/transactions_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../../shared/utils/dialogs.dart';
import '../../../../shared/utils/formatters.dart';
import '../widgets/category_selector_dialog.dart';
import '../widgets/currency_selector_dialog.dart';
import 'paid_by_screen.dart';
import 'split_method_screen.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String groupId;
  final Transaction? transaction; // Optional - for edit mode

  const AddExpenseScreen({
    super.key,
    required this.groupId,
    this.transaction,
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
  ExpenseCategory _category = ExpenseCategory.general;
  final Map<String, double> _payers = {};
  final Map<String, double> _splits = {};
  final Map<String, TextEditingController> _splitControllers = {};
  bool _isRecurring = false;
  String _recurringFrequency = 'monthly';
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    
    // If editing, initialize from transaction, otherwise set defaults
    if (widget.transaction != null) {
      _initializeFromTransaction(widget.transaction!);
    } else {
      _initializeDefaultPayer();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final group = ref.read(selectedGroupProvider(widget.groupId));
      if (group != null && widget.transaction == null) {
        // Only set currency from group if not editing
        setState(() {
          _selectedCurrency = group.currency;
        });
      }
    });
  }

  void _initializeFromTransaction(Transaction transaction) {
    _descriptionController.text = transaction.description;
    _amountController.text = transaction.totalAmount.toStringAsFixed(2);
    _notesController.text = transaction.notes ?? '';
    _splitMode = transaction.splitMode;
    _category = transaction.category;
    _isRecurring = transaction.isRecurring;
    _recurringFrequency = transaction.recurringFrequency ?? 'monthly';
    
    // Get currency from group
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final group = ref.read(selectedGroupProvider(widget.groupId));
      if (group != null) {
        setState(() {
          _selectedCurrency = group.currency;
        });
      }
    });
    
    // Initialize payers and splits from transaction
    _payers.clear();
    _payers.addAll(transaction.payers);
    
    _splits.clear();
    _splits.addAll(transaction.splits);
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
    for (final controller in _splitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateSplits() {
    final totalAmount = CurrencyFormatter.parse(_amountController.text);
    final group = ref.read(selectedGroupProvider(widget.groupId));
    
    if (group == null || totalAmount <= 0) return;

    // Check if we have any configured splits (including explicit zeros)
    final hasAnySplitData = _splits.isNotEmpty;
    final hasNonZeroSplits = _splits.values.any((v) => v > 0);
    
    if (!hasAnySplitData) {
      // No split data at all - initialize defaults
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
          // Initialize to 0 for all members
          for (final memberId in group.memberIds) {
            _splits[memberId] = 0.0;
          }
          break;
      }
    } else if (hasNonZeroSplits && _splitMode == SplitMode.equal) {
      // We have configured equal splits - recalculate amounts but preserve selection
      final selectedMembers = _splits.entries
          .where((e) => e.value > 0)
          .map((e) => e.key)
          .toSet();
      
      if (selectedMembers.isNotEmpty) {
        final perPerson = totalAmount / selectedMembers.length;
        // Update amounts for selected members, keep zeros for unselected
        for (final entry in _splits.entries.toList()) {
          if (selectedMembers.contains(entry.key)) {
            _splits[entry.key] = perPerson;
          }
          // Keep existing 0.0 for unselected members
        }
      }
    }
    // For other modes with configured data, don't recalculate

    setState(() {});
  }

  String _getPaidByText() {
    final deviceOwner = ref.read(deviceOwnerProvider);
    if (_payers.isEmpty) return 'You';
    
    if (_payers.length == 1) {
      final payerId = _payers.keys.first;
      if (deviceOwner?.id == payerId) return 'You';
      
      final users = ref.read(usersProvider);
      final user = users.firstWhere((u) => u.id == payerId, orElse: () => deviceOwner!);
      return user.name;
    }
    
    return '${_payers.length} people';
  }

  String _getSplitMethodText() {
    switch (_splitMode) {
      case SplitMode.equal:
        return 'Equally';
      case SplitMode.unequal:
        return 'Unequally';
      case SplitMode.percent:
        return 'By Percentage';
      case SplitMode.shares:
        return 'By Shares';
    }
  }

  Future<void> _openCategorySelector() async {
    final result = await showDialog<ExpenseCategory>(
      context: context,
      builder: (context) => CategorySelectorDialog(
        currentCategory: _category,
      ),
    );
    
    if (result != null) {
      setState(() {
        _category = result;
      });
    }
  }

  Future<void> _openCurrencySelector() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => CurrencySelectorDialog(
        currentCurrency: _selectedCurrency,
      ),
    );
    
    if (result != null) {
      setState(() {
        _selectedCurrency = result;
      });
    }
  }

  Future<void> _openPaidByScreen() async {
    // Validate description and amount first
    if (_descriptionController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter a description first', isError: true);
      return;
    }
    
    final totalAmount = CurrencyFormatter.parse(_amountController.text);
    if (totalAmount <= 0) {
      showSnackBar(context, 'Please enter a valid amount first', isError: true);
      return;
    }
    
    final group = ref.read(selectedGroupProvider(widget.groupId));
    final users = ref.read(usersProvider);
    final deviceOwner = ref.read(deviceOwnerProvider);
    
    if (group == null || deviceOwner == null) return;
    
    final members = users.where((u) => group.memberIds.contains(u.id)).toList();
    
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder: (context) => PaidByScreen(
          members: members,
          initialPayers: _payers,
          totalAmount: totalAmount,
          deviceOwnerId: deviceOwner.id,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _payers.clear();
        _payers.addAll(result);
      });
    }
  }

  Future<void> _openSplitMethodScreen() async {
    // Validate description and amount first
    if (_descriptionController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter a description first', isError: true);
      return;
    }
    
    final totalAmount = CurrencyFormatter.parse(_amountController.text);
    if (totalAmount <= 0) {
      showSnackBar(context, 'Please enter a valid amount first', isError: true);
      return;
    }
    
    final group = ref.read(selectedGroupProvider(widget.groupId));
    final users = ref.read(usersProvider);
    final deviceOwner = ref.read(deviceOwnerProvider);
    
    if (group == null || deviceOwner == null) return;
    
    final members = users.where((u) => group.memberIds.contains(u.id)).toList();
    
    // Ensure all members have an entry in splits (even if 0)
    // This preserves the selection/unselection state
    final splitsToPass = Map<String, double>.from(_splits);
    for (final member in members) {
      if (!splitsToPass.containsKey(member.id)) {
        splitsToPass[member.id] = 0.0;
      }
    }
    
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SplitMethodScreen(
          members: members,
          initialMode: _splitMode,
          initialSplits: splitsToPass,
          totalAmount: totalAmount,
          deviceOwnerId: deviceOwner.id,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _splitMode = result['mode'] as SplitMode;
        _splits.clear();
        _splits.addAll(result['splits'] as Map<String, double>);
      });
    }
  }

  void _updateDefaultPayerAmount() {
    final totalAmount = CurrencyFormatter.parse(_amountController.text);
    final deviceOwner = ref.read(deviceOwnerProvider);
    
    if (deviceOwner != null && totalAmount > 0) {
      // Check if device owner is the only payer
      if (_payers.length == 1 && _payers.containsKey(deviceOwner.id)) {
        setState(() {
          _payers[deviceOwner.id] = totalAmount;
        });
      }
    }
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

    // Ensure splits are calculated if empty
    if (_splits.isEmpty) {
      _calculateSplits();
    }
    
    // Filter out zero-value splits for cleaner data
    final cleanedSplits = Map<String, double>.fromEntries(
      _splits.entries.where((entry) => entry.value > 0),
    );
    
    // Validate splits total matches amount
    final splitsTotal = cleanedSplits.values.fold(0.0, (sum, amount) => sum + amount);
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
      id: widget.transaction?.id ?? const Uuid().v4(),
      groupId: widget.groupId,
      type: TransactionType.expense,
      description: _descriptionController.text.trim(),
      totalAmount: totalAmount,
      payers: Map.from(_payers),
      splits: cleanedSplits,
      splitMode: _splitMode,
      timestamp: widget.transaction?.timestamp ?? DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdBy: widget.transaction?.createdBy ?? deviceOwner.id,
      category: _category,
      isRecurring: _isRecurring,
      recurringFrequency: _isRecurring ? _recurringFrequency : null,
    );

    // Update or add based on whether we're editing
    if (widget.transaction != null) {
      await ref.read(transactionsProvider.notifier).updateTransaction(transaction);
    } else {
      await ref.read(transactionsProvider.notifier).addTransaction(transaction);
    }

    if (mounted) {
      showSnackBar(
        context,
        widget.transaction != null
            ? 'Expense updated successfully'
            : 'Expense added successfully',
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider(widget.groupId));

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Expense')),
        body: const Center(child: Text('Group not found')),
      );
    }

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
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Dinner at restaurant',
                prefixIcon: IconButton(
                  icon: Icon(_category.icon, color: _category.color),
                  onPressed: _openCategorySelector,
                  tooltip: 'Select Category',
                ),
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
              decoration: InputDecoration(
                labelText: 'Total Amount',
                hintText: '0.00',
                prefixIcon: IconButton(
                  icon: Text(
                    CurrencySelectorDialog.getCurrencySymbol(_selectedCurrency),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _openCurrencySelector,
                  tooltip: 'Change Currency',
                ),
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
              onChanged: (_) {
                _calculateSplits();
                _updateDefaultPayerAmount();
              },
            ),
            const SizedBox(height: 24),

            // Modern Paid By and Split Method Section
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Paid by',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: _openPaidByScreen,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getPaidByText(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Split',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: _openSplitMethodScreen,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getSplitMethodText(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

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
            const SizedBox(height: 16),

            // Recurring Expense Option
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Recurring Expense'),
                    subtitle: const Text('Automatically repeat this expense'),
                    value: _isRecurring,
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value;
                      });
                    },
                  ),
                  if (_isRecurring) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        value: _recurringFrequency,
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                          DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _recurringFrequency = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
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
            child: Text(widget.transaction != null ? 'Update Expense' : 'Add Expense'),
          ),
        ),
      ),
    );
  }
}
