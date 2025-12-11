---
trigger: always_on
---

# Performance & Safety Rules

## Build Cost

- Avoid heavy `build()` methods; break complex UIs into smaller, reusable widgets to reduce rebuild cost.
- Prefer `const` constructors where possible to minimize unnecessary widget rebuilds.[

## Lists & Lazy Loading

- Use builder constructors (such as `ListView.builder` and `GridView.builder`) for large or dynamic lists to avoid building all items at once.
- For very long lists, prefer lazily loaded and paginated UIs instead of loading the entire dataset in memory.

## Avoid Expensive Operations

- Do not perform heavy computation on the UI thread; use isolates or background tasks for CPU-intensive work.[web:10]
- Avoid synchronous disk and network operations in the frame build path; use async APIs instead.

## Async & Error Handling

- Use `async`/`await` with `try`-`catch` blocks for all fallible asynchronous operations that can throw.
- Validate null or unexpected values before use to prevent runtime exceptions and UI crashes.
- Propagate domain-friendly error states (not raw exceptions) to the UI layer for display.

## Caching

- Cache API results for repeated reads when the data is relatively stable (for example, configuration, reference data, or user profile).
- Define a clear cache invalidation policy (time-based, event-based, or manual refresh) so stale data is not shown indefinitely.

## Performance Checks

- Aim to keep work per frame within the 16ms budget on 60fps targets; avoid layouts or rebuilds that consistently exceed this budget.
- Use Flutter DevTools (especially the Performance and CPU Profiler tabs) regularly to identify jank, layout thrash, and expensive rebuilds.
- Track and optimize startup time by minimizing heavy work in `main()` and `initState()` of initial screens.[web:10]

## Test Coverage Goals

- Target a minimum of 70% coverage for core logic modules (view models, use cases, repositories).
- Ensure all critical user flows (authentication, payments, data submission, etc.) have automated tests.
- When fixing bugs or adding features in performance‑critical code, add or update tests that lock in the expected behavior.

## Security & Data Protection

- Do not hard‑code API keys, secrets, or credentials in source files; load them from secure storage or environment-specific configuration instead.
- Use HTTPS for all network calls and do not disable certificate validation or TLS checks in any environment.
- Avoid logging sensitive information such as access tokens, passwords, personal identifiers, or full payloads that may contain PII.
- Store sensitive data (tokens, session IDs, private keys) using platform‑secure mechanisms (such as Keychain/Keystore) rather than plain text files or shared preferences.[web:11]
- Validate and sanitize all external inputs (including deep links, query parameters, and webview content) before use to reduce the risk of injection or misuse.

## Safety in Error Handling

- Show user‑friendly error messages that do not leak stack traces, internal IDs, or implementation details.
- Distinguish between user‑recoverable errors (such as network issues) and non‑recoverable ones (such as corrupted state) and handle them differently.
- Always fail closed for security: if in doubt about auth state, permissions, or data integrity, deny access until the state is safely re‑established.
