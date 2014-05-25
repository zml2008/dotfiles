local awful = require('awful')
awful.rules = require('awful.rules')
local naughty = require('naughty')
local capi = {
    tag = tag,
    screen = screen,
    client = client,
    mouse = mouse,
    }

local signals = {
    "property::sync_screens", "property::persist",
}

for _, v in ipairs(signals) do
    capi.tag.add_signal(v)
end

local tagged = {
    tags = {},
    tag_props = {},
    default_tag = {
        name = "", -- The name to refer to the tag by. Does not have to be unique across all screens
        screen = 1, -- The screen(s) instances of the tag appear on
        sync_screens = false, -- When one screen activates the tag, activate it on all other screens too
        -- Plus any other options that can be set as a tag property
    }
}

-- Make input tags inherit from stuff we set above
local tag_mt = {}
function tag_mt.__index(t, item)
    return tagged.default_tag[item]
end

function tag_mt.__ipairs(t)
    if t.in_iter then
        return next, t, 0
    end
    t.in_iter = true
    local new_t = awful.util.table.join(tagged.default_tag, t)
    t.in_iter = false
    return ipairs(new_t)
end

function tag_mt.__pairs(t)
    if t.in_iter then
        return next, t, nil
    end
    t.in_iter = true
    local new_t = awful.util.table.join(tagged.default_tag, t)
    t.in_iter = false
    return pairs(new_t)
end

-- =============
-- API functions
-- =============
local patch_funcs = {
    add=awful.tag.add,
    viewonly=awful.tag.viewonly,
}

local function get_tag_data(name, screen)
    local data = tagged.tag_props[name]
    if not data then return nil end
    if screen then
        data = data[screen]
    end
    return data
end

--function awful.tag.add(name, props)
--    if not props then
--        props = get_tag_data(name, capi.mouse.screen)
--    elseif tagged.tag_props[name] then
--        props = afwul.util.table.join(get_tag_data(name, capi.mouse.screen), props)
--    end
--    patch_funcs.add(name, props)
--end

function awful.tag.viewonly(target, sync_screens)
    if awful.tag.getproperty(target, "sync_screens") and (sync_screens == true or sync_screens == nil) then
        for _, t in ipairs(tagged.tags[target.name]) do
            patch_funcs.viewonly(t)
        end
    else
        patch_funcs.viewonly(target)
    end
end

function tagged.init(tag_conf, default_layout)
    if default_layout ~= nil then
        tagged.default_tag.layout = default_layout
    end
    local added_s = {}
    for i, v in ipairs(tag_conf) do
        setmetatable(v, tag_mt)
        tagged.tag_props[v.name] = v
        local tag_screens = {}
        tagged.tags[v.name] = tag_screens
        if type(v.screen) == "number" then
            if v.screen <= screen.count() then
                tag_screens[v.screen] = awful.tag.add(v.name, v)
                if not added_s[v.screen] then
                    tag_screens[v.screen].selected = true
                    added_s[v.screen] = true
                end
            end
        else
            local orig_screens = v.screen
            for _, s in ipairs(v.screen) do
                if s <= screen.count() then
                    v.screen = s
                    tag_screens[s] = awful.tag.add(v.name, v)
                    if not added_s[v.screen] then
                        tag_screens[v.screen].selected = true
                        added_s[v.screen] = true
                    end
                end
            end
            v.screen = orig_screens
        end
    end
end


-- Actions:
-- window create: move to expected tag
-- Start: 1. Apply initial tag settings 2. Move window arrangements
-- Tag change: Check sync screens property
-- Window switches tag
return tagged

