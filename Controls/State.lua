local State = {}

State.menuOpen = true
State.mouseEnabled = false
State.overlayOpen = false
State.typingEnabled = false

State.optionIndex = 0
State.currentOption = 1
State.maxVisible = 0

State.upPressed = false
State.downPressed = false
State.leftPressed = false
State.rightPressed = false
State.selectPressed = false
State.backPressed = false
State.miscPressed = false

State.bindingKey = false

function State.IsMenuOpen()
    return State.menuOpen
end

function State.ToggleMenu()
    State.menuOpen = not State.menuOpen
    return State.menuOpen
end

function State.IsMouseEnabled()
    return State.mouseEnabled
end

function State.ToggleMouse()
    State.mouseEnabled = not State.mouseEnabled
    return State.mouseEnabled
end

return State
