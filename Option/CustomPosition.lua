-- CustomPosition.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/27/2022, 10:46:02 AM
--
---@class ns
local ns = select(2, ...)

---@class UI.CustomPosition: Object, tdTipCustomPositionFrameTemplate
---@field buttons CheckButton[]
local CustomPosition = ns.AddOn:NewClass('UI.CustomPosition', 'Frame')
ns.CustomPosition = CustomPosition

function CustomPosition:Constructor()
    self:SetFrameStrata('FULLSCREEN_DIALOG')
    self:RegisterForDrag('LeftButton')
    self:SetScript('OnDragStart', self.StartMoving)
    self:SetScript('OnDragStop', self.OnDragStop)
    self:SetScript('OnShow', self.Update)
end

function CustomPosition:OnDragStop()
    self:StopMovingOrSizing()
    self:OnCustomPositionUpdate()
end

function CustomPosition:Update()
    local pos = ns.profile.pos.custom

    self:ClearAllPoints()
    self:SetPoint(pos.point, pos.x, pos.y)

    for _, button in ipairs(self.buttons) do
        button:SetChecked(pos.point == button:GetPoint())
    end
end

function CustomPosition:UpdateAnchor(point)
    self:OnCustomPositionUpdate(point)
end

function CustomPosition:OnCustomPositionUpdate(point)
    point = point or ns.profile.pos.custom.point

    local x, y
    if point == 'TOPLEFT' then
        x = self:GetLeft()
        y = self:GetTop() - UIParent:GetHeight()
    elseif point == 'TOPRIGHT' then
        x = self:GetRight() - UIParent:GetWidth()
        y = self:GetTop() - UIParent:GetHeight()
    elseif point == 'BOTTOMLEFT' then
        x = self:GetLeft()
        y = self:GetBottom()
    elseif point == 'BOTTOMRIGHT' then
        x = self:GetRight() - UIParent:GetWidth()
        y = self:GetBottom()
    end

    local pos = ns.profile.pos.custom
    pos.point = point or pos
    pos.x = x
    pos.y = y

    self:Update()
end

function CustomPosition:Reset()
    ns.profile.pos.custom = CopyTable(ns.DEFAULT_CUSTOM_POSITION)
    self:Update()
end
