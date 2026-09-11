#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=0

for command_name in node npm npx; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'ERROR: missing required command: %s\n' "$command_name"
    errors=$((errors + 1))
  fi
done

check_mcp_json() {
  local file="$1"
  local label="$2"
  if ! node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$file" 2>/dev/null; then
    printf 'ERROR: %s is not valid JSON\n' "$label"
    errors=$((errors + 1))
    return
  fi
  if ! grep -q 'scripts/start-chrome-devtools-mcp.sh' "$file"; then
    printf 'ERROR: %s must launch chrome-devtools via scripts/start-chrome-devtools-mcp.sh\n' "$label"
    errors=$((errors + 1))
  fi
  if ! grep -q 'https://mcp.figma.com/mcp' "$file"; then
    printf 'ERROR: %s must include the official Figma MCP URL\n' "$label"
    errors=$((errors + 1))
  fi
}

check_mcp_json "$ROOT/.cursor/mcp.json" ".cursor/mcp.json"
check_mcp_json "$ROOT/.mcp.json" ".mcp.json"

if [[ ! -f "$ROOT/.codex/config.toml" ]]; then
  printf 'ERROR: missing .codex/config.toml (Codex project MCP)\n'
  errors=$((errors + 1))
else
  if ! grep -q 'scripts/start-chrome-devtools-mcp.sh' "$ROOT/.codex/config.toml"; then
    printf 'ERROR: .codex/config.toml must launch chrome-devtools via scripts/start-chrome-devtools-mcp.sh\n'
    errors=$((errors + 1))
  fi
  if ! grep -q 'https://mcp.figma.com/mcp' "$ROOT/.codex/config.toml"; then
    printf 'ERROR: .codex/config.toml must include the official Figma MCP URL\n'
    errors=$((errors + 1))
  fi
fi

if [[ ! -f "$ROOT/skills/droopy-qa/SKILL.md" ]]; then
  printf 'ERROR: missing canonical skill skills/droopy-qa/SKILL.md\n'
  errors=$((errors + 1))
fi

if [[ ! -f "$ROOT/.env" ]]; then
  printf 'WARN: copy .env.example to .env (or complete first-run interview) and add local values\n'
else
  if ! grep -Eq '^QA_REVIEWER_FIRST_NAME=.+$' "$ROOT/.env"; then
    printf 'WARN: QA_REVIEWER_FIRST_NAME is empty; complete onboarding\n'
  fi
  if ! grep -Eq '^QA_WORK_EMAIL=.+$' "$ROOT/.env"; then
    printf 'WARN: QA_WORK_EMAIL is empty; complete onboarding before SSO\n'
  fi
  if ! grep -Eq '^QA_PRODUCT_EMAIL=.+$' "$ROOT/.env"; then
    printf 'WARN: QA_PRODUCT_EMAIL is empty; complete onboarding before SSO\n'
  fi
  if ! grep -Eq '^QA_QUEUE_URL=.+$' "$ROOT/.env"; then
    printf 'WARN: QA_QUEUE_URL is empty; complete onboarding before QA\n'
  fi
  if ! grep -Eq '^QA_APP_URL=.+$' "$ROOT/.env"; then
    printf 'WARN: QA_APP_URL is empty; complete onboarding before QA\n'
  fi
  if ! grep -Eq '^FIGMA_API_TOKEN=.+$' "$ROOT/.env"; then
    printf 'WARN: FIGMA_API_TOKEN is empty; Figma OAuth is primary. REST fallback is unavailable.\n'
  fi
fi

if [[ ! -x "$ROOT/scripts/start-chrome-devtools-mcp.sh" ]]; then
  printf 'ERROR: Chrome DevTools MCP launcher is not executable\n'
  errors=$((errors + 1))
fi

if [[ "$errors" -gt 0 ]]; then
  printf 'Setup check failed with %d error(s).\n' "$errors"
  exit 1
fi

printf 'Setup structure is valid. Complete your agent OAuth and browser sign-ins interactively.\n'
