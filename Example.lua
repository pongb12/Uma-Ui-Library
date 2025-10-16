local UmaUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/pongb12/Uma-Ui-Library/refs/heads/main/source.lua'))()

local UI = UmaUI:CreateWindow({
    Name = "Uma UI Example",
    LoadingTitle = "Uma UI Library v2.0",
    LoadingSubtitle = "Fluent API Demo",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "example_config",
        FolderName = "UmaUI/Profiles"
    },
    Theme = "Default"
})

UI:Tab("Main")
 :Section("Combat")
    :Button("Attack", function()
        print("Attack executed!")
    end, "Primary attack action")
    :Toggle("Auto Attack", false, function(value)
        print("Auto Attack:", value)
    end, "Automatically attack enemies")
    :Slider("Attack Speed", 1, 10, 5, function(value)
        print("Attack Speed:", value)
    end, "x")
 :Section("Movement") 
    :Toggle("Speed Hack", false, function(value)
        print("Speed Hack:", value)
    end)
    :Slider("Speed Multiplier", 1, 5, 1, function(value)
        print("Speed Multiplier:", value)
    end, "x")
    :Keybind("Speed Key", "F", function(key)
        print("Speed key pressed:", key)
    end, false)

UI:Tab("Settings")
 :Section("Appearance")
    :Button("Dark Theme", function()
        UI:Theme("Default")
    end)
    :Button("Light Theme", function() 
        UI:Theme("Light")
    end)
 :Section("Configuration")
    :Label("Configuration Settings")
    :Toggle("Auto Save", true, function(value)
        print("Auto Save:", value)
    end)

UI:Tab("Utilities")
 :Section("Info")
    :Label("Welcome to Uma UI Library!")
    :Button("Show Notification", function()
        UI:Notify("Hello", "This is a notification from Uma UI!", 5)
    end)

UI:On("OnThemeChanged", function(themeName)
    print("Theme changed to:", themeName)
    UI:Notify("Theme Changed", "Active theme: " .. themeName, 3)
end)

UI:On("OnConfigLoaded", function(action)
    print("Configuration", action)
    if action == "Loaded" then
        UI:Notify("Config Loaded", "Your settings have been restored", 3)
    end
end)

UI:Notify("Welcome", "Uma UI Library v2.0 loaded successfully!", 5)

local performanceInfo = UmaUI:GetPerformanceInfo()
if performanceInfo then
    task.spawn(function()
        wait(3)
        UI:Notify("Performance", string.format("FPS: %d", performanceInfo.FPS), 3)
    end)
end

UmaUI:RegisterPlugin("Teleporter", {
    Initialize = function(core, settings)
        local teleportTab = UI:Tab("Teleporter")
        teleportTab:Section("Locations")
            :Button("Spawn", function()
                if settings and settings.spawn then
                    game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(settings.spawn)
                end
            end)
            :Button("Secret Area", function()
                if settings and settings.secret then
                    game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(settings.secret)
                end
            end)
    end
})

UI:Use("Teleporter", {
    spawn = CFrame.new(0, 10, 0),
    secret = CFrame.new(100, 50, 100)
})
