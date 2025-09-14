local InfiniteAmmo = {}
local StatusEffect = require("Utils").StatusEffect

InfiniteAmmo.enabled = { value = false }

local wasApplied = false

function InfiniteAmmo.Tick()
    if InfiniteAmmo.enabled.value then
        if not wasApplied then
            StatusEffect.Set("GameplayRestriction.InfiniteAmmo", true)
            wasApplied = true
        end
    elseif wasApplied then
            StatusEffect.Set("GameplayRestriction.InfiniteAmmo", false)
        wasApplied = false
    end
end

return InfiniteAmmo
