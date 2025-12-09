import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/expense_category.dart';
import '../providers/add_expense_form_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../../../shared/utils/dialogs.dart';
import '../../../../shared/utils/formatters.dart';
import '../widgets/category_selector_dialog.dart';
import '../widgets/currency_selector_dialog.dart';
import 'paid_by_screen.dart';
import 'split_method_screen.dart';

class AddExpenseScreen extends ConsumerWidget {
  final String groupId;
  final Transaction? transaction; // Optional - for edit mode

  const AddExpenseScreen({
    super.key,
    required this.groupId,
    this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = addExpenseFormProvider(groupId, transaction);
    final formState = ref.watch(provider);
    final formNotifier = ref.read(provider.notifier);

    ref.listen(provider.select((value) => value.errorMessage), (prev, next) {
      if (next != null) {
        showSnackBar(context, next, isError: true);
        formNotifier.clearErrorMessage();
      }
    });

    final group = ref.watch(selectedGroupProvider(groupId));

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Expense')),
        body: const Center(child: Text('Group not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(transaction != null ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Form(
        key: formState.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DescriptionAndAmountSection(
              formState: formState,
              formNotifier: formNotifier,
            ),
            const SizedBox(height: 24),
            _PaidByAndSplitSection(
              groupId: groupId,
              formState: formState,
              formNotifier: formNotifier,
            ),
            const SizedBox(height: 16),
            _NotesSection(formState: formState),
            const SizedBox(height: 16),
            _RecurringExpenseSection(
              formState: formState,
              formNotifier: formNotifier,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SaveButton(
        formState: formState,
        formNotifier: formNotifier,
      ),
    );
  }
}

class _DescriptionAndAmountSection extends ConsumerWidget {
  final AddExpenseFormState formState;
  final AddExpenseForm formNotifier;

  const _DescriptionAndAmountSection({
    required this.formState,
    required this.formNotifier,
  });

  Future<void> _openCategorySelector(BuildContext context) async {
    final result = await showDialog<ExpenseCategory>(
      context: context,
      builder: (context) => CategorySelectorDialog(
        currentCategory: formState.category,
      ),
    );
    if (result != null) {
      formNotifier.setCategory(result);
    }
  }

  Future<void> _openCurrencySelector(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => CurrencySelectorDialog(
        currentCurrency: formState.selectedCurrency,
      ),
    );
    if (result != null) {
      formNotifier.setCurrency(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TextFormField(
          controller: formState.descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'e.g., Dinner at restaurant',
            prefixIcon: IconButton(
              icon: Icon(formState.category.icon,
                  color: formState.category.color),
              onPressed: () => _openCategorySelector(context),
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
          controller: formState.amountController,
          decoration: InputDecoration(
            labelText: 'Total Amount',
            hintText: '0.00',
            prefixIcon: IconButton(
              icon: Text(
                CurrencySelectorDialog.getCurrencySymbol(
                    formState.selectedCurrency),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              onPressed: () => _openCurrencySelector(context),
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
        ),
      ],
    );
  }
}

class _PaidByAndSplitSection extends ConsumerWidget {
  final String groupId;
  final AddExpenseFormState formState;
  final AddExpenseForm formNotifier;

  const _PaidByAndSplitSection({
    required this.groupId,
    required this.formState,
    required this.formNotifier,
  });

  Future<void> _openPaidByScreen(BuildContext context, WidgetRef ref) async {
    if (formState.descriptionController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter a description first', isError: true);
      return;
    }
    final totalAmount =
        CurrencyFormatter.parse(formState.amountController.text);
    if (totalAmount <= 0) {
      showSnackBar(context, 'Please enter a valid amount first', isError: true);
      return;
    }

    final group = ref.read(selectedGroupProvider(groupId));
    final users = ref.read(usersProvider);
    final deviceOwner = ref.read(deviceOwnerProvider);

    if (group == null || deviceOwner == null) return;

    final members = users.where((u) => group.memberIds.contains(u.id)).toList();

    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder: (context) => PaidByScreen(
          members: members,
          initialPayers: formState.payers,
          totalAmount: totalAmount,
          deviceOwnerId: deviceOwner.id,
        ),
      ),
    );

    if (result != null) {
      formNotifier.setPayers(result);
    }
  }

  Future<void> _openSplitMethodScreen(
      BuildContext context, WidgetRef ref) async {
    if (formState.descriptionController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter a description first', isError: true);
      return;
    }
    final totalAmount =
        CurrencyFormatter.parse(formState.amountController.text);
    if (totalAmount <= 0) {
      showSnackBar(context, 'Please enter a valid amount first', isError: true);
      return;
    }

    final group = ref.read(selectedGroupProvider(groupId));
    final users = ref.read(usersProvider);
    final deviceOwner = ref.read(deviceOwnerProvider);

    if (group == null || deviceOwner == null) return;

    final members = users.where((u) => group.memberIds.contains(u.id)).toList();

    final splitsToPass = Map<String, double>.from(formState.splits);
    for (final member in members) {
      splitsToPass.putIfAbsent(member.id, () => 0.0);
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SplitMethodScreen(
          members: members,
          initialMode: formState.splitMode,
          initialSplits: splitsToPass,
          totalAmount: totalAmount,
          deviceOwnerId: deviceOwner.id,
        ),
      ),
    );

    if (result != null) {
      formNotifier.setSplitsAndMode(result['mode'], result['splits']);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildSelector(
                context,
                title: 'Paid by',
                value: formNotifier.getPaidByText(),
                onTap: () => _openPaidByScreen(context, ref),
                colorScheme: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSelector(
                context,
                title: 'Split',
                value: formNotifier.getSplitMethodText(),
                onTap: () => _openSplitMethodScreen(context, ref),
                colorScheme: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onTap,
    required Color colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 20, color: colorScheme),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  final AddExpenseFormState formState;

  const _NotesSection({required this.formState});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: formState.notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional details',
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }
}

class _RecurringExpenseSection extends StatelessWidget {
  final AddExpenseFormState formState;
  final AddExpenseForm formNotifier;

  const _RecurringExpenseSection({
    required this.formState,
    required this.formNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Recurring Expense'),
            subtitle: const Text('Automatically repeat this expense'),
            value: formState.isRecurring,
            onChanged: formNotifier.setIsRecurring,
          ),
          if (formState.isRecurring) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: formState.recurringFrequency,
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
                    formNotifier.setRecurringFrequency(value);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final AddExpenseFormState formState;
  final AddExpenseForm formNotifier;

  const _SaveButton({
    required this.formState,
    required this.formNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: formState.isSaving
              ? null
              : () async {
                  final success = await formNotifier.saveExpense();
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    final message = formState.initialTransaction != null
                        ? 'Expense updated successfully'
                        : 'Expense added successfully';
                    showSnackBar(context, message);
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: formState.isSaving
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(formState.initialTransaction != null
                  ? 'Update Expense'
                  : 'Add Expense'),
        ),
      ),
    );
  }
}
