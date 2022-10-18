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

    if ns.InDevMode() then
        tip:AddLine('|cff00ffffSpell ID:|r ' .. spellId, 1, 1, 1)
    end

    tip:Show()
end

function Spell:SetUnitAura(rawTip, unit, index, filter)
    local _, _, _, _, _, _, source, _, _, spellId = UnitAura(unit, index, filter)

    local tip = LibTooltipExtra:New(rawTip)

    if source then
        local name = ns.strcolor(UnitName(source), ns.UnitColor(source))

        tip:AddLine('|cff00ffffFrom:|r ' .. name)
    end

    if ns.InDevMode() or true then
        if spellId then
            tip:AddLine('|cff00ffffSpell ID:|r ' .. spellId, 1, 1, 1)
        end
    end

    tip:Show()
end
