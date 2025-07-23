local Logger = {
    logCount = 6,
    logDir = "Logs",
    logWindow = {},
    currentLogFile = "",
    numberedLogFile = "",
    autoScroll = true,
    showTimestamps = true
}

-- Get current timestamp string
local function getTimestamp()
    return os.date("[%Y-%m-%d %H:%M:%S]")
end

-- Get next log file index
local function getNextLogIndex()
    local index = 1
    while true do
        local path = string.format("%s/log_%d.txt", Logger.logDir, index)
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
        local path = string.format("%s/log_%d.txt", Logger.logDir, i)
        local file = io.open(path, "r")
        if file then
            table.insert(files, path)
            file:close()
        else
            break
        end
    end

    if #files >= Logger.logCount then
        for i = Logger.logCount, #files do
            os.remove(files[i])
        end
    end
end

-- Internal write to both log files
local function writeToFile(msg)
    local f1 = io.open(Logger.numberedLogFile, "a")
    if f1 then
        f1:write(msg .. "\n")
        f1:close()
    end

    local f2 = io.open(Logger.currentLogFile, "a")
    if f2 then
        f2:write(msg .. "\n")
        f2:close()
    end
end

-- Public: log message
function Logger.Log(msg)
    local timestamped = getTimestamp() .. " " .. msg
    table.insert(Logger.logWindow, timestamped)
    writeToFile(timestamped)
    print(msg)
end

-- Setup logger
function Logger.Initialize()
    rotateLogs()
    local index = getNextLogIndex()
    Logger.numberedLogFile = string.format("%s/log_%d.txt", Logger.logDir, index)
    Logger.currentLogFile = string.format("%s/log_current.txt", Logger.logDir)

    local clear = io.open(Logger.currentLogFile, "w")
    if clear then clear:close() end

    Logger.Log("[EasyTrainerLogger] Logger initialized. Writing to log_" .. index .. ".txt and log_current.txt")
end

-- Draw log window
function Logger.DrawLogWindow()
    ImGui.Begin("Logger Window")

    if ImGui.Button("Clear") then
        Logger.logWindow = {}
    end
    ImGui.SameLine()
    if ImGui.Button("Copy") then
        local text = table.concat(Logger.logWindow, "\n")
        ImGui.SetClipboardText(text)
    end

    ImGui.Separator()
    ImGui.BeginChild("LogScroll")

    for _, line in ipairs(Logger.logWindow) do
        if Logger.showTimestamps then
            ImGui.TextUnformatted(line)
        else
            local msgOnly = line:gsub("^%[.-%]%s*", "")
            ImGui.TextUnformatted(msgOnly)
        end
    end

    ImGui.SetScrollHereY(1.0)

    ImGui.EndChild()
    ImGui.End()
end

return Logger
