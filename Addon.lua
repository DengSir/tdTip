-- Addon.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/23/2022, 12:47:13 AM
--
---@class ns
local ns = select(2, ...)

local S = ns.Strings
local F = ns.Formats

local Formats = CopyTable(F)
wipe(F)

---@class Addon: AceAddon-3.0, AceEvent-3.0, LibClass-2.0
local Addon = LibStub('AceAddon-3.0'):NewAddon('tdTip', 'AceEvent-3.0', 'LibClass-2.0')
ns.AddOn = Addon

function Addon:OnInitialize()
    ---@class db: AceDB-3.0, DATABASE
    self.db = LibStub('AceDB-3.0'):New('TDDB_TIP', ns.DATABASE, true)

    local function UpdateProfile()
        return self:OnProfileUpdate()
    end

    self.db:RegisterCallback('OnProfileChanged', UpdateProfile)
    self.db:RegisterCallback('OnProfileReset', UpdateProfile)

    self:LoadOptionFrame()
end

function Addon:OnEnable()
    self:OnProfileUpdate()

    self:RegisterMessage('TDTIP_SETTING_UPDATE', 'OnProfileUpdate')
end

function Addon:OnProfileUpdate()
    ---@type DATABASE.profile
    ns.profile = self.db.profile

    self:UpdateColors()
    self:UpdateFormats()
end

function Addon:UpdateColors()
    local C = wipe(ns.Colors)
    for k, v in pairs(ns.profile.colors) do
        C[k] = ns.colorHex(v)
    end

    wipe(S.REACTIONS)
end

function Addon:UpdateFormats()
    for k, v in pairs(Formats) do
        F[k] = v:gsub('{(.+)}', function(x)
            return ns.colorHex(ns.profile.colors[x])
        end)
    end
end
