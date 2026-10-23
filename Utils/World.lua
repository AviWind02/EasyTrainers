local World = {}

local OUT_OF_BOUNDS = "Out of Bounds"
local UNKNOWN_DISTRICT = "Unknown District"

function World.GetCurrentDistrictName()
    local player = Game.GetPlayer()
    local prevention = player and player:GetPreventionSystem() or nil
    local districtManager = prevention and prevention.districtManager or nil
    local district = districtManager and districtManager:GetCurrentDistrict() or nil
    if not district then return OUT_OF_BOUNDS, OUT_OF_BOUNDS end

    local record = TweakDBInterface.GetDistrictRecord(district:GetDistrictID())
    if not record then return OUT_OF_BOUNDS, OUT_OF_BOUNDS end

    local childName = Game.GetLocalizedText(record:LocalizedName()) or UNKNOWN_DISTRICT
    local parent = record:ParentDistrict()
    local parentName = parent and Game.GetLocalizedText(parent:LocalizedName()) or UNKNOWN_DISTRICT

    return parentName, childName
end

return World
