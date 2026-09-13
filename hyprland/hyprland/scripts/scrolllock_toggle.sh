#!/bin/bash
# Toggle Scroll Lock LED on the CASUE USB KB (2a7a:939f)
STATE_FILE=/tmp/scrolllock_state
if [ "$(cat "$STATE_FILE" 2>/dev/null)" = "1" ]; then
    echo 0 > "$STATE_FILE"
else
    echo 1 > "$STATE_FILE"
fi

# ensure daemon is running (it applies state and fights firmware resets)
systemctl --user is-active --quiet scrolllock-led.service || \
    systemctl --user start scrolllock-led.service
