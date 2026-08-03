#!/bin/bash

get_current_window_id=$(hyprctl activewindow -j | jq -r '.address // empty')

if [[ -z "$get_current_window_id" ]]; then
	exit
fi

sleep 0.2

source ~/.config/dtf-config/config
rofi_theme=${rofi_theme:-black}
bar_top=${bar_top:-false}

if [[ $rofi_theme == "white" ]]; then
	path_to_theme="~/.config/rofi/rofi_theme/white/white.rasi"
else
	path_to_theme="~/.config/rofi/rofi_theme/black/black.rasi"
fi

if [[ $bar_top == "true" ]]; then
	location="north west"

	main_menu_x_offset=175px
	main_menu_y_offset=70px
else
	location="south west"

	main_menu_x_offset=175px
	main_menu_y_offset=-70px
fi

main_menu_height=280px
main_menu_width=300px

close_window="Close "
hide_window="Hide "
float_window="Toggle Float 󰖲"
move_window_workspace="Move To Workspace 󰧸"
quit="Exit 󰈆 "

select=$(echo -e "$close_window\n$hide_window\n$float_window\n$move_window_workspace\n$quit" | rofi -x11 -dmenu -theme $path_to_theme -i -p " Window Options 󱂬 " -theme-str "listview {columns: 1; layout: vertical;}" -theme-str "window {width: $main_menu_width; height: $main_menu_height; location: $location; x-offset: $main_menu_x_offset; y-offset: $main_menu_y_offset;}")

case $select in
$close_window)
	~/.config/hypr/scripts/kill_window.sh
	;;
$hide_window)
	~/.config/hypr/scripts/hide_unhide_window.sh h
	;;
$float_window)
	# hyprctl dispatch togglefloating && hyprctl dispatch resizeactive exact 70% 70%
	hyprctl eval '
	    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	    local monitor = hl.get_active_monitor()
	    if monitor then
		hl.dispatch(hl.dsp.window.resize({ x = monitor.width * 0.7, y = monitor.height * 0.7 }))
	    end
	'
	;;
$move_window_workspace)
	~/.config/hypr/rofi_hyprland/rofi-window-ws-switch/workspace_input_number_window_switch.sh
	;;
$quit)
	exit 0
	;;
esac
