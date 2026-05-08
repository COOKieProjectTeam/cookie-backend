# Источники правды и GitHub Issues (backend)

## Канон текста требований

Источник правды: репозиторий [**architecture**](https://github.com/COOKieProjectTeam/architecture) — `docs/requirements/FRS.md`, `docs/technical/tech-stack.md`. Не дублировать полные тексты спеки в issues.

## Формат issue

Заголовок: `[S1|…] API: …`. Секции как в [`docs/process/github-issue-format.md`](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/process/github-issue-format.md); форма — `.github/ISSUE_TEMPLATE/task.yml`.

**Trace:** FR + ссылка на раздел в `architecture/docs/requirements/FRS.md §…`.

**Companion:** при вертикали указывать issue в `cookie-frontend`.

**Организационная доска:** Projects v2 org **«cookie»** — метки **`area:frontend`**, **`area:backend`**, **`area:infra`**, **`area:docs`**. Процесс: [github-project-cookie](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/process/github-project-cookie.md).

## Pull Request

- **`main`** защищён: только ветка + **PR**. См. `.claude/rules/protected-main.md`.
- В описании PR — ссылка на **issue** (`Refs`/`Closes #NN`).

## Стек (сверка)

Канон: **.NET 8**, **ASP.NET Core 8**, EF Core 8, Identity + JWT, FluentValidation, PostgreSQL 15, REST + Swagger — см. [`docs/technical/tech-stack.md`](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/technical/tech-stack.md).
