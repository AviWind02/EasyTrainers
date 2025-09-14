local Buttons = require("UI").Buttons
local TextInput = require("UI/Options/TextInput")
local Notification = require("UI").Notification

local JsonHelper = require("Core/JsonHelper")
local World = require("Utils/World")
local TeleportLocations = require("Features/Teleports/TeleportLocations")

local nameRef = { value = "Custom Location", capturing = false }
local creatorRef = { value = "User", capturing = false }
local categoryRef = { index = 1 }
local categories = { "Custom" }

local offsetX = { value = 0, min = -3000, max = 3000 }
local offsetY = { value = 0, min = -3000, max = 3000 }
local offsetZ = { value = 0, min = -3000, max = 3000 }

local parentDistrict, childDistrict = "Unknown District", "Unknown Area"

local function ValidateTeleport(entry)
    if not entry.name or entry.name == "" then
        Notification.Error("Please enter name for teleport")
        return false
    end
    return true
end

local function BuildCategories()
    categories = { "Custom" }
    local seen = { Custom = true }
    for _, loc in ipairs(TeleportLocations.GetAll()) do
        if not seen[loc.category] then
            table.insert(categories, loc.category)
            seen[loc.category] = true
        end
    end
end

local function SaveCustomTeleport()
    local player = Game.GetPlayer()
    if not player then return end
    local pos = player:GetWorldPosition()
    if not pos then return end

    local finalPos = {
        x = pos.x + offsetX.value,
        y = pos.y + offsetY.value,
        z = pos.z + offsetZ.value
    }

    -- get district info once, here
    local parent, child = World.GetCurrentDistrictName()

    local entry = {
        name = nameRef.value ~= "" and nameRef.value,
        position = finalPos,
        parentDistrict = parent or "Unknown District",
        childDistrict = child or "Unknown Area",
        category = categories[categoryRef.index] or "Custom",
        creator = creatorRef.value or "User"
    }

    if not ValidateTeleport(entry) then return end

    local path = "Config/JSON/Teleports.json"
    local data, _ = JsonHelper.Read(path)
    if type(data) ~= "table" then data = {} end

    table.insert(data, entry)
    JsonHelper.Write(path, data)

    Notification.Success(string.format(
        "Saved custom teleport: %s\nDistrict: %s / %s\nCoords: (%.2f, %.2f, %.2f)",
        entry.name, entry.parentDistrict, entry.childDistrict,
        finalPos.x, finalPos.y, finalPos.z
    ))
end

local basePos = nil
local function CaptureBasePosition()
    local player = Game.GetPlayer()
    if not player then return end
    basePos = player:GetWorldPosition()
    parentDistrict, childDistrict = World.GetCurrentDistrictName()
end

local initialized = false
local function CustomTeleportViewFunction() 
    if not initialized then
        BuildCategories()
        initialized = true
    end 
    -- parentDistrict, childDistrict = World.GetCurrentDistrictName()

    -- CaptureBasePosition()
    TextInput.Option("Name:", nameRef, "Enter a name for this teleport location")
    TextInput.Option("Creator:", creatorRef, "Enter the creator name (default User)")

    Buttons.StringCycler("Category", categoryRef, categories, "Select category (default Custom)")

    -- Buttons.Break("Fine Tune Position")
    -- Buttons.Int("Offset X", offsetX, "Adjust X coordinate offset")
    -- Buttons.Int("Offset Y", offsetY, "Adjust Y coordinate offset")
    -- Buttons.Int("Offset Z", offsetZ, "Adjust Z coordinate offset")

    -- Buttons.Break("District Info")
    -- Buttons.OptionExtended("Parent District", "", parentDistrict, "Current parent district")
    -- Buttons.OptionExtended("Child District", "", childDistrict, "Current child district")

    -- Buttons.Break("Debug Info") -- I feel like this would break stuff
    -- local player = Game.GetPlayer()
    -- if player then
        -- local pos = player:GetWorldPosition()
       --  if pos then
           --  Buttons.OptionExtended("X", "", string.format("%.2f", pos.x), "Raw X coordinate")
           --  Buttons.OptionExtended("Y", "", string.format("%.2f", pos.y), "Raw Y coordinate")
           --  Buttons.OptionExtended("Z", "", string.format("%.2f", pos.z), "Raw Z coordinate")
      --   end
   --  end

    if Buttons.Option("Save Current Location", "Save this teleport to teleport.json") then
        SaveCustomTeleport()
    end
end

local CustomTeleportView = { title = "Custom Teleport", view = CustomTeleportViewFunction }
return CustomTeleportView
