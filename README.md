# COOKie Backend

ASP.NET Core API сервис проекта COOKie (organization [COOKieProjectTeam/cookie-backend](https://github.com/COOKieProjectTeam/cookie-backend)).

Канон технологического стека и API — см. зеркало в репозитории [architecture](https://github.com/COOKieProjectTeam/architecture): `docs/architecture/technical/tech-stack.md` и спеки в `docs/requirements/` (ветка **`main`**).

Workflow и защита ветки `main`: [.claude/rules/protected-main.md](.claude/rules/protected-main.md).

## GitHub Project · Actions

Созданная в этом репозитории **issue** добавляется в org Projects v2 **[«cookie»](https://github.com/orgs/COOKieProjectTeam/projects/2)** workflow [`.github/workflows/add-issue-to-org-project.yml`](.github/workflows/add-issue-to-org-project.yml). Нужен репозиторный секрет **`ADD_TO_PROJECT_PAT`** — см. [github-project-cookie](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/process/github-project-cookie.md) в **architecture**.

## Локально

Структура кода добавляется по мере реализации; после появления `Program.cs`/swagger файл README дополним командами `dotnet run` и базовым URL документации API.
