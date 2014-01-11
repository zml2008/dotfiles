require("defines")

local shiny = require("shiny")
shiny.init("zenburn")

local utils = require("utils")

-- Init
utils.check_errors()
local bar = require("bar")
local window_mgmt = require("window_mgmt")

-- Extra widgets
--local music_ctl = require("music_ctl")

-- Separate additions
require("mediakeys")
--require("ircnotify").setup_irc()
bar.setup()


