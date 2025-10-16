
local UmaUiLibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/pongb12/Uma-Ui-Library/refs/heads/main/source.lua'))()

local Window = UmaUiLibrary:CreateWindow({
    Name = "Uma UI Example",
    LoadingTitle = "Uma UI Library",
    LoadingSubtitle = "Example Interface",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "example_config"
    }
})

local MainTab = Window:CreateTab("Main")

local SettingsTab = Window:CreateTab("Settings")

local Toggle = MainTab:CreateToggle({
    Name = "Example Toggle",
    CurrentValue = false,
    Callback = function(Value)
        print("Toggle state:", Value)
        UmaUiLibrary:Notify({
            Title = "Toggle Updated",
            Content = "Toggle is now: " .. tostring(Value),
            Duration = 3
        })
    end
})

local Button = MainTab:CreateButton({
    Name = "Test Button",
    Callback = function()
        UmaUiLibrary:Notify({
            Title = "Button Pressed",
            Content = "You clicked the test button!",
            Duration = 5
        })
    end
})

local Slider = MainTab:CreateSlider({
    Name = "Example Slider",
    Range = {0, 100},
    Increment = 5,
    Suffix = "units",
    CurrentValue = 50,
    Callback = function(Value)
        print("Slider value:", Value)
    end
})

local Label = MainTab:CreateLabel("Welcome to Uma UI Library!")

wait(2)
UmaUiLibrary:Notify({
    Title = "Welcome",
    Content = "Uma UI Library loaded successfully!",
    Duration = 5
})
