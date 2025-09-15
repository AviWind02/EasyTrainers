local Buttons = require("UI").Buttons
local VehicleFeaures = require("Features/Vehicles")

local VehicleListView = require("View/Vehicle/VehicleListView")
local VehicleLightView = require("View/Vehicle/VehicleLightView")

local VehicleLights = VehicleFeaures.VehicleLightFade
local VehiclePreview = VehicleFeaures.VehiclePreview
local VehicleRepair = VehicleFeaures.VehicleRepair
local VehicleMount = VehicleFeaures.VehicleMountOnRoof


local function VehicleViewFunction()
    VehiclePreview.SetActive(false)
    if Buttons.Submenu(L("vehiclemenu.vehiclelist.label"), VehicleListView, L("vehiclemenu.vehiclelist.tip")) then VehicleFeaures.VehicleListStates.enableVehicleSpawnerMode = false end
    if Buttons.Submenu(L("vehiclemenu.vehiclespawner.label"), VehicleListView, L("vehiclemenu.vehiclespawner.tip")) then VehicleFeaures.VehicleListStates.enableVehicleSpawnerMode = true end
    Buttons.Submenu(L("vehiclemenu.vehicleheadlights.label"), VehicleLightView, L("vehiclemenu.vehicleheadlights.tip"))
    Buttons.Option(L("vehiclemenu.repairvehicle.label"), L("vehiclemenu.repairvehicle.tip"), VehicleRepair.RepairMounted)
    Buttons.Option(L("vehiclemenu.mountonroof.label"), L("vehiclemenu.mountonroof.tip"), VehicleMount.MountOnRoof)
    Buttons.Toggle(L("vehiclelights.rgbfade.label"), VehicleLights.toggleRGBFade, L("vehiclelights.rgbfade.tip"))

end

local VehicleView = { title = L("vehiclemenu.title"), view = VehicleViewFunction }

return VehicleView
