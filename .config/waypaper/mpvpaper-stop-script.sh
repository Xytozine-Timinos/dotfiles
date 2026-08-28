#!/bin/bash

sleep 0.6

if pgrep -f "mpvpaper" > /dev/null; then
    if ! pgrep -f "mpvpaper-stop --socket-path /tmp/mpv-socket-All" > /dev/null; then
        mpvpaper-stop --socket-path /tmp/mpv-socket-All -t 100 &
    fi
fi
