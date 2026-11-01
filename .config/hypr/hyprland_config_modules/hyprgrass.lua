-- Swipe from the right edge to the left to resize/adjust active window width
hl.plugin.hyprgrass.gesture {
    pattern = {
        kind = "edge",
        origin = "right",
        direction = "left"
    },
    action = "resize"
}

-- Swipe from the bottom edge upwards to resize vertically
hl.plugin.hyprgrass.gesture {
    pattern = {
        kind = "edge",
        origin = "down",
        direction = "up"
    },
    action = "resize"
}

-- Swipe 3 finger to change workspace
hl.plugin.hyprgrass.gesture({
	pattern = {
		kind = "swipe",
		fingers = 3,
		direction = "horizontal",
	},
	action = "workspace",
})

-- 3 fingers up for launcher menu
hl.plugin.hyprgrass.bind({
	pattern = {
		kind = "swipe",
		fingers = 3,
		direction = "up",
	},
	action = hl.dsp.exec_cmd("bash ~/.config/rofi/scripts/fullscreen.sh"),
})

-- 3 fingers down to close every launcher menu
hl.plugin.hyprgrass.bind({
	pattern = {
		kind = "swipe",
		fingers = 3,
		direction = "down",
	},
	action = hl.dsp.exec_cmd("killall rofi"),
})

-- Long-press with 2 fingers to grab and move the active window
hl.plugin.hyprgrass.bind {
    pattern = {
        kind = "longpress",
        fingers = 2
    },
    action = hl.dsp.window.drag(),
    mouse = true,
}

-- 2-finger tap to toggle floating mode
hl.plugin.hyprgrass.bind {
    pattern = {
        kind = "tap",
        fingers = 2
    },
    action = function()
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    end,
}
