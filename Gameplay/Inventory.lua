local Inventory = {}

local Logger = require("Core/Logger")

function Inventory.GiveItem(tweakID, quantity)
	if not tweakID or tweakID == "" then
		Logger.Log("[EasyTrainerInventory] Invalid TweakDBID passed to GiveItem.")
		return
	end

	quantity = quantity or 1

	local success, err = pcall(function()
		Game.AddToInventory(tweakID, quantity)
	end)

	if success then
		Logger.Log(string.format("[EasyTrainerInventory] Gave player %d x %s", quantity, tweakID))
	else
		Logger.Log(string.format("[EasyTrainerInventory] Failed to give item: %s (%s)", tweakID, tostring(err)))
	end
end

function Inventory.RemoveItem(tweakID, quantity)
	if not tweakID or tweakID == "" then
		Logger.Log("[EasyTrainerInventory] Invalid TweakDBID passed to RemoveItem.")
		return
	end

	if not TweakDB:GetRecord(tweakID) then
		Logger.Log(string.format("[EasyTrainerInventory] '%s' is not a valid item ID.", tweakID))
		return
	end

	quantity = quantity or 1

	local player = Game.GetPlayer()
	local ts = Game.GetTransactionSystem()
	local itemList = { ts:GetItemList(player) }
	local removed = false

	for _, item in ipairs(itemList[2]) do
		local itemID = item:GetID()
		local currentQuantity = ts:GetItemQuantity(player, itemID)
		local currentID = TDBID.ToStringDEBUG(itemID.id)

		if currentID == tweakID and currentQuantity >= quantity then
			local displayName = Game.GetLocalizedTextByKey(TDB.GetLocKey(itemID.id .. ".displayName")) or "Unknown Item"
			local itemData = ts:GetItemData(player, itemID)
			if itemData:HasTag("Quest") then
				itemData:RemoveDynamicTag("Quest")
			end
			ts:RemoveItemByTDBID(player, tweakID, quantity)
			Logger.Log(string.format("[EasyTrainerInventory] Removed %d x %s (%s)", quantity, displayName, currentID))
			removed = true
			break
		end
	end

	if not removed then
		local displayName = Game.GetLocalizedTextByKey(TDB.GetLocKey(tweakID .. ".displayName")) or "Unknown Item"
		Logger.Log(string.format("[EasyTrainerInventory] Item not found or not enough quantity: %s (%s)", displayName, tweakID))
	end
end




return Inventory
