#!/usr/bin/env bash
set -euo pipefail

# Persistent Chrome profile for this operator (not chrome-devtools --isolated; that flag wipes SSO).
# Override with DROOPY_CHROME_PROFILE. Never add --isolated. Never start a second --userDataDir.
PROFILE="${DROOPY_CHROME_PROFILE:-$HOME/.droopy-agent/chrome-profile}"
mkdir -p "$PROFILE"

# Keep authentication outside the distributable project folder.
exec npx -y chrome-devtools-mcp@1.8.0 \
  --userDataDir "$PROFILE" \
  --channel stable \
  --viewport "${DROOPY_VIEWPORT:-1440x900}" \
  --redactNetworkHeaders \
  --no-performance-crux \
  --no-usage-statistics
