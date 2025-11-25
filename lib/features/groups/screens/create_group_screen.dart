import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../providers/groups_provider.dart';
import '../providers/users_provider.dart';
import '../../../shared/providers/services_provider.dart';
import '../../../shared/utils/dialogs.dart';
import '../widgets/add_member_manually_dialog.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<User> _selectedMembers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
      // Check if user with same phone exists
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        final existingUsers = ref.read(usersProvider);
        final existing = existingUsers.where((u) => u.phoneNumber == user.phoneNumber).firstOrNull;
        
        if (existing != null) {
          // Check if already in selected members
          if (!_selectedMembers.any((m) => m.id == existing.id)) {
            setState(() {
              _selectedMembers.add(existing);
            });
            if (mounted) {
              showSnackBar(context, 'Existing member ${existing.name} added');
            }
          } else {
            if (mounted) {
              showSnackBar(context, '${existing.name} is already added');
            }
          }
          return;
        }
      }

      // Add new user
      await ref.read(usersProvider.notifier).addUser(user);
      
      setState(() {
        _selectedMembers.add(user);
      });
      
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
      final contactData = await contactsService.pickContact();
      if (contactData == null || !mounted) return;

      final name = contactData['name'] ?? 'Unknown';
      final phoneNumber = contactData['phoneNumber'];

      // Check if user already exists by phone number
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final existingUsers = ref.read(usersProvider);
        final existing = existingUsers.where((u) => u.phoneNumber == phoneNumber).firstOrNull;
        
        if (existing != null) {
          if (!_selectedMembers.any((m) => m.id == existing.id)) {
            setState(() {
              _selectedMembers.add(existing);
            });
            if (mounted) {
              showSnackBar(context, '${existing.name} added from contacts');
            }
          } else {
            if (mounted) {
              showSnackBar(context, '${existing.name} is already added');
            }
          }
          return;
        }
      }

      // Create new user
      final newUser = User(
        id: const Uuid().v4(),
        name: name,
        phoneNumber: phoneNumber,
        isDeviceOwner: false,
        createdAt: DateTime.now(),
      );

      // Save user and add to selected members
      await ref.read(usersProvider.notifier).addUser(newUser);
      
      setState(() {
        _selectedMembers.add(newUser);
      });
      
      if (mounted) {
        showSnackBar(context, '${newUser.name} added successfully');
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

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final deviceOwner = ref.read(deviceOwnerProvider);
    if (deviceOwner == null) {
      if (mounted) {
        showSnackBar(context, 'Device owner not found', isError: true);
      }
      return;
    }

    // Include device owner in members
    final memberIds = [
      deviceOwner.id,
      ..._selectedMembers.map((m) => m.id),
    ];

    final group = Group(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      memberIds: memberIds,
      createdBy: deviceOwner.id,
      createdAt: DateTime.now(),
    );

    await ref.read(groupsProvider.notifier).addGroup(group);

    if (mounted) {
      showSnackBar(context, 'Group created successfully');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceOwner = ref.watch(deviceOwnerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g., Trip to Paris',
                prefixIcon: Icon(Icons.group),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a group name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., Summer vacation expenses',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                ElevatedButton.icon(
                  onPressed: _addMembers,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Member'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (deviceOwner != null)
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('${deviceOwner.name} (You)'),
                subtitle: const Text('Admin'),
                tileColor: Colors.grey[100],
              ),
            ..._selectedMembers.map((member) {
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                title: Text(member.name),
                subtitle: Text(member.phoneNumber ?? 'No phone'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() {
                      _selectedMembers.remove(member);
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _createGroup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Create Group'),
          ),
        ),
      ),
    );
  }
}
