---
paths:
  - "tests/**"
  - "**/*.Tests/**"
  - "**/*Tests.cs"
---

# Testing

- Unit tests: xUnit. Test Application layer (use cases/validators) with mocked interfaces. No real DB.
- Integration tests: use `WebApplicationFactory<Program>` + real PostgreSQL (Testcontainers). Test full HTTP stack.
- Naming: `MethodName_StateUnderTest_ExpectedBehavior`.
- Arrange/Act/Assert pattern. One assertion concept per test.
- FluentAssertions for readable assertions.
- Mock only at system boundaries (external services, DbContext). Don't mock domain objects.
- Test validators separately — FluentValidation validators are pure functions.
- Coverage target: business logic in Application/Domain layers. Don't chase infrastructure coverage.
