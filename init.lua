local Language = require("Core/Language")
local Logger = require("Core/Logger")
local Event = require("Core/Event")
local JsonHelper = require("Core/JsonHelper")
local Session = require("Core/cp2077-cet-kit/GameSession")
local Cron = require("Core/cp2077-cet-kit/Cron")
local OptionConfig = require("Config/OptionConfig")

-- Config
local BindingsConfig = require("Config/BindingsConfig")
local UIConfig = require("Config/UIConfig")
local NavigationConfig = require("Config/NavigationConfig")

local State = require("Controls/State")
local Handler = require("Controls/Handler")
local Restrictions = require("Controls/Restrictions")

local Notification = require("UI/Elements/Notification")
local InfoBox = require("UI/Elements/InfoBox")

local VehicleLoader = require("Utils/DataExtractors/VehicleLoader")
local WeaponLoader = require("Utils/DataExtractors/WeaponLoader")
local PerkLoader = require("Utils/DataExtractors/PerkLoader")

local TeleportLocations = require("Features/Teleports/TeleportLocations")
local AutoTeleport = require("Features/Teleports/AutoTeleport")
local VehiclePreview = require("Features/Vehicles/VehiclePreview")

local Utils
local Weapon
local SelfFeature
local SelfTick
local MainMenu

registerForEvent("onOverlayOpen", function() State.overlayOpen = true end)
registerForEvent("onOverlayClose", function() State.overlayOpen = false end)

local modulesLoaded = false
GameState = {}

local function GetStartingState()
    GameState = Session.GetState()
end

local function UpdateSessionStateTick()
    GameState.isLoaded = Session.IsLoaded()
    GameState.isPaused = Session.IsPaused()
    GameState.isDead = Session.IsDead()
end

local function TryLoadModules()
    if Session.IsLoaded() and not modulesLoaded then
        local ok = true

        Utils = require("Utils")
        SelfFeature = require("Features/Self")
        SelfTick = require("Features/Self/Tick")
        Weapon = require("Features/Weapons/Tick")
        MainMenu = require("View/MainMenu")

        if not (Utils and SelfFeature and SelfTick and Weapon and MainMenu) then
            ok = false
        end

        if ok then
            modulesLoaded = true
            Logger.Log("Game modules initialized.")
        end
    end
end


local function OnSessionUpdate(state)
    GameState = state
    if GameState.event == "Start" and not GameState.wasLoaded then
        TryLoadModules()
    end
end


Event.RegisterInit(function()
    Logger.Initialize()
    Logger.Log("Initialization")

    Cron.After(0.1, GetStartingState)

    Session.Listen(OnSessionUpdate)

    Cron.Every(1.0, UpdateSessionStateTick)
    Cron.Every(0.5, TryLoadModules)
    Logger.Log("Cron Started")


    local config = JsonHelper.Read("config.json")
    local lang = (config and config.Lang) or "en"
    if not Language.Load(lang) then
        Logger.Log("Language failed to load, fallback to English")
        Language.Load("en")
    else
        Logger.Log("Language loaded: " .. lang)
    end

    
    TeleportLocations.LoadAll()


    PerkLoader:LoadAll()
    WeaponLoader:LoadAll()
    VehicleLoader:LoadAll()
    Logger.Log("DataLoaded")


    BindingsConfig.Load()
    Logger.Log("Bindings loaded")

    UIConfig.Load()
    Logger.Log("UI config loaded")

    NavigationConfig.Load()
    Logger.Log("Navigation config loaded")

    OptionConfig.Load()
    Logger.Log("Option config loaded")


    Event.Observe("PlayerPuppet", "OnAction", function(_, action)
        SelfFeature.NoClip.HandleMouseLook(action)
        Utils.Weapon.HandleInputAction(action)
    end)

    Event.Observe("BaseProjectile", "ProjectileHit", function(self, eventData)
        Weapon.HandleProjectileHit(self, eventData)
    end)

    Event.Override("scannerDetailsGameController", "ShouldDisplayTwintoneTab", function(this, wrappedMethod)
        return VehicleLoader:HandleTwinToneScan(this, wrappedMethod)
    end)

end)

Event.RegisterUpdate(function(dt)
    Cron.Update(dt)
    
    if not modulesLoaded then return end
    
    if not GameState.isLoaded or GameState.isPaused or GameState.isDead then
        return
    end
    VehiclePreview.Update(dt)
    SelfTick.TickHandler()
    Weapon.TickHandler(dt)
    AutoTeleport.Tick(dt)
    Utils.Vehicle.VehicleSpawning.HandlePending()
end)

Event.RegisterDraw(function()
    if not modulesLoaded then return end

    Notification.Render()
    Handler.Update()

    if not State.menuOpen then return end

    local menuX, menuY, menuW, menuH
    ImGui.SetNextWindowSize(300, 500, ImGuiCond.FirstUseEver)

    if ImGui.Begin("EasyTrainer", ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoScrollWithMouse + ImGuiWindowFlags.NoTitleBar) then
        menuX, menuY = ImGui.GetWindowPos()
        menuW, menuH = ImGui.GetWindowSize()
        MainMenu.Render(menuX, menuY, menuW, menuH)
        ImGui.End()
    end

    InfoBox.Render(menuX, menuY, menuW, menuH)
end)

Event.RegisterShutdown(function()
    Restrictions.Clear()
    BindingsConfig.Save()
    OptionConfig.Save()
    Utils.StatModifiers.Cleanup()
    Logger.Log("Clean up")
end)
