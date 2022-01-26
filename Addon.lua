-- Addon.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/23/2022, 12:47:13 AM
--
---@class ns
local ns = select(2, ...)

---@class Addon: AceAddon-3.0, AceEvent-3.0
local Addon = LibStub('AceAddon-3.0'):NewAddon('tdTip', 'AceEvent-3.0')
ns.AddOn = Addon

function Addon:OnInitialize()
    ---@class DATABASE
    local db = {
        ---@class DATABASE.profile
        profile = { --
            showPvpName = true,
            showGuildRank = true,
            showOffline = true,
            showAFK = true,
            showDND = true,

            pos = {type = ns.POS_TYPE.System, custom = {point = 'BOTTOMRIGHT', x = -300, y = 200}},

            bar = {height = 4, padding = 9},

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
        },
    }
    ---@class db: AceDB-3.0, DATABASE
    self.db = LibStub('AceDB-3.0'):New('TDDB_TIP', db)

    local function UpdateProfile()
        return self:OnProfileUpdate()
    end

    self.db:RegisterCallback('OnProfileChanged', UpdateProfile)
    self.db:RegisterCallback('OnProfileReset', UpdateProfile)

    ---@type DATABASE.profile.colors
    ns.colors = {}

    self:LoadOptionFrame()
end

function Addon:OnEnable()
    self:OnProfileUpdate()

    self:RegisterMessage('TDTIP_SETTING_UPDATE', 'OnProfileUpdate')
end

function Addon:OnProfileUpdate()
    ---@type DATABASE.profile
    ns.profile = self.db.profile

    local colors = wipe(ns.colors)

    for k, v in pairs(ns.profile.colors) do
        colors[k] = ns.colorHex(v)
    end
end
