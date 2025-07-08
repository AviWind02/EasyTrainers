local M = {}

local statusPath = "Shared/SharedStatus.json"

local function ReadStatus()
    local file = io.open(statusPath, "r")
    if not file then return {} end

    local content = file:read("*a")
    file:close()

    local ok, data = pcall(function() return json.decode(content) end)
    return ok and data or {}
end

local function WriteStatus(statusTable)
    local file = io.open(statusPath, "w")
    if not file then
        print("[SharedStatus] Failed to open status file for writing.")
        return false
    end

    file:write(json.encode(statusTable))
    file:close()
    return true
end

function M.SetDumpStatus(category, status)
    local current = ReadStatus()
    current[category] = status
    WriteStatus(current)
end

function M.GetDumpStatus(category)
    local current = ReadStatus()
    return current[category] or "Pending"
end

function M.ResetStatuses(categories)
    local reset = {}
    for _, cat in ipairs(categories) do
        reset[cat] = "Pending"
    end
    local file = io.open(statusPath, "w")
    if file then
        file:write(json.encode(reset))
        file:close()
    else
        print("[SharedStatus] Failed to reset status file.")
    end
end

return M
