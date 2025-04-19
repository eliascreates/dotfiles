-- ── Imports & Initialization ─────────────────────────────────────────
local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()
config.automatically_reload_config = true

-- ── Performance Settings ───────────────────────────────────────────────
config.front_end = "OpenGL"
config.prefer_egl = true
config.max_fps = 100
config.animation_fps = 1
config.window_close_confirmation = "NeverPrompt"

-- ── Cursor & Terminal ─────────────────────────────────────────────────
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.term = "xterm-256color"

-- ── Font Settings ─────────────────────────────────────────────────────
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size = 18.0
config.cell_width = 0.9

-- ── Window Appearance ─────────────────────────────────────────────────
config.window_background_opacity = 0.9
config.window_decorations = "NONE | RESIZE"
config.window_padding = { left = 0, right = 0, top = 10, bottom = 0 }
config.initial_cols = 80
config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe" }

-- ── Tab Bar Configuration ─────────────────────────────────────────────
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- ── Color Scheme ─────────────────────────────────────────────────────
config.color_scheme = "Tokyo Night"
config.colors = {
	tab_bar = {
		background = "#0c0b0f",
		active_tab = { bg_color = "#0c0b0f", fg_color = "#bea3c7" },
		inactive_tab = { bg_color = "#0c0b0f", fg_color = "#f8f2f5" },
		new_tab = { bg_color = "#0c0b0f", fg_color = "white" },
	},
}

-- ── Window Frame ─────────────────────────────────────────────────────
config.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Regular" }),
	active_titlebar_bg = "#0c0b0f",
}

-- ── Key Bindings ─────────────────────────────────────────────────────
config.keys = {
	-- Toggle between color schemes
	{ key = "E", mods = "CTRL|SHIFT|ALT", action = wezterm.action.EmitEvent("toggle-colorscheme") },
	-- Split Panes
	{ key = "h", mods = "CTRL|SHIFT|ALT", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
	{ key = "v", mods = "CTRL|SHIFT|ALT", action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }) },
	-- Adjust Pane Size
	{ key = "U", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "I", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "O", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "P", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
	-- Pane Select & Debug Overlay
	{ key = "9", mods = "CTRL", action = act.PaneSelect },
	{ key = "L", mods = "CTRL", action = act.ShowDebugOverlay },
	-- Toggle Transparency
	{
		key = "O",
		mods = "CTRL|ALT",
		action = wezterm.action_callback(function(window, _)
			local overrides = window:get_config_overrides() or {}
			overrides.window_background_opacity = (overrides.window_background_opacity == 1.0) and 0.9 or 1.0
			window:set_config_overrides(overrides)
		end),
	},
}

-- ── Event: Toggle Color Scheme ─────────────────────────────────────────
wezterm.on("toggle-colorscheme", function(window, _)
	local overrides = window:get_config_overrides() or {}
	overrides.color_scheme = (overrides.color_scheme == "Zenburn") and "Tokyo Night" or "Zenburn"
	window:set_config_overrides(overrides)
end)

-- ── Return Final Configuration ────────────────────────────────────────
return config
