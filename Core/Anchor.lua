-- Anchor.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/25/2022, 4:49:34 PM
--
---@class ns
local ns = select(2, ...)

---@class Anchor: AceAddon-3.0, AceHook-3.0
local Anchor = ns.AddOn:NewModule('Anchor', 'AceHook-3.0')
ns.Anchor = Anchor

function Anchor:OnInitialize()
    ---@type AnchorMargins
    self.margins = {}

    self.tip = LibStub('LibTooltipExtra-1.0'):New(GameTooltip)

    self.cursorUpdater = CreateFrame('Frame', nil, self.tip)
    self.cursorUpdater:Hide()
    self.cursorUpdater:SetScript('OnUpdate', function(f, elapsed)
        f.timr = (f.timr or 0) - elapsed
        if f.timr > 0 then
            return
        end
        f.timr = 0.05
        self:UpdateAnchor()
    end)

    if ns.AddOn.db.profile.posType == ns.POS_TYPE.Cursor then
        self.cursorUpdater:Show()
    end

    self.mask = self.tip:CreateTexture(nil, 'OVERLAY')
    self.mask:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
    self.mask:SetPoint('TOPLEFT', 3, -3)
    self.mask:SetPoint('BOTTOMRIGHT', self.tip.NineSlice, 'TOPRIGHT', -3, -32)
    self.mask:SetBlendMode('ADD')
    self.mask:SetGradientAlpha('VERTICAL', 0, 0, 0, 0, 0.9, 0.9, 0.9, 0.4)
end

function Anchor:OnEnable()
    self:HookScript(self.tip, 'OnTooltipCleared')
    self:SecureHook('GameTooltip_SetDefaultAnchor', 'OnTooltipSetDefaultAnchor')
end

function Anchor:OnTooltipCleared()
    self.tip.tip.default = nil
    self.tip.NineSlice:ClearAllPoints()
    self.tip.NineSlice:SetAllPoints(self.tip)
end

function Anchor:OnTooltipSetDefaultAnchor(tip, parent)
    if tip ~= self.tip.tip then
        return
    end
    self:UpdateAnchor()
end

function Anchor:SetMargins(left, right, top, bottom)
    ---@class AnchorMargins
    local margins = self.margins
    margins.left = left or nil
    margins.right = right or nil
    margins.top = top or nil
    margins.bottom = bottom or nil
    self:UpdateMargins()
    self:UpdateAnchor()
end

function Anchor:UpdateMargins()
    local margins = self.margins
    if not next(margins) then
        self.tip.NineSlice:ClearAllPoints()
        self.tip.NineSlice:SetAllPoints(true)
    else
        self.tip.NineSlice:ClearAllPoints()
        self.tip.NineSlice:SetPoint('TOPLEFT', -(margins.left or 0), margins.top or 0)
        self.tip.NineSlice:SetPoint('BOTTOMRIGHT', margins.right or 0, -(margins.bottom or 0))
    end
end

function Anchor:UpdateAnchor()
    if not self.tip.default then
        return
    end

    -- local owner = self.tip:GetOwner()
    -- if not owner or owner == UIParent or owner == WorldFrame then
        local posType = ns.AddOn.db.profile.posType
        local pos
        if posType == ns.POS_TYPE.System then
            pos = self:GetSystemAnchor()
        elseif posType == ns.POS_TYPE.Custom then
            pos = self:GetCustomAnchor()
        elseif posType == ns.POS_TYPE.Cursor then
            pos = self:GetCursorAnchor()
        end

        self.tip:ClearAllPoints()
        self.tip:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    -- end
end

function Anchor:GetSystemAnchor()
    return self:GetAnchor('BOTTOMRIGHT', -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y)
end

function Anchor:GetCustomAnchor()
    local pos = ns.AddOn.db.profile.posCustom
    return self:GetAnchor(pos.point, pos.x, pos.y)
end

function Anchor:GetCursorAnchor()
    local x, y = GetCursorPosition()
    local scale = self.tip:GetEffectiveScale()
    return self:GetAnchor('BOTTOMLEFT', x / scale + 20, y / scale)
end

local anchor = {}
function Anchor:GetAnchor(point, x, y)
    local margins = self.margins
    local atRight = point == 'BOTTOMRIGHT' or point == 'TOPRIGHT'
    local atTop = point == 'TOPLEFT' or point == 'TOPRIGHT'

    if atRight then
        x = x - (margins.right or 0)
    else
        x = x + (margins.left or 0)
    end

    if atTop then
        y = y - (margins.top or 0)
    else
        y = y + (margins.bottom or 0)
    end

    anchor.point = point
    anchor.x = x
    anchor.y = y

    return anchor
end
