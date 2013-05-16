local awful = require("awful")
local naughty = require("naughty")

utils = {}

-- This replaces the awesome builtin quit function with one that also is kind enough to call systemd and clear up leftovers
function utils.override_awesome_quit()
    old_quit = awesome.quit
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

return utils