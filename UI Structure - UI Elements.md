# Uma UI Library - Documentation

## Table of Contents
- [UI Structure](#ui-structure)
- [UI Elements](#ui-elements)
- [Advanced Features](#advanced-features)
- [Plugin System](#plugin-system)
- [Event System](#event-system)
- [Performance Monitoring](#performance-monitoring)

---

# UI Structure

## Window Creation

### Basic Window
```lua
local UmaUI = loadstring(game:HttpGet('...'))()

local Window = UmaUI:CreateWindow({
    Name = "My Script",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Please wait",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "my_config",
        FolderName = "UmaUI/MyScript"
    },
    KeySystem = false
})
```

### Window with Key System
```lua
local Window = UmaUI:CreateWindow({
    Name = "Premium Script",
    KeySystem = true,
    KeySettings = {
        Key = {"KEY123", "KEY456"},
        FileName = "premium_key"
    }
})
```

## Window Methods

### Window:Tab()
Creates a new tab in the window.
```lua
local Tab = Window:Tab("Main", "icon_id")
```

**Parameters:**
- `Name` (string): Tab display name
- `Image` (string, optional): Asset ID for tab icon

**Returns:** Tab object

### Window:Notify()
Displays a notification.
```lua
Window:Notify("Title", "Content", 5)
```

**Parameters:**
- `Title` (string): Notification title
- `Content` (string): Notification message
- `Duration` (number, optional): Display duration in seconds
- `Image` (string, optional): Asset ID for notification icon

**Returns:** Window (chainable)

### Window:Theme()
Changes the UI theme.
```lua
Window:Theme("Light")
```

**Parameters:**
- `ThemeName` (string): "Default" or "Light" or custom theme name

**Returns:** Window (chainable)

### Window:Toggle()
Shows or hides the entire UI.
```lua
Window:Toggle()
```

**Returns:** Window (chainable)

### Window:Destroy()
Destroys the UI and cleans up resources.
```lua
Window:Destroy()
```

### Window:Use()
Initializes a plugin.
```lua
Window:Use("PluginName", options)
```

**Parameters:**
- `PluginName` (string): Registered plugin name
- `...` (any): Plugin-specific parameters

**Returns:** Window (chainable)

### Window:On()
Registers an event listener.
```lua
Window:On("ThemeChanged", function(themeName)
    print("Theme:", themeName)
end)
```

**Parameters:**
- `Event` (string): Event name without "On" prefix
- `Callback` (function): Event handler function

**Returns:** Window (chainable)

---

# UI Elements

## Tab

### Tab:Section()
Creates a new section within the tab.
```lua
local Section = Tab:Section("Section Name")
```

**Returns:** Section object (chainable)

### Direct Element Creation
Tabs can create elements directly without sections:
```lua
Tab:Button("Name", callback)
Tab:Toggle("Name", default, callback)
Tab:Slider("Name", min, max, default, callback, suffix)
Tab:Label("Text")
Tab:Input("Name", default, callback, placeholder)
Tab:Keybind("Name", default, callback, hold)
Tab:Dropdown("Name", options, default, callback)
```

---

## Button

Creates a clickable button.

### Syntax
```lua
Section:Button("Button Name", function()
    print("Button clicked")
end, "Tooltip text")
```

### Parameters
- `Name` (string): Button display text
- `Callback` (function): Function to execute on click
- `Tooltip` (string, optional): Tooltip information

### Example
```lua
Tab:Section("Actions")
    :Button("Execute", function()
        print("Executed!")
    end)
    :Button("Reset", function()
        game.Players.LocalPlayer:LoadCharacter()
    end, "Respawn player")
```

---

## Toggle

Creates an on/off switch.

### Syntax
```lua
Section:Toggle("Toggle Name", false, function(value)
    print("Toggle state:", value)
end, "Tooltip text")
```

### Parameters
- `Name` (string): Toggle display text
- `DefaultValue` (boolean): Initial state
- `Callback` (function): Function called with new state
- `Tooltip` (string, optional): Tooltip information

### Methods
```lua
Toggle:Set(true)
```

### Example
```lua
local autoFarm = Tab:Toggle("Auto Farm", false, function(value)
    _G.AutoFarm = value
    while _G.AutoFarm do
        task.wait(1)
    end
end)

task.wait(5)
autoFarm:Set(true)
```

### Flags
```lua
UmaUI.Flags["Toggle Name"]:Set(true)
UmaUI.Flags["Toggle Name"].CurrentValue
```

---

## Slider

Creates a draggable slider for numeric values.

### Syntax
```lua
Section:Slider("Slider Name", 1, 100, 50, function(value)
    print("Slider value:", value)
end, "units")
```

### Parameters
- `Name` (string): Slider display text
- `Min` (number): Minimum value
- `Max` (number): Maximum value
- `DefaultValue` (number): Initial value
- `Callback` (function): Function called with new value
- `Suffix` (string, optional): Unit suffix (e.g., "x", "%", "ms")

### Methods
```lua
Slider:Set(75)
```

### Example
```lua
local speedSlider = Tab:Slider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end, "studs/s")

speedSlider:Set(50)
```

### Flags
```lua
UmaUI.Flags["Slider Name"]:Set(50)
UmaUI.Flags["Slider Name"].CurrentValue
```

---

## Label

Creates a text label for displaying information.

### Syntax
```lua
Section:Label("Label Text")
```

### Parameters
- `Text` (string): Text to display

### Methods
```lua
Label:Set("New text")
```

### Example
```lua
local statusLabel = Tab:Label("Status: Idle")

task.spawn(function()
    while task.wait(1) do
        local health = game.Players.LocalPlayer.Character.Humanoid.Health
        statusLabel:Set("Health: " .. math.floor(health))
    end
end)
```

---

## Input

Creates a text input field.

### Syntax
```lua
Section:Input("Input Name", "default text", function(text)
    print("Input value:", text)
end, "Placeholder text")
```

### Parameters
- `Name` (string): Input display label
- `DefaultValue` (string): Initial text value
- `Callback` (function): Function called when input loses focus
- `Placeholder` (string, optional): Placeholder text when empty

### Methods
```lua
Input:Set("New text")
```

### Example
```lua
local nameInput = Tab:Input("Player Name", "", function(text)
    game.Players.LocalPlayer.Character.Humanoid.DisplayName = text
end, "Enter name...")

nameInput:Set("Custom Name")
```

### Flags
```lua
UmaUI.Flags["Input Name"]:Set("text")
UmaUI.Flags["Input Name"].CurrentValue
```

---

## Keybind

Creates a keybind selector.

### Syntax
```lua
Section:Keybind("Keybind Name", "F", function()
    print("Key pressed")
end, false)
```

### Parameters
- `Name` (string): Keybind display label
- `DefaultKey` (string): Initial key (e.g., "F", "Q", "LeftControl")
- `Callback` (function): Function called when key is pressed
- `HoldToInteract` (boolean, optional): If true, callback fires continuously while held

### Methods
```lua
Keybind:Set("G")
```

### Example
```lua
local toggleKey = Tab:Keybind("Toggle UI", "RightShift", function()
    Window:Toggle()
end)

toggleKey:Set("Insert")
```

### Flags
```lua
UmaUI.Flags["Keybind Name"]:Set("F")
UmaUI.Flags["Keybind Name"].CurrentKeybind
```

---

## Dropdown

Creates a dropdown selection menu.

### Syntax
```lua
Section:Dropdown("Dropdown Name", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selected)
    print("Selected:", selected)
end)
```

### Parameters
- `Name` (string): Dropdown display label
- `Options` (table): Array of string options
- `DefaultOption` (string): Initially selected option
- `Callback` (function): Function called with selected option

### Methods
```lua
Dropdown:Set("Option 2")
```

### Example
```lua
local weaponDropdown = Tab:Dropdown("Weapon", {"Sword", "Bow", "Staff", "Axe"}, "Sword", function(weapon)
    _G.SelectedWeapon = weapon
    print("Equipped:", weapon)
end)

weaponDropdown:Set("Bow")
```

### Flags
```lua
UmaUI.Flags["Dropdown Name"]:Set("Option 2")
UmaUI.Flags["Dropdown Name"].CurrentOption
```

---

# Advanced Features

## Configuration System

### Automatic Saving
Configuration automatically saves when:
- Toggle state changes
- Slider value changes
- Input text changes
- Keybind is set
- Dropdown option is selected

### Manual Control
```lua
UmaUI:SaveConfiguration()

UmaUI:LoadConfiguration()
```

### Export/Import
```lua
local config = UmaUI:ExportConfiguration()

UmaUI:ImportConfiguration(config)
```

### Configuration Structure
```json
{
    "Toggle Name": true,
    "Slider Name": 50,
    "Input Name": "text",
    "Keybind Name": "F",
    "Dropdown Name": "Option 1",
    "Color Picker": {
        "R": 255,
        "G": 0,
        "B": 0
    }
}
```

---

## Theme System

### Built-in Themes
- `Default` - Dark blue theme
- `Light` - Light gray theme

### Change Theme
```lua
Window:Theme("Light")
```

### Create Custom Theme
```lua
UmaUI:CreateCustomTheme("MyTheme", {
    TextFont = Enum.Font.Gotham,
    TextColor = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(25, 25, 25),
    Topbar = Color3.fromRGB(35, 35, 35),
    ElementBackground = Color3.fromRGB(40, 40, 40),
    ToggleEnabled = Color3.fromRGB(0, 200, 100),
    ToggleDisabled = Color3.fromRGB(100, 100, 100),
    SliderProgress = Color3.fromRGB(0, 150, 255)
})

Window:Theme("MyTheme")
```

---

## Accessibility Features

### Zoom Control
Users can zoom the UI with `Ctrl + Scroll Wheel`

### Programmatic Zoom
```lua
UmaUI.Accessibility.ZoomLevel = 1.5
UmaUI:ApplyZoom()
```

### Large Fonts
```lua
UmaUI.Accessibility.LargeFonts = true
UmaUI:ApplyZoom()
```

### High Contrast
```lua
UmaUI.Accessibility.HighContrast = true
```

---

## Notification System

### Simple Notification
```lua
Window:Notify("Title", "Message", 5)
```

### Advanced Notification
```lua
UmaUI:Notify({
    Title = "Confirm",
    Content = "Are you sure?",
    Duration = 10,
    Image = "123456789",
    Actions = {
        {
            Name = "Yes",
            Callback = function()
                print("Confirmed")
            end
        },
        {
            Name = "No",
            Callback = function()
                print("Cancelled")
            end
        }
    }
})
```

---

# Plugin System

## Registering Plugins

```lua
UmaUI:RegisterPlugin("PluginName", PluginModule)
```

## Creating Custom Plugins

```lua
local MyPlugin = {
    Name = "MyPlugin",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab, options)
        local section = parentTab:Section("My Plugin")
        
        section:Button("Plugin Action", function()
            print("Plugin button clicked")
        end)
        
        return {
            DoSomething = function()
                print("Custom function")
            end
        }
    end
}

UmaUI:RegisterPlugin("MyPlugin", MyPlugin)

local pluginTab = Window:Tab("Plugins")
local plugin = Window:Use("MyPlugin", pluginTab, {option = "value"})
plugin.DoSomething()
```

## Built-in Plugins

### PresetManager
Manages multiple configuration presets.

```lua
local Plugins = loadstring(game:HttpGet('...plugins.lua'))()
UmaUI:RegisterPlugin("PresetManager", Plugins.PresetManager)

local tab = Window:Tab("Presets")
local presetMgr = Plugins.PresetManager.Initialize(UmaUI, tab)

presetMgr.SavePreset("MyPreset")
presetMgr.LoadPreset("MyPreset")
presetMgr.DeletePreset("MyPreset")
local presets = presetMgr.ListPresets()
```

### ColorPicker
Color selection and management.

```lua
UmaUI:RegisterPlugin("ColorPicker", Plugins.ColorPicker)

local tab = Window:Tab("Colors")
local colorPicker = Plugins.ColorPicker.Initialize(UmaUI, tab)

local color = colorPicker.GetCurrentColor()
colorPicker.SetColor(Color3.fromRGB(255, 0, 0))
local rgb = colorPicker.GetColorRGB()
local hex = colorPicker.GetColorHex()
```

### ThemeSwitcher
Quick theme switching utility.

```lua
UmaUI:RegisterPlugin("ThemeSwitcher", Plugins.ThemeSwitcher)

local tab = Window:Tab("Themes")
local themeSwitcher = Plugins.ThemeSwitcher.Initialize(UmaUI, tab)

themeSwitcher.SetTheme("Light")
```

### ConfigIO
Import/export configurations via clipboard.

```lua
UmaUI:RegisterPlugin("ConfigIO", Plugins.ConfigIO)

local tab = Window:Tab("Config")
Plugins.ConfigIO.Initialize(UmaUI, tab)
```

---

# Event System

## Available Events

### OnThemeChanged
Fired when theme changes.
```lua
Window:On("ThemeChanged", function(themeName)
    print("Theme changed to:", themeName)
end)
```

### OnConfigLoaded
Fired when configuration is loaded or saved.
```lua
Window:On("ConfigLoaded", function(action, filename)
    print("Config", action, filename)
end)
```

### OnWindowOpened
Fired when window is created.
```lua
Window:On("WindowOpened", function(window)
    print("Window opened")
end)
```

### OnWindowClosed
Fired when window is destroyed.
```lua
Window:On("WindowClosed", function()
    print("Window closed")
end)
```

### OnElementCreated
Fired when UI elements are created.
```lua
UmaUI.Events.OnElementCreated.Event:Connect(function(elementType, data)
    print("Element created:", elementType, data)
end)
```

---

# Performance Monitoring

## Setup

```lua
local PerfMonitor = loadstring(game:HttpGet('...performance_monitor.lua'))()

PerfMonitor:Initialize(UmaUI)

PerfMonitor:CreatePerformanceTab(Window)
```

## Getting Metrics

```lua
local metrics = PerfMonitor:GetMetrics()
print("FPS:", metrics.FPS)
print("Memory:", metrics.MemoryUsage, "MB")
print("Render Time:", metrics.RenderTime, "ms")
print("Active Elements:", metrics.ElementCount)
```

## Detailed Metrics

```lua
local detailed = PerfMonitor:GetDetailedMetrics()
print(detailed.PoolStats)
```

## Configuration

```lua
PerfMonitor:SetUpdateInterval(1.0)

local fps = PerfMonitor:GetFPS()
local memory = PerfMonitor:GetMemoryUsage()

PerfMonitor:Reset()
```

## Benchmark Mode

```lua
UmaUI.Performance.BenchmarkMode = true

local perfInfo = UmaUI:GetPerformanceInfo()
print("FPS:", perfInfo.FPS)
print("Active Objects:", perfInfo.ActiveObjects)
print("Pooled Objects:", perfInfo.PooledObjects)
```

---

# Complete Example

```lua
local UmaUI = loadstring(game:HttpGet('...source.lua'))()
local Plugins = loadstring(game:HttpGet('...plugins.lua'))()
local PerfMonitor = loadstring(game:HttpGet('...performance_monitor.lua'))()

local Window = UmaUI:CreateWindow({
    Name = "Complete Example",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "complete_example"
    }
})

local MainTab = Window:Tab("Main")

MainTab:Section("Combat")
    :Button("Attack", function()
        print("Attack!")
    end)
    :Toggle("Auto Farm", false, function(v)
        _G.AutoFarm = v
    end)
    :Slider("Speed", 1, 10, 5, function(v)
        _G.Speed = v
    end, "x")

MainTab:Section("Player")
    :Input("Name", "", function(t)
        print("Name:", t)
    end, "Enter name")
    :Dropdown("Class", {"Warrior", "Mage", "Rogue"}, "Warrior", function(c)
        _G.Class = c
    end)
    :Keybind("Toggle", "F", function()
        Window:Toggle()
    end)

local statusLabel = MainTab:Label("Status: Ready")

task.spawn(function()
    while task.wait(1) do
        statusLabel:Set("Time: " .. os.time())
    end
end)

UmaUI:RegisterPlugin("PresetManager", Plugins.PresetManager)
local PluginTab = Window:Tab("Plugins")
Plugins.PresetManager.Initialize(UmaUI, PluginTab)

PerfMonitor:Initialize(UmaUI)
PerfMonitor:CreatePerformanceTab(Window)

Window:On("ThemeChanged", function(theme)
    print("Theme:", theme)
end)

Window:Notify("Ready", "UI Loaded!", 3)
```

---

# API Reference Summary

## UmaUI Library
- `CreateWindow(settings)` - Create main window
- `SaveConfiguration()` - Save current config
- `LoadConfiguration()` - Load saved config
- `ExportConfiguration()` - Get config as table
- `ImportConfiguration(data)` - Load config from table
- `Notify(settings)` - Show notification
- `ChangeTheme(name)` - Change theme
- `CreateCustomTheme(name, data)` - Create theme
- `RegisterPlugin(name, module)` - Register plugin
- `Destroy()` - Cleanup and destroy
- `GetPerformanceInfo()` - Get performance data

## Window
- `Tab(name, icon)` - Create tab
- `Notify(title, content, duration, image)` - Show notification
- `Theme(name)` - Change theme
- `Toggle()` - Show/hide UI
- `Destroy()` - Cleanup
- `Use(plugin, ...)` - Initialize plugin
- `On(event, callback)` - Register event

## Tab / Section
- `Section(name)` - Create section
- `Button(name, callback, tooltip)` - Create button
- `Toggle(name, default, callback, tooltip)` - Create toggle
- `Slider(name, min, max, default, callback, suffix)` - Create slider
- `Label(text)` - Create label
- `Input(name, default, callback, placeholder)` - Create input
- `Keybind(name, default, callback, hold)` - Create keybind
- `Dropdown(name, options, default, callback)` - Create dropdown

## Element Methods
- `Set(value)` - Update element value

## Flags
- `UmaUI.Flags[name]` - Access element by name
- `UmaUI.Flags[name]:Set(value)` - Set value
- `UmaUI.Flags[name].CurrentValue` - Get value

---

# Tips & Best Practices

## Performance
- Use flags for frequently accessed elements
- Implement proper cleanup in callbacks
- Use async operations for heavy tasks
- Enable object pooling for dynamic UIs

## Configuration
- Use meaningful flag names
- Test save/load functionality
- Handle missing config gracefully
- Version your config files

## User Experience
- Provide clear labels and tooltips
- Use appropriate element types
- Group related settings in sections
- Implement keyboard shortcuts

## Code Organization
- Separate UI creation from logic
- Use plugins for modular features
- Handle errors gracefully
- Document custom implementations
