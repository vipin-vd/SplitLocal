import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

Future<bool?> showSettleDebtsDialog(
  BuildContext context, {
  required String title,
  required String memberName,
  required String debtInfo,
  required List<String> suggestions,
  String actionText = 'Back',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$memberName has outstanding debts that must be settled before this action.',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                debtInfo,
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'To proceed, you must:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ...suggestions.map(
              (suggestion) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8, top: 2),
                      child: Icon(Icons.check_circle_outline, size: 16),
                    ),
                    Expanded(
                        child: Text(suggestion,
                            style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(actionText),
        ),
      ],
    ),
  );
}

void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Text(message),
        ],
      ),
    ),
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}

class BlockingGroup {
  final String id;
  final String name;
  final bool canLeave;

  const BlockingGroup({
    required this.id,
    required this.name,
    required this.canLeave,
  });
}

Future<void> showCannotRemoveFriendDialog(
  BuildContext context, {
  required String friendName,
  required List<BlockingGroup> groups,
  void Function(String groupId)? onOpenGroup,
  void Function(String groupId)? onLeaveGroup,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cannot remove friend'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You cannot remove $friendName yet. There are outstanding balances in the following groups. Please settle up or leave the groups first.',
            ),
            const SizedBox(height: 12),
            ...groups.map(
              (g) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.group, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(g.name)),
                    TextButton(
                      onPressed:
                          onOpenGroup == null ? null : () => onOpenGroup(g.id),
                      child: const Text('Open Group'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: (onLeaveGroup == null || !g.canLeave)
                          ? null
                          : () => onLeaveGroup(g.id),
                      child: const Text('Leave Group'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tip: Outstanding debts must be settled before leaving a group.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
