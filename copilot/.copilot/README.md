# ~/.copilot (personal, global)

GitHub Copilot CLI settings that apply to every project on this machine. The files here come from the `copilot` package in `~/dotfiles` (GNU Stow), so edit them in `~/dotfiles/copilot/.copilot/`, not through the links.

This is the Copilot equivalent of `~/.claude`. Both tools share one set of personal rules and one set of skills, so there is nothing to keep in step by hand.

## What is here

| Path | What it is | Source |
| ---- | ---------- | ------ |
| `copilot-instructions.md` | Personal rules loaded in every session. It is a link to `claude/.claude/CLAUDE.md`, so Claude Code and Copilot read the same file. Edit `CLAUDE.md`. | Link to dotfiles (which links to the Claude file) |
| `statusline.sh` | Copilot's own status line: `🤖 model · effort  🧠 context %  💳 session AIC  🔖 session name  📁 folder  🌿 branch +added -deleted ⇡ahead ⇣behind  v<version>  ⚡ allow-all`. Reads Copilot's session JSON (`model.display_name`, `context_window.used_percentage`, `ai_used`, `session_name`, `version`, `allow_all_enabled`, `cwd`); git items come from git. Items with no value are skipped. No budget or dollar cost. Set `STATUSLINE_DEBUG=<file>` to dump the JSON it receives. | Link to dotfiles |
| `README.md` | This file. | Link to dotfiles |
| `settings.json` | Machine settings. Not tracked in dotfiles, because the CLI rewrites it and would replace the link. | Local |
| everything else | Copilot's own state (`config.json`, sessions, logs, MCP config, plugins). Not tracked. | Local |

## Skills

Skills are not copied here. Copilot reads the Claude skills folder directly through this line in `~/.copilot/settings.json`:

```json
"skillDirectories": ["~/.claude/skills"]
```

Add new skills in `~/dotfiles/claude/.claude/skills/<name>/` as usual; both tools pick them up. Check with `copilot skill list`.

## Settings to recreate on a new machine

`settings.json` is local, so set these by hand (or with `/settings`) after stowing:

| Setting | Value | Why |
| ------- | ----- | --- |
| `skillDirectories` | `["~/.claude/skills"]` | Share the Claude skills. |
| `defaultPermissionMode` | `"allow-all"` | Run commands without asking, as in Claude. |
| `sandbox.enabled` | `true`, with `addCurrentWorkingDirectory: true` | Run commands in a sandbox; network left open. |
| `sandbox.userPolicy.filesystem.deniedPaths` | `.env`, `~/.netrc`, `~/.aws`, `~/.ssh`, `~/.npmrc` | Block secrets from shell commands. |
| `statusLine` | `{"type": "command", "command": "~/.copilot/statusline.sh", "padding": 0}` | Copilot's own status line (not the Claude one). |
| `notifications` | `true` | Desktop notifications. |
| `model` | `"claude-sonnet-5.5"` | Default model. |

Check the instructions are loaded with `copilot instruction list` (look for "Personal instructions").
