#!/bin/bash
# Copilot CLI status line:
#   🤖 model · effort  🧠 context %  💳 session AIC  🔖 session name  📁 folder  🌿 branch +a -d ⇡n ⇣n  v<version>  ⚡ allow-all
# Copilot passes session JSON on stdin. Items with no value are skipped.
# Set STATUSLINE_DEBUG=<file> to dump the JSON received.
input=$(cat)
[ -n "$STATUSLINE_DEBUG" ] && echo "$input" > "$STATUSLINE_DEBUG"

j() { echo "$input" | jq -r "$1 // empty" 2>/dev/null; }

MODEL=$(j '.model.display_name // .model.id')
DIR=$(j '.workspace.current_dir // .cwd')
PCT=$(j '.context_window.used_percentage')
AI_USED=$(j '.ai_used | if type=="object" then (.aic // .credits // .total // empty) else . end')
SESSION=$(j '.session_name')
VERSION=$(j '.version')
ALLOW_ALL=$(j '.allow_all_enabled')

OUT="\033[36m🤖 $MODEL\033[0m"

if [ -n "$PCT" ]; then
  PCT=$(printf '%.0f' "$PCT")
  if [ "$PCT" -le 50 ]; then C=32; elif [ "$PCT" -le 75 ]; then C=33; else C=31; fi
  OUT="$OUT \033[${C}m🧠 ${PCT}%\033[0m"
fi

[ -n "$AI_USED" ] && OUT="$OUT \033[33m💳 $(printf '%.2f' "$AI_USED") AIC\033[0m"
[ -n "$SESSION" ] && OUT="$OUT \033[35m🔖 $SESSION\033[0m"
OUT="$OUT \033[37m📁 $(basename "$DIR")\033[0m"

if [ -n "$DIR" ] && git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  [ -n "$BRANCH" ] && OUT="$OUT \033[32m🌿 $BRANCH\033[0m"

  ADDED=0; DELETED=0
  while IFS=$'\t' read -r a d _; do
    [[ "$a" =~ ^[0-9]+$ ]] && ADDED=$((ADDED + a))
    [[ "$d" =~ ^[0-9]+$ ]] && DELETED=$((DELETED + d))
  done < <(git -C "$DIR" diff HEAD --numstat 2>/dev/null)
  [ "$ADDED" -gt 0 ] && OUT="$OUT \033[32m+${ADDED}\033[0m"
  [ "$DELETED" -gt 0 ] && OUT="$OUT \033[31m-${DELETED}\033[0m"

  if COUNTS=$(git -C "$DIR" rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null); then
    read -r AHEAD BEHIND <<<"$COUNTS"
    [ "$AHEAD" -gt 0 ] && OUT="$OUT \033[36m⇡${AHEAD}\033[0m"
    [ "$BEHIND" -gt 0 ] && OUT="$OUT \033[33m⇣${BEHIND}\033[0m"
  fi
fi

[ -n "$VERSION" ] && OUT="$OUT \033[90mv${VERSION}\033[0m"
[ "$ALLOW_ALL" = "true" ] && OUT="$OUT \033[31m⚡ allow-all\033[0m"

echo -e "$OUT"
