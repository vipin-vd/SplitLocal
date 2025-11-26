import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../providers/groups_provider.dart';
import '../providers/users_provider.dart';
import '../../../shared/providers/services_provider.dart';
import '../../../shared/utils/dialogs.dart';
import '../../../shared/utils/currency.dart';
import '../widgets/add_member_manually_dialog.dart';
import '../widgets/edit_member_dialog.dart';

class _DeleteGroupDialog extends StatefulWidget {
  const _DeleteGroupDialog();

  @override
  State<_DeleteGroupDialog> createState() => _DeleteGroupDialogState();
}

class _DeleteGroupDialogState extends State<_DeleteGroupDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _confirmController.removeListener(_onTextChanged);
    _confirmController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isValid = _confirmController.text.trim().toLowerCase() == 'delete';
    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action cannot be undone. All expenses and settlements in this group will be permanently deleted.',
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          const Text(
            'Type "delete" to confirm:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            decoration: const InputDecoration(
              hintText: 'delete',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isValid ? () => Navigator.pop(context, true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
          ),
          child: const Text('Delete Group'),
        ),
      ],
    );
  }
}

class GroupSettingsScreen extends ConsumerStatefulWidget {
  final Group group;

  const GroupSettingsScreen({
    super.key,
    required this.group,
  });

  @override
  ConsumerState<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends ConsumerState<GroupSettingsScreen> {
  Future<void> _addMembers() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: const Text('How would you like to add a member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'manual'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('Enter Manually'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'contacts'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.contacts),
                SizedBox(width: 8),
                Text('From Contacts'),
              ],
            ),
          ),
        ],
      ),
    );

    if (choice == null || !mounted) return;

    if (choice == 'manual') {
      await _addMemberManually();
    } else {
      await _addMemberFromContacts();
    }
  }

  Future<void> _addMemberManually() async {
    final user = await showDialog<User>(
      context: context,
      builder: (context) => const AddMemberManuallyDialog(),
    );

    if (user == null || !mounted) return;

    try {
      final usersNotifier = ref.read(usersProvider.notifier);
      final groupsNotifier = ref.read(groupsProvider.notifier);

      // Check if user with same phone exists
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        final existingUsers = ref.read(usersProvider);
        final existing = existingUsers.where((u) => u.phoneNumber == user.phoneNumber).firstOrNull;
        
        if (existing != null) {
          if (!widget.group.memberIds.contains(existing.id)) {
            final updatedMemberIds = [...widget.group.memberIds, existing.id];
            final updatedGroup = widget.group.copyWith(
              memberIds: updatedMemberIds,
              updatedAt: DateTime.now(),
            );
            
            await groupsNotifier.updateGroup(updatedGroup);
            
            if (mounted) {
              showSnackBar(context, 'Existing member ${existing.name} added to group');
            }
          } else {
            if (mounted) {
              showSnackBar(context, '${existing.name} is already a member');
            }
          }
          return;
        }
      }

      // Add new user
      await usersNotifier.addUser(user);
      
      final updatedMemberIds = [...widget.group.memberIds, user.id];
      final updatedGroup = widget.group.copyWith(
        memberIds: updatedMemberIds,
        updatedAt: DateTime.now(),
      );
      
      await groupsNotifier.updateGroup(updatedGroup);
      
      if (mounted) {
        showSnackBar(context, '${user.name} added successfully');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error adding member: $e', isError: true);
      }
    }
  }

  Future<void> _addMemberFromContacts() async {
    final contactsService = ref.read(contactsServiceProvider);
    
    try {
      final contacts = await contactsService.pickContact();
      if (contacts == null) return;

      final usersNotifier = ref.read(usersProvider.notifier);
      final groupsNotifier = ref.read(groupsProvider.notifier);
      
      final user = await usersNotifier.createUserFromContact(contacts);
      if (!widget.group.memberIds.contains(user.id)) {
        final updatedMemberIds = [...widget.group.memberIds, user.id];
        final updatedGroup = widget.group.copyWith(
          memberIds: updatedMemberIds,
          updatedAt: DateTime.now(),
        );
        
        await groupsNotifier.updateGroup(updatedGroup);
        
        if (mounted) {
          showSnackBar(context, 'Member added successfully');
        }
      } else {
        if (mounted) {
          showSnackBar(context, 'Contact is already a member');
        }
      }
    } catch (e) {
      if (mounted) {
        // Show manual entry dialog if contacts fail
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cannot Access Contacts'),
            content: Text('Error: $e\n\nWould you like to add the member manually instead?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addMemberManually();
                },
                child: const Text('Add Manually'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _removeMember(String userId) async {
    final user = ref.read(usersProvider.notifier).getUser(userId);
    if (user == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove Member',
      message: 'Remove ${user.name} from this group?',
    );

    if (confirmed != true || !mounted) return;

    try {
      final groupsNotifier = ref.read(groupsProvider.notifier);
      final updatedMemberIds = widget.group.memberIds.where((id) => id != userId).toList();
      
      final updatedGroup = widget.group.copyWith(
        memberIds: updatedMemberIds,
        updatedAt: DateTime.now(),
      );
      
      await groupsNotifier.updateGroup(updatedGroup);
      
      if (mounted) {
        showSnackBar(context, '${user.name} removed from group');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error removing member: $e', isError: true);
      }
    }
  }

  Future<void> _editMember(User member) async {
    final updatedUser = await showDialog<User>(
      context: context,
      builder: (context) => EditMemberDialog(user: member),
    );

    if (updatedUser == null || !mounted) return;

    try {
      final usersNotifier = ref.read(usersProvider.notifier);
      await usersNotifier.updateUser(updatedUser);
      
      if (mounted) {
        showSnackBar(context, '${updatedUser.name} updated successfully');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error updating member: $e', isError: true);
      }
    }
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const _DeleteGroupDialog(),
    );

    if (confirmed != true || !mounted) return;

    try {
      // Store references before deletion to avoid context issues
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      
      final groupsNotifier = ref.read(groupsProvider.notifier);
      
      // Pop all screens to get back to groups list (pop settings screen and group detail screen)
      navigator.pop(); // Pop settings screen
      navigator.pop(); // Pop group detail screen
      
      // Now delete the group
      await groupsNotifier.deleteGroup(widget.group.id);
      
      // Show success message
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Group deleted successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Since we already popped, we can't show error in original context
      // The error will be logged but not shown to user
      debugPrint('Error deleting group: $e');
    }
  }

  Future<void> _exportGroupData() async {
    try {
      final exportService = ref.read(exportImportServiceProvider);
      
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final success = await exportService.exportGroup(widget.group.id);
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        if (success) {
          showSnackBar(context, 'Group data exported successfully');
        } else {
          showSnackBar(context, 'Export cancelled', isError: false);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        showSnackBar(context, 'Error exporting data: $e', isError: true);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    // Watch the group for updates instead of using widget.group
    final currentGroup = ref.watch(selectedGroupProvider(widget.group.id));
    
    // If group is deleted or not found, show error
    if (currentGroup == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Group Settings'),
        ),
        body: const Center(
          child: Text('Group not found'),
        ),
      );
    }
    
    final users = ref.watch(usersProvider);
    final members = users.where((u) => currentGroup.memberIds.contains(u.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Settings'),
      ),
      body: ListView(
        children: [
          // Currency Section
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Currency',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Group Currency'),
                  subtitle: Text(
                    'Current: ${CurrencyHelper.getCurrency(currentGroup.currency).name}',
                  ),
                  trailing: DropdownButton<String>(
                    value: currentGroup.currency,
                    items: CurrencyHelper.supportedCurrencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency.code,
                        child: Text('${currency.symbol} ${currency.code}'),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null && value != currentGroup.currency) {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Change Currency',
                          message: 'Changing currency will not convert existing amounts. Are you sure?',
                        );

                        if (confirmed == true && mounted) {
                          try {
                            final groupsNotifier = ref.read(groupsProvider.notifier);
                            final updatedGroup = currentGroup.copyWith(
                              currency: value,
                              updatedAt: DateTime.now(),
                            );
                            
                            await groupsNotifier.updateGroup(updatedGroup);
                            
                            if (mounted) {
                              showSnackBar(context, 'Currency updated to $value');
                            }
                          } catch (e) {
                            if (mounted) {
                              showSnackBar(context, 'Error updating currency: $e', isError: true);
                            }
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Members Section
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Members',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addMembers,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (members.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No members yet'),
                    ),
                  )
                else
                  ...members.map((user) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.name[0].toUpperCase()),
                      ),
                      title: Text(user.name),
                      subtitle: user.phoneNumber != null
                          ? Text(user.phoneNumber!)
                          : const Text('No phone number'),
                      trailing: user.isDeviceOwner
                          ? const Chip(
                              label: Text('You'),
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () => _editMember(user),
                                  tooltip: 'Edit member',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.red,
                                  onPressed: () => _removeMember(user.id),
                                  tooltip: 'Remove member',
                                ),
                              ],
                            ),
                    );
                  }).toList(),
              ],
            ),
          ),

          // Group Info Section
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Group Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Group Name'),
                  subtitle: Text(currentGroup.name),
                ),
                if (currentGroup.description != null)
                  ListTile(
                    title: const Text('Description'),
                    subtitle: Text(currentGroup.description!),
                  ),
                ListTile(
                  title: const Text('Created'),
                  subtitle: Text(
                    currentGroup.createdAt.toString().split('.')[0],
                  ),
                ),
              ],
            ),
          ),

          // Data Management Section
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Export',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Export Group Data'),
                  subtitle: const Text('Share this group\'s expenses and members as a file'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _exportGroupData,
                ),
              ],
            ),
          ),

          // Danger Zone Section
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                  title: Text(
                    'Delete Group',
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                  subtitle: const Text(
                    'Permanently delete this group and all its data',
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red.shade700),
                  onTap: _deleteGroup,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
