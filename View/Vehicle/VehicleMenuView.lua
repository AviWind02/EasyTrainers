local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local Notification = require("UI/Panels/Notification/Notification")
local UIConfig = require("Config/UIConfig")
local VehicleLoader = require("Utils/DataExtractors/VehicleLoader")
local Vehicles = require("Features/Vehicles")
local VehicleListView = require("View/Vehicle/VehicleListView")
local VehicleLightView = require("View/Vehicle/VehicleLightView")

local Speedometer = Vehicles.VehicleSpeedometer
local Unlocking = Vehicles.VehicleUnlocking

local s_Faction = { index = 1 }
local s_Factions = nil

local function SaveColor(changed)
    if changed then UIConfig.Save() end
end

local function SpeedometerView()
    Buttons.Toggle("Show Speedometer", Speedometer.Enabled, "Show the analog gauges while driving.")
    Buttons.Toggle("Show RPM Gauge", Speedometer.ShowRPM, "Show the smaller engine RPM gauge.", UIConfig.Save)
    Buttons.Toggle("Use MPH", Speedometer.UseMPH, "Use miles per hour instead of kilometers per hour.")
    Buttons.Dropdown("Screen Position", Speedometer.Position, Speedometer.Positions, "Choose where the driving gauges appear.", UIConfig.Save)
    Buttons.Toggle("Automatic Maximum Speed", Speedometer.AutomaticMaxSpeed, "Estimate the dial range from the mounted vehicle's highest gear speed.", UIConfig.Save)

    if Speedometer.AutomaticMaxSpeed.value then
        local detected = Speedometer.DetectedMaxSpeed
        Buttons.OptionExtended("Detected Maximum", "", detected and string.format("%.0f KM/H", detected) or "Manual fallback",
            "The dial range estimated from the mounted vehicle's drivetrain.")
    else
        Buttons.Int("Maximum Speed", Speedometer.MaxSpeed, "Maximum speed shown around the analog dial.", UIConfig.Save)
    end
    Buttons.Float("Gauge Scale", Speedometer.Scale, "Adjust the overall size of both gauges.", UIConfig.Save)

    Buttons.Break("Placement Fine Tuning")
    Buttons.Int("Horizontal Offset", Speedometer.OffsetX, "Move the selected position left or right.", UIConfig.Save)
    Buttons.Int("Vertical Offset", Speedometer.OffsetY, "Move the selected position up or down.", UIConfig.Save)
    Buttons.Option("Reset Gauge Position", "Return the selected preset to its default position.", function()
        Speedometer.OffsetX.value = 0
        Speedometer.OffsetY.value = 0
        UIConfig.Save()
    end)

    Buttons.Break("Gauge Colors")
    SaveColor(Buttons.ColorHex("Active Ring", Speedometer.Colors, "Active", "Filled speed and RPM ring color."))
    SaveColor(Buttons.ColorHex("Needles", Speedometer.Colors, "Needle", "Speed and RPM needle color."))
    SaveColor(Buttons.ColorHex("Dial Text", Speedometer.Colors, "Text", "Tick and gear text color."))
    SaveColor(Buttons.ColorHex("Secondary Text", Speedometer.Colors, "Muted", "Number and unit label color."))
    SaveColor(Buttons.ColorHex("Inactive Ring", Speedometer.Colors, "Ring", "Unfilled gauge ring color."))
end

local SpeedometerMenu = Submenu.Create("Speedometer", SpeedometerView)

local function GetFactions()
    local seen = {}
    local factions = {}
    for _, vehicle in ipairs(VehicleLoader:GetAll()) do
        if vehicle.faction and not seen[vehicle.faction] then
            seen[vehicle.faction] = true
            table.insert(factions, vehicle.faction)
        end
    end
    table.sort(factions)
    return factions
end

local function SelectedFaction()
    return s_Factions[s_Faction.index or 1]
end

local function DespawnLast()
    if Vehicles.VehicleSpawning.DespawnLast() then
        Notification.Success("Last spawned vehicle removed", 2)
    else
        Notification.Info("No EasyTrainer vehicle to remove", 2)
    end
end

local function VehicleView()
    s_Factions = s_Factions or GetFactions()
    Vehicles.VehiclePreview.SetActive(false)

    Buttons.Submenu("Vehicle Spawner", VehicleListView, "Browse and spawn vehicles near the player.", function()
        Vehicles.ViewStates.SpawnerMode = true
    end)
    Buttons.Submenu("Garage Manager", VehicleListView, "Choose which vehicles appear in the player garage.", function()
        Vehicles.ViewStates.SpawnerMode = false
    end)
    Buttons.Submenu("Vehicle Light Controls", VehicleLightView, "Adjust individual vehicle lights, colors, and strength.")
    Buttons.Submenu("Speedometer", SpeedometerMenu, "Configure the analog speed and RPM gauges.")

    Buttons.Break("Mounted Vehicle")
    Buttons.Option("Repair Mounted Vehicle", "Fully repair the vehicle you are currently driving.", Vehicles.VehicleRepair.RepairMounted)
    Buttons.Option("Move to Vehicle Roof", "Unmount and place the player on top of the mounted vehicle.", Vehicles.VehicleMountOnRoof.MountOnRoof)
    Buttons.Option("Despawn Last Spawned Vehicle", "Remove the most recent vehicle spawned by EasyTrainer.", DespawnLast)
    Buttons.Float("Nitrous Boost", Vehicles.VehicleNitro.Multiplier, "Select to enable, left and right adjust the boost strength.")
    Buttons.Bind("Nitrous Key", "NITRO", "Control held to fire the nitrous boost.")
    Buttons.Toggle("RGB Light Fade", Vehicles.VehicleLightFade.Enabled, "Continuously cycle the mounted vehicle's light colors.")
    Buttons.Toggle("Freeze Vehicle Quest Timers", Vehicles.FreezeQuestTimer.Enabled, "Prevent timed vehicle objectives from counting down.")

    Buttons.Break("Fleet Management")
    Buttons.Dropdown("Selected Affiliation", s_Faction, s_Factions, "Choose the faction affected by the affiliation actions.")
    Buttons.Option("Unlock Selected Affiliation", "Unlock every vehicle for the selected affiliation.", function()
        Unlocking.UnlockFaction(SelectedFaction())
    end)
    Buttons.Option("Disable Selected Affiliation", "Remove every vehicle for the selected affiliation.", function()
        Unlocking.DisableFaction(SelectedFaction())
    end)
    Buttons.Option("Unlock Player Vehicles", "Unlock all player-assigned vehicles.", Unlocking.UnlockAllPlayerVehicles)
    Buttons.Option("Disable Player Vehicles", "Disable all player-assigned vehicles.", Unlocking.DisableAllPlayerVehicles)
    Buttons.Option("Unlock Add-On Vehicles", "Unlock all detected add-on vehicles and their variants.", Unlocking.UnlockAllModded)
    Buttons.Option("Disable Add-On Vehicles", "Disable all detected add-on vehicles and their variants.", Unlocking.DisableAllModded)
end

return Submenu.Create("Vehicles", VehicleView)
