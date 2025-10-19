local UmaUiLibrary = {
    Version = "3.0.0",
    SessionId = HttpService:GenerateGUID(false),
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
        MaxPoolSize = 50,
        Thresholds = {
            MaxMemoryMB = 300,
            MinFPS = 20,
            MaxElements = 200
        }
    },
    Internal = {
        EventConnections = setmetatable({}, {__mode = "v"}),
        MutexLocks = {},
        ElementData = {},
        TweenCache = {}
    },
    Configuration = {
        ErrorTracking = true,
        ShowErrorNotifications = true,
        AutoMobileDetect = true,
        TouchScrollSpeed = 2,
        MemoryMonitoring = true,
        PerformanceGuards = true
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

local Release = "3.0.0"
local UmaFolder = "UmaUI_Standalone"
local ConfigurationFolder = UmaFolder.."/Configurations"
local ConfigurationExtension = ".json"

local ErrorSeverity = {
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3,
    CRITICAL = 4
}

local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UmaUI_Standalone"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    ScreenGui.ResetOnSpawn = false
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 500, 0, 475)
    Main.Position = UDim2.new(0.5, -250, 0.5, -237)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.ZIndex = 0
    Shadow.Parent = Main
    
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main
    
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 10)
    TopbarCorner.Parent = Topbar
    
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Size = UDim2.new(1, 0, 0, 10)
    TopbarFix.Position = UDim2.new(0, 0, 1, -10)
    TopbarFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Parent = Topbar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Uma UI"
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(0, 150, 1, -50)
    TabList.Position = UDim2.new(0, 10, 0, 45)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 4
    TabList.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabList.Parent = Main
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabList
    
    local Elements = Instance.new("Frame")
    Elements.Name = "Elements"
    Elements.Size = UDim2.new(1, -170, 1, -50)
    Elements.Position = UDim2.new(0, 160, 0, 45)
    Elements.BackgroundTransparency = 1
    Elements.ClipsDescendants = true
    Elements.Parent = Main
    
    local ElementsScroll = Instance.new("ScrollingFrame")
    ElementsScroll.Name = "ElementsScroll"
    ElementsScroll.Size = UDim2.new(1, 0, 1, 0)
    ElementsScroll.BackgroundTransparency = 1
    ElementsScroll.BorderSizePixel = 0
    ElementsScroll.ScrollBarThickness = 4
    ElementsScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
    ElementsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ElementsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ElementsScroll.Parent = Elements
    
    local ElementsLayout = Instance.new("UIListLayout")
    ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ElementsLayout.Padding = UDim.new(0, 8)
    ElementsLayout.Parent = ElementsScroll
    
    local Notifications = Instance.new("Frame")
    Notifications.Name = "Notifications"
    Notifications.Size = UDim2.new(0, 300, 0, 100)
    Notifications.Position = UDim2.new(0.5, -150, 1, -120)
    Notifications.BackgroundTransparency = 1
    Notifications.Parent = ScreenGui
    
    return ScreenGui, Main, Topbar, TabList, Elements, ElementsScroll, Notifications
end

if gethui then
    UmaUI.Parent = gethui()
elseif syn and syn.protect_gui then 
    syn.protect_gui(UmaUI)
    UmaUI.Parent = CoreGui
else
    UmaUI.Parent = CoreGui
end

local UmaUI, Main, Topbar, TabList, Elements, ElementsScroll, Notifications = CreateUI()

if gethui then
    UmaUI.Parent = gethui()
else
    UmaUI.Parent = CoreGui
end

local CurrentTheme = {
    TextFont = Enum.Font.Gotham,
    TextColor = Color3.fromRGB(240, 240, 240),
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
}

local ThemeCache = {}

function UmaUiLibrary:SanitizeInput(input, inputType)
    if type(input) ~= "string" then return "" end
    
    local sanitized = input:gsub("[<>\"']", ""):sub(1, 1000)
    
    if inputType == "filename" then
        sanitized = sanitized:gsub("%.%.[\\/]", ""):gsub("[\\/]", "_")
    elseif inputType == "numeric" then
        sanitized = sanitized:gsub("%D", "")
    elseif inputType == "alphanumeric" then
        sanitized = sanitized:gsub("%W", "")
    end
    
    return sanitized
end

function UmaUiLibrary:SafeWriteFile(path, content)
    local success, err = pcall(function()
        if not path:match("^" .. UmaFolder) then
            error("Invalid file path")
        end
        
        if #content > 1000000 then
            error("File too large (max 1MB)")
        end
        
        writefile(path, content)
        return true
    end)
    
    return success, err
end

function UmaUiLibrary:AcquireLock(lockName, timeout)
    timeout = timeout or 5
    local startTime = tick()
    
    while self.Internal.MutexLocks[lockName] do
        if tick() - startTime >= timeout then
            error("Lock timeout: " .. lockName)
        end
        task.wait(0.01)
    end
    
    self.Internal.MutexLocks[lockName] = true
    return true
end

function UmaUiLibrary:ReleaseLock(lockName)
    self.Internal.MutexLocks[lockName] = nil
end

function UmaUiLibrary:TrackError(err, stack, location, severity)
    severity = severity or ErrorSeverity.MEDIUM
    
    local errorData = {
        Error = tostring(err),
        Stack = stack or debug.traceback(),
        Location = location or "Unknown",
        Severity = severity,
        Timestamp = os.time(),
        Version = self.Version,
        SessionId = self.SessionId,
        Device = self.Device
    }
    
    if severity >= ErrorSeverity.HIGH then
        warn("🚨 CRITICAL ERROR:", err)
        
        if self.Configuration.ShowErrorNotifications then
            self:Notify({
                Title = "Critical Error",
                Content = tostring(err):sub(1, 100),
                Duration = 10
            })
        end
    end
    
    if self.Configuration.ErrorTracking then
        pcall(function()
            if not isfolder(UmaFolder .. "/ErrorLogs") then
                makefolder(UmaFolder .. "/ErrorLogs")
            end
            
            local filename = string.format("%s/ErrorLogs/error_%d_%s.json", 
                UmaFolder, os.time(), tostring(severity))
            
            local json = HttpService:JSONEncode(errorData)
            self:SafeWriteFile(filename, json)
        end)
    end
end

function UmaUiLibrary:DetectDevice()
    local screenSize = workspace.CurrentCamera.ViewportSize
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
        Main.Size = UDim2.new(0, 380, 0, 450)
    end
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

function UmaUiLibrary:GetFromPool(elementType, createCallback)
    local pool = self.Performance.ObjectPool[elementType]
    if pool and #pool.Inactive > 0 then
        local instance = table.remove(pool.Inactive)
        pool.Active[instance] = true
        pool.ActiveCount = pool.ActiveCount + 1
        return instance
    end
    
    if createCallback then
        local newInstance = createCallback()
        if newInstance and pool then
            pool.Active[newInstance] = true
            pool.ActiveCount = pool.ActiveCount + 1
        end
        return newInstance
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

function UmaUiLibrary:SetupMemoryMonitor()
    if not self.Configuration.MemoryMonitoring then return end
    
    local memoryThreshold = self.Performance.Thresholds.MaxMemoryMB
    local checkInterval = 30
    
    task.spawn(function()
        while self.Configuration.MemoryMonitoring do
            task.wait(checkInterval)
            
            local memoryUsage = collectgarbage("count") / 1024
            if memoryUsage > memoryThreshold then
                local beforeMem = memoryUsage
                self:PerformCleanup()
                collectgarbage("collect")
                local afterMem = collectgarbage("count") / 1024
                
                warn(string.format("🔄 Memory cleanup: %.2f MB -> %.2f MB", beforeMem, afterMem))
            end
        end
    end)
end

function UmaUiLibrary:PerformCleanup()
    for elementType, pool in pairs(self.Performance.ObjectPool) do
        if pool and pool.Inactive then
            local maxKeep = math.floor(self.Performance.MaxPoolSize * 0.5)
            while #pool.Inactive > maxKeep do
                local instance = table.remove(pool.Inactive)
                pcall(function() instance:Destroy() end)
            end
        end
    end
    
    pcall(function()
        local errorLogs = listfiles(UmaFolder .. "/ErrorLogs") or {}
        table.sort(errorLogs)
        while #errorLogs > 50 do
            local oldFile = table.remove(errorLogs, 1)
            delfile(oldFile)
        end
    end)
    
    for tweenId, tween in pairs(self.Internal.TweenCache) do
        if tween and tween.PlaybackState == Enum.PlaybackState.Completed then
            tween:Destroy()
            self.Internal.TweenCache[tweenId] = nil
        end
    end
end

function UmaUiLibrary:SetupPerformanceGuards()
    if not self.Configuration.PerformanceGuards then return end
    
    task.spawn(function()
        while self.Configuration.PerformanceGuards do
            task.wait(5)
            
            local memory = collectgarbage("count") / 1024
            if memory > self.Performance.Thresholds.MaxMemoryMB then
                self:PerformCleanup()
            end
            
            local elementCount = 0
            for _, pool in pairs(self.Performance.ObjectPool) do
                if pool then
                    elementCount = elementCount + (pool.ActiveCount or 0)
                end
            end
            
            if elementCount > self.Performance.Thresholds.MaxElements then
                warn("⚠️ High element count:", elementCount)
            end
        end
    end)
end

function UmaUiLibrary:GetVisibleElements()
    local visible = {}
    for _, pool in pairs(self.Performance.ObjectPool) do
        if pool and pool.Active then
            for element in pairs(pool.Active) do
                if element and element.Parent and element.Visible then
                    table.insert(visible, element)
                end
            end
        end
    end
    return visible
end

function UmaUiLibrary:BatchTween(instances, properties, tweenInfo)
    local tweens = {}
    for _, instance in ipairs(instances) do
        if instance and instance.Parent then
            local tween = TweenService:Create(instance, tweenInfo, properties)
            table.insert(tweens, tween)
            tween:Play()
            
            local tweenId = HttpService:GenerateGUID(false)
            self.Internal.TweenCache[tweenId] = tween
        end
    end
    return tweens
end

function UmaUiLibrary:ApplyTheme(theme)
    if self.ThemeChangeDebounce then return end
    self.ThemeChangeDebounce = true
    
    if not ThemeCache[theme] then
        ThemeCache[theme] = theme
    end
    
    CurrentTheme = theme
    
    Main.BackgroundColor3 = theme.Background
    Topbar.BackgroundColor3 = theme.Topbar
    
    task.spawn(function()
        local visibleElements = self:GetVisibleElements()
        local chunkSize = self.Device.IsMobile and 5 or 15
        
        for i = 1, #visibleElements, chunkSize do
            task.wait(0.016)
            local endIdx = math.min(i + chunkSize - 1, #visibleElements)
            
            for j = i, endIdx do
                if visibleElements[j] and visibleElements[j].Parent then
                    self:UpdateElementTheme(visibleElements[j], theme)
                end
            end
        end
        
        task.wait(0.1)
        self.ThemeChangeDebounce = false
    end)
end

function UmaUiLibrary:UpdateElementTheme(element, theme)
    if not element or not element.Parent then return end
    
    local elementType = element:GetAttribute("ElementType")
    
    pcall(function()
        if element:FindFirstChild("Title") then
            element.Title.TextColor3 = theme.TextColor
            element.Title.Font = theme.TextFont
        end
        
        if elementType == "Button" then
            element.BackgroundColor3 = theme.ElementBackground
        elseif elementType == "Toggle" then
            element.BackgroundColor3 = theme.ElementBackground
            if element:FindFirstChild("Switch") and element.Switch:FindFirstChild("Indicator") then
                local isEnabled = element.Switch.Indicator.Position.X.Offset > -30
                element.Switch.Indicator.BackgroundColor3 = isEnabled and theme.ToggleEnabled or theme.ToggleDisabled
            end
        elseif elementType == "Slider" then
            if element:FindFirstChild("Main") then
                element.Main.BackgroundColor3 = theme.SliderBackground
                if element.Main:FindFirstChild("Progress") then
                    element.Main.Progress.BackgroundColor3 = theme.SliderProgress
                end
            end
        elseif elementType == "Input" then
            if element:FindFirstChild("InputFrame") and element.InputFrame:FindFirstChild("InputBox") then
                element.InputFrame.BackgroundColor3 = theme.InputBackground
                element.InputFrame.InputBox.TextColor3 = theme.TextColor
                element.InputFrame.InputBox.PlaceholderColor3 = theme.PlaceholderColor
            end
        end
    end)
end

function UmaUiLibrary:EnhancedAsyncCallback(callback, ...)
    local args = {...}
    local callbackName = debug.info(callback, "n") or "Anonymous"
    
    task.spawn(function()
        local success, result = xpcall(function()
            return callback(table.unpack(args))
        end, function(err)
            local stack = debug.traceback()
            self:TrackError(err, stack, callbackName, ErrorSeverity.MEDIUM)
            return err
        end)
        
        if not success and self.Configuration.ShowErrorNotifications then
            self:Notify({
                Title = "Callback Error",
                Content = tostring(result):sub(1, 50),
                Duration = 5
            })
        end
    end)
end

function UmaUiLibrary:Notify(settings)
    task.spawn(function()
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0, 280, 0, 80)
        notif.Position = UDim2.new(0.5, -140, 1, 100)
        notif.BackgroundColor3 = CurrentTheme.Background
        notif.BorderSizePixel = 0
        notif.Parent = Notifications
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notif
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 25)
        title.Position = UDim2.new(0, 10, 0, 10)
        title.BackgroundTransparency = 1
        title.Text = settings.Title or "Notification"
        title.TextColor3 = CurrentTheme.TextColor
        title.TextSize = 14
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = notif
        
        local content = Instance.new("TextLabel")
        content.Size = UDim2.new(1, -20, 1, -40)
        content.Position = UDim2.new(0, 10, 0, 35)
        content.BackgroundTransparency = 1
        content.Text = settings.Content or ""
        content.TextColor3 = CurrentTheme.TextColor
        content.TextSize = 12
        content.Font = Enum.Font.Gotham
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.TextYAlignment = Enum.TextYAlignment.Top
        content.TextWrapped = true
        content.Parent = notif
        
        notif:TweenPosition(UDim2.new(0.5, -140, 1, -100), "Out", "Quint", 0.5, true)
        
        task.wait(settings.Duration or 5)
        
        notif:TweenPosition(UDim2.new(0.5, -140, 1, 100), "Out", "Quint", 0.5, true)
        task.wait(0.5)
        notif:Destroy()
    end)
end

function UmaUiLibrary:CreateWindow(settings)
    self:DetectDevice()
    self:SetupMobileSupport()
    self:SetupMemoryMonitor()
    self:SetupPerformanceGuards()
    
    local windowWidth = self.Device.IsMobile and 380 or 500
    local windowHeight = self.Device.IsMobile and 450 or 475
    
    Main.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    Topbar.Title.Text = settings.Name or "Uma UI"
    
    UmaUI.Enabled = true
    
    local Window = {}
    local CurrentTab = nil
    
    function Window:Tab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name
        tabButton.Size = UDim2.new(1, -10, 0, 35)
        tabButton.BackgroundColor3 = CurrentTheme.TabBackground
        tabButton.Text = name
        tabButton.TextColor3 = CurrentTheme.TabTextColor
        tabButton.TextSize = 13
        tabButton.Font = Enum.Font.Gotham
        tabButton.AutoButtonColor = false
        tabButton.Parent = TabList
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        local tabContent = Instance.new("Frame")
        tabContent.Name = name .. "_Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = ElementsScroll
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent
        
        tabButton.MouseButton1Click:Connect(function()
            if CurrentTab then
                CurrentTab.Visible = false
            end
            
            for _, btn in ipairs(TabList:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = CurrentTheme.TabBackground
                    btn.TextColor3 = CurrentTheme.TabTextColor
                end
            end
            
            tabButton.BackgroundColor3 = CurrentTheme.TabBackgroundSelected
            tabButton.TextColor3 = CurrentTheme.SelectedTabTextColor
            tabContent.Visible = true
            CurrentTab = tabContent
        end)
        
        if not CurrentTab then
            tabButton.BackgroundColor3 = CurrentTheme.TabBackgroundSelected
            tabButton.TextColor3 = CurrentTheme.SelectedTabTextColor
            tabContent.Visible = true
            CurrentTab = tabContent
        end
        
        local Tab = {Content = tabContent}
        
        function Tab:Section(sectionName)
            local section = Instance.new("Frame")
            section.Name = sectionName
            section.Size = UDim2.new(1, 0, 0, 25)
            section.BackgroundTransparency = 1
            section.Parent = tabContent
            
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Size = UDim2.new(1, 0, 1, 0)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = CurrentTheme.TextColor
            sectionTitle.TextSize = 14
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = section
            
            local SectionAPI = {}
            
            function SectionAPI:Button(name, callback)
                local button = Instance.new("TextButton")
                button.Name = name
                button.Size = UDim2.new(1, 0, 0, 35)
                button.BackgroundColor3 = CurrentTheme.ElementBackground
                button.Text = name
                button.TextColor3 = CurrentTheme.TextColor
                button.TextSize = 13
                button.Font = Enum.Font.Gotham
                button.AutoButtonColor = false
                button.Parent = tabContent
                button:SetAttribute("ElementType", "Button")
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    UmaUiLibrary:EnhancedAsyncCallback(callback)
                end)
                
                button.MouseEnter:Connect(function()
                    button.BackgroundColor3 = CurrentTheme.ElementBackgroundHover
                end)
                
                button.MouseLeave:Connect(function()
                    button.BackgroundColor3 = CurrentTheme.ElementBackground
                end)
                
                return SectionAPI
            end
            
            function SectionAPI:Toggle(name, defaultValue, callback)
                local toggle = Instance.new("Frame")
                toggle.Name = name
                toggle.Size = UDim2.new(1, 0, 0, 35)
                toggle.BackgroundColor3 = CurrentTheme.ElementBackground
                toggle.Parent = tabContent
                toggle:SetAttribute("ElementType", "Toggle")
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 6)
                toggleCorner.Parent = toggle
                
                local title = Instance.new("TextLabel")
                title.Name = "Title"
                title.Size = UDim2.new(1, -60, 1, 0)
                title.Position = UDim2.new(0, 10, 0, 0)
                title.BackgroundTransparency = 1
                title.Text = name
                title.TextColor3 = CurrentTheme.TextColor
                title.TextSize = 13
                title.Font = Enum.Font.Gotham
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = toggle
                
                local switch = Instance.new("Frame")
                switch.Name = "Switch"
                switch.Size = UDim2.new(0, 40, 0, 20)
                switch.Position = UDim2.new(1, -50, 0.5, -10)
                switch.BackgroundColor3 = defaultValue and CurrentTheme.ToggleEnabled or CurrentTheme.ToggleDisabled
                switch.Parent = toggle
                
                local switchCorner = Instance.new("UICorner")
                switchCorner.CornerRadius = UDim.new(1, 0)
                switchCorner.Parent = switch
                
                local indicator = Instance.new("Frame")
                indicator.Name = "Indicator"
                indicator.Size = UDim2.new(0, 16, 0, 16)
                indicator.Position = defaultValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                indicator.Parent = switch
                
                local indicatorCorner = Instance.new("UICorner")
                indicatorCorner.CornerRadius = UDim.new(1, 0)
                indicatorCorner.Parent = indicator
                
                local toggleSettings = {
                    CurrentValue = defaultValue,
                    Type = "Toggle"
                }
                
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 1, 0)
                button.BackgroundTransparency = 1
                button.Text = ""
                button.Parent = toggle
                
                button.MouseButton1Click:Connect(function()
                    toggleSettings.CurrentValue = not toggleSettings.CurrentValue
                    
                    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart)
                    
                    if toggleSettings.CurrentValue then
                        TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                        TweenService:Create(switch, tweenInfo, {BackgroundColor3 = CurrentTheme.ToggleEnabled}):Play()
                    else
                        TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                        TweenService:Create(switch, tweenInfo, {BackgroundColor3 = CurrentTheme.ToggleDisabled}):Play()
                    end
                    
                    UmaUiLibrary:EnhancedAsyncCallback(callback, toggleSettings.CurrentValue)
                end)
                
                function toggleSettings:Set(value)
                    toggleSettings.CurrentValue = value
                    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart)
                    
                    if value then
                        TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                        TweenService:Create(switch, tweenInfo, {BackgroundColor3 = CurrentTheme.ToggleEnabled}):Play()
                    else
                        TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                        TweenService:Create(switch, tweenInfo, {BackgroundColor3 = CurrentTheme.ToggleDisabled}):Play()
                    end
                    
                    UmaUiLibrary:EnhancedAsyncCallback(callback, value)
                end
                
                if settings and settings.ConfigurationSaving and settings.ConfigurationSaving.Enabled then
                    UmaUiLibrary.Flags[name] = toggleSettings
                end
                
                return SectionAPI
            end
            
            function SectionAPI:Slider(name, min, max, defaultValue, callback, suffix)
                if min > max then min, max = max, min end
                
                local slider = Instance.new("Frame")
                slider.Name = name
                slider.Size = UDim2.new(1, 0, 0, 45)
                slider.BackgroundColor3 = CurrentTheme.ElementBackground
                slider.Parent = tabContent
                slider:SetAttribute("ElementType", "Slider")
                
                local sliderCorner = Instance.new("UICorner")
                sliderCorner.CornerRadius = UDim.new(0, 6)
                sliderCorner.Parent = slider
                
                local title = Instance.new("TextLabel")
                title.Name = "Title"
                title.Size = UDim2.new(1, -20, 0, 20)
                title.Position = UDim2.new(0, 10, 0, 5)
                title.BackgroundTransparency = 1
                title.Text = name
                title.TextColor3 = CurrentTheme.TextColor
                title.TextSize = 13
                title.Font = Enum.Font.Gotham
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = slider
                
                local sliderBar = Instance.new("Frame")
                sliderBar.Name = "Main"
                sliderBar.Size = UDim2.new(1, -20, 0, 6)
                sliderBar.Position = UDim2.new(0, 10, 1, -12)
                sliderBar.BackgroundColor3 = CurrentTheme.SliderBackground
                sliderBar.Parent = slider
                
                local barCorner = Instance.new("UICorner")
                barCorner.CornerRadius = UDim.new(1, 0)
                barCorner.Parent = sliderBar
                
                local progress = Instance.new("Frame")
                progress.Name = "Progress"
                progress.Size = UDim2.new(0, 0, 1, 0)
                progress.BackgroundColor3 = CurrentTheme.SliderProgress
                progress.BorderSizePixel = 0
                progress.Parent = sliderBar
                
                local progressCorner = Instance.new("UICorner")
                progressCorner.CornerRadius = UDim.new(1, 0)
                progressCorner.Parent = progress
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Name = "Information"
                valueLabel.Size = UDim2.new(0, 60, 0, 20)
                valueLabel.Position = UDim2.new(1, -70, 0, 5)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(defaultValue) .. (suffix or "")
                valueLabel.TextColor3 = CurrentTheme.TextColor
                valueLabel.TextSize = 12
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = slider
                
                local sliderSettings = {
                    CurrentValue = defaultValue,
                    Range = {min, max},
                    Type = "Slider"
                }
                
                local dragging = false
                local precision = (max - min) < 1 and 0.001 or (max - min) < 10 and 0.01 or 0.1
                
                local function updateSlider(value)
                    value = math.clamp(value, min, max)
                    value = math.floor(value / precision + 0.5) * precision
                    
                    sliderSettings.CurrentValue = value
                    
                    local percent = (value - min) / (max - min)
                    progress.Size = UDim2.new(percent, 0, 1, 0)
                    
                    local displayValue = value >= 100 and string.format("%.0f", value) or
                                       value >= 10 and string.format("%.1f", value) or
                                       string.format("%.2f", value)
                    
                    valueLabel.Text = displayValue .. (suffix or "")
                end
                
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 1, 0)
                button.BackgroundTransparency = 1
                button.Text = ""
                button.Parent = slider
                
                button.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)
                
                local releaseConnection = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                local moveConnection = UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                                    input.UserInputType == Enum.UserInputType.Touch) then
                        local mousePos = input.Position.X
                        local barPos = sliderBar.AbsolutePosition.X
                        local barSize = sliderBar.AbsoluteSize.X
                        
                        local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                        local value = min + (max - min) * percent
                        
                        updateSlider(value)
                        UmaUiLibrary:EnhancedAsyncCallback(callback, value)
                    end
                end)
                
                table.insert(UmaUiLibrary.Internal.EventConnections, releaseConnection)
                table.insert(UmaUiLibrary.Internal.EventConnections, moveConnection)
                
                function sliderSettings:Set(value)
                    updateSlider(value)
                    UmaUiLibrary:EnhancedAsyncCallback(callback, value)
                end
                
                updateSlider(defaultValue)
                
                if settings and settings.ConfigurationSaving and settings.ConfigurationSaving.Enabled then
                    UmaUiLibrary.Flags[name] = sliderSettings
                end
                
                return SectionAPI
            end
            
            function SectionAPI:Label(text)
                local label = Instance.new("Frame")
                label.Size = UDim2.new(1, 0, 0, 25)
                label.BackgroundTransparency = 1
                label.Parent = tabContent
                label:SetAttribute("ElementType", "Label")
                
                local labelText = Instance.new("TextLabel")
                labelText.Name = "Title"
                labelText.Size = UDim2.new(1, 0, 1, 0)
                labelText.BackgroundTransparency = 1
                labelText.Text = text
                labelText.TextColor3 = CurrentTheme.TextColor
                labelText.TextSize = 12
                labelText.Font = Enum.Font.Gotham
                labelText.TextXAlignment = Enum.TextXAlignment.Left
                labelText.TextWrapped = true
                labelText.Parent = label
                
                local labelSettings = {Type = "Label"}
                
                function labelSettings:Set(newText)
                    labelText.Text = UmaUiLibrary:SanitizeInput(newText)
                end
                
                return labelSettings
            end
            
            function SectionAPI:Input(name, defaultValue, callback, placeholder)
                local input = Instance.new("Frame")
                input.Name = name
                input.Size = UDim2.new(1, 0, 0, 60)
                input.BackgroundColor3 = CurrentTheme.ElementBackground
                input.Parent = tabContent
                input:SetAttribute("ElementType", "Input")
                
                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = UDim.new(0, 6)
                inputCorner.Parent = input
                
                local title = Instance.new("TextLabel")
                title.Name = "Title"
                title.Size = UDim2.new(1, -20, 0, 25)
                title.Position = UDim2.new(0, 10, 0, 5)
                title.BackgroundTransparency = 1
                title.Text = name
                title.TextColor3 = CurrentTheme.TextColor
                title.TextSize = 13
                title.Font = Enum.Font.Gotham
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = input
                
                local inputBox = Instance.new("TextBox")
                inputBox.Name = "InputBox"
                inputBox.Size = UDim2.new(1, -20, 0, 25)
                inputBox.Position = UDim2.new(0, 10, 1, -30)
                inputBox.BackgroundColor3 = CurrentTheme.InputBackground
                inputBox.Text = UmaUiLibrary:SanitizeInput(defaultValue or "")
                inputBox.PlaceholderText = placeholder or "Enter text..."
                inputBox.TextColor3 = CurrentTheme.TextColor
                inputBox.PlaceholderColor3 = CurrentTheme.PlaceholderColor
                inputBox.TextSize = 12
                inputBox.Font = Enum.Font.Gotham
                inputBox.ClearTextOnFocus = false
                inputBox.Parent = input
                
                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 4)
                boxCorner.Parent = inputBox
                
                local inputSettings = {
                    CurrentValue = defaultValue or "",
                    Type = "Input"
                }
                
                inputBox.FocusLost:Connect(function()
                    local sanitized = UmaUiLibrary:SanitizeInput(inputBox.Text)
                    inputBox.Text = sanitized
                    inputSettings.CurrentValue = sanitized
                    UmaUiLibrary:EnhancedAsyncCallback(callback, sanitized)
                end)
                
                function inputSettings:Set(value)
                    local sanitized = UmaUiLibrary:SanitizeInput(value)
                    inputBox.Text = sanitized
                    inputSettings.CurrentValue = sanitized
                    UmaUiLibrary:EnhancedAsyncCallback(callback, sanitized)
                end
                
                if settings and settings.ConfigurationSaving and settings.ConfigurationSaving.Enabled then
                    UmaUiLibrary.Flags[name] = inputSettings
                end
                
                return SectionAPI
            end
            
            return SectionAPI
        end
        
        function Tab:Button(name, callback)
            return self:Section(""):Button(name, callback)
        end
        
        function Tab:Toggle(name, defaultValue, callback)
            return self:Section(""):Toggle(name, defaultValue, callback)
        end
        
        function Tab:Slider(name, min, max, defaultValue, callback, suffix)
            return self:Section(""):Slider(name, min, max, defaultValue, callback, suffix)
        end
        
        function Tab:Label(text)
            return self:Section(""):Label(text)
        end
        
        function Tab:Input(name, defaultValue, callback, placeholder)
            return self:Section(""):Input(name, defaultValue, callback, placeholder)
        end
        
        return Tab
    end
    
    function Window:Notify(title, content, duration)
        UmaUiLibrary:Notify({
            Title = title,
            Content = content,
            Duration = duration
        })
        return Window
    end
    
    function Window:Destroy()
        UmaUiLibrary:Destroy()
    end
    
    local dragging, dragInput, dragStart, startPos
    
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    self.Events.OnWindowOpened:Fire(Window)
    
    return Window
end

function UmaUiLibrary:Destroy()
    for _, connection in pairs(self.Internal.EventConnections) do
        pcall(function()
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end)
    end
    
    self.Internal.EventConnections = setmetatable({}, {__mode = "v"})
    
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
    
    for _, tween in pairs(self.Internal.TweenCache) do
        pcall(function() tween:Cancel() end)
    end
    
    self.Configuration.MemoryMonitoring = false
    self.Configuration.PerformanceGuards = false
    
    pcall(function() UmaUI:Destroy() end)
    self.Events.OnWindowClosed:Fire()
end

UmaUiLibrary:InitializeObjectPool()

return UmaUiLibrary
