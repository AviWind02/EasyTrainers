local Logger = require("Core/Logger")

local Inventory = {}

local function LocalizedName(tweakID)
    local name = Game.GetLocalizedTextByKey(TDB.GetLocKey(tweakID .. ".displayName"))
    if not name or name == "" then return tweakID end
    return name
end

function Inventory.GiveItem(tweakID, quantity)
    if not tweakID or tweakID == "" then
        Logger.Log("Inventory: invalid TweakDBID passed to GiveItem")
        return false
    end

    quantity = quantity or 1
    local ok, err = pcall(Game.AddToInventory, tweakID, quantity)
    if not ok then
        Logger.Log(string.format("Inventory: failed to give %s (%s)", tweakID, tostring(err)))
        return false
    end

    Logger.Log(string.format("Inventory: gave %d x %s", quantity, tweakID))
    return true
end

function Inventory.RemoveItem(tweakID, quantity)
    if not tweakID or tweakID == "" then
        Logger.Log("Inventory: invalid TweakDBID passed to RemoveItem")
        return false
    end

    if not TweakDB:GetRecord(tweakID) then
        Logger.Log(string.format("Inventory: '%s' is not a valid item ID", tweakID))
        return false
    end

    quantity = quantity or 1

    local player = Game.GetPlayer()
    local transactionSystem = Game.GetTransactionSystem()
    local ok, items = transactionSystem:GetItemList(player)
    if not ok then return false end

    for _, item in ipairs(items) do
        local itemID = item:GetID()
        if TDBID.ToStringDEBUG(itemID.id) == tweakID and transactionSystem:GetItemQuantity(player, itemID) >= quantity then
            transactionSystem:RemoveItemByTDBID(player, tweakID, quantity)
            Logger.Log(string.format("Inventory: removed %d x %s", quantity, LocalizedName(tweakID)))
            return true
        end
    end

    Logger.Log(string.format("Inventory: item not found or insufficient quantity (%s)", tweakID))
    return false
end

function Inventory.GetAllItems()
    local player = Game.GetPlayer()
    local transactionSystem = Game.GetTransactionSystem()
    local result = {}

    local ok, items = transactionSystem:GetItemList(player)
    if not ok then return result end

    for _, item in ipairs(items) do
        local itemID = item:GetID()
        local tweakID = TDBID.ToStringDEBUG(itemID.id)
        table.insert(result, {
            id = tweakID,
            name = LocalizedName(tweakID),
            quantity = transactionSystem:GetItemQuantity(player, itemID) or 1,
            raw = item
        })
    end

    return result
end

return Inventory
