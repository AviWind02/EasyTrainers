local Draw = require("UI")
local Welcome = require("View/Welcome")

local Logger = require("Core/Logger")
local Language = require("Core/Language")
local JsonHelper = require("Core/JsonHelper")
local Session = require("Core/cp2077-cet-kit/GameSession")
local Cron = require("Core/cp2077-cet-kit/Cron")

local Gameplay = require("Gameplay")

local SelfTick = require("Features/Self/Tick")
local WeaponsTick = require("Features/Weapons/Tick")

local WeaponLoader = require("Features/DataExtractors/WeaponLoader")
local VehicleLoader = require("Features/DataExtractors/VehicleLoader")
local GeneralLoader = require("Features/DataExtractors/GeneralLoader")
local PerkLoader = require("Features/DataExtractors/PerkLoader")
local Telport = require("Features/Teleports/TeleportLocations")

GameState = {}

local config = JsonHelper.Read("config.json")

local MainMenu, World, Vehicle

local modulesLoaded = false
local function TryLoadModules()
    if GameState.isLoaded and not modulesLoaded then
        modulesLoaded = true

        MainMenu = require("View/MainMenu")
        World = require("Features/World")
        Vehicle = require("Features/Vehicle")

        Logger.Log("[EasyTrainer] Game modules initialized.")
    end
end

;
local function GetGameState()
    GameState = Session.GetState()
end

local function UpdateSessionState()
    GameState.isLoaded = Session.IsLoaded()
    TryLoadModules()
end


registerForEvent("onInit", function()
    
    Logger.Initialize()
    Logger.Log("[EasyTrainer] Initialization started")
    Language.Load(config and config.Lang or "en")

    Cron.After(0.3, GetGameState)
    Session.Listen(UpdateSessionState)

    Logger.Log("[EasyTrainer] Game session States")

    Cron.Every(0.3, UpdateSessionState)


    Logger.Log("[EasyTrainer] Loading data...")
    WeaponLoader:LoadAll()
    VehicleLoader:LoadAll()
    GeneralLoader:LoadAll()
    PerkLoader:LoadAll()
    Telport.LoadAll()

    Observe("BaseProjectile", "ProjectileHit", function(self, eventData)
        WeaponsTick.HandleProjectileHit(self, eventData)
    end)

    Observe("PlayerPuppet", "OnAction", function(_, action)
        -- local actionName = Game.NameToString(action:GetName(action))
        -- local actionType = action:GetType(action).value
        Gameplay.WeaponInput.HandleInputAction(action)
        -- Draw.InputHandler.LogAction(actionName, actionType)
    end)



    Logger.Log("[EasyTrainer] Init complete.")
end)

Draw.InputHandler.RegisterInput()

registerForEvent("onUpdate", function(deltaTime)  


    SelfTick.TickHandler()
    WeaponsTick.TickHandler(deltaTime)
    World.WorldTime.Update(deltaTime)
    World.WorldWeather.Update()
    Vehicle.Headlights.UpdateRGB(deltaTime)

    Cron.Update(deltaTime)
end)



registerForEvent("onDraw", function()
    Draw.InputHandler.HandleInputTick()
    Draw.Notifier.Render()
    Welcome.Render()

    if not Draw.InputHandler.IsMenuOpen() or not modulesLoaded then return end
    
    local menuX, menuY, menuW, menuH
    ImGui.SetNextWindowSize(300, 500, ImGuiCond.FirstUseEver)

    if ImGui.Begin("EasyTrainer", ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoScrollWithMouse + ImGuiWindowFlags.NoTitleBar) then
        menuX, menuY = ImGui.GetWindowPos()
        menuW, menuH = ImGui.GetWindowSize()

        MainMenu.Render(menuX, menuY, menuW, menuH)
        ImGui.End()
    end

    Draw.InfoBox.Render(menuX, menuY, menuW, menuH)
end)

registerForEvent("onShutdown", function()
    Gameplay.StatModifiers.ClearAll()
    Draw.InputHandler.ClearMenuRestrictions() -- I don't know how status effects work but I believe they apply to the save?
end)

