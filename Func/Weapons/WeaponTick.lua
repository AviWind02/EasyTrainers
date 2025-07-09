local JsonHelper = require("Func/Core/JsonHelper")

local FlyingThunderGod = require("Func/Weapons/FlyingThunderGod")
local SmartBlade = require("Func/Weapons/SmartBlade")
local GravityGun = require("Func/Weapons/GravityGun")
local TeleportShot = require("Func/Weapons/TeleportShot")


local WeaponTick = {}

local lastCheck = 0
local gravityGunEnabled = false
local teleyGunEnabled = false

function WeaponTick.TickHandler(delta)
    lastCheck = lastCheck + delta
    if lastCheck >= 1.0 then
        lastCheck = 0
        gravityGunEnabled = JsonHelper.GetBoolValue("WeaponOptions", "GravityGun")
        teleyGunEnabled = JsonHelper.GetBoolValue("WeaponOptions", "TeleyGun")
    end

    if gravityGunEnabled then
        GravityGun.Tick()
    end
    if teleyGunEnabled then
        TeleportShot.TeleportToLookAt()
    end
end

function WeaponTick.HandleProjectileHit(self, eventData)
    if JsonHelper.GetBoolValue("WeaponOptions", "FlyingThunderGodTechnique") then
        FlyingThunderGod.Handle(eventData)
    end

    if JsonHelper.GetBoolValue("WeaponOptions", "SmartBladeReturn") then
        SmartBlade.Return(self, eventData)

    end
end

return WeaponTick
