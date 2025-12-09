import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/add_expense_screen.dart';
import '../../friends/providers/friend_group_provider.dart';
import 'add_expense_target_selector.dart';

/// Unified entry point for adding expenses to groups or friends.
/// Shows a FAB that opens AddExpenseScreen or a target selector.
class AddExpenseEntry extends ConsumerWidget {
  final String? groupId;
  final String? friendId;
  final String? heroTag;

  const AddExpenseEntry({
    super.key,
    this.groupId,
    this.friendId,
    this.heroTag = 'add_expense',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If groupId is provided, navigate directly to AddExpenseScreen
    if (groupId != null) {
      return FloatingActionButton(
        heroTag: heroTag,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddExpenseScreen(groupId: groupId!),
          ),
        ),
        child: const Icon(Icons.add),
      );
    }

    // If friendId is provided, resolve friend group and navigate
    if (friendId != null) {
      final friendGroup = ref.watch(friendGroupProvider(friendId!));
      return friendGroup.when(
        data: (group) => FloatingActionButton(
          heroTag: heroTag,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(groupId: group.id),
            ),
          ),
          child: const Icon(Icons.add),
        ),
        loading: () => FloatingActionButton(
          heroTag: heroTag,
          onPressed: null,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
        error: (_, __) => FloatingActionButton(
          heroTag: heroTag,
          onPressed: null,
          child: const Icon(Icons.error_outline),
        ),
      );
    }

    // Neither groupId nor friendId: open selector
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: false,
        builder: (context) => const AddExpenseTargetSelector(),
      ),
      child: const Icon(Icons.add),
    );
  }
}
