-- Spell.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/27/2022, 11:27:53 AM
--
---@class ns
local ns = select(2, ...)

---@class Spell: AceAddon-3.0, AceEvent-3.0, AceHook-3.0
local Spell = ns.AddOn:NewModule('Spell', 'AceEvent-3.0', 'AceHook-3.0')

function Spell:OnInitialize()
    self.tip = LibStub('LibTooltipExtra-1.0'):New(GameTooltip)
end

function Spell:OnEnable()
    self:HookScript(GameTooltip, 'OnTooltipSetSpell')
end

function Spell:OnTooltipSetSpell()
    local _, spellId = self.tip:GetSpell()
    if not spellId then
        return
    end

    local icon = select(3, GetSpellInfo(spellId))
    if not icon then
        return
    end

    local fontString = self.tip:GetFontStringLeft(1)
    local text = fontString:GetText()

    fontString:SetFormattedText('|T%s:18:18|t %s', icon, text)
end
