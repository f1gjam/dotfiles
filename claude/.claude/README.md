# ~/.claude (personal, global)

Claude Code settings that apply to every project on this machine. The files here come from the `claude` package in `~/dotfiles` (GNU Stow), so edit them in `~/dotfiles/claude/.claude/`, not through the links.

## What is here

| Path | What it is | Source |
| ---- | ---------- | ------ |
| `CLAUDE.md` | Personal rules loaded in every session: Google Drive safety, Markdown for Google, facts and accuracy, text to paste elsewhere, engineering principles, skills and their docs (every skill has a README, kept in step with CLAUDE.md and READMEs), diagrams. | Link to dotfiles |
| `skills/` | Personal skills available everywhere (table below). | One link to `~/dotfiles/claude/.claude/skills/` |
| `README.md` | This file. | Link to dotfiles |
| `settings.json` | Machine settings. Not tracked in dotfiles. | Local |
| everything else | Claude Code's own state (history, projects, plugins, caches). Not tracked. | Local |

## Global skills

Each skill folder has its own `README.md`.

| Skill | What it does | Writes anywhere? |
| ----- | ------------ | ---------------- |
| [`gdrive-sync`](skills/gdrive-sync/README.md) | Push, pull or compare a local file with an existing Google Drive file, with conflict checks and backups. | Drive, only after you say yes |
| [`gdoc-markdown-compat`](skills/gdoc-markdown-compat/README.md) | Rules and lint checks for Markdown that must look right in Google Docs. | No |
| [`jira-reply-tracker`](skills/jira-reply-tracker/README.md) | Finds Jira tickets where someone is waiting on your reply. | No (read-only) |

## Shared with GitHub Copilot CLI

The `copilot` package links `~/.copilot/copilot-instructions.md` to this `CLAUDE.md`, and Copilot's `settings.json` lists `~/.claude/skills` in `skillDirectories`. So Copilot uses the same rules and skills: write them so they make sense in both tools. See `~/.copilot/README.md`.

## Company-specific rules and skills

Nothing company-specific belongs in this directory. Company rules and skills are kept outside it, in the company's own folders.

## Adding a skill

Create `~/dotfiles/claude/.claude/skills/<name>/SKILL.md` and a `README.md`. Because `skills/` is one link, it appears at once; no restow needed. New files directly under `claude/.claude/` need `stow -R claude`.
