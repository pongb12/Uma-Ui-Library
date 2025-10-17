local UmaUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/pongb12/Uma-Ui-Library/refs/heads/main/source.lua'))()
local Plugins = loadstring(game:HttpGet('https://raw.githubusercontent.com/pongb12/Uma-Ui-Library/refs/heads/main/plugins.lua'))()
local PerfMonitor = loadstring(game:HttpGet('https://raw.githubusercontent.com/pongb12/Uma-Ui-Library/refs/heads/main/performance_monitor.lua'))()

local UI = UmaUI:CreateWindow({
    Name = "Uma UI Example v2.0.1",
    LoadingTitle = "Uma UI Library",
    LoadingSubtitle = "Enhanced Edition",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "example_config",
        FolderName = "UmaUI/Profiles"
    }
})

local MainTab = UI:Tab("Main")

MainTab:Section("Combat")

MainTab:Button("Attack", function()
    print("Attack executed!")
    UI:Notify("Combat", "Attack performed", 2)
end)

MainTab:Toggle("Auto Attack", false, function(value)
    print("Auto Attack:", value)
    _G.AutoAttack = value
end)

MainTab:Slider("Attack Speed", 1, 10, 5, function(value)
    print("Attack Speed:", value)
    _G.AttackSpeed = value
end, "x")

MainTab:Section("Movement")

MainTab:Toggle("Speed ", false, function(value)
    print("Speed :", value)
    if value then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

MainTab:Slider("Speed Multiplier", 1, 5, 1, function(value)
    print("Speed Multiplier:", value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 * value
end, "x")

MainTab:Keybind("Toggle Speed", "F", function()
    print("Speed keybind pressed")
    UI:Toggle()
end)

MainTab:Section("Player Info")

MainTab:Input("Custom Name", "", function(text)
    print("Custom name set to:", text)
    game.Players.LocalPlayer.Character.Humanoid.DisplayName = text
end, "Enter your name")

local statusLabel = MainTab:Label("Status: Ready")

task.spawn(function()
    while task.wait(2) do
        local health = game.Players.LocalPlayer.Character.Humanoid.Health
        statusLabel:Set("Status: Health " .. math.floor(health))
    end
end)

local SettingsTab = UI:Tab("Settings")

SettingsTab:Section("Appearance")

SettingsTab:Button("Dark Theme", function()
    UI:Theme("Default")
end)

SettingsTab:Button("Light Theme", function() 
    UI:Theme("Light")
end)

SettingsTab:Section("Configuration")

SettingsTab:Label("Save & Load Settings")

SettingsTab:Toggle("Auto Save", true, function(value)
    print("Auto Save:", value)
    _G.AutoSaveEnabled = value
end)

SettingsTab:Button("Save Config Now", function()
    UmaUI:SaveConfiguration()
    UI:Notify("Config", "Configuration saved", 3)
end)

SettingsTab:Button("Load Config", function()
    UmaUI:LoadConfiguration()
    UI:Notify("Config", "Configuration loaded", 3)
end)

SettingsTab:Section("Advanced")

SettingsTab:Dropdown("Game Mode", {"Easy", "Normal", "Hard", "Extreme"}, "Normal", function(option)
    print("Game mode selected:", option)
    _G.GameMode = option
end)

local UtilitiesTab = UI:Tab("Utilities")

UtilitiesTab:Section("Teleportation")

local locations = {
    {Name = "Spawn", Position = CFrame.new(0, 10, 0)},
    {Name = "Shop", Position = CFrame.new(100, 10, 0)},
    {Name = "Arena", Position = CFrame.new(-50, 10, 50)},
    {Name = "Secret Area", Position = CFrame.new(200, 100, 200)}
}

for _, location in ipairs(locations) do
    UtilitiesTab:Button("Teleport to " .. location.Name, function()
        local char = game.Players.LocalPlayer.Character
        if char and char.PrimaryPart then
            char:SetPrimaryPartCFrame(location.Position)
            UI:Notify("Teleport", "Teleported to " .. location.Name, 2)
        end
    end)
end

UtilitiesTab:Section("Notifications")

UtilitiesTab:Button("Test Notification", function()
    UI:Notify("Test", "This is a test notification!", 3)
end)

UtilitiesTab:Button("Notification with Actions", function()
    UI:Notify({
        Title = "Confirm Action",
        Content = "Do you want to continue?",
        Actions = {
            {
                Name = "Yes",
                Callback = function()
                    print("User selected Yes")
                    UI:Notify("Result", "Action confirmed", 2)
                end
            },
            {
                Name = "No",
                Callback = function()
                    print("User selected No")
                    UI:Notify("Result", "Action cancelled", 2)
                end
            }
        }
    })
end)

UmaUI:RegisterPlugin("PresetManager", Plugins.PresetManager)
UmaUI:RegisterPlugin("ColorPicker", Plugins.ColorPicker)
UmaUI:RegisterPlugin("ThemeSwitcher", Plugins.ThemeSwitcher)
UmaUI:RegisterPlugin("ConfigIO", Plugins.ConfigIO)

local PluginsTab = UI:Tab("Plugins")

local presetManager = Plugins.PresetManager.Initialize(UmaUI, PluginsTab)
local colorPicker = Plugins.ColorPicker.Initialize(UmaUI, PluginsTab)
local themeSwitcher = Plugins.ThemeSwitcher.Initialize(UmaUI, PluginsTab)
local configIO = Plugins.ConfigIO.Initialize(UmaUI, PluginsTab)

PluginsTab:Section("Plugin Info")

PluginsTab:Button("Get Current Color", function()
    if colorPicker then
        local color = colorPicker.GetCurrentColor()
        local hex = colorPicker.GetColorHex()
        print("Current color:", color, "Hex:", hex)
        UI:Notify("Color Info", "Hex: " .. hex, 3)
    end
end)

PluginsTab:Button("List All Presets", function()
    if presetManager then
        local presets = presetManager.ListPresets()
        local count = 0
        for _ in pairs(presets) do
            count = count + 1
        end
        UI:Notify("Presets", "Found " .. count .. " presets", 3)
    end
end)

PerfMonitor:Initialize(UmaUI)
PerfMonitor:CreatePerformanceTab(UI)

UI:On("ThemeChanged", function(themeName)
    print("Theme changed to:", themeName)
    UI:Notify("Theme", "Switched to " .. themeName, 2)
end)

UI:On("ConfigLoaded", function(action, filename)
    print("Configuration", action, filename or "")
    if action == "Loaded" then
        UI:Notify("Config", "Settings restored successfully", 3)
    elseif action == "Saved" then
        UI:Notify("Config", "Settings saved successfully", 2)
    end
end)

UI:On("WindowOpened", function()
    print("Window opened")
end)

UI:On("WindowClosed", function()
    print("Window closed")
end)

UI:Notify("Welcome", "Uma UI v2.0.1 loaded successfully!", 5)

task.spawn(function()
    task.wait(2)
    local perfInfo = UmaUI:GetPerformanceInfo()
    if perfInfo then
        print("Performance Info:", perfInfo)
        UI:Notify("Performance", string.format("FPS: %d | Active: %d", perfInfo.FPS, perfInfo.ActiveObjects), 3)
    end
end)

task.spawn(function()
    task.wait(5)
    print("=== Uma UI Example Loaded ===")
    print("Features demonstrated:")
    print("- All UI elements (Button, Toggle, Slider, Input, Dropdown, Label, Keybind)")
    print("- Theme switching")
    print("- Configuration save/load")
    print("- Plugins (PresetManager, ColorPicker, ThemeSwitcher, ConfigIO)")
    print("- Performance monitoring")
    print("- Event system")
    print("- Notifications")
    print("==============================")
end)

return UI
