import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:splitlocal/features/expenses/models/transaction.dart';
import 'package:splitlocal/features/expenses/models/transaction_type.dart';
import 'package:splitlocal/features/expenses/models/split_mode.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/shared/utils/formatters.dart';

part 'settle_up_provider.g.dart';

class SettleUpState {
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final String? payerId;
  final String? recipientId;
  final bool isSaving;
  final String? errorMessage;

  SettleUpState({
    required this.formKey,
    required this.amountController,
    required this.notesController,
    this.payerId,
    this.recipientId,
    this.isSaving = false,
    this.errorMessage,
  });

  SettleUpState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? amountController,
    TextEditingController? notesController,
    String? payerId,
    String? recipientId,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SettleUpState(
      formKey: formKey ?? this.formKey,
      amountController: amountController ?? this.amountController,
      notesController: notesController ?? this.notesController,
      payerId: payerId ?? this.payerId,
      recipientId: recipientId ?? this.recipientId,
      isSaving: isSaving ?? this.isSaving,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class SettleUpForm extends _$SettleUpForm {
  @override
  SettleUpState build() {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    ref.onDispose(() {
      amountController.dispose();
      notesController.dispose();
    });
    return SettleUpState(
      formKey: GlobalKey<FormState>(),
      amountController: amountController,
      notesController: notesController,
    );
  }

  void setPayer(String? payerId) {
    state = state.copyWith(payerId: payerId, clearErrorMessage: true);
  }

  void setRecipient(String? recipientId) {
    state = state.copyWith(recipientId: recipientId, clearErrorMessage: true);
  }

  void setFromSuggestion(String payerId, String recipientId, double amount) {
    state.amountController.text = amount.toStringAsFixed(2);
    state = state.copyWith(
        payerId: payerId, recipientId: recipientId, clearErrorMessage: true,);
  }

  Future<bool> savePayment(String groupId) async {
    if (!state.formKey.currentState!.validate()) return false;
    if (state.payerId == null || state.recipientId == null) {
      state = state.copyWith(errorMessage: 'Please select payer and recipient');
      return false;
    }
    if (state.payerId == state.recipientId) {
      state = state.copyWith(
          errorMessage: 'Payer and recipient cannot be the same',);
      return false;
    }

    state = state.copyWith(isSaving: true, clearErrorMessage: true);

    final deviceOwner = ref.read(deviceOwnerProvider);
    if (deviceOwner == null) {
      state = state.copyWith(
          isSaving: false, errorMessage: 'Device owner not found',);
      return false;
    }

    final amount = CurrencyFormatter.parse(state.amountController.text);
    final transaction = Transaction(
      id: const Uuid().v4(),
      groupId: groupId,
      type: TransactionType.payment,
      description: 'Settlement',
      totalAmount: amount,
      payers: {state.payerId!: amount},
      splits: {state.recipientId!: amount},
      splitMode: SplitMode.unequal,
      timestamp: DateTime.now(),
      notes: state.notesController.text.trim().isEmpty
          ? null
          : state.notesController.text.trim(),
      createdBy: deviceOwner.id,
    );

    try {
      await ref.read(transactionsProvider.notifier).addTransaction(transaction);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearErrorMessage() {
    state = state.copyWith(clearErrorMessage: true);
  }
}
