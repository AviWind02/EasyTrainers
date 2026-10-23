local Notification = require("UI/Panels/Notification/Notification")
local Lifecycle = require("Core/Lifecycle")

local InfiniteJumps = {}

InfiniteJumps.Enabled = { value = false }

local MULTI_JUMPS = 5000

local MULTI_JUMP_FLATS = {
    "playerStateMachineBaseLocomotion.locomotionAir.numberOfMultiJumps",
    "playerStateMachineBaseLocomotionTakedown.grappleAir.numberOfMultiJumps",
    "playerStateMachineBaseLocomotionTier3.locomotionAirTier3.numberOfMultiJumps",
    "playerStateMachineBaseLocomotionTier4.locomotionAirTier4.numberOfMultiJumps",
    "playerStateMachineBaseLocomotionTier5.locomotionAirTier5.numberOfMultiJumps",
    "playerStateMachineLocomotion.airHover.numberOfMultiJumps",
    "playerStateMachineLocomotion.airThrusters.numberOfMultiJumps",
    "playerStateMachineLocomotion.bodySlamJump.numberOfMultiJumps",
    "playerStateMachineLocomotion.chargeJump.numberOfMultiJumps",
    "playerStateMachineLocomotion.coolExitJump.numberOfMultiJumps",
    "playerStateMachineLocomotion.dodgeAir.numberOfMultiJumps",
    "playerStateMachineLocomotion.fall.numberOfMultiJumps",
    "playerStateMachineLocomotion.hoverJump.numberOfMultiJumps",
    "playerStateMachineLocomotion.doubleJump.numberOfMultiJumps",
    "playerStateMachineLocomotion.jump.numberOfMultiJumps",
    "playerStateMachineLocomotion.ladderCrouch.numberOfMultiJumps",
    "playerStateMachineLocomotion.ladderJump.numberOfMultiJumps",
    "playerStateMachineLocomotion.slideFall.numberOfMultiJumps",
    "playerStateMachineLocomotion.superheroFall.numberOfMultiJumps",
    "playerStateMachineLocomotion.unsecureFootingFall.numberOfMultiJumps",
    "playerStateMachineLocomotionTakedown.grappleFall.numberOfMultiJumps"
}

local s_Applied = false
local s_Defaults = {}

local function HasReinforcedTendons()
    local player = Game.GetPlayer()
    if not player then return false end

    local equipment = Game.GetScriptableSystemsContainer():Get("EquipmentSystem"):GetPlayerData(player)
    local itemID = equipment:GetItemInEquipSlot(gamedataEquipmentArea.LegsCW, 0)
    if itemID.tdbid.hash == 0 then
        Notification.Warning("No cyberware in Legs slot.\nEquip Reinforced Tendons first.")
        return false
    end

    local itemData = Game.GetTransactionSystem():GetItemData(player, itemID)
    local recordID = TDBID.ToStringDEBUG(itemData:GetID().id)
    if recordID and recordID:find("BoostedTendons", 1, true) then return true end

    Notification.Error("Reinforced Tendons not detected.\nEquip them before enabling Infinite Jumps.")
    return false
end

local function Apply()
    for _, flat in ipairs(MULTI_JUMP_FLATS) do
        if s_Defaults[flat] == nil then s_Defaults[flat] = TweakDB:GetFlat(flat) or 1 end
        TweakDB:SetFlat(flat, MULTI_JUMPS)
    end
end

local function Restore()
    for _, flat in ipairs(MULTI_JUMP_FLATS) do
        TweakDB:SetFlat(flat, s_Defaults[flat] or 1)
    end
end

function InfiniteJumps.Tick()
    if InfiniteJumps.Enabled.value == s_Applied then return end

    if not InfiniteJumps.Enabled.value then
        Restore()
        s_Applied = false
        Notification.Info("Infinite Jumps disabled.\nLoad a save to restore default jumps.", 6.0)
        return
    end

    if not HasReinforcedTendons() then
        InfiniteJumps.Enabled.value = false
        return
    end

    Apply()
    s_Applied = true
    Notification.Success("Infinite Jumps enabled.\nLoad a save to apply.", 6.0)
end

Lifecycle.Register("InfiniteJumps", {
    OnShutdown = function()
        if s_Applied then Restore() end
        s_Applied = false
    end
})

return InfiniteJumps
