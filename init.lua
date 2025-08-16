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
local TeleportTick = require("Features/Teleports/Teleport")

local WeaponLoader = require("Features/DataExtractors/WeaponLoader")
local VehicleLoader = require("Features/DataExtractors/VehicleLoader")
local GeneralLoader = require("Features/DataExtractors/GeneralLoader")
local PerkLoader = require("Features/DataExtractors/PerkLoader")
local Teleport = require("Features/Teleports/TeleportLocations")

local SelfNoClip = require("Features/Self/NoClip")

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
    GameState.IsPaused = Session.IsPaused() 
    GameState.IsDead = Session.IsDead()
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
    Teleport.LoadAll()

    Logger.Log("[EasyTrainer] Registering overrides...")
    Override("scannerDetailsGameController", "ShouldDisplayTwintoneTab", function(this, wrappedMethod)
        return VehicleLoader:HandleTwinToneScan(this, wrappedMethod)
    end)

    Logger.Log("[EasyTrainer] Registering observers...")
    Observe("BaseProjectile", "ProjectileHit", function(self, eventData)
        WeaponsTick.HandleProjectileHit(self, eventData)
    end)
    
    Observe("PlayerPuppet", "OnAction", function(_, action)
        Gameplay.WeaponInput.HandleInputAction(action)
        SelfNoClip.HandleMouseLook(action)
    end)

    Logger.Log("[EasyTrainer] Init complete.")
end)

Draw.InputHandler.RegisterInput()

registerForEvent("onUpdate", function(deltaTime)  

     if not GameState.isLoaded or GameState.IsPaused or GameState.IsDead then
        return
    end


    SelfTick.TickHandler()
    WeaponsTick.TickHandler(deltaTime)
    World.WorldTime.Update(deltaTime)
    World.WorldWeather.Update()
    Vehicle.Headlights.UpdateRGB(deltaTime)
    TeleportTick.Tick(deltaTime)
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

