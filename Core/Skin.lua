-- Skin.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/26/2022, 3:20:29 PM
--
---@type ns
local ns = select(2, ...)

---@class Skin: AceAddon-3.0, AceEvent-3.0
local Skin = ns.AddOn:NewModule('Skin', 'AceEvent-3.0')

local frames = { --
    GameTooltip, --
    DropDownList1MenuBackdrop, --
    DropDownList2MenuBackdrop, --
    LibDBIconTooltip, --
    AceGUITooltip, --
    AceConfigDialogTooltip, --
}

function Skin:OnInitialize()

end

function Skin:OnEnable()
    for _, frame in ipairs(frames) do
        self:Apply(frame)
    end
end

function Skin:Apply(frame)
    local parent = frame.NineSlice or frame

    local mask = parent:CreateTexture(nil, 'OVERLAY')
    mask:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
    mask:SetPoint('TOPLEFT', 3, -3)
    mask:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', -3, -32)
    mask:SetBlendMode('ADD')
    mask:SetGradientAlpha('VERTICAL', 0, 0, 0, 0, 0.9, 0.9, 0.9, 0.4)
end
