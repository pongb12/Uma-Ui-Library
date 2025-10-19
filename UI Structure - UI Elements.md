# Uma UI Library v3.0.0 - Complete Documentation

## 📚 Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [UI Structure](#ui-structure)
- [UI Elements](#ui-elements)
- [Configuration System](#configuration-system)
- [Security Features](#security-features)
- [Performance System](#performance-system)
- [Plugin System](#plugin-system)
- [Event System](#event-system)
- [Mobile Support](#mobile-support)
- [Advanced Features](#advanced-features)
- [API Reference](#api-reference)
- [Examples](#examples)

---

# Installation

## Loading the Library

```lua
local UmaUI = loadstring(game:HttpGet('YOUR_URL/source.lua'))()
local Plugins = loadstring(game:HttpGet('YOUR_URL/plugins.lua'))()
local PerfMon = loadstring(game:HttpGet('YOUR_URL/performance_monitor.lua'))()
```

## Configuration

```lua
UmaUI.Configuration.ErrorTracking = true
UmaUI.Configuration.MemoryMonitoring = true
UmaUI.Configuration.PerformanceGuards = true
UmaUI.Configuration.ShowErrorNotifications = true
```

---

# Quick Start

## Basic Window

```lua
local Window = UmaUI:CreateWindow({
    Name = "My Script v3.0"
})

local MainTab = Window:Tab("Main")

MainTab:Button("Click Me", function()
    print("Button clicked!")
end)

MainTab:Toggle("Feature", false, function(enabled)
    print("Feature:", enabled)
end)

MainTab:Slider("Value", 0, 100, 50, function(value)
    print("Value:", value)
end, "%")
```

---

# UI Structure

## Window

### Creating a Window

```lua
local Window = UmaUI:CreateWindow({
    Name = "Window Title"
})
```

**Parameters:**
- `Name` (string): Window title displayed in topbar

**Returns:** Window object

### Window Properties

```lua
Window.Version = "3.0.0"
Window.SessionId = "unique-id"
Window.Device = {
    IsMobile = false,
    IsTablet = false,
    TouchEnabled = false,
    ScreenSize = Vector2.new(1920, 1080)
}
```

---

## Tabs

### Creating a Tab

```lua
local Tab = Window:Tab("Tab Name")
```

**Parameters:**
- `name` (string): Tab display name

**Returns:** Tab object

**Features:**
- Automatic navigation
- Visual selection indicator
- Scrollable content area
- Mobile optimized

### Tab Methods

```lua
Tab:Section(name)
Tab:Button(name, callback)
Tab:Toggle(name, default, callback)
Tab:Slider(name, min, max, default, callback, suffix)
Tab:Label(text)
Tab:Input(name, default, callback, placeholder)
```

---

## Sections

### Creating a Section

```lua
local Section = Tab:Section("Section Name")
```

**Purpose:** Organizes elements into logical groups

**Features:**
- Visual separator
- Group heading
- Chainable methods

### Section Methods

All section methods are chainable:

```lua
Section:Button("Name", callback)
Section:Toggle("Name", default, callback)
Section:Slider("Name", min, max, default, callback, suffix)
Section:Label("Text")
Section:Input("Name", default, callback, placeholder)
```

---

# UI Elements

## Button

Interactive clickable button.

### Syntax

```lua
Section:Button("Button Name", function()
    print("Clicked!")
end)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| name | string | Button text |
| callback | function | Click handler |

### Features

- Hover effect
- Click animation
- Mobile touch support
- Auto-sized

### Example

```lua
Tab:Section("Actions")
    :Button("Execute", function()
        print("Executing...")
    end)
    :Button("Reset", function()
        game.Players.LocalPlayer:LoadCharacter()
    end)
```

---

## Toggle

On/off switch with smooth animation.

### Syntax

```lua
Section:Toggle("Toggle Name", false, function(enabled)
    print("State:", enabled)
end)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| name | string | Toggle label |
| defaultValue | boolean | Initial state |
| callback | function | State change handler |

### Methods

```lua
Toggle:Set(true)
```

### Features

- Smooth indicator animation
- Visual state feedback
- Remembers state
- Mobile friendly

### Example

```lua
local autoFarm = Tab:Toggle("Auto Farm", false, function(enabled)
    _G.AutoFarm = enabled
    
    while _G.AutoFarm do
        task.wait(1)
    end
end)

task.wait(5)
autoFarm:Set(true)
```

---

## Slider

Draggable value selector with precision control.

### Syntax

```lua
Section:Slider("Slider Name", 1, 100, 50, function(value)
    print("Value:", value)
end, "units")
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| name | string | Slider label |
| min | number | Minimum value |
| max | number | Maximum value |
| defaultValue | number | Initial value |
| callback | function | Value change handler |
| suffix | string | Unit suffix (optional) |

### Methods

```lua
Slider:Set(75)
```

### Features

- **Smart Precision:**
  - Range < 1: 0.001 precision
  - Range < 10: 0.01 precision
  - Range ≥ 10: 0.1 precision
- Auto-swap if min > max
- Visual progress bar
- Touch and mouse support

### Example

```lua
local speedSlider = Tab:Slider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end, " studs/s")

speedSlider:Set(50)
```

---

## Label

Static or dynamic text display.

### Syntax

```lua
Section:Label("Label Text")
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| text | string | Display text |

### Methods

```lua
Label:Set("New text")
```

### Features

- Text wrapping
- Dynamic updates
- Sanitized content
- Theme-aware colors

### Example

```lua
local statusLabel = Tab:Label("Status: Idle")

task.spawn(function()
    while task.wait(1) do
        local health = game.Players.LocalPlayer.Character.Humanoid.Health
        statusLabel:Set(string.format("Health: %.0f", health))
    end
end)
```

---

## Input

Text input field with sanitization.

### Syntax

```lua
Section:Input("Input Name", "default", function(text)
    print("Input:", text)
end, "Placeholder text")
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| name | string | Input label |
| defaultValue | string | Initial value |
| callback | function | Text change handler |
| placeholder | string | Placeholder text (optional) |

### Methods

```lua
Input:Set("New text")
```

### Features

- **Auto Sanitization:**
  - Removes `< > " '` characters
  - 1000 character limit
  - XSS protection
- Focus/blur events
- Clear on focus option

### Example

```lua
local nameInput = Tab:Input("Player Name", "", function(text)
    game.Players.LocalPlayer.Character.Humanoid.DisplayName = text
end, "Enter your name...")

nameInput:Set("CustomName")
```

---

# Configuration System

## Settings

```lua
UmaUI.Configuration = {
    ErrorTracking = true,
    ShowErrorNotifications = true,
    AutoMobileDetect = true,
    TouchScrollSpeed = 2,
    MemoryMonitoring = true,
    PerformanceGuards = true
}
```

### ErrorTracking

Logs all errors to `UmaUI_Standalone/ErrorLogs/`

```lua
UmaUI.Configuration.ErrorTracking = true
```

**Features:**
- JSON formatted logs
- Severity levels (LOW, MEDIUM, HIGH, CRITICAL)
- Stack traces
- Session tracking
- Auto cleanup (keeps 50 most recent)

### MemoryMonitoring

Automatic memory management.

```lua
UmaUI.Configuration.MemoryMonitoring = true
```

**Triggers:**
- Cleanup at 300MB threshold
- Checks every 30 seconds
- Removes old pooled objects
- Clears error logs

### PerformanceGuards

Real-time performance protection.

```lua
UmaUI.Configuration.PerformanceGuards = true
```

**Monitors:**
- Memory usage
- FPS drops
- Element count
- Render time

---

# Security Features

## Input Sanitization

### SanitizeInput

```lua
local safe = UmaUI:SanitizeInput(userInput, inputType)
```

**Input Types:**

| Type | Description | Effect |
|------|-------------|--------|
| `nil` | General | Removes `< > " '`, max 1000 chars |
| `"filename"` | File names | Prevents path traversal |
| `"numeric"` | Numbers only | Removes non-digits |
| `"alphanumeric"` | Letters/numbers | Removes special chars |

### Example

```lua
local username = UmaUI:SanitizeInput(rawInput, "alphanumeric")
local filepath = UmaUI:SanitizeInput(path, "filename")
```

## Safe File Operations

### SafeWriteFile

```lua
local success, err = UmaUI:SafeWriteFile(path, content)
```

**Protection:**
- Path must start with `UmaUI_Standalone`
- 1MB file size limit
- Error handling
- Validates before writing

### Example

```lua
local success, err = UmaUI:SafeWriteFile(
    "UmaUI_Standalone/config.json",
    json
)

if not success then
    warn("Save failed:", err)
end
```

---

# Performance System

## Object Pooling

### GetFromPool

```lua
local element = UmaUI:GetFromPool("Button", function()
    return CreateNewButton()
end)
```

**Features:**
- Fallback creation
- Max 50 pooled per type
- Active count tracking
- Auto cleanup

### ReturnToPool

```lua
UmaUI:ReturnToPool("Button", element)
```

**Behavior:**
- Returns to pool if under limit
- Destroys if over limit
- Updates active count

## Memory Management

### Manual Cleanup

```lua
UmaUI:PerformCleanup()
```

**Cleans:**
- Excess pooled objects (keeps 50%)
- Old error logs (keeps 50 most recent)
- Completed tweens
- Disconnected events

### Auto Cleanup

Automatic cleanup triggers:
- Memory > 300MB
- Every 30 seconds check
- On window destroy

---

# Performance Monitoring

## Initialization

```lua
PerfMon:Initialize(UmaUI)
local PerfTab = PerfMon:CreatePerformanceTab(Window)
```

## Metrics

### GetMetrics

```lua
local metrics = PerfMon:GetMetrics()
```

**Returns:**
```lua
{
    FPS = 60,
    RenderTime = 2.5,
    AverageRenderTime = 3.2,
    MemoryUsage = 45.67,
    PeakMemory = 78.90,
    ElementCount = 25
}
```

### GetDetailedMetrics

```lua
local detailed = PerfMon:GetDetailedMetrics()
```

**Includes:**
- Pool statistics per type
- Memory trend (↑↓→)
- FPS trend
- History data

## Health Report

```lua
local report = PerfMon:GetHealthReport()
```

**Returns:**
```lua
{
    Status = "Excellent",
    Score = 95,
    Issues = {"High element count: 150"},
    Recommendations = {"Use lazy rendering"},
    Details = {
        FPS = 58,
        Memory = 123.45,
        PeakMemory = 234.56,
        RenderTime = 4.2,
        Elements = 150,
        MemoryTrend = "Stable →",
        FPSTrend = "Decreasing ↓"
    }
}
```

**Status Levels:**
- `"Excellent"` - Score 80-100
- `"Warning"` - Score 50-79
- `"Critical"` - Score 0-49

## Alert Thresholds

```lua
PerfMon.AlertThresholds = {
    CriticalMemory = 400,
    WarningMemory = 250,
    CriticalFPS = 20,
    WarningFPS = 40
}
```

---

# Plugin System

## Built-in Plugins

### DeviceInfo

Shows device information and system stats.

```lua
Plugins.DeviceInfo.Initialize(UmaUI, pluginTab)
```

**Features:**
- Device type (Mobile/Tablet/Desktop)
- Screen resolution
- Touch capability
- Real-time memory/FPS

### ConfigManager

Import/export configuration via clipboard.

```lua
Plugins.ConfigManager.Initialize(UmaUI, pluginTab)
```

**Actions:**
- Export to clipboard (JSON)
- Import from clipboard
- Reset all settings

### ErrorViewer

View and manage error logs.

```lua
Plugins.ErrorViewer.Initialize(UmaUI, pluginTab)
```

**Features:**
- Error counter
- View recent errors (last 10)
- Clear error history
- Toggle auto-report

### Shortcuts

Keyboard shortcuts for quick actions.

```lua
Plugins.Shortcuts.Initialize(UmaUI, pluginTab)
```

**Shortcuts:**
- `Ctrl + H` - Toggle UI
- `Ctrl + R` - Reset config
- `Ctrl + C` - Run cleanup

### ThemeCustomizer

Quick theme switching.

```lua
Plugins.ThemeCustomizer.Initialize(UmaUI, pluginTab)
```

**Themes:**
- Dark Mode
- Light Mode
- OLED Black

### QuickActions

One-click utility actions.

```lua
Plugins.QuickActions.Initialize(UmaUI, pluginTab)
```

**Actions:**
- 🗑️ Full Cleanup
- 📊 System Info
- 🔄 Restart UI
- 💾 Emergency Save

## Custom Plugin Development

```lua
local MyPlugin = {
    Name = "MyPlugin",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        parentTab:Section("My Plugin")
        
        parentTab:Button("Action", function()
            print("Plugin action executed")
        end)
        
        local stats = {
            calls = 0
        }
        
        return {
            GetStats = function()
                return stats
            end,
            
            DoSomething = function(arg)
                stats.calls = stats.calls + 1
                print("Custom function:", arg)
            end
        }
    end
}

return MyPlugin
```

**Usage:**
```lua
local plugin = MyPlugin.Initialize(UmaUI, pluginTab)
print(plugin.GetStats())
plugin.DoSomething("test")
```

---

# Event System

## Available Events

Events use BindableEvent internally.

### OnThemeChanged

Fired when theme changes.

```lua
UmaUI.Events.OnThemeChanged.Event:Connect(function(themeName)
    print("Theme changed to:", themeName)
end)
```

### OnElementCreated

Fired when elements are created.

```lua
UmaUI.Events.OnElementCreated.Event:Connect(function(elementType, data)
    print("Element created:", elementType)
end)
```

### OnWindowOpened

Fired when window is created.

```lua
UmaUI.Events.OnWindowOpened.Event:Connect(function(window)
    print("Window opened")
end)
```

### OnWindowClosed

Fired when window is destroyed.

```lua
UmaUI.Events.OnWindowClosed.Event:Connect(function()
    print("Window closed, cleaning up...")
end)
```

### OnConfigLoaded

Fired on config operations.

```lua
UmaUI.Events.OnConfigLoaded.Event:Connect(function(action, filename)
    print("Config", action, filename)
end)
```

---

# Mobile Support

## Device Detection

### DetectDevice

```lua
local device = UmaUI:DetectDevice()
```

**Returns:**
```lua
{
    IsMobile = false,
    IsTablet = false,
    TouchEnabled = true,
    ScreenSize = Vector2.new(1920, 1080)
}
```

**Detection Logic:**
- **Mobile:** Touch enabled + screen < 600px
- **Tablet:** Touch enabled + screen 600-1024px
- **Desktop:** Non-touch or screen > 1024px

## Mobile Features

### Touch Gestures

**Two-Finger Swipe:**
- Swipe left: Hide UI
- Swipe right: Show UI

### Adaptive UI

**Mobile (< 600px):**
- Window: 380x450
- Text: 13-14px
- Chunk size: 5 elements

**Desktop (> 1024px):**
- Window: 500x475
- Text: 13-14px
- Chunk size: 15 elements

### Setup

```lua
UmaUI:SetupMobileSupport()
```

Automatically called in `CreateWindow()`.

---

# Advanced Features

## Enhanced Error Handling

### EnhancedAsyncCallback

```lua
UmaUI:EnhancedAsyncCallback(callback, ...)
```

**Features:**
- xpcall protection
- Stack trace capture
- Severity logging
- Auto-notification on errors

### TrackError

```lua
UmaUI:TrackError(err, stack, location, severity)
```

**Severity Levels:**
```lua
local ErrorSeverity = {
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3,
    CRITICAL = 4
}
```

**Example:**
```lua
UmaUI:TrackError(
    "Connection failed",
    debug.traceback(),
    "NetworkModule",
    ErrorSeverity.HIGH
)
```

## Mutex Locks

### AcquireLock

```lua
local success = UmaUI:AcquireLock("lockName", 5)
```

**Parameters:**
- `lockName` (string): Lock identifier
- `timeout` (number): Max wait time (default: 5s)

**Returns:** true or throws error on timeout

### ReleaseLock

```lua
UmaUI:ReleaseLock("lockName")
```

**Example:**
```lua
UmaUI:AcquireLock("ConfigSave")

local success, err = pcall(function()
    writefile(path, data)
end)

UmaUI:ReleaseLock("ConfigSave")
```

## Batch Tweening

### BatchTween

```lua
local tweens = UmaUI:BatchTween(
    {frame1, frame2, frame3},
    {BackgroundTransparency = 0},
    TweenInfo.new(0.5)
)
```

**Features:**
- Single TweenInfo for all
- Cached in TweenCache
- Auto cleanup on complete
- Returns array of tweens

## Theme System

### ApplyTheme

```lua
UmaUI:ApplyTheme({
    TextFont = Enum.Font.Gotham,
    TextColor = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(20, 20, 25),
    Topbar = Color3.fromRGB(30, 30, 40),
    ElementBackground = Color3.fromRGB(30, 30, 40),
    ElementBackgroundHover = Color3.fromRGB(35, 35, 45),
    ElementStroke = Color3.fromRGB(45, 45, 55),
    SliderBackground = Color3.fromRGB(40, 100, 150),
    SliderProgress = Color3.fromRGB(40, 100, 150),
    ToggleEnabled = Color3.fromRGB(0, 140, 200),
    ToggleDisabled = Color3.fromRGB(90, 90, 100),
    InputBackground = Color3.fromRGB(25, 25, 35),
    PlaceholderColor = Color3.fromRGB(170, 170, 170),
    TabBackground = Color3.fromRGB(70, 70, 85),
    TabBackgroundSelected = Color3.fromRGB(200, 200, 220),
    TabTextColor = Color3.fromRGB(240, 240, 240),
    SelectedTabTextColor = Color3.fromRGB(40, 40, 50)
})
```

**Features:**
- Debounced changes
- Visible-only updates
- Chunked processing (5-15 per frame)
- Theme caching
- 16ms frame budget

---

# API Reference

## Core Library

### UmaUI

| Method | Description |
|--------|-------------|
| `CreateWindow(settings)` | Create main window |
| `DetectDevice()` | Get device info |
| `SetupMobileSupport()` | Enable mobile features |
| `PerformCleanup()` | Manual cleanup |
| `TrackError(err, stack, loc, sev)` | Log error |
| `SanitizeInput(input, type)` | Sanitize user input |
| `SafeWriteFile(path, content)` | Secure file write |
| `AcquireLock(name, timeout)` | Get mutex lock |
| `ReleaseLock(name)` | Release mutex lock |
| `EnhancedAsyncCallback(fn, ...)` | Protected callback |
| `Notify(settings)` | Show notification |
| `BatchTween(instances, props, info)` | Batch animations |
| `ApplyTheme(theme)` | Change theme |
| `GetVisibleElements()` | Get visible elements |
| `GetFromPool(type, createFn)` | Get pooled object |
| `ReturnToPool(type, instance)` | Return to pool |
| `Destroy()` | Cleanup everything |

### Window

| Method | Description |
|--------|-------------|
| `Tab(name)` | Create tab |
| `Notify(title, content, duration)` | Show notification |
| `Destroy()` | Destroy window |

### Tab

| Method | Description |
|--------|-------------|
| `Section(name)` | Create section |
| `Button(name, callback)` | Create button |
| `Toggle(name, default, callback)` | Create toggle |
| `Slider(name, min, max, default, callback, suffix)` | Create slider |
| `Label(text)` | Create label |
| `Input(name, default, callback, placeholder)` | Create input |

### Section

Same as Tab (chainable)

### Element Methods

| Method | Element Types | Description |
|--------|--------------|-------------|
| `Set(value)` | Toggle, Slider, Label, Input | Update value |

---

# Examples

## Complete Application

```lua
local UmaUI = loadstring(game:HttpGet('...'))()
local Plugins = loadstring(game:HttpGet('...'))()
local PerfMon = loadstring(game:HttpGet('...'))()

UmaUI.Configuration.ErrorTracking = true
UmaUI.Configuration.MemoryMonitoring = true
UmaUI.Configuration.PerformanceGuards = true

local Window = UmaUI:CreateWindow({
    Name = "Complete Example v3.0"
})

local MainTab = Window:Tab("Main")

MainTab:Section("Combat")
    :Button("Attack", function()
        print("Attacking!")
    end)
    :Toggle("Auto Farm", false, function(enabled)
        _G.AutoFarm = enabled
    end)
    :Slider("Attack Speed", 1, 10, 5, function(value)
        _G.AttackSpeed = value
    end, "x")

MainTab:Section("Movement")
    :Slider("Walk Speed", 16, 100, 16, function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end, " studs/s")

MainTab:Section("Player")
    :Input("Display Name", "", function(text)
        game.Players.LocalPlayer.Character.Humanoid.DisplayName = text
    end, "Enter name...")

local statusLabel = MainTab:Label("Status: Ready")

task.spawn(function()
    while task.wait(1) do
        local health = game.Players.LocalPlayer.Character.Humanoid.Health
        statusLabel:Set(string.format("Health: %.0f", health))
    end
end)

PerfMon:Initialize(UmaUI)
PerfMon:CreatePerformanceTab(Window)

local PluginTab = Window:Tab("Plugins")
Plugins.DeviceInfo.Initialize(UmaUI, PluginTab)
Plugins.ConfigManager.Initialize(UmaUI, PluginTab)
Plugins.ErrorViewer.Initialize(UmaUI, PluginTab)
Plugins.Shortcuts.Initialize(UmaUI, PluginTab)
Plugins.ThemeCustomizer.Initialize(UmaUI, PluginTab)
Plugins.QuickActions.Initialize(UmaUI, PluginTab)

UmaUI.Events.OnWindowClosed.Event:Connect(function()
    print("Cleaning up...")
end)

Window:Notify("Ready", "Uma UI v3.0.0 loaded!", 5)
```

## Error Handling Example

```lua
local function riskyOperation()
    UmaUI:AcquireLock("Operation", 5)
    
    local success, err = pcall(function()
        local result = someRiskyFunction()
        return result
    end)
    
    UmaUI:ReleaseLock("Operation")
    
    if not success then
        UmaUI:TrackError(
            err,
            debug.traceback(),
            "RiskyOperation",
            ErrorSeverity.HIGH
        )
    end
    
    return success
end
```

## Plugin Example

```lua
local CustomPlugin = {
    Name = "CustomPlugin",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        local state = {
            enabled = false,
            counter = 0
        }
        
        parentTab:Section("Custom Plugin")
        
        parentTab:Toggle("Enable", false, function(enabled)
            state.enabled = enabled
        end)
        
        parentTab:Button("Increment", function()
            if state.enabled then
                state.counter = state.counter + 1
                print("Counter:", state.counter)
            end
        end)
        
        return {
            GetState = function()
                return state
            end,
            Reset = function()
                state.counter = 0
            end
        }
    end
}
```

---

## 📊 Performance Tips

1. **Use Object Pooling**
   ```lua
   local button = UmaUI:GetFromPool("Button", createFunction)
   ```

2. **Enable Memory Monitoring**
   ```lua
   UmaUI.Configuration.MemoryMonitoring = true
   ```

3. **Manual Cleanup**
   ```lua
   UmaUI:PerformCleanup()
   collectgarbage("collect")
   ```

4. **Monitor Performance**
   ```lua
   local report = PerfMon:GetHealthReport()
   if report.Score < 50 then
       UmaUI:PerformCleanup()
   end
   ```

---

## 🔐 Security Best Practices

1. **Always Sanitize User Input**
   ```lua
   local safe = UmaUI:SanitizeInput(userInput, "alphanumeric")
   ```

2. **Use Safe File Operations**
   ```lua
   UmaUI:SafeWriteFile(path, content)
   ```

3. **Enable Error Tracking**
   ```lua
   UmaUI.Configuration.ErrorTracking = true
   ```

4. **Validate Before Processing**
   ```lua
   if type(value) == "number" and value >= min and value <= max then
       process(value)
   end
   ```

---

**Uma UI Library v3.0.0 - The Last Update**  
**Complete, Optimized, Production Ready** ✅
