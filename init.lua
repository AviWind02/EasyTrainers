local Language = require("Core/Language")
local Logger = require("Core/Logger")
local Event = require("Core/Event")
local JsonHelper = require("Core/JsonHelper")
local Session = require("Core/cp2077-cet-kit/GameSession")
local Cron = require("Core/cp2077-cet-kit/Cron")
local OptionConfig = require("Config/OptionConfig")
local Input = require("Core/Input")
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

local WelcomeWindow = require("View/Welcome")

local Utils
local Weapon
local SelfFeature
local SelfTick
local MainMenu
local Vehicle
local AutoTeleport
local WorldWeather
local WorldTime

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
        Vehicle = require("Features/Vehicles")
        AutoTeleport = require("Features/Teleports/AutoTeleport")
        WorldWeather = require("Features/World/WorldWeather")
        WorldTime = require("Features/World/WorldTime")

        MainMenu = require("View/MainMenu")

        -- this is a very cancer statement but I guess it works?
        if not (Utils and SelfFeature and AutoTeleport and WorldWeather and WorldTime and SelfTick and Weapon and Vehicle and MainMenu) then
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

    Input.Initialize()

    Cron.After(0.1, GetStartingState)

    Session.Listen(OnSessionUpdate)

    Cron.Every(1.0, UpdateSessionStateTick)
    Cron.Every(0.5, TryLoadModules)

    Logger.Log("Cron Started")


    local config = JsonHelper.Read("Config/JSON/Settings.json")
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
        if modulesLoaded then
            SelfFeature.NoClip.HandleMouseLook(action)
            Utils.Weapon.HandleInputAction(action)
        end
    end)

    Event.Observe("BaseProjectile", "ProjectileHit", function(self, eventData)
        if modulesLoaded then
            Weapon.HandleProjectileHit(self, eventData)
        end
    end)

    Event.ObserveAfter("LocomotionAirEvents", "OnEnter", function(_, context, _)
        if modulesLoaded then
            SelfFeature.GodMode.DisableFallFX(_, context, _)
        end
    end)

    Event.ObserveAfter("MinimapContainerController", "OnCountdownTimerActiveUpdated", function(_, _)
        if modulesLoaded then
            Vehicle.FreezeQuestTimer.HandleCountdownTimer(_, _)
        end
    end)

    Event.Override("LocomotionTransition", "WantsToDodge", function(transition, stateContext, scriptInterface, wrappedFunc)
        if modulesLoaded then
            return SelfFeature.InfiniteAirDash.HandleAirDash(transition, stateContext, scriptInterface, wrappedFunc)
        end
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

    SelfTick.TickHandler()
    Weapon.TickHandler(dt)
    AutoTeleport.Tick(dt)

    Vehicle.VehicleLightFade.TickFade(dt)
    Vehicle.VehiclePreview.Update(dt)
    Vehicle.VehicleSpawning.HandlePending()
    Vehicle.VehicleNitro.Tick(dt)
    WorldWeather.Update()
    WorldTime.Update(dt)

end)

Event.RegisterDraw(function()

    Notification.Render()
    WelcomeWindow.Render()

    if not modulesLoaded then return end
    MainMenu.Initialize()
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
