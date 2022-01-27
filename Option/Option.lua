-- Option.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/25/2022, 11:28:20 PM
--
---@type ns
local ns = select(2, ...)

local L = ns.L

---@class Addon
local Addon = ns.AddOn

local customPosition

function Addon:LoadOptionFrame()
    local order = 0
    local function orderGen()
        order = order + 1
        return order
    end

    local function get(paths)
        ---@type any
        local d = ns.profile
        for _, v in ipairs(paths) do
            if v ~= 'general' then
                d = d[v]
            end
        end
        if paths.type == 'color' then
            return d.r, d.g, d.b, d.a
        else
            return d
        end
    end

    local function set(paths, ...)
        local d = ns.profile
        local n = #paths
        for i, v in ipairs(paths) do
            if i < n then
                if v ~= 'general' then
                    d = d[v]
                end
            else
                if paths.type == 'color' then
                    d[v] = {}
                    d = d[v]
                    d.r, d.g, d.b, d.a = ...
                else
                    d[v] = ...
                end
                self:SendMessage('TDTIP_SETTING_UPDATE')
            end
        end
    end

    local function inline(name)
        return function(args)
            return {type = 'group', name = name, inline = true, order = orderGen(), args = args}
        end
    end

    local function rgb(name)
        return {type = 'color', name = name, order = orderGen()}
    end

    local function toggle(name)
        return {type = 'toggle', name = name, order = orderGen()}
    end

    local function range(name, min, max, step)
        return {type = 'range', order = orderGen(), name = name, min = min, max = max, step = step}
    end

    local function drop(name)
        return function(values)
            local opts = { --
                type = 'select',
                name = name,
                order = orderGen(),
            }

            if type(values) == 'function' then
                opts.values = values
            else
                opts.values = {}
                opts.sorting = {}

                for i, v in ipairs(values) do
                    opts.values[v.value] = v.name
                    opts.sorting[i] = v.value
                end
            end
            return opts
        end
    end

    local options = {
        type = 'group',
        name = 'tdTip ' .. GetAddOnMetadata('tdTip', 'Version'),
        get = get,
        set = set,
        args = {
            reset = {
                type = 'execute',
                name = L['Restore default Settings'],
                order = orderGen(),
                confirm = true,
                confirmText = L['Are you sure you want to restore the current Settings?'],
                func = function()
                    self.db:ResetProfile()
                end,
            },
            line = {type = 'header', name = '', order = orderGen()},
            general = inline(GENERAL) {
                showPvpName = toggle(L['Show player title']),
                showGuildRank = toggle(L['Show guild rank']),
                showFactionIcon = toggle(L['Show faction icon']),
                showClassIcon = toggle(L['Show class icon']),
                showOffline = toggle(L['Show offline']),
                showAFK = toggle(L['Show AFK']),
                showDND = toggle(L['Show DND']),

                classIconSize = range(L['Class icon size'], 10, 32, 1),
                raidIconSize = range(L['Raid icon size'], 10, 128, 1),
            },

            pos = inline(L['Position']) {
                type = drop(L['Type']) {
                    {name = L['System'], value = ns.POS_TYPE.System}, --
                    {name = L['Cursor'], value = ns.POS_TYPE.Cursor}, --
                    {name = L['Custom'], value = ns.POS_TYPE.Custom},
                },
                custom = {
                    type = 'execute',
                    name = L['Custom position'],
                    order = orderGen(),
                    func = function()
                        if not customPosition then
                            customPosition = ns.CustomPosition:Bind(
                                                 CreateFrame('Frame', nil, UIParent, 'tdTipCustomPositionFrameTemplate'))
                        end
                        customPosition:SetShown(not customPosition:IsShown())
                    end,
                    hidden = function()
                        return ns.profile.pos.type ~= ns.POS_TYPE.Custom
                    end,
                },
            },

            bar = inline(L['Bar']) { --
                height = range(L['Height'], 2, 50, 1),
                padding = range(L['Padding'], -50, 50, 1),
            },

            colors = inline('Colors') {
                guildColor = rgb(L['Guild Color']),
                guildRankColor = rgb(L['Guild Rank Color']),
                friendColor = rgb(L['Friend Color']),
                enemyColor = rgb(L['Enemy Color']),
                playerTitleColor = rgb(L['Player Title Color']),
                realmColor = rgb(L['Realm Color']),
                npcTitleColor = rgb(L['Npc Title Color']),
                reactionColor = rgb(L['Reaction Color']),
            },
        },
    }

    local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
    local AceConfigDialog = LibStub('AceConfigDialog-3.0')

    AceConfigRegistry:RegisterOptionsTable('tdTip', options)
    AceConfigDialog:AddToBlizOptions('tdTip', 'tdTip')
end
