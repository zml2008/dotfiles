local wibox = require("wibox")
local widgets = require("widgets")
local awful = require("awful")
local config = require("config")

local separator = widgets.separator
local def_layouts = { -- Button bar arrangements for multiscreens -- center is always tasklist
primary = {
    left = { "taglist", "promptbox" },
    right = { "weather", "ram_monitor", "cpu_monitor", "systray", "clock", "layoutbox" },
},
secondary = {
    left = { "taglist", "promptbox" },
    right = { "clock", "layoutbox" }
}
}

local function get_screen_layout(s, layouts)
    if layouts[s] then return layouts[s] end
    s_str = tostring(s)
    if layouts[s_str] then return layouts[s_str] end

    if s == 1 and layouts.primary then return layouts.primary end
    if layouts.secondary then return layouts.secondary end

    if layouts.left then return layouts end
    return nil
end



local screen_widgets = {}
local function setup()
    for s=1, screen.count() do
        local created_widgets = {}
        screen_widgets[s] = created_widgets

        -- Create a tasklist widget
        created_widgets.tasklist = widgets.tasklist(s)

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        local right_layout = wibox.layout.fixed.horizontal()
        layouts = config.load("bar", def_layouts)

        local layout = get_screen_layout(s, layouts)

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
end

return {
    screen_widgets=screen_widgets,
    setup=setup
}
