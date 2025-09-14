local UI = require("UI/Core/Style")

local ResetUI = {}

function ResetUI.ResetLayout()
    UI.Layout.Padding = 14.0
    UI.Layout.FrameRounding = 6.0
    UI.Layout.FrameHeight = 22.0
    UI.Layout.OptionHeight = 28.0
    UI.Layout.OptionPaddingX = 3.0
    UI.Layout.OptionPaddingY = 5.0
    UI.Layout.LabelOffsetX = 8.0
    UI.Layout.ItemSpacing = { x = 8.0, y = 2.0 }
    UI.Layout.FramePadding = { x = 4.0, y = 0.5 }

    UI.OptionRow.HoverBg = UI.Colors.HoverBg
    UI.OptionRow.HighlightBg = UI.Colors.Highlight
    UI.OptionRow.Text = UI.Colors.Text
    UI.OptionRow.MutedText = UI.Colors.MutedText
    UI.OptionRow.Rounding = UI.Layout.FrameRounding
    UI.OptionRow.LabelOffsetX = UI.Layout.LabelOffsetX
    UI.OptionRow.SmoothY = 0
    UI.OptionRow.SmoothSpeed = 0.25
end

function ResetUI.ResetFrame()
    UI.Header.Height = 40.0
    UI.Header.BackgroundColor = UI.Colors.Background
    UI.Header.TextColor = UI.Colors.Text
    UI.Header.FontSize = 18.0
    UI.Header.FontSizeSub = 16.0
    UI.Header.Text = "EasyTrainer"

    UI.Footer.Height = 25.0
    UI.Footer.BackgroundColor = UI.Colors.Background
    UI.Footer.TextColor = UI.ColPalette.MediumGray
    UI.Footer.FontSize = 12.0
    UI.Footer.Text = "Beta 1.0 | By Avi"
end

function ResetUI.ResetNotification()
    UI.Notification.Width = 300.0
    UI.Notification.Padding = 15.0
    UI.Notification.Spacing = 6.0
    UI.Notification.Rounding = 6.0
    UI.Notification.SlideDistance = 40.0
    UI.Notification.AnimDuration = 0.2
    UI.Notification.BackgroundColor = UI.ColPalette.DarkCharcoal
    UI.Notification.BorderColor = UI.ColPalette.SteelBorderGray
    UI.Notification.ProgressHeight = 4.0
    UI.Notification.ProgressOffsetY = -2.0
    UI.Notification.ProgressColors = {
        Default = UI.ColPalette.CoolSkyBlue,
        info = UI.ColPalette.PureWhite,
        success = UI.ColPalette.GlowGreen,
        warning = UI.ColPalette.GlowYellow,
        error = UI.ColPalette.SoftRed,
    }
    UI.Notification.TypeColors = {
        info = UI.ColPalette.PureWhite,
        success = UI.ColPalette.GlowGreen,
        warning = UI.ColPalette.GlowYellow,
        error = UI.ColPalette.SoftRed,
    }
end

function ResetUI.ResetInfoBox()
    UI.InfoBox.Padding = 14.0
    UI.InfoBox.Rounding = UI.Layout.FrameRounding
    UI.InfoBox.Spacing = 15.0
    UI.InfoBox.TextColor = UI.Colors.Text
    UI.InfoBox.BackgroundColor = UI.ColPalette.DarkCharcoal
    UI.InfoBox.BorderColor = UI.ColPalette.SteelBorderGray
    UI.InfoBox.CharsPerSecond = 175.0
    UI.InfoBox.FallbackRotateSeconds = 10.0
end

function ResetUI.ResetSimpleControls()
    UI.BreakRow.Text = UI.Colors.MutedText
    UI.BreakRow.HighlightBg = UI.ColPalette.Transparent

    UI.Dropdown.FramesPerOption = 3
    UI.Dropdown.RevealFrameDelay = 3
    UI.Dropdown.TextColor = UI.Colors.Text
    UI.Dropdown.SelectedColor = UI.ColPalette.CoolSkyBlue
    UI.Dropdown.RowPrefix = "- "

    UI.StringCycler.FramePadding = 6.0
    UI.StringCycler.TextPadding = 3.0
    UI.StringCycler.BoxRounding = UI.Layout.FrameRounding
    UI.StringCycler.FrameBg = UI.Colors.FrameBg
    UI.StringCycler.ValueColor = UI.ColPalette.CoolSkyBlue
end

function ResetUI.ResetSelectionControls()
    UI.Toggle.Size = 18.0
    UI.Toggle.Rounding = UI.Layout.FrameRounding
    UI.Toggle.Inset = 2.0
    UI.Toggle.StatePadding = 6.0
    UI.Toggle.StateSpacing = 8.0
    UI.Toggle.OnColor = UI.ColPalette.SoftWhite
    UI.Toggle.OffColor = UI.ColPalette.SoftYellow
    UI.Toggle.BorderColor = UI.Colors.Text
    UI.Toggle.FrameBg = UI.Colors.FrameBg
    UI.Toggle.TextColor = UI.Colors.Text

    UI.Radio.Radius = 6.0
    UI.Radio.LineThickness = 1.5
    UI.Radio.Segments = 20
    UI.Radio.SelectedColor = UI.Toggle.OnColor
    UI.Radio.UnselectedColor = UI.Colors.Text
end

function ResetUI.ResetInputControls()
    UI.Numeric.ToggleSize = 18.0
    UI.Numeric.ToggleSpacing = 10.0
    UI.Numeric.BoxFramePadding = 6.0
    UI.Numeric.BoxTextPadding = 3.0
    UI.Numeric.FrameBg = UI.Colors.FrameBg
    UI.Numeric.TextColor = UI.Colors.Text
    UI.Numeric.DisabledColor = UI.Colors.MutedText
    UI.Numeric.Decimals = 2
    UI.Numeric.DefaultIntStep = 1
    UI.Numeric.DefaultFloatStep = 0.1

    UI.ColorPicker.ChannelBoxSize = 24.0
    UI.ColorPicker.ChannelPadding = 6.0
    UI.ColorPicker.PreviewBoxSize = 18.0
    UI.ColorPicker.RowSpacing = 2.0
    UI.ColorPicker.FrameBg = UI.Colors.FrameBg
    UI.ColorPicker.TextColor = UI.Colors.Text
    UI.ColorPicker.BorderColor = UI.Colors.Border
    UI.ColorPicker.Rounding = UI.Layout.FrameRounding
end

function ResetUI.ResetTextInput()
    UI.TextInput.Width = 400.0
    UI.TextInput.Height = 140.0
    UI.TextInput.Padding = 14.0
    UI.TextInput.Rounding = UI.Layout.FrameRounding
    UI.TextInput.BackgroundColor = UI.ColPalette.DarkCharcoal
    UI.TextInput.BorderColor = UI.ColPalette.SteelBorderGray
    UI.TextInput.TextColor = UI.Colors.Text
    UI.TextInput.ButtonSpacing = 10.0
end

function ResetUI.ResetAll()
    ResetUI.ResetLayout()
    ResetUI.ResetFrame()
    ResetUI.ResetNotification()
    ResetUI.ResetInfoBox()
    ResetUI.ResetSimpleControls()
    ResetUI.ResetSelectionControls()
    ResetUI.ResetInputControls()
    ResetUI.ResetTextInput() 
end

return ResetUI
