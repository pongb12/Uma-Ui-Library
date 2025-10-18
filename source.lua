local UmaUiLibrary = {
    Version = "2.1.0",
    Flags = {},
    Events = {
        OnThemeChanged = Instance.new("BindableEvent"),
        OnElementCreated = Instance.new("BindableEvent"),
        OnWindowOpened = Instance.new("BindableEvent"),
        OnWindowClosed = Instance.new("BindableEvent"),
        OnConfigLoaded = Instance.new("BindableEvent")
    },
    Plugins = {},
    Performance = {
        ObjectPool = {},
        LazyRendered = {},
        BenchmarkMode = false,
        MaxPoolSize = 50
    },
    Internal = {
        EventConnections = {},
        MutexLocks = {},
        ElementData = {}
    },
    Configuration = {
        ErrorTracking = false,
        ShowErrorNotifications = true,
        AutoMobileDetect = true,
        TouchScrollSpeed = 2
    },
    Device = {
        IsMobile = false,
        IsTablet = false,
        TouchEnabled = false,
        ScreenSize = Vector2.new(0, 0)
    },
    ThemeChangeDebounce = false
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Release = "2.1.0"
local NotificationDuration = 6.5
local UmaFolder = "UmaUI"
local ConfigurationFolder = UmaFolder.."/Configurations"
local ConfigurationExtension = ".json"

local Uma = game:GetObjects("rbxassetid://10804731440")[1]
Uma.Enabled = false

if gethui then
    Uma.Parent = gethui()
elseif syn and syn.protect_gui then 
    syn.protect_gui(Uma)
    Uma.Parent = CoreGui
elseif CoreGui:FindFirstChild("RobloxGui") then
    Uma.Parent = CoreGui:FindFirstChild("RobloxGui")
else
    Uma.Parent = CoreGui
end

local function RemoveOldInstances()
    local parent = gethui and gethui() or CoreGui
    for _, Interface in ipairs(parent:GetChildren()) do
        if Interface.Name == Uma.Name and Interface ~= Uma then
            Interface.Enabled = false
            Interface.Name = "UmaUI-Old"
            task.delay(1, function()
                pcall(function() Interface:Destroy() end)
            end)
        end
    end
end

RemoveOldInstances()

local Camera = workspace.CurrentCamera
local Main = Uma.Main
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList

Uma.DisplayOrder = 100
LoadingFrame.Version.Text = Release

local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local Notifications = Uma.Notifications

local Themes = {
    Default = {
        TextFont = Enum.Font.Gotham,
        TextColor = Color3.fromRGB(240, 240, 240),
        Background = Color3.fromRGB(20, 20, 25),
        Topbar = Color3.fromRGB(30, 30, 40),
        Shadow = Color3.fromRGB(15, 15, 20),
        NotificationBackground = Color3.fromRGB(15, 15, 20),
        NotificationActionsBackground = Color3.fromRGB(220, 220, 220),
        TabBackground = Color3.fromRGB(70, 70, 85),
        TabStroke = Color3.fromRGB(75, 75, 90),
        TabBackgroundSelected = Color3.fromRGB(200, 200, 220),
        TabTextColor = Color3.fromRGB(240, 240, 240),
        SelectedTabTextColor = Color3.fromRGB(40, 40, 50),
        ElementBackground = Color3.fromRGB(30, 30, 40),
        ElementBackgroundHover = Color3.fromRGB(35, 35, 45),
        SecondaryElementBackground = Color3.fromRGB(20, 20, 25),
        ElementStroke = Color3.fromRGB(45, 45, 55),
        SecondaryElementStroke = Color3.fromRGB(35, 35, 45),
        SliderBackground = Color3.fromRGB(40, 100, 150),
        SliderProgress = Color3.fromRGB(40, 100, 150),
        SliderStroke = Color3.fromRGB(45, 110, 165),
        ToggleBackground = Color3.fromRGB(25, 25, 35),
        ToggleEnabled = Color3.fromRGB(0, 140, 200),
        ToggleDisabled = Color3.fromRGB(90, 90, 100),
        ToggleEnabledStroke = Color3.fromRGB(0, 160, 240),
        ToggleDisabledStroke = Color3.fromRGB(115, 115, 125),
        ToggleEnabledOuterStroke = Color3.fromRGB(90, 90, 100),
        ToggleDisabledOuterStroke = Color3.fromRGB(60, 60, 70),
        InputBackground = Color3.fromRGB(25, 25, 35),
        InputStroke = Color3.fromRGB(60, 60, 70),
        PlaceholderColor = Color3.fromRGB(170, 170, 170),
        DropdownSelected = Color3.fromRGB(40, 40, 50),
        DropdownUnselected = Color3.fromRGB(30, 30, 40)
    },
    Light = {
        TextFont = Enum.Font.Gotham,
        TextColor = Color3.fromRGB(50, 50, 50),
        Background = Color3.fromRGB(245, 245, 245),
        Topbar = Color3.fromRGB(230, 230, 230),
        Shadow = Color3.fromRGB(220, 220, 220),
        NotificationBackground = Color3.fromRGB(240, 240, 240),
        NotificationActionsBackground = Color3.fromRGB(200, 200, 200),
        TabBackground = Color3.fromRGB(200, 200, 200),
        TabStroke = Color3.fromRGB(180, 180, 180),
        TabBackgroundSelected = Color3.fromRGB(100, 150, 255),
        TabTextColor = Color3.fromRGB(80, 80, 80),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(255, 255, 255),
        ElementBackgroundHover = Color3.fromRGB(245, 245, 245),
        SecondaryElementBackground = Color3.fromRGB(240, 240, 240),
        ElementStroke = Color3.fromRGB(220, 220, 220),
        SecondaryElementStroke = Color3.fromRGB(210, 210, 210),
        SliderBackground = Color3.fromRGB(200, 200, 200),
        SliderProgress = Color3.fromRGB(65, 150, 255),
        SliderStroke = Color3.fromRGB(180, 180, 180),
        ToggleBackground = Color3.fromRGB(230, 230, 230),
        ToggleEnabled = Color3.fromRGB(65, 150, 255),
        ToggleDisabled = Color3.fromRGB(180, 180, 180),
        ToggleEnabledStroke = Color3.fromRGB(45, 130, 235),
        ToggleDisabledStroke = Color3.fromRGB(150, 150, 150),
        ToggleEnabledOuterStroke = Color3.fromRGB(180, 180, 180),
        ToggleDisabledOuterStroke = Color3.fromRGB(140, 140, 140),
        InputBackground = Color3.fromRGB(255, 255, 255),
        InputStroke = Color3.fromRGB(220, 220, 220),
        PlaceholderColor = Color3.fromRGB(150, 150, 150),
        DropdownSelected = Color3.fromRGB(240, 240, 240),
        DropdownUnselected = Color3.fromRGB(255, 255, 255)
    }
}

local CurrentTheme = Themes.Default
local Accessibility = {
    HighContrast = false,
    LargeFonts = false,
    ZoomLevel = 1
}

function UmaUiLibrary:DetectDevice()
    local screenSize = Camera.ViewportSize
    self.Device.ScreenSize = screenSize
    self.Device.TouchEnabled = UserInputService.TouchEnabled
    
    if UserInputService.TouchEnabled then
        if screenSize.X < 600 or screenSize.Y < 600 then
            self.Device.IsMobile = true
            self.Device.IsTablet = false
        elseif screenSize.X < 1024 or screenSize.Y < 768 then
            self.Device.IsMobile = false
            self.Device.IsTablet = true
        else
            self.Device.IsMobile = false
            self.Device.IsTablet = false
        end
    else
        self.Device.IsMobile = false
        self.Device.IsTablet = false
    end
    
    return self.Device
end

function UmaUiLibrary:SetupMobileSupport()
    if not self.Device.TouchEnabled then return end
    
    local touchConnection = UserInputService.TouchTap:Connect(function(touchPositions, gameProcessedEvent)
        if gameProcessedEvent then return end
    end)
    
    local swipeConnection = UserInputService.TouchSwipe:Connect(function(swipeDirection, numberOfTouches, gameProcessedEvent)
        if gameProcessedEvent then return end
        
        if swipeDirection == Enum.SwipeDirection.Left and numberOfTouches == 2 then
            Main.Visible = false
        elseif swipeDirection == Enum.SwipeDirection.Right and numberOfTouches == 2 then
            Main.Visible = true
        end
    end)
    
    table.insert(self.Internal.EventConnections, touchConnection)
    table.insert(self.Internal.EventConnections, swipeConnection)
    
    if self.Device.IsMobile then
        if Main then
            Main.Size = UDim2.new(0, 380, 0, 450)
        end
        
        if Elements.UIPageLayout then
            Elements.UIPageLayout.ScrollWheelInputEnabled = true
        end
    end
end

function UmaUiLibrary:AcquireLock(lockName)
    while self.Internal.MutexLocks[lockName] do
        task.wait(0.01)
    end
    self.Internal.MutexLocks[lockName] = true
end

function UmaUiLibrary:ReleaseLock(lockName)
    self.Internal.MutexLocks[lockName] = nil
end

function UmaUiLibrary:InitializeObjectPool()
    for _, elementType in pairs({"Button", "Toggle", "Slider", "Label", "Dropdown", "Input", "Keybind"}) do
        self.Performance.ObjectPool[elementType] = {
            Active = {},
            Inactive = {},
            ActiveCount = 0
        }
    end
end

function UmaUiLibrary:GetFromPool(elementType)
    local pool = self.Performance.ObjectPool[elementType]
    if pool and #pool.Inactive > 0 then
        local instance = table.remove(pool.Inactive)
        pool.Active[instance] = true
        pool.ActiveCount = pool.ActiveCount + 1
        return instance
    end
    return nil
end

function UmaUiLibrary:ReturnToPool(elementType, instance)
    local pool = self.Performance.ObjectPool[elementType]
    if pool then
        pool.Active[instance] = nil
        pool.ActiveCount = math.max(0, pool.ActiveCount - 1)
        
        if #pool.Inactive < self.Performance.MaxPoolSize then
            table.insert(pool.Inactive, instance)
        else
            pcall(function() instance:Destroy() end)
        end
    end
end

function UmaUiLibrary:EnhancedAsyncCallback(callback, ...)
    local args = {...}
    local callbackName = debug.info(callback, "n") or "Anonymous"
    
    task.spawn(function()
        local success, result = xpcall(function()
            return callback(table.unpack(args))
        end, function(err)
            local stack = debug.traceback()
            warn(string.format("🚨 UmaUI Error in %s:\n%s\n%s", callbackName, err, stack))
            
            if self.Configuration.ErrorTracking then
                self:TrackError(err, stack, callbackName)
            end
            
            return err
        end)
        
        if not success and self.Configuration.ShowErrorNotifications then
            self:Notify({
                Title = "Script Error",
                Content = "An error occurred: " .. tostring(result),
                Duration = 5
            })
        end
    end)
end

function UmaUiLibrary:AsyncCallback(callback, ...)
    self:EnhancedAsyncCallback(callback, ...)
end

function UmaUiLibrary:TrackError(err, stack, location)
    local errorLog = {
        Error = err,
        Stack = stack,
        Location = location,
        Timestamp = os.time(),
        Version = self.Version
    }
    
    if not isfolder(UmaFolder .. "/ErrorLogs") then
        makefolder(UmaFolder .. "/ErrorLogs")
    end
    
    local filename = string.format("%s/ErrorLogs/error_%d.json", UmaFolder, os.time())
    pcall(function()
        writefile(filename, HttpService:JSONEncode(errorLog))
    end)
end

function UmaUiLibrary:RegisterPlugin(name, pluginModule)
    self.Plugins[name] = pluginModule
    self.Events.OnElementCreated:Fire("PluginRegistered", name)
end

function UmaUiLibrary:SetupAccessibility()
    local connection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local ctrlPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
                              UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            
            if ctrlPressed then
                Accessibility.ZoomLevel = math.clamp(
                    Accessibility.ZoomLevel + (input.Position.Z > 0 and 0.1 or -0.1),
                    0.5, 2.0
                )
                self:ApplyZoom()
            end
        end
    end)
    table.insert(self.Internal.EventConnections, connection)
end

function UmaUiLibrary:ApplyZoom()
    local elements = self:GetAllElements()
    for _, element in pairs(elements) do
        if element and element:FindFirstChild("Title") then
            local baseSize = Accessibility.LargeFonts and 16 or 14
            element.Title.TextSize = baseSize * Accessibility.ZoomLevel
        end
    end
end

function UmaUiLibrary:GetAllElements()
    local elements = {}
    for _, pool in pairs(self.Performance.ObjectPool) do
        if pool and type(pool) == "table" and pool.Active then
            for element in pairs(pool.Active) do
                table.insert(elements, element)
            end
        end
    end
    return elements
end

function UmaUiLibrary:ChangeTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        self:ApplyTheme(CurrentTheme)
        self.Events.OnThemeChanged:Fire(themeName)
    else
        warn("Theme '" .. tostring(themeName) .. "' not found")
    end
end

function UmaUiLibrary:ApplyTheme(theme)
    if self.ThemeChangeDebounce then return end
    self.ThemeChangeDebounce = true
    
    if Main then
        Main.BackgroundColor3 = theme.Background
        Topbar.BackgroundColor3 = theme.Topbar
    end
    
    task.spawn(function()
        local elements = self:GetAllElements()
        local chunkSize = 10
        
        for i = 1, #elements, chunkSize do
            task.wait(0.01)
            local endIdx = math.min(i + chunkSize - 1, #elements)
            
            for j = i, endIdx do
                if elements[j] then
                    self:UpdateElementTheme(elements[j], theme)
                end
            end
        end
        
        task.wait(0.1)
        self.ThemeChangeDebounce = false
    end)
end

function UmaUiLibrary:UpdateElementTheme(element, theme)
    if not element or not element.Parent then return end
    
    local elementType = element:GetAttribute("ElementType") or "Unknown"
    
    pcall(function()
        if element:FindFirstChild("Title") then
            element.Title.TextColor3 = theme.TextColor
            element.Title.Font = theme.TextFont
            element.Title.TextSize = (Accessibility.LargeFonts and 16 or 14) * Accessibility.ZoomLevel
        end
        
        if elementType == "Button" then
            element.BackgroundColor3 = theme.ElementBackground
            if element:FindFirstChild("Interact") then
                element.Interact.BackgroundColor3 = theme.ElementBackgroundHover
            end
            
        elseif elementType == "Toggle" then
            element.BackgroundColor3 = theme.ElementBackground
            if element:FindFirstChild("Switch") then
                element.Switch.BackgroundColor3 = theme.ToggleBackground
                local indicator = element.Switch:FindFirstChild("Indicator")
                if indicator then
                    local isEnabled = indicator.Position.X.Offset > -30
                    indicator.BackgroundColor3 = isEnabled and theme.ToggleEnabled or theme.ToggleDisabled
                end
            end
            
        elseif elementType == "Slider" then
            if element:FindFirstChild("Main") then
                element.Main.BackgroundColor3 = theme.SliderBackground
                if element.Main:FindFirstChild("Progress") then
                    element.Main.Progress.BackgroundColor3 = theme.SliderProgress
                end
                if element.Main:FindFirstChild("Information") then
                    element.Main.Information.TextColor3 = theme.TextColor
                end
            end
            
        elseif elementType == "Input" then
            if element:FindFirstChild("InputFrame") then
                element.InputFrame.BackgroundColor3 = theme.InputBackground
                if element.InputFrame:FindFirstChild("InputBox") then
                    element.InputFrame.InputBox.TextColor3 = theme.TextColor
                    element.InputFrame.InputBox.PlaceholderColor3 = theme.PlaceholderColor
                end
            end
            
        elseif elementType == "Dropdown" then
            element.BackgroundColor3 = theme.ElementBackground
            if element:FindFirstChild("DropdownFrame") then
                element.DropdownFrame.BackgroundColor3 = theme.InputBackground
                if element.DropdownFrame:FindFirstChild("SelectedOption") then
                    element.DropdownFrame.SelectedOption.TextColor3 = theme.TextColor
                    element.DropdownFrame.SelectedOption.BackgroundColor3 = theme.ElementBackground
                end
            end
            
        elseif elementType == "Keybind" then
            if element:FindFirstChild("KeybindFrame") then
                element.KeybindFrame.BackgroundColor3 = theme.InputBackground
                if element.KeybindFrame:FindFirstChild("KeybindBox") then
                    element.KeybindFrame.KeybindBox.TextColor3 = theme.TextColor
                end
            end
        end
        
        if element:FindFirstChild("UIStroke") then
            element.UIStroke.Color = theme.ElementStroke
        end
    end)
end

function UmaUiLibrary:CreateCustomTheme(name, themeData)
    Themes[name] = themeData
    return true
end

function UmaUiLibrary:ValidateConfigValue(valueType, value, min, max)
    if valueType == "boolean" then
        return type(value) == "boolean" and value or false
    elseif valueType == "number" then
        if type(value) ~= "number" then return min or 0 end
        if min and max then
            return math.clamp(value, min, max)
        end
        return value
    elseif valueType == "string" then
        if type(value) ~= "string" then return "" end
        return value:sub(1, 1000)
    elseif valueType == "Color3" then
        if type(value) == "table" and value.R and value.G and value.B then
            local r = math.clamp(tonumber(value.R) or 255, 0, 255)
            local g = math.clamp(tonumber(value.G) or 255, 0, 255)
            local b = math.clamp(tonumber(value.B) or 255, 0, 255)
            return {R = r, G = g, B = b}
        end
    end
    return value
end

function UmaUiLibrary:MigrateConfig(oldData, oldVersion)
    if oldVersion == "2.0.2" then
        local migrated = {
            Version = self.Version,
            Timestamp = os.time(),
            Flags = {}
        }
        
        for flag, value in pairs(oldData) do
            if type(value) == "table" and value.Value then
                migrated.Flags[flag] = value
            else
                migrated.Flags[flag] = {
                    Type = "Unknown",
                    Value = value,
                    Timestamp = os.time()
                }
            end
        end
        
        return migrated
    end
    return oldData
end

function UmaUiLibrary:SaveConfiguration()
    if not CEnabled then return end
    
    self:AcquireLock("ConfigSave")
    
    local success, err = pcall(function()
        local data = {
            Version = self.Version,
            Timestamp = os.time(),
            Device = {
                IsMobile = self.Device.IsMobile,
                IsTablet = self.Device.IsTablet
            },
            Flags = {}
        }
        
        for flag, element in pairs(self.Flags) do
            if element.Type == "ColorPicker" then
                data.Flags[flag] = {
                    Type = "ColorPicker",
                    Value = {
                        R = element.Color.R * 255,
                        G = element.Color.G * 255,
                        B = element.Color.B * 255
                    },
                    Timestamp = os.time()
                }
            elseif element.Type == "Slider" then
                data.Flags[flag] = {
                    Type = "Slider",
                    Value = self:ValidateConfigValue("number", element.CurrentValue, element.Range[1], element.Range[2]),
                    Range = element.Range,
                    Timestamp = os.time()
                }
            elseif element.Type == "Toggle" then
                data.Flags[flag] = {
                    Type = "Toggle",
                    Value = self:ValidateConfigValue("boolean", element.CurrentValue),
                    Timestamp = os.time()
                }
            else
                data.Flags[flag] = {
                    Type = element.Type,
                    Value = self:ValidateConfigValue("string", element.CurrentValue or element.CurrentKeybind or element.CurrentOption),
                    Timestamp = os.time()
                }
            end
        end
        
        local json = HttpService:JSONEncode(data)
        local filePath = ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension
        writefile(filePath, json)
        
        self.Events.OnConfigLoaded:Fire("Saved", CFileName)
    end)
    
    self:ReleaseLock("ConfigSave")
    
    if not success then
        warn("Failed to save configuration:", err)
    end
end

function UmaUiLibrary:LoadConfiguration()
    if not CEnabled then return end
    
    local success, data = pcall(function()
        local filePath = ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension
        if not isfile(filePath) then
            return nil
        end
        
        local json = readfile(filePath)
        local decoded = HttpService:JSONDecode(json)
        
        if type(decoded) ~= "table" then
            warn("Invalid config format")
            return nil
        end
        
        if decoded.Version and decoded.Version ~= self.Version then
            decoded = self:MigrateConfig(decoded.Flags or decoded, decoded.Version)
        end
        
        return decoded
    end)
    
    if success and data then
        local flags = data.Flags or data
        
        for flagName, flagData in pairs(flags) do
            if self.Flags[flagName] then
                local element = self.Flags[flagName]
                pcall(function()
                    local value = type(flagData) == "table" and flagData.Value or flagData
                    
                    if element.Type == "ColorPicker" then
                        local validated = self:ValidateConfigValue("Color3", value)
                        element:Set(Color3.fromRGB(validated.R, validated.G, validated.B))
                    elseif element.Type == "Slider" then
                        local validated = self:ValidateConfigValue("number", value, element.Range[1], element.Range[2])
                        element:Set(validated)
                    elseif element.Type == "Toggle" then
                        local validated = self:ValidateConfigValue("boolean", value)
                        element:Set(validated)
                    else
                        local validated = self:ValidateConfigValue("string", value)
                        element:Set(validated)
                    end
                end)
            end
        end
        self.Events.OnConfigLoaded:Fire("Loaded", CFileName)
    else
        warn("Failed to load configuration")
    end
end

function UmaUiLibrary:ExportConfiguration()
    local data = {
        Version = self.Version,
        Timestamp = os.time(),
        Flags = {}
    }
    
    for flag, element in pairs(self.Flags) do
        if element.Type == "ColorPicker" then
            data.Flags[flag] = {
                Type = "ColorPicker",
                Value = {
                    R = element.Color.R * 255,
                    G = element.Color.G * 255,
                    B = element.Color.B * 255
                }
            }
        else
            data.Flags[flag] = {
                Type = element.Type,
                Value = element.CurrentValue or element.CurrentKeybind or element.CurrentOption
            }
        end
    end
    return data
end

function UmaUiLibrary:ImportConfiguration(data)
    if type(data) ~= "table" then
        warn("Invalid configuration data")
        return
    end
    
    local flags = data.Flags or data
    
    for flagName, flagData in pairs(flags) do
        if self.Flags[flagName] then
            local element = self.Flags[flagName]
            pcall(function()
                local value = type(flagData) == "table" and flagData.Value or flagData
                
                if element.Type == "ColorPicker" then
                    local validated = self:ValidateConfigValue("Color3", value)
                    element:Set(Color3.fromRGB(validated.R, validated.G, validated.B))
                else
                    element:Set(value)
                end
            end)
        end
    end
end

function UmaUiLibrary:ShowColorPicker(callback)
    local colorPicker = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local hueSlider = Instance.new("Frame")
    local satBright = Instance.new("Frame")
    local preview = Instance.new("Frame")
    local rgbInput = Instance.new("TextBox")
    local hexInput = Instance.new("TextBox")
    local confirm = Instance.new("TextButton")
    local cancel = Instance.new("TextButton")
    
    colorPicker.Name = "ColorPicker"
    colorPicker.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frameWidth = self.Device.IsMobile and 280 or 320
    local frameHeight = self.Device.IsMobile and 420 or 460
    
    frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
    frame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
    frame.BackgroundColor3 = CurrentTheme.Background
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Color Picker"
    title.TextColor3 = CurrentTheme.TextColor
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    satBright.Size = UDim2.new(0.9, 0, 0, 180)
    satBright.Position = UDim2.new(0.05, 0, 0, 50)
    satBright.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
    satBright.BorderSizePixel = 0
    satBright.Parent = frame
    
    local satGradient = Instance.new("UIGradient")
    satGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    satGradient.Parent = satBright
    
    local brightGradient = Instance.new("UIGradient")
    brightGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    brightGradient.Rotation = 90
    brightGradient.Parent = satBright
    
    hueSlider.Size = UDim2.new(0.9, 0, 0, 20)
    hueSlider.Position = UDim2.new(0.05, 0, 0, 240)
    hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueSlider.BorderSizePixel = 0
    hueSlider.Parent = frame
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Parent = hueSlider
    
    preview.Size = UDim2.new(0, 60, 0, 60)
    preview.Position = UDim2.new(0.5, -30, 0, 270)
    preview.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    preview.BorderSizePixel = 0
    preview.Parent = frame
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 8)
    previewCorner.Parent = preview
    
    rgbInput.Size = UDim2.new(0.8, 0, 0, 25)
    rgbInput.Position = UDim2.new(0.1, 0, 0, 340)
    rgbInput.PlaceholderText = "RGB: 255,255,255"
    rgbInput.Text = ""
    rgbInput.TextColor3 = CurrentTheme.TextColor
    rgbInput.BackgroundColor3 = CurrentTheme.InputBackground
    rgbInput.Font = Enum.Font.Gotham
    rgbInput.TextSize = 12
    rgbInput.Parent = frame
    
    hexInput.Size = UDim2.new(0.8, 0, 0, 25)
    hexInput.Position = UDim2.new(0.1, 0, 0, 370)
    hexInput.PlaceholderText = "Hex: #FFFFFF"
    hexInput.Text = ""
    hexInput.TextColor3 = CurrentTheme.TextColor
    hexInput.BackgroundColor3 = CurrentTheme.InputBackground
    hexInput.Font = Enum.Font.Gotham
    hexInput.TextSize = 12
    hexInput.Parent = frame
    
    confirm.Size = UDim2.new(0, 120, 0, 35)
    confirm.Position = UDim2.new(0.05, 0, 0, frameHeight - 45)
    confirm.BackgroundColor3 = CurrentTheme.ToggleEnabled
    confirm.Text = "Confirm"
    confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirm.TextSize = 14
    confirm.Font = Enum.Font.Gotham
    confirm.Parent = frame
    
    cancel.Size = UDim2.new(0, 120, 0, 35)
    cancel.Position = UDim2.new(0.55, 0, 0, frameHeight - 45)
    cancel.BackgroundColor3 = CurrentTheme.ElementStroke
    cancel.Text = "Cancel"
    cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancel.TextSize = 14
    cancel.Font = Enum.Font.Gotham
    cancel.Parent = frame
    
    frame.Parent = colorPicker
    colorPicker.Parent = CoreGui
    
    local currentHue = 0
    local currentSat = 1
    local currentVal = 1
    local currentColor = Color3.fromRGB(255, 255, 255)
    
    local function updatePreview()
        currentColor = Color3.fromHSV(currentHue, currentSat, currentVal)
        preview.BackgroundColor3 = currentColor
        satBright.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
        
        local r = math.floor(currentColor.R * 255)
        local g = math.floor(currentColor.G * 255)
        local b = math.floor(currentColor.B * 255)
        rgbInput.Text = string.format("RGB: %d,%d,%d", r, g, b)
        hexInput.Text = string.format("#%02X%02X%02X", r, g, b)
    end
    
    local hueConnection
    hueConnection = hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local moveConnection
            moveConnection = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch then
                    local mouseX = input2.Position.X
                    local sliderPos = hueSlider.AbsolutePosition.X
                    local sliderSize = hueSlider.AbsoluteSize.X
                    local percent = math.clamp((mouseX - sliderPos) / sliderSize, 0, 1)
                    currentHue = percent
                    updatePreview()
                end
            end)
            
            local releaseConnection
            releaseConnection = UserInputService.InputEnded:Connect(function(input3)
                if input3.UserInputType == Enum.UserInputType.MouseButton1 or input3.UserInputType == Enum.UserInputType.Touch then
                    moveConnection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end)
    
    local satBrightConnection
    satBrightConnection = satBright.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local moveConnection
            moveConnection = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch then
                    local mousePos = input2.Position
                    local areaPos = satBright.AbsolutePosition
                    local areaSize = satBright.AbsoluteSize
                    
                    local sat = math.clamp((mousePos.X - areaPos.X) / areaSize.X, 0, 1)
                    local bright = 1 - math.clamp((mousePos.Y - areaPos.Y) / areaSize.Y, 0, 1)
                    
                    currentSat = sat
                    currentVal = bright
                    updatePreview()
                end
            end)
            
            local releaseConnection
            releaseConnection = UserInputService.InputEnded:Connect(function(input3)
                if input3.UserInputType == Enum.UserInputType.MouseButton1 or input3.UserInputType == Enum.UserInputType.Touch then
                    moveConnection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end)
    
    rgbInput.FocusLost:Connect(function()
        local success = pcall(function()
            local r, g, b = rgbInput.Text:match("(%d+)[,%s]+(%d+)[,%s]+(%d+)")
            if r and g and b then
                r, g, b = tonumber(r), tonumber(g), tonumber(b)
                if r and g and b then
                    r = math.clamp(r, 0, 255)
                    g = math.clamp(g, 0, 255)
                    b = math.clamp(b, 0, 255)
                    currentColor = Color3.fromRGB(r, g, b)
                    local h, s, v = currentColor:ToHSV()
                    currentHue, currentSat, currentVal = h, s, v
                    updatePreview()
                end
            end
        end)
        if not success then
            updatePreview()
        end
    end)
    
    hexInput.FocusLost:Connect(function()
        local success = pcall(function()
            local hex = hexInput.Text:gsub("#", "")
            if #hex == 6 then
                local r = tonumber(hex:sub(1,2), 16)
                local g = tonumber(hex:sub(3,4), 16)
                local b = tonumber(hex:sub(5,6), 16)
                if r and g and b then
                    currentColor = Color3.fromRGB(r, g, b)
                    local h, s, v = currentColor:ToHSV()
                    currentHue, currentSat, currentVal = h, s, v
                    updatePreview()
                end
            end
        end)
        if not success then
            updatePreview()
        end
    end)
    
    confirm.MouseButton1Click:Connect(function()
        hueConnection:Disconnect()
        satBrightConnection:Disconnect()
        colorPicker:Destroy()
        if callback then
            callback(currentColor)
        end
    end)
    
    cancel.MouseButton1Click:Connect(function()
        hueConnection:Disconnect()
        satBrightConnection:Disconnect()
        colorPicker:Destroy()
    end)
    
    updatePreview()
end

function UmaUiLibrary:Notify(NotificationSettings)
    task.spawn(function()
        local ActionCompleted = true
        local Notification = Notifications.Template:Clone()
        Notification.Parent = Notifications
        Notification.Name = NotificationSettings.Title or "Notification"
        Notification.Visible = true

        Notification.Actions.Template.Visible = false

        if NotificationSettings.Actions then
            for _, Action in pairs(NotificationSettings.Actions) do
                ActionCompleted = false
                local NewAction = Notification.Actions.Template:Clone()
                NewAction.BackgroundColor3 = CurrentTheme.NotificationActionsBackground
                if CurrentTheme ~= Themes.Default then
                    NewAction.TextColor3 = CurrentTheme.TextColor
                end
                NewAction.Name = Action.Name
                NewAction.Visible = true
                NewAction.Parent = Notification.Actions
                NewAction.Text = Action.Name
                NewAction.BackgroundTransparency = 1
                NewAction.TextTransparency = 1
                NewAction.Size = UDim2.new(0, NewAction.TextBounds.X + 27, 0, 36)

                NewAction.MouseButton1Click:Connect(function()
                    self:AsyncCallback(Action.Callback)
                    ActionCompleted = true
                end)
            end
        end

        Notification.BackgroundColor3 = CurrentTheme.Background
        Notification.Title.Text = NotificationSettings.Title or "Notification"
        Notification.Title.TextTransparency = 1
        Notification.Title.TextColor3 = CurrentTheme.TextColor
        Notification.Description.Text = NotificationSettings.Content or ""
        Notification.Description.TextTransparency = 1
        Notification.Description.TextColor3 = CurrentTheme.TextColor
        Notification.Icon.ImageColor3 = CurrentTheme.TextColor
        
        if NotificationSettings.Image then
            Notification.Icon.Image = "rbxassetid://"..tostring(NotificationSettings.Image) 
        else
            Notification.Icon.Image = "rbxassetid://3944680095"
        end

        Notification.Icon.ImageTransparency = 1
        Notification.Parent = Notifications
        Notification.Size = UDim2.new(0, 260, 0, 80)
        Notification.BackgroundTransparency = 1

        TweenService:Create(Notification, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 295, 0, 91)}):Play()
        TweenService:Create(Notification, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.1}):Play()
        Notification:TweenPosition(UDim2.new(0.5,0,0.915,0),'Out','Quint',0.8,true)

        task.wait(0.3)
        TweenService:Create(Notification.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        TweenService:Create(Notification.Title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        TweenService:Create(Notification.Description, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.2}):Play()
        task.wait(0.2)

        if not NotificationSettings.Actions then
            task.wait(NotificationSettings.Duration or NotificationDuration - 0.5)
        else
            task.wait(0.8)
            TweenService:Create(Notification, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 295, 0, 132)}):Play()
            task.wait(0.3)
            for _, Action in ipairs(Notification.Actions:GetChildren()) do
                if Action.ClassName == "TextButton" and Action.Name ~= "Template" then
                    TweenService:Create(Action, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.2}):Play()
                    TweenService:Create(Action, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
                    task.wait(0.05)
                end
            end
        end

        repeat task.wait(0.001) until ActionCompleted

        for _, Action in ipairs(Notification.Actions:GetChildren()) do
            if Action.ClassName == "TextButton" and Action.Name ~= "Template" then
                TweenService:Create(Action, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
                TweenService:Create(Action, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
            end
        end

        TweenService:Create(Notification, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Notification.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(Notification.Description, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(Notification.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        
        task.wait(0.9)
        Notification:Destroy()
    end)
end

function UmaUiLibrary:ShowKeybindOverlay(callback)
    local overlay = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local label = Instance.new("TextLabel")
    local corner = Instance.new("UICorner")
    
    overlay.Name = "KeybindOverlay"
    overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frameWidth = self.Device.IsMobile and 250 or 300
    local frameHeight = self.Device.IsMobile and 120 or 150
    
    frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
    frame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
    frame.BackgroundColor3 = CurrentTheme.Background
    frame.BorderSizePixel = 0
    
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "Press any key...\n(ESC to cancel)"
    label.TextColor3 = CurrentTheme.TextColor
    label.BackgroundTransparency = 1
    label.TextSize = self.Device.IsMobile and 14 or 18
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    
    frame.Parent = overlay
    label.Parent = frame
    overlay.Parent = CoreGui
    
    local function checkModifiers()
        local modifiers = {}
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            table.insert(modifiers, "Ctrl")
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            table.insert(modifiers, "Shift")
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) then
            table.insert(modifiers, "Alt")
        end
        return modifiers
    end
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Escape then
            overlay:Destroy()
            connection:Disconnect()
            return
        end
        
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            local modifiers = checkModifiers()
            local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            
            if keyName:find("Left") or keyName:find("Right") then
                keyName = keyName:gsub("Left", "L-"):gsub("Right", "R-")
            end
            
            local fullKey = keyName
            if #modifiers > 0 then
                fullKey = table.concat(modifiers, "+") .. "+" .. keyName
            end
            
            overlay:Destroy()
            connection:Disconnect()
            self:AsyncCallback(callback, fullKey)
        end
    end)
    
    table.insert(self.Internal.EventConnections, connection)
end

function UmaUiLibrary:CreateWindow(Settings)
    self:DetectDevice()
    
    local Passthrough = false
    Topbar.Title.Text = Settings.Name
    
    local windowWidth = self.Device.IsMobile and 380 or 500
    local windowHeight = self.Device.IsMobile and 450 or 475
    
    Main.Size = UDim2.new(0, 450, 0, 260)
    Main.Visible = true
    Main.BackgroundTransparency = 1
    LoadingFrame.Title.TextTransparency = 1
    LoadingFrame.Subtitle.TextTransparency = 1
    Main.Shadow.Image.ImageTransparency = 1
    LoadingFrame.Version.TextTransparency = 1
    LoadingFrame.Title.Text = Settings.LoadingTitle or "Uma UI Library"
    LoadingFrame.Subtitle.Text = Settings.LoadingSubtitle or "by Uma Team"
    
    Topbar.Visible = false
    Elements.Visible = false
    LoadingFrame.Visible = true

    pcall(function()
        if Settings.ConfigurationSaving then
            if not Settings.ConfigurationSaving.FileName then
                Settings.ConfigurationSaving.FileName = tostring(game.PlaceId)
            end
            CFileName = Settings.ConfigurationSaving.FileName
            ConfigurationFolder = Settings.ConfigurationSaving.FolderName or ConfigurationFolder
            CEnabled = Settings.ConfigurationSaving.Enabled

            if Settings.ConfigurationSaving.Enabled then
                if not isfolder(ConfigurationFolder) then
                    makefolder(ConfigurationFolder)
                end	
            end
        end
    end)

    if Settings.KeySystem then
        if not Settings.KeySettings then
            Passthrough = true
        else
            if not isfolder(UmaFolder.."/Key System") then
                makefolder(UmaFolder.."/Key System")
            end

            if typeof(Settings.KeySettings.Key) == "string" then 
                Settings.KeySettings.Key = {Settings.KeySettings.Key} 
            end

            local keyFilePath = UmaFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension
            if isfile(keyFilePath) then
                local fileContent = readfile(keyFilePath)
                for _, MKey in ipairs(Settings.KeySettings.Key) do
                    local keyHash = HttpService:JSONEncode({key = MKey, timestamp = os.time()})
                    if fileContent == keyHash then
                        Passthrough = true
                        break
                    end
                end
            end
        end
        
        repeat task.wait() until Passthrough
    end

    Notifications.Template.Visible = false
    Notifications.Visible = true
    Uma.Enabled = true
    
    task.wait(0.5)
    TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {ImageTransparency = 0.55}):Play()
    task.wait(0.1)
    TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    task.wait(0.05)
    TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    task.wait(0.05)
    TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

    Elements.Template.LayoutOrder = 100000
    Elements.Template.Visible = false
    Elements.UIPageLayout.FillDirection = Enum.FillDirection.Horizontal
    TabList.Template.Visible = false

    local FirstTab = false
    local Window = {}
    local OpenDropdowns = {}
    
    local dropdownCloseConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            for _, dropdown in ipairs(OpenDropdowns) do
                if dropdown and dropdown.closeFunction then
                    dropdown.closeFunction()
                end
            end
            OpenDropdowns = {}
        end
    end)
    
    table.insert(self.Internal.EventConnections, dropdownCloseConnection)
    
    function Window:Tab(Name, Image)
        local TabButton = TabList.Template:Clone()
        TabButton.Name = Name
        TabButton.Title.Text = Name
        TabButton.Parent = TabList
        TabButton.Visible = true

        local TabPage = Elements.Template:Clone()
        TabPage.Name = Name
        TabPage.Visible = true
        TabPage.LayoutOrder = #Elements:GetChildren()

        for _, TemplateElement in ipairs(TabPage:GetChildren()) do
            if TemplateElement.ClassName == "Frame" and TemplateElement.Name ~= "Placeholder" then
                TemplateElement:Destroy()
            end
        end

        TabPage.Parent = Elements
        
        TabButton.MouseButton1Click:Connect(function()
            Elements.UIPageLayout:JumpTo(TabPage)
        end)
        
        if not FirstTab then
            Elements.UIPageLayout.Animated = false
            Elements.UIPageLayout:JumpTo(TabPage)
            Elements.UIPageLayout.Animated = true
            FirstTab = true
        end

        local Tab = {}

        function Tab:Section(SectionName)
            local SectionSpace = Elements.Template.SectionSpacing:Clone()
            SectionSpace.Visible = true
            SectionSpace.Parent = TabPage

            local Section = Elements.Template.SectionTitle:Clone()
            Section.Title.Text = SectionName
            Section.Visible = true
            Section.Parent = TabPage

            local SectionAPI = {}

            function SectionAPI:Button(Name, Callback, Tooltip)
                local Button = Elements.Template.Button:Clone()
                Button.Name = Name
                Button.Title.Text = Name
                Button.Visible = true
                Button.Parent = TabPage
                Button:SetAttribute("ElementType", "Button")

                Button.Interact.MouseButton1Click:Connect(function()
                    UmaUiLibrary:AsyncCallback(Callback)
                end)

                if Tooltip then
                    Button.Title.Text = Name .. " (ℹ)"
                end

                return SectionAPI
            end

            function SectionAPI:Toggle(Name, DefaultValue, Callback, Tooltip)
                local Toggle = Elements.Template.Toggle:Clone()
                Toggle.Name = Name
                Toggle.Title.Text = Name
                Toggle.Visible = true
                Toggle.Parent = TabPage
                Toggle:SetAttribute("ElementType", "Toggle")

                local ToggleSettings = {
                    Name = Name,
                    CurrentValue = DefaultValue,
                    Callback = Callback,
                    Type = "Toggle"
                }

                local function updateVisuals(value)
                    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart)
                    if value then
                        TweenService:Create(Toggle.Switch.Indicator, tweenInfo, {
                            Position = UDim2.new(1, -20, 0.5, 0),
                            BackgroundColor3 = CurrentTheme.ToggleEnabled
                        }):Play()
                    else
                        TweenService:Create(Toggle.Switch.Indicator, tweenInfo, {
                            Position = UDim2.new(1, -40, 0.5, 0),
                            BackgroundColor3 = CurrentTheme.ToggleDisabled
                        }):Play()
                    end
                end

                Toggle.Interact.MouseButton1Click:Connect(function()
                    ToggleSettings.CurrentValue = not ToggleSettings.CurrentValue
                    updateVisuals(ToggleSettings.CurrentValue)
                    UmaUiLibrary:AsyncCallback(ToggleSettings.Callback, ToggleSettings.CurrentValue)
                    UmaUiLibrary:SaveConfiguration()
                end)

                function ToggleSettings:Set(value)
                    ToggleSettings.CurrentValue = value
                    updateVisuals(value)
                    UmaUiLibrary:AsyncCallback(ToggleSettings.Callback, value)
                    UmaUiLibrary:SaveConfiguration()
                end

                updateVisuals(DefaultValue)

                if Tooltip then
                    Toggle.Title.Text = Name .. " (ℹ)"
                end

                if Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled and Name then
                    UmaUiLibrary.Flags[Name] = ToggleSettings
                end

                return SectionAPI
            end

            function SectionAPI:Slider(Name, Min, Max, DefaultValue, Callback, Suffix)
                if Min > Max then
                    Min, Max = Max, Min
                end
                
                local Slider = Elements.Template.Slider:Clone()
                Slider.Name = Name
                Slider.Title.Text = Name
                Slider.Visible = true
                Slider.Parent = TabPage
                Slider:SetAttribute("ElementType", "Slider")

                local SliderSettings = {
                    Name = Name,
                    Range = {Min, Max},
                    CurrentValue = DefaultValue,
                    Callback = Callback,
                    Suffix = Suffix or "",
                    Type = "Slider"
                }

                local dragging = false
                local precision = 0.01
                
                if (Max - Min) < 1 then
                    precision = 0.001
                elseif (Max - Min) < 10 then
                    precision = 0.01
                else
                    precision = 0.1
                end

                local function updateSlider(value)
                    value = math.clamp(value, Min, Max)
                    
                    local decimalPlaces = math.max(0, -math.floor(math.log10(precision)))
                    value = math.floor(value / precision + 0.5) * precision
                    value = tonumber(string.format("%." .. decimalPlaces .. "f", value))
                    
                    if value < Min then value = Min end
                    if value > Max then value = Max end
                    
                    SliderSettings.CurrentValue = value
                    
                    local percent = (value - Min) / (Max - Min)
                    Slider.Main.Progress.Size = UDim2.new(percent, 0, 1, 0)
                    
                    local displayValue
                    if math.abs(value) >= 100 then
                        displayValue = string.format("%.0f", value)
                    elseif math.abs(value) >= 10 then
                        displayValue = string.format("%.1f", value)
                    else
                        displayValue = string.format("%.2f", value)
                    end
                    
                    Slider.Main.Information.Text = displayValue .. (Suffix and " " .. Suffix or "")
                end

                local interactConnection = Slider.Main.Interact.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)

                local releaseConnection = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if dragging then
                            dragging = false
                            UmaUiLibrary:SaveConfiguration()
                        end
                    end
                end)

                local moveConnection = UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local mousePos = input.Position.X
                        local sliderPos = Slider.Main.AbsolutePosition.X
                        local sliderSize = Slider.Main.AbsoluteSize.X
                        
                        local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                        local value = Min + (Max - Min) * percent
                        
                        updateSlider(value)
                        UmaUiLibrary:AsyncCallback(SliderSettings.Callback, value)
                    end
                end)

                function SliderSettings:Set(value)
                    updateSlider(value)
                    UmaUiLibrary:AsyncCallback(SliderSettings.Callback, value)
                    UmaUiLibrary:SaveConfiguration()
                end

                updateSlider(DefaultValue)

                if Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled and Name then
                    UmaUiLibrary.Flags[Name] = SliderSettings
                end

                table.insert(UmaUiLibrary.Internal.EventConnections, interactConnection)
                table.insert(UmaUiLibrary.Internal.EventConnections, releaseConnection)
                table.insert(UmaUiLibrary.Internal.EventConnections, moveConnection)

                return SectionAPI
            end

            function SectionAPI:Label(Text)
                local Label = Elements.Template.Label:Clone()
                Label.Title.Text = Text
                Label.Visible = true
                Label.Parent = TabPage
                Label:SetAttribute("ElementType", "Label")
                
                local LabelSettings = {
                    Type = "Label"
                }
                
                function LabelSettings:Set(newText)
                    Label.Title.Text = newText
                end
                
                return LabelSettings
            end

            function SectionAPI:Input(Name, DefaultValue, Callback, Placeholder)
                local Input = Elements.Template.Input:Clone()
                Input.Name = Name
                Input.Title.Text = Name
                Input.Visible = true
                Input.Parent = TabPage
                Input:SetAttribute("ElementType", "Input")

                local InputSettings = {
                    Name = Name,
                    CurrentValue = DefaultValue or "",
                    Callback = Callback,
                    Type = "Input"
                }

                Input.InputFrame.InputBox.Text = DefaultValue or ""
                Input.InputFrame.InputBox.PlaceholderText = Placeholder or "Enter text..."

                Input.InputFrame.InputBox.FocusLost:Connect(function(enterPressed)
                    local text = Input.InputFrame.InputBox.Text
                    InputSettings.CurrentValue = text
                    UmaUiLibrary:AsyncCallback(InputSettings.Callback, text)
                    UmaUiLibrary:SaveConfiguration()
                end)

                function InputSettings:Set(value)
                    InputSettings.CurrentValue = value
                    Input.InputFrame.InputBox.Text = value
                    UmaUiLibrary:AsyncCallback(InputSettings.Callback, value)
                    UmaUiLibrary:SaveConfiguration()
                end

                if Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled and Name then
                    UmaUiLibrary.Flags[Name] = InputSettings
                end

                return SectionAPI
            end

            function SectionAPI:Keybind(Name, DefaultKey, Callback, HoldToInteract)
                local Keybind = Elements.Template.Keybind:Clone()
                Keybind.Name = Name
                Keybind.Title.Text = Name
                Keybind.Visible = true
                Keybind.Parent = TabPage
                Keybind:SetAttribute("ElementType", "Keybind")

                local KeybindSettings = {
                    Name = Name,
                    CurrentKeybind = DefaultKey,
                    Callback = Callback,
                    HoldToInteract = HoldToInteract or false,
                    Type = "Keybind"
                }

                Keybind.KeybindFrame.KeybindBox.Text = DefaultKey

                Keybind.KeybindFrame.KeybindBox.Focused:Connect(function()
                    Keybind.KeybindFrame.KeybindBox.Text = "..."
                    UmaUiLibrary:ShowKeybindOverlay(function(newKey)
                        KeybindSettings.CurrentKeybind = newKey
                        Keybind.KeybindFrame.KeybindBox.Text = newKey
                        UmaUiLibrary:SaveConfiguration()
                    end)
                end)

                local keybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.KeyCode ~= Enum.KeyCode.Unknown then
                        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                        
                        if keyName:find("Left") or keyName:find("Right") then
                            keyName = keyName:gsub("Left", "L-"):gsub("Right", "R-")
                        end
                        
                        if keyName == KeybindSettings.CurrentKeybind or KeybindSettings.CurrentKeybind:find(keyName) then
                            UmaUiLibrary:AsyncCallback(KeybindSettings.Callback)
                        end
                    end
                end)

                function KeybindSettings:Set(key)
                    KeybindSettings.CurrentKeybind = key
                    Keybind.KeybindFrame.KeybindBox.Text = key
                    UmaUiLibrary:SaveConfiguration()
                end

                if Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled and Name then
                    UmaUiLibrary.Flags[Name] = KeybindSettings
                end

                table.insert(UmaUiLibrary.Internal.EventConnections, keybindConnection)

                return SectionAPI
            end

            function SectionAPI:Dropdown(Name, Options, DefaultOption, Callback)
                local Dropdown = Elements.Template.Dropdown:Clone()
                Dropdown.Name = Name
                Dropdown.Title.Text = Name
                Dropdown.Visible = true
                Dropdown.Parent = TabPage
                Dropdown:SetAttribute("ElementType", "Dropdown")

                local DropdownSettings = {
                    Name = Name,
                    Options = Options,
                    CurrentOption = DefaultOption,
                    Callback = Callback,
                    Type = "Dropdown"
                }

                local dropdownData = {
                    Connections = {},
                    Element = Dropdown
                }
                
                local isOpen = false
                Dropdown.DropdownFrame.SelectedOption.Text = DefaultOption or "Select..."

                local function closeDropdown()
                    isOpen = false
                    for _, option in ipairs(Dropdown.DropdownFrame.OptionsList:GetChildren()) do
                        if option:IsA("TextButton") then
                            option:Destroy()
                        end
                    end
                    Dropdown.DropdownFrame.OptionsList.Visible = false
                    
                    for i, dd in ipairs(OpenDropdowns) do
                        if dd.dropdown == Dropdown then
                            table.remove(OpenDropdowns, i)
                            break
                        end
                    end
                end

                local function openDropdown()
                    for _, dd in ipairs(OpenDropdowns) do
                        if dd and dd.closeFunction then
                            dd.closeFunction()
                        end
                    end
                    OpenDropdowns = {}
                    
                    isOpen = true
                    Dropdown.DropdownFrame.OptionsList.Visible = true
                    
                    for _, option in ipairs(Options) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Size = UDim2.new(1, 0, 0, 30)
                        optionButton.Text = option
                        optionButton.BackgroundColor3 = CurrentTheme.DropdownUnselected
                        optionButton.TextColor3 = CurrentTheme.TextColor
                        optionButton.Font = Enum.Font.Gotham
                        optionButton.TextSize = UmaUiLibrary.Device.IsMobile and 12 or 14
                        optionButton.BorderSizePixel = 0
                        optionButton.Parent = Dropdown.DropdownFrame.OptionsList

                        optionButton.MouseButton1Click:Connect(function()
                            DropdownSettings.CurrentOption = option
                            Dropdown.DropdownFrame.SelectedOption.Text = option
                            UmaUiLibrary:AsyncCallback(DropdownSettings.Callback, option)
                            UmaUiLibrary:SaveConfiguration()
                            closeDropdown()
                        end)
                    end
                    
                    table.insert(OpenDropdowns, {
                        dropdown = Dropdown,
                        closeFunction = closeDropdown
                    })
                end

                local dropdownConnection = Dropdown.DropdownFrame.SelectedOption.MouseButton1Click:Connect(function()
                    if isOpen then
                        closeDropdown()
                    else
                        openDropdown()
                    end
                end)
                
                table.insert(dropdownData.Connections, dropdownConnection)

                function DropdownSettings:Set(option)
                    DropdownSettings.CurrentOption = option
                    Dropdown.DropdownFrame.SelectedOption.Text = option
                    UmaUiLibrary:AsyncCallback(DropdownSettings.Callback, option)
                    UmaUiLibrary:SaveConfiguration()
                    closeDropdown()
                end
                
                local ancestryConnection = Dropdown.AncestryChanged:Connect(function()
                    if not Dropdown.Parent then
                        for _, conn in ipairs(dropdownData.Connections) do
                            pcall(function() conn:Disconnect() end)
                        end
                        closeDropdown()
                    end
                end)
                
                table.insert(dropdownData.Connections, ancestryConnection)

                if Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled and Name then
                    UmaUiLibrary.Flags[Name] = DropdownSettings
                end

                for _, conn in ipairs(dropdownData.Connections) do
                    table.insert(UmaUiLibrary.Internal.EventConnections, conn)
                end

                return SectionAPI
            end

            return SectionAPI
        end

        function Tab:Button(Name, Callback)
            return self:Section(""):Button(Name, Callback)
        end

        function Tab:Toggle(Name, DefaultValue, Callback)
            return self:Section(""):Toggle(Name, DefaultValue, Callback)
        end

        function Tab:Slider(Name, Min, Max, DefaultValue, Callback, Suffix)
            return self:Section(""):Slider(Name, Min, Max, DefaultValue, Callback, Suffix)
        end

        function Tab:Label(Text)
            return self:Section(""):Label(Text)
        end

        function Tab:Input(Name, DefaultValue, Callback, Placeholder)
            return self:Section(""):Input(Name, DefaultValue, Callback, Placeholder)
        end

        function Tab:Keybind(Name, DefaultKey, Callback, HoldToInteract)
            return self:Section(""):Keybind(Name, DefaultKey, Callback, HoldToInteract)
        end

        function Tab:Dropdown(Name, Options, DefaultOption, Callback)
            return self:Section(""):Dropdown(Name, Options, DefaultOption, Callback)
        end

        return Tab
    end

    function Window:Notify(Title, Content, Duration, Image)
        UmaUiLibrary:Notify({
            Title = Title,
            Content = Content,
            Duration = Duration or 5,
            Image = Image
        })
        return Window
    end

    function Window:Theme(ThemeName)
        UmaUiLibrary:ChangeTheme(ThemeName)
        return Window
    end

    function Window:Use(PluginName, ...)
        local plugin = UmaUiLibrary.Plugins[PluginName]
        if plugin and plugin.Initialize then
            plugin:Initialize(UmaUiLibrary, ...)
        else
            warn("Plugin '" .. tostring(PluginName) .. "' not found or invalid")
        end
        return Window
    end

    function Window:On(Event, Callback)
        local eventName = "On" .. Event
        local bindableEvent = UmaUiLibrary.Events[eventName]
        if bindableEvent then
            local connection = bindableEvent.Event:Connect(Callback)
            table.insert(UmaUiLibrary.Internal.EventConnections, connection)
        else
            warn("Event '" .. tostring(Event) .. "' not found")
        end
        return Window
    end

    function Window:Toggle()
        Main.Visible = not Main.Visible
        return Window
    end

    function Window:Destroy()
        UmaUiLibrary:Destroy()
    end

    task.wait(0.7)
    TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    task.wait(0.2)
    TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, windowWidth, 0, windowHeight)}):Play()

    Topbar.Visible = true
    Elements.Visible = true
    TabList.Visible = true
    LoadingFrame.Visible = false
    
    TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Topbar.Title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    self:SetupMobileSupport()
    
    UmaUiLibrary.Events.OnWindowOpened:Fire(Window)

    task.delay(1, function()
        UmaUiLibrary:LoadConfiguration()
    end)

    return Window
end

function UmaUiLibrary:Destroy()
    for _, connection in ipairs(self.Internal.EventConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    self.Internal.EventConnections = {}
    
    for _, pool in pairs(self.Performance.ObjectPool) do
        if pool then
            for instance in pairs(pool.Active) do
                pcall(function() instance:Destroy() end)
            end
            for _, instance in ipairs(pool.Inactive) do
                pcall(function() instance:Destroy() end)
            end
        end
    end
    
    pcall(function() Uma:Destroy() end)
    self.Events.OnWindowClosed:Fire()
end

function UmaUiLibrary:GetPerformanceInfo()
    if self.Performance.BenchmarkMode then
        local activeCount = 0
        local pooledCount = 0
        
        for _, pool in pairs(self.Performance.ObjectPool) do
            if pool then
                activeCount = activeCount + (pool.ActiveCount or 0)
                pooledCount = pooledCount + #pool.Inactive
            end
        end
        
        return {
            FPS = self.Performance.FPS or 0,
            ActiveObjects = activeCount,
            PooledObjects = pooledCount,
            Device = self.Device
        }
    end
    return nil
end

UmaUiLibrary:InitializeObjectPool()
UmaUiLibrary:SetupAccessibility()

if UmaUiLibrary.Performance.BenchmarkMode then
    UmaUiLibrary.Performance.FPS = 0
    UmaUiLibrary.Performance.FrameCount = 0
    UmaUiLibrary.Performance.LastTime = tick()
    
    local benchmarkConnection = RunService.Heartbeat:Connect(function()
        UmaUiLibrary.Performance.FrameCount = UmaUiLibrary.Performance.FrameCount + 1
        local currentTime = tick()
        if currentTime - UmaUiLibrary.Performance.LastTime >= 1 then
            UmaUiLibrary.Performance.FPS = UmaUiLibrary.Performance.FrameCount
            UmaUiLibrary.Performance.FrameCount = 0
            UmaUiLibrary.Performance.LastTime = currentTime
        end
    end)
    
    table.insert(UmaUiLibrary.Internal.EventConnections, benchmarkConnection)
end

return UmaUiLibrary
