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