import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitlocal/features/expenses/models/split_mode.dart';
import 'package:splitlocal/features/expenses/providers/split_method_provider.dart';
import 'package:splitlocal/features/groups/models/user.dart';

// Mock specific dependencies if needed, but here we just need basic setup
void main() {
  group('SplitMethodProvider Logic Tests', () {
    late List<User> members;
    const double totalAmount = 30.0;

    setUp(() {
      members = [
        User(id: '1', name: 'User 1', createdAt: DateTime.now()),
        User(id: '2', name: 'User 2', createdAt: DateTime.now()),
        User(id: '3', name: 'User 3', createdAt: DateTime.now()),
      ];
    });

    test('Unequal Split Logic: Total validation should match inputs', () {
      final initialSplits = {
        '1': 10.0,
        '2': 10.0,
        '3': 10.0,
      };

      final container = ProviderContainer();
      final provider = splitMethodProvider(
        members,
        SplitMode.unequal,
        initialSplits,
        totalAmount,
      );

      // Initial state
      var state = container.read(provider);
      expect(state.splitMode, SplitMode.unequal);

      // Calculate total split
      double totalSplit =
          state.splits.values.fold(0.0, (sum, val) => sum + val);
      expect(totalSplit, 30.0); // Initially matches totalAmount

      // Update one user to 6.0
      container.read(provider.notifier).updateSplit('1', '6.00');
      state = container.read(provider);

      // Total should be 6 + 10 + 10 = 26
      totalSplit = state.splits.values.fold(0.0, (sum, val) => sum + val);
      expect(totalSplit, 26.0);
      expect(state.calculatedAmounts['1'], 6.0);

      // Update second user to 6.0
      container.read(provider.notifier).updateSplit('2', '6.00');
      state = container.read(provider);

      // Total should be 6 + 6 + 10 = 22
      totalSplit = state.splits.values.fold(0.0, (sum, val) => sum + val);
      expect(totalSplit, 22.0);

      // Update third user to 6.0
      container.read(provider.notifier).updateSplit('3', '6.00');
      state = container.read(provider);

      // Total should be 6 + 6 + 6 = 18
      totalSplit = state.splits.values.fold(0.0, (sum, val) => sum + val);
      expect(totalSplit, 18.0);

      // Check for hidden members
      // (Test if there are more keys in splits than in members if we initialized with more)

      // Check remaining
      double remaining = totalAmount - totalSplit;
      expect(remaining, 12.0);
    });

    test('Percentage Split Logic: Validation', () {
      final initialSplits = {
        '1': 30.0,
        '2': 40.0,
        '3': 30.0,
      };

      final container = ProviderContainer();
      final provider = splitMethodProvider(
        members,
        SplitMode.percent,
        initialSplits,
        totalAmount,
      );

      // Update User 1 to 50%
      container.read(provider.notifier).updateSplit('1', '50');
      var state = container.read(provider);

      // 50 + 40 + 30 = 120
      double totalPercent =
          state.splits.values.fold(0.0, (sum, val) => sum + val);
      expect(totalPercent, 120.0);

      // Check calculated amounts
      // User 1: 50% of 30 = 15.0
      expect(state.calculatedAmounts['1'], 15.0);
    });

    test('Shares Split Logic: Validation', () {
      final initialSplits = {
        '1': 1.0,
        '2': 1.0,
        '3': 1.0,
      };

      final container = ProviderContainer();
      final provider = splitMethodProvider(
        members,
        SplitMode.shares,
        initialSplits,
        totalAmount,
      );

      // Update User 1 to 2 shares
      container.read(provider.notifier).updateSplit('1', '2');
      var state = container.read(provider);

      // Total shares = 2+1+1 = 4
      double totalShares =
          state.splits.values.fold(0.0, (sum, val) => sum + val);
      expect(totalShares, 4.0);

      // Check calculated amounts
      // User 1: 2/4 * 30 = 15.0
      expect(state.calculatedAmounts['1'], 15.0);
      // User 2: 1/4 * 30 = 7.5
      expect(state.calculatedAmounts['2'], 7.5);
    });

    test('Ghost Member Logic: Skips members not in the list', () {
      final initialSplits = {
        '1': 10.0,
        '2': 10.0,
        'ghost_user': 999.0, // Should be ignored
      };

      final container = ProviderContainer();
      final provider = splitMethodProvider(
        members,
        SplitMode.unequal,
        initialSplits,
        totalAmount,
      );

      var state = container.read(provider);

      // Total should be 10 + 10 = 20 (ghost ignored)
      double totalSplit =
          state.splits.values.fold(0.0, (sum, val) => sum + val);
      expect(totalSplit, 20.0);

      // Check that ghost key is NOT in splits
      expect(state.splits.containsKey('ghost_user'), false);
    });
  });
}
