---
name: test-writer
description: Write comprehensive xUnit tests for new or changed C# code. Use automatically when new features are added, methods are created, or behavior is modified.
---

Write comprehensive tests for the code that was just added or changed.

## Step 1: Discover What Changed

- Check `git diff` and `git diff --cached` to identify new/modified methods, classes, and handlers
- Read each changed file to understand the behavior being added
- Identify the project's existing test framework and conventions by finding existing test files in `tests/`
- Place new test files in the matching test project, mirroring the source structure (e.g., `src/Application/Recipes/Commands/` → `tests/Application.Tests/Recipes/Commands/`)

## Step 2: Analyze Every Code Path

For each new or modified method/class/handler, map out:

- **Happy path**. Normal input, expected output
- **Edge cases**. Empty strings, null, zero, boundary values
- **Null/uninitialized**. What happens with missing data — nullable reference types enabled, so track these carefully
- **Error paths**. Invalid input, not found, concurrency conflict, validation failure
- **Async behavior**. CancellationToken propagation, timeout, concurrent calls with shared state
- **State transitions**. Entity state before/after command execution
- **Integration points**. How this interacts with `DbContext`, external services, domain events

## Step 3: Write the Tests

For EACH scenario identified above, write a test. No skipping.

### Structure

- **One assertion concept per test** — use FluentAssertions for readable assertions
- **Naming**: `MethodName_StateUnderTest_ExpectedBehavior`
- **Arrange-Act-Assert**. Clear separation with blank lines between sections

### What to Test

**Application layer (use cases / handlers):**
- Returns expected result on success
- Returns typed error (not-found, conflict, validation) on failure — not exceptions
- Calls correct repository/service methods with correct arguments
- Does NOT call external services when domain logic fails early

**Validators (FluentValidation):**
- Each validation rule: valid value passes, invalid value fails with correct error code/message
- Required fields missing → validation fails
- Boundary values (MaxLength, range)

**Domain layer:**
- Business rule enforcement: invariants throw or return error on violation
- Entity state after operations
- Value object equality and construction

**API endpoints (integration tests with WebApplicationFactory):**
- Returns correct HTTP status code and response shape on success
- Returns 400/422 on validation failure with problem details body
- Returns 401/403 for unauthenticated/unauthorized requests
- Returns 404 for unknown resource IDs

### Mocking Rules

- Unit tests: mock only at system boundaries — `IRepository`, `IEmailService`, external HTTP — not domain objects
- Integration tests: use real PostgreSQL via Testcontainers (`WebApplicationFactory<Program>`)
- Never mock `DbContext` in unit tests — use an in-memory or real DB instead, or restructure to test through a repository interface
- Reset mocks between tests. No shared state leaking

## Step 4: Verify

- Run `dotnet test` — all new tests pass
- Temporarily break the code (change a return value or condition) — confirm at least one test fails
- If no test fails when code is broken, the tests are useless. Rewrite them
- Check coverage: every new public method should have at least one test, every branch should be exercised

## Output

- Complete, runnable test file(s). Not snippets
- Tests grouped by the class/method they cover
- A brief summary: how many tests, what scenarios covered, any gaps you couldn't cover and why
