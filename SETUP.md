# Setup Guide for SplitLocal

This guide will walk you through setting up the SplitLocal development environment and building the app.

## Prerequisites

### 1. Install Flutter

**macOS**:
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

**Windows**: Follow [official guide](https://docs.flutter.dev/get-started/install/windows)

**Linux**: Follow [official guide](https://docs.flutter.dev/get-started/install/linux)

### 2. Install IDE

**VS Code** (Recommended):
```bash
# Install Flutter extension
code --install-extension Dart-Code.flutter
```

**Android Studio**: Install Flutter plugin from marketplace

### 3. Setup iOS (macOS only)

```bash
# Install Xcode from App Store
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods
```

### 4. Setup Android

1. Install Android Studio
2. Install Android SDK (via Android Studio)
3. Accept licenses:
   ```bash
   flutter doctor --android-licenses
   ```

## Project Setup

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/SplitLocal.git
cd SplitLocal
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

```bash
# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Or use watch mode during development
flutter pub run build_runner watch --delete-conflicting-outputs
```

This generates:
- `*.g.dart` files for JSON serialization
- Hive type adapters
- Riverpod providers

### 4. Configure Platform-Specific Settings

#### iOS Configuration

Edit `ios/Podfile`:
```ruby
# Uncomment this line
platform :ios, '12.0'
```

Edit `ios/Runner/Info.plist`:
```xml
<dict>
  <!-- Add before closing </dict> -->
  <key>NSContactsUsageDescription</key>
  <string>We need access to your contacts to add group members easily</string>
</dict>
```

#### Android Configuration

Edit `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Change from flutter.minSdkVersion
    }
}
```

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <!-- Add before <application> -->
    <uses-permission android:name="android.permission.READ_CONTACTS"/>
    
    <application>
        <!-- Add inside <application> -->
        <queries>
            <package android:name="com.whatsapp" />
        </queries>
    </application>
</manifest>
```

## Running the App

### Development Mode

```bash
# List available devices
flutter devices

# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload enabled (default)
flutter run
```

### Debug Tips

- **Hot Reload**: Press `r` in terminal or save file in IDE
- **Hot Restart**: Press `R` in terminal
- **DevTools**: Press `v` to open Flutter DevTools

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
# Build for iOS
flutter build ios --release

# Then open in Xcode:
open ios/Runner.xcworkspace

# Archive and upload via Xcode
```

## Code Generation Workflow

### When to Regenerate

Run code generation after:
- Adding/modifying models with `@JsonSerializable`
- Adding/modifying models with `@HiveType`
- Adding/modifying providers with `@riverpod`

### Commands

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild (if conflicts)
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test

```bash
flutter test test/services/debt_calculator_service_test.dart
```

### Run with Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Troubleshooting

### Common Issues

#### 1. Code Generation Fails

**Problem**: `*.g.dart` files not generating

**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. Hive Type Conflict

**Problem**: `HiveError: Cannot write, unknown type: User`

**Solution**: 
- Check typeIds are unique (0-223 range)
- Verify adapters registered in `LocalStorageService.initialize()`

#### 3. iOS Build Fails

**Problem**: CocoaPods errors

**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

#### 4. Android Build Fails

**Problem**: Gradle sync issues

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 5. Contacts Permission Not Working

**Problem**: Can't access contacts

**Solution**:
- iOS: Check `Info.plist` has `NSContactsUsageDescription`
- Android: Check `AndroidManifest.xml` has `READ_CONTACTS` permission
- Test on real device (simulator may have restrictions)

#### 6. WhatsApp Not Opening

**Problem**: URL launcher fails

**Solution**:
- iOS: Add URL scheme to `Info.plist`:
  ```xml
  <key>LSApplicationQueriesSchemes</key>
  <array>
    <string>whatsapp</string>
  </array>
  ```
- Android: Add to `AndroidManifest.xml` (see above)

## Development Workflow

### 1. Start Development Server

```bash
# Terminal 1: Watch mode for code generation
flutter pub run build_runner watch

# Terminal 2: Run app with hot reload
flutter run
```

### 2. Make Changes

- Edit Dart files
- Save to trigger hot reload
- Changes appear instantly (usually)

### 3. Full Restart When Needed

Press `R` in terminal after:
- Changing native code
- Modifying `pubspec.yaml`
- Adding assets
- Changing app structure significantly

### 4. Testing Workflow

```bash
# Run tests on file save
flutter test --watch

# Or run manually
flutter test
```

## IDE Setup

### VS Code

Install extensions:
```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

Recommended settings (`.vscode/settings.json`):
```json
{
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "dart.debugExternalPackageLibraries": true,
  "dart.debugSdkLibraries": false
}
```

### Android Studio

1. Install Flutter plugin
2. Install Dart plugin
3. Enable auto-save
4. Configure Dart format on save

## Version Control

### .gitignore

Already configured to exclude:
- `*.g.dart` (generated)
- `*.hive` (database files)
- Build outputs
- IDE files

### Before Committing

```bash
flutter analyze
flutter test
flutter format .
```

## Continuous Integration

### GitHub Actions (Example)

Create `.github/workflows/flutter.yml`:
```yaml
name: Flutter CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter pub run build_runner build
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk
```

## Performance Tips

### 1. Development

- Use `--profile` mode for performance testing:
  ```bash
  flutter run --profile
  ```

### 2. Release Builds

- Always test release builds before publishing:
  ```bash
  flutter run --release
  ```

### 3. App Size

- Check app size:
  ```bash
  flutter build apk --analyze-size
  ```

## Next Steps

1. ✅ Setup complete? Run the app!
2. 📖 Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand the codebase
3. 🧪 Explore the test files
4. 🎨 Customize the theme in `lib/shared/theme/`
5. 🚀 Build your first feature!

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)

## Support

Having issues? Check:
1. Run `flutter doctor` and fix any issues
2. Search existing GitHub issues
3. Create new issue with:
   - Flutter version (`flutter --version`)
   - Error message
   - Steps to reproduce

Happy coding! 🎉
