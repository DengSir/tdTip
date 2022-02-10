-- Addon.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/23/2022, 12:47:13 AM
--
---@class ns
local ns = select(2, ...)

---@class Addon: AceAddon-3.0, AceEvent-3.0, LibClass-2.0
local Addon = LibStub('AceAddon-3.0'):NewAddon('tdTip', 'AceEvent-3.0', 'LibClass-2.0')
ns.AddOn = Addon

function Addon:OnInitialize()
    ---@class db: AceDB-3.0, DATABASE
    self.db = LibStub('AceDB-3.0'):New('TDDB_TIP', ns.DATABASE, true)

    self.db.RegisterCallback(self, 'OnProfileChanged', 'OnProfileUpdate')
    self.db.RegisterCallback(self, 'OnProfileReset', 'OnProfileUpdate')

    self:LoadOptionFrame()
end

function Addon:OnEnable()
    self:OnProfileUpdate()
    self:RegisterMessage('TDTIP_SETTING_UPDATE', 'OnProfileUpdate')
end

function Addon:OnProfileUpdate()
    ns.P(self.db.profile)

    for _, v in ipairs(ns.PROFILED_TABLES) do
        wipe(v)
    end
end
