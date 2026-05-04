# cookie-backend (COOKie)

Корень репозитория — **ASP.NET Core** сервис проекта COOKie (org [COOKieProjectTeam](https://github.com/COOKieProjectTeam)).

## Читать первым

1. [.claude/rules/protected-main.md](rules/protected-main.md) — **`main`** защищённая ветка: только через новую ветку, push и **PR → `main`**; в PR указать связь с **issue** (`Closes` / `Refs #N`).
2. [.claude/rules/sot-and-issues.md](rules/sot-and-issues.md) — источники правды и формат задач.
3. Канон стека и API: заметка **tech-stack** в Obsidian — `Knowledge/Development/Projects/COOKie/architecture/technical/tech-stack.md` (локально на машине разработчика).

## Коротко

- Ветки и PR см. [.claude/rules/protected-main.md](rules/protected-main.md): не пушить в `main` напрямую.
- Спецификация в **vault**, не копировать простыни SRS в PR/issues.
- Issues: поля формы `.github/ISSUE_TEMPLATE/task.yml`, блок **Trace** обязателен для связи с FR.
- Диаграммы и зеркало репозитория **architecture**: [github.com/COOKieProjectTeam/architecture](https://github.com/COOKieProjectTeam/architecture).

### API / качество перед PR

- **Платформа:** **ASP.NET Core 8**, REST поверх версионированных маршрутов (канонический префикс **`api/v1`**, см. SRS/архитектурное зеркало); не добавлять несогласованные версии без trace в issue и обновления спеки/vault при необходимости.
- **Документация контрактов:** локально при запущенном API — Swagger UI типично на **`/swagger`** (конкретный путь см. код `Program.cs`/регистрация OpenAPI по мере появления приложения в репо).
- **Health:** при наличии production-oriented endpoints держите отдельно liveness/readiness и не сваливать в них бизнес-логику.
- **От issue к коду:** в PR явная связь (`Refs`/`Closes`); затем соответствие **Trace ↔ контроллер/сервис ↔ тесты** (юнит/интеграционные там, где заведены в решении).

### Организационная доска

- Единый org Projects **«cookie»**, workflow добавления issue: см. [github-project-cookie](https://github.com/COOKieProjectTeam/architecture/blob/main/docs/process/github-project-cookie.md).
