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
- Do not put the user's name, email, project or file contents into any request except to Google's own Drive API for the file they named.
- Report outcomes faithfully. If a check fails or was skipped, say so.

## Environment notes

- Shell state does not persist between Bash calls: redefine the variables in every call.
- `gcloud` writes to `~/.config/gcloud`, which the sandbox blocks. Run gcloud-using commands with `dangerouslyDisableSandbox: true` and tell the user why. Mention `/sandbox` if relevant.
- Needs Drive scope. If a call returns `ACCESS_TOKEN_SCOPE_INSUFFICIENT`, tell the user to run `! gcloud auth login --enable-gdrive-access`. If `Reauthentication failed`, tell them to run `! gcloud auth login`. If the organisation blocks the scope, say so and offer manual export/paste instead; do not hunt for other credentials.
- Billing/quota project: use the user's active one (`gcloud config get-value project`), do not hardcode.

Common preamble (repeat in each call):

```bash
ID=<fileId>
TOKEN=$(gcloud auth print-access-token 2>/dev/null)
PROJECT=$(gcloud config get-value project 2>/dev/null)
H=(-H "Authorization: Bearer $TOKEN" -H "x-goog-user-project: $PROJECT")
API="https://www.googleapis.com/drive/v3/files/$ID"
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
curl -s "${H[@]}" "$API?fields=id,name,mimeType,version,md5Checksum,modifiedTime,size,shared,capabilities(canEdit)&supportsAllDrives=true"
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
- **Content:** download of the current Drive file: `curl -s "${H[@]}" "$API?alt=media&supportsAllDrives=true" -o ...` and confirm its md5 matches Drive's.
- **Comments:** paginate until no `nextPageToken`:
  `$API/comments?fields=nextPageToken,comments(id,author(displayName,emailAddress),content,createdTime,resolved,deleted,anchor,quotedFileContent(value),replies(author(displayName),content,createdTime,deleted))&includeDeleted=true&pageSize=100`
- **Permissions:** `$API/permissions?fields=permissions(id,type,role,emailAddress,domain,allowFileDiscovery)&supportsAllDrives=true`
- **Revisions:** `$API/revisions?fields=revisions(id,modifiedTime,keepForever,size)`

### 5. Ask before uploading
Use AskUserQuestion. Show, in the question text: local file, size and md5; Drive name, current version and size; what changed vs the last synced version (short diff summary); number of open and resolved comments (from the snapshot); who has access (from the snapshot, names only as needed). Options: **Upload now**, **Show full diff first**, **Cancel**.

If there are existing comments, warn that for uploaded files Drive may keep a comment but lose its highlighted anchor, and that the snapshot has the full text. Do not claim comments will definitely survive.

Also ask, as a separate question, whether to pin the current Drive revision (`keepForever`) before overwriting, because unpinned revisions can be deleted after about 30 days. Pin only if they say yes:
`curl -s -X PATCH "${H[@]}" -H "Content-Type: application/json" -d '{"keepForever":true}' "$API/revisions/<revisionId>"`

### 6. Upload (only after yes)
```bash
curl -s -X PATCH "${H[@]}" -H "Content-Type: <existing mimeType>" \
  --data-binary @"<local file>" \
  "https://www.googleapis.com/upload/drive/v3/files/$ID?uploadType=media&supportsAllDrives=true&fields=id,name,version,md5Checksum,size"
```
- Use the file's existing `mimeType`. Do not send a metadata body, so the name and parents stay unchanged.
- Files over about 5 MB: use `uploadType=resumable` instead.

### 7. Verify
- New Drive `md5Checksum` equals the local md5. If not, report a failed sync and do not update the sidecar.
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
