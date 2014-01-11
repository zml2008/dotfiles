local dkjson = require("dkjson")
local lfs = require("lfs")
local awful = require("awful")

local CONFIG_FILE = os.getenv("HOME") .. "/.config/awesome/config.json"

local config = {}


local function load_file()
    fp, err = io.open(CONFIG_FILE, 'r')
    if not fp then
        config.raw = {}
    else
        config.raw = dkjson.decode(fp:read("*a"))
        fp:close()
    end
    if not config.raw then
        config.raw = {}
    end
end
  
local function save_file()
    if not config.raw then
        return
    end
    fp, err = io.open(CONFIG_FILE, 'w')
    if not fp then return end

    fp:write(dkjson.encode(config.raw, { indent=true }))
    fp:close()
end

function config.load(section, def)
    if not config.raw then
        load_file()
    end
    if config.raw[section] then
        local res = config.raw[section]
        if def then
            res = awful.util.table.join(def, res)
            config.raw[section] = res
            save_file()
        end
        return res
    else
        if def then
            config.raw[section] = def
            save_file()
            return def
        else
            local res = {}
            config.raw[section] = res
            return res
        end
    end
end


return config
