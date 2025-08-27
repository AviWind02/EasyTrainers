local UI = require("UI/Core/Style")
local JsonHelper = require("Core/JsonHelper")
local Logger = require("Core/Logger")
local Notification = require("UI").Notifier
local StyleConfig = {}
local filePath = "style.json"

local function u32ToArray(c)
    local f = ImGui.ColorConvertU32ToFloat4(c)
    return { f[1], f[2], f[3], f[4] }
end

local function arrayToU32(arr)
    return ImGui.ColorConvertFloat4ToU32(arr)
end

function StyleConfig.Save()
    local data = {
        Colors = {
            Text = u32ToArray(UI.Colors.Text),
            MutedText = u32ToArray(UI.Colors.MutedText),
            Background = u32ToArray(UI.Colors.Background),
            FrameBg = u32ToArray(UI.Colors.FrameBg),
            Border = u32ToArray(UI.Colors.Border),
            Highlight = u32ToArray(UI.Colors.Highlight),
            ActiveHighlight = u32ToArray(UI.Colors.ActiveHighlight),
            HoverBg = u32ToArray(UI.Colors.HoverBg),
            Active = u32ToArray(UI.Colors.Active),
            Grab = u32ToArray(UI.Colors.Grab),
        },
        Layout = UI.Layout,
        Toggle = {
            Size = UI.Toggle.Size,
            Rounding = UI.Toggle.Rounding,
            OnColor = u32ToArray(UI.Toggle.OnColor),
            OffColor = u32ToArray(UI.Toggle.OffColor),
        },
        Slider = {
            Height = UI.Slider.Height,
            Rounding = UI.Slider.Rounding,
            BgColor = u32ToArray(UI.Slider.BgColor),
            GrabColor = u32ToArray(UI.Slider.GrabColor),
        },
        Header = UI.Header,
        Footer = UI.Footer,
        Scroll = UI.Scroll,
        Animation = UI.Animation,
        OptionRow = UI.OptionRow,
        Numeric = UI.Numeric,
        StringCycler = UI.StringCycler
    }

    local ok, err = JsonHelper.Write(filePath, data)
    if ok then
        Logger.Log("Saved style.json")
        Notification.Push("Style saved")
    else
        Logger.Log("Failed to save style.json: " .. tostring(err))
        Notification.Push("Failed to save style")
    end
end

function StyleConfig.Load()
    local data, err = JsonHelper.Read(filePath)
    if not data then
        Logger.Log("No style.json loaded: " .. tostring(err))
        return
    end

    if data.Colors then
        for k,v in pairs(data.Colors) do
            if UI.Colors[k] and type(v) == "table" then
                UI.Colors[k] = arrayToU32(v)
            end
        end
    end

    if data.Layout then for k,v in pairs(data.Layout) do UI.Layout[k] = v end end
    if data.Toggle then
        UI.Toggle.Size = data.Toggle.Size or UI.Toggle.Size
        UI.Toggle.Rounding = data.Toggle.Rounding or UI.Toggle.Rounding
        if data.Toggle.OnColor then UI.Toggle.OnColor = arrayToU32(data.Toggle.OnColor) end
        if data.Toggle.OffColor then UI.Toggle.OffColor = arrayToU32(data.Toggle.OffColor) end
    end
    if data.Slider then
        UI.Slider.Height = data.Slider.Height or UI.Slider.Height
        UI.Slider.Rounding = data.Slider.Rounding or UI.Slider.Rounding
        if data.Slider.BgColor then UI.Slider.BgColor = arrayToU32(data.Slider.BgColor) end
        if data.Slider.GrabColor then UI.Slider.GrabColor = arrayToU32(data.Slider.GrabColor) end
    end
    if data.Header then for k,v in pairs(data.Header) do UI.Header[k] = v end end
    if data.Footer then for k,v in pairs(data.Footer) do UI.Footer[k] = v end end
    if data.Scroll then for k,v in pairs(data.Scroll) do UI.Scroll[k] = v end end
    if data.Animation then for k,v in pairs(data.Animation) do UI.Animation[k] = v end end
    if data.OptionRow then for k,v in pairs(data.OptionRow) do UI.OptionRow[k] = v end end
    if data.Numeric then for k,v in pairs(data.Numeric) do UI.Numeric[k] = v end end
    if data.StringCycler then for k,v in pairs(data.StringCycler) do UI.StringCycler[k] = v end end

    Logger.Log("Loaded style.json")
    Notification.Push("Style loaded")
end

return StyleConfig
