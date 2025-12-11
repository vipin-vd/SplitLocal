import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/shared/utils/formatters.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/split_mode.dart';
import '../models/expense_category.dart';
import '../models/transaction_type.dart';
import 'transactions_provider.dart';

part 'add_expense_form_provider.g.dart';

class AddExpenseFormState {
  final Transaction? initialTransaction;
  final String groupId;

  final GlobalKey<FormState> formKey;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final TextEditingController notesController;

  final SplitMode splitMode;
  final ExpenseCategory category;
  final Map<String, double> payers;
  final Map<String, double> splits;
  final bool isRecurring;
  final String recurringFrequency;
  final String selectedCurrency;
  final bool isSaving;
  final String? errorMessage;

  AddExpenseFormState({
    this.initialTransaction,
    required this.groupId,
    required this.formKey,
    required this.descriptionController,
    required this.amountController,
    required this.notesController,
    required this.splitMode,
    required this.category,
    required this.payers,
    required this.splits,
    required this.isRecurring,
    required this.recurringFrequency,
    required this.selectedCurrency,
    this.isSaving = false,
    this.errorMessage,
  });

  AddExpenseFormState copyWith({
    Transaction? initialTransaction,
    String? groupId,
    GlobalKey<FormState>? formKey,
    TextEditingController? descriptionController,
    TextEditingController? amountController,
    TextEditingController? notesController,
    SplitMode? splitMode,
    ExpenseCategory? category,
    Map<String, double>? payers,
    Map<String, double>? splits,
    bool? isRecurring,
    String? recurringFrequency,
    String? selectedCurrency,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AddExpenseFormState(
      initialTransaction: initialTransaction ?? this.initialTransaction,
      groupId: groupId ?? this.groupId,
      formKey: formKey ?? this.formKey,
      descriptionController:
          descriptionController ?? this.descriptionController,
      amountController: amountController ?? this.amountController,
      notesController: notesController ?? this.notesController,
      splitMode: splitMode ?? this.splitMode,
      category: category ?? this.category,
      payers: payers ?? this.payers,
      splits: splits ?? this.splits,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      isSaving: isSaving ?? this.isSaving,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class AddExpenseForm extends _$AddExpenseForm {
  @override
  AddExpenseFormState build(String groupId, Transaction? transaction) {
    final group = ref.watch(selectedGroupProvider(groupId));
    final currency = group?.currency ?? 'USD';

    final amountText =
        transaction != null ? transaction.totalAmount.toStringAsFixed(2) : '';

    final descriptionController =
        TextEditingController(text: transaction?.description ?? '');
    final amountController = TextEditingController(text: amountText);
    final notesController =
        TextEditingController(text: transaction?.notes ?? '');

    final payers = Map<String, double>.from(transaction?.payers ?? {});

    // Initialize default payer if it's a new expense
    if (transaction == null) {
      final deviceOwner = ref.read(deviceOwnerProvider);
      if (deviceOwner != null) {
        payers[deviceOwner.id] = 0.0;
        if (amountText.isNotEmpty && CurrencyFormatter.parse(amountText) > 0) {
          payers[deviceOwner.id] = CurrencyFormatter.parse(amountText);
        }
      }
    }

    // Add listener to amount controller
    amountController.addListener(_amountChanged);
    ref.onDispose(() {
      amountController.removeListener(_amountChanged);
      descriptionController.dispose();
      amountController.dispose();
      notesController.dispose();
    });

    return AddExpenseFormState(
      initialTransaction: transaction,
      groupId: groupId,
      formKey: GlobalKey<FormState>(),
      descriptionController: descriptionController,
      amountController: amountController,
      notesController: notesController,
      splitMode: transaction?.splitMode ?? SplitMode.equal,
      category: transaction?.category ?? ExpenseCategory.general,
      payers: payers,
      splits: Map.from(transaction?.splits ?? {}),
      isRecurring: transaction?.isRecurring ?? false,
      recurringFrequency: transaction?.recurringFrequency ?? 'monthly',
      selectedCurrency: currency,
    );
  }

  void _amountChanged() {
    _calculateSplits();
    _updateDefaultPayerAmount();
  }

  void _updateDefaultPayerAmount() {
    final totalAmount = CurrencyFormatter.parse(state.amountController.text);
    final deviceOwner = ref.read(deviceOwnerProvider);

    if (deviceOwner != null && totalAmount > 0) {
      if (state.payers.length == 1 &&
          state.payers.containsKey(deviceOwner.id)) {
        final newPayers = Map.of(state.payers);
        newPayers[deviceOwner.id] = totalAmount;
        state = state.copyWith(payers: newPayers);
      }
    }
  }

  void _calculateSplits() {
    final totalAmount = CurrencyFormatter.parse(state.amountController.text);
    final group = ref.read(selectedGroupProvider(state.groupId));
    if (group == null || totalAmount <= 0) return;

    final newSplits = Map.of(state.splits);

    final hasAnySplitData = newSplits.isNotEmpty;
    final hasNonZeroSplits = newSplits.values.any((v) => v > 0);

    if (!hasAnySplitData) {
      switch (state.splitMode) {
        case SplitMode.equal:
          final perPerson = totalAmount / group.memberIds.length;
          for (final memberId in group.memberIds) {
            newSplits[memberId] = perPerson;
          }
          break;
        case SplitMode.unequal:
        case SplitMode.percent:
        case SplitMode.shares:
          for (final memberId in group.memberIds) {
            newSplits[memberId] = 0.0;
          }
          break;
      }
    } else if (hasNonZeroSplits && state.splitMode == SplitMode.equal) {
      final selectedMembers =
          newSplits.entries.where((e) => e.value > 0).map((e) => e.key).toSet();

      if (selectedMembers.isNotEmpty) {
        final perPerson = totalAmount / selectedMembers.length;
        for (final key in newSplits.keys) {
          if (selectedMembers.contains(key)) {
            newSplits[key] = perPerson;
          }
        }
      }
    }
    state = state.copyWith(splits: newSplits);
  }

  String getPaidByText() {
    final deviceOwner = ref.read(deviceOwnerProvider);
    if (state.payers.isEmpty) return 'You';

    if (state.payers.length == 1) {
      final payerId = state.payers.keys.first;
      if (deviceOwner?.id == payerId) return 'You';

      final users = ref.read(usersProvider);
      final user =
          users.firstWhere((u) => u.id == payerId, orElse: () => deviceOwner!);
      return user.name;
    }

    return '${state.payers.length} people';
  }

  String getSplitMethodText() {
    switch (state.splitMode) {
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

  Future<bool> saveExpense() async {
    if (!state.formKey.currentState!.validate()) {
      return false;
    }
    state = state.copyWith(isSaving: true, clearErrorMessage: true);

    final deviceOwner = ref.read(deviceOwnerProvider);
    if (deviceOwner == null) {
      state = state.copyWith(
          isSaving: false, errorMessage: 'Device owner not found',);
      return false;
    }

    final totalAmount = CurrencyFormatter.parse(state.amountController.text);

    final payersTotal =
        state.payers.values.fold(0.0, (sum, amount) => sum + amount);
    if ((payersTotal - totalAmount).abs() > 0.01) {
      state = state.copyWith(
          isSaving: false,
          errorMessage: 'Payers total must equal total amount',);
      return false;
    }

    final splits = state.splits.isEmpty
        ? _calculateSplitsForSave(totalAmount)
        : state.splits;

    final cleanedSplits = Map<String, double>.fromEntries(
      splits.entries.where((entry) => entry.value > 0),
    );

    final splitsTotal =
        cleanedSplits.values.fold(0.0, (sum, amount) => sum + amount);
    if ((splitsTotal - totalAmount).abs() > 0.01) {
      state = state.copyWith(
          isSaving: false, errorMessage: 'Splits must add up to total amount',);
      return false;
    }

    final transaction = Transaction(
      id: state.initialTransaction?.id ?? const Uuid().v4(),
      groupId: state.groupId,
      type: TransactionType.expense,
      description: state.descriptionController.text.trim(),
      totalAmount: totalAmount,
      payers: Map.from(state.payers),
      splits: cleanedSplits,
      splitMode: state.splitMode,
      timestamp: state.initialTransaction?.timestamp ?? DateTime.now(),
      notes: state.notesController.text.trim().isEmpty
          ? null
          : state.notesController.text.trim(),
      createdBy: state.initialTransaction?.createdBy ?? deviceOwner.id,
      category: state.category,
      isRecurring: state.isRecurring,
      recurringFrequency: state.isRecurring ? state.recurringFrequency : null,
    );

    try {
      if (state.initialTransaction != null) {
        await ref
            .read(transactionsProvider.notifier)
            .updateTransaction(transaction);
      } else {
        await ref
            .read(transactionsProvider.notifier)
            .addTransaction(transaction);
      }
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
          isSaving: false, errorMessage: 'Error saving expense: $e',);
      return false;
    }
  }

  Map<String, double> _calculateSplitsForSave(double totalAmount) {
    final group = ref.read(selectedGroupProvider(state.groupId));
    if (group == null || totalAmount <= 0) return {};

    final newSplits = <String, double>{};
    switch (state.splitMode) {
      case SplitMode.equal:
        final perPerson = totalAmount / group.memberIds.length;
        for (final memberId in group.memberIds) {
          newSplits[memberId] = perPerson;
        }
        break;
      case SplitMode.unequal:
      case SplitMode.percent:
      case SplitMode.shares:
        for (final memberId in group.memberIds) {
          newSplits[memberId] = 0.0;
        }
        break;
    }
    return newSplits;
  }

  void clearErrorMessage() {
    state = state.copyWith(clearErrorMessage: true);
  }

  void setSplitMode(SplitMode mode) {
    state = state.copyWith(splitMode: mode, clearErrorMessage: true);
    _calculateSplits();
  }

  void setCategory(ExpenseCategory category) {
    state = state.copyWith(category: category, clearErrorMessage: true);
  }

  void setPayers(Map<String, double> payers) {
    state = state.copyWith(payers: payers, clearErrorMessage: true);
  }

  void setSplits(Map<String, double> splits) {
    state = state.copyWith(splits: splits, clearErrorMessage: true);
  }

  void setSplitsAndMode(SplitMode mode, Map<String, double> splits) {
    state = state.copyWith(
        splitMode: mode, splits: splits, clearErrorMessage: true,);
  }

  void setIsRecurring(bool isRecurring) {
    state = state.copyWith(isRecurring: isRecurring, clearErrorMessage: true);
  }

  void setRecurringFrequency(String frequency) {
    state =
        state.copyWith(recurringFrequency: frequency, clearErrorMessage: true);
  }

  void setCurrency(String currency) {
    state = state.copyWith(selectedCurrency: currency, clearErrorMessage: true);
  }
}
