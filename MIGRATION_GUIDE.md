# Migration Guide: setup.sh → Taskfile.yml

This project now uses **Task** instead of shell scripts for better cross-platform support and developer experience.

## What Changed?

### Before (setup.sh)
```bash
chmod +x setup.sh
./setup.sh
```

### Now (Taskfile.yml)
```bash
# Install Task once
brew install go-task/tap/go-task

# Run setup
task install
```

## Why Task?

✅ **Cross-platform**: Works on macOS, Linux, Windows  
✅ **Self-documenting**: `task --list` shows all commands  
✅ **Smart caching**: Skips unnecessary work  
✅ **Better errors**: Clear error messages  
✅ **Modern**: YAML syntax, no shell quirks  

## Command Mapping

All `setup.sh` functionality is available in Task:

| Old (setup.sh) | New (Task) | Description |
|---------------|------------|-------------|
| `./setup.sh` | `task install` | Complete setup |
| N/A | `task run` | Run the app |
| N/A | `task test` | Run tests |
| N/A | `task generate-code` | Generate code |
| N/A | `task analyze` | Analyze code |
| N/A | `task build-android` | Build APK |
| N/A | `task clean` | Clean build |

## Installation

### macOS
```bash
brew install go-task/tap/go-task
```

### Linux
```bash
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
```

### Windows
```powershell
choco install go-task
```

Or download from: https://github.com/go-task/task/releases

## Quick Start

```bash
# Complete setup (replaces ./setup.sh)
task install

# Run the app
task run

# See all available commands
task --list
```

## Feature Comparison

### setup.sh provided:
- Initial dependency installation
- Code generation
- Basic verification

### Taskfile.yml provides:
- ✅ Everything setup.sh did
- ✅ **Plus** 40+ additional commands
- ✅ Code generation with watch mode
- ✅ Testing with coverage
- ✅ Building for all platforms
- ✅ Code quality checks
- ✅ Git hooks
- ✅ Database management
- ✅ Version bumping
- ✅ And much more!

## Common Workflows

### First Time Setup
```bash
# Old way
chmod +x setup.sh
./setup.sh
flutter run

# New way
task install
task run
```

### Development
```bash
# Old way
# (Manual commands)
flutter pub get
dart run build_runner watch
flutter run

# New way
task watch    # Terminal 1
task run      # Terminal 2
```

### Before Committing
```bash
# Old way
flutter format .
flutter analyze
flutter test

# New way
task ci       # Runs all checks
```

### Building
```bash
# Old way
flutter build apk --release

# New way
task build-android
```

## Benefits Over Shell Scripts

### 1. No More Platform Issues
```bash
# setup.sh might fail on Windows/Linux
./setup.sh

# Task works everywhere
task install
```

### 2. Self-Documenting
```bash
# What does setup.sh do? Have to read the file
cat setup.sh

# Task shows all available commands
task --list
```

### 3. Smart Execution
```yaml
# Task only runs if files changed
sources:
  - lib/**/*.dart
generates:
  - lib/**/*.g.dart
```

### 4. Better Error Handling
```yaml
# Task verifies prerequisites
preconditions:
  - sh: command -v flutter
    msg: "Flutter is not installed"
```

### 5. Reusable Tasks
```bash
# Can call other tasks
task ci
# Internally runs: format, analyze, test
```

## Advanced Features

### Task with Arguments
```bash
task create-model -- Payment
```

### Parallel Execution
```bash
task format analyze test
```

### Watch Mode
```bash
task watch    # Auto-regenerate on file changes
```

### Git Hooks
```bash
task install-hooks    # Auto-format before commits
```

## Still Prefer Manual Commands?

No problem! Taskfile doesn't replace Flutter commands, it wraps them.

You can still use:
```bash
flutter pub get
flutter run
dart run build_runner build --delete-conflicting-outputs
```

But Task makes it easier:
```bash
task install
task run
task g
```

## Learning Task

### Basic Usage
```bash
task              # Same as: task --list
task run          # Run a task
task r            # Use shortcuts
```

### Documentation
```bash
task --list       # List all tasks
task --summary    # Show task descriptions
```

### Files
- `Taskfile.yml` - Task definitions (like Makefile)
- Official docs: https://taskfile.dev

## Troubleshooting

### "task: command not found"
```bash
# Install Task
brew install go-task/tap/go-task

# Verify installation
task --version
```

### "Taskfile.yml not found"
```bash
# Make sure you're in project root
cd /path/to/SplitLocal

# Verify file exists
ls -la Taskfile.yml
```

### "Want to use setup.sh anyway"
The setup.sh script has been removed in favor of Task, but you can create a simple alternative:

```bash
#!/bin/bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

However, we **strongly recommend** using Task for better developer experience.

## Getting Help

### Task-specific help
```bash
task --help
task --list
```

### Project-specific help
- Read: [TASK_COMMANDS.md](TASK_COMMANDS.md)
- Read: [GETTING_STARTED.md](GETTING_STARTED.md)

### Still stuck?
```bash
task verify    # Check project setup
task doctor    # Run Flutter doctor
```

## Summary

| Aspect | setup.sh | Taskfile.yml |
|--------|----------|--------------|
| Setup | `./setup.sh` | `task install` |
| Cross-platform | ❌ Shell-dependent | ✅ Works everywhere |
| Self-documenting | ❌ Manual | ✅ `task --list` |
| Features | ~3 commands | 40+ commands |
| Caching | ❌ No | ✅ Smart caching |
| Error handling | ⚠️ Basic | ✅ Preconditions |
| Maintenance | ⚠️ Shell scripting | ✅ Clean YAML |
| Learning curve | Low | Low |

## Next Steps

1. ✅ **Install Task**: `brew install go-task/tap/go-task`
2. 📖 **Read Task docs**: [TASK_COMMANDS.md](TASK_COMMANDS.md)
3. 🚀 **Start using**: `task install && task run`
4. 💡 **Explore**: `task --list`

---

**Welcome to modern task running!** 🎉

Questions? Check [TASK_COMMANDS.md](TASK_COMMANDS.md) or visit https://taskfile.dev
