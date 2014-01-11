-- This file contains the base storage for keybindings. Keys can be registered though here to avoid conflicts
local awful = require("awful")
local root = root
local pairs = pairs

module("keybindings")

local store = {
  globalkeys = {},
  globalbuttons = {},
  clientkeys = {},
  clientbuttons = {}
}

function globalkeys(...) 
  if ... then
    store.globalkeys = awful.util.table.join(store.globalkeys, ...)
    root.keys(store.globalkeys)
  else
    return store.globalkeys
  end
end

function globalbuttons(add_table) 
  if add_table then
    for k, v in pairs(add_table) do
      store.globalbuttons[k] = v
    end
    root.buttons(store.globalbuttons)
  else
    return store.globalbuttons
  end
end

function clientkeys(add_table) 
  if add_table then
    for k, v in pairs(add_table) do
      store.clientkeys[k] = v
    end
  else
    return store.clientkeys
  end
end

function clientbuttons(add_table) 
  if add_table then
    for k, v in pairs(add_table) do
      store.clientbuttons[k] = v
    end
  else
    return store.clientbuttons
  end
end
