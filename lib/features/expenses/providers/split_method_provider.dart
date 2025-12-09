import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/expenses/models/split_mode.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/shared/utils/formatters.dart';

part 'split_method_provider.g.dart';

class SplitMethodState {
  final SplitMode splitMode;
  final Map<String, double> splits;
  final Set<String> selectedMembers;
  final Map<String, TextEditingController> controllers;
  final double totalAmount;

  SplitMethodState({
    required this.splitMode,
    required this.splits,
    required this.selectedMembers,
    required this.controllers,
    required this.totalAmount,
  });

  SplitMethodState copyWith({
    SplitMode? splitMode,
    Map<String, double>? splits,
    Set<String>? selectedMembers,
    Map<String, TextEditingController>? controllers,
    double? totalAmount,
  }) {
    return SplitMethodState(
      splitMode: splitMode ?? this.splitMode,
      splits: splits ?? this.splits,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      controllers: controllers ?? this.controllers,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

@riverpod
class SplitMethod extends _$SplitMethod {
  @override
  SplitMethodState build(List<User> members, SplitMode initialMode,
      Map<String, double> initialSplits, double totalAmount) {
    final splits = Map<String, double>.from(initialSplits);
    final selectedMembers = initialSplits.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toSet();
    final controllers = <String, TextEditingController>{};

    for (final member in members) {
      controllers[member.id] = TextEditingController(
          text: splits[member.id]?.toStringAsFixed(2) ?? '0.00');
    }

    ref.onDispose(() {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    });

    final initialState = SplitMethodState(
        splitMode: initialMode,
        splits: splits,
        selectedMembers: selectedMembers.isEmpty
            ? Set.from(members.map((m) => m.id))
            : selectedMembers,
        controllers: controllers,
        totalAmount: totalAmount);

    // Initial calculation
    return _calculateSplits(initialState);
  }

  void setSplitMode(SplitMode mode) {
    state = _calculateSplits(state.copyWith(splitMode: mode));
  }

  void toggleMember(String memberId) {
    final newSelectedMembers = Set.of(state.selectedMembers);
    if (newSelectedMembers.contains(memberId)) {
      newSelectedMembers.remove(memberId);
    } else {
      newSelectedMembers.add(memberId);
    }
    state =
        _calculateSplits(state.copyWith(selectedMembers: newSelectedMembers));
  }

  void updateSplit(String memberId, String value) {
    final newSplits = Map.of(state.splits);
    newSplits[memberId] = CurrencyFormatter.parse(value);
    state = state.copyWith(splits: newSplits);
  }

  SplitMethodState _calculateSplits(SplitMethodState state) {
    if (state.totalAmount <= 0) return state;

    final newSplits = Map.of(state.splits);
    switch (state.splitMode) {
      case SplitMode.equal:
        if (state.selectedMembers.isNotEmpty) {
          final perPerson = state.totalAmount / state.selectedMembers.length;
          for (final memberId in state.selectedMembers) {
            newSplits[memberId] = perPerson;
            state.controllers[memberId]?.text = perPerson.toStringAsFixed(2);
          }
          for (final memberId in state.controllers.keys) {
            if (!state.selectedMembers.contains(memberId)) {
              newSplits[memberId] = 0;
              state.controllers[memberId]?.text = "0.00";
            }
          }
        }
        break;
      default:
        break;
    }
    return state.copyWith(splits: newSplits);
  }

  Map<String, dynamic>? onSave() {
    if (!_validateSplits()) return null;
    return {'mode': state.splitMode, 'splits': _getFinalSplits()};
  }

  bool _validateSplits() {
    switch (state.splitMode) {
      case SplitMode.equal:
        return state.selectedMembers.isNotEmpty;
      case SplitMode.unequal:
        final total =
            state.splits.values.fold(0.0, (sum, amount) => sum + amount);
        return (total - state.totalAmount).abs() < 0.01;
      case SplitMode.percent:
        final total =
            state.splits.values.fold(0.0, (sum, percent) => sum + percent);
        return (total - 100.0).abs() < 0.01;
      case SplitMode.shares:
        return state.splits.values.any((shares) => shares > 0);
    }
  }

  Map<String, double> _getFinalSplits() {
    final finalSplits = <String, double>{};
    switch (state.splitMode) {
      case SplitMode.equal:
        final perPerson = state.totalAmount / state.selectedMembers.length;
        for (final memberId in state.controllers.keys) {
          finalSplits[memberId] =
              state.selectedMembers.contains(memberId) ? perPerson : 0;
        }
        break;
      case SplitMode.unequal:
        return state.splits;
      case SplitMode.percent:
        for (final entry in state.splits.entries) {
          finalSplits[entry.key] = state.totalAmount * (entry.value / 100.0);
        }
        break;
      case SplitMode.shares:
        final totalShares =
            state.splits.values.fold(0.0, (sum, shares) => sum + shares);
        for (final entry in state.splits.entries) {
          finalSplits[entry.key] = totalShares > 0
              ? state.totalAmount * (entry.value / totalShares)
              : 0;
        }
        break;
    }
    return finalSplits;
  }
}
