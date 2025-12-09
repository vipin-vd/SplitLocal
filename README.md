# SplitLocal

<!-- Project overview remains here. -->

## Quick Start
See `GETTING_STARTED.md` for full setup and troubleshooting. For the shortest path:

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Documentation
- `GETTING_STARTED.md`: Detailed onboarding and troubleshooting
- `TASK_COMMANDS.md`: Task reference for common workflows
- `DEVELOPER_GUIDE.md`: Development patterns and tips
- `ARCHITECTURE.md`: System design and module overview
- `CONTRIBUTING.md`: How to contribute
- `CODE_OF_CONDUCT.md`: Community guidelines
- `SECURITY.md`: Vulnerability reporting
- `CHANGELOG.md`: Release notes

## Contributing
We welcome contributions! Please read `CONTRIBUTING.md` and open an issue before large changes.

## License
See `LICENSE`.
## 🚀 Getting Started

### Quick Start with Task (Recommended)

[Task](https://taskfile.dev) is a modern task runner that makes development easier.

```bash
# Install Task
brew install go-task/tap/go-task  # macOS
# or visit https://taskfile.dev for other platforms

# Setup project
task install

# Run the app
task run

# See all available tasks
task --list
```

📖 See [TASK_COMMANDS.md](TASK_COMMANDS.md) for complete Task reference.

### Manual Setup

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

📖 See [GETTING_STARTED.md](GETTING_STARTED.md) for detailed instructions.

### Platform-Specific Setup

#### iOS
Add to `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

Add to `Info.plist` for contacts permission:
```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts to add group members</string>
```

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

Min SDK version in `android/app/build.gradle`:
```gradle
minSdkVersion 21
```

## 🧮 Algorithms

### Net Balance Calculation
```
For each transaction:
  If type == expense:
    For each payer: balance += amount_paid
    For each split: balance -= amount_owed
  If type == payment:
    For payer: balance -= amount_paid
    For recipient: balance += amount_received
```

### Simplify Debts (Greedy Algorithm)
```
1. Calculate net balance for all users
2. Separate into debtors (negative) and creditors (positive)
3. Sort both by magnitude (largest first)
4. While both lists not empty:
   a. Match largest debtor with largest creditor
   b. Transfer min(|debtor|, creditor)
   c. Update balances
   d. Remove if settled
```

**Example**:
- Initial: A owes 60, B owes 40, C is owed 70, D is owed 30
- Simplified: A pays C (60), B pays C (10), B pays D (30)
- Result: 3 transfers instead of potentially 4+

## 📱 Usage Guide

### First Launch
1. Enter your name (device owner/admin)
2. Optionally add phone number for WhatsApp

### Create a Group
1. Tap **+** button on Groups screen
2. Enter group name and description
3. Add members from contacts
4. Create group

### Add an Expense
1. Open a group
2. Tap **+ (Add Expense)** button
3. Enter description and amount
4. Select who paid (can be multiple people)
5. Choose split mode (Equal/Unequal/Percent/Shares)
6. Save

### Settle Up
1. Open a group
2. Tap **$ (Settle Up)** button
3. View suggested settlements
4. Select payer and recipient
5. Enter amount
6. Record payment

### Backup & Restore
1. Go to Settings → Backup & Restore
2. **Export**: Tap "Export to Clipboard" → Save JSON somewhere safe
3. **Import**: Paste JSON → Tap "Import & Restore"

### WhatsApp Sharing
1. Open a group
2. Tap share icon
3. Select contact
4. WhatsApp opens with pre-filled message

## 🧪 Testing

Run unit tests:
```bash
flutter test
```

Run specific test:
```bash
flutter test test/services/debt_calculator_service_test.dart
```

## ✅ Acceptance Criteria

- [x] **Offline & Persistent**: Data survives app restart
- [x] **Backup/Restore**: Can export/import full database via JSON
- [x] **Settlement Logic**: Payments reduce debt without affecting total spend
- [x] **WhatsApp Integration**: Share summaries via WhatsApp
- [x] **Multi-Payer Support**: Handle expenses with multiple payers
- [x] **Simplified Debts**: Greedy algorithm minimizes transfers

## 🎨 Design Decisions

### Why Hive?
- Fast, lightweight NoSQL database
- Built for Flutter
- Easy JSON serialization
- No native dependencies

### Why Riverpod?
- Type-safe state management
- Code generation for cleaner syntax
- Better testability
- Automatic dependency injection

### Why Local-Only?
- Privacy: Your data never leaves your device
- Offline: Works without internet
- Simple: No authentication, servers, or sync complexity

## 🔮 Future Enhancements

- [ ] Recurring expenses
- [ ] Categories and tags
- [ ] Charts and analytics
- [ ] Multiple currency support
- [ ] Receipt photo attachments
- [ ] Export to PDF/CSV
- [ ] Dark mode

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💡 Tips & Tricks

### Best Practices
- **Regular Backups**: Export your data weekly
- **Descriptive Names**: Use clear expense descriptions
- **Settle Regularly**: Record payments as they happen
- **Use Simplified View**: Easier settlement with fewer transfers

### Troubleshooting
- **Lost Data**: Import from last backup
- **Incorrect Balances**: Review transaction history
- **WhatsApp Not Opening**: Check phone number format
- **Contacts Not Loading**: Grant contacts permission in settings

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing issues for solutions
- Review the documentation

---

**Built with ❤️ using Flutter**
A expense manager which runs in your local only
# SplitLocal 💰

A **local-only, offline-first expense tracking app** built with Flutter. Track and split expenses with your groups, similar to Splitwise, but with all data stored locally on your device. No login required, no servers, no internet dependency.

## 🎯 Key Features

### Group & Member Management
- **Admin-Managed Ledger**: You are the device owner and admin who records all expenses
- **Contacts Integration**: Add members from your device contacts
- **Multiple Groups**: Create and manage multiple expense groups (trips, roommates, etc.)

### Expense Tracking
- **Multiple Split Modes**:
  - **Equal**: Split evenly among all members
  - **Unequal**: Specify exact amounts for each person
  - **Percent**: Split by percentage
  - **Shares**: Split by ratio (e.g., 1:2:3)
- **Multi-Payer Support**: Handle expenses where multiple people paid
- **Settlement Tracking**: Record payments between members

### Smart Debt Calculation
- **Net Balances**: See who owes whom at a glance
- **Simplified Debts**: Minimize the number of transactions needed to settle up (greedy algorithm)
- **Detailed Insights**: View total group spending, individual contributions, and balances

### Data Portability
- **JSON Export**: Export all data to clipboard
- **JSON Import**: Restore data from backup
- **Uninstall-Safe**: Export before uninstalling, import after reinstalling

### Communication
- **WhatsApp Integration**: Share summaries and reminders via WhatsApp
- **Formatted Messages**: Auto-generated settlement plans and balance summaries

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (with code generation)
- **Local Storage**: Hive (NoSQL database)
- **Code Generation**: json_serializable, riverpod_generator, hive_generator

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Main app widget
├── features/
│   ├── groups/
│   │   ├── models/             # User, Group models
│   │   ├── providers/          # Riverpod providers for groups/users
│   │   └── screens/            # Group UI screens
│   ├── expenses/
│   │   ├── models/             # Transaction, SplitMode, TransactionType
│   │   ├── providers/          # Transaction providers
│   │   └── screens/            # Expense & settlement screens
│   └── settings/
│       └── screens/            # Onboarding, backup/restore
├── services/
│   ├── storage/                # LocalStorageService (Hive)
│   ├── debt_calculator_service.dart   # Net balance & simplify algorithms
│   ├── contacts_service.dart   # Flutter contacts integration
│   └── whatsapp_service.dart   # WhatsApp share intents
└── shared/
    ├── providers/              # Service providers
    ├── theme/                  # App theme
    ├── utils/                  # Formatters, dialogs
    └── widgets/                # Reusable widgets
```

### Data Models

#### User
```dart
{
  id: String,              // UUID
  name: String,
  phoneNumber: String?,    // For WhatsApp
  isDeviceOwner: bool,     // Admin flag
  createdAt: DateTime
}
```

#### Group
```dart
{
  id: String,
  name: String,
  description: String?,
  memberIds: List<String>, // User IDs
  createdBy: String,       // User ID
  createdAt: DateTime
}
```

#### Transaction
```dart
{
  id: String,
  groupId: String,
  type: TransactionType,   // expense | payment
  description: String,
  totalAmount: double,
  payers: Map<String, double>,    // userId -> amount paid
  splits: Map<String, double>,    // userId -> amount owed
  splitMode: SplitMode,
  timestamp: DateTime,
  notes: String?,
  createdBy: String
}
```

## 🚀 Getting Started

### Quick Start with Task (Recommended)

[Task](https://taskfile.dev) is a modern task runner that makes development easier.

```bash
# Install Task
brew install go-task/tap/go-task  # macOS
# or visit https://taskfile.dev for other platforms

# Setup project
task install

# Run the app
task run

# See all available tasks
task --list
```

📖 See [TASK_COMMANDS.md](TASK_COMMANDS.md) for complete Task reference.

### Manual Setup

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

📖 See [GETTING_STARTED.md](GETTING_STARTED.md) for detailed instructions.

### Platform-Specific Setup

#### iOS
Add to `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

Add to `Info.plist` for contacts permission:
```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts to add group members</string>
```

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

Min SDK version in `android/app/build.gradle`:
```gradle
minSdkVersion 21
```

## 🧮 Algorithms

### Net Balance Calculation
```
For each transaction:
  If type == expense:
    For each payer: balance += amount_paid
    For each split: balance -= amount_owed
  If type == payment:
    For payer: balance -= amount_paid
    For recipient: balance += amount_received
```

### Simplify Debts (Greedy Algorithm)
```
1. Calculate net balance for all users
2. Separate into debtors (negative) and creditors (positive)
3. Sort both by magnitude (largest first)
4. While both lists not empty:
   a. Match largest debtor with largest creditor
   b. Transfer min(|debtor|, creditor)
   c. Update balances
   d. Remove if settled
```

**Example**:
- Initial: A owes 60, B owes 40, C is owed 70, D is owed 30
- Simplified: A pays C (60), B pays C (10), B pays D (30)
- Result: 3 transfers instead of potentially 4+

## 📱 Usage Guide

### First Launch
1. Enter your name (device owner/admin)
2. Optionally add phone number for WhatsApp

### Create a Group
1. Tap **+** button on Groups screen
2. Enter group name and description
3. Add members from contacts
4. Create group

### Add an Expense
1. Open a group
2. Tap **+ (Add Expense)** button
3. Enter description and amount
4. Select who paid (can be multiple people)
5. Choose split mode (Equal/Unequal/Percent/Shares)
6. Save

### Settle Up
1. Open a group
2. Tap **$ (Settle Up)** button
3. View suggested settlements
4. Select payer and recipient
5. Enter amount
6. Record payment

### Backup & Restore
1. Go to Settings → Backup & Restore
2. **Export**: Tap "Export to Clipboard" → Save JSON somewhere safe
3. **Import**: Paste JSON → Tap "Import & Restore"

### WhatsApp Sharing
1. Open a group
2. Tap share icon
3. Select contact
4. WhatsApp opens with pre-filled message

## 🧪 Testing

Run unit tests:
```bash
flutter test
```

Run specific test:
```bash
flutter test test/services/debt_calculator_service_test.dart
```

## ✅ Acceptance Criteria

- [x] **Offline & Persistent**: Data survives app restart
- [x] **Backup/Restore**: Can export/import full database via JSON
- [x] **Settlement Logic**: Payments reduce debt without affecting total spend
- [x] **WhatsApp Integration**: Share summaries via WhatsApp
- [x] **Multi-Payer Support**: Handle expenses with multiple payers
- [x] **Simplified Debts**: Greedy algorithm minimizes transfers

## 🎨 Design Decisions

### Why Hive?
- Fast, lightweight NoSQL database
- Built for Flutter
- Easy JSON serialization
- No native dependencies

### Why Riverpod?
- Type-safe state management
- Code generation for cleaner syntax
- Better testability
- Automatic dependency injection

### Why Local-Only?
- Privacy: Your data never leaves your device
- Offline: Works without internet
- Simple: No authentication, servers, or sync complexity

## 🔮 Future Enhancements

- [ ] Recurring expenses
- [ ] Categories and tags
- [ ] Charts and analytics
- [ ] Multiple currency support
- [ ] Receipt photo attachments
- [ ] Export to PDF/CSV
- [ ] Dark mode

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💡 Tips & Tricks

### Best Practices
- **Regular Backups**: Export your data weekly
- **Descriptive Names**: Use clear expense descriptions
- **Settle Regularly**: Record payments as they happen
- **Use Simplified View**: Easier settlement with fewer transfers

### Troubleshooting
- **Lost Data**: Import from last backup
- **Incorrect Balances**: Review transaction history
- **WhatsApp Not Opening**: Check phone number format
- **Contacts Not Loading**: Grant contacts permission in settings

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing issues for solutions
- Review the documentation

---

**Built with ❤️ using Flutter**
A expense manager which runs in your local only
