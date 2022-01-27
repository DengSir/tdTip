---@diagnostic disable: undefined-global
-- Strings.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/27/2022, 5:00:01 PM
--
---@class ns
local ns = select(2, ...)

local strcolor = ns.strcolor

local L = ns.L

local Formats = { --
    Guild = '|c{guildColor}<%s>|r',
    GuildRank = '|cffffffff-|r |c{guildRankColor}%s|r',
    NpcTitle = '|c{npcTitleColor}<%s>|r',
    Realm = '|c{realmColor}%s|r',
    Reaction = '|c{reactionColor}<%s>|r',
}
ns.Formats = Formats

local Strings = { --
    DEAD = strcolor(DEAD, ns.RED_COLOR),
    OFFLINE = strcolor(PLAYER_OFFLINE, ns.GRAY_COLOR),
    AFK = strcolor(AFK, ns.GRAY_COLOR),
    DND = strcolor(DND, ns.GRAY_COLOR),

    YOU = strcolor(format('>> %s <<', L.YOU), ns.RED_COLOR),

    TARGET = format('|cffffd100%s: %%s|r', TARGET),

    CLASSIFICATIONS = {
        elite = strcolor(ELITE, 'ffffff33'),
        worldboss = strcolor(BOSS, 'ffff0000'),
        rare = strcolor(L.Rare, 'ffff66ff'),
        rareelite = strcolor(L.Rare .. ELITE, 'ffffaaff'),
    },

    REACTIONS = setmetatable({}, {
        __index = function(t, k)
            t[k] = Formats.Reaction:format(_G['FACTION_STANDING_LABEL' .. k])
            return t[k]
        end,
    }),
}
ns.Strings = Strings

local Icons = {
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

    Class = setmetatable({}, {
        __index = function(t, k)
            local coords = CLASS_ICON_TCOORDS[k]
            t[k] = format([[|TInterface\WorldStateFrame\ICONS-CLASSES:%%d:%%d:0:0:256:256:%d:%d:%d:%d|t]],
                          coords[1] * 0xFF, coords[2] * 0xFF, coords[3] * 0xFF, coords[4] * 0xFF)
            return t[k]
        end,
    }),
}
ns.Icons = Icons
