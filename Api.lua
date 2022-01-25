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
ns.colorHex = memorize(colorHex, 'k')

function ns.strcolor(text, color)
    if not text then
        return
    end
    if not color then
        return text
    end
    return WrapTextInColorCode(text, colorHex(color))
end

ns.GREY_COLOR = colorHex({r = 0.5, g = 0.5, b = 0.5})
ns.FRIEND_COLOR = colorHex({r = 0.00, g = 1.00, b = 0.20})
ns.ENEMY_COLOR = colorHex({r = 1.00, g = 0.20, b = 0.00})
ns.GUILD_COLOR = colorHex({r = 1.00, g = 0.00, b = 1.00})
ns.NPC_TITLE_COLOR = 'ff99e8e8'

local L = setmetatable({}, {
    __index = function(t, k)
        return k
    end,
})

ns.CLASSIFICATIONS = {
    elite = format('|cffffff33%s|r', ELITE),
    worldboss = format('|cffff0000%s|r', BOSS),
    rare = format('|cffff66ff%s|r', L.Rare),
    rareelite = format('|cffffaaff%s%s|r', L.Rare, ELITE),
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
