-- Addon.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/23/2022, 12:47:13 AM
--
---@class ns
local ns = select(2, ...)

---@class Addon: AceAddon-3.0
local Addon = LibStub('AceAddon-3.0'):NewAddon('tdTip')
ns.AddOn = Addon
