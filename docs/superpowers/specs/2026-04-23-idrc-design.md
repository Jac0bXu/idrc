# idrc — "I Don't Really Care" Mode for Claude Code

**Date:** 2026-04-23
**Status:** Approved

## Problem

When using Claude Code in plan mode or during long implementation sessions, Claude frequently asks clarifying questions (via `AskUserQuestion`), requests plan approvals (via `ExitPlanMode`), and prompts for tool permissions. For users who trust Claude's judgment and want maximum velocity, these interruptions break flow. The user wants a toggle that says "I don't really care — just pick the best option and keep going."

## Solution

A Claude Code plugin called **idrc** that provides a toggleable fully-automated mode. When active:

1. **AskUserQuestion** — Claude auto-picks the best option using its own judgment (smart pick), with a brief rationale visible to the user
2. **ExitPlanMode** — Plans are auto-approved, implementation begins immediately
3. **Tool permissions** — All tool uses (Bash, Edit, Write, etc.) are auto-approved via hooks
4. **General behavior** — Claude minimizes back-and-forth, favors action over asking

## Trigger

- Slash command: `/idrc` toggles the mode on/off
- Cannot be added to the built-in shift+tab mode cycle (that's hardcoded in Claude Code)
- State is per-project, stored in `.claude/.idrc-active`

## Architecture

```
idrc/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata
│   └── marketplace.json         # Marketplace listing
├── hooks/
│   ├── hooks.json               # Declares PreToolUse hook
│   ├── check-idrc-active.sh     # Checks .claude/.idrc-active, returns allow/pass
│   └── toggle-idrc.sh           # Creates/deletes .claude/.idrc-active
└── skills/
    └── idrc/
        └── SKILL.md             # Skill: auto-answer, auto-approve, minimize interaction
```

## Components

### 1. SKILL.md — Auto-behavior instructions

The skill is invoked with `/idrc`. It does two things:

**Toggle action:** Runs `toggle-idrc.sh` to create or delete `.claude/.idrc-active`.

**Behavior instructions (when active):**
- `AskUserQuestion`: Before asking the user, evaluate all options and pick the best one. Include a one-line rationale. Only ask the user if genuinely ambiguous with no clear best choice.
- `ExitPlanMode`: Auto-approve plans and proceed to implementation immediately.
- General: Favor action over clarification. Don't ask questions that can be resolved with reasonable defaults.

**Behavior instructions (when inactive):**
- Remove all auto-behavior. Return to normal Claude Code interaction.

### 2. hooks.json — Hook declarations

Registers a `PreToolUse` hook that matches all tools. The hook runs `check-idrc-active.sh`.

### 3. check-idrc-active.sh — Permission auto-allow

Shell script that:
1. Checks if `.claude/.idrc-active` exists in the current project root
2. If yes: outputs `{"hookSpecificOutput": {"permissionDecision": "allow"}}`
3. If no: outputs nothing (normal permission flow continues)

This gives functionally identical behavior to `bypassPermissions` mode, but only when idrc is toggled on.

### 4. toggle-idrc.sh — State toggle

Shell script that:
1. Checks if `.claude/.idrc-active` exists
2. If yes: deletes it, prints "idrc mode: OFF"
3. If no: creates it, prints "idrc mode: ON"

## Data Flow

```
User types /idrc
  → SKILL.md loads
  → toggle-idrc.sh runs
  → .claude/.idrc-active created (ON) or deleted (OFF)

During conversation (idrc ON):
  Claude asks question → SKILL.md instructions → smart-pick answer
  Claude uses tool → PreToolUse hook → check-idrc-active.sh → "allow"

User types /idrc again → file deleted → all automation stops
```

## Design Decisions

- **File-based state** over environment variable: Hooks run as separate shell processes with no shared memory. A file is the simplest cross-process state mechanism.
- **Skill + Hooks hybrid** over pure skill: Skills can't bypass the permission system — only hooks can return `permissionDecision: "allow"`. Skills handle the "smart picking" behavior; hooks handle the permission bypass.
- **Project-scoped state** over global: `.claude/.idrc-active` is project-local, so toggling idrc in one project doesn't affect others.
- **Transparent auto-decisions**: User sees what was auto-picked in the conversation. No hidden choices.

## Out of Scope

- Adding to shift+tab mode cycle (not possible via plugin API)
- Global/permanent toggle (project-scoped only)
- Customizable auto-pick strategy (always smart-pick, no "always pick first/last")
