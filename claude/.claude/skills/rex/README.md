# rex

Lets Claude drive the Rex terminal app through its `rex` CLI: manage sessions, open tabs, arrange panes, run commands, read terminal output and control connected Rex apps.

**Run it:** ask Claude to do something in Rex, for example "open a new tab and run the tests" or "show me the output of the other pane".

**What it does:** `SKILL.md` is a small stub. It tells Claude to run `rex __internal skill --feature-session-naming=false` and follow the guide that command prints. The guide comes from the installed Rex version, so it always matches the commands that version has. If that command fails (an older Rex), Claude falls back to `rex whoami --json`, `rex --help` and `rex COMMAND --help`.

**Inputs:** your request. No files.

**Needs:**

- The `rex` CLI installed (it ships with the Rex app). Check with `rex --version`. At the time of writing it was not on this machine's PATH.
- A running Rex app that the CLI can connect to. Check with `rex whoami --json`.

**Writes:** nothing itself. The Rex commands Claude runs can open tabs, change panes and run commands in your terminal sessions.

**Config:** Rex's own settings (`~/.config/rex/init.lua`, key bindings) are in the separate `rex` package in `~/dotfiles`, not in this skill. Stow it with `stow -v rex`.

**Managed by Rex:** `SKILL.md` was installed by `rex skill setup`. Rex can rewrite it on update, and `rex skill remove` deletes it. Do not hand-edit it; edit this README instead.

| File | Purpose |
| ---- | ------- |
| `SKILL.md` | The stub Claude follows (written by Rex). |
| `README.md` | This file. |
