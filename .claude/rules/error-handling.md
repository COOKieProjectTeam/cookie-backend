---
paths:
  - "src/**"
  - "**/*.cs"
---

# Error Handling

- Use typed exception classes or result types (`Result<T>`). Never throw generic `Exception("something went wrong")`.
- Never swallow exceptions silently. Log with context (operation name, relevant IDs) then rethrow or convert.
- Handle all async exceptions. No fire-and-forget without explicit error handling.
- Global exception middleware converts unhandled exceptions to RFC 7807 problem details. Don't duplicate this in controllers.
- Domain errors (validation, not-found, conflict): return typed results from Application layer, map to HTTP in controllers.
- EF Core: catch `DbUpdateConcurrencyException` and `DbUpdateException` separately — they need different handling.
- Never return 500 for business logic failures (not found → 404, conflict → 409, validation → 400/422).
- Log at appropriate level: Warning for expected failures (not found, validation), Error for unexpected exceptions.
