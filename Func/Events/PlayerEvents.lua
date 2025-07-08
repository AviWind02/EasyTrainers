local WeaponGlobals = require("Func/Weapons/WeaponGlobals")
local PlayerEvents = {}

function PlayerEvents.Init()
    Observe("PlayerPuppet", "OnHit", function(self, hitEvent)
        if hitEvent and hitEvent.hitPosition then
            lastHit = hitEvent.hitPosition
            print(string.format("[PlayerPuppet:OnHit] Impact at: x=%.2f y=%.2f z=%.2f", lastHit.x, lastHit.y, lastHit.z))
        else
            print("[PlayerPuppet:OnHit] Hit received, but no hit position provided.")
        end
    end)

    Observe("PlayerPuppet", "OnAction", function(_, action)
        WeaponGlobals.HandleInputAction(action)
    end)
end

return PlayerEvents
