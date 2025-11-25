# Task Commands Reference

This project uses [Task](https://taskfile.dev) - a modern task runner / build tool as an alternative to Makefile.

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

## Quick Reference

### Essential Commands

```bash
task                    # Show all available tasks
task install           # Complete project setup (first time)
task run               # Run the app
task test              # Run all tests
task generate-code     # Generate code (models, providers)
task analyze           # Analyze code for issues
```

### Shortcuts

```bash
task r    # Quick run
task t    # Quick test
task g    # Quick generate
task a    # Quick analyze
```

## All Available Tasks

### Setup & Installation

| Command | Description |
|---------|-------------|
| `task install` | Install all dependencies and setup project |
| `task check-flutter` | Verify Flutter/Dart installation |
| `task get-dependencies` | Get Flutter dependencies |
| `task verify` | Verify complete project setup |

### Code Generation

| Command | Description |
|---------|-------------|
| `task generate-code` | Run all code generators once |
| `task g` | Shortcut for generate-code |
| `task watch` | Watch for changes and auto-generate |

### Running the App

| Command | Description |
|---------|-------------|
| `task run` | Run in debug mode |
| `task r` | Shortcut for run |
| `task run-release` | Run in release mode |
| `task run-profile` | Run in profile mode |
| `task ios` | Run on iOS device/simulator |
| `task android` | Run on Android device/emulator |
| `task devices` | List all connected devices |

### Testing

| Command | Description |
|---------|-------------|
| `task test` | Run all tests |
| `task t` | Shortcut for test |
| `task test-coverage` | Run tests with coverage report |
| `task benchmark` | Run benchmark tests |

### Code Quality

| Command | Description |
|---------|-------------|
| `task analyze` | Analyze code for issues |
| `task a` | Shortcut for analyze |
| `task format` | Format all Dart code |
| `task format-check` | Check if code is formatted |
| `task lint` | Run all quality checks |
| `task ci` | Run all CI checks |

### Building

| Command | Description |
|---------|-------------|
| `task build-android` | Build Android APK |
| `task build-android-bundle` | Build Android App Bundle |
| `task build-ios` | Build iOS app (macOS only) |
| `task build-all` | Build for all platforms |

### Cleaning

| Command | Description |
|---------|-------------|
| `task clean` | Clean build artifacts |
| `task clean-generate` | Clean and regenerate all code |
| `task clean-ios` | Clean iOS build (macOS only) |
| `task clean-android` | Clean Android build |

### Utilities

| Command | Description |
|---------|-------------|
| `task doctor` | Run Flutter doctor |
| `task upgrade` | Upgrade Flutter and dependencies |
| `task outdated` | Check for outdated packages |
| `task docs` | Generate documentation |
| `task count-lines` | Count lines of code |
| `task tree` | Show project structure |

### Git & Version Control

| Command | Description |
|---------|-------------|
| `task install-hooks` | Install Git pre-commit hooks |
| `task version-patch` | Bump patch version (x.x.X) |
| `task version-minor` | Bump minor version (x.X.0) |
| `task version-major` | Bump major version (X.0.0) |

### Database

| Command | Description |
|---------|-------------|
| `task reset-db` | Reset local database (with prompt) |

### Development Helpers

| Command | Description |
|---------|-------------|
| `task create-model -- ModelName` | Create new model with boilerplate |
| `task profile` | Run performance profiling |

## Common Workflows

### First Time Setup

```bash
# Install Task (if not already installed)
brew install go-task/tap/go-task

# Setup the project
task install

# Run the app
task run
```

### Daily Development

```bash
# Terminal 1: Watch for code changes
task watch

# Terminal 2: Run the app with hot reload
task run
```

### Before Committing

```bash
# Run all checks
task ci

# Or run individually
task format
task analyze
task test
```

### Adding a New Feature

```bash
# Create model (optional helper)
task create-model -- Payment

# Generate code
task generate-code

# Run tests
task test

# Format and analyze
task format
task analyze
```

### Building for Release

```bash
# Android APK
task build-android

# Android App Bundle (Play Store)
task build-android-bundle

# iOS (macOS only)
task build-ios

# All platforms
task build-all
```

### Troubleshooting

```bash
# Clean everything and start fresh
task clean-generate

# Check Flutter setup
task doctor

# Verify project is correctly setup
task verify

# Check for outdated packages
task outdated
```

## Task Features

### Smart Caching
Task automatically tracks file changes and skips tasks if nothing changed:

```yaml
sources:
  - lib/**/*.dart
generates:
  - lib/**/*.g.dart
```

### Preconditions
Tasks verify requirements before running:

```yaml
preconditions:
  - sh: command -v flutter
    msg: "Flutter is not installed"
```

### User Prompts
Dangerous operations require confirmation:

```yaml
prompt: This will delete all local data. Continue?
```

### Parallel Execution
Run multiple tasks simultaneously:

```bash
task clean & task get-dependencies
```

## Customization

### Adding Your Own Tasks

Edit `Taskfile.yml`:

```yaml
tasks:
  my-task:
    desc: My custom task
    cmds:
      - echo "Hello from my task"
      - flutter test integration_test/
```

Run with:
```bash
task my-task
```

### Task with Arguments

```yaml
tasks:
  greet:
    cmds:
      - echo "Hello {{.CLI_ARGS}}"
```

Run with:
```bash
task greet -- World
# Output: Hello World
```

## Comparison: Task vs Manual Commands

| Task Command | Equivalent Flutter Commands |
|--------------|----------------------------|
| `task install` | `flutter pub get && dart run build_runner build --delete-conflicting-outputs` |
| `task generate-code` | `dart run build_runner build --delete-conflicting-outputs` |
| `task watch` | `dart run build_runner watch --delete-conflicting-outputs` |
| `task test-coverage` | `flutter test --coverage && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html` |
| `task ci` | `dart format --set-exit-if-changed . && flutter analyze && flutter test` |

## Why Task?

### Benefits

1. **Simplicity**: Easy to read YAML syntax
2. **Cross-platform**: Works on macOS, Linux, Windows
3. **Smart**: Caching, dependencies, preconditions
4. **Fast**: Parallel execution, incremental builds
5. **Self-documenting**: `task --list` shows all commands
6. **No dependencies**: Single binary, no runtime needed

### vs Makefile

- ✅ Better syntax (YAML vs Makefile tabs)
- ✅ Cross-platform (no need for make on Windows)
- ✅ Better error messages
- ✅ Built-in file watching
- ✅ Modern features (caching, prompts, etc.)

### vs Shell Scripts

- ✅ Structured task definitions
- ✅ Better reusability
- ✅ Automatic dependency management
- ✅ Self-documenting
- ✅ Easier to maintain

## Tips & Best Practices

### 1. Use `task --list` Frequently
Always check available tasks:
```bash
task --list
```

### 2. Combine Tasks
Chain multiple tasks:
```bash
task format analyze test
```

### 3. Use Shortcuts
Save time with aliases:
```bash
task r     # instead of: task run
task g     # instead of: task generate-code
```

### 4. Watch Mode for Development
Keep generation running:
```bash
task watch
```

### 5. CI/CD Integration
In your CI pipeline:
```bash
task ci
```

### 6. Install Git Hooks
Automate quality checks:
```bash
task install-hooks
```

## Troubleshooting

### Task not found
```bash
# Check installation
task --version

# Reinstall
brew reinstall go-task
```

### Task file not found
```bash
# Make sure you're in project root
cd /path/to/SplitLocal

# Verify Taskfile.yml exists
ls -la Taskfile.yml
```

### Permission denied
```bash
# Make sure Taskfile.yml is readable
chmod 644 Taskfile.yml
```

### Task hangs
```bash
# Cancel with Ctrl+C
# Check for infinite loops in task dependencies
```

## Additional Resources

- **Official Documentation**: https://taskfile.dev
- **GitHub Repository**: https://github.com/go-task/task
- **Example Taskfiles**: https://github.com/go-task/task/tree/main/docs/docs/usage_examples

---

**Pro Tip**: Add `alias t=task` to your shell profile for even quicker access! 🚀
