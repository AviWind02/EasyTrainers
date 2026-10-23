local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local Notification = require("UI/Panels/Notification/Notification")

local POSITIONS = { "Auto", "TopLeft", "TopCenter", "TopRight", "BottomLeft", "BottomCenter", "BottomRight" }

local PREVIEWS = {
    { Label = "Information Notification", Tip = "Preview a standard notification.", Show = Notification.Info, Text = "This is an information notification." },
    { Label = "Success Notification", Tip = "Preview a success notification.", Show = Notification.Success, Text = "This is a success notification." },
    { Label = "Warning Notification", Tip = "Preview a warning notification.", Show = Notification.Warning, Text = "This is a warning notification." },
    { Label = "Error Notification", Tip = "Preview an error notification.", Show = Notification.Error, Text = "This is an error notification." }
}

local s_Position = { index = 1 }

local function NotificationView()
    Buttons.Dropdown("Notification Position", s_Position, POSITIONS, "Choose where preview notifications appear.")

    Buttons.Break("Preview")
    for _, preview in ipairs(PREVIEWS) do
        Buttons.Option(preview.Label, preview.Tip, function()
            preview.Show(preview.Text, 3, POSITIONS[s_Position.index])
        end)
    end
end

return Submenu.Create("settings.notifications.title", NotificationView)
