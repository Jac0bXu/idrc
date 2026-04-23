# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**idrc** is a Claude Code plugin that toggles a fully-automated mode via `/idrc`. State is stored per-project in `.claude/.idrc-active`.

## Development

- All hook scripts are bash. Test with: `echo '{}' | bash hooks/check-idrc-active.sh`
- Validate JSON: `python3 -c "import json; json.load(open('hooks/hooks.json'))"`
- Toggle state manually: `bash hooks/toggle-idrc.sh`

## Plugin Installation

Install locally by adding to `~/.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "idrc@idrc-marketplace": true
  },
  "extraKnownMarketplaces": {
    "idrc-marketplace": {
      "source": {
        "source": "directory",
        "path": "/home/xzh/Documents/idrc"
      }
    }
  }
}
```
