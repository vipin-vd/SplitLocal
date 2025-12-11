import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/settings/providers/backup_restore_provider.dart';
import 'package:splitlocal/shared/utils/dialogs.dart';

class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupRestoreProvider);
    final notifier = ref.read(backupRestoreProvider.notifier);

    ref.listen(backupRestoreProvider.select((s) => s.successMessage),
        (prev, next) {
      if (next != null) {
        showSnackBar(context, next);
        notifier.clearMessages();
      }
    });
    ref.listen(backupRestoreProvider.select((s) => s.errorMessage),
        (prev, next) {
      if (next != null) {
        showSnackBar(context, next, isError: true);
        notifier.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: AbsorbPointer(
        absorbing: state.isProcessing,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _ExportCard(),
                SizedBox(height: 24),
                _ImportCard(),
                SizedBox(height: 24),
                _WarningCard(),
              ],
            ),
            if (state.isProcessing)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class _ExportCard extends ConsumerWidget {
  const _ExportCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(backupRestoreProvider.notifier).exportAsFile(),
              icon: const Icon(Icons.share),
              label: const Text('Export as File'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(backupRestoreProvider.notifier).exportToClipboard(),
              icon: const Icon(Icons.content_copy),
              label: const Text('Copy to Clipboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportCard extends ConsumerWidget {
  const _ImportCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupRestoreProvider);
    final notifier = ref.read(backupRestoreProvider.notifier);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Import Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final merge = await showDialog<bool>(
                    context: context,
                    builder: (context) => const _ImportModeDialog(),);
                if (merge != null) notifier.importFromFile(merge);
              },
              icon: const Icon(Icons.file_upload),
              label: const Text('Import from File'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: notifier.pasteFromClipboard,
              icon: const Icon(Icons.content_paste),
              label: const Text('Paste from Clipboard'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: state.importController,
              decoration: const InputDecoration(
                  labelText: 'JSON Data',
                  hintText: 'Paste your backup data here',),
              maxLines: 8,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final merge = await showDialog<bool>(
                    context: context,
                    builder: (context) => const _ImportModeDialog(),);
                if (merge != null) notifier.importFromText(merge);
              },
              icon: const Icon(Icons.restore),
              label: const Text('Import & Restore'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportModeDialog extends StatelessWidget {
  const _ImportModeDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Import Mode'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Merge'),),
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Replace'),),
      ],
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
            'Important: Importing will overwrite existing data unless merged. Keep your backups safe.',),
      ),
    );
  }
}
