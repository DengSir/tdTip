-- Item.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/25/2022, 5:22:33 PM
--
---@class ns
local ns = select(2, ...)

local S, P = ns.S, ns.P

local LibTooltipExtra = LibStub('LibTooltipExtra-1.0')

---@class Item: AceAddon-3.0, AceEvent-3.0, AceHook-3.0
local Item = ns.AddOn:NewModule('Item', 'AceEvent-3.0', 'AceHook-3.0')

local APIS = {
    'SetMerchantItem',
    'SetBuybackItem',
    'SetBagItem',
    'SetAuctionItem',
    'SetAuctionSellItem',
    'SetLootItem',
    'SetLootRollItem',
    'SetInventoryItem',
    'SetTradePlayerItem',
    'SetTradeTargetItem',
    'SetQuestItem',
    'SetQuestLogItem',
    'SetInboxItem',
    'SetSendMailItem',
    'SetHyperlink',
    'SetTradeSkillItem',
    'SetAction',
    'SetItemByID',
    'SetMerchantCostItem',
    'SetGuildBankItem',
    'SetExistingSocketGem',
    'SetSocketGem',
    'SetSocketedItem',
    SetCraftItem = function(index, slot)
        if not slot then
            return GetCraftItemLink(index)
        else
            return GetCraftReagentItemLink(index, slot)
        end
    end,
}

function Item:OnInitialize()
    self.pendings = {}
end

function Item:OnEnable()
    for _, name in ipairs(ns.Tooltips) do
        local rawTip = _G[name]
        if rawTip then
            self:HookTip(rawTip)
        end
    end

    self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
end

function Item:OnDisable()
    wipe(self.pendings)
end

function Item:GET_ITEM_INFO_RECEIVED(_, itemId, ok)
    if not ok then
        return
    end

    local pendings = self.pendings[itemId]
    if not pendings then
        return
    end

    C_Timer.After(0.05, function()
        self.pendings[itemId] = nil

        for tip, info in pairs(pendings) do
            tip:ClearLines()
            tip[info.method](tip, unpack(info.args, 1, info.argsCount))
        end
    end)
end

function Item:HookTip(rawTip)
    for k, v in pairs(APIS) do
        local api
        if type(k) == 'number' then
            api = v
        else
            api = k
        end

        if rawTip[api] then
            self:SecureHook(rawTip, api, function(t, ...)
                return self:OnCall(t, api, ...)
            end)
        end
    end

    do
        local tip = LibTooltipExtra:New(rawTip)
        tip:GetFontStringLeft(1):SetFontObject('GameTooltipHeaderText')
        tip:GetFontStringRight(1):SetFontObject('GameTooltipHeaderText')
    end

    if rawTip.shoppingTooltips then
        for _, shoppingTip in ipairs(rawTip.shoppingTooltips) do
            self:SecureHook(shoppingTip, 'SetCompareItem', 'OnCompareItem')
            self:HookTip(shoppingTip)

            local tip = LibTooltipExtra:New(shoppingTip)
            tip:GetFontStringLeft(2):SetFontObject('GameTooltipHeaderText')
            tip:GetFontStringRight(2):SetFontObject('GameTooltipHeaderText')

            local i = 3
            while tip:GetFontStringLeft(i) do
                tip:GetFontStringLeft(i):SetFontObject('GameTooltipText')
                tip:GetFontStringRight(i):SetFontObject('GameTooltipText')

                i = i + 1
            end
        end
    end
end

function Item:OnCompareItem(tip1, tip2)
    self:OnCall(tip1, 'SetHyperlink', select(2, tip1:GetItem()))
    self:OnCall(tip2, 'SetHyperlink', select(2, tip2:GetItem()))
end

function Item:OnCall(rawTip, method, ...)
    local link
    if APIS[method] then
        link = APIS[method](...)
    else
        link = select(2, rawTip:GetItem())
    end

    if not link then
        return
    end

    local itemId = self:OnTooltipSetItem(LibTooltipExtra:New(rawTip), link)
    if not itemId then
        return
    end

    self.pendings[itemId] = self.pendings[itemId] or {}
    self.pendings[itemId][rawTip] = {method = method, argsCount = select('#', ...), args = {...}}
end

---@param tip LibGameTooltip
---@param item string
function Item:OnTooltipSetItem(tip, item)
    local name, _, quality, itemLevel, _, _, _, _, equipLoc, icon = GetItemInfo(item)
    if not name then
        return tonumber(item) or GetItemInfoFromHyperlink(item)
    end

    local nameLineNum = tip:GetFontStringLeft(1):GetText() == CURRENTLY_EQUIPPED and 2 or 1

    tip:GetFontStringLeft(2):SetFontObject(nameLineNum == 2 and 'GameTooltipHeaderText' or 'GameTooltipText')

    local nameLine = tip:GetFontStringLeft(nameLineNum)

    if P.showItemIcon then
        nameLine:SetFormattedText('|T%s:18|t %s', icon, nameLine:GetText())
    end

    if P.showItemLevel and (not P.showItemLevelOnlyEquip or equipLoc ~= '') then
        tip:AppendLineFrontLeft(nameLineNum + 1, format(S.ITEM_LEVEL, itemLevel))
    end

    if P.showItemBorderColor then
        local r, g, b = GetItemQualityColor(quality)
        if r then
            tip:SetBackdropBorderColor(r, g, b)
        end
    end

    tip:Show()
end
