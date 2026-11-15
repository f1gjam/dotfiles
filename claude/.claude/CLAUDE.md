# Personal rules

## Google Drive

- To sync, upload, overwrite, pull or compare any local file with Google Drive, use the `gdrive-sync` skill. Do not upload to Drive by other means.
- Never upload, overwrite, pin a revision or change anything on Drive without asking the user first, every time.
- Never change sharing on a Drive file, never delete Drive files, comments or revisions, and never create a new file to replace an existing one (it breaks the link and sharing).
- Before overwriting a Drive file, check it has not changed since the last download, and save comments, permissions and a copy of the current content locally. The skill describes this routine.
- Keep backups in a `drive-sync-backups/` folder beside the document, not in `$TMPDIR` (it is cleared on reboot).
- Never print or store gcloud access tokens.

## Markdown that goes to Google

- When writing or editing any Markdown that will be uploaded to or shared through Google Drive, follow the `gdoc-markdown-compat` skill.
- Short version: no raw HTML, no colour or underline, no `==highlight==`, no relative image links. Embed images as reference-style base64 (`![alt][image1]` with definitions at the end of the file). Mark warnings as `### ***TEXT***` (or `***TEXT***` in table cells).
- Keep full-resolution PNG masters next to the document. Never round-trip images through Google, because it downscales them.
- Run the lint checks in the skill before any upload.

## Facts and accuracy

- Never invent facts, owners, numbers or dates. If something isn't known, say so or ask.
- Turn relative dates ("next Friday", "last week") into absolute dates.
- When sources give conflicting facts and you can't tell which is right, ask rather than picking one.

## Text to paste elsewhere

- Text the user will paste somewhere else (Slack, review tools, emails, ticket comments) goes in one fenced code block, so `/copy` picks it up in one go.

## Engineering principles

- Think before coding: understand the problem and the existing code first, and state assumptions.
- Simplicity first: the simplest solution that works. No speculative features or abstractions.
- Surgical changes: touch only what the task needs. Don't reformat or refactor unrelated code.
- Goal-driven: know what "done" looks like and check it (run it, test it) before saying it works.
- No sprawling hacks: if a fix needs workarounds piling up, stop and rethink, or ask.

## Diagrams

- Graphviz diagrams are delivered as `.dot` and `.png` only. No SVG unless asked.

## Work rules

- Company (CIH) rules, including the DBX connectivity status update, live in `~/Dropbox/CIH/CLAUDE.md` and skills in `~/Dropbox/CIH/.claude/skills/`, not in this file.
