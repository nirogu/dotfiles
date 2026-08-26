-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

function Get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

function Scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Everforest Dark Hard (Gogh)'
  else
    return 'Everforest Light Medium (Gogh)'
  end
end

config.font_size = 12
config.font = wezterm.font 'JetBrainsMonoNerdFont'
config.warn_about_missing_glyphs = false
config.color_scheme = Scheme_for_appearance(Get_appearance())
config.window_background_opacity = 0.9
config.tab_bar_at_bottom = true
config.default_cursor_style = "BlinkingBar"
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Finally, return the configuration to wezterm:
return config
