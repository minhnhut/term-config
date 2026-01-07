-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 15
config.font = wezterm.font("BlexMono Nerd Font Mono")
config.color_scheme = "Dracula"
config.hide_tab_bar_if_only_one_tab = true

-- Finally, return the configuration to wezterm:
config.keys = {
  {key="Enter", mods="SHIFT", action=wezterm.action{SendString="\x1b\r"}},
}

return config
