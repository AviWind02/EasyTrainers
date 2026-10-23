local Logger = {
    LogCount = 6,
    LogDirectory = "Logs"
}

local s_CurrentLogFile = ""
local s_NumberedLogFile = ""

local function GetTimestamp()
    return os.date("[%Y-%m-%d %H:%M:%S]")
end

local function LogPath(index)
    return string.format("%s/log_%d.txt", Logger.LogDirectory, index)
end

local function FileExists(path)
    local file = io.open(path, "r")
    if not file then return false end
    file:close()
    return true
end

local function GetNextLogIndex()
    local index = 1
    while FileExists(LogPath(index)) do
        index = index + 1
    end
    return index
end

local function RotateLogs()
    local count = 0
    while count < 100 and FileExists(LogPath(count + 1)) do
        count = count + 1
    end

    for index = Logger.LogCount, count do
        os.remove(LogPath(index))
    end
end

local function AppendLine(path, line)
    local file = io.open(path, "a")
    if not file then return end
    file:write(line .. "\n")
    file:close()
end

function Logger.Log(message)
    local line = GetTimestamp() .. " " .. tostring(message)
    AppendLine(s_NumberedLogFile, line)
    AppendLine(s_CurrentLogFile, line)
    print("[EasyTrainer] " .. tostring(message))
end

function Logger.Initialize()
    RotateLogs()

    local index = GetNextLogIndex()
    s_NumberedLogFile = LogPath(index)
    s_CurrentLogFile = string.format("%s/log_current.txt", Logger.LogDirectory)

    local file = io.open(s_CurrentLogFile, "w")
    if file then file:close() end

    Logger.Log("Logger initialized, writing to log_" .. index .. ".txt and log_current.txt")
end

return Logger
