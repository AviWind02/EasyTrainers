local Draw = require("UI")
local MainMenu = require("View/MainMenu")
local Logger = require("Core/Logger")
local Gameplay = require("Gameplay")


local SelfTick = require("Features/Self/Tick")
local WeaponsTick = require("Features/Weapons/Tick")

local WeaponLoader = require("Features/DataExtractors/WeaponLoader")
local VehicleLoader = require("Features/DataExtractors/VehicleLoader")
local GeneralLoader = require("Features/DataExtractors/GeneralLoader")

registerForEvent("onInit", function()
    Logger.Initialize()
    Logger.Log("[EasyTrainerInit] Starting initialization")

    Logger.Log("[EasyTrainerInit] Performing data dumps and loading to memory.")
    WeaponLoader:LoadAll()
    VehicleLoader:LoadAll()
    GeneralLoader:LoadAll()

    Observe("BaseProjectile", "ProjectileHit", function(self, eventData)
        WeaponsTick.HandleProjectileHit(self, eventData)
    end)
    Logger.Log("[EasyTrainerInit] Observing BaseProjectile.ProjectileHit")

    Observe("PlayerPuppet", "OnAction", function(_, action)
        local actionName = Game.NameToString(action:GetName(action))
        local actionType = action:GetType(action).value
        Gameplay.WeaponInput.HandleInputAction(action)
    end)
    Logger.Log("[EasyTrainerInit] Observing PlayerPuppet.OnAction")

    Logger.Log("[EasyTrainerInit] Initialization complete.")
end)
registerForEvent("onUpdate", function(deltaTime)
    SelfTick.TickHandler()
    WeaponsTick.TickHandler(deltaTime)
end)



registerForEvent("onDraw", function()
    Draw.InputHandler.HandleInputTick()
    local menuX, menuY, menuW, menuH

    if Draw.InputHandler.IsMenuOpen() then
        ImGui.SetNextWindowSize(300, 500, ImGuiCond.FirstUseEver)

        if ImGui.Begin("EasyTrainer", ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoScrollWithMouse + ImGuiWindowFlags.NoTitleBar) then
            menuX, menuY = ImGui.GetWindowPos()
            menuW, menuH = ImGui.GetWindowSize()

            MainMenu.Render(menuX, menuY, menuW, menuH)
            ImGui.End()
        end
        Draw.InfoBox.Render(menuX, menuY, menuW, menuH)
    end

    Draw.Notifier.Render()
end)



registerForEvent("onShutdown", function()
    Gameplay.StatModifiers.ClearAll()
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
