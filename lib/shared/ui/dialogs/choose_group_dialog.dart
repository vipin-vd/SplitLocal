import 'package:flutter/material.dart';
import 'package:splitlocal/features/groups/models/group.dart';

/// A simple dialog to let users choose a group from a list.
/// Returns the selected Group or null if cancelled.
Future<Group?> showChooseGroupDialog({
  required BuildContext context,
  required List<Group> groups,
  String title = 'Choose a Group',
  String? subtitle,
}) async {
  if (groups.isEmpty) return null;

  return showDialog<Group>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
          ],
          ...groups.map((group) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  group.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(group.name),
              subtitle: Text('${group.memberIds.length} members'),
              onTap: () => Navigator.of(context).pop(group),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
