#!/usr/bin/bash
source ~/.config/dtf-config/config
bar_top=${bar_top:-false}
rofi_theme=${rofi_theme:-black}

if [[ $LAUNCHED_FROM_BAR == "true" ]]; then
	if [[ $bar_top == "true" ]]; then
		location="north west"

		main_menu_x_offset=10px
		main_menu_y_offset=70px
	else
		location="south west"

		main_menu_x_offset=10px
		main_menu_y_offset=-70px
	fi
else
	location="center"
	main_menu_x_offset=0px
	main_menu_y_offset=0px
fi

if [[ $rofi_theme == "white" ]]; then
	path_to_theme="~/.config/rofi/rofi_theme/white/white-search.rasi"
else
	path_to_theme="~/.config/rofi/rofi_theme/black/black-search.rasi"
fi

rofi -x11 -theme $path_to_theme -show drun -theme-str "window {location: $location; x-offset: $main_menu_x_offset; y-offset: $main_menu_y_offset;}"
