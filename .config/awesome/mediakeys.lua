local awful = require("awful")
local keybindings = require("keybindings")
local pa = require("pulseaudio.pulseaudio")


keybindings.globalkeys(awful.util.table.join(
	awful.key({}, "XF86MonBrightnessDown", function () coroutine.resume(coroutine.create(function() 
			awful.util.spawn("xbacklight -dec 5", false) 
		end))
	end),
	awful.key({}, "XF86MonBrightnessUp", function () coroutine.resume(coroutine.create(function() 
			awful.util.spawn("xbacklight -inc 5", false) 
		end)) 
	end),
	awful.key({}, "XF86AudioMute", function () pulseaudio.volumeMute() end),
	awful.key({}, "XF86AudioLowerVolume", function () pulseaudio.volumeDown() end),
	awful.key({}, "XF86AudioRaiseVolume", function () pulseaudio.volumeUp() end),
	awful.key({}, "XF86Display", function () end)
))