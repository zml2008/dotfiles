local wibox = require("wibox")
local vicious = require("vicious")
local awful = require("awful")
local beautiful = require("beautiful")
--local window_mgmt = require("window_mgmt")

local widgets = {}

function widgets.define(create_func, buttons)
	return function (...)
		local ret = create_func(...)
		if buttons then
			ret:buttons(buttons)
		end
		return ret
	end
end
local define = widgets.define

local function singleton_factory(factory_func)
    local widget_obj = nil
    return function (...)
        if widget_obj == nil then
            widget_obj = factory_func(...)
        end
        return widget_obj
    end
end

local function create_vprogbar()
    local ret = awful.widget.progressbar() 
    ret:set_vertical(true)
    ret:set_width(8)
    ret:set_background_color(beautiful.bg_normal)
    return ret
end

widgets.separator = define(singleton_factory(function (s)
	return wibox.widget.textbox("  ")
end))

widgets.tasklist = define(function (s) return awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, 
				awful.util.table.join(
                     awful.button({ }, 1, function (c)
				                          if c == client.focus then
                                              c.minimized = true
                                          else
                                              -- Without this, the following
                                              -- :isvisible() makes no sense
                                              c.minimized = false
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              -- This will also un-minimize
                                              -- the client, if needed
                                              client.focus = c
                                              c:raise()
                                          end
                                      end),
                     awful.button({ }, 3, function ()
                                          if instance then
                                              instance:hide()
                                              instance = nil
                                          else
                                              instance = awful.menu.clients({ width=250 })
                                          end
                                      end),
                     awful.button({ }, 4, function ()
                                          awful.client.focus.byidx(1)
                                          if client.focus then client.focus:raise() end
                                      end),
                     awful.button({ }, 5, function ()
                                          awful.client.focus.byidx(-1)
                                          if client.focus then client.focus:raise() end
                                      end)
                )) end)
widgets.clock = define(function () return awful.widget.textclock("%a %b %d, %H:%M:%S", 1) end)
widgets.taglist = define(function(s)
        return awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.table.join(
            awful.button({ }, 1, awful.tag.viewonly),
            awful.button({ modkey }, 1, awful.client.movetotag),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, awful.client.toggletag),
            awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
            awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
        )) end)
widgets.systray = define(wibox.widget.systray)
widgets.promptbox = define(function () return awful.widget.prompt() end)
widgets.layoutbox = define(awful.widget.layoutbox, awful.util.table.join(
                       awful.button({ }, 1, function () awful.layout.inc(window_mgmt.layouts, 1) end),
                       awful.button({ }, 3, function () awful.layout.inc(window_mgmt.layouts, -1) end),
                       awful.button({ }, 4, function () awful.layout.inc(window_mgmt.layouts, 1) end),
                       awful.button({ }, 5, function () awful.layout.inc(window_mgmt.layouts, -1) end)))
widgets.cpu_monitor = define(singleton_factory(function ()
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

                return "C "
            end, 3)

        return ret
    end))
widgets.ram_monitor = define(singleton_factory(function () 
        local ret = wibox.layout.fixed.horizontal()
        local tooltip = awful.tooltip({objects = {ret}})
        ret:add(wibox.widget.textbox("R "))

        local graph = awful.widget.graph()
        graph:set_width(25)
        graph:set_background_color(beautiful.bg_normal)
        ret:add(graph)

        vicious.register(graph, vicious.widgets.mem, function (widget, args)
            tooltip:set_text("RAM Usage: " .. args[2] .. "M/" .. args[3] .. "M (" .. args[1] .. "%)")
            return args[1]
            end, 7)

        return ret
    end))
widgets.weather = define(singleton_factory(function ()
        local ret = wibox.widget.textbox()
        vicious.register(ret, vicious.widgets.weather, "☀ ${tempc}⁰C", 61, "KPDX")
        return ret
    end))
widgets.battery = define(singleton_factory(function ()
            local ret = wibox.widget.textbox()
            vicious.register(ret, vicious.widgets.bat, "$1$2", 63, "BAT0")
            return ret
        end))
widgets.volume = define(singleton_factory(function ()
    local pa = require("apw.widget")
    pa:set_width(8)
    pa:set_vertical(true)

    local ticker = timer({timeout = 10})
    ticker:connect_signal("timeout", pa.Update)
    ticker:start()
    local layout = wibox.layout.fixed.horizontal()
    layout:add(wibox.widget.textbox("V "))
    layout:add(pa)
    return layout
end))

widgets.mpd = define(singleton_factory(function ()
    local ret = wibox.widget.textbox()
    vicious.register(ret, vicious.widgets.mpd, "${state} ${Title} - ${Artist}")
    return ret
end))

return widgets
