#!/bin/bash
# Clear latched modifier keys after wake by forcing keymap rebuild.
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

for kb in $(hyprctl devices -j | jq -r '.keyboards[].name' 2>/dev/null); do
    # switch layout forward and back -> forces full xkb state re-init
    hyprctl switchxkblayout "$kb" 1 >/dev/null 2>&1
    hyprctl switchxkblayout "$kb" -1 >/dev/null 2>&1
done
