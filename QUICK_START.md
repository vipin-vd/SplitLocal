# 🚀 Quick Start Guide (Consolidated)

This guide is now consolidated. Prefer:
- `README.md` for the shortest quick start
- `GETTING_STARTED.md` for detailed setup and troubleshooting
- `TASK_COMMANDS.md` for complete task reference

The content below remains for convenience.

## Prerequisites

- **Flutter SDK** installed ([Get Flutter](https://flutter.dev/docs/get-started/install))
- **Task** installed (optional but recommended)

## Setup

### Option 1: With Task ⚡ (Recommended)

```bash
# 1. Install Task (one-time)
brew install go-task/tap/go-task

# 2. Clone & setup
git clone <your-repo-url>
cd SplitLocal
task install

# 3. Run!
task run
```

**That's it!** 🎉

### Option 2: Manual

```bash
# 1. Clone
git clone <your-repo-url>
cd SplitLocal

# 2. Install dependencies
flutter pub get

# 3. Generate code
dart run build_runner build --delete-conflicting-outputs

# 4. Run
flutter run
```

## Common Tasks

```bash
# Development
task run              # Run the app
task watch            # Auto-generate code on file changes
task test             # Run tests

# Code quality
task format           # Format code
task analyze          # Analyze code
task ci               # Run all checks (before commit)

# Building
task build-android    # Build APK
task build-ios        # Build iOS app

# Help
task --list           # Show all available tasks
```

## Next Steps

1. ✅ **Run the app**: `task run`
2. 📖 **Read docs**: Check `GETTING_STARTED.md` for detailed guide
3. 🏗️ **Understand architecture**: Read `ARCHITECTURE.md`
4. 💻 **Start coding**: See `DEVELOPER_GUIDE.md`
5. 📋 **Learn Task**: Read `TASK_COMMANDS.md`

## Troubleshooting

### "Flutter not found"
```bash
# Check Flutter installation
flutter doctor

# If not installed, visit: https://flutter.dev/docs/get-started/install
```

### "Task not found"
```bash
# Install Task
brew install go-task/tap/go-task

# Or visit: https://taskfile.dev/#/installation
```

### Code generation errors
```bash
task clean-generate
```

### Still stuck?
```bash
# Verify everything
task verify

# Or check: GETTING_STARTED.md → Troubleshooting section
```

## File Structure

```
SplitLocal/
├── Taskfile.yml              ← Task definitions (new!)
├── QUICK_START.md            ← You are here
├── GETTING_STARTED.md        ← Detailed setup
├── TASK_COMMANDS.md          ← Task reference
├── README.md                 ← Project overview
├── ARCHITECTURE.md           ← Technical details
├── DEVELOPER_GUIDE.md        ← API reference
├── lib/                      ← Source code
│   ├── main.dart
│   ├── features/
│   ├── services/
│   └── shared/
└── test/                     ← Tests
```

## Development Workflow

```bash
# Terminal 1: Auto-generate code
task watch

# Terminal 2: Run app with hot reload
task run

# Before committing
task ci
```

## Building for Release

```bash
# Android
task build-android          # Generates APK in build/app/outputs/

# iOS (macOS only)
task build-ios

# Both
task build-all
```

## Resources

| Document | Description |
|----------|-------------|
| 📋 [TASK_COMMANDS.md](TASK_COMMANDS.md) | Complete Task reference |
| 🚀 [GETTING_STARTED.md](GETTING_STARTED.md) | Detailed setup guide |
| 📖 [README.md](README.md) | Project overview & features |
| 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md) | Architecture & design |
| 💻 [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) | API & code reference |
| 📊 [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | Complete feature list |

## Tips

### Use Task Shortcuts
```bash
task r    # = task run
task t    # = task test
task g    # = task generate-code
task a    # = task analyze
```

### Install Git Hooks
```bash
task install-hooks    # Auto-format & analyze before commits
```

### See All Commands
```bash
task --list          # List all available tasks
```

---

**Happy coding!** 🎉

Need help? Check the documentation files above or run `task --list` to see all available commands.
