import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'storage/local_storage_service.dart';

class ExportImportService {
  final LocalStorageService storageService;

  ExportImportService(this.storageService);

  /// Export data to a JSON file and share it
  Future<bool> exportData({String? groupId}) async {
    try {
      // Get the data to export
      final data = storageService.exportToJson();
      
      // If groupId is provided, filter to only that group's data
      if (groupId != null) {
        final filteredData = _filterDataByGroup(data, groupId);
        data.clear();
        data.addAll(filteredData);
      }

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = groupId != null 
          ? 'splitlocal_group_${groupId}_${DateTime.now().millisecondsSinceEpoch}.json'
          : 'splitlocal_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${directory.path}/$fileName';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share the file
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: groupId != null ? 'SplitLocal Group Data' : 'SplitLocal Backup',
        text: 'Import this file in SplitLocal app to view the expense data.',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Import data from a JSON file
  Future<bool> importData({bool mergeWithExisting = false}) async {
    try {
      // Pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return false; // User cancelled
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        throw Exception('Invalid file path');
      }

      // Read the file
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate the data
      if (!_isValidExportData(data)) {
        throw Exception('Invalid SplitLocal data file');
      }

      if (mergeWithExisting) {
        await _mergeData(data);
      } else {
        // Clear and import
        await storageService.importFromJson(data);
      }

      return true;
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Filter export data to include only a specific group
  Map<String, dynamic> _filterDataByGroup(Map<String, dynamic> data, String groupId) {
    final group = (data['groups'] as List).firstWhere(
      (g) => g['id'] == groupId,
      orElse: () => null,
    );

    if (group == null) {
      throw Exception('Group not found');
    }

    // Get member IDs
    final memberIds = List<String>.from(group['memberIds'] ?? []);

    // Filter users (only members of this group)
    final users = (data['users'] as List)
        .where((u) => memberIds.contains(u['id']))
        .toList();

    // Filter transactions (only for this group)
    final transactions = (data['transactions'] as List)
        .where((t) => t['groupId'] == groupId)
        .toList();

    return {
      'version': data['version'],
      'exportedAt': data['exportedAt'],
      'users': users,
      'groups': [group],
      'transactions': transactions,
    };
  }

  /// Validate export data format
  bool _isValidExportData(Map<String, dynamic> data) {
    return data.containsKey('version') &&
        data.containsKey('users') &&
        data.containsKey('groups') &&
        data.containsKey('transactions') &&
        data['users'] is List &&
        data['groups'] is List &&
        data['transactions'] is List;
  }

  /// Merge imported data with existing data
  Future<void> _mergeData(Map<String, dynamic> data) async {
    // Get existing data
    final existingData = storageService.exportToJson();
    
    // Create maps for quick lookup
    final existingUserIds = (existingData['users'] as List)
        .map((u) => u['id'] as String)
        .toSet();
    final existingGroupIds = (existingData['groups'] as List)
        .map((g) => g['id'] as String)
        .toSet();
    final existingTransactionIds = (existingData['transactions'] as List)
        .map((t) => t['id'] as String)
        .toSet();

    // Merge users (skip duplicates)
    final newUsers = (data['users'] as List)
        .where((u) => !existingUserIds.contains(u['id']))
        .toList();
    
    // Merge groups (skip duplicates)
    final newGroups = (data['groups'] as List)
        .where((g) => !existingGroupIds.contains(g['id']))
        .toList();
    
    // Merge transactions (skip duplicates)
    final newTransactions = (data['transactions'] as List)
        .where((t) => !existingTransactionIds.contains(t['id']))
        .toList();

    // Create merged data
    final mergedData = {
      'version': data['version'],
      'exportedAt': DateTime.now().toIso8601String(),
      'users': [...existingData['users'] as List, ...newUsers],
      'groups': [...existingData['groups'] as List, ...newGroups],
      'transactions': [...existingData['transactions'] as List, ...newTransactions],
    };

    // Import merged data
    await storageService.importFromJson(mergedData);
  }

  /// Export only a specific group's data
  Future<bool> exportGroup(String groupId) async {
    return await exportData(groupId: groupId);
  }

  /// Get export file size estimate
  Future<String> getExportSizeEstimate() async {
    final data = storageService.exportToJson();
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString).length;
    
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
