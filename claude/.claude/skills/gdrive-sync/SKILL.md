---
name: gdrive-sync
description: Safely sync a local file (markdown, text, csv, pdf, etc.) to an existing Google Drive file, or pull the Drive copy down. Use whenever the user asks to upload, push, sync, overwrite, update, download or compare a local doc with Google Drive. Checks the Drive version for conflicts, snapshots comments, permissions and revisions, asks before any upload, and keeps the file ID and sharing unchanged.
---

# gdrive-sync

Sync a local file with an **existing** Google Drive file without losing other people's changes, comments or sharing. Generic: works for any Drive file ID, not one specific document.

Scope: **uploaded files** (`.md`, `.txt`, `.csv`, `.pdf`, ...). Native Google Docs, Sheets and Slides (`mimeType` starting `application/vnd.google-apps.`) are out of scope: refuse and explain, because an upload would not replace their content the same way.

## Ground rules

- **Never upload, overwrite, pin a revision, or change anything on Drive without an explicit yes** from the user in this turn, via AskUserQuestion. Approval for one sync does not cover the next.
- **Never change sharing.** No permission create/update/delete calls, ever. Never delete files, comments or revisions.
- **Always update the existing file ID** (PATCH). Never create a new file to "replace" one: that changes the link and loses sharing.
- **Never print the access token** or put it in a file. Keep it inside the command.
- **Use the `gws` CLI (googleworkspace-cli) for every Drive call. Do not use `curl`.** Do not use `gws drive +upload`: it is a helper that sets metadata (name, parents). Use `gws drive files update --upload` only.
- Do not put the user's name, email, project or file contents into any request except to Google's own Drive API for the file they named.
- Report outcomes faithfully. If a check fails or was skipped, say so.

## Environment notes

- Shell state does not persist between Bash calls: redefine the variables in every call.
- Needs the Google Workspace CLI: `command -v gws` must work and `gws --version` must start `gws 0.` from googleworkspace-cli (https://github.com/googleworkspace/cli). A different `gws` exists (a git-workspace tool in Homebrew, whose output is "Not in a workspace"): if you see that, stop and tell the user.
- `gws` and `gcloud` write under `~/.config`, which the sandbox blocks (`discoveryError: Operation not permitted`). Run gws/gcloud commands with `dangerouslyDisableSandbox: true` and tell the user why. Mention `/sandbox` if relevant.
- Auth: `gws` takes the `gcloud` access token from `GOOGLE_WORKSPACE_CLI_TOKEN`. Set it inline in every call (see preamble); there is no `gws-auth` function to rely on.
- `GOOGLE_APPLICATION_CREDENTIALS=/dev/null` stops `gws` reading a quota project from ADC, which causes "API not enabled" errors. Keep it. It replaces the old quota-project header.
- Needs Drive scope. If a call returns `ACCESS_TOKEN_SCOPE_INSUFFICIENT`, tell the user to run `! gcloud auth login --enable-gdrive-access`. If `Reauthentication failed`, tell them to run `! gcloud auth login`. If the organisation blocks the scope, say so and offer manual export/paste instead; do not hunt for other credentials.
- Always pass `"supportsAllDrives": true` in `--params` where the method accepts it, or Shared Drive files return 404. `comments list` and `revisions list` have no such parameter and must not get it.
- `gws` prints `Using keyring backend: keyring` before its JSON. Strip any line before the first `{` when saving JSON, or send stderr to `/dev/null` when the call succeeded.
- `--dry-run` validates a call locally and sends nothing. Use it to check the URL and method before any write.
- `--page-all` prints one JSON line per page (NDJSON) and stops at 10 pages by default: pass `--page-limit 100` and save as `.ndjson`.

Common preamble (repeat in each call):

```bash
ID=<fileId>
export GOOGLE_WORKSPACE_CLI_TOKEN=$(gcloud auth print-access-token 2>/dev/null)
export GOOGLE_APPLICATION_CREDENTIALS=/dev/null
```

## State: sidecar file per document

For each local doc keep `<doc>.drive.json` next to it (syncs with Dropbox):

```json
{
  "fileId": "...",
  "name": "...",
  "mimeType": "text/markdown",
  "version": "47",
  "md5Checksum": "...",
  "modifiedTime": "...",
  "syncedAt": "2026-11-11T13:38:22Z",
  "localMd5AtSync": "..."
}
```

`md5Checksum` is the Drive content hash **as of the last download or upload**. It is the baseline for conflict detection. Write it with `python3 -I` (no jq dependency). Backups go in `drive-sync-backups/` beside the doc (create if missing), never only in `$TMPDIR` (it is cleared on reboot).

## Push (local -> Drive)

### 1. Identify
- Local file path. File ID from the user's Drive URL (`/d/<id>/`) or the sidecar.
- No sidecar and no ID: ask the user for the Drive link. Do not guess from filenames.

### 2. Preflight (read only)
```bash
gws drive files get --params "{\"fileId\":\"$ID\",\"supportsAllDrives\":true,\"fields\":\"id,name,mimeType,version,md5Checksum,modifiedTime,size,shared,capabilities(canEdit)\"}"
```
- Stop if `mimeType` starts with `application/vnd.google-apps.` (native Google file).
- Stop if `capabilities.canEdit` is false.
- Show the user: Drive name, version, modified time, size.

### 3. Conflict check
Compare Drive `md5Checksum` with the sidecar's `md5Checksum`.
- **Equal:** nobody changed Drive since the last sync. Continue.
- **Different, or no sidecar baseline:** **STOP. Do not upload.** Download the current Drive copy to `drive-sync-backups/<doc>.drive-v<version>.<ext>`, diff it against the local file (normalise whitespace for text), summarise the differences, and ask the user how to proceed: keep Drive's, keep local, or merge specific changes. Only continue after the agreed merge is written locally and the baseline is refreshed to the Drive version just downloaded.

### 4. Snapshot (read only, saved locally before touching Drive)
Save to `drive-sync-backups/`, timestamped (`<doc>.<YYYYMMDD-HHMMSS>.*`):
- **Content:** download of the current Drive file, then confirm its md5 matches Drive's `md5Checksum`:
  `gws drive files get --params "{\"fileId\":\"$ID\",\"alt\":\"media\",\"supportsAllDrives\":true}" -o <backup path>`
- **Comments:** `--page-all` follows `nextPageToken` for you (NDJSON, one page per line; save as `.ndjson`):
  `gws drive comments list --page-all --page-limit 100 --params "{\"fileId\":\"$ID\",\"includeDeleted\":true,\"pageSize\":100,\"fields\":\"nextPageToken,comments(id,author(displayName,emailAddress),content,createdTime,resolved,deleted,anchor,quotedFileContent(value),replies(author(displayName),content,createdTime,deleted))\"}"`
- **Permissions:** `gws drive permissions list --params "{\"fileId\":\"$ID\",\"supportsAllDrives\":true,\"fields\":\"permissions(id,type,role,emailAddress,domain,allowFileDiscovery)\"}"`
- **Revisions:** `gws drive revisions list --params "{\"fileId\":\"$ID\",\"fields\":\"revisions(id,modifiedTime,keepForever,size)\"}"`

### 5. Ask before uploading
Use AskUserQuestion. Show, in the question text: local file, size and md5; Drive name, current version and size; what changed vs the last synced version (short diff summary); number of open and resolved comments (from the snapshot); who has access (from the snapshot, names only as needed). Options: **Upload now**, **Show full diff first**, **Cancel**.

If there are existing comments, warn that for uploaded files Drive may keep a comment but lose its highlighted anchor, and that the snapshot has the full text. Do not claim comments will definitely survive.

Also ask, as a separate question, whether to pin the current Drive revision (`keepForever`) before overwriting, because unpinned revisions can be deleted after about 30 days. Pin only if they say yes:
`gws drive revisions update --params "{\"fileId\":\"$ID\",\"revisionId\":\"<revisionId>\"}" --json '{"keepForever":true}'`

### 6. Upload (only after yes)
```bash
gws drive files update \
  --params "{\"fileId\":\"$ID\",\"supportsAllDrives\":true,\"fields\":\"id,name,version,md5Checksum,size\"}" \
  --upload "<local file>" --upload-content-type "<existing mimeType>"
```
- Run the same command with `--dry-run` first. It must show `PATCH` on `.../upload/drive/v3/files/<the file ID>`, `"body": null` and `is_multipart_upload: true`. Anything else: stop.
- Always pass `--upload-content-type` with the file's existing `mimeType` (do not let `gws` guess from the extension). Do not pass `--json`, so the name and parents stay unchanged.
- Verify in step 7 that the returned `name` equals the name from the preflight.
- Large files: `gws` handles the upload itself. If a big upload fails, report it and check Drive's version before retrying.

### 7. Verify
- New Drive `md5Checksum` equals the local md5. If not, report a failed sync and do not update the sidecar.
- Returned `name` equals the preflight name (the upload must not rename the file). If it changed, report it loudly.
- Permissions list is identical to the snapshot (diff the JSON). Report any difference loudly.
- Comment count is unchanged versus the snapshot. If any comment was lost or orphaned, say so and point at the saved snapshot.
- Write the sidecar with the new version, md5, modifiedTime, syncedAt and local md5.

### 8. Report
Give: file link (`https://drive.google.com/file/d/<id>/view`), old and new version, checksum match, sharing unchanged (list roles), comment result, where backups are. Say what was **not** checked (for example how Drive's viewer renders the file).

## Pull (Drive -> local)

1. Preflight and conflict logic as above, but the direction is reversed: if the local file differs from the sidecar's `localMd5AtSync`, local has unsynced edits, so **ask before overwriting** the local file.
2. Download to the target path (or `<doc>.drive.<ext>` beside it if the user wants to compare first). Confirm the md5 equals Drive's.
3. Update the sidecar baseline. Back up any local file that would be replaced into `drive-sync-backups/` first.

## Compare only

Download to `drive-sync-backups/`, normalise, and diff. Make no changes to Drive or the local file. If the files are Markdown, apply the gdoc-markdown-compat skill's normalisation notes before judging which differences are real.

## Things that will go wrong

- **Version changed under you:** handled by step 3. Never skip it, even if the user is in a hurry.
- **Token scope or login expiry:** see Environment notes.
- **Large embedded images:** a Markdown file with base64 images can be over 1 MB. Fine for simple upload, but do not print or Read it whole: strip data URIs before viewing (`sed -E 's/^\[image[0-9]+\]: <data:[^>]*>.*$/[embedded image removed]/'`).
- **Comments on a different copy:** if someone opens an uploaded `.md` in Google Docs, that creates a separate copy. Comments there are not on this file.
