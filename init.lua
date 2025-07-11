local generalItems = require("DataExtractors/GeneralItems")
local vehiclesItems = require("DataExtractors/VehiclesItems")
local weaponsItems = require("DataExtractors/WeaponItems")

local status = require("Func/Core/SharedStatus")

local playerEvents = require("Func/Events/PlayerEvents")
local projectileEvents = require("Func/Events/ProjectileEvents")
local vehicleEvents = require("Func/Events/VehicleEvents")

local weaponsTickEvents = require("Func/Weapons/WeaponTick")
local vehicleTickEvents = require("Func/Vehicles/VehicleTick")

local JsonHelper = require("Func/Core/JsonHelper") -- Assuming you're requiring this module
local sharePath = "Shared/Dump.json"


registerForEvent("onInit", function()
    print("[EasyTrainerInit] Starting initialization")

    print("[EasyTrainerInit] Resetting dump statuses.")
    status.ResetStatuses({
        "GeneralItems",
        "VehiclesItems",
        "WeaponsItems"
    })

    print("[EasyTrainerInit] Performing data dumps")
    generalItems.Dump()
    vehiclesItems.Dump()
    weaponsItems.Dump()

    print("[EasyTrainerInit] Initializing events")
    playerEvents.Init()
    projectileEvents.Init()
    vehicleEvents.Init()




    print("[EasyTrainerInit] Initialization complete.")
end)




registerForEvent("onUpdate", function(delta)
    weaponsTickEvents.TickHandler(delta)
    vehicleTickEvents.TickHandler(delta)
end)







local DrawManager = require("Draw/Manager")

registerForEvent("onDraw", function()
    -- Set up a dummy window to enable movement and resizing
    ImGui.SetNextWindowSize(300, 500, ImGuiCond.FirstUseEver)

    if ImGui.Begin("Luna Menu", ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoScrollWithMouse + ImGuiWindowFlags.NoTitleBar) then
        -- Get window position and size
        local winX, winY = ImGui.GetWindowPos()
        local winW, winH = ImGui.GetWindowSize()

        -- Pass the bounds into your DrawMenu
        DrawManager.DrawMenu(winX, winY, winW, winH)

        ImGui.End()
    end
end)


--[[
local loggedActions = {}
local logFilePath = "Shared/CyberpunkInputLog.json"

Observe("PlayerPuppet", "OnAction", function(_, action)
    local actionName = Game.NameToString(action:GetName(action))
    local actionType = action:GetType(action).value
    local key = actionName .. "|" .. actionType

    if loggedActions[key] then return end
    loggedActions[key] = true

    local keys = action:GetKey(action)
    local keyStr = "UnknownKey"
    if keys and #keys > 0 then
        keyStr = table.concat(keys, ", ")
    end

    local value = action:GetValue(action)
    local isButton = action:IsButton(action)
    local isJustPressed = action:IsButtonJustPressed(action)
    local isJustReleased = action:IsButtonJustReleased(action)
    local isAxis = action:IsAxisChangeAction(action)
    local isRelative = action:IsRelativeChangeAction(action)

    local jsonData = {
        actionName = actionName,
        actionType = actionType,
        keyCode = keyStr,
        value = value or 0,
        isButton = isButton,
        justPressed = isJustPressed,
        justReleased = isJustReleased,
        isAxis = isAxis,
        isRelative = isRelative
    }

    -- Serialize table to JSON manually
    local function escape(str)
        return tostring(str):gsub("\\", "\\\\"):gsub("\"", "\\\"")
    end

    local function toJSON(tbl)
        local parts = {}
        for k, v in pairs(tbl) do
            local key = "\"" .. escape(k) .. "\""
            local value
            if type(v) == "string" then
                value = "\"" .. escape(v) .. "\""
            elseif type(v) == "number" or type(v) == "boolean" then
                value = tostring(v)
            else
                value = "\"UnsupportedType\""
            end
            table.insert(parts, key .. ": " .. value)
        end
        return "{ " .. table.concat(parts, ", ") .. " }"
    end

    local line = toJSON(jsonData) .. "\n\n\n\n"

    local file = io.open(logFilePath, "a")
    if file then
        file:write(line)
        file:close()
    else
        print("Failed to open file:", logFilePath)
    end
end)
--]]
