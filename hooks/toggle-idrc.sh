#!/usr/bin/env bash
set -euo pipefail

TOGGLE_FILE=".claude/.idrc-active"

if [ -f "$TOGGLE_FILE" ]; then
    rm "$TOGGLE_FILE"
    echo "idrc mode: OFF"
else
    mkdir -p "$(dirname "$TOGGLE_FILE")"
    touch "$TOGGLE_FILE"
    echo "idrc mode: ON"
fi