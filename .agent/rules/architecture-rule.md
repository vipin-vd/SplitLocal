---
trigger: always_on
---

# Architecture & Project Structure Rules

## Layers & Separation of Concerns
- UI layer must not contain business logic.
- Logic belongs in ViewModel / Controller classes.
- Domain and data logic must not depend directly on UI widgets.
- Cross-cutting concerns (logging, analytics, error reporting) must be handled via dedicated services or middleware.

## App Structure
Use a feature-based structure:
lib/
├── features/
│ ├── <feature_name>/
│ │ ├── presentation/ # Widgets, pages, view models/controllers
│ │ ├── domain/ # Use cases, entities, interfaces
│ │ └── data/ # Repositories, data sources, DTOs
├── common_widgets/ # Shared, reusable UI components
├── services/ # Cross-cutting services (analytics, logging, config, etc.)
├── models/ # Shared models (only if truly cross-feature)
├── utils/ # Pure utility code with no app-specific dependencies
└── main.dart


- Avoid “god” folders like `helpers/` or `misc/`; every file should have a clear home.
- Prefer feature-specific code living under its feature folder rather than shared/global modules by default.

## State Management

- Choose one primary state management approach (Provider, Riverpod, Bloc, etc.) for the project or module.
- Avoid mixing multiple state management paradigms within the same feature/module.
- State must be owned at the appropriate scope (screen, flow, or app-level) and passed down explicitly.
- Do not perform navigation, I/O, or side effects inside widget build methods.

## Navigation

- Prefer `go_router` for navigation unless there are clear reasons to use Navigator 2.0 directly.
- Route configuration must live in a dedicated navigation layer/file, not scattered through widgets.
- Deep links and guarded routes (auth, onboarding, etc.) must be handled centrally in the routing setup.

## Data Access

- Use the Repository pattern to decouple network, local, and domain logic.
- Repositories expose domain models or domain-specific DTOs, never raw HTTP or database responses.
- Data sources (remote, local, cache) must not be used directly in UI or ViewModel layers.
- Serialization and deserialization logic must live in models or dedicated mappers, not in UI code.

## Dependency Injection

- Use DI (e.g., Provider, Riverpod, or a DI container) for singletons and services.
- Do not use global mutable singletons or static service locators except in controlled DI setup.
- All external dependencies (HTTP clients, storage, analytics, etc.) must be injected, not created directly in business logic.

## Error & Failure Handling

- All network, IO, and parsing operations must handle errors explicitly (no silent failures).
- Map low-level errors to domain-level failure types before exposing them to the UI or ViewModel.
- UI must show clear, user-friendly error states; never expose raw exception messages.
- Implement retry, fallback, or offline behavior where appropriate instead of simply failing.

## Networking & Data Persistence

- All HTTP access must go through dedicated data source classes (e.g., `RemoteDataSource`).
- Configure timeouts, base URLs, and headers centrally; do not hard-code them across the app.
- If local persistence (e.g., SQLite, Hive, shared_preferences) is used, keep schemas and migrations in the data layer.
- Design caching strategy explicitly (what to cache, invalidation policy, cache vs. network precedence).

## Async & Concurrency

- Prefer `Future` and `Stream` for async work; avoid blocking the UI thread.
- Never perform heavy computation in the build method; use isolates or background tasks when needed.
- Ensure long-running tasks are cancellable where applicable (e.g., when widgets are disposed).
- Avoid race conditions by clearly defining ownership and lifetime of async operations per view model.

## Performance & Accessibility

- Use `const` constructors wherever possible to reduce rebuild costs.
- Minimize widget rebuilds by splitting large widgets into smaller, focused components.
- Always provide loading, empty, and error states for data-driven UIs.
- Follow basic accessibility guidelines: semantics labels, sufficient contrast, and tap target sizes.

## Security & Secrets

- Do not hard-code API keys, secrets, or credentials in the source code.
- Store secrets using platform-secure storage mechanisms or environment configuration, not in the repo.
- Validate and sanitize any external input before using it (especially for web views or dynamic content).
- Avoid logging sensitive data (PII, tokens, passwords) in any environment.

## Testing Strategy

- Mirror `lib/` layout in `test/` so tests are easy to discover.
- Unit tests should cover view model / controller logic, use cases, and repositories.
- Widget tests should cover UI components and their interaction with state, including basic navigation.
- Integration tests should cover critical flows (authentication, checkout, onboarding, etc.) where applicable.
- Any new behavior or bug fix must include or update tests to prevent regressions.

## AI Integration Rules (if using AI/LLMs)

- All AI/LLM calls must go through a dedicated service (e.g., `AiService` or `ChatService`), not directly from UI.
- Prompt templates, system messages, and model configuration must live in version-controlled files, not hard-coded inline.
- Do not send PII or sensitive information to external AI providers unless explicitly allowed and documented.
- Implement rate limiting, retries, and graceful degradation for AI-dependent features (fall back to non-AI UX when needed).

## AI Agent Behavior & Code Change Rules

These rules apply specifically when an AI agent is modifying the codebase:

- Do not introduce new third-party packages, state management libraries, or navigation stacks without explicit human approval.
- Do not break layer boundaries: 
  - UI must not perform network calls or direct data persistence.
  - Data layer must not depend on UI widgets.
- Preserve existing public APIs, data contracts, feature flags, and configuration unless explicitly instructed to change them.
- When adding or changing functionality:
  - Update or add appropriate unit, widget, and/or integration tests.
  - Ensure `flutter analyze`, `flutter test`, and formatting checks pass.
- Do not remove or bypass error handling, logging, or analytics unless a better replacement is provided.
- Keep the feature-based structure intact; new code must be placed in the correct feature and layer folders.

---