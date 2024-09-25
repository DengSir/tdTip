-- Anchor.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/25/2022, 4:49:34 PM
--
---@class ns
local ns = select(2, ...)

local P = ns.P
local POS_TYPE = ns.POS_TYPE

---@class Anchor: AceModule, AceHook-3.0, AceEvent-3.0
local Anchor = ns.AddOn:NewModule('Anchor', 'AceHook-3.0', 'AceEvent-3.0')
ns.Anchor = Anchor

function Anchor:OnInitialize()
    ---@type AnchorMargins
    self.margins = {}

    self.tip = LibStub('LibTooltipExtra-1.0'):New(GameTooltip)
end

function Anchor:OnEnable()
    self:HookScript(self.tip, 'OnTooltipCleared')
    self:SecureHook('GameTooltip_SetDefaultAnchor', 'OnTooltipSetDefaultAnchor')
end

function Anchor:OnTooltipCleared()
    wipe(self.margins)
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

    local posType = P.pos.type
    if posType == POS_TYPE.Cursor then
        local owner = self.tip:GetOwner()
        if not owner or owner == UIParent or owner == WorldFrame then
            if self.tip:GetUnit() then
                self.tip:SetAnchorType('ANCHOR_CURSOR_RIGHT', 30, -20)
            else
                self.tip:SetAnchorType('ANCHOR_CURSOR')
            end
        else
            if owner:GetRight() < GetScreenWidth() / 2 then
                self.tip:SetAnchorType('ANCHOR_RIGHT')
            else
                self.tip:SetAnchorType('ANCHOR_LEFT')
            end
        end
    else
        local point, x, y = self:GetPointArgs()
        self.tip:ClearAllPoints()
        self.tip:SetPoint(point, UIParent, point, x, y)
    end
end

function Anchor:GetPointArgs()
    local posType = P.pos.type
    if posType == POS_TYPE.System then
        return self:CalcPointArgs('BOTTOMRIGHT', -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y)
    elseif posType == POS_TYPE.Custom then
        local pos = P.pos.custom
        return self:CalcPointArgs(pos.point, pos.x, pos.y)
    end
end

function Anchor:CalcPointArgs(point, x, y)
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

    return point, x, y
end
