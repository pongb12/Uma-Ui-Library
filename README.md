-- Load library
local UmaLib = loadstring(game:HttpGet("link_to_uma_lib"))()

-- Create window
local Window = UmaLib:CreateWindow({
    Name = "Uma UI Example",
    Theme = "Default",
    SaveConfig = true,
    IntroEnabled = true,
    IntroText = "Welcome to Uma UI"
})

-- Create tab
local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "rbxassetid://..."
})

-- Add elements
Tab:CreateButton({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})

Tab:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(value)
        print("Toggle:", value)
    end
})

-- Notification
UmaLib:Notify({
    Title = "Success",
    Content = "Script loaded!",
    Duration = 3,
    Type = "Success"
})
