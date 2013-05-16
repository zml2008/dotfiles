local beautiful = require("beautiful")
local lfs = require("lfs")


local shiny = { mt = {}}
shiny.path =  os.getenv("HOME") .. "/.config/awesome/themes/?.lua;/usr/share/awesome/themes/?.lua"

local function match_theme(name)
	return package.searchpath(name .. ".theme", shiny.path)
end

local THEME_REGEX = "\\@(.*)?theme.lua"

function shiny.theme_base(stacklevel)
	if stacklevel == nil then stacklevel = 1 end
	fname = debug.getinfo(stacklevel + 1, 'S').source -- get info from calling file (should be a theme's theme.lua)
	if fname[0] == "@" then
		local basedir = fname:match(THEME_REGEX)
		if not basedir then
			basedir = lfs.currentdir()
		end
		return { basedir = basedir }
	else
		return { basedir = lfs.currentdir() }
	end
end

-- To be used in a theme file for parent functions
function shiny.theme_inherit(name)
	local success
	local dir = match_theme(name)
	success, parent_theme = pcall(function() return dofile(dir) end)
	if not parent_theme then
		return shiny.theme_base(2)
	else
		if not parent_theme.basedir then
			parent_theme.basedir = dir:match(THEME_REGEX)
		end
		return parent_theme
	end
end

local function to_hex_str(n)
	if type(n) == "string" then n = tonumber(n) end
	return string.format("%x", n)
end

function shiny.color(r, g, b, a) -- or (rgb, a)
	if b == nil then
		if r[0] ~= '#' then r = '#' .. r end
		return r .. to_hex_str(g)
	else
		local color_str = '#' .. to_hex_str(r) .. to_hex_str(g) .. to_hex_str(b)
		if a ~= nil then color_str = color_str .. to_hex_str(a) end
		return color_str
	end
end

-- to be used for theme initialization

function shiny.init(name)
	return beautiful.init(match_theme(name))
end

function shiny.mt:__index(k)
	return beautiful[k]
end

setmetatable(shiny, shiny.mt)

return shiny