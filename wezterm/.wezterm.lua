local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- Window settings
config.initial_cols = 120
config.initial_rows = 28
config.hide_tab_bar_if_only_one_tab = false

-- Font settings
config.font = wezterm.font("BlexMono Nerd Font Mono")
config.font_size = 15

-- Color scheme
config.color_scheme = "Dracula"

-- Leader key
config.leader = { key = "a", mods = "CTRL" }

-- Tab bar styling (like tmux status bar at top)
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- Dracula-inspired colors for tab bar
config.colors = {
	tab_bar = {
		background = "#282a36",
		active_tab = {
			bg_color = "#50fa7b",
			fg_color = "#282a36",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#1d1d21",
			fg_color = "#f8f8f2",
		},
		inactive_tab_hover = {
			bg_color = "#6272a4",
			fg_color = "#f8f8f2",
		},
		new_tab = {
			bg_color = "#6272a4",
			fg_color = "#f8f8f2",
		},
	},
}

-- Status bar (mimicking tmux)
wezterm.on("update-right-status", function(window, pane)
	local cells = {}

	-- Dracula colors
	local blue = "#6272a4"
	local yellow = "#f1fa8c"
	local purple = "#bd93f9"
	local bg = "#282a36"
	local fg = "#f8f8f2"

	-- Time: HH:MM [Day] DD.MM.YY
	local date = wezterm.strftime(" %H:%M [%a] %d.%m.%y ")

	-- Battery
	local battery = ""
	for _, b in ipairs(wezterm.battery_info()) do
		battery = string.format(" 󰄌 %.0f%% ", b.state_of_charge * 100)
	end

	-- Build the status
	window:set_right_status(wezterm.format({
		{ Background = { Color = blue } },
		{ Foreground = { Color = fg } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = date },
		{ Background = { Color = purple } },
		{ Foreground = { Color = bg } },
		{ Text = battery },
		{ Background = { Color = bg } },
		{ Foreground = { Color = purple } },
		{ Text = "" },
	}))
end)

-- Keybindings (adapted from your tmux.conf)
config.keys = { -- Send C-a when pressing leader twice
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},
	-- for Claude Code to enter
	{ key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },

	-- Pane navigation (C-hjkl without leader, like your tmux)
	{ key = "h", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Right") },

	-- Tab navigation (C-q previous, C-e next, C-Tab last)
	{ key = "q", mods = "CTRL", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "e", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL", action = wezterm.action.ActivateLastTab },

	-- Create new tab with leader+c (opens in current dir)
	{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

	-- Split panes (leader+" for vertical, leader+% for horizontal)
	{ key = '"', mods = "LEADER|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "%", mods = "LEADER|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- Zoom pane
	{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },

	-- Copy mode (leader+[ like tmux)
	{ key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },

	-- Close pane
	{ key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },

	-- Resize panes (leader+hjkl with shift)
	{ key = "H", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },

	-- Tab selection (leader+1-9)
	{ key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },

	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Rearrange tabs (move left/right)
	{ key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

	-- Rotate/swap panes
	{ key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	{ key = "O", mods = "LEADER|SHIFT", action = act.RotatePanes("CounterClockwise") },

	-- Cycle through pane layouts
	{ key = "Space", mods = "LEADER", action = act.PaneSelect({ mode = "SwapWithActive" }) },

	-- Session save/restore (resurrect plugin)
	{
		key = "s",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Save session as (default: 'default'): ",
			action = wezterm.action_callback(function(win, pane, line)
				local name = line and line ~= "" and line or "default"
				local state = resurrect.workspace_state.get_workspace_state()
				state.workspace = name
				resurrect.state_manager.save_state(state)
				resurrect.state_manager.write_current_state(name, "workspace")
			end),
		}),
	},
	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)")
				id = string.match(id, "([^/]+)$")
				id = string.match(id, "(.+)%..+$")
				local opts = {
					window = win:mux_window(),
					relative = true,
					restore_text = true,
					close_open_tabs = true,
					close_open_panes = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.state_manager.load_state(id, "workspace")
					-- Only restore first window into current window
					if state and state.windows and #state.windows > 0 then
						state.windows = { state.windows[1] }
					end
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.state_manager.load_state(id, "window")
					resurrect.window_state.restore_window(win:mux_window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.state_manager.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
				-- Reset font and window size after restore
				win:perform_action(act.ResetFontAndWindowSize, pane)
			end)
		end),
	},
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
				resurrect.state_manager.delete_state(id)
			end, {
				title = "Delete State",
				description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
				fuzzy_description = "Search State to Delete: ",
				is_fuzzy = true,
			})
		end),
	},
}

-- Copy mode with vi keys
config.key_tables = {
	copy_mode = {
		{ key = "y", mods = "NONE", action = wezterm.action.CopyTo("ClipboardAndPrimarySelection") },
		{ key = "Escape", mods = "NONE", action = wezterm.action.CopyMode("Close") },
	},
}

return config
