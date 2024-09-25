---@diagnostic disable: undefined-global
-- Data.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/27/2022, 5:00:01 PM
--
---@class ns
local ns = select(2, ...)

local strcolor = ns.strcolor
local colorHex = ns.colorHex

local L = ns.L

---@type DATABASE.profile
local P
do
    local profile
    P = setmetatable({}, {
        __index = function(_, k)
            return profile[k]
        end,
        __newindex = function(t, k, v)
            profile[k] = v
        end,
        __call = function(_, p)
            profile = p
        end,
    })
    ns.P = P
end

---@type Formats
local F
do
    ---@class Formats
    local Formats = { --
        Guild = '|c{guildColor}<%s>|r',
        GuildRank = '|c{guildRankColor}%s|r',
        NpcTitle = '|c{npcTitleColor}<%s>|r',
        Realm = '|c{realmColor}%s|r',
        Reaction = '|c{reactionColor}<%s>|r',
    }

    F = ns.profiled(function(k)
        return Formats[k]:gsub('{(.+)}', function(x)
            return colorHex(P.colors[x])
        end)
    end)
    ns.F = F
end

---@class Strings
ns.S = { --
    DEAD = strcolor(DEAD, ns.RED_COLOR),
    OFFLINE = strcolor(PLAYER_OFFLINE, ns.GRAY_COLOR),
    AFK = strcolor(DEFAULT_AFK_MESSAGE, ns.GRAY_COLOR),
    DND = strcolor(DEFAULT_DND_MESSAGE, ns.GRAY_COLOR),

    YOU = strcolor(format('>> %s <<', L.YOU), ns.RED_COLOR),

    TARGET = format('|cffffd100%s: %%s|r', TARGET),

    CLASSIFICATIONS = {
        elite = strcolor(ELITE, 'ffffff33'),
        worldboss = strcolor(BOSS, 'ffff0000'),
        rare = strcolor(L.Rare, 'ffff66ff'),
        rareelite = strcolor(L.Rare .. ELITE, 'ffffaaff'),
    },

    REACTIONS = ns.profiled(function(k)
        return ns.F.Reaction:format(_G['FACTION_STANDING_LABEL' .. k])
    end),

    ITEM_LEVEL = NORMAL_FONT_COLOR_CODE .. ITEM_LEVEL_PLUS:gsub(' *%%d%+$', ' %%d') .. '|r',
}

---@class Icons
ns.O = {
    Raid = setmetatable({}, {
        __index = function(t, k)
            t[k] = format([[Interface\TargetingFrame\UI-RaidTargetingIcon_%d]], k)
            return t[k]
        end,
    }),

    Faction = {
        Alliance = [[Interface\Timer\Alliance-Logo]],
        Horde = [[Interface\Timer\Horde-Logo]],
        Neutral = [[Interface\Timer\Panda-Logo]],
    },

    Class = ns.profiled(function(k)
        local coords = CLASS_ICON_TCOORDS[k]
        local size = P.classIconSize
        return format([[|TInterface\WorldStateFrame\ICONS-CLASSES:%d:%d:0:0:256:256:%d:%d:%d:%d|t]], size, size,
                      coords[1] * 255, coords[2] * 255, coords[3] * 255, coords[4] * 255)
    end),
}

---@type DATABASE.profile.colors
ns.C = ns.profiled(function(k)
    return colorHex(P.colors[k])
end)

ns.Tooltips = {'GameTooltip', 'ItemRefTooltip', 'WorldMapTooltip'}

ns.Frames = {
    'LibDBIconTooltip', 'AceGUITooltip', 'AceConfigDialogTooltip', 'FriendsTooltip', 'ChatMenu', 'EmoteMenu',
    'LanguageMenu', 'VoiceMacroMenu',
}
