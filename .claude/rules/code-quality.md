---
paths:
  - "**/*.cs"
  - "src/**"
---

# Code Quality

- Follow C# conventions: PascalCase for types/members, camelCase for locals/params, `_camelCase` for private fields.
- Prefer records for immutable DTOs and value objects.
- Nullable reference types enabled (`<Nullable>enable</Nullable>`). No `!` suppression without justification.
- No magic strings/numbers — use constants or enums.
- Keep controllers thin: no business logic, only HTTP mapping + dispatch to Application layer.
- Constructor injection only. No service locator pattern.
- Avoid `static` mutable state.
- XML docs on public API surface (controllers, DTOs). Not required on internal implementation.
