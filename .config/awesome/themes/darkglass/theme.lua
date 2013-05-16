-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
--                           --
--   With modifications by:  -- 
--    zml2008 (Zach Levis)   --
-------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons
local shiny = require('shiny')

-- {{{ Main
theme = shiny.theme_inherit("zenburn")
-- }}}

-- {{{ Styles
theme.font      = "sans 8"

-- Opacity in hex
local opacity = 255 * 0.75
-- {{{ Colors
theme.fg_normal  = shiny.color(0xDC, 0xDC, 0xCC)
theme.fg_focus   = shiny.color(0xF0, 0xDF, 0xAF)
theme.fg_urgent  = shiny.color(0xCC, 0x93, 0x33)
theme.bg_normal  = shiny.color(0x3F, 0x3F, 0x3F, opacity)
theme.bg_focus   = shiny.color(0x1E, 0x23, 0x20, opacity) -- Emphasize focused
theme.bg_urgent  = shiny.color(0x3F, 0x3F, 0x3F, opacity + 5) -- Even more for urgent
theme.bg_systray = theme.bg_normal
-- }}}

return theme
