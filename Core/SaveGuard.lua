local Logger = require("Core/Logger")
local Session = require("Core/cp2077-cet-kit/GameSession")

local SaveGuard = {
    Directory = "Sessions"
}

local s_SessionData = { Trackers = {} }
local s_Trackers = {}
local s_Pending = nil

function SaveGuard.Track(name, tracker)
    s_Trackers[name] = tracker
end

local function Capture(data)
    data.Trackers = {}
    for name, tracker in pairs(s_Trackers) do
        local ok, value = pcall(tracker.Capture)
        if ok and value ~= nil then data.Trackers[name] = value end
    end
end

local function QueueRestore(data)
    s_Pending = type(data.Trackers) == "table" and data.Trackers or nil
end

function SaveGuard.Initialize()
    Session.StoreInDir(SaveGuard.Directory)
    Session.Persist(s_SessionData)
    Session.OnSaveData(Capture)
    Session.OnLoadData(QueueRestore)
end

function SaveGuard.Tick()
    if not s_Pending or not Game.GetPlayer() then return end

    local pending = s_Pending
    s_Pending = nil

    for name, value in pairs(pending) do
        local tracker = s_Trackers[name]
        if tracker then
            local ok, err = pcall(tracker.Restore, value)
            if not ok then Logger.Log(string.format("SaveGuard: %s restore failed (%s)", name, tostring(err))) end
        end
    end
end

return SaveGuard
