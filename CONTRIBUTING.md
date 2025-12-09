# Contributing to SplitLocal

Thanks for your interest in contributing! This guide helps you get set up and explains our workflow and expectations.

## How to Contribute
- **Discuss first:** Open an issue for bugs/features before large changes.
- **Small PRs:** Keep changes focused; prefer separate PRs for unrelated fixes.
- **Tests:** Add/adjust tests for code changes where applicable.

## Project Setup
- **Prereqs:** Flutter (stable), Dart, Xcode/Android SDK as needed.
- **Install deps:** `flutter pub get`
- **Codegen:** `dart run build_runner build --delete-conflicting-outputs`
- **Run app:** `flutter run`
- **Tasks:** See `TASK_COMMANDS.md` for common tasks.

## Branching & Commits
- **Branch format:** `feature/<short-name>` or `fix/<short-name>`.
- **Commit style:** Conventional Commits (e.g., `feat: add group settings screen`).
- **Link issues:** Reference GitHub issue numbers in PRs.

## Pull Requests
- **Checklist:**
  - Code builds locally (all platforms you touched)
  - No new lints; run format (`flutter format .`)
  - Tests updated/added if logic changed
  - Updated docs where relevant
- **Description:** Explain motivation, approach, and any trade-offs.

## Code Style & Linting
- **Dart style:** Follow `analysis_options.yaml`.
- **Naming:** Prefer clear, descriptive names; avoid one-letter vars.
- **Imports:** Organize and avoid unused imports.

## Releases & Changelog
- We follow SemVer. See `CHANGELOG.md`.
- Maintainers handle version bumps and tagging.

## Security
- Please do not file security issues publicly. See `SECURITY.md` for reporting.

## Community
- Be kind and constructive. Read `CODE_OF_CONDUCT.md`.
