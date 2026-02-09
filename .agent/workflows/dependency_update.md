---
description: Update project dependencies safely, handling conflicts and discontinued packages.
---

# Dependency Update Workflow

This workflow guides you through updating Flutter project dependencies, handling common issues like conflicts and discontinued packages.

## 1. Check for Outdated Packages

Run the following command to see which packages have newer versions:

```bash
flutter pub outdated
```

## 2. Upgrade Dependencies

### SAFE Upgrade (Recommended)

Upgrades to the latest compatible versions within your `pubspec.yaml` constraints:

```bash
flutter pub upgrade
```

### MAJOR Upgrade (Use with Caution)

Upgrades to the latest resolvable versions, ignoring current constraints. This modifies `pubspec.yaml`:

```bash
flutter pub upgrade --major-versions
```

**Warning:** This often introduces breaking changes. Always review the changelogs of major version bumps.

## 3. Handle Conflicts & Discontinued Packages

If you encounter conflicts (e.g., with `hive_generator` or `build_runner`):

1.  **Clean Cache**:
    ```bash
    flutter clean
    rm pubspec.lock
    ```
2.  **Refresh Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Resolve Specific Conflicts**:
    - **hive_generator**: Stick to version `2.0.1` and ensure `json_serializable` and `riverpod_generator` versions are compatible (often older versions).
    - **build_runner**: If you see "discontinued" warnings for `build_resolvers`, ignore them if `build_runner` itself is up to date, as functionality was merged.

## 4. Regenerate Code

After any dependency change involving code generation (Riverpod, Hive, JSON), you **MUST** regenerate the code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 5. Verify

1.  **Analyze**: `flutter analyze`
2.  **Test**: `flutter test`
3.  **Run**: `flutter run` prevents runtime crashes.
