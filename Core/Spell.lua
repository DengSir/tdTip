-- Spell.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/27/2022, 11:27:53 AM
--
---@class ns
local ns = select(2, ...)

local P = ns.P

local LibTooltipExtra = LibStub('LibTooltipExtra-1.0')

---@class Spell: AceAddon-3.0, AceEvent-3.0, AceHook-3.0
local Spell = ns.AddOn:NewModule('Spell', 'AceEvent-3.0', 'AceHook-3.0')

function Spell:OnEnable()
    for _, name in ipairs(ns.Tooltips) do
        local rawTip = _G[name]
        if rawTip then
            self:HookScript(rawTip, 'OnTooltipSetSpell')
            self:SecureHook(rawTip, 'SetUnitAura')
            self:SecureHook(rawTip, 'SetUnitBuff')
            self:SecureHook(rawTip, 'SetUnitDebuff')
        end
    end
end

function Spell:OnTooltipSetSpell(rawTip)
    local _, spellId = rawTip:GetSpell()
    if not spellId then
        return
    end

    local tip = LibTooltipExtra:New(rawTip)

    if P.showSpellIcon then
        local icon = select(3, GetSpellInfo(spellId))
        if icon then
            local fontString = tip:GetFontStringLeft(1)
            local text = fontString:GetText()

            fontString:SetFormattedText('|T%s:18:18|t %s', icon, text)
        end
    end

    do
        local fontString = tip:GetFontStringRight(1)
        local text = fontString:GetText()
        if not text or text == '' then
            local subtext = GetSpellSubtext(spellId)
            if subtext then
                fontString:SetText(subtext)
                fontString:SetTextColor(GRAY_FONT_COLOR:GetRGB())
                fontString:Show()
            end
        end
    end

    self:OnTooltipSpell(tip, spellId)

    tip:Show()
end

function Spell:SetUnitAura(rawTip, ...)
    self:OnTooltipAura(LibTooltipExtra:New(rawTip), true, UnitAura(...))
end

function Spell:SetUnitBuff(rawTip, ...)
    self:OnTooltipAura(LibTooltipExtra:New(rawTip), false, UnitBuff(...))
end

function Spell:SetUnitDebuff(rawTip, ...)
    self:OnTooltipAura(LibTooltipExtra:New(rawTip), false, UnitDebuff(...))
end

function Spell:OnTooltipAura(tip, hasSource, ...)
    local _, _, _, _, _, _, source, _, _, spellId = ...
    if source then
        local name = ns.strcolor(UnitName(source), ns.UnitColor(source))

        tip:AddLine('|cff00ffffFrom:|r ' .. name)
    end

    self:OnTooltipSpell(tip, spellId)

    tip:Show()
end

function Spell:OnTooltipSpell(tip, spellId)
    if ns.InDevMode() then
        if spellId then
            local _, _, icon = GetSpellInfo(spellId)
            tip:AddLine('|cff00ffffSpell ID:|r ' .. spellId, 1, 1, 1)
            tip:AddLine('|cff00ffffSpell Icon:|r ' .. icon, 1, 1, 1)
        end
    end
end
