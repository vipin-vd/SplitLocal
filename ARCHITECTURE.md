# SplitLocal Architecture Documentation

## Overview
SplitLocal is an offline-first, local-only expense tracking application built with Flutter. This document outlines the architectural decisions, patterns, and structure of the application.

## Architecture Pattern

### Clean Architecture Principles
The app follows a **feature-first** architecture with clear separation of concerns:

```
Presentation Layer (UI) → Business Logic Layer (Providers/Services) → Data Layer (Hive)
```

### Layer Responsibilities

#### 1. Presentation Layer (`features/*/screens/`)
- **Responsibility**: Display UI and handle user interactions
- **Technology**: Flutter widgets (Stateless/Stateful)
- **State Access**: Via Riverpod providers (read-only)
- **No Direct**: Database access or business logic

#### 2. Business Logic Layer
- **Providers** (`features/*/providers/`): State management and business rules
- **Services** (`services/`): Reusable business logic
- **Technology**: Riverpod, Dart classes
- **Responsibilities**:
  - Data transformation
  - Algorithm execution (debt calculation)
  - Orchestration of services

#### 3. Data Layer
- **Models** (`features/*/models/`): Data structures
- **Storage Service** (`services/storage/`): Database operations
- **Technology**: Hive (NoSQL), JSON serialization
- **Responsibilities**:
  - CRUD operations
  - Data persistence
  - Backup/restore

## State Management

### Riverpod Strategy

We use **Riverpod with code generation** for type-safe, boilerplate-free state management.

#### Provider Types Used

1. **@riverpod (Function Providers)**
   - Services (singleton-like)
   - Computed values
   - Example: `localStorageServiceProvider`

2. **@riverpod class (Notifier Providers)**
   - Mutable state with methods
   - CRUD operations
   - Example: `UsersProvider`, `GroupsProvider`

3. **Family Providers**
   - Parameterized providers
   - Example: `groupTransactionsProvider(groupId)`

#### Provider Organization

```
shared/providers/
  └── services_provider.dart    # Global services

features/*/providers/
  └── *_provider.dart            # Feature-specific state
```

## Data Models

### Entity Design

All models follow this pattern:
```dart
@HiveType(typeId: X)
@JsonSerializable()
class Entity {
  // Fields with @HiveField annotations
  
  // Constructor
  Entity({required ...});
  
  // JSON serialization
  factory Entity.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  
  // copyWith for immutability
  Entity copyWith({...});
}
```

### Type IDs (Hive)
- 0: User
- 1: Group
- 2: TransactionType (enum)
- 3: SplitMode (enum)
- 4: Transaction

### Key Design Decisions

#### Transaction Model
- **Single model for expenses & payments**: Simplifies logic
- **Multi-payer support**: `payers` map allows multiple payers per transaction
- **Flexible splits**: `splits` map supports all split modes

#### User Model
- **isDeviceOwner flag**: Identifies the admin (single source of truth)
- **phoneNumber optional**: Not required but enables WhatsApp

## Services Architecture

### Core Services

#### 1. LocalStorageService
**Purpose**: Abstraction over Hive database operations

**Key Methods**:
- `initialize()`: Open boxes, register adapters
- `save*()`: CRUD operations
- `exportToJson()`: Full database export
- `importFromJson()`: Restore from backup

**Design**:
- Singleton-like (provided via Riverpod)
- All database access goes through this service
- Validates data on import

#### 2. DebtCalculatorService
**Purpose**: Business logic for balance calculations

**Key Methods**:
- `computeNetBalances()`: Calculate net position for each user
- `simplifyDebts()`: Greedy algorithm for minimal transfers
- `getActualDebts()`: Graph-based debt view

**Algorithm Complexity**:
- `computeNetBalances`: O(n×m) where n=transactions, m=members
- `simplifyDebts`: O(m log m) where m=members

#### 3. ContactsService
**Purpose**: Device contacts integration

**Key Methods**:
- `requestPermission()`: Handle runtime permissions
- `pickContact()`: System contact picker
- `searchContacts()`: Query contacts

#### 4. WhatsAppService
**Purpose**: Generate and share via WhatsApp

**Key Methods**:
- `shareBalanceReminder()`: Individual reminder
- `shareGroupSummary()`: Full group overview
- `generateSimplifiedDebtsMessage()`: Settlement plan

**Implementation**:
- Uses `url_launcher` with `wa.me` URLs
- URL-encodes message content
- Validates phone numbers

## Algorithms

### Net Balance Calculation

**Input**: List of transactions
**Output**: Map of userId → balance

**Logic**:
```
For each transaction:
  if transaction.type == expense:
    for each payer:
      balance[userId] += amountPaid
    for each split:
      balance[userId] -= amountOwed
      
  if transaction.type == payment:
    balance[payerId] -= amount
    balance[recipientId] += amount
```

**Result Interpretation**:
- Positive balance → User is owed money
- Negative balance → User owes money
- Zero balance → User is settled up

### Simplify Debts (Greedy Algorithm)

**Input**: Net balances
**Output**: Minimal set of transfers

**Steps**:
1. Separate users into debtors (negative) and creditors (positive)
2. Sort both lists by magnitude (descending)
3. Match largest debtor with largest creditor
4. Transfer `min(|debtor|, creditor)`
5. Update balances
6. Remove settled parties
7. Repeat until all settled

**Complexity**: O(m log m) for sorting, O(m) for matching

**Optimality**: Greedy approach guarantees minimal transfers

**Example**:
```
Input:  A: -60, B: -40, C: +70, D: +30
Output: [A→C: 60, B→C: 10, B→D: 30]
Transfers: 3 (optimal)
```

## Data Flow

### Adding an Expense

```
User Input (UI)
  ↓
Validate Form
  ↓
Create Transaction Model
  ↓
TransactionsProvider.addTransaction()
  ↓
LocalStorageService.saveTransaction()
  ↓
Hive Box.put()
  ↓
Provider Invalidates Self
  ↓
UI Rebuilds with New Data
```

### Backup/Restore Flow

#### Export
```
User Taps Export
  ↓
LocalStorageService.exportToJson()
  ↓
Collect all boxes (users, groups, transactions)
  ↓
Serialize to JSON
  ↓
Clipboard.setData()
```

#### Import
```
User Pastes JSON
  ↓
jsonDecode()
  ↓
Validate Schema
  ↓
LocalStorageService.importFromJson()
  ↓
Clear existing boxes
  ↓
Deserialize each entity
  ↓
Save to Hive
  ↓
Invalidate all providers
```

## UI Structure

### Screen Navigation

```
OnboardingScreen (first launch)
  ↓
GroupsScreen (home)
  ├── CreateGroupScreen
  │   └── ContactPicker
  └── GroupDetailScreen
      ├── AddExpenseScreen
      ├── SettleUpScreen
      └── BackupRestoreScreen
```

### State Updates

All screens are **reactive**:
- Use `ref.watch()` to listen to providers
- Automatically rebuild when data changes
- No manual state synchronization

### Form Handling

Pattern used across all forms:
1. `GlobalKey<FormState>` for validation
2. `TextEditingController` for text inputs
3. `validator` functions for validation
4. `dispose()` to clean up controllers

## Error Handling

### Strategies

1. **Validation**: Prevent invalid data entry
   - Form validators
   - Schema validation on import

2. **Try-Catch**: Handle runtime errors
   - File operations
   - JSON parsing
   - Database operations

3. **User Feedback**:
   - SnackBars for success/error messages
   - Dialogs for confirmations
   - Error messages in forms

### Example
```dart
try {
  await storage.importFromJson(json);
  showSnackBar(context, 'Success!');
} catch (e) {
  showSnackBar(context, 'Failed: $e', isError: true);
}
```

## Performance Considerations

### Optimizations

1. **Lazy Loading**: Hive boxes are lazy-loaded
2. **Provider Scoping**: Feature-specific providers
3. **Computation Caching**: Riverpod auto-caches computed values
4. **Efficient Queries**: Filter at database level when possible

### Scalability

**Current Design Supports**:
- Hundreds of groups
- Thousands of transactions
- Dozens of members per group

**Bottlenecks** (if any):
- Simplify algorithm with 100+ members (rare)
- JSON export/import with 10,000+ transactions (manageable)

### Memory Management

- Hive keeps boxes in memory (efficient for our use case)
- Controllers properly disposed
- Providers auto-cleaned by Riverpod

## Testing Strategy

### Unit Tests
- Models: JSON serialization
- Services: Business logic, algorithms
- Utils: Formatters, helpers

### Widget Tests
- Form validation
- User interactions
- Navigation flows

### Integration Tests
- End-to-end flows
- Database operations
- State synchronization

## Security & Privacy

### Data Security
- All data stored locally (Hive)
- No network transmission
- No cloud sync

### Permissions
- Contacts: READ_CONTACTS (optional)
- No sensitive permissions required

### Privacy Benefits
- No user tracking
- No analytics
- No third-party services

## Extensibility

### Adding Features

1. **New Entity**:
   - Create model in `features/*/models/`
   - Add Hive typeId
   - Register adapter in storage service
   - Create provider

2. **New Screen**:
   - Add to `features/*/screens/`
   - Use existing providers
   - Follow reactive pattern

3. **New Service**:
   - Add to `services/`
   - Create provider in `shared/providers/`
   - Inject via Riverpod

## Code Generation

### Required Generators

```bash
flutter pub run build_runner build
```

**Generates**:
- `*.g.dart`: JSON serialization, Hive adapters, Riverpod
- Must run after modifying:
  - Models with `@JsonSerializable`
  - Models with `@HiveType`
  - Providers with `@riverpod`

### Watch Mode (Development)

```bash
flutter pub run build_runner watch
```

## Build & Release

### Development
```bash
flutter run
```

### Production Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Version Management
Update in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

## Maintenance

### Regular Tasks
- Update dependencies: `flutter pub upgrade`
- Run tests: `flutter test`
- Regenerate code: `flutter pub run build_runner build`
- Check for lints: `flutter analyze`

### Debugging
- Use Flutter DevTools
- Add breakpoints in VS Code
- Check Hive boxes: `Hive.box('users').values`

## Conclusion

This architecture provides:
✅ Clear separation of concerns
✅ Testable business logic
✅ Reactive, efficient UI
✅ Offline-first capability
✅ Easy extensibility
✅ Type safety throughout

The design prioritizes **simplicity**, **maintainability**, and **user privacy**.
