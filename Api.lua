---@diagnostic disable: undefined-global
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
    if not text or not color then
        return text
    end
    return WrapTextInColorCode(text, colorHex(color))
end

do
    local _sb = {}

    function ns.strjoin(...)
        local sb = wipe(_sb)
        for i = 1, select('#', ...) do
            local v = select(i, ...)
            if v ~= nil then
                sb[#sb + 1] = v
            end
        end
        if #sb > 0 then
            return table.concat(sb, ' ')
        end
    end
end

function ns.UnitColor(unitOrIsPlayer, classFileName, reaction)
    local isPlayer, color
    if classFileName or reaction then
        isPlayer = unitOrIsPlayer
    else
        local unit = unitOrIsPlayer
        isPlayer = UnitIsPlayer(unit)
        classFileName = UnitClassBase(unit)
        reaction = UnitReaction(unit, 'player')
    end

    if isPlayer then
        if classFileName then
            color = RAID_CLASS_COLORS[classFileName]
        end
    else
        if reaction then
            color = FACTION_BAR_COLORS[reaction]
        end
    end
    return color or HIGHLIGHT_FONT_COLOR
end

ns.GRAY_COLOR = colorHex(GRAY_FONT_COLOR)
ns.WHITE_COLOR = colorHex(HIGHLIGHT_FONT_COLOR)
ns.RED_COLOR = colorHex(RED_FONT_COLOR)
ns.GOLD_COLOR = colorHex(NORMAL_FONT_COLOR)

ns.L = LibStub('AceLocale-3.0'):GetLocale('tdTip')

ns.POS_TYPE = { --
    System = 1,
    Cursor = 2,
    Custom = 3,
}

ns.DEFAULT_CUSTOM_POSITION = {point = 'BOTTOMRIGHT', x = -300, y = 200}

---@class DATABASE
ns.DATABASE = {
    ---@class DATABASE.profile
    profile = { --
        showPvpName = true,
        showGuildRank = true,
        showOffline = true,
        showAFK = true,
        showDND = true,
        showFactionIcon = true,
        showClassIcon = true,
        showTargetBy = true,

        classIconSize = 18,
        raidIconSize = 32,

        pos = {type = ns.POS_TYPE.System, custom = ns.DEFAULT_CUSTOM_POSITION},

        bar = {height = 4, paddingX = 9, paddingY = 9},

        ---@class DATABASE.profile.colors
        colors = {
            guildColor = {r = 1, g = 0, b = 1},
            guildRankColor = {r = 0.8, g = 0.53, b = 1},
            friendColor = {r = 0, g = 1, b = 0.2},
            enemyColor = {r = 1, g = 0, b = 0},
            playerTitleColor = {r = 0.8, g = 1, b = 1},
            realmColor = {r = 0, g = 0.93, b = 0.93},

            npcTitleColor = {r = 0.6, g = 0.9, b = 0.9},
            reactionColor = {r = 0.2, g = 1, b = 1},
        },

        showItemLevel = true,
        showItemLevelOnlyEquip = true,
        showItemIcon = true,
        showItemBorderColor = true,

        showSpellIcon = true,
    },
}

ns.PROFILED_TABLES = {}
function ns.profiled(get)
    local tbl = {}
    tinsert(ns.PROFILED_TABLES, tbl)

    return setmetatable(tbl, {
        __index = function(t, k)
            local v = get(k)
            t[k] = v
            return v
        end,
    })
end

local frames = {'tdDevToolsFrame', 'WeakAurasOptions', 'tdPack2RuleOptionFrame'}

function ns.InDevMode()
    for _, v in ipairs(frames) do
        local f = _G[v]
        if f and f:IsVisible() then
            return true
        end
    end
end
