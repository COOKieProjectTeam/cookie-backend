---
paths:
  - "**/*.cs"
  - "src/**"
  - "tests/**"
---

# Backend

## Stack (project-specific)

- **Platform**: ASP.NET Core 8, .NET 8
- **Architecture**: Clean Architecture — `API` → `Application` → `Domain` → `Infrastructure`
- **ORM**: EF Core 8 + PostgreSQL 15. Migrations only via `dotnet ef migrations add`.
- **Auth**: ASP.NET Identity + JWT Bearer. Refresh token in HttpOnly cookie (never in localStorage).
- **Validation**: FluentValidation in Application layer. Never validate in Domain.
- **API**: REST, prefix `/api/v1/`, Swagger/OpenAPI via Swashbuckle.

## API Design

- Route prefix: `/api/v1/{resource}`. No ad-hoc versioning without architecture approval.
- HTTP verbs: GET (read), POST (create), PUT (replace), PATCH (partial update), DELETE.
- Response: standard envelope `{ data, errors, meta }` or problem details (RFC 7807) on error.
- Never return 200 with error payload. Use correct 4xx/5xx codes.
- Paginated lists: `?page=1&pageSize=20`, return `{ items, totalCount, page, pageSize }`.

## Clean Architecture Rules

- `Domain`: entities, value objects, domain events, interfaces. No infrastructure deps.
- `Application`: use cases (commands/queries via MediatR or manual), DTOs, FluentValidation validators. No direct DB access.
- `Infrastructure`: EF Core DbContext, repositories, external services, Identity.
- `API`: controllers, middleware, DI registration. No business logic.

## EF Core / Database

- Migrations: `dotnet ef migrations add <Name> --project src/Infrastructure --startup-project src/CookieApi`
- Never edit migration files manually after applying.
- Use `AsNoTracking()` for read-only queries.
- Transactions: explicit `IDbContextTransaction` for multi-aggregate operations.

## Performance

- Async all the way: `async/await` on every I/O call. No `.Result` or `.Wait()`.
- N+1: use `.Include()` / `.ThenInclude()` or explicit joins. Never lazy-load in loops.
- Large lists: paginate. Never return unbounded collections.
