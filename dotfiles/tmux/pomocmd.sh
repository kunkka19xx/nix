#!/usr/bin/env bash
set -e

INPUT="$1"
DEFAULT_WORK=25
DEFAULT_BREAK=5
DEFAULT_SESS=4

# Parse input
INPUT="${INPUT//,/ }"

read SESS WORK BREAK <<<"$INPUT"

SESS=${SESS:-$DEFAULT_SESS}
WORK=${WORK:-$DEFAULT_WORK}
BREAK=${BREAK:-$DEFAULT_BREAK}

~/nix/dotfiles/tmux/pomodoro.sh "$SESS" "$WORK" "$BREAK"
