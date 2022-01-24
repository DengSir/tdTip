-- Unit.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/23/2022, 12:49:49 AM
--
---@type ns
local ns = select(2, ...)

local strcolor = ns.strcolor

---@type LibTooltipExtra-1.0
local LibTooltipExtra = LibStub('LibTooltipExtra-1.0')
---@type StatusBar
local GameTooltipStatusBar = _G.GameTooltipStatusBar

---@class Unit: AceAddon-3.0, AceHook-3.0
local Unit = ns.AddOn:NewModule('Unit', 'AceHook-3.0')

function Unit:OnInitialize()
    ---@type UnitInfo
    self.info = {}
    ---@class stringbuilder
    self.sb = {}

    local sb = {}

    ---@return stringbuilder
    function self.sb:wipe()
        wipe(sb)
        return self
    end

    function self.sb:push(text)
        if text then
            sb[#sb + 1] = text
        end
    end

    function self.sb:join(sep)
        return table.concat(sb, sep)
    end

    self.PLAYER_FACTION = select(2, UnitFactionGroup('player'))

    self.tip = LibTooltipExtra:New(GameTooltip)
    self.bar = GameTooltipStatusBar

    local n = 0
    local function newTexture()
        local texture = self.tip:CreateTexture(nil, 'OVERLAY')
        texture:Hide()
        texture:SetSize(24, 24)
        texture:SetPoint('BOTTOMLEFT', self.tip, 'TOPLEFT', 29 * n + 5, 0)
        n = n + 1
        return texture
    end

    self.classIcon = newTexture()
    self.raidIcon = newTexture()
    self.factionIcon = self.tip:CreateTexture(nil, 'ARTWORK')
    self.factionIcon:SetSize(64, 64)
    self.factionIcon:SetPoint('TOPRIGHT', self.tip.NineSlice, 'TOPRIGHT')
    self.factionIcon:SetAlpha(0.5)

    self.classIcon:SetTexture([[Interface\WORLDSTATEFRAME\Icons-Classes]])
end

function Unit:OnEnable()
    self.bar:SetHeight(5)
    self.bar:ClearAllPoints()
    self.bar:SetPoint('BOTTOMLEFT', GameTooltip.NineSlice, 'BOTTOMLEFT', 5, 5)
    self.bar:SetPoint('BOTTOMRIGHT', GameTooltip.NineSlice, 'BOTTOMRIGHT', -5, 5)

    self:HookScript(self.tip, 'OnTooltipSetUnit')
    self:HookScript(self.tip, 'OnTooltipCleared')
    self:HookScript(self.bar, 'OnValueChanged', 'OnBarValueChanged')
end

function Unit:OnTooltipCleared()
    self.tip.NineSlice:SetBorderColor(1, 1, 1)
    self.tip.NineSlice:ClearAllPoints()
    self.tip.NineSlice:SetAllPoints(self.tip)
    self.classIcon:Hide()
    self.raidIcon:Hide()
    self.factionIcon:Hide()
end

function Unit:OnTooltipSetUnit()
    local _, unit = self.tip:GetUnit()
    if not unit then
        return
    end

    self:UpdateInfo(unit)
    self:UpdateNameLine()
    self:UpdateLevelLine()
    self:UpdateGuildLine()
    self:UpdateNpcTitleLine()
    self:UpdateBorder()
    self:UpdateStatusBar()
    self:UpdateClassIcon()
    self:UpdateRaidIcon()
    self:UpdateFactionIcon()
    self:UpdateMargins()
end

function Unit:OnBarValueChanged()
    local info = self.info
    local color = info.classColor or info.reactionColor
    if color then
        self.bar:SetStatusBarColor(color.r, color.g, color.b)
    end
end

local CLASS_ICONS = setmetatable({}, {
    __index = function(t, k)
        local coords = CLASS_ICON_TCOORDS[k]
        t[k] = format([[|TInterface\WorldStateFrame\ICONS-CLASSES:%%d:%%d:0:0:256:256:%d:%d:%d:%d|t %%s]],
                      coords[1] * 0xFF, coords[2] * 0xFF, coords[3] * 0xFF, coords[4] * 0xFF)
        return t[k]
    end,
})

function Unit:UpdateInfo(unit)
    ---@class UnitInfo
    local info = wipe(self.info)

    info.unit = unit
    info.isPlayer = UnitIsPlayer(unit)
    -- @retail@
    info.isBattlePet = UnitIsBattlePet(unit)
    -- @end-retail@
    info.isDead = UnitIsDeadOrGhost(unit)
    info.name, info.realm = UnitName(unit)
    info.factionFileName, info.faction = UnitFactionGroup(unit)
    info.raidIndex = GetRaidTargetIndex(unit)

    if info.isPlayer then
        info.isFriend = info.faction == self.PLAYER_FACTION
        info.level = UnitLevel(unit)
        info.race, info.raceFileName = UnitRace(unit)
        info.class, info.classFileName = UnitClass(unit)
        info.guild, info.guildRank, info.guildIndex, info.guildRealm = GetGuildInfo(unit)
        info.classColor = RAID_CLASS_COLORS[info.classFileName]
    elseif info.isBattlePet then
        info.level = UnitBattlePetLevel(unit)
    else
        info.level = UnitLevel(unit)
        info.type = UnitPlayerControlled(unit) and UnitCreatureFamily(unit) or UnitCreatureType(unit)
        info.classification = ns.CLASSIFICATION[UnitClassification(unit)]
        info.reaction = UnitReaction(unit, 'player')
        info.isTapDenied = UnitIsTapDenied(unit)
        info.reactionColor = FACTION_BAR_COLORS[info.reaction]

        if info.reaction and info.reaction >= 6 then
            info.reactionName = strcolor(_G['FACTION_STANDING_LABEL' .. info.reaction], ns.GREY_COLOR)
        end
    end

    for i = 2, self.tip:NumLines() do
        local line = self.tip:GetFontStringLeft(i)
        local text = line:GetText()
        if text then
            if info.isPlayer and info.guild and not info.lineGuild and text:find(info.guild, nil, true) then
                info.lineGuild = i
            elseif not info.lineLevel and text:find(LEVEL, nil, true) then
                info.lineLevel = i
            elseif not info.linePvp and text:find(PVP, nil, true) then
                info.linePvp = i
                line:SetText()
            end
        end
    end

    if info.isBattlePet then
    else
        if info.level <= 0 then
            info.level = '|cffff0000??|r'
        else
            info.level = strcolor(info.level, GetQuestDifficultyColor(info.level))
        end
    end

    if info.isPlayer then
        info.class = strcolor(info.class, info.classColor)
        info.name = strcolor(info.name, info.classColor)
        info.race = strcolor(info.race, info.isFriend and ns.FRIEND_COLOR or ns.ENEMY_COLOR)

        info.name = CLASS_ICONS[info.classFileName]:format(18, 18, info.name)

        if info.guild then
            info.guild = strcolor(format('<%s - %s>', info.guild, info.guildRank), ns.GUILD_COLOR)
        end
    else
        if info.isTapDenied then
            info.name = strcolor(info.name, ns.GREY_COLOR)
        else
            info.name = strcolor(info.name, info.reactionColor)
        end

        info.type = strcolor(info.type, info.reactionColor)

        if info.lineLevel > 2 then
            local title = self.tip:GetFontStringLeft(2):GetText()

            info.title = strcolor(format('<%s>', title), ns.NPC_TITLE_COLOR)
        end
    end

    info.marginBottom = not info.isDead and 6 or nil
    info.marginRight = info.factionFileName and 52 or nil
    info.marginTop = nil
end

function Unit:UpdateNameLine()
    self.tip:GetFontStringLeft(1):SetText(self.info.name)
end

function Unit:UpdateGuildLine()
    if not self.info.guild then
        return
    end
    self.tip:GetFontStringLeft(self.info.lineGuild):SetText(self.info.guild)
end

function Unit:UpdateNpcTitleLine()
    if not self.info.title then
        return
    end

    self.tip:GetFontStringLeft(2):SetText(self.info.title)
end

function Unit:UpdateLevelLine()
    local sb = self.sb:wipe()
    local info = self.info

    sb:push(info.level)
    sb:push(info.race)
    sb:push(info.class)
    sb:push(info.type)
    sb:push(info.classification)
    sb:push(info.reactionName)
    sb:push(info.isDead and DEAD)

    self.tip:GetFontStringLeft(info.lineLevel):SetText(sb:join(' '))
end

function Unit:UpdateBorder()
    local info = self.info
    local color = info.classColor or info.reactionColor
    if color then
        self.tip.NineSlice:SetBorderColor(color.r, color.g, color.b)
    end
end

function Unit:UpdateStatusBar()
    if self.info.isDead then
        self.bar:Hide()
    else
        self.bar:Show()
        self:OnBarValueChanged(self.bar, self.bar:GetValue())
    end
end

function Unit:UpdateClassIcon()
    local info = self.info
    if not info.classFileName then
        return
    end

    self.classIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[info.classFileName]))
    self.classIcon:Show()
end

function Unit:UpdateRaidIcon()
    local info = self.info
    if not info.raidIndex then
        return
    end

    self.raidIcon:SetTexture(format([[Interface\TargetingFrame\UI-RaidTargetingIcon_%d]], info.raidIndex))
    self.raidIcon:Show()
end

local factionLogoTextures = {
    ['Alliance'] = 'Interface\\Timer\\Alliance-Logo',
    ['Horde'] = 'Interface\\Timer\\Horde-Logo',
    ['Neutral'] = 'Interface\\Timer\\Panda-Logo',
}
function Unit:UpdateFactionIcon()
    local info = self.info
    if not info.factionFileName then
        return
    end

    self.factionIcon:SetTexture(factionLogoTextures[info.factionFileName])
    self.factionIcon:Show()
end

function Unit:UpdateMargins()
    local info = self.info
    if not (info.marginBottom or info.marginTop or info.marginRight) then
        self.tip.NineSlice:ClearAllPoints()
        self.tip.NineSlice:SetAllPoints(true)
    else
        self.tip.NineSlice:ClearAllPoints()
        self.tip.NineSlice:SetPoint('TOPLEFT', 0, info.marginTop or 0)
        self.tip.NineSlice:SetPoint('BOTTOMRIGHT', info.marginRight or 0, -(info.marginBottom or 0))
    end
end
