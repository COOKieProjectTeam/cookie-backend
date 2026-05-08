# cookie-backend (COOKie)

Корень репозитория — **ASP.NET Core 8** сервис проекта COOKie (org [COOKieProjectTeam](https://github.com/COOKieProjectTeam)).

## Команды

```bash
dotnet build                        # сборка
dotnet run --project src/CookieApi  # dev-сервер
dotnet test                         # все тесты
dotnet format                       # форматирование
dotnet ef migrations add <Name>     # EF Core миграция
dotnet ef database update           # применить миграции
```

## Читать первым

1. [.claude/rules/protected-main.md](rules/protected-main.md) — **`main`** защищённая ветка: ветка → push → **PR → `main`**; в PR указать связь с **issue** (`Closes` / `Refs #N`).
2. [.claude/rules/sot-and-issues.md](rules/sot-and-issues.md) — источники правды и формат задач.
3. Канон стека и API: репозиторий [architecture](https://github.com/COOKieProjectTeam/architecture) — `docs/technical/tech-stack.md` и `docs/requirements/FRS.md`.

## Архитектура

Clean Architecture слои: `API` → `Application` → `Domain` → `Infrastructure`. Не пропускать слои.

## Ключевые решения

- **Платформа**: ASP.NET Core 8, .NET 8
- **Auth**: JWT Bearer + Identity, refresh token в HttpOnly cookie
- **ORM**: EF Core 8, PostgreSQL 15
- **Валидация**: FluentValidation
- **API**: REST, версионирование `/api/v1/...`, Swagger/OpenAPI

## Dev / качество перед PR

- **Swagger:** при запущенном API доступен на `/swagger`; контракты не менять без обновления спеки в [architecture](https://github.com/COOKieProjectTeam/architecture).
- **Миграции:** добавлять только через `dotnet ef migrations add`, не редактировать вручную.
- **Проверки перед PR:** `dotnet build` → `dotnet test` → `dotnet format --verify-no-changes`; при ошибках чинить перед ревью.

## Организационная доска

- Единый org Projects **«cookie»**: [github-project-cookie](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/process/github-project-cookie.md).
