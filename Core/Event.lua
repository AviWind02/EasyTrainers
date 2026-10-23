local Logger = require("Core/Logger")

local Event = {}

function Event.RegisterInit(callback)
    registerForEvent("onInit", callback)
end

function Event.RegisterUpdate(callback)
    registerForEvent("onUpdate", callback)
end

function Event.RegisterDraw(callback)
    registerForEvent("onDraw", callback)
end

function Event.RegisterShutdown(callback)
    registerForEvent("onShutdown", callback)
end

function Event.Observe(class, method, callback)
    Observe(class, method, callback)
    Logger.Log(string.format("Event: observing %s.%s", tostring(class), tostring(method)))
end

function Event.ObserveAfter(class, method, callback)
    ObserveAfter(class, method, callback)
    Logger.Log(string.format("Event: observing after %s.%s", tostring(class), tostring(method)))
end

function Event.Override(class, method, callback)
    Override(class, method, callback)
    Logger.Log(string.format("Event: overriding %s.%s", tostring(class), tostring(method)))
end

return Event
