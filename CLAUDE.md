# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**idrc** is a Claude Code plugin that provides a toggleable fully-automated mode. When active (`/idrc`):
- Auto-answers AskUserQuestion using smart-pick (best judgment)
- Auto-approves ExitPlanMode (plans proceed to implementation immediately)
- Bypasses all tool permission prompts via PreToolUse hook

State is stored per-project in `.claude/.idrc-active`.

## Architecture

```
idrc/
├── .claude-plugin/       # Plugin metadata (plugin.json, marketplace.json)
├── hooks/
│   ├── hooks.json        # Declares PreToolUse hook matching all tools
│   ├── run-hook.cmd      # Cross-platform polyglot wrapper (CMD + bash)
│   ├── check-idrc-active.sh  # Returns allow if .claude/.idrc-active exists
│   └── toggle-idrc.sh    # Creates/deletes .claude/.idrc-active
└── skills/
    └── idrc/
        └── SKILL.md      # Skill: toggle + auto-behavior instructions
```

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