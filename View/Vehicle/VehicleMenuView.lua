local Buttons = require("UI").Buttons
local VehicleFeaures = require("Features/Vehicles")
local Vehicle = require("Utils").Vehicle
local VehiclePreview = require("Features/Vehicles/VehiclePreview")
local VehicleListView = require("View/Vehicle/VehicleListView")


local function VehicleViewFunction()
    VehiclePreview.SetActive(false)
    if Buttons.Submenu(L("vehiclemenu.vehiclelist.label"), VehicleListView, L("vehiclemenu.vehiclelist.tip")) then VehicleFeaures.VehicleListStates.enableVehicleSpawnerMode = false end
    if Buttons.Submenu(L("vehiclemenu.vehiclespawner.label"), VehicleListView, L("vehiclemenu.vehiclespawner.tip")) then VehicleFeaures.VehicleListStates.enableVehicleSpawnerMode = true end
    Buttons.Option(L("vehiclemenu.repairvehicle.label"), L("vehiclemenu.repairvehicle.tip"), Vehicle.RepairMounted)
    Buttons.Option(L("vehiclemenu.mountonroof.label"), L("vehiclemenu.mountonroof.tip"), Vehicle.MountOnRoof)
end

local VehicleView = { title = L("vehiclemenu.title"), view = VehicleViewFunction }

return VehicleView
