# Getting Started - Quick Commands

## Option 1: Using Task (Recommended) ⚡

### Install Task

```bash
# macOS
brew install go-task/tap/go-task

# Linux
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin

# Windows
choco install go-task
```

### First Time Setup

```bash
# Complete setup in one command
task install

# Or see all available tasks
task --list
```

### Run the App

```bash
task run    # or: task r
```

See **[TASK_COMMANDS.md](TASK_COMMANDS.md)** for complete Task reference.

---

## Option 2: Manual Setup

### First Time Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (IMPORTANT!)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

## Daily Development

### Using Task

```bash
# Terminal 1: Watch for changes
task watch

# Terminal 2: Run app with hot reload
task run
```

### Manual Commands

```bash
# Start code generation in watch mode (Terminal 1)
flutter pub run build_runner watch --delete-conflicting-outputs

# Run app with hot reload (Terminal 2)
flutter run
```

## Testing

### Using Task

```bash
task test              # Run all tests
task test-coverage     # Run with coverage report
task t                 # Quick shortcut
```

### Manual Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/debt_calculator_service_test.dart

# Run with coverage
flutter test --coverage
```

## Code Quality

### Using Task

```bash
task format    # Format code
task analyze   # Analyze code
task lint      # Format + Analyze + Test
task ci        # Run all CI checks
```

### Manual Commands

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Check for issues
flutter doctor
```

## Building for Production

### Using Task

```bash
task build-android          # APK
task build-android-bundle   # App Bundle
task build-ios              # iOS
task build-all              # All platforms
```

### Manual Commands

#### Android
```bash
# APK
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Using Task

```bash
task clean-generate   # Clean and regenerate everything
task verify          # Verify project setup
task doctor          # Run Flutter doctor
task outdated        # Check for updates
```

### Manual Commands

#### Code generation issues
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Platform issues

#### Using Task

```bash
# iOS
task clean-ios

# Android
task clean-android

# Complete clean
task clean
task install
```

#### Manual Commands

**iOS**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

**Android**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

## File Structure Reference

```
lib/
├── main.dart                          # Start here
├── features/
│   ├── groups/screens/                # Group UI
│   ├── expenses/screens/              # Expense UI
│   └── settings/screens/              # Settings UI
├── services/
│   ├── debt_calculator_service.dart   # Core algorithms
│   └── storage/                       # Database
└── shared/
    ├── theme/                         # Colors & styles
    └── utils/                         # Helpers
```

## Documentation

- **TASK_COMMANDS.md** - Complete Task reference (recommended)
- **README.md** - Start here for overview
- **SETUP.md** - Detailed setup instructions
- **ARCHITECTURE.md** - How everything works
- **DEVELOPER_GUIDE.md** - Quick reference
- **PROJECT_SUMMARY.md** - Complete feature list

## Quick Tips

### Task Shortcuts

```bash
task r    # Run app
task t    # Run tests
task g    # Generate code
task a    # Analyze
```

### Common Workflows

```bash
# Before committing
task ci

# Add new feature
task g && task t

# Fresh start
task clean-generate
```

## Support

- Check existing issues in the documentation
- Run `flutter doctor` to diagnose environment issues
- See SETUP.md troubleshooting section

---

**Ready to code?** Run the setup commands above and you're good to go! 🚀
