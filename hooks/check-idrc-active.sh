#!/usr/bin/env bash
set -euo pipefail

# The hook system passes tool info on stdin, but we don't need it
# We just need to check if idrc mode is active
cat > /dev/null

TOGGLE_FILE=".claude/.idrc-active"

if [ -f "$TOGGLE_FILE" ]; then
    printf '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
fi

# If file doesn't exist, output nothing — normal permission flow continues
exit 0