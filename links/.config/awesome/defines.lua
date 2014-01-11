local naughty = require("naughty")
-- local menubar = require("menubar")

-- This is used later as the default terminal and editor to run.
terminal = "st"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
-- menubar.util.terminal = terminal

-- Default modkey.
-- Mod4 == winkey
modkey = "Mod4"


-- Notification (naughty) settings
naughty.config.defaults.icon_size = 32
-- naughty.config.defaults.callback = function(data, appname, replace_id, icon, title, text, actions, hints, expire) end