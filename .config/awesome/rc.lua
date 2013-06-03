require("defines")

local shiny = require("shiny")
shiny.init("darkglass")

local utils = require("utils")
local bar = require("bar")
local keybindings = require("keybindings")
local window_mgmt = require("window_mgmt")

-- Init
--utils.override_awesome_quit()
utils.check_errors()


-- Extra widgets
-- local music_ctl = require("music_ctl")

window_mgmt:init_tags(1)
bar.setup(1)
keybindings.apply(modkey)
