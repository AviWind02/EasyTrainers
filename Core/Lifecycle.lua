local Logger = require("Core/Logger")

local Lifecycle = {}

local s_Handlers = {}

function Lifecycle.Register(name, handlers)
    table.insert(s_Handlers, { Name = name, OnSessionEnd = handlers.OnSessionEnd, OnShutdown = handlers.OnShutdown })
end

local function Run(stage)
    for _, handler in ipairs(s_Handlers) do
        local callback = handler[stage]
        if callback then
            local ok, err = pcall(callback)
            if not ok then
                Logger.Log(string.format("Lifecycle: %s %s failed (%s)", handler.Name, stage, tostring(err)))
            end
        end
    end
end

function Lifecycle.SessionEnd()
    Run("OnSessionEnd")
end

function Lifecycle.Shutdown()
    Run("OnShutdown")
end

return Lifecycle
