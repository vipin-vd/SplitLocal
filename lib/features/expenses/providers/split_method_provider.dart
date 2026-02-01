import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/features/expenses/models/split_mode.dart';
import 'package:splitlocal/features/groups/models/user.dart';
import 'package:splitlocal/shared/utils/formatters.dart';

part 'split_method_provider.g.dart';

class SplitMethodState {
  final SplitMode splitMode;
  final Map<String, double>
      splits; // The raw input values (%, shares, or amounts)
  final Set<String> selectedMembers;
  final Map<String, TextEditingController> controllers;
  final double totalAmount;
  final Map<String, double> calculatedAmounts; // Derived currency amounts

  SplitMethodState({
    required this.splitMode,
    required this.splits,
    required this.selectedMembers,
    required this.controllers,
    required this.totalAmount,
    required this.calculatedAmounts,
  });

  SplitMethodState copyWith({
    SplitMode? splitMode,
    Map<String, double>? splits,
    Set<String>? selectedMembers,
    Map<String, TextEditingController>? controllers,
    double? totalAmount,
    Map<String, double>? calculatedAmounts,
  }) {
    return SplitMethodState(
      splitMode: splitMode ?? this.splitMode,
      splits: splits ?? this.splits,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      controllers: controllers ?? this.controllers,
      totalAmount: totalAmount ?? this.totalAmount,
      calculatedAmounts: calculatedAmounts ?? this.calculatedAmounts,
    );
  }
}

@riverpod
class SplitMethod extends _$SplitMethod {
  @override
  SplitMethodState build(
    List<User> members,
    SplitMode initialMode,
    Map<String, double> initialSplits,
    double totalAmount,
  ) {
    // Sanitize splits: remove any member ID not in the provided members list
    final validMemberIds = members.map((m) => m.id).toSet();
    final splits = Map<String, double>.from(initialSplits)
      ..removeWhere((key, value) => !validMemberIds.contains(key));

    final selectedMembers =
        splits.entries.where((e) => e.value > 0).map((e) => e.key).toSet();
    final controllers = <String, TextEditingController>{};

    for (final member in members) {
      String initialText;
      final val = splits[member.id] ?? 0.0;

      if (initialMode == SplitMode.shares) {
        // If coming with 0 (default), set to 1. Else use value as int.
        // Actually AddExpense passes 0 maps by default to start.
        // But if user saved and came back, it might be > 0.
        // User said: "shares just keep 1 share each in begining"
        if (val == 0) {
          initialText = '1';
          splits[member.id] = 1.0;
        } else {
          initialText = val.toStringAsFixed(0);
        }
      } else if (initialMode == SplitMode.percent) {
        // "keep only placeholder instead of prepopulating"
        // If 0, show empty.
        initialText = val == 0 ? '' : val.toStringAsFixed(0);
      } else if (initialMode == SplitMode.unequal) {
        initialText = val == 0 ? '' : val.toStringAsFixed(2);
      } else {
        initialText = val.toStringAsFixed(2);
      }

      controllers[member.id] = TextEditingController(text: initialText);
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
      totalAmount: totalAmount,
      calculatedAmounts: {},
    );

    // Initial calculation
    return _calculateSplits(initialState);
  }

  void setSplitMode(SplitMode mode) {
    if (mode == state.splitMode) return;

    final newSplits = Map<String, double>.from(state.splits);

    if (mode == SplitMode.shares) {
      // "shares just keep 1 share each in begining"
      for (final key in newSplits.keys) {
        newSplits[key] = 1.0;
        state.controllers[key]?.text = '1';
      }
    } else if (mode == SplitMode.percent || mode == SplitMode.unequal) {
      // Clear for placeholder
      for (final key in newSplits.keys) {
        newSplits[key] = 0.0;
        state.controllers[key]?.text = '';
      }
    }
    // Equal mode is handled by _calculateSplits

    state =
        _calculateSplits(state.copyWith(splitMode: mode, splits: newSplits));
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
    var newSplits = Map.of(state.splits);
    newSplits[memberId] = CurrencyFormatter.parse(value);
    // Recalculate everything with the new input value
    state = _calculateSplits(state.copyWith(splits: newSplits));
  }

  SplitMethodState _calculateSplits(SplitMethodState state) {
    if (state.totalAmount <= 0) return state;

    final newSplits = Map.of(state.splits);
    final calculatedAmounts = <String, double>{};

    switch (state.splitMode) {
      case SplitMode.equal:
        if (state.selectedMembers.isNotEmpty) {
          final perPerson = state.totalAmount / state.selectedMembers.length;
          for (final memberId in state.selectedMembers) {
            newSplits[memberId] = perPerson;
            state.controllers[memberId]?.text = perPerson.toStringAsFixed(2);
            calculatedAmounts[memberId] = perPerson;
          }
          for (final memberId in state.controllers.keys) {
            if (!state.selectedMembers.contains(memberId)) {
              newSplits[memberId] = 0;
              state.controllers[memberId]?.text = '0.00';
              calculatedAmounts[memberId] = 0.0;
            }
          }
        }
        break;

      case SplitMode.unequal:
        // In unequal, the split value IS the amount
        for (final entry in state.splits.entries) {
          calculatedAmounts[entry.key] = entry.value;
        }
        break;

      case SplitMode.percent:
        for (final entry in state.splits.entries) {
          calculatedAmounts[entry.key] =
              state.totalAmount * (entry.value / 100.0);
        }
        break;

      case SplitMode.shares:
        final totalShares =
            state.splits.values.fold(0.0, (sum, shares) => sum + shares);
        for (final entry in state.splits.entries) {
          calculatedAmounts[entry.key] = totalShares > 0
              ? state.totalAmount * (entry.value / totalShares)
              : 0;
        }
        break;
    }
    return state.copyWith(
      splits: newSplits,
      calculatedAmounts: calculatedAmounts,
    );
  }

  Map<String, dynamic>? onSave() {
    if (!_validateSplits()) return null;
    return {'mode': state.splitMode, 'splits': state.calculatedAmounts};
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
}
