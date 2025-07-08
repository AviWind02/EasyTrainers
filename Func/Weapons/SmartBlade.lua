local SmartBlade = {}

-- Bring blade back to player (SmartBlade)
function SmartBlade.Return(self, eventData)
    local player = Game.GetPlayer()
    if not player then return end

    local playerPos = player:GetWorldPosition()
    local playerLookPos = player:GetLookAtPosition()

    local returnPos = Vector4.new(playerPos.x, playerPos.y, playerPos.z - 0.5, 1.0)
    Game.GetTeleportationFacility():Teleport(self, returnPos, EulerAngles.new(playerLookPos.x, playerLookPos.y, playerLookPos.z))
end

return SmartBlade
