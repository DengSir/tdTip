-- Item.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/25/2022, 5:22:33 PM
--
---@class ns
local ns = select(2, ...)

local LibTooltipExtra = LibStub('LibTooltipExtra-1.0')

local ITEM_LEVEL = NORMAL_FONT_COLOR_CODE .. ITEM_LEVEL_PLUS:gsub(' *%%d%+$', ' %%d') .. '|r'

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
    SetCraftItem = true,
}

function Item:OnInitialize()
    self.pendings = {}
end

function Item:OnEnable()
    self:HookTip(GameTooltip)
    self:HookTip(ItemRefTooltip)

    self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
end

function Item:GET_ITEM_INFO_RECEIVED(_, itemId, ok)
    if not ok then
        return
    end

    C_Timer.After(0, function()
        local pendings = self.pendings[itemId]
        if not pendings then
            return
        end
        self.pendings[itemId] = nil

        print(itemId)

        for _, tip in ipairs(pendings) do
            self:Translate(tip, itemId)
        end
    end)
end

function Item:HookTip(rawTip)
    -- local api, handler
    -- for k, v in pairs(APIS) do
    --     if type(k) == 'number' then
    --         api, handler = v, 'OnCall'
    --     elseif type(v) == 'string' then
    --         api, handler = k, v
    --     else
    --         api, handler = k, k
    --     end

    --     if rawTip[api] then
    --         self:SecureHook(rawTip, api, handler)
    --     end
    -- end

    self:HookScript(rawTip, 'OnTooltipSetItem', 'OnCall')

    if rawTip.shoppingTooltips then
        for _, shoppingTip in ipairs(rawTip.shoppingTooltips) do
            -- self:SecureHook(shoppingTip, 'SetCompareItem', 'OnCompareItem')
            self:HookTip(shoppingTip)
        end
    end
end

function Item:OnCompareItem(tip1, tip2)
    self:OnCall(tip1)
    self:OnCall(tip2)
end

function Item:OnCall(rawTip)
    return self:Translate(rawTip, select(2, rawTip:GetItem()))
end

function Item:SetCraftItem(rawTip, index, slot)
    if not slot then
        return self:Translate(rawTip, GetCraftItemLink(index))
    else
        return self:Translate(rawTip, GetCraftReagentItemLink(index, slot))
    end
end

function Item:Translate(rawTip, item)
    if not item then
        return
    end
    return self:OnTooltipSetItem(LibTooltipExtra:New(rawTip), item)
end

---@param tip LibGameTooltip
---@param item string
function Item:OnTooltipSetItem(tip, item)
    local name, _, quality, itemLevel, _, _, _, _, equipLoc, icon = GetItemInfo(item)
    print(item, name, quality, itemLevel, equipLoc, icon)
    if not name then

        local itemId = tonumber(item) or GetItemInfoFromHyperlink(item)
        if itemId then
            self:Pending(tip, itemId)
        end

        print(itemId)

        return
    end

    local nameLineNum = tip:GetFontStringLeft(1):GetText() == CURRENTLY_EQUIPPED and 2 or 1

    tip:AppendLineFrontLeft(nameLineNum + 1, format(ITEM_LEVEL, itemLevel))

    local nameLine = tip:GetFontStringLeft(nameLineNum)
    nameLine:SetFormattedText('|T%s:18|t %s', icon, nameLine:GetText())

    local r, g, b = GetItemQualityColor(quality)
    if r then
        tip:SetBackdropBorderColor(r, g, b)
    end

    tip:Show()
end

---@param tip LibGameTooltip
---@param itemId number
function Item:Pending(tip, itemId)
    self.pendings[itemId] = self.pendings[itemId] or {}
    tinsert(self.pendings[itemId], tip.tip)
end
