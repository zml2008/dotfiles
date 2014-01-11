local naughty = require("naughty")
local irc = require("irc")
local socket = require("socket")

local config = require("config")
local capi = {
    timer=timer
}

local ircnotify = {}

function ircnotify.setup_irc()
    local config = config.load("ircnotify", {nick = socket.dns.gethostname(),
                                            server = "changeme",
                                            port = 6667,
                                            channel = "#ircnotify"})

    if not config.server or config.server == "changeme" then
        return
    end

    local bot = irc.new({ nick = config.nick })
    function bot:reconnect()
        self:connect(config.server, config.port)
        self:join(config.channel)
    end
    bot:hook("OnDisconnect", function (message, error)
        local t = capi.timer({timeout=30})
        t:connect_signal("timeout", function() 
            bot:reconnect()
            t:stop()
        end)
        t:start()
    end)

    bot:reconnect()

    local bot_timer = capi.timer({timeout=0.5})
    bot_timer:connect_signal("timeout", function() bot:think() end)
    bot_timer:start()

    function naughty.config.notify_callback(args)
        if args.appname ~= "HexChat" then
            local msg = ""
            if args.appname then msg = args.appname .. " - " end
            msg = msg .. args.title .. ": " .. args.text
            bot:sendChat(config.channel, msg)
            return args
        end
        return args
    end
end

return ircnotify

