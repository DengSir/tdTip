-- Item.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/25/2022, 5:22:33 PM
--
---@class ns
local ns = select(2, ...)

---@class Item: AceAddon-3.0, AceHook-3.0
local Item = ns.AddOn:NewModule('Item', 'AceHook-3.0')

function Item:OnEnable()

end

function Item:HookTip(tip)
    -- body...
end
