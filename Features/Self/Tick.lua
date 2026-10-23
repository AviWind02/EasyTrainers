local Self = require("Features/Self")

local SelfTick = {}

function SelfTick.TickHandler()
    local player = Game.GetPlayer()
    if not player then return end

    local playerID = player:GetEntityID()
    Self.StatModifiers.Tick(playerID)
    Self.AirThrusterBoots.Tick(playerID)
    Self.AdvancedMobility.Tick(playerID)

    Self.WantedLevel.Tick()
    Self.GodMode.Tick()
    Self.Invisibility.Tick()
    Self.SuperSpeed.Tick()
    Self.NoClip.Tick()
    Self.InfiniteJumps.Tick()
end

return SelfTick
