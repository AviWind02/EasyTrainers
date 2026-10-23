local Logger = require("Core/Logger")

local WorldFacts = {}

function WorldFacts.Get(name)
    return Game.GetQuestsSystem():GetFactStr(name)
end

function WorldFacts.Set(name, value)
    Game.GetQuestsSystem():SetFactStr(name, value)
    Logger.Log(string.format("WorldFacts: %s set to %s", name, tostring(value)))
end

function WorldFacts.IsTrue(name)
    return tostring(WorldFacts.Get(name)) == "1"
end

function WorldFacts.SetBool(name, state)
    WorldFacts.Set(name, state and 1 or 0)
end

return WorldFacts
