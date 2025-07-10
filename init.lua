local generalItems = require("DataExtractors/GeneralItems")
local vehiclesItems = require("DataExtractors/VehiclesItems")
local weaponsItems = require("DataExtractors/WeaponItems")

local status = require("Func/Core/SharedStatus")

local playerEvents = require("Func/Events/PlayerEvents")
local projectileEvents = require("Func/Events/ProjectileEvents")
local vehicleEvents = require("Func/Events/VehicleEvents")

local weaponsTickEvents = require("Func/Weapons/WeaponTick")
local vehicleTickEvents = require("Func/Vehicles/VehicleTick")
 


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

local lastVehicle = nil
local wasInVehicle = false

registerForEvent("onDraw", function()
    local player = Game.GetPlayer()
    if not player then return end

    local currentVehicle = Game.GetMountedVehicle(player)

    -- Track last vehicle when player exits
    if currentVehicle ~= nil then
        wasInVehicle = true
        lastVehicle = currentVehicle
    elseif wasInVehicle then
        wasInVehicle = false
        -- lastVehicle already set, keep it
    end

    -- === Demo ImGui Window ===
    ImGui.Begin("Vehicle Remote Test")

    if lastVehicle then
        local name = lastVehicle:GetDisplayName()
        ImGui.Text("Last Vehicle: " .. tostring(name))


    else
        ImGui.Text("No last vehicle stored.")
    end


    ImGui.End()
end)


 registerForEvent("onUpdate", function(delta)
     weaponsTickEvents.TickHandler(delta)
     vehicleTickEvents.TickHandler(delta) 
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


