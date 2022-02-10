-- Skin.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/26/2022, 3:20:29 PM
--
---@type ns
local ns = select(2, ...)

---@class Skin: AceAddon-3.0, AceEvent-3.0, AceHook-3.0
local Skin = ns.AddOn:NewModule('Skin', 'AceEvent-3.0', 'AceHook-3.0')

function Skin:OnInitialize()
    ---@type table<Frame, Texture>
    self.masks = {}
end

function Skin:OnEnable()
    self:ApplyFrames(ns.Tooltips)
    self:ApplyFrames(ns.Frames)

    self.dropmenuAppliedLevel = 0
    self:UIDropDownMenu_CreateFrames()
    self:SecureHook('UIDropDownMenu_CreateFrames')
end

function Skin:OnDisable()
    for _, texture in ipairs(self.masks) do
        texture:Hide()
    end
end

function Skin:UIDropDownMenu_CreateFrames()
    for i = self.dropmenuAppliedLevel + 1, UIDROPDOWNMENU_MAXLEVELS do
        self:Apply(_G['DropDownList' .. i .. 'MenuBackdrop'])
    end
end

function Skin:ApplyFrames(frames)
    for _, v in ipairs(frames) do
        local t = type(v)
        if t == 'string' then
            local frame = _G[v]
            if frame then
                self:Apply(frame)
            end
        elseif t == 'function' then
            local ok, frame = pcall(v)
            if ok and frame then
                self:Apply(frame)
            end
        elseif t == 'table' and C_Widget.IsFrameWidget(v) then
            self:Apply(v)
        end
    end
end

function Skin:Apply(frame)
    local mask = self.masks[frame]
    if not mask then
        local parent = frame.NineSlice or frame

        mask = parent:CreateTexture(nil, 'OVERLAY')
        mask:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
        mask:SetPoint('TOPLEFT', 3, -3)
        mask:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', -3, -32)
        mask:SetBlendMode('ADD')
        mask:SetGradientAlpha('VERTICAL', 0, 0, 0, 0, 0.9, 0.9, 0.9, 0.4)

        self.masks[frame] = mask
    end

    mask:Show()

    if frame.shoppingTooltips then
        for _, tip in ipairs(frame.shoppingTooltips) do
            self:Apply(tip)
        end
    end
end
