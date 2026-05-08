#!/usr/bin/env bash
# Blocks edits to sensitive or generated files.
# PreToolUse hook for Edit|Write operations.
# Exit 2 = block. Exit 0 = allow.

set -uo pipefail

emit() {
  local decision="$1"
  local reason="${2//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$decision" "$reason"
  exit 2
}

INPUT=$(cat)

# Extract file_path using grep+sed — no jq/python required
FILE_PATH=$(printf '%s' "$INPUT" \
  | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/' \
  | head -1 || true)

[ -z "$FILE_PATH" ] && exit 0

BASENAME=$(basename -- "$FILE_PATH")
BASENAME_LC=$(printf '%s' "$BASENAME" | tr '[:upper:]' '[:lower:]')
# Normalize backslashes to forward slashes for consistent matching
PATH_NORM=$(printf '%s' "$FILE_PATH" | tr '\\' '/')
PATH_LC=$(printf '%s' "$PATH_NORM" | tr '[:upper:]' '[:lower:]')

# Protected filename patterns (case-insensitive exact/glob match)
PROTECTED_PATTERNS=(
  ".env"
  ".env.*"
  "*.pem"
  "*.key"
  "*.crt"
  "*.p12"
  "*.pfx"
  "id_rsa"
  "id_ed25519"
  "credentials.json"
  ".npmrc"
  ".pypirc"
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  "*.gen.ts"
  "*.generated.*"
  "*.min.js"
  "*.min.css"
)

shopt -s nocasematch 2>/dev/null || true
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  case "$BASENAME_LC" in
    $pattern)
      emit deny "Protected file: $BASENAME matches pattern '$pattern'"
      ;;
  esac
done

# Sensitive path patterns (normalized to forward slashes)
case "$PATH_LC" in
  .git/*|*/.git/*)
    emit deny "Cannot edit files inside .git/" ;;
  */secrets/*)
    emit deny "Cannot edit files inside secrets/" ;;
  */.env|*/.env.*)
    emit deny "Cannot edit .env files" ;;
  .claude/hooks/*|*/.claude/hooks/*)
    emit deny "Cannot edit hook scripts. These enforce security boundaries." ;;
  .claude/settings.json|.claude/settings.local.json|*/.claude/settings.json|*/.claude/settings.local.json)
    emit ask "Editing settings.json controls permissions and hooks. Confirm this change." ;;
esac

exit 0
