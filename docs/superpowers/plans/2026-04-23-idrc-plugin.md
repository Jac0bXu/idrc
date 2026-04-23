# idrc Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude Code plugin that toggles a fully-automated mode — auto-answers questions, auto-approves plans, and bypasses all permission prompts.

**Architecture:** Skill + Hooks hybrid. A `SKILL.md` skill provides the `/idrc` slash command and instructs Claude on auto-behavior. A `PreToolUse` hook checks a file-based toggle and returns `permissionDecision: "allow"` when active. State is stored per-project in `.claude/.idrc-active`.

**Tech Stack:** Bash (hooks), Markdown (skill), JSON (config)

---

## File Structure

```
idrc/
├── .claude-plugin/
│   ├── plugin.json                  # Plugin metadata
│   └── marketplace.json             # Marketplace listing
├── hooks/
│   ├── hooks.json                   # Declares PreToolUse hook
│   ├── run-hook.cmd                 # Cross-platform polyglot wrapper
│   ├── check-idrc-active.sh         # Checks toggle state, outputs allow/pass
│   └── toggle-idrc.sh              # Creates/deletes .claude/.idrc-active
└── skills/
    └── idrc/
        └── SKILL.md                 # Skill: toggle + auto-behavior instructions
```

---

### Task 1: Plugin Manifest

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Create the plugin directory structure**

Run: `mkdir -p .claude-plugin`

- [ ] **Step 2: Create plugin.json**

```json
{
  "name": "idrc",
  "description": "Toggle 'I Don't Really Care' mode — auto-answers questions, auto-approves plans, bypasses all permission prompts",
  "version": "0.1.0",
  "author": {
    "name": "Jacob Xu"
  },
  "license": "MIT",
  "keywords": [
    "automation",
    "permissions",
    "mode",
    "toggle"
  ]
}
```

- [ ] **Step 3: Create marketplace.json**

```json
{
  "name": "idrc-marketplace",
  "description": "Marketplace for idrc plugin",
  "owner": {
    "name": "Jacob Xu"
  },
  "plugins": [
    {
      "name": "idrc",
      "description": "Toggle 'I Don't Really Care' mode — auto-answers questions, auto-approves plans, bypasses all permission prompts",
      "version": "0.1.0",
      "source": "./",
      "author": {
        "name": "Jacob Xu"
      }
    }
  ]
}
```

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "feat: add plugin manifest and marketplace listing"
```

---

### Task 2: Toggle Script

**Files:**
- Create: `hooks/toggle-idrc.sh`

- [ ] **Step 1: Create hooks directory**

Run: `mkdir -p hooks`

- [ ] **Step 2: Write toggle-idrc.sh**

```bash
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
```

- [ ] **Step 3: Make executable**

Run: `chmod +x hooks/toggle-idrc.sh`

- [ ] **Step 4: Test the toggle**

Run:
```bash
# Test ON
cd /tmp && /home/xzh/Documents/idrc/hooks/toggle-idrc.sh
cat /tmp/.claude/.idrc-active && echo " — file exists, ON"

# Test OFF
/tmp/toggle-idrc.sh 2>/dev/null || cd /tmp && /home/xzh/Documents/idrc/hooks/toggle-idrc.sh
ls /tmp/.claude/.idrc-active 2>&1 || echo "file gone, OFF"
```

Expected: First run prints "idrc mode: ON" and creates the file. Second run prints "idrc mode: OFF" and deletes it.

- [ ] **Step 5: Commit**

```bash
git add hooks/toggle-idrc.sh
git commit -m "feat: add toggle script for idrc mode state"
```

---

### Task 3: Permission Check Hook

**Files:**
- Create: `hooks/check-idrc-active.sh`

- [ ] **Step 1: Write check-idrc-active.sh**

This script reads JSON on stdin (provided by the hooks system), checks for the toggle file, and outputs a permission decision.

```bash
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
```

- [ ] **Step 2: Make executable**

Run: `chmod +x hooks/check-idrc-active.sh`

- [ ] **Step 3: Test the check script**

Run:
```bash
# Should output nothing when inactive
echo '{}' | /home/xzh/Documents/idrc/hooks/check-idrc-active.sh
echo "exit code: $?"

# Activate and test
mkdir -p /tmp/.claude && touch /tmp/.claude/.idrc-active
cd /tmp && echo '{}' | /home/xzh/Documents/idrc/hooks/check-idrc-active.sh
echo ""
echo "exit code: $?"

# Cleanup
rm /tmp/.claude/.idrc-active
```

Expected: First run outputs nothing. Second run outputs `{"hookSpecificOutput":{"permissionDecision":"allow"}}`.

- [ ] **Step 4: Commit**

```bash
git add hooks/check-idrc-active.sh
git commit -m "feat: add permission check hook script"
```

---

### Task 4: Cross-Platform Hook Wrapper

**Files:**
- Create: `hooks/run-hook.cmd`

- [ ] **Step 1: Write run-hook.cmd (polyglot wrapper)**

This file is valid in both CMD (Windows) and bash (Unix). It dispatches to the correct `.sh` script.

```cmd
: << 'CMDBLOCK'
@echo off
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_NAME=%~1"
"C:\Program Files\Git\bin\bash.exe" -l -c "cd \"$(cygpath -u \"%SCRIPT_DIR%\")\" && \"./%SCRIPT_NAME%\""
exit /b
CMDBLOCK

# Unix shell runs from here
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift
"${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
```

- [ ] **Step 2: Make executable**

Run: `chmod +x hooks/run-hook.cmd`

- [ ] **Step 3: Test the wrapper on Linux**

Run:
```bash
echo '{}' | /home/xzh/Documents/idrc/hooks/run-hook.cmd check-idrc-active.sh
echo "exit code: $?"
```

Expected: Outputs nothing (idrc inactive). Exit code 0.

- [ ] **Step 4: Commit**

```bash
git add hooks/run-hook.cmd
git commit -m "feat: add cross-platform polyglot hook wrapper"
```

---

### Task 5: Hook Registration

**Files:**
- Create: `hooks/hooks.json`

- [ ] **Step 1: Write hooks.json**

Register a `PreToolUse` hook that matches all tools. The `*` matcher intercepts every tool invocation.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" check-idrc-active.sh"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Validate JSON**

Run: `python3 -c "import json; json.load(open('hooks/hooks.json')); print('valid JSON')"`

Expected: "valid JSON"

- [ ] **Step 3: Commit**

```bash
git add hooks/hooks.json
git commit -m "feat: register PreToolUse hook for idrc permission bypass"
```

---

### Task 6: Skill Definition

**Files:**
- Create: `skills/idrc/SKILL.md`

- [ ] **Step 1: Create skills directory**

Run: `mkdir -p skills/idrc`

- [ ] **Step 2: Write SKILL.md**

```markdown
---
name: idrc
description: Toggle "I Don't Really Care" mode — auto-answers questions, auto-approves plans, and bypasses all permission prompts. Use when the user types /idrc.
---

# idrc — "I Don't Really Care" Mode

Toggle fully-automated mode. When active, Claude makes decisions autonomously without waiting for user input.

## Activation

Run the toggle script to switch mode:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/hooks/toggle-idrc.sh"
```

Then follow the behavior instructions below based on the new state.

## When Active (idrc mode: ON)

<HARD_GATE>
You are in idrc mode. Follow ALL of these rules until the mode is toggled off.
</HARD_GATE>

### AskUserQuestion

Before presenting any question to the user, evaluate the options yourself:

1. Read all options carefully
2. Pick the best option based on context, feasibility, and your recommendation
3. Present your choice to the user with a brief one-line rationale
4. Only ask the user directly if there is genuinely no clear best choice (equal trade-offs with no distinguishing factors)

Format:
> **idrc auto-pick:** [chosen option] — [one-line reason]

### ExitPlanMode

Auto-approve the plan and proceed directly to implementation. Do not wait for user confirmation. State:

> **idrc:** Plan auto-approved, starting implementation.

### General Behavior

- Favor action over clarification
- Don't ask questions that can be resolved with reasonable defaults
- If something is ambiguous but a reasonable default exists, use the default and note what you chose
- Keep moving forward — the user enabled this mode because they trust your judgment

### Tool Permissions

All tool permissions are handled automatically by the PreToolUse hook. You do not need to request permission for any tool use. Proceed with all operations directly.

## When Inactive (idrc mode: OFF)

Return to normal Claude Code behavior. Ask questions normally. Wait for plan approvals. Respect permission prompts.

## Toggling

The user can type `/idrc` at any time to toggle the mode. Each invocation flips the state.
```

- [ ] **Step 3: Commit**

```bash
git add skills/idrc/SKILL.md
git commit -m "feat: add idrc skill with auto-answer and auto-approve behavior"
```

---

### Task 7: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update CLAUDE.md with plugin structure and dev commands**

Replace the current CLAUDE.md content with:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with plugin architecture and dev commands"
```

---

### Task 8: End-to-End Verification

**Files:** None (verification only)

- [ ] **Step 1: Verify all files exist with correct structure**

Run:
```bash
find . -not -path './.git/*' -not -path './docs/*' -type f | sort
```

Expected output:
```
./.claude-plugin/marketplace.json
./.claude-plugin/plugin.json
./CLAUDE.md
./hooks/check-idrc-active.sh
./hooks/hooks.json
./hooks/run-hook.cmd
./hooks/toggle-idrc.sh
./README.md
./skills/idrc/SKILL.md
```

- [ ] **Step 2: Verify all JSON files are valid**

Run:
```bash
python3 -c "
import json, sys
for f in ['.claude-plugin/plugin.json', '.claude-plugin/marketplace.json', 'hooks/hooks.json']:
    try:
        json.load(open(f))
        print(f'{f}: valid')
    except Exception as e:
        print(f'{f}: INVALID — {e}')
        sys.exit(1)
"
```

Expected: All three files report "valid".

- [ ] **Step 3: Verify all hook scripts are executable**

Run:
```bash
ls -la hooks/*.sh hooks/*.cmd | awk '{print $1, $NF}'
```

Expected: All show `-rwxr-xr-x` (executable).

- [ ] **Step 4: Test toggle cycle**

Run:
```bash
cd /home/xzh/Documents/idrc
bash hooks/toggle-idrc.sh
cat .claude/.idrc-active && echo " → ON"
bash hooks/toggle-idrc.sh
ls .claude/.idrc-active 2>&1 || echo " → OFF (file gone)"
```

Expected: First toggle prints "idrc mode: ON", second prints "idrc mode: OFF".

- [ ] **Step 5: Test permission check with toggle on**

Run:
```bash
cd /home/xzh/Documents/idrc
bash hooks/toggle-idrc.sh  # Turn ON
echo '{}' | bash hooks/check-idrc-active.sh
bash hooks/toggle-idrc.sh  # Turn OFF
```

Expected: Outputs `{"hookSpecificOutput":{"permissionDecision":"allow"}}` when on, nothing when off.

- [ ] **Step 6: Final commit with all verification passing**

```bash
git add -A
git status  # Should show nothing to commit
echo "All verification passed"
```
