-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/24/2022, 7:34:59 PM
--
---@class ns
local ns = select(2, ...)

---@generic T
---@param func T
---@return T
local function memorize(func, mode)
    local cache = {}
    if mode then
        setmetatable(cache, {__mode = mode})
    end
    return function(k, ...)
        if not k then
            return
        end
        if cache[k] == nil then
            cache[k] = func(k, ...)
        end
        return cache[k]
    end
end
ns.memorize = memorize

local function colorHex(color)
    if type(color) == 'string' then
        return color
    end
    if color.colorStr then
        return color.colorStr
    end
    return format('ff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
end
ns.colorHex = colorHex

local function strcolor(text, color)
    if not text then
        return
    end
    if not color then
        return text
    end
    return WrapTextInColorCode(text, colorHex(color))
end
ns.strcolor = strcolor

ns.GREY_COLOR = colorHex({r = 0.5, g = 0.5, b = 0.5})

local L = setmetatable({}, {
    __index = function(t, k)
        return k
    end,
})

ns.L = L

ns.CLASSIFICATIONS = {
    elite = strcolor(ELITE, 'ffffff33'),
    worldboss = strcolor(BOSS, 'ffff0000'),
    rare = strcolor(L.Rare, 'ffff66ff'),
    rareelite = strcolor(L.Rare .. ELITE, 'ffffaaff'),
}

ns.RAID_ICONS = setmetatable({}, {
    __index = function(t, k)
        t[k] = format([[Interface\TargetingFrame\UI-RaidTargetingIcon_%d]], k)
        return t[k]
    end,
})

ns.FACTION_ICONS = {
    Alliance = [[Interface\Timer\Alliance-Logo]],
    Horde = [[Interface\Timer\Horde-Logo]],
    Neutral = [[Interface\Timer\Panda-Logo]],
}

ns.RAID_ICON_STRINGS = setmetatable({}, {
    __index = function(t, k)
        t[k] = format([[|TInterface\TargetingFrame\UI-RaidTargetingIcon_%d:18:18|t]], k)
        return t[k]
    end,
})

ns.CLASS_ICON_STRINGS = setmetatable({}, {
    __index = function(t, k)
        local coords = CLASS_ICON_TCOORDS[k]
        t[k] = format([[|TInterface\WorldStateFrame\ICONS-CLASSES:%%d:%%d:0:0:256:256:%d:%d:%d:%d|t]], coords[1] * 0xFF,
                      coords[2] * 0xFF, coords[3] * 0xFF, coords[4] * 0xFF)
        return t[k]
    end,
})

ns.REACTION_STRINGS = setmetatable({}, {
    __index = function(t, k)
        t[k] = format('<%s>', _G['FACTION_STANDING_LABEL' .. k])
        return t[k]
    end,
})

ns.POS_TYPE = {System = 1, Cursor = 2, Custom = 3}

do
    local stringbuilder = {}
    local sb = {}
    function stringbuilder:wipe()
        wipe(sb)
        return self
    end

    function stringbuilder:push(text)
        if text then
            sb[#sb + 1] = text
        end
    end

    function stringbuilder:join(sep)
        if #sb == 0 then
            return
        end
        return table.concat(sb, sep)
    end

    ns.stringbuilder = stringbuilder
end
