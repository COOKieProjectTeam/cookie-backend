# COOKie Backend

ASP.NET Core API сервис проекта COOKie (organization [COOKieProjectTeam/cookie-backend](https://github.com/COOKieProjectTeam/cookie-backend)).

Канон технологического стека и API — см. зеркало в репозитории [architecture](https://github.com/COOKieProjectTeam/architecture): `docs/architecture/technical/tech-stack.md` и спеки в `docs/requirements/` (ветка **`main`**).

**Защита ветки `main`** (ветка → PR): [.claude/rules/protected-main.md](.claude/rules/protected-main.md).

## GitHub Project · Actions

Организационный backlog: **[«cookie»](https://github.com/orgs/COOKieProjectTeam/projects/2)**.

После добавления workflow **Add issue to COOK org project** (эталон — [github-project-cookie](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/process/github-project-cookie.md), секция «Автоматизация») и репозиторного секрета **`ADD_TO_PROJECT_PAT`** новые **issue** будут добавляться в проект при открытии.

## Локально

Структура кода добавляется по мере реализации; после появления `Program.cs`/swagger файл README дополним командами `dotnet run` и базовым URL документации API.
