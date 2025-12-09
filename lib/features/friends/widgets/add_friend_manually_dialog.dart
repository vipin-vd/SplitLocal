import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:splitlocal/features/groups/models/user.dart';

class AddFriendManuallyDialog extends StatefulWidget {
  const AddFriendManuallyDialog({super.key});

  @override
  State<AddFriendManuallyDialog> createState() =>
      _AddFriendManuallyDialogState();
}

class _AddFriendManuallyDialogState extends State<AddFriendManuallyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      final user = User(
        id: const Uuid().v4(),
        name: name,
        phoneNumber: phone.isEmpty ? null : phone,
        isDeviceOwner: false,
        createdAt: DateTime.now(),
      );

      Navigator.of(context).pop(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Friend Manually'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'Enter friend name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone),
                helperText: 'Required for WhatsApp sharing',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Add Friend'),
        ),
      ],
    );
  }
}
