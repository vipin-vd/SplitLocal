import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/shared/utils/formatters.dart';
import '../../groups/models/user.dart';

part 'paid_by_provider.g.dart';

class PaidByState {
  final Map<String, double> payers;
  final Map<String, TextEditingController> controllers;
  final bool isMultiplePayers;
  final String? selectedSinglePayer;
  final double totalAmount;

  PaidByState({
    required this.payers,
    required this.controllers,
    required this.isMultiplePayers,
    this.selectedSinglePayer,
    required this.totalAmount,
  });

  PaidByState copyWith({
    Map<String, double>? payers,
    Map<String, TextEditingController>? controllers,
    bool? isMultiplePayers,
    String? selectedSinglePayer,
    double? totalAmount,
  }) {
    return PaidByState(
      payers: payers ?? this.payers,
      controllers: controllers ?? this.controllers,
      isMultiplePayers: isMultiplePayers ?? this.isMultiplePayers,
      selectedSinglePayer: selectedSinglePayer ?? this.selectedSinglePayer,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

@riverpod
class PaidBy extends _$PaidBy {
  @override
  PaidByState build(List<User> members, Map<String, double> initialPayers,
      double totalAmount, String deviceOwnerId,) {
    final payers = Map<String, double>.from(initialPayers);
    final controllers = <String, TextEditingController>{};
    for (final member in members) {
      final amount = payers[member.id] ?? 0.0;
      controllers[member.id] = TextEditingController(
          text: amount > 0 ? amount.toStringAsFixed(2) : '',);
      controllers[member.id]!.addListener(() => _updatePayer(member.id));
    }

    bool isMultiple = payers.length > 1;
    String? singlePayer = payers.length == 1
        ? payers.keys.first
        : (isMultiple ? null : deviceOwnerId);
    if (singlePayer != null && !isMultiple) {
      payers.clear();
      payers[singlePayer] = totalAmount;
    }

    ref.onDispose(() {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    });

    return PaidByState(
      payers: payers,
      controllers: controllers,
      isMultiplePayers: isMultiple,
      selectedSinglePayer: singlePayer,
      totalAmount: totalAmount,
    );
  }

  void _updatePayer(String memberId) {
    final text = state.controllers[memberId]?.text ?? '';
    final newPayers = Map.of(state.payers);
    if (text.isEmpty) {
      newPayers.remove(memberId);
    } else {
      newPayers[memberId] = CurrencyFormatter.parse(text);
    }
    state = state.copyWith(payers: newPayers);
  }

  void setMultiplePayers(bool isMultiple) {
    final newPayers = <String, double>{};
    if (!isMultiple) {
      newPayers[state.selectedSinglePayer ?? deviceOwnerId] = state.totalAmount;
    }
    for (var controller in state.controllers.values) {
      controller.clear();
    }
    state = state.copyWith(isMultiplePayers: isMultiple, payers: newPayers);
  }

  void setSinglePayer(String payerId) {
    final newPayers = {payerId: state.totalAmount};
    state = state.copyWith(selectedSinglePayer: payerId, payers: newPayers);
  }

  Map<String, double>? onSave() {
    if (state.isMultiplePayers) {
      final payersTotal =
          state.payers.values.fold(0.0, (sum, amount) => sum + amount);
      if ((payersTotal - state.totalAmount).abs() > 0.01) {
        return null;
      }
    }
    return state.payers;
  }
}
