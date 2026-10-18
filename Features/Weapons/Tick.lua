local Weapons = require("Features/Weapons")
local Weapon = require("Utils/Weapon")
local StatModifiers = require("Utils/StatModifiers")
local WeaponTick = {}

local modifierEntries = {
    { feature = Weapons.StatModifiers.NoReloading, enabled = Weapons.StatModifiers.NoReloading.toggleNoReloading },
    { feature = Weapons.StatModifiers.FastReload, enabled = Weapons.StatModifiers.FastReload.toggleFastReload },
    { feature = Weapons.StatModifiers.NoRecoil, enabled = Weapons.StatModifiers.NoRecoil.toggleNoRecoil },
    { feature = Weapons.StatModifiers.RapidFire, enabled = Weapons.StatModifiers.RapidFire.toggleRapidFire },
    { feature = Weapons.StatModifiers.ShotgunSpray, enabled = Weapons.StatModifiers.ShotgunSpray.toggleShotgunSpray },
    { feature = Weapons.StatModifiers.AlwaysCrit, enabled = Weapons.StatModifiers.AlwaysCrit.toggleAlwaysCrit },
    { feature = Weapons.StatModifiers.InsaneCritDmg, enabled = Weapons.StatModifiers.InsaneCritDmg.toggleInsaneCritDmg },
    { feature = Weapons.StatModifiers.HighBlock, enabled = Weapons.StatModifiers.HighBlock.toggleHighBlock },
    { feature = Weapons.StatModifiers.LowStaminaCost, enabled = Weapons.StatModifiers.LowStaminaCost.toggleLowStaminaCost },
    { feature = Weapons.StatModifiers.BladeCarnage, enabled = Weapons.StatModifiers.BladeCarnage.toggleBladeCarnage },
    { feature = Weapons.StatModifiers.InfiniteCombo, enabled = Weapons.StatModifiers.InfiniteCombo.toggleInfiniteCombo },
    { feature = Weapons.StatModifiers.SmartFastLock, enabled = Weapons.StatModifiers.SmartFastLock.toggleFastLock },
    { feature = Weapons.StatModifiers.SmartWideLock, enabled = Weapons.StatModifiers.SmartWideLock.toggleWideLock },
    { feature = Weapons.StatModifiers.SmartExtraTargets, enabled = Weapons.StatModifiers.SmartExtraTargets.toggleExtraTargets },
    { feature = Weapons.StatModifiers.SmartPerfectAcc, enabled = Weapons.StatModifiers.SmartPerfectAcc.togglePerfectAcc },
    { feature = Weapons.StatModifiers.UnlimitedRange, enabled = Weapons.StatModifiers.UnlimitedRange.toggleUnlimitedRange },
    { feature = Weapons.StatModifiers.PenetrationRounds, enabled = Weapons.StatModifiers.PenetrationRounds.togglePenetrationRounds },
    { feature = Weapons.StatModifiers.HipfireAccuracy, enabled = Weapons.StatModifiers.HipfireAccuracy.toggleHipfireAccuracy },
    { feature = Weapons.StatModifiers.AdsAccuracy, enabled = Weapons.StatModifiers.AdsAccuracy.toggleAdsAccuracy },
}

local refreshQueue = {}
local refreshIndex = 1

local function ClearModifier(feature)
    if #feature.handles == 0 then return end

    for _, id in ipairs(feature.handles) do
        StatModifiers.Remove(id)
    end
    feature.handles = {}
    feature.appliedToWeaponID = nil
end

local function QueueEnabledModifierRefreshes()
    refreshQueue = {}
    refreshIndex = 1

    for _, entry in ipairs(modifierEntries) do
        if entry.enabled.value then
            table.insert(refreshQueue, entry.feature)
        end
    end
end

local function TickStatModifiers(deltaTime)
    if Weapon.HasChanged() then
        QueueEnabledModifierRefreshes()
    end

    local queuedModifier = refreshQueue[refreshIndex]
    if queuedModifier then
        -- Clear the previous weapon before this family applies to the new one.
        ClearModifier(queuedModifier)
        Weapon.MarkChanged()
        queuedModifier.Tick(deltaTime)
        refreshIndex = refreshIndex + 1
        return
    end

    refreshQueue = {}
    refreshIndex = 1
    for _, entry in ipairs(modifierEntries) do
        if not entry.enabled.value then ClearModifier(entry.feature) end
        entry.feature.Tick(deltaTime)
    end
end

function WeaponTick.TickHandler(deltaTime)
    Weapons.GravityGun.Tick()
    Weapons.TeleportShot.Tick()
    Weapons.InfiniteAmmo.Tick()
    Weapons.ForceGun.Tick(deltaTime)
    Weapons.ExplosiveBullets.Tick()
    local hasActiveModifiers = false
    for _, entry in ipairs(modifierEntries) do
        if entry.enabled.value or #entry.feature.handles > 0 then
            hasActiveModifiers = true
            break
        end
    end
    if hasActiveModifiers then
        Weapon.Tick(deltaTime)
        TickStatModifiers(deltaTime)
    end
    Weapon.EndFrame()
end

function WeaponTick.HandleProjectileHit(self, eventData)
    Weapons.FlyingThunderGod.Tick(eventData)
    Weapons.ExplosiveKnives.Tick(eventData)
    Weapons.SmartBlade.Tick(self)
end

return WeaponTick
