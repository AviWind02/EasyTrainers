local Draw = require("UI")
local MainMenu = require("View/MainMenu")
local Welcome = require("View/Welcome")
local Logger = require("Core/Logger")
local Gameplay = require("Gameplay")

local SelfTick = require("Features/Self/Tick")
local WeaponsTick = require("Features/Weapons/Tick")
local World = require("Features/World")
local Vehicle = require("Features/Vehicle")

local WeaponLoader = require("Features/DataExtractors/WeaponLoader")
local VehicleLoader = require("Features/DataExtractors/VehicleLoader")
local GeneralLoader = require("Features/DataExtractors/GeneralLoader")
local PerkLoader = require("Features/DataExtractors/PerkLoader")

local Session = require("Core/cp2077-cet-kit/GameSession")
local Cron = require("Core/cp2077-cet-kit/Cron")

GameState = {}
local SessionLoaded = false

local function GetGameState()
        GameState = Session.GetState()
end

local function UpdateSessionState()
    GameState.isLoaded = Session.IsLoaded()

    if GameState.isLoaded then
        SessionLoaded = true
    end
end

registerForEvent("onInit", function()
    
    Logger.Initialize()
    Logger.Log("[EasyTrainer] Initialization started")
    
    Cron.After(0.3, GetGameState)
    Session.Listen(UpdateSessionState)

    Logger.Log("[EasyTrainer] Game session States")

    Cron.Every(0.3, UpdateSessionState)


    Logger.Log("[EasyTrainer] Loading data...")
    WeaponLoader:LoadAll()
    VehicleLoader:LoadAll()
    GeneralLoader:LoadAll()
    PerkLoader:LoadAll()

    Observe("BaseProjectile", "ProjectileHit", function(self, eventData)
        WeaponsTick.HandleProjectileHit(self, eventData)
    end)

    Observe("PlayerPuppet", "OnAction", function(_, action)
        Draw.InputHandler.HandleControllerInput(action)
        Gameplay.WeaponInput.HandleInputAction(action)
        -- Draw.InputHandler.LogAction(actionName, actionType)
    end)



    Logger.Log("[EasyTrainer] Init complete.")
end)

Draw.InputHandler.RegisterInput()

registerForEvent("onUpdate", function(deltaTime)
    if not SessionLoaded then return end

    SelfTick.TickHandler()
    WeaponsTick.TickHandler(deltaTime)
    World.WorldTime.Update(deltaTime)
    World.WorldWeather.Update()
    Vehicle.Headlights.UpdateRGB(deltaTime)

    Cron.Update(deltaTime)
end)


registerForEvent("onDraw", function()
    Draw.InputHandler.HandleInputTick()
    Welcome.Render()

    if not Draw.InputHandler.IsMenuOpen() or not SessionLoaded then return end

    local menuX, menuY, menuW, menuH
    ImGui.SetNextWindowSize(300, 500, ImGuiCond.FirstUseEver)

    if ImGui.Begin("EasyTrainer", ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoScrollWithMouse + ImGuiWindowFlags.NoTitleBar) then
        menuX, menuY = ImGui.GetWindowPos()
        menuW, menuH = ImGui.GetWindowSize()

        MainMenu.Render(menuX, menuY, menuW, menuH)
        ImGui.End()
    end

    Draw.InfoBox.Render(menuX, menuY, menuW, menuH)
    Draw.Notifier.Render()
end)



registerForEvent("onShutdown", function()
    Gameplay.StatModifiers.ClearAll()
    Draw.InputHandler.ClearMenuRestrictions()
end)


