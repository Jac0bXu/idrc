# idrc

**"I Don't Really Care"** — a [Claude Code](https://claude.ai/code) plugin that toggles a fully-automated mode.

When active, Claude stops asking you questions, auto-approves its own plans, and bypasses all permission prompts. You type what you want, it does it. No interruptions.

## What it does

When you toggle `/idrc` on:

- **Auto-answers questions** — When Claude would normally present multiple-choice options, it evaluates them itself and picks the best one. You see what it chose and why.
- **Auto-approves plans** — Plans are accepted immediately and implementation starts without waiting for your confirmation.
- **Bypasses permissions** — All tool uses (Bash, Edit, Write, etc.) are auto-approved. No more pressing "y" on every command.

## How it works

idrc uses a **skill + hooks** hybrid:

1. **Skill** (`/idrc`) — Instructs Claude to make autonomous decisions and minimize back-and-forth.
2. **PreToolUse hook** — Intercepts every tool call and auto-approves permissions when the mode is active.
3. **File-based toggle** — State is stored in `.claude/.idrc-active`. Creating the file activates the mode, deleting it deactivates.

```
/idrc          → toggle on/off
AskUserQuestion → auto-picked by Claude
ExitPlanMode    → auto-approved
Tool use        → auto-allowed by hook
```

## Installation

Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "idrc@idrc-marketplace": true
  },
  "extraKnownMarketplaces": {
    "idrc-marketplace": {
      "source": {
        "source": "directory",
        "path": "/path/to/idrc"
      }
    }
  }
}
```

Restart Claude Code, then type `/idrc` to toggle the mode.

## Usage

```
> /idrc
idrc mode: ON

> refactor the auth module to use JWTs
# Claude proceeds without asking questions, auto-approves its plan,
# and runs all commands without permission prompts.

> /idrc
idrc mode: OFF

# Back to normal interaction.
```

## Architecture

```
idrc/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata
│   └── marketplace.json         # Marketplace listing
├── hooks/
│   ├── hooks.json               # PreToolUse hook declaration
│   ├── run-hook.cmd             # Cross-platform wrapper (Windows + Unix)
│   ├── check-idrc-active.sh     # Returns "allow" when mode is active
│   └── toggle-idrc.sh           # Creates/deletes the toggle file
└── skills/
    └── idrc/
        └── SKILL.md             # Auto-answer and auto-approve instructions
```

## Warning

This plugin disables all safety prompts. Claude will execute commands, edit files, and make decisions without asking you. Use it when you trust the output and want maximum velocity. Toggle it off when you want control back.

## License

MIT
