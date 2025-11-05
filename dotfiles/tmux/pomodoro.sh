#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.cache/pomo.json"
mkdir -p "$(dirname "$STATE_FILE")"

if [ $# -eq 3 ]; then
  SESSIONS=$1
  WORK_MIN=$2
  BREAK_MIN=$3

  jq -n \
    --argjson sessions "$SESSIONS" \
    --argjson work "$((WORK_MIN * 60))" \
    --argjson break "$((BREAK_MIN * 60))" \
    --argjson current 1 \
    --arg mode "work" \
    --argjson start "$(date +%s)" \
    '{
      sessions: $sessions,
      work: $work,
      break: $break,
      current: $current,
      mode: $mode,
      start: $start
    }' > "$STATE_FILE"

  tmux display-message "👨‍💻 Started $SESSIONS sessions ($WORK_MIN/$BREAK_MIN min)"
  exit 0
fi

if [ "${1:-}" = "stop" ]; then
  rm -f "$STATE_FILE"
  tmux display-message "Pomodoro stopped"
  exit 0
fi

if [ ! -f "$STATE_FILE" ]; then
  echo ""
  exit 0
fi

mode=$(jq -r .mode "$STATE_FILE")
start=$(jq -r .start "$STATE_FILE")
sessions=$(jq -r .sessions "$STATE_FILE")
current=$(jq -r .current "$STATE_FILE")
duration=$(jq -r ".\"$mode\"" "$STATE_FILE")  # fix: access key safely

now=$(date +%s)
remaining=$((start + duration - now))


if [ "$remaining" -le 0 ]; then
  if [ "$mode" = "work" ]; then
    jq --arg mode "break" \
       --argjson start "$(date +%s)" \
       '.mode=$mode | .start=$start' \
       "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    tmux display-message "☕ Break #$current started"
  else
    next=$((current + 1))
    if [ "$next" -gt "$sessions" ]; then
      tmux display-message "✅ All sessions done!"
      rm -f "$STATE_FILE"
      echo ""
      exit 0
    fi
    jq --arg mode "work" \
       --argjson start "$(date +%s)" \
       --argjson current "$next" \
       '.mode=$mode | .start=$start | .current=$current' \
       "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    tmux display-message "👨‍💻 Work #$next started"
  fi
  echo ""
  exit 0
fi

m=$((remaining / 60))
s=$((remaining % 60))
icon=$([ "$mode" = "work" ] && echo "👨‍💻" || echo "☕")

printf "%s %d/%d %02d:%02d" "$icon" "$current" "$sessions" "$m" "$s"

