local Button = require("UI/Widgets/Button/Button")
local Notification = require("UI/Panels/Notification/Notification")
local Input = require("Core/Input")
local Language = require("Core/Language")
local Bindings = require("Controls/Bindings")
local State = require("Controls/State")
local BindingsConfig = require("Config/BindingsConfig")

local BindButton = {}

local COUNTDOWN = 3
local TIMEOUT = 10

local s_Action = nil
local s_StartTime = nil
local s_HeldKeys = {}
local s_HeldButtons = {}
local s_WasAnyDown = false

local function Describe(list, describe)
    local parts = {}
    for _, code in ipairs(list or {}) do table.insert(parts, describe(code)) end
    return #parts > 0 and table.concat(parts, " + ") or nil
end

local function FormatBinding(binding)
    local keys = Describe(binding and binding.keys, Language.GetInputKey)
    local buttons = Describe(binding and binding.btns, Language.GetInputButton)
    if keys and buttons then return keys .. " | " .. buttons end
    return keys or buttons or L("optionmanager.none")
end

local function Stop()
    State.BindingKey = false
    s_Action = nil
    s_StartTime = nil
    s_HeldKeys = {}
    s_HeldButtons = {}
    s_WasAnyDown = false
end

local function SortedKeys(set)
    local result = {}
    for code in pairs(set) do table.insert(result, code) end
    table.sort(result)
    return result
end

local function CaptureHeld()
    for _, vk in pairs(Input.VK) do
        if Input.IsKeyDown(vk) then s_HeldKeys[vk] = true end
    end
    for _, button in pairs(Input.GP) do
        if Input.IsButtonDown(button) then s_HeldButtons[button] = true end
    end
end

local function AnyHeldDown()
    for vk in pairs(s_HeldKeys) do
        if Input.IsKeyDown(vk) then return true end
    end
    for button in pairs(s_HeldButtons) do
        if Input.IsButtonDown(button) then return true end
    end
    return false
end

local function Commit(action, label)
    if next(s_HeldKeys) then
        local keys = SortedKeys(s_HeldKeys)
        Bindings.Rebind(action, { keys = keys })
        Notification.Success("Bound " .. label .. " to " .. FormatBinding({ keys = keys }), 3)
    end

    if next(s_HeldButtons) then
        local buttons = SortedKeys(s_HeldButtons)
        Bindings.Rebind(action, { btns = buttons })
        Notification.Success("Bound " .. label .. " to " .. FormatBinding({ btns = buttons }), 3)
    end

    BindingsConfig.Save()
    Stop()
end

local function StatusText(label, elapsed)
    if elapsed < COUNTDOWN then return "Binding in: " .. tostring(math.ceil(COUNTDOWN - elapsed)) end

    local remaining = TIMEOUT - math.floor(elapsed - COUNTDOWN)
    if remaining > 0 then return "Press any key to bind (" .. remaining .. ")" end

    Notification.Warning("Key binding timed out. Restored original binding for " .. label, 3)
    Stop()
    return nil
end

local function UpdateCapture(action, label, elapsed)
    if elapsed < COUNTDOWN then return end

    if Input.IsKeyDown(Input.VK.ESCAPE) then
        Notification.Warning("Key binding cancelled. Restored original binding for " .. label, 3)
        Stop()
        return
    end

    CaptureHeld()
    local anyDown = AnyHeldDown()
    if s_WasAnyDown and not anyDown then
        Commit(action, label)
        return
    end
    s_WasAnyDown = anyDown
end

function BindButton.Option(label, action, tipText)
    local display = FormatBinding(Bindings.Actions[action])
    if s_Action == action then
        display = StatusText(label, os.clock() - s_StartTime) or FormatBinding(Bindings.Actions[action])
    end

    local clicked, data = Button.Draw(label, tipText, display, label .. "##binding##" .. action)
    if not data then return false end

    if clicked then
        Stop()
        s_Action = action
        s_StartTime = os.clock()
        State.BindingKey = true
        Notification.Info("Get ready to bind " .. label .. " in " .. COUNTDOWN .. " seconds", 2)
    end

    if s_Action == action then UpdateCapture(action, label, os.clock() - s_StartTime) end
    return clicked
end

return BindButton
