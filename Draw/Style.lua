local UI = {}

local function RGBA(r, g, b, a)
    return { r = r, g = g, b = b, a = a }
end


UI.Colors = {
    -- Text
    Text = 0xFFFFFFFF,
    MutedText = 0xFF788CA0,

    -- Surfaces
    Background = 0xFF080A12,
    FrameBg = 0xFF202020,

    -- Borders & UI elements
    Border = 0xFF505A6E,
    Highlight = 0xFF3A6EA5,
    ActiveHighlight = 0x5A00FFB4,
    HoverBg = 0xA01E3C5A,
    Active = 0xFFFF1493,
    Grab = 0xFF00FFFF,

    -- Utility
    Transparent = 0x00000000
}

UI.Layout = {
    Padding = 14.0,
    FrameRounding = 6.0,
    FrameHeight = 22.0,
    OptionHeight = 28.0,
    OptionPaddingX = 3.0,
    OptionPaddingY = 5.0,
    CheckboxSize = 18.0,
    SliderWidth = 100.0,
    LabelOffsetX = 8.0,

    ItemSpacing = { x = 8.0, y = 2.0 },
    FramePadding = { x = 4.0, y = 0.5 },
}

UI.Toggle = {
    OnColor = UI.Colors.Highlight,
    OffColor = RGBA(40, 40, 60, 255),
    Size = 10.0,
    Rounding = 4.0,

    FramePadding = UI.Layout.FramePadding,
    ItemSpacing = UI.Layout.ItemSpacing,
    BorderSize = 1.0,
    ToggleOffsetX = 4.0,
}

UI.Slider = {
    BgColor = UI.Colors.FrameBg,
    GrabColor = UI.Colors.Grab,
    Height = 10.0,
    Rounding = 6.0,

    FramePadding = UI.Layout.FramePadding,
    ItemSpacing = UI.Layout.ItemSpacing,
    BorderSize = 1.0,
}

UI.Input = {
    Bg = 0xFF14141C,
    Text = UI.Colors.Text,
    Placeholder = 0x789FA0A0,
    Height = 20.0,
    Rounding = UI.Layout.FrameRounding
}

UI.Header = {
    TitleBar = 0xFF14161C,
    Footer = 0xFF191926,
    Height = 40.0
}

UI.Scroll = {
    MaxVisibleOptions = 10,
    ScrollSpeed = 3.0,
}

UI.Animation = {
    SmoothSpeed = 0.12,
}

return UI
