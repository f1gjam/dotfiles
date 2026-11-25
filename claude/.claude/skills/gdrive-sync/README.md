# gdrive-sync

Safely syncs a local file with an **existing** Google Drive file, in either direction.

**Run it:** ask to upload, push, sync, overwrite, pull, download or compare a local file with Drive.

**What it does:**

- Push: checks the Drive copy has not changed since the last sync, saves its comments, permissions and current content to `drive-sync-backups/` beside the document, shows you what will change, and uploads only after you say yes. The file ID and sharing stay the same.
- Pull: downloads the Drive copy, asking first if the local file has unsynced edits.
- Compare: downloads to `drive-sync-backups/` and diffs. Changes nothing.

**Needs (install once):**

- **Google Workspace CLI:** `brew install googleworkspace-cli`. This puts `gws` on your PATH. Check with `gws --version`, which should print `gws 0.22` or later. Homebrew also has an unrelated formula called `gws` (git workspaces) that conflicts with it. If `gws` prints "Not in a workspace", it is the wrong one: run `brew uninstall gws`, then install the Google one.
- **Google Cloud SDK (`gcloud`):** install from https://cloud.google.com/sdk/docs/install, then run `gcloud auth login --enable-gdrive-access`. `gws` uses the `gcloud` token, passed inline in each command.
- **Python 3, `diff` and `md5`:** already on macOS and Homebrew. Python 3 is used for the sidecar file and `diff` for the conflict check.
- **Not needed:** `curl`, a `gws-auth` shell function, or anything in `~/.bashrc`.
- `gws` and `gcloud` write under `~/.config`, so Claude runs them outside the sandbox.

**State:** a sidecar `<doc>.drive.json` next to each document records the file ID and the last-synced versions.

**Never:** changes sharing, deletes Drive files, comments or revisions, replaces a file with a new one, or prints access tokens. Native Google Docs, Sheets and Slides are out of scope.

Markdown files are checked with `gdoc-markdown-compat` first.
