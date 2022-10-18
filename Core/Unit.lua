-- Unit.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/23/2022, 12:49:49 AM
--
---@type ns
local ns = select(2, ...)

local L = ns.L
local strcolor = ns.strcolor
local strjoin = ns.strjoin

local S, F, O, C, P = ns.S, ns.F, ns.O, ns.C, ns.P

local CLEAR_LINES = { --
    [PVP] = true,
    [PLAYER_OFFLINE] = true,
    [FACTION_HORDE] = true,
    [FACTION_ALLIANCE] = true,
}

---@type LibTooltipExtra-1.0
local LibTooltipExtra = LibStub('LibTooltipExtra-1.0')

---@class Unit: AceAddon-3.0, AceHook-3.0, AceTimer-3.0, AceEvent-3.0
local Unit = ns.AddOn:NewModule('Unit', 'AceHook-3.0', 'AceTimer-3.0', 'AceEvent-3.0')

function Unit:OnInitialize()
    ---@type UnitInfo
    self.info = {}
    ---@class lines
    self.lines = {}

    self.PLAYER_FACTION = select(2, UnitFactionGroup('player'))

    self.tip = LibTooltipExtra:New(GameTooltip)
    ---@type StatusBar
    self.bar = GameTooltipStatusBar

    self.raidIcon = self.tip:CreateTexture(nil, 'OVERLAY')
    self.raidIcon:SetSize(32, 32)
    self.raidIcon:SetPoint('BOTTOM', self.tip.NineSlice, 'TOP', 0, -10)

    self.factionIcon = self.tip:CreateTexture(nil, 'ARTWORK')
    self.factionIcon:SetSize(64, 64)
    self.factionIcon:SetPoint('TOPRIGHT', self.tip.NineSlice, 'TOPRIGHT')
    self.factionIcon:SetAlpha(0.5)
end

function Unit:OnEnable()
    self:OnSettingUpdate()

    self:HookScript(self.tip, 'OnTooltipSetUnit')
    self:HookScript(self.tip, 'OnTooltipCleared')

    self:HookScript(self.bar, 'OnShow', 'OnBarShow')
    self:HookScript(self.bar, 'OnHide', 'OnBarHide')

    self:RegisterMessage('TDTIP_SETTING_UPDATE', 'OnSettingUpdate')

    self.bar:SetStatusBarTexture([[Interface\AddOns\tdTip\Media\StatusBar]])

    self.bar.bg = self.bar:CreateTexture(nil, 'BACKGROUND')
    self.bar.bg:SetAllPoints(true)
    self.bar.bg:SetTexture([[Interface\AddOns\tdTip\Media\StatusBar]])
    self.bar.bg:SetVertexColor(1, 1, 1, 0.2)
end

function Unit:OnSettingUpdate()
    local padding = P.bar.padding
    self.bar:SetHeight(P.bar.height)
    self.bar:ClearAllPoints()
    self.bar:SetPoint('BOTTOMLEFT', GameTooltip.NineSlice, 'BOTTOMLEFT', padding, padding)
    self.bar:SetPoint('BOTTOMRIGHT', GameTooltip.NineSlice, 'BOTTOMRIGHT', -padding, padding)

    local size = P.raidIconSize
    self.raidIcon:SetSize(size, size)
end

function Unit:OnBarShow()
    if self.tip:GetUnit() then
        return
    end

    self.bar.lockColor = nil
    ns.Anchor:SetMargins(nil, nil, nil, P.bar.padding + P.bar.height - 5)
end

function Unit:OnBarHide()
    self.bar.lockColor = nil
end

function Unit:OnTooltipCleared()
    self.bar:Hide()
    self.tip:SetBackdropBorderColor(1, 1, 1)
    self.raidIcon:Hide()
    self.factionIcon:Hide()
    self:CancelAllTimers()
end

function Unit:OnBarValueChanged()
    local info = self.info
    local color = info.classColor or info.reactionColor
    if color then
        self.bar:SetStatusBarColor(color.r, color.g, color.b)
    end
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
    self:UpdateFactionIcon()
    self:UpdateRaidIcon()
    self:UpdateTarget(true)
    self:ScheduleRepeatingTimer('UpdateTarget', 0.1)
end

function Unit:UpdateInfo(unit)
    ---@class UnitInfo
    local info = wipe(self.info)
    ---@class lines
    local lines = wipe(self.lines)

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
        if UnitInBattleground('player') then
            info.isFriend = UnitInRaid(unit) or nil
        else
            info.isFriend = info.faction == self.PLAYER_FACTION
        end
        info.level = UnitLevel(unit)
        info.race, info.raceFileName = UnitRace(unit)
        info.guild, info.guildRank = GetGuildInfo(unit)
        info.class, info.classFileName = UnitClass(unit)
    elseif info.isBattlePet then
        info.level = UnitBattlePetLevel(unit)
    else
        info.level = UnitLevel(unit)
        info.type = UnitPlayerControlled(unit) and UnitCreatureFamily(unit) or UnitCreatureType(unit)
        info.classification = S.CLASSIFICATIONS[UnitClassification(unit)]
        info.reaction = UnitReaction(unit, 'player')
        info.isTapDenied = UnitIsTapDenied(unit)
    end

    for i = 2, self.tip:NumLines() do
        local line = self.tip:GetFontStringLeft(i)
        local text = line:GetText()
        if text then
            if info.isPlayer and info.guild and not lines.guild and text:find(info.guild, nil, true) then
                lines.guild = i
            elseif not lines.level and text:find(LEVEL, nil, true) then
                lines.level = i
            elseif CLEAR_LINES[text] then
                tinsert(self.lines, i)
                line:SetText()
            end
        end
    end

    if info.isDead then
        info.dead = S.DEAD
    end

    if not info.isBattlePet then
        if info.level <= 0 then
            info.level = '|cffff0000??|r'
        else
            info.level = strcolor(info.level, GetQuestDifficultyColor(info.level))
        end
    end

    if info.isPlayer then
        info.classColor = RAID_CLASS_COLORS[info.classFileName]
        info.class = strcolor(info.class, info.classColor)
        info.race = strcolor(info.race, info.isFriend and C.friendColor or C.enemyColor)

        if P.showClassIcon then
            info.classIcon = O.Class[info.classFileName]
        end

        local pvpName = P.showPvpName and UnitPVPName(unit)
        if pvpName then
            info.name = pvpName:gsub(info.name, strcolor(info.name, info.classColor))
            info.name = strcolor(info.name, C.playerTitleColor)
        else
            info.name = strcolor(info.name, info.classColor)
        end

        if info.guild then
            info.guild = F.Guild:format(info.guild)
            info.guildRank = P.showGuildRank and F.GuildRank:format(info.guildRank) or nil
        end

        if info.realm then
            info.realm = F.Realm:format(info.realm)
        end

        if P.showOffline and not UnitIsConnected(unit) then
            info.offline = S.OFFLINE
        end

        if P.showAFK and UnitIsAFK(unit) then
            info.afk = S.AFK
        end

        if P.showDND and UnitIsDND(unit) then
            info.dnd = S.DND
        end

        if P.showTargetBy then
            self:AddTargetBy(info)
        end
    else
        info.reactionColor = FACTION_BAR_COLORS[info.reaction]
        info.type = strcolor(info.type, info.reactionColor)

        if info.isTapDenied then
            info.name = strcolor(info.name, ns.GRAY_COLOR)
        else
            info.name = strcolor(info.name, info.reactionColor)
        end

        if info.reaction and info.reaction >= 6 then
            info.reactionName = S.REACTIONS[info.reaction]
        end

        if lines.level and lines.level > 2 then
            info.title = F.NpcTitle:format(self.tip:GetFontStringLeft(2):GetText())
        end
    end

    local right = P.showFactionIcon and info.factionFileName and 52 or nil
    local bottom = not info.isDead and P.bar.padding + P.bar.height - 5 or nil

    ns.Anchor:SetMargins(nil, right, nil, bottom)
end

function Unit:AddTargetBy(info)
    local numGroup = GetNumGroupMembers()
    if not numGroup or numGroup <= 1 then
        return
    end

    local inRaid = IsInRaid()
    local targeted = {}
    for i = 1, numGroup do
        local unit = inRaid and 'raid' .. i or 'party' .. i
        if UnitIsUnit(unit .. 'target', info.unit) then
            local _, classFile = UnitClass(unit)
            local color = RAID_CLASS_COLORS[classFile]
            local name = strcolor(UnitName(unit), color)
            table.insert(targeted, name)
        end
    end

    if #targeted > 0 then
        info.targetedBy = string.format(L['Targeted By (|cffffffff%d|r): %s'], #targeted,
                                        table.concat(targeted, ', ', 1, math.min(3, #targeted)))
    end
end

function Unit:GetEmptyLine()
    local line = tremove(self.lines)
    if not line then
        self.tip:AddLine(' ')
        line = self.tip:NumLines()
    end
    return line
end

function Unit:UpdateNameLine()
    local info = self.info
    local text = strjoin(info.classIcon, info.name, info.realm)
    self.tip:GetFontStringLeft(1):SetText(text)
end

function Unit:UpdateGuildLine()
    local info = self.info

    local text = strjoin(info.guild, info.guildRank)
    if not text then
        return
    end

    local lineGuild = self.lines.guild
    if lineGuild then
        self.tip:GetFontStringLeft(lineGuild):SetText(text)
    else
        self.tip:AppendLineFrontLeft(2, text)
    end
end

function Unit:UpdateNpcTitleLine()
    if not self.info.title then
        return
    end

    self.tip:GetFontStringLeft(2):SetText(self.info.title)
end

function Unit:UpdateLevelLine()
    if not self.lines.level then
        return
    end
    local info = self.info
    local text = strjoin(info.level, info.race, info.class, info.type, info.classification, info.reactionName,
                         info.dead, info.offline, info.afk, info.dnd)

    self.tip:GetFontStringLeft(self.lines.level):SetText(text)
end

function Unit:UpdateBorder()
    local info = self.info
    local color
    if info.isTapDenied then
        color = GRAY_FONT_COLOR
    else
        color = info.classColor or info.reactionColor
    end

    if color then
        self.tip:SetBackdropBorderColor(color.r, color.g, color.b)
    end
end

function Unit:UpdateStatusBar()
    local info = self.info
    if info.isDead then
        self.bar:Hide()
    else
        self.bar.lockColor = true
        self.bar:Show()
        self:OnBarValueChanged(self.bar, self.bar:GetValue())
    end
end

function Unit:UpdateRaidIcon()
    local info = self.info
    if not info.raidIndex then
        return
    end

    self.raidIcon:SetTexture(O.Raid[info.raidIndex])
    self.raidIcon:Show()
end

function Unit:UpdateFactionIcon()
    if not P.showFactionIcon then
        return
    end
    local info = self.info
    if not info.factionFileName then
        return
    end

    self.factionIcon:SetTexture(O.Faction[info.factionFileName])
    self.factionIcon:Show()
end

function Unit:UpdateTarget(first)
    local _, unit = self.tip:GetUnit()
    if not unit or not UnitExists(unit) then
        return
    end
    if not first and not UnitExists('mouseover') then
        return
    end

    local lines = self.lines
    local target = self:GetTargetText()
    if target then
        lines.target = lines.target or self:GetEmptyLine()
        self.tip:GetFontStringLeft(lines.target):SetText(target)
    elseif lines.target then
        self.tip:GetFontStringLeft(lines.target):SetText()
    end

    if self.info.targetedBy then
        lines.targetedBy = lines.targetedBy or self:GetEmptyLine()
        self.tip:GetFontStringLeft(lines.targetedBy):SetText(self.info.targetedBy)
    elseif lines.targetedBy then
        self.tip:GetFontStringLeft(lines.targetedBy):SetText()
    end
    self.tip:Show()
end

function Unit:GetTargetText()
    local unit = self.info.unit .. 'target'
    if not UnitExists(unit) then
        return
    end
    local unitName
    if UnitIsUnit(unit, 'player') then
        unitName = S.YOU
    else
        unitName = strcolor(format('[%s]', UnitName(unit)), ns.UnitColor(unit))
    end
    return unitName and S.TARGET:format(unitName) or nil
end
