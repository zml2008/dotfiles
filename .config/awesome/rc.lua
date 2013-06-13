require("defines")

local shiny = require("shiny")
shiny.init("darkglass")

local bar = require("bar")
local window_mgmt = require("window_mgmt")
local utils = require("utils")

-- Init
--utils.override_awesome_quit()
utils.check_errors()
require("mediakeys")


-- Extra widgets
-- local music_ctl = require("music_ctl")
