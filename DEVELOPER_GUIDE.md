# SplitLocal - Developer Quick Reference

## 🚀 Quick Start Commands

```bash
# Install dependencies
flutter pub get

# Generate code (REQUIRED before first run)
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test

# Format code
flutter format .

# Analyze code
flutter analyze
```

## 📁 Project Structure Quick Map

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # Main app widget
├── features/
│   ├── groups/
│   │   ├── models/
│   │   │   ├── user.dart             # User model + JSON + Hive
│   │   │   └── group.dart            # Group model + JSON + Hive
│   │   ├── providers/
│   │   │   ├── users_provider.dart   # User state management
│   │   │   └── groups_provider.dart  # Group state management
│   │   └── screens/
│   │       ├── groups_screen.dart    # Home screen
│   │       ├── create_group_screen.dart
│   │       └── group_detail_screen.dart
│   ├── expenses/
│   │   ├── models/
│   │   │   ├── transaction.dart      # Transaction model
│   │   │   ├── transaction_type.dart # Expense vs Payment
│   │   │   └── split_mode.dart       # Equal/Unequal/Percent/Shares
│   │   ├── providers/
│   │   │   └── transactions_provider.dart
│   │   └── screens/
│   │       ├── add_expense_screen.dart
│   │       └── settle_up_screen.dart
│   └── settings/
│       └── screens/
│           ├── onboarding_screen.dart
│           └── backup_restore_screen.dart
├── services/
│   ├── storage/
│   │   └── local_storage_service.dart    # Hive wrapper
│   ├── debt_calculator_service.dart      # Balance algorithms
│   ├── contacts_service.dart             # Device contacts
│   └── whatsapp_service.dart             # WhatsApp intents
└── shared/
    ├── providers/
    │   └── services_provider.dart        # Service instances
    ├── theme/
    │   └── app_theme.dart                # Colors & theme
    └── utils/
        ├── formatters.dart               # Currency, date formatters
        └── dialogs.dart                  # Reusable dialogs
```

## 🔧 Common Tasks

### Adding a New Model

1. Create model file in `features/*/models/`
```dart
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_model.g.dart';

@HiveType(typeId: 5)  // Use next available ID
@JsonSerializable()
class MyModel {
  @HiveField(0)
  final String id;
  
  MyModel({required this.id});
  
  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}
```

2. Register adapter in `LocalStorageService.initialize()`:
```dart
if (!Hive.isAdapterRegistered(5)) {
  Hive.registerAdapter(MyModelAdapter());
}
```

3. Generate code:
```bash
flutter pub run build_runner build
```

### Adding a New Screen

1. Create in `features/*/screens/`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: Container(),
    );
  }
}
```

2. Navigate to it:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const MyScreen()),
);
```

### Adding a New Provider

1. Create in `features/*/providers/`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
class MyData extends _$MyData {
  @override
  List<String> build() {
    return [];
  }
  
  void addItem(String item) {
    state = [...state, item];
  }
}
```

2. Generate:
```bash
flutter pub run build_runner build
```

3. Use in widget:
```dart
final data = ref.watch(myDataProvider);
```

### Adding a New Service

1. Create in `services/`
```dart
class MyService {
  Future<void> doSomething() async {
    // Implementation
  }
}
```

2. Add provider in `shared/providers/services_provider.dart`:
```dart
@riverpod
MyService myService(MyServiceRef ref) {
  return MyService();
}
```

3. Use:
```dart
final service = ref.read(myServiceProvider);
await service.doSomething();
```

## 💾 Database Operations

### Save Data
```dart
final storage = ref.read(localStorageServiceProvider);
await storage.saveUser(user);
await storage.saveGroup(group);
await storage.saveTransaction(transaction);
```

### Read Data
```dart
final user = storage.getUser(userId);
final groups = storage.getAllGroups();
final transactions = storage.getTransactionsByGroup(groupId);
```

### Delete Data
```dart
await storage.deleteUser(userId);
await storage.deleteGroup(groupId);  // Also deletes transactions
await storage.deleteTransaction(transactionId);
```

### Backup/Restore
```dart
// Export
final json = storage.exportToJson();
final jsonString = jsonEncode(json);
await Clipboard.setData(ClipboardData(text: jsonString));

// Import
final jsonString = await Clipboard.getData(Clipboard.kTextPlain);
final json = jsonDecode(jsonString!.text!);
await storage.importFromJson(json);
```

## 🧮 Using Debt Calculator

```dart
final calculator = ref.read(debtCalculatorServiceProvider);
final transactions = ref.watch(groupTransactionsProvider(groupId));

// Net balances
final balances = calculator.computeNetBalances(transactions);
// Result: {'userId1': 50.0, 'userId2': -50.0}

// Simplified debts
final debts = calculator.simplifyDebts(transactions);
// Result: [DebtDetail(from: 'userId2', to: 'userId1', amount: 50.0)]

// Total spending
final totalSpend = calculator.calculateTotalGroupSpend(transactions);

// User stats
final paid = calculator.getUserTotalPaid(userId, transactions);
final share = calculator.getUserTotalShare(userId, transactions);
```

## 📱 UI Patterns

### Show SnackBar
```dart
import '../../shared/utils/dialogs.dart';

showSnackBar(context, 'Success message');
showSnackBar(context, 'Error message', isError: true);
```

### Show Confirmation Dialog
```dart
final confirmed = await showConfirmDialog(
  context,
  title: 'Delete Group',
  message: 'Are you sure?',
  confirmText: 'Delete',
  cancelText: 'Cancel',
);

if (confirmed == true) {
  // User confirmed
}
```

### Format Currency
```dart
import '../../shared/utils/formatters.dart';

final formatted = CurrencyFormatter.format(123.45);  // "$123.45"
final compact = CurrencyFormatter.formatCompact(1500);  // "$1.5K"
final parsed = CurrencyFormatter.parse('$100.50');  // 100.5
```

### Format Dates
```dart
final relative = DateFormatter.formatRelative(DateTime.now().subtract(Duration(hours: 2)));
// "2h ago"

final date = DateFormatter.formatDate(DateTime.now());
// "Nov 25, 2025"

final dateTime = DateFormatter.formatDateTime(DateTime.now());
// "Nov 25, 2025 • 03:30 PM"
```

## 🎨 Using Theme Colors

```dart
import '../../shared/theme/app_theme.dart';

Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

## 🧪 Writing Tests

### Service Test
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyService', () {
    late MyService service;
    
    setUp(() {
      service = MyService();
    });
    
    test('does something', () {
      final result = service.doSomething();
      expect(result, equals(expected));
    });
  });
}
```

### Widget Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('MyWidget shows text', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MyWidget()),
      ),
    );
    
    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

## 🐛 Debugging

### Check Hive Data
```dart
// In debug console
print(Hive.box('users').values);
print(Hive.box('groups').values);
print(Hive.box('transactions').values);
```

### Provider State
```dart
// Add listener for debugging
ref.listen(myProvider, (previous, next) {
  print('Provider changed: $previous -> $next');
});
```

### Network Calls (WhatsApp)
```dart
// Check URL being launched
print('Launching: $url');
```

## 📝 Code Style

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase` or `SCREAMING_SNAKE_CASE`
- **Private**: `_leadingUnderscore`

### Import Order
```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 4. Local imports
import '../models/user.dart';
import '../../shared/utils/formatters.dart';
```

### Widget Organization
```dart
class MyWidget extends ConsumerWidget {
  // 1. Constructor
  const MyWidget({super.key});
  
  // 2. Build method
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2a. Watch providers
    final data = ref.watch(myProvider);
    
    // 2b. Return widget tree
    return Scaffold(...);
  }
  
  // 3. Helper methods (if needed)
  void _handleTap() {}
}
```

## 🔍 Useful Snippets

### Create Transaction (Expense)
```dart
final transaction = Transaction(
  id: const Uuid().v4(),
  groupId: groupId,
  type: TransactionType.expense,
  description: 'Dinner',
  totalAmount: 90.0,
  payers: {userId1: 90.0},  // Single payer
  splits: {userId1: 30.0, userId2: 30.0, userId3: 30.0},
  splitMode: SplitMode.equal,
  timestamp: DateTime.now(),
  createdBy: deviceOwnerId,
);
```

### Create Transaction (Payment)
```dart
final transaction = Transaction(
  id: const Uuid().v4(),
  groupId: groupId,
  type: TransactionType.payment,
  description: 'Settlement',
  totalAmount: 50.0,
  payers: {payerId: 50.0},
  splits: {recipientId: 50.0},
  splitMode: SplitMode.unequal,
  timestamp: DateTime.now(),
  createdBy: deviceOwnerId,
);
```

### Multi-Payer Expense
```dart
final transaction = Transaction(
  id: const Uuid().v4(),
  groupId: groupId,
  type: TransactionType.expense,
  description: 'Shopping',
  totalAmount: 150.0,
  payers: {
    userId1: 100.0,  // A paid 100
    userId2: 50.0,   // B paid 50
  },
  splits: {
    userId1: 50.0,   // A owes 50
    userId2: 50.0,   // B owes 50
    userId3: 50.0,   // C owes 50
  },
  splitMode: SplitMode.equal,
  timestamp: DateTime.now(),
  createdBy: deviceOwnerId,
);
```

## 🔗 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `riverpod_annotation` | Provider code generation |
| `hive` + `hive_flutter` | Local database |
| `json_annotation` + `json_serializable` | JSON serialization |
| `uuid` | Unique IDs |
| `intl` | Formatting (currency, dates) |
| `flutter_contacts` | Device contacts |
| `url_launcher` | WhatsApp intents |

## 📚 Additional Resources

- **README.md** - Project overview and features
- **ARCHITECTURE.md** - Deep dive into architecture
- **SETUP.md** - Detailed setup instructions
- **LICENSE** - MIT License

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| `*.g.dart` not found | Run `flutter pub run build_runner build` |
| Hive type error | Check typeIds and adapter registration |
| Provider not updating | Use `ref.invalidateSelf()` or check reactivity |
| Contacts not loading | Check permissions in AndroidManifest/Info.plist |
| WhatsApp not opening | Add URL scheme to platform configs |

## 💡 Pro Tips

1. **Use watch mode**: `flutter pub run build_runner watch` during development
2. **Hot reload**: Save files to instantly see changes
3. **DevTools**: Press `v` in terminal to open Flutter DevTools
4. **Const constructors**: Use `const` for better performance
5. **Format on save**: Enable in your IDE settings
6. **Test on real devices**: Simulators may not support all features (contacts, WhatsApp)

---

**Happy coding! 🎉**
