local Logger = {}
local logCount = 6
local logDir = "Logs"
local logWindow = {}
local currentLogFile = ""
local numberedLogFile = ""

-- Get current timestamp string
local function getTimestamp()
    return os.date("[%Y-%m-%d %H:%M:%S]")
end

-- Get next log file index
local function getNextLogIndex()
    local index = 1
    while true do
        local path = string.format("%s/log_%d.txt", logDir, index)
        local file = io.open(path, "r")
        if not file then break end
        file:close()
        index = index + 1
    end
    return index
end

-- Rotate logs (keep max 6, delete older ones)
local function rotateLogs()
    local files = {}
    for i = 1, 100 do
        local path = string.format("%s/log_%d.txt", logDir, i)
        local file = io.open(path, "r")
        if file then
            table.insert(files, path)
            file:close()
        else
            break
        end
    end

    if #files >= logCount then
        for i = logCount, #files do
            os.remove(files[i])
        end
    end
end

-- Internal write to both log files
local function writeToFile(msg)
    -- Write to numbered log
    local f1 = io.open(numberedLogFile, "a")
    if f1 then
        f1:write(msg .. "\n")
        f1:close()
    end

    -- Write to current log
    local f2 = io.open(currentLogFile, "a")
    if f2 then
        f2:write(msg .. "\n")
        f2:close()
    end
end

-- Public: log message
function Logger.Log(msg)
    local timestamped = getTimestamp() .. " " .. msg
    table.insert(logWindow, timestamped)
    writeToFile(timestamped)
    print(msg) -- Log to console as well
end

-- Setup logger
function Logger.Initialize()
    rotateLogs()
    local index = getNextLogIndex()
    numberedLogFile = string.format("%s/log_%d.txt", logDir, index)
    currentLogFile = string.format("%s/log_current.txt", logDir)

    -- Clear current log on each run
    local clear = io.open(currentLogFile, "w")
    if clear then clear:close() end

    Logger.Log("[EasyTrainerLogger] Logger initialized. Writing to log_" .. index .. ".txt and log_current.txt")
end

return Logger
