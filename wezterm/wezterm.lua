-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local act = wezterm.action
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

local function is_shell(foreground_process_name)
  local shell_names = { 'bash', 'zsh', 'fish', 'sh', 'ksh', 'dash' }
  local process = string.match(foreground_process_name, '[^/\\]+$')
    or foreground_process_name
  for _, shell in ipairs(shell_names) do
    if process == shell then
      return true
    end
  end
  return false
end

wezterm.on('open-uri', function(window, pane, uri)
  local editor = 'helix'

  -- Map a file(1) MIME type to the program that should open it.
  -- Returns nil when we have no opinion -> default WezTerm behaviour.
  -- NOTE order matters: DjVu is reported as image/vnd.djvu, so the
  -- document rule must come before the generic image/ rule.
  local function mime_opener(mime)
    if mime:sub(1, 5) == 'text/'
      or mime == 'application/json'
      or mime == 'application/toml'
      or mime:find 'xml$'
      or mime:find 'shellscript'
    then
      return editor
    end
    if mime:find 'djvu'                          -- image/vnd.djvu
      or mime == 'application/pdf'
      or mime == 'application/postscript'        -- ps/eps
      or mime == 'application/epub+zip'
      or mime:find '^application/x%-cb'          -- cbz, cbr, cb7, cbt
      or mime:find '^application/vnd%.comicbook' -- comicbook+zip/+rar
    then
      return 'zathura'
    end
    if mime:sub(1, 6) == 'image/' then
      return 'imv'
    end
    if mime:sub(1, 6) == 'audio/'
      or mime:sub(1, 6) == 'video/'
      or mime == 'application/ogg'
    then
      return 'mpv'
    end
    return nil
  end

  if uri:find '^file:' == 1 and not pane:is_alt_screen_active() then
    -- We're processing an hyperlink and the uri format should be: file://[HOSTNAME]/PATH[#linenr]
    -- Also the pane is not in an alternate screen (an editor, less, etc)
    local url = wezterm.url.parse(uri)

    -- Filenames may legally contain control characters (\r = Enter in a tty);
    -- strip them, shell quoting alone doesn't help against those.
    local path = (url.file_path:gsub('%c', ''))
    -- Only digits where the value becomes helix's +linenr argument
    local frag = url.fragment and url.fragment:match '^%d+$' or nil

    if is_shell(pane:get_foreground_process_name()) then
      -- A shell has been detected. WezTerm can check the file type directly
      local success, stdout, _ = wezterm.run_child_process {
        'file', '--brief', '--mime-type', path,
      }
      if success then
        local mime = stdout:gsub('%s+$', '')

        if mime == 'inode/directory' then
          pane:send_text(wezterm.shell_join_args { 'cd', path } .. '\r')
          pane:send_text(wezterm.shell_join_args { 'ls' } .. '\r')
          return false
        end

        local opener = mime_opener(mime)
        if opener then
          -- Only the editor understands the #linenr fragment
          local args = { opener, path }
          if opener == editor and frag then
            table.insert(args, 2, '+' .. frag)
          end
          pane:send_text(wezterm.shell_join_args(args) .. '\r')
          return false
        end
        -- anything else: no return -> default actions
      end
    else
      -- No shell detected, we're probably connected with SSH. Only handle
      -- what every Unix serves well: directories (cd into them) and text
      -- files (cat them). Everything else prints nothing here.
      local q = "'" .. path:gsub("'", "'\\''") .. "'"
      pane:send_text(
        'if [ -d ' .. q .. ' ]; then '
        .. 'cd ' .. q .. ' && ls -a -p --hyperlink --group-directories-first; '
        .. 'elif [ -f ' .. q .. ' ] && grep -Iq . ' .. q .. '; then '
        .. 'cat -- ' .. q .. '; fi; echo\r'
      )
      return false
    end
  end

  -- without a return value, we allow default actions
end)

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
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.Nop,
  },
}

-- Finally, return the configuration to wezterm:
return config
