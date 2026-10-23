local Input = {}

Input.OpenPressed = false
Input.ToggleMousePressed = false
Input.UpPressed = false
Input.DownPressed = false
Input.LeftPressed = false
Input.RightPressed = false
Input.SelectPressed = false
Input.BackPressed = false

function Input.Clear()
    Input.OpenPressed = false
    Input.ToggleMousePressed = false
    Input.UpPressed = false
    Input.DownPressed = false
    Input.LeftPressed = false
    Input.RightPressed = false
    Input.SelectPressed = false
    Input.BackPressed = false
end

function Input.Apply(source)
    source = source or {}
    Input.OpenPressed = source.OpenPressed or false
    Input.ToggleMousePressed = source.ToggleMousePressed or false
    Input.UpPressed = source.UpPressed or false
    Input.DownPressed = source.DownPressed or false
    Input.LeftPressed = source.LeftPressed or false
    Input.RightPressed = source.RightPressed or false
    Input.SelectPressed = source.SelectPressed or false
    Input.BackPressed = source.BackPressed or false
end

return Input
