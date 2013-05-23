local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local beautiful = require("beautiful")
local tonumber = tonumber
require("defines")

local window_mgmt = {}

-- data structures

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

window_mgmt.tag_patterns = {
    {match_screen = "primary", tags = {"misc", {"web", awful.layout.suit.max}, {"dev", awful.layout.suit.tile.left}, {"media", awful.layout.suit.max}, "work"}},
    {match_screen = "secondary", tags = {{ "term", awful.layout.suit.tile.top }, "audio", "irc"}}
}

window_mgmt.tags = {}

window_mgmt.all_window_properties = {
                    border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = awful.client.focus.filter,
                    }

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = window_mgmt.all_window_properties },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "st-256color" },
      properties = { opacity = 0.8} },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}

local function get_tag_lazy(screen, name)
    return nil
end

-- Tag handling
local function matches_screen(match_string, s, primary_screen)
    if s == primary_screen and match_string == "primary" then
        return true
    elseif (s ~= primary_screen or screen.count() == 1) and match_string == "secondary" then -- if there's only one screen, put all the tags on one.
        return true
    elseif tonumber(match_string) == s then
        return true
    else
        return false
    end
end

local function tag_pair_to_tables(tag_table)
    names = {}
    layouts = {}
    for _, v in ipairs(tag_table) do
        if type(v) == "string" then
            table.insert(names, v)
            table.insert(layouts, window_mgmt.default_layout)
        elseif type(v) == "table" then
            table.insert(names, v[1])
            table.insert(layouts, v[2])
        end
    end
    return names, layouts
end

function window_mgmt:init_tags(primary_screen)
    for s = 1, screen.count() do
        for i, v in ipairs(self.tag_patterns) do
            if matches_screen(v.match_screen, s, primary_screen) then
                local names, layouts = tag_pair_to_tables(v.tags)
                local tags = awful.tag(names, s, layouts)
                local mapped_tags = window_mgmt.tags[s]
                if mapped_tags == nil then mapped_tags = {} end

                window_mgmt.tags[s] = mapped_tags
                window_mgmt.tags[v.match_screen] = mapped_tags
                for i, tag in ipairs(tags) do
                    mapped_tags[tag.name] = tag
                end
            end
        end
    end
end



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