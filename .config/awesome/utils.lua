require("defines")
local awful = require("awful")
local naughty = require("naughty")
local keybindings = require("keybindings")
local bar = require("bar")

local utils = {}

-- This replaces the awesome builtin quit function with one that also is kind enough to call systemd and clear up leftovers
function utils.override_awesome_quit()
    local old_quit = awesome.quit
    awesome.quit = function ()
        old_quit()
        awful.spawn("systemctl --user exit") -- Might cause loop issues with awesome, hopefully they have protection against that?
    end
end


function utils.check_errors()
	-- Check if awesome encountered an error during startup and fell back to
	-- another config (This code will only ever execute for the fallback config)
	if awesome.startup_errors then
    	naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
	end

	-- Handle runtime errors after startup
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
  	-- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, an error happened!",
                     text = err })
        in_error = false
    end)
end

keybindings.globalkeys(awful.util.table.join(
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- Prompt
    awful.key({ modkey },            "r",     
      function () 
        local pbox = bar.screen_widgets[mouse.screen].promptbox
        if pbox then
          pbox:run()
        end
      end),

    awful.key({ modkey }, "x",
        function ()
            local pbox = bar.screen_widgets[mouse.screen].promptbox
            if pbox then
                awful.prompt.run({ prompt = "Run Lua code: " },
                pbox.widget,
                awful.util.eval, nil,
                awful.util.getdir("cache") .. "/history_eval")
            end
        end)
    ))

return utils