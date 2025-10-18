local UmaUiLibrary = {
    Version = "2.0.1",
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
        BenchmarkMode = false
    }
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Release = "2.0"
local NotificationDuration = 6.5
local UmaFolder = "UmaUI"
local ConfigurationFolder = UmaFolder.."/Configurations"
local ConfigurationExtension = ".json"

local Uma = game:GetObjects("rbxassetid://10804731440")[1]
Uma.Enabled = false

-- Better GUI protection
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

-- Remove old instances
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

-- Initialize Object Pool
function UmaUiLibrary:InitializeObjectPool()
    for _, elementType in pairs({"Button", "Toggle", "Slider", "Label", "Dropdown", "Input", "Keybind"}) do
        self.Performance.ObjectPool[elementType] = {
            Active = {},
            Inactive = {}
        }
    end
end

function UmaUiLibrary:GetFromPool(elementType)
    local pool = self.Performance.ObjectPool[elementType]
    if pool and #pool.Inactive > 0 then
        local instance = table.remove(pool.Inactive)
        pool.Active[instance] = true
        return instance
    end
    return nil
end

function UmaUiLibrary:ReturnToPool(elementType, instance)
    local pool = self.Performance.ObjectPool[elementType]
    if pool then
        pool.Active[instance] = nil
        table.insert(pool.Inactive, instance)
    end
end

function UmaUiLibrary:AsyncCallback(callback, ...)
    local args = {...}
    task.spawn(function()
        local success, result = pcall(callback, table.unpack(args))
        if not success then
            warn("UmaUI Async Error:", result)
        end
    end)
end

function UmaUiLibrary:RegisterPlugin(name, pluginModule)
    self.Plugins[name] = pluginModule
    self.Events.OnElementCreated:Fire("PluginRegistered", name)
end

function UmaUiLibrary:SetupAccessibility()
    UserInputService.InputChanged:Connect(function(input)
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
        if pool then
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
    for _, element in pairs(self:GetAllElements()) do
        self:UpdateElementTheme(element, theme)
    end
    
    if Main then
        Main.BackgroundColor3 = theme.Background
        Topbar.BackgroundColor3 = theme.Topbar
    end
end

function UmaUiLibrary:UpdateElementTheme(element, theme)
    if not element then return end
    
    if element:FindFirstChild("Title") then
        element.Title.TextColor3 = theme.TextColor
        element.Title.Font = theme.TextFont
    end
    
    if element:IsA("Frame") then
        element.BackgroundColor3 = theme.ElementBackground
    end
end

function UmaUiLibrary:CreateCustomTheme(name, themeData)
    Themes[name] = themeData
    return true
end

-- Simplified config save/load without encryption
function UmaUiLibrary:SaveConfiguration()
    if not CEnabled then return end
    
    local success, err = pcall(function()
        local data = {}
        for flag, element in pairs(self.Flags) do
            if element.Type == "ColorPicker" then
                data[flag] = {
                    R = element.Color.R * 255, 
                    G = element.Color.G * 255, 
                    B = element.Color.B * 255
                }
            else
                data[flag] = element.CurrentValue or element.CurrentKeybind or element.CurrentOption
            end
        end
        
        local json = HttpService:JSONEncode(data)
        local filePath = ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension
        writefile(filePath, json)
        
        self.Events.OnConfigLoaded:Fire("Saved", CFileName)
    end)
    
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
        return HttpService:JSONDecode(json)
    end)
    
    if success and data then
        for flagName, flagValue in pairs(data) do
            if self.Flags[flagName] then
                local element = self.Flags[flagName]
                pcall(function()
                    if element.Type == "ColorPicker" then
                        element:Set(Color3.fromRGB(flagValue.R, flagValue.G, flagValue.B))
                    else
                        element:Set(flagValue)
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
    local data = {}
    for flag, element in pairs(self.Flags) do
        if element.Type == "ColorPicker" then
            data[flag] = {
                R = element.Color.R * 255, 
                G = element.Color.G * 255, 
                B = element.Color.B * 255
            }
        else
            data[flag] = element.CurrentValue or element.CurrentKeybind or element.CurrentOption
        end
    end
    return data
end

function UmaUiLibrary:ImportConfiguration(data)
    for flagName, flagValue in pairs(data) do
        if self.Flags[flagName] then
            local element = self.Flags[flagName]
            pcall(function()
                if element.Type == "ColorPicker" then
                    element:Set(Color3.fromRGB(flagValue.R, flagValue.G, flagValue.B))
                else
                    element:Set(flagValue)
                end
            end)
        end
    end
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
    
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = CurrentTheme.Background
    frame.BorderSizePixel = 0
    
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "Press any key...\n(ESC to cancel)"
    label.TextColor3 = CurrentTheme.TextColor
    label.BackgroundTransparency = 1
    label.TextSize = 18
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    
    frame.Parent = overlay
    label.Parent = frame
    overlay.Parent = CoreGui
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Escape then
            overlay:Destroy()
            connection:Disconnect()
            return
        end
        
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            overlay:Destroy()
            connection:Disconnect()
            self:AsyncCallback(callback, keyName)
        end
    end)
end

function UmaUiLibrary:ShowColorPicker(callback)
    -- Placeholder for color picker
    warn("Color picker not yet implemented")
    if callback then
        callback(Color3.fromRGB(255, 255, 255))
    end
end

function UmaUiLibrary:CreateWindow(Settings)
    local Passthrough = false
    Topbar.Title.Text = Settings.Name
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

            if isfile(UmaFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension) then
                for _, MKey in ipairs(Settings.KeySettings.Key) do
                    if string.find(readfile(UmaFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension), MKey) then
                        Passthrough = true
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
                local Slider = Elements.Template.Slider:Clone()
                Slider.Name = Name
                Slider.Title.Text = Name
                Slider.Visible = true
                Slider.Parent = TabPage

                local SliderSettings = {
                    Name = Name,
                    Range = {Min, Max},
                    CurrentValue = DefaultValue,
                    Callback = Callback,
                    Suffix = Suffix or "",
                    Type = "Slider"
                }

                local dragging = false

                local function updateSlider(value)
                    value = math.clamp(value, Min, Max)
                    SliderSettings.CurrentValue = value
                    
                    local percent = (value - Min) / (Max - Min)
                    Slider.Main.Progress.Size = UDim2.new(percent, 0, 1, 0)
                    Slider.Main.Information.Text = tostring(math.floor(value * 100) / 100) .. (Suffix and " " .. Suffix or "")
                end

                Slider.Main.Interact.MouseButton1Down:Connect(function()
                    dragging = true
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if dragging then
                            dragging = false
                            UmaUiLibrary:SaveConfiguration()
                        end
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
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

                return SectionAPI
            end

            function SectionAPI:Label(Text)
                local Label = Elements.Template.Label:Clone()
                Label.Title.Text = Text
                Label.Visible = true
                Label.Parent = TabPage
                
                local LabelSettings = {
                    Type = "Label"
                }
                
                function LabelSettings:Set(newText)
                    Label.Title.Text = newText
                end
                
                return SectionAPI
            end

            function SectionAPI:Input(Name, DefaultValue, Callback, Placeholder)
                local Input = Elements.Template.Input:Clone()
                Input.Name = Name
                Input.Title.Text = Name
                Input.Visible = true
                Input.Parent = TabPage

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

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed then
                        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                        if keyName == KeybindSettings.CurrentKeybind then
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

                return SectionAPI
            end

            function SectionAPI:Dropdown(Name, Options, DefaultOption, Callback)
                local Dropdown = Elements.Template.Dropdown:Clone()
                Dropdown.Name = Name
                Dropdown.Title.Text = Name
                Dropdown.Visible = true
                Dropdown.Parent = TabPage

                local DropdownSettings = {
                    Name = Name,
                    Options = Options,
                    CurrentOption = DefaultOption,
                    Callback = Callback,
                    Type = "Dropdown"
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
                end

                local function openDropdown()
                    isOpen = true
                    Dropdown.DropdownFrame.OptionsList.Visible = true
                    
                    for _, option in ipairs(Options) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Size = UDim2.new(1, 0, 0, 30)
                        optionButton.Text = option
                        optionButton.BackgroundColor3 = CurrentTheme.DropdownUnselected
                        optionButton.TextColor3 = CurrentTheme.TextColor
                        optionButton.Font = Enum.Font.Gotham
                        optionButton.TextSize = 14
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
                end

                Dropdown.DropdownFrame.SelectedOption.MouseButton1Click:Connect(function()
                    if isOpen then
                        closeDropdown()
                    else
                        openDropdown()
                    end
                end)

                function DropdownSettings:Set(option)
                    DropdownSettings.CurrentOption = option
                    Dropdown.DropdownFrame.SelectedOption.Text = option
                    UmaUiLibrary:AsyncCallback(DropdownSettings.Callback, option)
                    UmaUiLibrary:SaveConfiguration()
                    closeDropdown()
                end

                if Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled and Name then
                    UmaUiLibrary.Flags[Name] = DropdownSettings
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
            bindableEvent.Event:Connect(Callback)
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
    TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 500, 0, 475)}):Play()

    Topbar.Visible = true
    Elements.Visible = true
    TabList.Visible = true
    LoadingFrame.Visible = false
    
    TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Topbar.Title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

    -- Drag functionality
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    UmaUiLibrary.Events.OnWindowOpened:Fire(Window)

    -- Auto-load configuration after window is created
    task.delay(1, function()
        UmaUiLibrary:LoadConfiguration()
    end)

    return Window
end

function UmaUiLibrary:Destroy()
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
                for _ in pairs(pool.Active) do
                    activeCount = activeCount + 1
                end
                pooledCount = pooledCount + #pool.Inactive
            end
        end
        
        return {
            FPS = self.Performance.FPS or 0,
            ActiveObjects = activeCount,
            PooledObjects = pooledCount
        }
    end
    return nil
end

-- Initialize
UmaUiLibrary:InitializeObjectPool()
UmaUiLibrary:SetupAccessibility()

if UmaUiLibrary.Performance.BenchmarkMode then
    UmaUiLibrary.Performance.FPS = 0
    UmaUiLibrary.Performance.FrameCount = 0
    UmaUiLibrary.Performance.LastTime = tick()
    
    RunService.Heartbeat:Connect(function()
        UmaUiLibrary.Performance.FrameCount = UmaUiLibrary.Performance.FrameCount + 1
        local currentTime = tick()
        if currentTime - UmaUiLibrary.Performance.LastTime >= 1 then
            UmaUiLibrary.Performance.FPS = UmaUiLibrary.Performance.FrameCount
            UmaUiLibrary.Performance.FrameCount = 0
            UmaUiLibrary.Performance.LastTime = currentTime
        end
    end)
end

return UmaUiLibrary
