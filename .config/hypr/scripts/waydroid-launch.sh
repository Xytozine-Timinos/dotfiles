#!/bin/bash

if command -v waydroid >/dev/null 2>&1; then
	waydroid show-full-ui &
	disown
	sleep 1
	if pgrep -x waydroid >/dev/null 2>&1; then
		notify-send -t 3250 "Launching Waydroid..."
	else
		notify-send -t 3250 "Waydroid Failed to Start" "Check logs for details"
	fi
else
	notify-send -t 3250 "Waydroid Not Found!" "Please Install It Manually"
fi
