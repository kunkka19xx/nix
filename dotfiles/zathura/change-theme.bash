#!/usr/bin/env bash

THEME_DIR="$HOME/.config/zathura/themes"
LINK_PATH="$HOME/.config/zathura/zathurarc"

themes=($(basename -s .theme "$THEME_DIR"/*.theme))

if [ ! -f "$LINK_PATH" ]; then
  current=""
else
  current=$(readlink "$LINK_PATH" | xargs basename -s .theme)
fi

next=""
for i in "${!themes[@]}"; do
  if [[ "${themes[$i]}" == "$current" ]]; then
    next_index=$(( (i + 1) % ${#themes[@]} ))
    next="${themes[$next_index]}"
    break
  fi
done

if [ -z "$next" ]; then
  next="${themes[0]}"
fi

ln -sf "$THEME_DIR/$next.theme" "$LINK_PATH"
echo "Switched to theme: $next"

lastfile=$(cat ~/.cache/zathura-lastfile)
pkill zathura
sleep 0.3
zathura "$lastfile" &

