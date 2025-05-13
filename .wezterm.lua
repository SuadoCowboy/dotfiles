-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- For example, changing the color scheme:
config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 16

config.window_decorations = "NONE"

-- powershell instead of cmd
config.default_prog = { "powershell" }

-- tmux
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
	{
		mods = "LEADER",
		key = "o",
		action = wezterm.action.EmitEvent("toggle-opacity"),
	},
	{
		mods = "LEADER",
		key = "z",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "x",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "h",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		mods = "LEADER",
		key = "j",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		mods = "LEADER",
		key = "k",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		mods = "LEADER",
		key = "l",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		mods = "LEADER",
		key = "LeftArrow",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		mods = "LEADER",
		key = "RightArrow",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		mods = "LEADER",
		key = "DownArrow",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		mods = "LEADER",
		key = "UpArrow",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
}

for i = 0, 9 do
	-- leader + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i),
	})
end

-- tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = false

-- background
local BACKGROUND_BRIGHTNESS = 0.05
local BACKGROUND_IMAGE = "C:\\Users\\emilly\\Documents\\Lucca\\Imagens\\background\\outros\\store.png"
local BACKGROUND_HUE = 1.0
local BACKGROUND_SATURATION = 1.0
local BACKGROUND_OPACITY = 0.9

config.window_background_image = BACKGROUND_IMAGE
config.window_background_opacity = BACKGROUND_OPACITY

config.window_background_image_hsb = {
	brightness = BACKGROUND_BRIGHTNESS,
	hue = BACKGROUND_HUE,
	saturation = BACKGROUND_SATURATION,
}

-- window transparency
wezterm.on("toggle-opacity", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.window_background_opacity == BACKGROUND_OPACITY then
		overrides.window_background_opacity = 1.0
	else
		overrides.window_background_opacity = BACKGROUND_OPACITY
	end
	window:set_config_overrides(overrides)
end)

-- window size and position
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	local screen = wezterm.gui.screens().active
	local sW, sH = screen.width, screen.height - 40

	local gWindow = window:gui_window()
	local dimensions = gWindow:get_dimensions()

	dimensions.pixel_width = sW * 0.95
	dimensions.pixel_height = sH * 0.95

	gWindow:set_inner_size(dimensions.pixel_width, dimensions.pixel_height)

	gWindow:set_position((sW - dimensions.pixel_width) / 2, (sH - dimensions.pixel_height) / 2)
end)

wezterm.on("update-right-status", function(window, pane)
	local leader = ""
	if window:leader_is_active() then
		leader = "LEADER"
	end
	window:set_right_status(leader)
end)

-- and finally, return the configuration to wezterm
return config
