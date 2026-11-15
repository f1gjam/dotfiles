# gdrive-sync

Safely syncs a local file with an **existing** Google Drive file, in either direction.

**Run it:** ask to upload, push, sync, overwrite, pull, download or compare a local file with Drive.

**What it does:**

- Push: checks the Drive copy has not changed since the last sync, saves its comments, permissions and current content to `drive-sync-backups/` beside the document, shows you what will change, and uploads only after you say yes. The file ID and sharing stay the same.
- Pull: downloads the Drive copy, asking first if the local file has unsynced edits.
- Compare: downloads to `drive-sync-backups/` and diffs. Changes nothing.

**State:** a sidecar `<doc>.drive.json` next to each document records the file ID and the last-synced versions.

**Never:** changes sharing, deletes Drive files, comments or revisions, replaces a file with a new one, or prints access tokens. Native Google Docs, Sheets and Slides are out of scope.

Markdown files are checked with `gdoc-markdown-compat` first.
