local UI = {}

local function RGBA(r, g, b, a)
    return { r = r, g = g, b = b, a = a }
end




UI.ColPalette = {
    PureWhite = 0xFFFFFFFF,
    DesaturatedBlueGray = 0xFFA08C78,
    DeepBlueBlack = 0xFF120A08,
    SlightBlueGray = 0xFF221612,
    MutedSlate = 0xFF6E5A50,
    BrightNeonAqua = 0xFFB4FF00,
    TranslucentAqua = 0x5AB4FF00,
    SoftCyanHighlight = 0xA05A3C1E,
    CyberpunkPink = 0xFF9314FF,
    NeonTeal = 0xFFFFFF00,

    Transparent = 0x00000000,

    DustySteelBlue = 0xFFA08C78,
    MidnightPurple = 0xFF120A08,
    DarkCharcoal = 0xFF202020,
    GunmetalEdge = 0xFF6E5A50,
    DeepSkyAccent = 0xFFA56E3A,
    HotPinkPulse = 0xFF9314FF,

    SoftWhite = 0xFFC8C8C8,
    SoftGreen = 0xFF70C070,
    SoftYellow = 0xFF80D0D0,
    SoftRed = 0xFF8080F0,
    SoftBlue = 0xFFD0B0A0,
    SoftPurple = 0xFFD080D0,
    SoftOrange = 0xFFA0C0D0,
    SoftTeal = 0xFF80C0C0,
    SoftPink = 0xFFD0A0C0,

    MutedGrey = 0xFF5A5A5A,
    MutedCyan = 0xFF608080,
    MutedLime = 0xFF88AA88,
    MutedRose = 0xFFAA8888,

    GlowGreen = 0xFF88FF00,
    GlowBlue = 0xFFFFBB00,
    GlowPurple = 0xFFFF88B3,
    GlowYellow = 0xFF88FFFF,
    GlowRed = 0xFF6A6AFF,

    DesaturatedSlateBlue = 0xFF788CA0,
    DeepIndigoBlack = 0xFF080A12,
    SteelBorderGray = 0xFF505A6E,
    CoolSkyBlue = 0xFF3A6EA5,
    HotCyberPink = 0xFFFF1493,
    
}


UI.Colors={
    Text=UI.ColPalette.PureWhite,
    MutedText=UI.ColPalette.DesaturatedSlateBlue,

    Background=UI.ColPalette.DeepIndigoBlack,
    FrameBg=UI.ColPalette.DarkCharcoal,

    Border=UI.ColPalette.SteelBorderGray,
    Highlight=UI.ColPalette.CoolSkyBlue,
    ActiveHighlight=UI.ColPalette.TranslucentAqua,
    HoverBg=UI.ColPalette.SoftCyanHighlight,
    Active=UI.ColPalette.HotCyberPink,
    Grab=UI.ColPalette.NeonTeal,

    Transparent=UI.ColPalette.Transparent
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
    OnColor = UI.ColPalette.SoftWhite,
    OffColor = UI.ColPalette.SoftYellow,
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

-- Header style config
UI.Header = {
    Height = 40.0,
    BackgroundColor = 0xFF14161C,
    TextColor = 0xFFFFFFFF,
    FontSize = 18,
    Text = "Main Menu"
}

-- Footer style config
UI.Footer = {
    Height = 25.0,
    BackgroundColor = 0xFF191926,
    TextColor = 0xFFAAAAAA,
    FontSize = 12,
    Text = "v1.0.0 | Easy Trainers",
}

UI.Scroll = {
    MaxVisibleOptions = 10,
    ScrollSpeed = 3.0,
}

UI.Animation = {
    SmoothSpeed = 0.12,
}

return UI
