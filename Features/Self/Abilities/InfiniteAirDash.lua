-- Contributed by barhxr, refactored for EasyTrainer.
local Notification = require("UI/Panels/Notification/Notification")

local InfiniteAirDash = {}

InfiniteAirDash.Enabled = { value = false }

local DIRECTION = {
    Back = -180.0,
    Right = -90.0,
    Forward = 0.0,
    Left = 90.0
}

local DIRECTIONAL_ACTIONS = {
    { "DodgeForward", DIRECTION.Forward },
    { "DodgeRight", DIRECTION.Right },
    { "DodgeLeft", DIRECTION.Left },
    { "DodgeBack", DIRECTION.Back }
}

local function SetDodgeDirection(stateContext, scriptInterface, direction)
    stateContext:SetConditionFloatParameter("DodgeDirection", direction, true)
    scriptInterface.localBlackboard:SetFloat(
        GetAllBlackboardDefs().PlayerStateMachine.DodgeTimeStamp,
        EngineTime.ToFloat(GameInstance.GetSimTime())
    )
end

local function CheckDirectionalDodge(stateContext, scriptInterface)
    for _, entry in ipairs(DIRECTIONAL_ACTIONS) do
        if scriptInterface:IsActionJustPressed(entry[1]) then
            SetDodgeDirection(stateContext, scriptInterface, entry[2])
            return true
        end
    end
    return false
end

local function CheckTappedDodge(transition, stateContext, scriptInterface)
    if not scriptInterface:IsActionJustTapped("Dodge") and not scriptInterface:IsActionJustReleased("Dodge") then
        return false
    end

    local direction = scriptInterface:GetInputHeading()
    if transition:GetStaticBoolParameterDefault("dodgeWithNoMovementInput", false) then direction = DIRECTION.Back end
    SetDodgeDirection(stateContext, scriptInterface, direction)
    return true
end

local function HasRequirements(scriptInterface)
    local owner = scriptInterface.executionOwner
    local perkLevel = PlayerDevelopmentSystem.GetInstance(owner):IsNewPerkBought(owner, gamedataNewPerkType.Reflexes_Central_Milestone_3)
    if perkLevel ~= 3 then
        Notification.Error("Air Dash Perk (Level 3) is required for Infinite Air Dash.")
        return false
    end

    local stamina = GameInstance.GetStatPoolsSystem():GetStatPoolValue(owner:GetEntityID(), gamedataStatPoolType.Stamina, true)
    if stamina <= 0.0 then
        Notification.Error("Not enough stamina to air dash. (Tip: enable Infinite Stamina)")
        return false
    end

    return true
end

local function CanAirDash(transition, stateContext, scriptInterface)
    local disabled = stateContext:GetPermanentBoolParameter("disableAirDash")
    if disabled.valid and disabled.value then return false end
    if not GameplaySettingsSystem.GetMovementDodgeEnabled(scriptInterface.executionOwner) then return false end
    if transition:IsTouchingGround(scriptInterface) then return false end
    return not transition:IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface)
end

function InfiniteAirDash.HandleAirDash(transition, stateContext, scriptInterface, wrappedFunc)
    local tapped = CheckTappedDodge(transition, stateContext, scriptInterface)
    local directional = CheckDirectionalDodge(stateContext, scriptInterface)
    local result = wrappedFunc(stateContext, scriptInterface)

    if result or not InfiniteAirDash.Enabled.value then return result end
    if not tapped and not directional then return result end
    if not HasRequirements(scriptInterface) then return result end

    return CanAirDash(transition, stateContext, scriptInterface)
end

return InfiniteAirDash
