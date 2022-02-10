-- Option.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/25/2022, 11:28:20 PM
--
---@type ns
local ns = select(2, ...)

local L = ns.L
local P = ns.P
local POS_TYPE = ns.POS_TYPE

---@class Addon
local Addon = ns.AddOn

local customPosition

function Addon:LoadOptionFrame()
    local order = 0
    local function orderGen()
        order = order + 1
        return order
    end

    local IGNORE_PATH_KEYS = {}

    local function get(paths)
        ---@type any
        local d = P
        for _, v in ipairs(paths) do
            if not IGNORE_PATH_KEYS[v] then
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
        local d = P
        local n = #paths
        for i, v in ipairs(paths) do
            if i < n then
                if not IGNORE_PATH_KEYS[v] then
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
            end
        end
        self:SendMessage('TDTIP_SETTING_UPDATE')
    end

    local function group(name)
        return function(args)
            return {type = 'group', name = name, inline = true, order = orderGen(), args = args}
        end
    end

    local function rgb(name)
        return {type = 'color', name = name, order = orderGen()}
    end

    local function toggle(name)
        return {type = 'toggle', name = name, width = 'full', order = orderGen()}
    end

    local function range(name, min, max, step)
        return {type = 'range', order = orderGen(), width = 'full', name = name, min = min, max = max, step = step}
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

    local function inline(key)
        IGNORE_PATH_KEYS[key] = true
        return key
    end

    local function treeTitle(name)
        return {type = 'group', name = '|cffffd100' .. name .. '|r', order = orderGen(), args = {}, disabled = true}
    end

    local function treeItem(name)
        return function(args)
            return {type = 'group', name = '  |cffffffff' .. name .. '|r', order = orderGen(), args = args}
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

            unitTitle = treeTitle(L['Unit']),

            [inline 'unitGeneral'] = treeItem(GENERAL) {
                [inline 'features'] = group(L['Features']) {
                    showPvpName = toggle(L['Show player title']),
                    showGuildRank = toggle(L['Show guild rank']),
                    showFactionIcon = toggle(L['Show faction icon']),
                    showClassIcon = toggle(L['Show class icon']),
                    showOffline = toggle(L['Show offline']),
                    showAFK = toggle(L['Show AFK']),
                    showDND = toggle(L['Show DND']),
                },
                [inline 'iconSize'] = group(L['Icon size']) {
                    classIconSize = range(L['Class icon size'], 10, 32, 1),
                    raidIconSize = range(L['Raid icon size'], 10, 128, 1),
                },
            },

            colors = treeItem(L['Text colors']) {
                realmColor = rgb(L['Realm']),
                guildColor = rgb(L['Guild']),
                guildRankColor = rgb(L['Guild rank']),
                friendColor = rgb(L['Friend']),
                enemyColor = rgb(L['Enemy']),
                reactionColor = rgb(L['Reaction']),
                playerTitleColor = rgb(L['Player title']),
                npcTitleColor = rgb(L['Npc title']),
            },

            bar = treeItem(L['Bar']) { --
                height = range(L['Height'], 2, 50, 1),
                padding = range(L['Padding'], -50, 50, 1),
            },

            itemTitle = treeTitle(L['Item']),
            [inline 'item'] = treeItem(L['Item']) {
                showItemLevel = toggle(L['Show item level']),
                showItemLevelOnlyEquip = toggle(L['Show item level only on equipment']),
                showItemIcon = toggle(L['Show item icon']),
                showItemBorderColor = toggle(L['Set border color by item quality']),
            },

            spellTitle = treeTitle(L['Spell']),
            [inline 'spell'] = treeItem(L['Spell']) { --
                showSpellIcon = toggle(L['Show spell icon']),
            },

            posTitle = treeTitle(L['Position']),
            pos = treeItem(L['Position']) {
                type = drop(L['Type']) {
                    {name = L['System'], value = POS_TYPE.System}, --
                    {name = L['Cursor'], value = POS_TYPE.Cursor}, --
                    {name = L['Custom'], value = POS_TYPE.Custom},
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
                        return P.pos.type ~= POS_TYPE.Custom
                    end,
                },
            },
        },
    }

    local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
    local AceConfigDialog = LibStub('AceConfigDialog-3.0')

    AceConfigRegistry:RegisterOptionsTable('tdTip', options)
    AceConfigDialog:AddToBlizOptions('tdTip', 'tdTip')
end
