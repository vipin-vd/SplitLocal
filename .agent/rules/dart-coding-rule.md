---
trigger: always_on
---

# Core Lint & Style Rules for Flutter + Dart

## Include Official Lints
- Use `flutter_lints` as the baseline for all lint checks:
```yaml
include: package:flutter_lints/flutter.yaml
```
## Naming conventions

- **Classes & Enums:** `PascalCase`
- **Variables & Functions:** `lowerCamelCase`
- **Constants & File Names:** `snake_case`
- **Directory Names:** `kebab-case`
- Avoid ambiguous abbreviations.

## File and class organization

- One public class per file.
- File name must match the main class name.

## Formatting

- Always run `dart format` on commit and pre-push.
- Use trailing commas to improve auto-formatted readability.

## Deprecated API avoidance

- Fix all compile warnings.
- Do not use deprecated APIs; prefer current Flutter SDK equivalents.

## Dependency versioning

- Pin dependency versions in `pubspec.yaml` to avoid unpredictable breaking updates.

## Logging

- Use structured logging (for example, `log()`), not `print()`.

## Code review rules

- All PRs must pass `flutter analyze` and `flutter test` before merge.