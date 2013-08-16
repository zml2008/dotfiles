local awful = require("awful")
local keybindings = require("keybindings")
local pa = require("apw.widget")


keybindings.globalkeys(awful.util.table.join(
	awful.key({}, "XF86MonBrightnessDown", function () coroutine.resume(coroutine.create(function() 
			awful.util.spawn("xbacklight -dec 5", false) 
		end))
	end),
	awful.key({}, "XF86MonBrightnessUp", function () coroutine.resume(coroutine.create(function() 
			awful.util.spawn("xbacklight -inc 5", false) 
		end)) 
	end),
	awful.key({}, "XF86AudioMute", pa.ToggleMute),
	awful.key({}, "XF86AudioLowerVolume", pa.Down),
	awful.key({}, "XF86AudioRaiseVolume", pa.Up),
	awful.key({}, "XF86Display", function () end)
))
