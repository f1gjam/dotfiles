# Rex preferences backup

Backs up and restores the preferences of the Rex terminal app (bundle ID `com.superlogical.rex`).

## Files

| File | Purpose |
| ---- | ------- |
| `backup_rex_ui_settings.sh` | Exports the current Rex preferences to a new timestamped file in `backups/` |
| `restore_rex_ui_settings.sh` | Restores Rex preferences from the plist file you name (required) |
| `backups/` | Timestamped history, `preferences-YYYYMMDD-HHMMSS.plist` |

## Needs

- Nothing to install. `defaults`, `osascript` and `open` come with macOS.
- Check: `defaults read com.superlogical.rex > /dev/null && echo OK` (prints `OK` once Rex has been run at least once).
- The repo must be at `~/dotfiles`. The script writes to `~/dotfiles/rex/backups/`.

## Back up

Run the script. It writes the current preferences to a new timestamped file and never overwrites an old one:

```bash
bash ~/dotfiles/rex/backup_rex_ui_settings.sh
```

It is safe to run while Rex is open. What it does:

- Exports the preferences with `defaults export` to a temp file, and only moves it into `backups/` if that succeeds, so a failed export never leaves a broken backup.
- Strips four keys that change constantly or are specific to this machine, so git diffs stay small and a restore does not bring back stale state: `rex.local-server.cached-route.v1`, `Workspace.programActivitySeen`, `Workspace.lastFocusedSession` and `SULastCheckTime`. To change the list, edit `VOLATILE_KEYS` in the script.
- Checks the result is a valid plist.
- Saves `backups/preferences-YYYYMMDD-HHMMSS.plist`.
- Prints `No changes` and writes nothing if nothing differs from the newest file in `backups/`.
- Stops with a message if Rex has no preferences on this machine yet.

Then commit the change:

```bash
cd ~/dotfiles
git add rex/backups
git commit -m "updated rex preferences"
```

## Restore

**Run every restore step from a terminal that is not inside Rex**, such as the macOS Terminal app (or Ghostty). Restoring quits Rex, which closes the terminal panes running inside it and would stop the restore halfway. The script refuses to run inside Rex. The manual steps below have no such check, so the same rule applies. Backing up does not need this: it only reads the preferences, so it is safe to run from inside Rex.

### Script

It restores only the file you give it and has no default. Run it with no argument to see usage and the list of available backups. It saves the current preferences to `~/rex-pre-restore-<timestamp>.plist`, quits Rex, runs `defaults import`, then restarts Rex:

```bash
bash ~/dotfiles/rex/restore_rex_ui_settings.sh ~/dotfiles/rex/backups/preferences-20261126-141845.plist
```

### Manual steps

The same thing by hand, from a terminal outside Rex (see above). Rex may cache preferences while it runs, so always quit it before restoring.

### 1. Save the current preferences first

```bash
defaults export com.superlogical.rex ~/rex-pre-restore-$(date +%Y%m%d-%H%M%S).plist
```

### 2. Quit Rex

```bash
osascript -e 'quit app "Rex"'
```

### 3. Import the backup (preferred method)

```bash
defaults import com.superlogical.rex ~/dotfiles/rex/backups/preferences-YYYYMMDD-HHMMSS.plist
```

### 4. Start Rex

```bash
open -a Rex
```

### 5. Verify

This prints the current preferences to the terminal:

```bash
defaults export com.superlogical.rex -
```

## Fallback: copy the plist file

Use this only if the `defaults import` method does not work. It restores the exact plist snapshot instead of going through `defaults`. macOS manages preference files through its preferences subsystem, so replacing the file directly is a fallback, not the normal method.

```bash
osascript -e 'quit app "Rex"'

cp ~/dotfiles/rex/backups/preferences-YYYYMMDD-HHMMSS.plist \
  ~/Library/Preferences/com.superlogical.rex.plist

open -a Rex
```

## Writes

- The restore script overwrites the live Rex preferences and writes a pre-restore copy to `~/`.
- The backup script writes only one new file in `~/dotfiles/rex/backups/`. Old files in `backups/` are never deleted.
