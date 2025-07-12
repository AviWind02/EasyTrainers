
local DrawManager = require("Draw/Manager")
local Notifier = require("Draw/NotificationManager")
local Controls = require("Draw/Controls")
local status = require("Func/Core/SharedStatus")
local Logger = require("Func/Core/Logger")

local generalItems = require("Func/DataExtractors/GeneralItems")
local vehiclesItems = require("Func/DataExtractors/VehiclesItems")
local weaponsItems = require("Func/DataExtractors/WeaponItems")


local playerEvents = require("Func/Events/PlayerEvents")
local projectileEvents = require("Func/Events/ProjectileEvents")
local vehicleEvents = require("Func/Events/VehicleEvents")

local weaponsTickEvents = require("Func/Weapons/WeaponTick")
local vehicleTickEvents = require("Func/Vehicles/VehicleTick")



registerForEvent("onInit", function()
    Logger.Initialize()
    Logger.Log("[EasyTrainerInit] Starting initialization")

    Logger.Log("[EasyTrainerInit] Resetting dump statuses.")
    status.ResetStatuses({
        "GeneralItems",
        "VehiclesItems",
        "WeaponsItems"
    })

    Logger.Log("[EasyTrainerInit] Performing data dumps")
    generalItems.Dump()
    vehiclesItems.Dump()
    weaponsItems.Dump()

    Logger.Log("[EasyTrainerInit] Initializing events")
    playerEvents.Init()
    projectileEvents.Init()
    vehicleEvents.Init()

    Logger.Log("[EasyTrainerInit] Initialization complete.")
end)


registerForEvent("onUpdate", function(delta)
    weaponsTickEvents.TickHandler(delta)
    vehicleTickEvents.TickHandler(delta)
end)


local hasShownWelcome = false

registerForEvent("onDraw", function()
    Controls.HandleInputTick()

    if Controls.IsMenuOpen() then
        -- Draw main menu
        ImGui.SetNextWindowSize(300, 500, ImGuiCond.FirstUseEver)

        if ImGui.Begin("Luna Menu", ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoScrollWithMouse + ImGuiWindowFlags.NoTitleBar) then
            local winX, winY = ImGui.GetWindowPos()
            local winW, winH = ImGui.GetWindowSize()
            DrawManager.DrawMenu(winX, winY, winW, winH)
            ImGui.End()
        end
    end

    -- Always render notifications
    Notifier.Render()
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
