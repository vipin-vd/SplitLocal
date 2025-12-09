import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';
import 'package:splitlocal/features/groups/providers/groups_provider.dart';
import 'package:splitlocal/features/groups/providers/users_provider.dart';
import 'package:splitlocal/features/expenses/providers/transactions_provider.dart';

part 'backup_restore_provider.g.dart';

class BackupRestoreState {
  final bool isProcessing;
  final TextEditingController importController;
  final String? successMessage;
  final String? errorMessage;

  BackupRestoreState({
    this.isProcessing = false,
    required this.importController,
    this.successMessage,
    this.errorMessage,
  });

  BackupRestoreState copyWith({
    bool? isProcessing,
    TextEditingController? importController,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return BackupRestoreState(
      isProcessing: isProcessing ?? this.isProcessing,
      importController: importController ?? this.importController,
      successMessage:
          clearMessages ? null : successMessage ?? this.successMessage,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class BackupRestore extends _$BackupRestore {
  @override
  BackupRestoreState build() {
    final controller = TextEditingController();
    ref.onDispose(controller.dispose);
    return BackupRestoreState(importController: controller);
  }

  Future<void> exportToClipboard() async {
    state = state.copyWith(isProcessing: true, clearMessages: true);
    try {
      final data = ref.read(localStorageServiceProvider).exportToJson();
      await Clipboard.setData(ClipboardData(text: jsonEncode(data)));
      state = state.copyWith(
          isProcessing: false, successMessage: 'Data exported to clipboard!');
    } catch (e) {
      state = state.copyWith(
          isProcessing: false, errorMessage: 'Export failed: $e');
    }
  }

  Future<void> exportAsFile() async {
    state = state.copyWith(isProcessing: true, clearMessages: true);
    try {
      final success = await ref.read(exportImportServiceProvider).exportData();
      if (success) {
        state = state.copyWith(
            isProcessing: false, successMessage: 'Data exported as file!');
      } else {
        state = state.copyWith(isProcessing: false);
      }
    } catch (e) {
      state = state.copyWith(
          isProcessing: false, errorMessage: 'Export failed: $e');
    }
  }

  Future<void> importFromFile(bool merge) async {
    state = state.copyWith(isProcessing: true, clearMessages: true);
    try {
      final success = await ref
          .read(exportImportServiceProvider)
          .importData(mergeWithExisting: merge);
      if (success) {
        _invalidateProviders();
        state = state.copyWith(
            isProcessing: false, successMessage: 'Data imported successfully!');
      } else {
        state = state.copyWith(isProcessing: false);
      }
    } catch (e) {
      state = state.copyWith(
          isProcessing: false, errorMessage: 'Import failed: $e');
    }
  }

  Future<void> pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      state.importController.text = clipboardData!.text!;
    }
  }

  Future<void> importFromText(bool merge) async {
    state = state.copyWith(isProcessing: true, clearMessages: true);
    try {
      final data =
          jsonDecode(state.importController.text) as Map<String, dynamic>;
      await ref
          .read(localStorageServiceProvider)
          .importFromJson(data, merge: merge);
      _invalidateProviders();
      state = state.copyWith(
          isProcessing: false, successMessage: 'Data imported successfully!');
    } catch (e) {
      state = state.copyWith(
          isProcessing: false, errorMessage: 'Import failed: $e');
    }
  }

  void _invalidateProviders() {
    ref.invalidate(usersProvider);
    ref.invalidate(groupsProvider);
    ref.invalidate(transactionsProvider);
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }
}
