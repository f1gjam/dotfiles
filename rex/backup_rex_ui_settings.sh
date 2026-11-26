#!/bin/bash
# Back up Rex app preferences to a timestamped file in ~/dotfiles/rex/backups/.
# Restore with restore_rex_ui_settings.sh. See README.md in this folder.
set -euo pipefail

DOMAIN="com.superlogical.rex"
HISTORY_DIR="$HOME/dotfiles/rex/backups"
DEST="$HISTORY_DIR/preferences-$(date +%Y%m%d-%H%M%S).plist"

# Machine-specific or constantly changing keys. Leaving them out keeps git diffs
# small and stops a restore bringing back a stale server route or focus state.
VOLATILE_KEYS=(
  "rex.local-server.cached-route.v1"
  "Workspace.programActivitySeen"
  "Workspace.lastFocusedSession"
  "SULastCheckTime"
)

if ! defaults read "$DOMAIN" >/dev/null 2>&1; then
  echo "No preferences found for $DOMAIN. Has Rex been run on this machine?" >&2
  exit 1
fi

# Export to a temp file and move it into place only on success, so a failed
# export never leaves a truncated backup.
TMP="$(mktemp "${TMPDIR:-/tmp}/rex-prefs.XXXXXX")"
trap 'rm -f "$TMP"' EXIT

defaults export "$DOMAIN" "$TMP"

for key in "${VOLATILE_KEYS[@]}"; do
  # PlistBuddy, not plutil: plutil reads the dots in these key names as paths
  /usr/libexec/PlistBuddy -c "Delete :$key" "$TMP" 2>/dev/null || true
done

plutil -lint "$TMP" >/dev/null

LATEST="$(ls "$HISTORY_DIR"/preferences-*.plist 2>/dev/null | tail -n 1 || true)"
if [ -n "$LATEST" ] && cmp -s "$TMP" "$LATEST"; then
  echo "No changes since $LATEST."
  exit 0
fi

mkdir -p "$HISTORY_DIR"
mv "$TMP" "$DEST"
trap - EXIT
echo "Saved $DEST"
