-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = "tokyonight-storm"

config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = 600, italic = false })
config.font_size = 18

config.enable_tab_bar = false

config.window_padding = {
	left = 3,
	right = 0,
	top = 0,
	bottom = 0,
}

config.scrollback_lines = 5000

-- and finally, return the configuration to wezterm
return config
