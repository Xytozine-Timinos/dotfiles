local home = os.getenv("HOME")

hl.exec_cmd(home .. "/.config/hypr/scripts/hyprland_plugins.sh")

----------------
--- Hyprbars ---
----------------
if hl.plugin.hyprbars ~= nil then
	_G.Bar_color = "rgb(16161d)"
	hl.config({
		plugin = {
			hyprbars = {
				bar_blur = true,
				bar_height = 38,
				bar_color = _G.Bar_color,
				["col.text"] = "rgb(e0e6ed)",
				bar_text_size = 18,
				bar_text_font = "JetBrainsMono Nerd Font",
				bar_text_weight = "bold",
				bar_text_align = "left",
				bar_button_padding = 12,
				bar_padding = 15,
				bar_precedence_over_border = true,
				on_double_click = "hyprctl dispatch 'hl.dsp.window.fullscreen({ action = \"toggle\" })' && notify-send 'Fullscreen!' 'Use Mod+F to undo it.' -t 2100",
			},
		},
	})

	hl.plugin.hyprbars.add_button({
		bg_color = "rgb(ff6f91)",
		fg_color = _G.Bar_color,
		size = 22,
		icon = "",
		action = "~/.config/hypr/scripts/kill_window.sh",
	})
	hl.plugin.hyprbars.add_button({
		bg_color = "rgb(f9e2af)",
		fg_color = _G.Bar_color,
		size = 22,
		icon = "󱂬",
		action = [[bash -c "hyprctl eval '
			    hl.dispatch(hl.dsp.window.float({ action = \"toggle\" }))
			    local monitor = hl.get_active_monitor()
			    if monitor then
				hl.dispatch(hl.dsp.window.resize({ x = monitor.width * 0.7, y = monitor.height * 0.7 }))
			    end
			'"]],
	})
	hl.plugin.hyprbars.add_button({
		bg_color = "rgb(a6e3a1)",
		fg_color = _G.Bar_color,
		size = 22,
		icon = "",
		action = "~/.config/hypr/scripts/hide_unhide_window.sh h",
	})
	hl.plugin.hyprbars.add_button({
		bg_color = "rgb(81ccee)",
		fg_color = _G.Bar_color,
		size = 22,
		icon = "󰖲",
		action = "~/.config/hypr/rofi_hyprland/rofi-window-ws-switch/workspace_input_number_window_switch.sh",
	})
end
