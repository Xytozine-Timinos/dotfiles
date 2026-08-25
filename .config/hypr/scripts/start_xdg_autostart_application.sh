#!/usr/bin/env bash

source ~/.config/dtf-config/config

xdg_autostart=${xdg_autostart:-true}

if [[ $xdg_autostart == true ]]; then
	dex -a
fi
