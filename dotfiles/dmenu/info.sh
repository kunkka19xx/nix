#!/usr/bin/env bash

get_volume() {
    local sink
    sink=$(pactl get-default-sink)
    local volume mute
    volume=$(pactl get-sink-volume "$sink" | grep -oP '\d+%' | head -1)
    mute=$(pactl get-sink-mute "$sink" | awk '{print $2}')
    if [ "$mute" = "yes" ]; then
        echo "🔇 Volume: Muted"
    else
        echo "🔊 Volume: $volume"
    fi
}

get_wifi() {
    if nmcli networking connectivity | grep -q "full"; then
        ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        echo "📶 Wi-Fi: $ssid"
    else
        echo "📶 Wi-Fi: Disconnected"
    fi
}

get_datetime() {
    echo "📅 $(date '+%A, %d %b %Y %H:%M:%S')"
}

get_current_workspace() {
    i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name'
}

get_all_workspaces() {
    i3-msg -t get_workspaces | jq -r '.[].name'
}

get_workspaces_info() {
    local current all
    current=$(get_current_workspace)
    all=$(get_all_workspaces | tr '\n' ' ')
    echo "🧩 Workspace: $current 🗂️ All: $all"
}

workspace_output=$(get_workspaces_info &)
volume_output=$(get_volume &)
datetime_output=$(get_datetime &)
wait

INFO="$workspace_output · $volume_output · $datetime_output"

echo -e "$INFO" | dmenu -p "📋 System Info"
