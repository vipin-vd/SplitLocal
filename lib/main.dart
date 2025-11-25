import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'features/groups/models/user.dart';
import 'features/groups/models/group.dart';
import 'features/expenses/models/transaction.dart';
import 'features/expenses/models/transaction_type.dart';
import 'features/expenses/models/split_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters with unique type IDs
  Hive.registerAdapter(UserAdapter());              // typeId: 0
  Hive.registerAdapter(GroupAdapter());             // typeId: 1
  Hive.registerAdapter(TransactionTypeAdapter());   // typeId: 2
  Hive.registerAdapter(SplitModeAdapter());         // typeId: 3
  Hive.registerAdapter(TransactionAdapter());       // typeId: 4
  
  // Open boxes
  await Hive.openBox<User>('users');
  await Hive.openBox<Group>('groups');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox('settings');  // Non-typed box for settings
  
  runApp(
    const ProviderScope(
      child: SplitLocalApp(),
    ),
  );
}
