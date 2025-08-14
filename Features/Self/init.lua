local SelfFeatures = {}

SelfFeatures.GodMode = require("Features/Self/GodMode")
SelfFeatures.Invisibility = require("Features/Self/Invisibility")
SelfFeatures.SuperSpeed = require("Features/Self/SuperSpeed")
SelfFeatures.AirThrusterBoots = require("Features/Self/AirThrusterBoots")
SelfFeatures.CombatIgnore = require("Features/Self/CombatIgnore")
SelfFeatures.AdvancedMobility = require("Features/Self/AdvancedMobility")
SelfFeatures.WantedLevel = require("Features/Self/WantedLevel")
SelfFeatures.NoClip = require("Features/Self/NoClip")

SelfFeatures.StatModifiers = {
	Movement = require("Features/Self/StatModifiers/Movement"),
	Cooldown = require("Features/Self/StatModifiers/Cooldown"),
	Enhancements = require("Features/Self/StatModifiers/Enhancements"),
	Stealth = require("Features/Self/StatModifiers/Stealth"),
	Utility = require("Features/Self/StatModifiers/Utility")
}


return SelfFeatures
