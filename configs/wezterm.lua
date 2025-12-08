local wezterm = require 'wezterm'
local config = {}

config.default_prog = { "/run/current-system/sw/bin/fish" }  -- Replace with your shell path
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = .8
config.macos_window_background_blur = 100
config.native_macos_fullscreen_mode = true
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.keys = {
    {
        key = "k",
        mods = "CMD",
        action = wezterm.action.ClearScrollback "ScrollbackAndViewport",
    },
}

return config