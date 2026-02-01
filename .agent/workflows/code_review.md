---
description: Run a comprehensive code review checklist including analysis, formatting, tests, and best practices checks.
---

Flutter Mobile App – AI Code Review Workflow (Antigravity IDE)

1. Workflow Objective
	•	Catch architecture, performance, state management, and Flutter-specific anti-patterns
	•	Enforce Dart + Flutter best practices
	•	Ensure Android + iOS readiness
	•	Produce actionable PR comments

⸻

2. Step 1: Context Bootstrapping (MANDATORY)

AI Role Prompt

You are a senior Flutter engineer.
Review this code assuming:
- Flutter >= 3.x
- Dart >= 3.x (null safety enforced)
- Production mobile app (Android + iOS)
- Performance, maintainability, and testability matter


⸻

3. Step 2: Project Health Scan

Focus Areas
	•	State management (Bloc, Riverpod, Provider, setState)
	•	Navigation (Navigator 1.0 / 2.0, go_router)
	•	Architecture (MVC, Clean, Feature-first, Layered)

Prompt

Scan the repository and summarize:
1. Architecture pattern
2. State management choice
3. Navigation approach
4. High-risk structural issues
Keep it under 10 bullets.


⸻

4. Step 3: Dart & Flutter Code Quality Review

Checklist
	•	❌ late abuse
	•	❌ Nullable types misused
	•	❌ dynamic where generics should exist
	•	❌ setState misuse
	•	❌ Large build() methods (>100 lines)
	•	❌ Missing const constructors
	•	❌ Unnecessary rebuilds

Prompt

Review Dart & Flutter code for:
- Null-safety violations
- Widget rebuild inefficiencies
- Const correctness
- Immutability issues
Provide file + line references.


⸻

5. Step 4: Performance Review

Focus Areas
	•	Widget rebuilds
	•	ListView.builder vs Column
	•	Expensive work inside build()
	•	Image loading & caching
	•	Async misuse in UI

Prompt

Identify performance issues:
- Rebuild hotspots
- Layout inefficiencies
- Async calls in UI
- Image & list rendering problems
Suggest concrete fixes.


⸻

6. Step 5: Platform Readiness (Android + iOS)

Checks
	•	Android: Gradle config, min SDK, permissions
	•	iOS: Info.plist, ATS, background modes
	•	Plugins: Platform channel usage, permission guards

Prompt

Review Android and iOS platform configuration:
- Permissions
- Build settings
- Plugin usage
- Platform-specific risks


⸻

7. Step 6: Security Review

Must Flag
	•	Secrets in code
	•	Insecure storage
	•	HTTP without TLS
	•	Token handling issues
	•	Logging sensitive data

Prompt

Perform a mobile security review.
Flag any:
- Hardcoded secrets
- Insecure storage
- Network security issues
Be explicit and direct.


⸻

8. Step 7: Test Coverage Review

Checks
	•	Unit vs widget test balance
	•	Business logic testability
	•	Missing edge cases
	•	Golden tests (if UI-heavy)

Prompt

Evaluate test strategy:
- Coverage gaps
- Untestable code
- Suggestions to improve testability


⸻

9. Step 8: Lint & Formatting Enforcement

Expected
	•	analysis_options.yaml present
	•	Strict lints enabled
	•	Consistent formatting

Prompt

Review linting & formatting:
- analysis_options.yaml quality
- Recommended Flutter/Dart lints
- Missing rules


⸻

10. Final Output Format (STRICT)

## Summary
<5 bullets max>

## Must Fix (Blocking)
- [File:Line] Issue → Fix

## Should Fix
- [File:Line] Issue → Fix

## Nice to Have
- Improvement suggestion

## Performance Risks
- Specific hotspots

## Security Risks
- Severity + fix


⸻

11. Assumed Local Commands

flutter analyze
flutter test
dart format .
flutter build apk
flutter build ios --no-codesign


⸻

12. Opinionated Defaults
	•	State management: Riverpod / Bloc
	•	Navigation: go_router
	•	Architecture: Feature-first + Clean
	•	Testing: Logic-heavy unit tests > widget tests

⸻

13. Explicitly Avoided
	•	Generic style comments
	•	“Looks good” feedback
	•	Over-documentation advice
	•	Beginner explanations
Note: Please don't fix the findings, only report them 