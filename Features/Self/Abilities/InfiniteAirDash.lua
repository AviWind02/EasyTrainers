local InfiniteAirDash = {}
InfiniteAirDash.enabled = { value = false }
local Notification = require("UI").Notification

local function dodgeDirection(sc, si, dir)
    sc:SetConditionFloatParameter("DodgeDirection", dir, true);
    si.localBlackboard:SetFloat(
        GetAllBlackboardDefs().PlayerStateMachine.DodgeTimeStamp, EngineTime.ToFloat(GameInstance.GetSimTime())
    )
end

local function dodgedDirectionally(sc, si)
    if si:IsActionJustPressed("DodgeForward") then
        dodgeDirection(sc, si, Direction.Forward)
        return true, Direction.Forward
    elseif si:IsActionJustPressed("DodgeRight") then
        dodgeDirection(sc, si, Direction.Right)
        return true, Direction.Right
    elseif si:IsActionJustPressed("DodgeLeft") then
        dodgeDirection(sc, si, Direction.Left)
        return true, Direction.Left
    elseif si:IsActionJustPressed("DodgeBack") then
        dodgeDirection(sc, si, Direction.Back)
        return true, Direction.Back
    end
    return false, nil
end

local function dodgeTapped(tr, sc, si)
    local dp = si:IsActionJustTapped("Dodge") or si:IsActionJustReleased("Dodge")
    local dir = 0
    if dp then
        if tr:GetStaticBoolParameterDefault("dodgeWithNoMovementInput", false) then
            dir = Direction.Back
            dodgeDirection(sc, si, dir)
            return true, dir
        else
            dir = si:GetInputHeading()
            dodgeDirection(sc, si, dir)
            return true, nil
        end
    end
    return false, nil
end

local function hasValidRequirements(si)
    local hasAirDashPerk = PlayerDevelopmentSystem.GetInstance(
            si.executionOwner
        ):IsNewPerkBought(
            si.executionOwner,
            gamedataNewPerkType.Reflexes_Central_Milestone_3
        ) == 3 -- Level 3 to unlock ability to dash in midair

    local enoughStamina = GameInstance.GetStatPoolsSystem():GetStatPoolValue(
        si.executionOwner:GetEntityID(),
        gamedataStatPoolType.Stamina,
        true
    ) > 0.0

    if not hasAirDashPerk then
        Notification.Error("You must have Air Dash Perk Level 3 first to use this feature.")
        InfiniteAirDash.enabled.value = false -- turn it off
        return false
    end

    if not enoughStamina then
        Notification.Error("Your stamina is running low.\nHave you activated infinite stamina?")
        return false
    end

    return hasAirDashPerk and enoughStamina
end

function InfiniteAirDash.Tick(tr, sc, si, wf)
    local dp = dodgeTapped(tr, sc, si)
    local ddp = dodgedDirectionally(sc, si)
    local tf = tr:IsCurrentFallSpeedTooFastToEnter(sc, si)
    local r = wf(sc, si)

    if InfiniteAirDash.enabled.value and (dp or ddp) then
        if hasValidRequirements(si) then
            local param = sc:GetPermanentBoolParameter("disableAirDash")
            local airDashDisable = param.valid and param.value
            local dodgeEnabled = GameplaySettingsSystem.GetMovementDodgeEnabled(si.executionOwner)
            r = (airDashDisable or not dodgeEnabled or tf)
        end
    end

    return r
end
return InfiniteAirDash