
local lgi = require 'lgi'
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
local dbus_pithos_proxy = nil
local state = {running = false, playing = false, song = nil}

local function init_connection()
    pcall(function () dbus_pithos_proxy = gio.DBusProxy.new_for_bus_sync(gio.BusType.SESSION, gio.DBusProxyFlags.NONE, nil, PITHOS_INTERFACE, PITHOS_OBJ_PATH, PITHOS_INTERFACE, nil) end) -- exception catch
    if dbus_pithos_proxy ~= nil then 
        state.running = true
    else
        state.running = false
        return
    end
    state.playing = controller.isplaying()
    state.song = controller.currentsong()

    dbus_pithos_proxy.on_g_signal = function (proxy, sender, signal, parameters)
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
end

local function reset_connection()
    if dbus_pithos_proxy ~= nil then
        dbus_pithos_proxy.g_connection.close_sync(nil)
        dbus_pithos_proxy = nil
        state.running = false
        state.playing = false
    end
end

awesome.connect_signal("spawn::initiated", function (c)
    if c.name == "Pithos" and not controller.isavailable() then
        init_connection()
    end
end)

awesome.connect_signal("exit", function () reset_connection() end)

-- Bridge functions

function controller.isavailable()
    return dbus_pithos_proxy ~= nil
end

function controller.spawn_pithos()
    if dbus_pithos_proxy == nil then
        awful.util.spawn("pithos")
    end
end

function controller.playpause()
    if dbus_pithos_proxy == nil then return false end
    dbus_pithos_proxy:call(PITHOS_INTERFACE .. ".PlayPause", nil, 0, DEFAULT_TIMEOUT, nil)
end

function controller.isplaying()
    if dbus_pithos_proxy == nil then return false end
    res = dbus_pithos_proxy:call_sync(PITHOS_INTERFACE .. ".IsPlaying", nil, 0, DEFAULT_TIMEOUT, nil)
    if res ~= nil and res.value ~= nil then
        return res.value[1]
    else
        return false
    end
end

function controller.currentsong()
    if dbus_pithos_proxy == nil then return nil end
    res = dbus_pithos_proxy:call_sync(PITHOS_INTERFACE .. ".GetCurrentSong", nil, 0, DEFAULT_TIMEOUT, nil)
    if res ~= nil and res.value ~= nil then
        return res.value[1]
    else
        return nil
    end
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
    if not state.running or state.song == nil then
        return self.quit_icon
    end

    local song = state.song
    if state.song == nil then
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
keybindings.widget_buttons.music_ctl = 

widgets.music_ctl = widgets.define(make, awful.util.table.join(
    awful.button({}, 1, function () controller.playpause() end)
    )
)

return {
    controller=controller,
    callbacks=callbacks
}





