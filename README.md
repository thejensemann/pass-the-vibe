# pass-the-vibe

Auto-document your Claude Code sessions per git branch.

## What it does

- Maintains markdown files per git branch in a `.vibe/` directory
- Files are named with date prefix and branch name: `2025-01-14_feature-xyz.md`
- Automatically logs user prompts and Claude's responses
- Optional auto-commit: automatically commit changes when Claude finishes
- Single command initialization, no manual action needed afterward

## Installation

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/thejensemann/pass-the-vibe/main/install.sh | bash
```

This will:
- Check for dependencies (git required, jq recommended)
- Install to `~/.pass-the-vibe`
- Provide instructions for adding to your PATH

### Manual installation

```bash
git clone https://github.com/thejensemann/pass-the-vibe.git ~/.pass-the-vibe
export PATH="$PATH:$HOME/.pass-the-vibe"
```

## Usage

### Initialize in your project

```bash
cd your-project
pass-the-vibe init
```

This will:
1. Create a `.vibe/` directory for logs and config
2. Configure Claude Code hooks in `.claude/settings.local.json`

The settings file uses portable commands (`pass-the-vibe _hook ...`) so it can be
committed and shared with your team. Teammates just need `pass-the-vibe` in their PATH.

### Enable auto-commit (optional)

Automatically commit all changes when Claude finishes:

```bash
# During init
pass-the-vibe init --auto-commit

# Or enable later
pass-the-vibe config --auto-commit

# Disable auto-commit
pass-the-vibe config --no-auto-commit
```

### Check status

```bash
pass-the-vibe status
```

### That's it!

After initialization, every Claude Code session will automatically log to:
```
.vibe/<date>_<branch>.md
```

Commit these files with your code changes to document the vibe.

## Example output

```markdown
# Vibe Log: feature/add-authentication

Date: 2025-01-14

---

## [10:23:45] User

Add a login form component with email and password fields

## [10:24:12] Claude

I'll create a login form component...

---

## [10:30:00] User

Now add form validation

## [10:30:45] Claude

I've added validation for the email and password fields...

---
```

## Requirements

- Git repository
- Claude Code
- `jq` (recommended for merging with existing Claude settings)
- Bash

## How it works

pass-the-vibe uses Claude Code's [hooks system](https://code.claude.com/docs/en/hooks):

- **UserPromptSubmit**: Captures and logs user prompts
- **Stop**: Captures and logs Claude's responses

The hooks are configured in `.claude/settings.local.json` and run automatically during Claude Code sessions.

## License

MIT
