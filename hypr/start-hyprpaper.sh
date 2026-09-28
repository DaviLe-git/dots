#!/bin/bash

WALLPAPER_STATE="$HOME/.cache/current-wallpaper"

hyprpaper &

sleep 0.5

if [ -f "$WALLPAPER_STATE" ]; then
    img=$(readlink -f "$WALLPAPER_STATE")

    if [ -f "$img" ]; then
        hyprctl hyprpaper wallpaper "eDP-1,$img"
        hyprctl hyprpaper wallpaper "HDMI-A-1,$img"
    fi
fi
