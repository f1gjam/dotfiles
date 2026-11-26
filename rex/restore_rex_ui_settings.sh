#!/bin/bash
# Restore Rex app preferences from the plist file given as the only argument.
# Usage: restore_rex_ui_settings.sh FILE   (e.g. backups/preferences-YYYYMMDD-HHMMSS.plist)
# Run it from a terminal other than Rex: it quits Rex, which would kill this script.
set -euo pipefail

DOMAIN="com.superlogical.rex"
if [ $# -ne 1 ]; then
  echo "Usage: $0 FILE" >&2
  echo "Available backups:" >&2
  ls "$HOME/dotfiles/rex/backups/" 2>/dev/null | sed 's/^/  /' >&2 || true
  exit 1
fi
SRC="$1"
PRE="$HOME/rex-pre-restore-$(date +%Y%m%d-%H%M%S).plist"

if [ -n "${REX_BLOCK:-}" ]; then
  echo "Running inside Rex. Quitting Rex would stop this script. Use another terminal." >&2
  exit 1
fi

if [ ! -f "$SRC" ]; then
  echo "Backup not found: $SRC" >&2
  exit 1
fi
plutil -lint "$SRC" >/dev/null

# Keep a copy of the current preferences first (skipped if Rex has none yet)
if defaults export "$DOMAIN" "$PRE" 2>/dev/null; then
  echo "Current preferences saved to $PRE"
fi

# Rex caches preferences while running, so quit it before importing
osascript -e 'quit app "Rex"' || true
sleep 2

defaults import "$DOMAIN" "$SRC"
echo "Imported $SRC"

open -a Rex
echo "Rex restarted. Check with: defaults export $DOMAIN -"
