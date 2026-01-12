import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/groups/providers/create_group_form_provider.dart';
import 'package:splitlocal/features/groups/screens/select_friends_screen.dart';
import '../models/user.dart';
import '../providers/users_provider.dart';
import '../../../shared/utils/dialogs.dart';
import '../widgets/add_member_manually_dialog.dart';

class CreateGroupScreen extends ConsumerWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = createGroupFormProvider;
    final formState = ref.watch(provider);
    final formNotifier = ref.read(provider.notifier);

    ref.listen(provider.select((value) => value.errorMessage), (prev, next) {
      if (next != null) {
        showSnackBar(context, next, isError: true);
        formNotifier.clearErrorMessage();
      }
    });

    ref.listen(provider.select((s) => s.isSaving), (prev, next) {
      if (prev == true && next == false && formState.errorMessage == null) {
        showSnackBar(context, 'Group created successfully');
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Form(
        key: formState.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _GroupForm(),
            SizedBox(height: 24),
            _MemberList(),
          ],
        ),
      ),
      bottomNavigationBar: const _CreateGroupButton(),
    );
  }
}

class _GroupForm extends ConsumerWidget {
  const _GroupForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(createGroupFormProvider);
    return Column(
      children: [
        TextFormField(
          controller: formState.nameController,
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
          controller: formState.descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'e.g., Summer vacation expenses',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}

class _MemberList extends ConsumerWidget {
  const _MemberList();

  Future<void> _addMembers(BuildContext context, WidgetRef ref) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: const Text('How would you like to add a member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'manual'),
            child: const Text('Enter Manually'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'contacts'),
            child: const Text('From Contacts'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'friends'),
            child: const Text('From Friends'),
          ),
        ],
      ),
    );

    if (choice == null) return;

    final notifier = ref.read(createGroupFormProvider.notifier);

    if (choice == 'manual') {
      if (!context.mounted) return;
      final user = await showDialog<User>(
        context: context,
        builder: (context) => const AddMemberManuallyDialog(),
      );
      if (user != null) {
        await ref.read(usersProvider.notifier).addUser(user);
        notifier.addMember(user);
      }
    } else if (choice == 'contacts') {
      await notifier.addMemberFromContacts();
    } else if (choice == 'friends') {
      if (!context.mounted) return;
      final selectedFriends = await Navigator.push<List<User>>(
        context,
        MaterialPageRoute(
          builder: (context) => const SelectFriendsScreen(),
        ),
      );
      if (selectedFriends != null) {
        for (final friend in selectedFriends) {
          notifier.addMember(friend);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(createGroupFormProvider);
    final formNotifier = ref.read(createGroupFormProvider.notifier);
    final deviceOwner = ref.watch(deviceOwnerProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Members',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton.icon(
              onPressed: () => _addMembers(context, ref),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Member'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (deviceOwner != null)
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('${deviceOwner.name} (You)'),
            subtitle: const Text('Admin'),
          ),
        ...formState.selectedMembers.map((member) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(member.name),
            subtitle: Text(member.phoneNumber ?? 'No phone number'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => formNotifier.removeMember(member),
            ),
          );
        }),
      ],
    );
  }
}

class _CreateGroupButton extends ConsumerWidget {
  const _CreateGroupButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(createGroupFormProvider);
    final formNotifier = ref.read(createGroupFormProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: formState.isSaving ? null : formNotifier.createGroup,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: formState.isSaving
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Group'),
        ),
      ),
    );
  }
}
