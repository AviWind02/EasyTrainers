local Weapon = require("Utils/Weapon")

local SmartBlade = {}

SmartBlade.Enabled = { value = false }

function SmartBlade.OnProjectileHit(projectile)
    if not SmartBlade.Enabled.value or not projectile then return end
    if Weapon.IsRangedEquipped() then return end

    local player = Game.GetPlayer()
    if not player then return end

    local position = player:GetWorldPosition()
    local returnPosition = Vector4.new(position.x, position.y, position.z - 0.5, 1.0)
    Game.GetTeleportationFacility():Teleport(projectile, returnPosition, player:GetWorldOrientation():ToEulerAngles())
end

return SmartBlade
