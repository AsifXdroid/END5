#!/bin/bash
# Launch Zen browser; focus existing window if already running, else start it
WID=$(hyprctl clients -j 2>/dev/null | python3 -c "
import sys, json
try:
    for c in json.load(sys.stdin):
        cls = c.get('class', '').lower()
        if 'zen' in cls:
            print(c.get('address'))
            break
except Exception:
    pass
" 2>/dev/null)

if [ -n "$WID" ]; then
    hyprctl eval "hl.dsp.focus({ window = '$WID' })" 2>/dev/null
else
    zen-browser &
fi