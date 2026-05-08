---
paths:
  - "src/**"
  - "**/*.cs"
---

# Security

- Validate all input at system boundary (controllers/validators). Never trust request data.
- Use parameterized queries / EF Core. Never concatenate user input into SQL.
- Sanitize output to prevent XSS in any HTML-generating endpoints.
- JWT: short-lived access tokens (≤15 min). Refresh tokens server-side only, stored HttpOnly cookie.
- Never log secrets, tokens, passwords, or PII. Scrub sensitive fields from structured logs.
- Use constant-time comparison for secrets and tokens (`CryptographicOperations.FixedTimeEquals`).
- Set appropriate CORS policy — whitelist specific origins, never `AllowAnyOrigin` in production.
- Rate-limit authentication endpoints (`/api/v1/auth/*`).
- HTTPS only in production. Redirect HTTP → HTTPS.
- Never expose stack traces or internal error details in API responses (use problem details without `detail` in production).
