import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../groups/providers/groups_provider.dart';
import '../../groups/providers/users_provider.dart';
import '../../expenses/providers/transactions_provider.dart';
import '../../../shared/providers/services_provider.dart';
import '../../../shared/utils/dialogs.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  final _importController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _exportData() async {
    setState(() => _isProcessing = true);

    try {
      final storage = ref.read(localStorageServiceProvider);
      final data = storage.exportToJson();
      final jsonString = jsonEncode(data);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        showSnackBar(context, 'Data exported to clipboard!');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Export failed: $e', isError: true);
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportAsFile() async {
    setState(() => _isProcessing = true);

    try {
      final exportService = ref.read(exportImportServiceProvider);
      final success = await exportService.exportData();

      if (mounted) {
        if (success) {
          showSnackBar(context, 'Data exported successfully!');
        } else {
          showSnackBar(context, 'Export cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Export failed: $e', isError: true);
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _importFromFile() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('How would you like to import the data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'replace'),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh),
                SizedBox(height: 4),
                Text('Replace All', textAlign: TextAlign.center),
                Text(
                  '(Delete existing data)',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'merge'),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.merge),
                SizedBox(height: 4),
                Text('Merge', textAlign: TextAlign.center),
                Text(
                  '(Keep existing data)',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (choice == null || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final exportService = ref.read(exportImportServiceProvider);
      final success = await exportService.importData(
        mergeWithExisting: choice == 'merge',
      );

      if (mounted) {
        if (success) {
          // Invalidate all providers to refresh UI
          ref.invalidate(usersProvider);
          ref.invalidate(groupsProvider);
          ref.invalidate(transactionsProvider);

          showSnackBar(context, 'Data imported successfully!');
        } else {
          showSnackBar(context, 'Import cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Import failed: $e', isError: true);
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _importData() async {
    if (_importController.text.trim().isEmpty) {
      showSnackBar(context, 'Please paste JSON data', isError: true);
      return;
    }

    final confirm = await showConfirmDialog(
      context,
      title: 'Confirm Import',
      message:
          'This will replace all existing data. Are you sure you want to continue?',
      confirmText: 'Import',
      cancelText: 'Cancel',
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final jsonString = _importController.text.trim();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final storage = ref.read(localStorageServiceProvider);
      await storage.importFromJson(data);

      if (mounted) {
        showSnackBar(context, 'Data imported successfully!');
        _importController.clear();
        
        // Invalidate all providers to refresh UI
        ref.invalidate(usersProvider);
        ref.invalidate(groupsProvider);
        ref.invalidate(transactionsProvider);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Import failed: Invalid JSON format or data',
          isError: true,
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        _importController.text = clipboardData!.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Export Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.upload, color: Color(0xFF6C63FF)),
                      SizedBox(width: 12),
                      Text(
                        'Export Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Export all your data (users, groups, transactions) to JSON format. '
                    'Share as a file or copy to clipboard.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _exportAsFile,
                    icon: const Icon(Icons.share),
                    label: const Text('Export as File'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _exportData,
                    icon: const Icon(Icons.content_copy),
                    label: const Text('Copy to Clipboard'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Import Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.download, color: Color(0xFF6C63FF)),
                      SizedBox(width: 12),
                      Text(
                        'Import Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Restore your data from a JSON backup file or paste JSON data. '
                    'Choose to replace or merge with existing data.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _importFromFile,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Import from File'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Or paste JSON data manually:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pasteFromClipboard,
                          icon: const Icon(Icons.content_paste),
                          label: const Text('Paste from Clipboard'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _importController,
                    decoration: const InputDecoration(
                      labelText: 'JSON Data',
                      hintText: 'Paste your backup data here',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 8,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _importData,
                    icon: const Icon(Icons.restore),
                    label: const Text('Import & Restore'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Warning Card
          Card(
            color: Colors.orange[50],
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important Notes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Keep your backup safe - store it in a secure location\n'
                          '• Importing will overwrite ALL existing data\n'
                          '• Make sure to export before uninstalling the app',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
