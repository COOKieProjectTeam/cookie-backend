---
name: api-spec-export
description: Export the running API's OpenAPI/Swagger spec into a versioned artifact under docs/api/, so the frontend /api-client skill can consume it without hitting a live server. Use after API contract changes (new endpoints, DTO updates, breaking renames).
argument-hint: "[version-tag]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash(dotnet build*)
  - Bash(dotnet run*)
  - Bash(curl*)
  - Bash(git status)
  - Bash(git diff*)
  - Bash(git add*)
---

Export the live OpenAPI document from the running ASP.NET Core API and commit it to `docs/api/` as a versioned artifact. Mirror of frontend `/api-client` — frontend consumes what this skill produces.

## Why this exists

Frontend `/api-client` skill needs a swagger source. Hitting a live dev server is brittle (env down, drift between branches). A checked-in `docs/api/openapi.json` is reproducible and reviewable in PRs.

## Inputs

- `$ARGUMENTS`: optional version tag. Examples: `v1`, `2026-05-08`, `sprint-01`. Defaults to `v1`.
- The skill assumes `src/CookieApi/` (or whatever the API project is named) exposes Swashbuckle and serves `/swagger/v1/swagger.json`.

## Step 1: Discover the API project and Swagger endpoint

- Glob `**/*.csproj` to find the API project.
- Read its `Program.cs` to confirm Swagger is registered (`AddSwaggerGen` / `UseSwagger`).
- Identify the swagger doc URL. Default Swashbuckle path: `/swagger/v1/swagger.json`.
- If no Swagger configured: STOP. Tell the user to add Swashbuckle to the API project first; do not silently proceed.

## Step 2: Pick export strategy

Two options. Prefer (A) when scaffold supports it:

**(A) Build-time export via `Swashbuckle.AspNetCore.Cli`** (preferred — no dev server needed):

- Check if `Swashbuckle.AspNetCore.Cli` is referenced.
- If not, propose adding it: `dotnet tool install --global Swashbuckle.AspNetCore.Cli` and a project reference.
- Run: `swagger tofile --output docs/api/openapi.json src/CookieApi/bin/Debug/net8.0/CookieApi.dll v1`
- This requires a successful `dotnet build` first.

**(B) Runtime export** (fallback — when CLI tool not available):

- Start the API in background: `dotnet run --project src/CookieApi --no-launch-profile`.
- Wait for readiness (poll `/health` or `/swagger/v1/swagger.json` with retry).
- `curl -sf http://localhost:5000/swagger/v1/swagger.json -o docs/api/openapi.json`.
- Stop the background process cleanly.

ASK the user which strategy to use if both are viable.

## Step 3: Normalize the output

- Pretty-print JSON (4-space indent) so diffs in PRs are readable: `jq '.' docs/api/openapi.json > tmp && mv tmp docs/api/openapi.json`.
- Strip volatile fields that change every export but carry no contract value:
  - `info.version` if it's a build-time GUID/timestamp — replace with the `$ARGUMENTS` tag.
  - Server URLs that include random ports — normalize to `https://api.cookie.test/api/v1`.
- Do NOT strip schema definitions, paths, or operationIds.

## Step 4: Versioned snapshot (optional)

- Always keep `docs/api/openapi.json` as the latest.
- If `$ARGUMENTS` provided, also write `docs/api/openapi-<tag>.json` as an immutable snapshot. This lets PR reviewers compare versions.

## Step 5: Diff review

- Run `git diff docs/api/openapi.json` and surface to the user:
  - **Added paths** — new endpoints (likely safe additive change).
  - **Removed paths** — breaking change. Flag explicitly.
  - **Changed schemas** — for each, classify: additive (new optional field) vs breaking (renamed field, type change, required added).
- Categorize the diff at the top of the response:
  - `[additive]` — frontend can pull without code changes
  - `[breaking]` — frontend must update; flag the consuming `entities/<domain>/` slices to fix

## Step 6: Hand-off

- Commit message proposal: `docs(api): export openapi <tag>` or `docs(api): export openapi (breaking: removed POST /api/v1/x)`.
- Tell the user to run `/api-client <domain>` on the frontend repo for any domain whose schema changed.

## Rules

- Never edit `docs/api/openapi.json` by hand — always re-export.
- Never commit a spec that fails `jq empty docs/api/openapi.json` (broken JSON).
- Never silently strip operations, paths, or schemas during normalization.
- If the live server returns non-200, STOP with the exact error. Do not write a partial spec.
- If `dotnet build` fails, STOP. The spec must reflect a building API.
- This skill is read-only against the API code itself — never modify controllers, DTOs, or Program.cs to "fix" spec issues. Surface the issue and let the user fix the source.
