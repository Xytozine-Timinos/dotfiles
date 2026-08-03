#!/bin/bash

if command -v waypaper &>/dev/null; then
	waypaper --restore
else
	swaybg -i ~/.dtf_default_wallpaper/evening-sky-by-mei-ying.png -m fill -c #16161D
fi
