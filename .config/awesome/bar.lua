local awful = require("awful")
local beautiful = require("beautiful")
local keybindings = require("keybindings")
local wibox = require("wibox")
local vicious = require("vicious")



-- Menus (there really aren't that many of these, I don't like menus)
local root_menu = awful.menu({ items = { { "open terminal", terminal },
                                { "restart", awesome.restart},
                                { "quit", awesome.quit}
                              }
                        })

root_menu.launcher_button = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = root_menu })

local function singleton_widget(factory_func)
    local widget_obj = nil
    return function ()
        if widget_obj == nil then
            widget_obj = factory_func()
        end
        return widget_obj
    end
end

function gradient(color, to_color, min, max, value)
    local function color2dec(c)
        return tonumber(c:sub(2,3),16), tonumber(c:sub(4,5),16), tonumber(c:sub(6,7),16)
    end

    local factor = 0
    if (value >= max ) then 
        factor = 1  
    elseif (value > min ) then 
        factor = (value - min) / (max - min)
    end 

    local red, green, blue = color2dec(color) 
    local to_red, to_green, to_blue = color2dec(to_color) 

    red   = red   + (factor * (to_red   - red))
    green = green + (factor * (to_green - green))
    blue  = blue  + (factor * (to_blue  - blue))

    -- dec2color
    return string.format("#%02x%02x%02x", red, green, blue)
end

-- Returns the string as vertical text
-- At the moment DOES NOT support modification -- it'll probably mess stuff up
local function vtext(str)
    local text = wibox.widget.textbox(str:gsub(".", "%1\n"))
    text:set_font("5")
    return text
end

local separator = singleton_widget(function () 
    local box = wibox.widget.textbox("  ") 
    return box
end)

local function create_vprogbar()
    local ret = awful.widget.progressbar() 
    ret:set_vertical(true)
    ret:set_width(8)
    ret:set_background_color(beautiful.bg_normal)
    return ret
end


-- Widget factory functions. If there's a matching key in the keybindings.widgets table, those keybindings are applied to this widget on creatation
local widgets = {
    clock=function (s) return awful.widget.textclock("%a %b %d, %H:%M:%S", 1) end,
    taglist=function(s, buttons)
        return awful.widget.taglist(s, awful.widget.taglist.filter.all, buttons)
    end,
    systray = wibox.widget.systray,
    promptbox = awful.widget.prompt,
    layoutbox = awful.widget.layoutbox,
    cpu_monitor = singleton_widget(function ()
        local widgets = {}
        local ret = wibox.layout.fixed.horizontal()
        local sep_widget = wibox.widget.textbox(" ") -- we resue this a ton

        local label = wibox.widget.textbox()
        ret:add(label)
        vicious.register(label, vicious.widgets.cpu,
            function (widget, args)
                -- list only real cpu cores
                for i=2,#args do
                    -- get the graph to update (and stick in separator)
                    if widgets[i] == nil then
                        widgets[i] = create_vprogbar()
                        widgets[i]:set_max_value(100)
                        ret:add(sep_widget)
                        ret:add(widgets[i])
                    end
                    widgets[i]:set_value(args[i])
                end

                return "CPU: "
            end, 3)

        return ret
        --return layout
    end),
    ram_monitor = singleton_widget(function () 
        local ret = wibox.layout.fixed.horizontal()
        local tooltip = awful.tooltip({objects = {ret}})
        ret:add(wibox.widget.textbox("RAM "))

        local graph = awful.widget.graph()
        graph:set_width(25)
        graph:set_background_color(beautiful.bg_normal)
        ret:add(graph)

        vicious.register(graph, vicious.widgets.mem, function (widget, args)
            tooltip:set_text("RAM Usage: " .. args[2] .. "M/" .. args[3] .. "M (" .. args[1] .. "%)")
            return args[1]
            end, 7)

        return ret
    end),
    weather = singleton_widget(function ()
        local ret = wibox.widget.textbox()
        vicious.register(ret, vicious.widgets.weather, "☀ ${tempc}⁰C", 61, "KPDX")
        return ret
    end),
}

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

local function construct_widget(widget, screen)
    if widgets[widget] ~= nil then
        local buttons = keybindings.widget_buttons[widget]
        local widget_obj = widgets[widget](s, buttons)
        if buttons ~= nil then
            widget_obj:buttons(buttons)
        end
        return widget_obj
    end
end

local function setup(primary_screen)
    for s=1, screen.count() do
        local created_widgets = {}
        screen_widgets[s] = created_widgets

        -- Create a tasklist widget
        created_widgets.tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, keybindings.widget_buttons.tasklist)

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        local right_layout = wibox.layout.fixed.horizontal()

        local layout = s == primary_screen and layouts.primary or layouts.secondary

        for key, value in ipairs(layout.left) do
            local widget = construct_widget(value, s)
            created_widgets[value] = widget
            left_layout:add(widget)
            if key < #layout.left then
                left_layout:add(separator())
            end
        end

        for key, value in ipairs(layout.right) do
            widget = construct_widget(value, s)
            created_widgets[value] = widget
            right_layout:add(widget)
            if key < #layout.right then
                right_layout:add(separator())
            end
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
    widgets=widgets,
    layouts=layouts,
    setup=setup
}