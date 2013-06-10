local wibox = require("wibox")
local widgets = require("widgets")
local awful = require("awful")

local separator = widgets.separator
local layouts = { -- Button bar arrangements for multiscreens -- center is always tasklist
    primary = {
        left = { "taglist", "promptbox" },
        right = { "weather", "ram_monitor", "cpu_monitor", "systray", "clock", "layoutbox" },
    },
    secondary = {
        left = { "taglist", "promptbox" },
        right = { "clock", "layoutbox" }
    }
}

local screen_widgets = {}

for s=1, screen.count() do
    local created_widgets = {}
    screen_widgets[s] = created_widgets

    -- Create a tasklist widget
    created_widgets.tasklist = widgets.tasklist(s)

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    local right_layout = wibox.layout.fixed.horizontal()

    local layout = s == 1 and layouts.primary or layouts.secondary

    for i, value in ipairs(layout.left) do
        local widget = widgets[value](s)
        created_widgets[value] = widget
        left_layout:add(widget)
        if i < #layout.left then
            left_layout:add(separator())
        end
    end

    for i, value in ipairs(layout.right) do
        right_layout:add(separator())
        widget = widgets[value](s)
        created_widgets[value] = widget
        right_layout:add(widget)
    end

    -- Now bring it all together (with the tasklist in the middle)
    local screen_wibox = awful.wibox({position = "top", screen = s})
    local final_layout = wibox.layout.align.horizontal()
    final_layout:set_left(left_layout)
    final_layout:set_middle(created_widgets.tasklist)
    final_layout:set_right(right_layout)

    screen_wibox:set_widget(final_layout)
end


return {
    screen_widgets=screen_widgets,
    layouts=layouts,
    setup=setup
}