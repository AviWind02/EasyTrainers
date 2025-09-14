local Buttons = require("UI").Buttons
local UI = require("UI/Core/Style")
local ResetUI = require("UI/Core/ResetUI")
local Notification = require("UI/Elements/Notification")


local widthRef = { value = UI.Notification.Width, min = 100, max = 800 }
local paddingRef = { value = UI.Notification.Padding, min = 0, max = 50 }
local spacingRef = { value = UI.Notification.Spacing, min = 0, max = 30 }
local roundingRef = { value = UI.Notification.Rounding, min = 0, max = 20 }
local slideDistRef = { value = UI.Notification.SlideDistance, min = 0, max = 200 }
local animDurRef = { value = UI.Notification.AnimDuration, min = 0.01, max = 2.0, step = 0.01 }
local progressHeightRef = { value = UI.Notification.ProgressHeight, min = 1, max = 20 }
local progressOffsetRef = { value = UI.Notification.ProgressOffsetY, min = -20, max = 20 }

local notifPosRef = { index = 1 }
local notifPosOptions = {
    "Auto", "TopLeft", "TopRight", "TopCenter",
    "BottomLeft", "BottomRight", "BottomCenter"
}

local function NotificationViewFunction()
    Buttons.Option("Reset Notification", "Restore Notification defaults", ResetUI.ResetNotification)

    Buttons.Break("Layout")
    if Buttons.Int("Width", widthRef, "Width of the notification window") then
        UI.Notification.Width = widthRef.value
    end
    if Buttons.Int("Padding", paddingRef, "Inner padding for notification text") then
        UI.Notification.Padding = paddingRef.value
    end
    if Buttons.Int("Spacing", spacingRef, "Spacing between stacked notifications") then
        UI.Notification.Spacing = spacingRef.value
    end
    if Buttons.Int("Rounding", roundingRef, "Corner roundness of notification box") then
        UI.Notification.Rounding = roundingRef.value
    end
    if Buttons.Int("Slide Distance", slideDistRef, "Distance notifications slide in/out") then
        UI.Notification.SlideDistance = slideDistRef.value
    end
    if Buttons.Float("Animation Duration", animDurRef, "Duration of slide animation") then
        UI.Notification.AnimDuration = animDurRef.value
    end

    Buttons.Break("Progress Bar")
    if Buttons.Int("Height", progressHeightRef, "Height of the progress bar") then
        UI.Notification.ProgressHeight = progressHeightRef.value
    end
    if Buttons.Int("Offset Y", progressOffsetRef, "Vertical offset of progress bar inside notification") then
        UI.Notification.ProgressOffsetY = progressOffsetRef.value
    end

    Buttons.Break("Colors")
    Buttons.ColorHex("Background", UI.Notification, "BackgroundColor", "Background fill of notification box")
    Buttons.ColorHex("Border", UI.Notification, "BorderColor", "Notification border color")

    Buttons.ColorHex("Progress Default", UI.Notification.ProgressColors, "Default", "Progress bar default color")
    Buttons.ColorHex("Progress Info", UI.Notification.ProgressColors, "info", "Progress bar color for info type")
    Buttons.ColorHex("Progress Success", UI.Notification.ProgressColors, "success", "Progress bar color for success type")
    Buttons.ColorHex("Progress Warning", UI.Notification.ProgressColors, "warning", "Progress bar color for warning type")
    Buttons.ColorHex("Progress Error", UI.Notification.ProgressColors, "error", "Progress bar color for error type")

    Buttons.ColorHex("Text Info", UI.Notification.TypeColors, "info", "Text color for info notifications")
    Buttons.ColorHex("Text Success", UI.Notification.TypeColors, "success", "Text color for success notifications")
    Buttons.ColorHex("Text Warning", UI.Notification.TypeColors, "warning", "Text color for warning notifications")
    Buttons.ColorHex("Text Error", UI.Notification.TypeColors, "error", "Text color for error notifications")

    Buttons.Break("Position")
    Buttons.Dropdown("Notification Position", notifPosRef, notifPosOptions, "Position where notifications will appear")
    local pos = notifPosOptions[notifPosRef.index]

    Buttons.Break("Test Notifications")
    if Buttons.Option("Send Info", "Show an info notification") then
        Notification.Info("This is a test info notification.", 3, pos)
    end
    if Buttons.Option("Send Success", "Show a success notification") then
        Notification.Success("This is a test success notification.", 3, pos)
    end
    if Buttons.Option("Send Warning", "Show a warning notification") then
        Notification.Warning("This is a test warning notification.", 3, pos)
    end
    if Buttons.Option("Send Error", "Show an error notification") then
        Notification.Error("This is a test error notification.", 3, pos)
    end
end

local NotificationView = { title = "Notifications", view = NotificationViewFunction }

return NotificationView
