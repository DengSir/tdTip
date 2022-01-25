-- Unit.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/23/2022, 12:49:49 AM
--
---@type ns
local ns = select(2, ...)

local strcolor = ns.strcolor

local YOU = format('|cffff0000>> %s <<|r', 'You')
local DEAD = strcolor(DEAD, ns.GREY_COLOR)

---@type LibTooltipExtra-1.0
local LibTooltipExtra = LibStub('LibTooltipExtra-1.0')

---@class Unit: AceAddon-3.0, AceHook-3.0, AceTimer-3.0
local Unit = ns.AddOn:NewModule('Unit', 'AceHook-3.0', 'AceTimer-3.0')

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
    local padding = ns.profile.barPadding
    self.bar.lockColor = true
    self.bar:SetHeight(ns.profile.barHeight)
    self.bar:SetStatusBarTexture([[Interface\AddOns\tdTip\Media\StatusBar]])
    self.bar:ClearAllPoints()
    self.bar:SetPoint('BOTTOMLEFT', GameTooltip.NineSlice, 'BOTTOMLEFT', padding, padding)
    self.bar:SetPoint('BOTTOMRIGHT', GameTooltip.NineSlice, 'BOTTOMRIGHT', -padding, padding)

    self:HookScript(self.tip, 'OnTooltipSetUnit')
    self:HookScript(self.tip, 'OnTooltipCleared')
end

function Unit:OnDisable()
    self.bar.lockColor = nil
end

function Unit:OnTooltipCleared()
    self.bar:Hide()
    self.tip:SetBackdropBorderColor(1, 1, 1)
    self.raidIcon:Hide()
    self.factionIcon:Hide()
    self:CancelAllTimers()

    print('Clear')
end

function Unit:OnBarValueChanged()
    local info = self.info
    local color = info.classColor or info.reactionColor
    if color then
        self.bar:SetStatusBarColor(color.r, color.g, color.b)
    end
end

function Unit:OnTooltipSetUnit()
    print(1, self.tip:GetUnit())
    local _, unit = self.tip:GetUnit()
    if not unit then
        return
    end

    print(unit)

    self:UpdateInfo(unit)
    self:UpdateNameLine()
    self:UpdateLevelLine()
    self:UpdateGuildLine()
    self:UpdateNpcTitleLine()
    self:UpdateBorder()
    self:UpdateStatusBar()
    self:UpdateFactionIcon()
    self:UpdateRaidIcon()
    self:UpdateTarget()
    self:ScheduleRepeatingTimer('UpdateTarget', 0.1)
end

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
        info.guild, info.guildRank = GetGuildInfo(unit)
        info.class, info.classFileName = UnitClass(unit)
        info.classColor = RAID_CLASS_COLORS[info.classFileName]
    elseif info.isBattlePet then
        info.level = UnitBattlePetLevel(unit)
    else
        info.level = UnitLevel(unit)
        info.type = UnitPlayerControlled(unit) and UnitCreatureFamily(unit) or UnitCreatureType(unit)
        info.classification = ns.CLASSIFICATIONS[UnitClassification(unit)]
        info.reaction = UnitReaction(unit, 'player')
        info.isTapDenied = UnitIsTapDenied(unit)
        info.reactionColor = FACTION_BAR_COLORS[info.reaction]

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
        -- if not info.realm then
        --     info.realm = GetRealmName()
        -- end

        info.class = strcolor(info.class, info.classColor)
        info.race = strcolor(info.race, info.isFriend and ns.colors.friendColor or ns.colors.enemyColor)
        info.classIcon = ns.CLASS_ICON_STRINGS[info.classFileName]:format(18, 18)

        local pvpName = ns.profile.showPvpName and UnitPVPName(unit)
        if pvpName then
            info.name = pvpName:gsub(info.name, strcolor(info.name, info.classColor))
            info.name = strcolor(info.name, ns.colors.playerTitleColor)
        else
            info.name = strcolor(info.name, info.classColor)
        end

        if info.guild then
            info.guild = strcolor(format('<%s>', info.guild), ns.colors.guildColor)
            info.guildRank = ns.profile.showGuildRank and
                                 strcolor(format('(%s)', info.guildRank), ns.colors.guildRankColor) or nil
        end

        if info.realm then
            info.realm = strcolor(info.realm, ns.colors.realmColor)
        end
    else
        info.type = strcolor(info.type, info.reactionColor)

        if info.isTapDenied then
            info.name = strcolor(info.name, ns.GREY_COLOR)
        else
            info.name = strcolor(info.name, info.reactionColor)
        end

        if info.reaction and info.reaction >= 6 then
            info.reactionName = strcolor(ns.REACTION_STRINGS[info.reaction], ns.colors.reactionColor)
        end

        if info.lineLevel > 2 then
            local title = self.tip:GetFontStringLeft(2):GetText()

            info.title = strcolor(format('<%s>', title), ns.colors.npcTitleColor)
        end
    end

    if info.linePvp then
        info.lineTarget = info.linePvp
        info.linePvp = nil
    else
        self.tip:AddLine(' ')
        info.lineTarget = self.tip:NumLines()
        self.tip:GetFontStringLeft(info.lineTarget):SetText()
    end

    self.tip:GetFontStringLeft(info.lineTarget):SetTextColor(NORMAL_FONT_COLOR:GetRGB())

    ns.Anchor:SetMargins(nil, info.factionFileName and 52 or nil, nil,
                         not info.isDead and ns.profile.barPadding + 1 or nil)
end

function Unit:UpdateNameLine()
    local info = self.info

    local sb = self.sb:wipe()
    sb:push(info.classIcon)
    sb:push(info.name)
    sb:push(info.realm)

    self.tip:GetFontStringLeft(1):SetText(sb:join(' '))
end

function Unit:UpdateGuildLine()
    local info = self.info

    local sb = self.sb:wipe()
    sb:push(info.guild)
    sb:push(info.guildRank)

    local text = sb:join(' ')
    if not text or text == '' then
        return
    end

    if info.lineGuild then
        self.tip:GetFontStringLeft(info.lineGuild):SetText(text)
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
        self.tip:SetBackdropBorderColor(color.r, color.g, color.b)
    end
end

function Unit:UpdateStatusBar()
    local info = self.info
    if info.isDead then
        self.bar:Hide()
    else
        self.bar:Show()
        self:OnBarValueChanged(self.bar, self.bar:GetValue())
    end
end

function Unit:UpdateRaidIcon()
    local info = self.info
    if not info.raidIndex then
        return
    end

    self.raidIcon:SetTexture(ns.RAID_ICONS[info.raidIndex])
    self.raidIcon:Show()
end

function Unit:UpdateFactionIcon()
    local info = self.info
    if not info.factionFileName then
        return
    end

    self.factionIcon:SetTexture(ns.FACTION_ICONS[info.factionFileName])
    self.factionIcon:Show()
end

function Unit:UpdateTarget()
    local _, unit = self.tip:GetUnit()
    if not unit or not UnitExists(unit) then
        return
    end

    self.tip:GetFontStringLeft(self.info.lineTarget):SetText(self:GetTargetText())
    self.tip:Show()
end

local function UnitColor(unit)
    if UnitIsPlayer(unit) then
        local _, classKey = UnitClass(unit)
        if classKey then
            return RAID_CLASS_COLORS[classKey]
        end
    else
        local reaction = UnitReaction(unit, 'player')
        if reaction then
            return FACTION_BAR_COLORS[reaction]
        end
    end
    return HIGHLIGHT_FONT_COLOR
end

function Unit:GetTargetText()
    local unit = self.info.unit .. 'target'
    if not UnitExists(unit) then
        return
    end
    local unitName
    if UnitIsUnit(unit, 'player') then
        unitName = YOU
    else
        unitName = strcolor(UnitName(unit), UnitColor(unit))
    end
    return unitName and format('%s: [[ %s ]]', TARGET, unitName) or nil
end
