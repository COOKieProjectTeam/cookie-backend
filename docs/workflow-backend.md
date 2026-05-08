# Workflow для cookie-backend

Инструкция по работе с Claude Code в этом репозитории: какие агенты, скиллы, хуки и правила настроены и как их собирать в единый цикл фичи.

Стек: **.NET 8 + ASP.NET Core 8 + EF Core 8 + Identity + JWT + FluentValidation + PostgreSQL 15 + xUnit + Swashbuckle**.

> **Главное условие:** открывать VS Code в корне `cookie-backend` (не `COOK/`). Иначе `.claude/settings.json` не подхватывается, hooks не цепляются, skills не видны.

## 1. Что лежит в `.claude/`

### Agents (`.claude/agents/`)

| Агент | Назначение |
|---|---|
| `api-designer` | REST контракты — routes, DTOs, controllers, status codes по конвенциям проекта |
| `code-reviewer` | Общий ревью изменений |
| `security-reviewer` | AuthZ/AuthN, инъекции, secrets, JWT валидация |
| `performance-reviewer` | EF Core N+1, async/await, аллокации, индексы |
| `doc-reviewer` | XML-doc, README, комментарии |

### Skills (`.claude/skills/<name>/SKILL.md`, вызов как `/<name>`)

| Скилл | Что делает |
|---|---|
| `/api-spec-export` | Выгружает OpenAPI спеку в `docs/api/openapi.json` для consume фронтендом |
| `/test-writer` | xUnit тесты под изменённый код |
| `/tdd` | Red → green → refactor цикл |
| `/pr-review` | Параллельный прогон reviewer-агентов |
| `/refactor` | Безопасный рефактор без смены поведения |
| `/debug-fix` | Гипотеза → repro → фикс |
| `/explain` | Объяснение участка кода |
| `/ship` | git status → commit → push → PR (с подтверждением на каждом шаге) |

### Hooks (`.claude/hooks/`)

| Хук | Триггер | Что делает |
|---|---|---|
| `protect-files.sh` | PreToolUse Edit/Write | Блок Edit/Write на `.env*`, `*.pem`, `*.key`, `appsettings*.Production.json` без явного approve |
| `scan-secrets.sh` | PreToolUse Edit/Write | Ловит хардкод connection strings, JWT секретов, API ключей |
| `warn-large-files.sh` | PreToolUse Edit/Write | Отстреливает попытку коммитить `bin/`, `obj/`, `*.user` |
| `block-dangerous-commands.sh` | PreToolUse Bash | Режет `rm -rf`, `git push --force` в main, `dotnet ef database drop`, `dotnet nuget push` |
| `format-on-save.sh` | PostToolUse Edit/Write | `dotnet format` после правок `.cs` файлов |
| `session-start.sh` | SessionStart | Подгружает контекст в начале сессии |
| `notify.sh` | Notification | Системные уведомления |

### Rules (`.claude/rules/`, автозагрузка в контекст)

| Файл | Что внутри |
|---|---|
| `protected-main.md` | `main` защищён, только PR |
| `sot-and-issues.md` | SoT — repo `architecture`, формат GitHub issue |
| `backend.md` | Clean Architecture слои, EF Core конвенции, DI, async/await |
| `code-quality.md`, `error-handling.md`, `security.md`, `testing.md` | Поперечные правила |

### Permissions (`settings.json`, allow без подтверждения)

`dotnet build|run|test|format|ef|add|remove|restore|clean`, весь `git *`, `gh pr|issue|run`. Всё остальное — спросит.

`Read/Write/Edit` на `.env*`, `*.pem`, `*.key`, `secrets/**` — **deny**.

## 2. Workflow на реальном примере

**Sprint 01, задача [BE#10](https://github.com/COOKieProjectTeam/cookie-backend/issues/10): JWT auth (FR-US-001).**

### Шаг 1. API дизайн

```
Ты:  /api-designer спроектируй endpoints для регистрации,
     логина и refresh по FR-US-001
```

`api-designer` возвращает:

- **Route table:**
  ```
  POST /api/v1/auth/register   201 → AuthResponse
  POST /api/v1/auth/login      200 → AuthResponse
  POST /api/v1/auth/refresh    200 → AuthResponse  (Cookie: refreshToken)
  POST /api/v1/auth/logout     204
  ```
- **DTO records:** `RegisterRequest`, `LoginRequest`, `AuthResponse(string AccessToken)`.
- **Controller stub:** `AuthController` с `[ApiController]`, `[Route("api/v1/[controller]")]`.
- **Application layer sketch:** `RegisterUserCommand`, `LoginCommand`, `RefreshTokenCommand` + handlers.
- **Open questions:** lockout policy? token TTL (access vs refresh)? rate limit на register?

### Шаг 2. Реализация

```
Ты:  ok, access TTL 15min, refresh 30 days. Lockout 5 attempts/15min. Реализуй
```

Claude пишет код. Hooks работают незаметно:
- `format-on-save.sh` гоняет `dotnet format` после каждого Write
- `scan-secrets.sh` сработает если случайно закоммитишь `Issuer` / `Audience` / signing key в код вместо `appsettings.json`
- `protect-files.sh` не даст тронуть `appsettings.Production.json`

### Шаг 3. Миграция

```
Ты:  dotnet ef migrations add AddIdentitySchema
```

`block-dangerous-commands.sh` пропустит. `database update` тоже разрешён, но `database drop` — заблокирован.

### Шаг 4. Тесты

```
Ты:  /test-writer
```

xUnit + `WebApplicationFactory` интеграционные тесты для:
- `POST /register` — happy path, дубликат email (409), невалидный пароль (400)
- `POST /login` — happy path, неверный пароль (401), lockout после 5 попыток (423)
- `POST /refresh` — валидный cookie → new access, отсутствие cookie (401)
- Юнит-тесты для `JwtTokenService` — issuer/audience, expiry, claims shape

### Шаг 5. Экспорт OpenAPI

```
Ты:  /api-spec-export sprint-01
```

Скилл собирает API, выгружает swagger в `docs/api/openapi.json` + `docs/api/openapi-sprint-01.json`. Diff:

```
[additive]
+ POST /api/v1/auth/register
+ POST /api/v1/auth/login
+ POST /api/v1/auth/refresh
+ POST /api/v1/auth/logout
+ schema: AuthResponse, RegisterRequest, LoginRequest
```

Frontend теперь может `/api-client auth ./docs/api/openapi.json` без поднятого dev-сервера.

### Шаг 6. Ревью и shipping

```
Ты:  /pr-review
```

Параллельно `code-reviewer`, `security-reviewer`, `performance-reviewer`. Сводный отчёт:

```
## PR Review: feature/auth

src/Application/Auth/Handlers/LoginHandler.cs:42:
  [perf] N+1: UserManager.GetClaimsAsync вызывается в цикле (fix: bulk query)

src/API/Controllers/AuthController.cs:18:
  [sec] Refresh token читается из request.Cookies без validation flag
        (fix: проверить HttpOnly + Secure + SameSite=Strict при выдаче)

src/Infrastructure/Auth/JwtTokenService.cs:24:
  [code] HMACSHA256 hardcoded — вынести в options
```

Чинишь.

```bash
dotnet build
dotnet test
dotnet format --verify-no-changes
```

```
Ты:  /ship "feat: add JWT auth (FR-US-001)"
```

`/ship` показывает diff, предлагает файлы, пишет commit message по стилю репо, пушит, создаёт PR с `Refs #10`. На каждом шаге подтверждение.

`block-dangerous-commands.sh` заблокирует `push --force` или push в `main`.

## 3. Чем backend отличается от frontend workflow

| Аспект | Backend (.NET) | Frontend (Next.js) |
|---|---|---|
| Дизайн-агент | `api-designer` (DTOs, controllers, MediatR) | `frontend-designer` (UI, токены, FSD) |
| Контракт-обмен | `/api-spec-export` swagger → `docs/api/` | `/api-client` swagger → Axios + Zod + hooks |
| Format hook | `dotnet format` | `prettier --write` |
| Lint hook | `dotnet build` warnings (TreatWarningsAsErrors) | `next lint --fix` (после prettier) |
| Тест-стек | xUnit + WebApplicationFactory + Testcontainers | Vitest + RTL + MSW |
| Boundary mock | mock DbContext / Identity или Testcontainers Postgres | MSW на `/api/v1/*` |
| Артефакты | OpenAPI spec, EF migrations | bundle size, RSC/client разметка |
| Слои | Clean Architecture (API → Application → Domain → Infrastructure) | FSD (app → features → entities → shared) |
| Performance focus | EF Core N+1, async/await, аллокации | re-renders, useMemo, dynamic imports |
| Дополнительная политика | EF migrations не редактируем руками | RSC vs `'use client'` |

## 4. Контракт-обмен с frontend

**Цикл при изменении API:**

1. `api-designer` спроектировал → реализовал → тесты зелёные.
2. `/api-spec-export <tag>` — выгрузил `docs/api/openapi.json` + immutable snapshot.
3. Закоммитил вместе с feature: `feat: add ... + docs(api): export openapi <tag>` (или отдельный commit).
4. На фронтенде: `/api-client <domain> ./path/to/openapi.json` → новый/обновлённый slice.
5. Если diff `[breaking]` — флагнуть в PR description, договориться о порядке мержа (backend first, потом frontend).

## 5. Полезные ссылки

- Канон стека: [architecture/docs/architecture/technical/tech-stack.md](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/architecture/technical/tech-stack.md)
- Требования: [architecture/docs/requirements/FRS.md](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/requirements/FRS.md)
- Формат issue: [architecture/docs/process/github-issue-format.md](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/process/github-issue-format.md)
- Org Project: [COOKieProjectTeam/projects/2](https://github.com/orgs/COOKieProjectTeam/projects/2)
- Frontend mirror: [cookie-frontend/docs/workflow-frontend.md](https://github.com/COOKieProjectTeam/cookie-frontend/blob/main/docs/workflow-frontend.md)
