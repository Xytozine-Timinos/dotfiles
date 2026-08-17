local M = {}

local function get_template(choice)
	if choice == "Right / East Side" then
		return [=[#!/bin/bash
source ~/.config/dtf-config/config

bar_top=${bar_top:-false}
rofi_theme=${rofi_theme:-black}

if [[ $bar_top == "true" ]]; then
    location="north east"

    main_menu_x_offset=-10px
    main_menu_y_offset=70px
else
    location="south east"

    main_menu_x_offset=-10px
    main_menu_y_offset=-70px
fi

if [[ $rofi_theme == "white" ]]; then
    path_to_theme="~/.config/rofi/rofi_theme/white/white.rasi"
else
    path_to_theme="~/.config/rofi/rofi_theme/black/black.rasi"
fi

main_menu_height=200px
main_menu_width=200px

options="Option 1"
quit="Exit 󰈆 "

main_menu() {
    menu_name="Testing"
    select=$(echo -e "$options\n$quit" | rofi -x11 -dmenu -theme $path_to_theme -i -p " $menu_name " -theme-str "listview {columns: 1; layout: vertical;}" -theme-str "window {width: $main_menu_width; height: $main_menu_height; location: $location; x-offset: $main_menu_x_offset; y-offset: $main_menu_y_offset;}")

    #Your own case/if block here!
}

main_menu]=]
	elseif choice == "Left / West Side" then
		return [=[#!/bin/bash
source ~/.config/dtf-config/config

bar_top=${bar_top:-false}
rofi_theme=${rofi_theme:-black}

if [[ $bar_top == "true" ]]; then
    location="north west"

    main_menu_x_offset=10px
    main_menu_y_offset=70px
else
    location="south west"

    main_menu_x_offset=10px
    main_menu_y_offset=-70px
fi

if [[ $rofi_theme == "white" ]]; then
    path_to_theme="~/.config/rofi/rofi_theme/white/white.rasi"
else
    path_to_theme="~/.config/rofi/rofi_theme/black/black.rasi"
fi

main_menu_height=200px
main_menu_width=200px

options="Option 1"
quit="Exit 󰈆 "

main_menu() {
    menu_name="Testing"
    select=$(echo -e "$options\n$quit" | rofi -x11 -dmenu -theme $path_to_theme -i -p " $menu_name " -theme-str "listview {columns: 1; layout: vertical;}" -theme-str "window {width: $main_menu_width; height: $main_menu_height; location: $location; x-offset: $main_menu_x_offset; y-offset: $main_menu_y_offset;}")

    #Your own case/if block here!
}

main_menu]=]
	end
end

function M.insert(template)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, "\n"))
end

function M.ask_and_insert()
	local options = {
		"Right / East Side",
		"Left / West Side",
	}

	vim.ui.select(options, {
		prompt = "Select a Rofi template position:",
	}, function(choice)
		if choice then
			local template = get_template(choice)
			vim.schedule(function()
				M.insert(template)
			end)
		end
	end)
end

function M.setup()
	vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
		pattern = "rofi-*",
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
			if vim.api.nvim_buf_line_count(0) == 1 and lines[1] == "" then
				vim.schedule(function()
					M.ask_and_insert()
				end)
			end
		end,
	})
end

return M
