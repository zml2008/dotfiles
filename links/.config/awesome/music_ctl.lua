local lgi = require('lgi')
local gio = lgi.Gio
local glib = lgi.GLib

local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")

local widgets = require("widgets")


-- constants
local PITHOS_INTERFACE = "net.kevinmehall.Pithos"
local PITHOS_OBJ_PATH = "/net/kevinmehall/Pithos"
local DEFAULT_TIMEOUT = 1000
local controller = {}

local callbacks = {play={}, song={}}
function callbacks:register(type, callback_func)
    table.insert(self[type], callback_func)
end

-- Connection management
local state = {playing = false, song = nil}
function state.running()
    return controller.dbus_proxy and not controller.dbus_proxy.g_connection:is_closed()
end
controller.state = state

local function valid_variant(var)
    print("mus variant: " .. (var and var:print(true) or "null"))
    return var and var.type and var.value
end

controller.dbus_proxy = gio.DBusProxy.new_for_bus_sync(gio.BusType.SESSION,
                                            gio.DBusProxyFlags.DO_NOT_AUTO_START,
                                            nil,
                                            PITHOS_INTERFACE,
                                            PITHOS_OBJ_PATH,
                                            PITHOS_INTERFACE)

controller.dbus_proxy.on_g_signal = function (proxy, sender, signal, parameters)
    if not valid_variant(parameters) then
        return
    end

    if signal == "PlayStateChanged" then
        print("Signal: PlayStateChanged")
        state.playing = parameters.value[1]
        for _, v in ipairs(callbacks.play) do v() end
    elseif signal == "SongChanged" then
        print("Signal: SongChanged")
        state.song = parameters.value[1]
        for _, v in ipairs(callbacks.song) do v() end
    end
end


-- Functions only used to initialize the state

local function isplaying()
    if not state.running() then return false end
    res = controller.dbus_proxy:call_sync(PITHOS_INTERFACE .. ".IsPlaying", nil, 0, DEFAULT_TIMEOUT, nil)
    if valid_variant(res) then
        return res.value[1]
    else
        return false
    end
end

local function currentsong()
    if not state.running() then return nil end
    res = controller.dbus_proxy:call_sync(PITHOS_INTERFACE .. ".GetCurrentSong", nil, 0, DEFAULT_TIMEOUT, nil)
    if valid_variant(res) then
        return res.value[1]
    else
        return nil
    end
end


local function init_connection()
    if not state.running() then
        return
    end

    state.playing = isplaying()
    state.song = currentsong()

end

local function reset_connection()
    if state.running() then
        controller.dbus_proxy.g_connection:close_sync(nil)
        state.playing = false
    end
end

awesome.connect_signal("spawn::initiated", function (c)
    if c.name == "Pithos" and not state.running() then
        init_connection()
    end
end)

awesome.connect_signal("exit", function () reset_connection() end)

-- Bridge functions

function controller.spawn_pithos()
    if controller.dbus_proxy == nil then
        awful.util.spawn("pithos")
    end
end

function controller.playpause()
    if not state.running() then return nil end
    controller.dbus_proxy:call(PITHOS_INTERFACE .. ".PlayPause", nil, 0, DEFAULT_TIMEOUT, nil)
end


-- Widget definition

local ctl_widget = {
    quit_icon = "◾", 
    playing_icons = { 
        [true]="▶", 
        [false]="||"
    }
}

function ctl_widget:update_txt()
    self:set_text(self:generate_title())
end

function ctl_widget:generate_title()
    local song = state.song
    if state.song == nil or not state.running() then
        return self.quit_icon
    end
    
    local title = song.title or "Unknown"
    local artist = song.artist or "Unknown"
    return self.playing_icons[state.playing] .. " " .. title .. " | " .. artist
    -- text format: "play/paused icon song | album | artist"
end

local function make()
    local box = wibox.widget.textbox()
    -- Initialize attributes
    box = awful.util.table.join(box, ctl_widget)

    callbacks:register("play", function () box:update_txt() end)
    callbacks:register("song", function () box:update_txt() end)

    box:update_txt()
    return box
end

init_connection()
-- Install into registry
widgets.music_ctl = widgets.define(make, awful.util.table.join(
    awful.button({}, 1, function () controller.playpause() end)
    )
)

return {
    controller=controller,
    callbacks=callbacks
}





