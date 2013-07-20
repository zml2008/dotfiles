local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local beautiful = require("beautiful")
local tonumber = tonumber
require("defines")
local keybindings = require("keybindings")
local bar = require('bar')
local tagged = require('tagged')
--local eminent = require('eminent.eminent')
local window_mgmt = {}

-- window placement rules

window_mgmt.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

window_mgmt.default_layout = awful.layout.suit.fair

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            keys = keybindings.clientkeys(),
            buttons = keybindings.clientbuttons()
        } 
    },
    { rule = { role = "conversation" },
        properties = { floating = true, ontop = true }
    },
    { rule = { class = "pinentry" },
        properties = { floating = true, ontop = true }
    },
    --{ rule = { class = "gimp" },
    -- properties = { floating = true } },
    { rule = { class = "st-256color" },
        properties = { opacity = 1.0}
    },
}

window_mgmt.tag_presets = {
    ["vim+term"]={"st", "st", "gvim"},
    ["terms"]={"st", "st", "st"},
    ["browser"]={"surf"}
}
tagged.default_layout = window_mgmt.default_layout
tagged.init({
    {
        name = "term",
        only_matching = true,
        screen = screen.count() > 1 and 2 or 1,
        layout = awful.layout.suit.tile.top,
    },
    {
        name = "media",
        screen = {1, 2},
        -- clone_on = 2,
        layout = awful.layout.suit.fair,
    },
    {
        name        = "www",
        --icon        = "~net.png",                 -- Use this icon for the tag (uncomment with a real path)
        screen      = 1,
        layout      = awful.layout.suit.max,      -- Use the max layout
    } ,
    {
        name = "comms",
        screen      = 1,
        mwfact = 0.15,
        layout      = awful.layout.suit.tile,
    } ,
    {
        name = "dev",
        screen      = {1, 2},
--        sync_screens = true,
        layout      = awful.layout.suit.max,
    } ,
})

-- keybindings
-- Keys that apply to all windows - these are the only keybindings directly applied in this file
keybindings.globalkeys(awful.util.table.join(
awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

awful.key({ modkey,           }, "j",
function ()
    awful.client.focus.byidx( 1)
    if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "k",
function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end),

-- Layout manipulation
awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
awful.key({ modkey,           }, "Tab",
function ()
    awful.client.focus.history.previous()
    if client.focus then
        client.focus:raise()
    end
end),
awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
awful.key({ modkey,           }, "space", function () awful.layout.inc(window_mgmt.layouts,  1) end),
awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(window_mgmt.layouts, -1) end),

awful.key({ modkey, "Control" }, "n", awful.client.restore),



-- Mouse location control
awful.key({modkey}, ".", function () -- move mouse to next screen
    local sid = mouse.screen + 1
    if sid > screen.count() then sid = 1 end
    s_geom = screen[sid].geometry

    mouse.coords({x=s_geom.x + (s_geom.width / 2), y=s_geom.y + s_geom.height / 2})
end),
awful.key({modkey}, ",", function () -- move to top of window
    local c = awful.mouse.client_under_pointer()
    if c then
        mouse.coords({x=mouse.coords().x, y=c:geometry().y})
    end
end),
awful.key({modkey}, "o", function () -- down
    local c = awful.mouse.client_under_pointer()
    if c then
        local geom = c:geometry()
        mouse.coords({x=mouse.coords().x, y=(geom.y + geom.height)})
    end
end),
awful.key({modkey}, "a", function () -- left
    local c = awful.mouse.client_under_pointer()
    if c then
        mouse.coords({x=c:geometry().x, y=mouse.coords().y})
    end
end),
awful.key({modkey}, "e", function () -- right
    local c = awful.mouse.client_under_pointer()
    if c then
        local geom = c:geometry()
        mouse.coords({x=(geom.x + geom.width), y=mouse.coords().y})
    end
end),
awful.key({modkey}, "u", function () -- center of window
    local c = awful.mouse.client_under_pointer()
    if c then
        local geom = c:geometry()
        mouse.coords({x=(geom.x + geom.width / 2), y=(geom.y  + geom.height / 2)})
    end
end),
awful.key({modkey}, "p", function ()
    local pbox = bar.screen_widgets[mouse.screen].promptbox
    if pbox then
        awful.prompt.run({ prompt = "Add a new tag: " },
        pbox.widget,
        function (txt)
            awful.tag.add(txt, {})
        end)
    end
end),
awful.key({"Control", modkey}, "p", function ()
    local pbox = bar.screen_widgets[mouse.screen].promptbox
    if pbox then
        awful.prompt.run({ prompt = "Add a tag (w/tmpl): " },
        pbox.widget,
        function (txt)
            actions = {}
            for k, v in pairs(window_mgmt.tag_presets) do
                table.insert(actions, {k, function()
                    t = awful.tag.add(txt, {})
                    awful.tag.viewonly(t)
                    for _, torun in pairs(v) do
                        awful.util.spawn(torun)
                    end
                end})
            end
            awful.menu(actions):show()
        end)
    end
end),
awful.key({modkey, "Shift"}, "p", function ()
    awful.tag.delete()
end)
))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    keybindings.globalkeys(awful.util.table.join(
    awful.key({ modkey }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
            awful.tag.viewonly(tag)
        end
    end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
            awful.tag.viewtoggle(tag)
        end
    end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
    function ()
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if client.focus and tag then
            awful.client.movetotag(tag)
        end
    end),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
    function ()
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if client.focus and tag then
            awful.client.toggletag(tag)
        end
    end)))
end


keybindings.clientkeys(awful.util.table.join(
awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
awful.key({ modkey,           }, ";",      awful.client.movetoscreen                        ),
awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
awful.key({ modkey,           }, "n",
function (c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
end),
awful.key({ modkey,           }, "m",
function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
end)
))

local altkey = "Mod1"
keybindings.clientbuttons(awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ altkey }, 1, awful.mouse.client.move),
awful.button({ altkey }, 3, awful.mouse.client.resize)
))


-- # EVENT LOGIC #
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = nil
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
        )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

return window_mgmt
