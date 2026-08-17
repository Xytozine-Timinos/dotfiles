#!/bin/bash

source ~/.config/dtf-config/config

animations=${animations:-true}
blur=${blur:-true}
transparent_window_when_unfocus=${transparent_window_when_unfocus:-true}

if [[ $transparent_window_when_unfocus == "false" ]]; then
	hyprctl eval 'hl.config({decoration = { inactive_opacity = 1 }})'
else
	hyprctl eval 'hl.config({decoration = { inactive_opacity = 0.95 }})'
fi

power_mode_status=$(powerprofilesctl get)
if [[ $power_mode_status != "power-saver" ]]; then
	if [[ $animations == "false" ]]; then
		hyprctl eval 'hl.config({animations = {enabled = false}})'
	else
		hyprctl eval 'hl.config({animations = {enabled = true}})'
	fi

	if [[ $blur == "false" ]]; then
		hyprctl eval 'hl.config({decoration = { blur = { enabled = false }}})'
	else
		hyprctl eval 'hl.config({decoration = { blur = { enabled = true }}})'
	fi
else
	hyprctl eval 'hl.config({animations = {enabled = false}})'
	hyprctl eval 'hl.config({decoration = { blur = { enabled = false }}})'
fi
