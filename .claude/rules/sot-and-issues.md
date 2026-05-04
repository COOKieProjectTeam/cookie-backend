# Источники правды и GitHub Issues (backend)

## Канон текста требований

Ведущая копия: **Obsidian**, папка `Knowledge/Development/Projects/COOKie/`. После создания issue полный текст задачи живёт в **GitHub**; в vault остаются ссылки и трассировка (`requirements/traceability.md` и спринты).

## Формат issue

Заголовок: `[S1|…] API: …` (см. `process/github-issue-format.md` в vault).

Секции: **Goal**, **Scope (in/out)**, **Trace** (FR, опционально UC/NFR, строка `Vault:` с путём к файлу vault), **Acceptance criteria**, **Companion** (ссылка на `cookie-frontend` при необходимости), **Notes**.

Форма: `.github/ISSUE_TEMPLATE/task.yml`.

См. также org-проект **«cookie»** и метки `area:*` — [github-project-cookie](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/process/github-project-cookie.md).

## Pull Request

- **`main`** защищён на GitHub: работа только в отдельной ветке и через **Pull Request**. Подробно: `.claude/rules/protected-main.md`.
- Текст PR: связь с **issue** этого репозитория (`Refs #NN` или `Closes #NN`).

## Стек (сверка)

Ориентир: `architecture/technical/tech-stack.md` в vault — .NET **8**, EF Core **8**, Identity + JWT, FluentValidation, PostgreSQL **15**, REST + swagger. Не противоречить без явной пометки и согласования (CR).
