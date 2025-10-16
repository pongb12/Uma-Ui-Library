
local UmaLib = {
    Flags = {},
    Connections = {},
    Elements = {},
    Themes = {
        Default = {
            -- Colors
            Background = Color3.fromRGB(20, 20, 20),
            Surface = Color3.fromRGB(28, 28, 28),
            Primary = Color3.fromRGB(88, 101, 242),
            Secondary = Color3.fromRGB(114, 137, 218),
            Accent = Color3.fromRGB(67, 181, 129),
            Text = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(180, 180, 180),
            Border = Color3.fromRGB(40, 40, 40),
            Hover = Color3.fromRGB(35, 35, 35),
            Success = Color3.fromRGB(67, 181, 129),
            Warning = Color3.fromRGB(250, 166, 26),
            Error = Color3.fromRGB(240, 71, 71),
        },
        Dark = {
            Background = Color3.fromRGB(15, 15, 15),
            Surface = Color3.fromRGB(24, 24, 24),
            Primary = Color3.fromRGB(114, 137, 218),
            Secondary = Color3.fromRGB(88, 101, 242),
            Accent = Color3.fromRGB(67, 181, 129),
            Text = Color3.fromRGB(245, 245, 245),
            TextSecondary = Color3.fromRGB(170, 170, 170),
            Border = Color3.fromRGB(35, 35, 35),
            Hover = Color3.fromRGB(30, 30, 30),
            Success = Color3.fromRGB(67, 181, 129),
            Warning = Color3.fromRGB(250, 166, 26),
            Error = Color3.fromRGB(240, 71, 71),
        }
    },
    CurrentTheme = "Default",
    ConfigFolder = "UmaUI"
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Utility Functions
local function Tween(obj, props, duration, style, direction)
    duration = duration or 0.3
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    
    return TweenService:Create(obj, TweenInfo.new(duration, style, direction), props)
end

local function AddConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(UmaLib.Connections, connection)
    return connection
end

local function MakeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(frame, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }, 0.25):Play()
        end
    end)
end

local function SaveConfig()
    if not UmaLib.SaveEnabled then return end
    
    local data = {}
    for flag, element in pairs(UmaLib.Flags) do
        if element.Save then
            data[flag] = element.Value
        end
    end
    
    local success, err = pcall(function()
        if not isfolder(UmaLib.ConfigFolder) then
            makefolder(UmaLib.ConfigFolder)
        end
        writefile(UmaLib.ConfigFolder .. "/" .. game.PlaceId .. ".json", HttpService:JSONEncode(data))
    end)
    
    if not success then
        warn("Uma UI: Failed to save config - " .. tostring(err))
    end
end

local function LoadConfig()
    if not UmaLib.SaveEnabled then return end
    
    local success, result = pcall(function()
        local path = UmaLib.ConfigFolder .. "/" .. game.PlaceId .. ".json"
        if isfile(path) then
            return HttpService:JSONDecode(readfile(path))
        end
    end)
    
    if success and result then
        for flag, value in pairs(result) do
            if UmaLib.Flags[flag] then
                spawn(function()
                    UmaLib.Flags[flag]:Set(value)
                end)
            end
        end
    end
end

-- Main UI Creation
function UmaLib:CreateWindow(config)
    config = config or {}
    config.Name = config.Name or "Uma UI"
    config.Icon = config.Icon or ""
    config.Theme = config.Theme or "Default"
    config.SaveConfig = config.SaveConfig ~= false
    config.IntroEnabled = config.IntroEnabled ~= false
    config.IntroText = config.IntroText or "Uma UI Library"
    
    self.CurrentTheme = config.Theme
    self.SaveEnabled = config.SaveConfig
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UmaUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    local UIShadow = Instance.new("ImageLabel")
    UIShadow.Name = "Shadow"
    UIShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    UIShadow.BackgroundTransparency = 1
    UIShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    UIShadow.Size = UDim2.new(1, 40, 1, 40)
    UIShadow.ZIndex = 0
    UIShadow.Image = "rbxassetid://5554236805"
    UIShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    UIShadow.ImageTransparency = 0.5
    UIShadow.Parent = MainFrame
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = self.Themes[self.CurrentTheme].Surface
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 10)
    TopBarCorner.Parent = TopBar
    
    local TopBarCover = Instance.new("Frame")
    TopBarCover.Size = UDim2.new(1, 0, 0, 10)
    TopBarCover.Position = UDim2.new(0, 0, 1, -10)
    TopBarCover.BackgroundColor3 = self.Themes[self.CurrentTheme].Surface
    TopBarCover.BorderSizePixel = 0
    TopBarCover.Parent = TopBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name
    Title.TextColor3 = self.Themes[self.CurrentTheme].Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 10)
    CloseButton.BackgroundColor3 = self.Themes[self.CurrentTheme].Error
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = TopBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -75, 0, 10)
    MinimizeButton.BackgroundColor3 = self.Themes[self.CurrentTheme].Warning
    MinimizeButton.Text = "—"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 16
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.Parent = TopBar
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 6)
    MinimizeCorner.Parent = MinimizeButton
    
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        Tween(MainFrame, {
            Size = minimized and UDim2.new(0, 600, 0, 50) or UDim2.new(0, 600, 0, 400)
        }, 0.3):Play()
    end)
    
    MakeDraggable(MainFrame, TopBar)
    
    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -60)
    TabContainer.Position = UDim2.new(0, 5, 0, 55)
    TabContainer.BackgroundColor3 = self.Themes[self.CurrentTheme].Surface
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = self.Themes[self.CurrentTheme].Primary
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = MainFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabContainer
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingBottom = UDim.new(0, 5)
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingRight = UDim.new(0, 5)
    TabPadding.Parent = TabContainer
    
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -165, 1, -60)
    ContentContainer.Position = UDim2.new(0, 160, 0, 55)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    -- Intro Animation
    if config.IntroEnabled then
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        
        local IntroLabel = Instance.new("TextLabel")
        IntroLabel.Size = UDim2.new(1, 0, 1, 0)
        IntroLabel.BackgroundTransparency = 1
        IntroLabel.Text = config.IntroText
        IntroLabel.TextColor3 = self.Themes[self.CurrentTheme].Primary
        IntroLabel.TextSize = 24
        IntroLabel.Font = Enum.Font.GothamBold
        IntroLabel.TextTransparency = 1
        IntroLabel.Parent = MainFrame
        
        spawn(function()
            Tween(IntroLabel, {TextTransparency = 0}, 0.5):Play()
            wait(1.5)
            Tween(IntroLabel, {TextTransparency = 1}, 0.5):Play()
            wait(0.5)
            IntroLabel:Destroy()
            Tween(MainFrame, {
                Size = UDim2.new(0, 600, 0, 400),
                BackgroundTransparency = 0
            }, 0.5):Play()
        end)
    end
    
    -- Window object
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }
    
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Icon = tabConfig.Icon or ""
        
        local Tab = {
            Name = tabConfig.Name,
            Elements = {}
        }
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabConfig.Name
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.BackgroundColor3 = self.Themes[self.CurrentTheme].Hover
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 6)
        TabButtonCorner.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -10, 1, 0)
        TabLabel.Position = UDim2.new(0, 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabConfig.Name
        TabLabel.TextColor3 = self.Themes[self.CurrentTheme].TextSecondary
        TabLabel.TextSize = 14
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabConfig.Name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = self.Themes[self.CurrentTheme].Primary
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = TabContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 8)
        ContentPadding.PaddingBottom = UDim.new(0, 8)
        ContentPadding.PaddingLeft = UDim.new(0, 8)
        ContentPadding.PaddingRight = UDim.new(0, 8)
        ContentPadding.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 16)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                Tween(tab.Button, {BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Hover}):Play()
                Tween(tab.Label, {TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].TextSecondary}):Play()
            end
            
            TabContent.Visible = true
            Window.CurrentTab = Tab
            Tween(TabButton, {BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Primary}):Play()
            Tween(TabLabel, {TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Text}):Play()
        end)
        
        Tab.Button = TabButton
        Tab.Label = TabLabel
        Tab.Content = TabContent
        
        if #Window.Tabs == 0 then
            TabContent.Visible = true
            Window.CurrentTab = Tab
            TabButton.BackgroundColor3 = self.Themes[self.CurrentTheme].Primary
            TabLabel.TextColor3 = self.Themes[self.CurrentTheme].Text
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Tab Elements
        function Tab:CreateButton(btnConfig)
            btnConfig = btnConfig or {}
            btnConfig.Name = btnConfig.Name or "Button"
            btnConfig.Callback = btnConfig.Callback or function() end
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
            ButtonFrame.BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Surface
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Parent = TabContent
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = ButtonFrame
            
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.BackgroundTransparency = 1
            Button.Text = ""
            Button.Parent = ButtonFrame
            
            local ButtonLabel = Instance.new("TextLabel")
            ButtonLabel.Size = UDim2.new(1, -20, 1, 0)
            ButtonLabel.Position = UDim2.new(0, 10, 0, 0)
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Text = btnConfig.Name
            ButtonLabel.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Text
            ButtonLabel.TextSize = 14
            ButtonLabel.Font = Enum.Font.Gotham
            ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
            ButtonLabel.Parent = ButtonFrame
            
            Button.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Hover}):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Surface}):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Primary}, 0.1):Play()
                wait(0.1)
                Tween(ButtonFrame, {BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Surface}):Play()
                
                local success, err = pcall(btnConfig.Callback)
                if not success then
                    warn("Uma UI: Button callback error - " .. tostring(err))
                end
            end)
            
            return {
                Set = function(_, text)
                    ButtonLabel.Text = text
                end
            }
        end
        
        function Tab:CreateToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            toggleConfig.Name = toggleConfig.Name or "Toggle"
            toggleConfig.Default = toggleConfig.Default or false
            toggleConfig.Callback = toggleConfig.Callback or function() end
            toggleConfig.Flag = toggleConfig.Flag
            toggleConfig.Save = toggleConfig.Save or false
            
            local Toggle = {
                Value = toggleConfig.Default,
                Save = toggleConfig.Save
            }
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            ToggleFrame.BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Surface
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = toggleConfig.Name
            ToggleLabel.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Text
            ToggleLabel.TextSize = 14
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 45, 0, 24)
            ToggleButton.Position = UDim2.new(1, -55, 0.5, -12)
            ToggleButton.BackgroundColor3 = Toggle.Value and UmaLib.Themes[UmaLib.CurrentTheme].Success or UmaLib.Themes[UmaLib.CurrentTheme].Border
            ToggleButton.Text = ""
            ToggleButton.AutoButtonColor = false
            ToggleButton.Parent = ToggleFrame
            
            local ToggleButtonCorner = Instance.new("UICorner")
            ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
            ToggleButtonCorner.Parent = ToggleButton
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
            ToggleCircle.Position = Toggle.Value and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleButton
            
            local ToggleCircleCorner = Instance.new("UICorner")
            ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
            ToggleCircleCorner.Parent = ToggleCircle
            
            function Toggle:Set(value)
                Toggle.Value = value
                
                Tween(ToggleButton, {
                    BackgroundColor3 = value and UmaLib.Themes[UmaLib.CurrentTheme].Success or UmaLib.Themes[UmaLib.CurrentTheme].Border
                }):Play()
                
                Tween(ToggleCircle, {
                    Position = value and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                }):Play()
                
                local success, err = pcall(toggleConfig.Callback, value)
                if not success then
                    warn("Uma UI: Toggle callback error - " .. tostring(err))
                end
                
                SaveConfig()
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                Toggle:Set(not Toggle.Value)
            end)
            
            if toggleConfig.Flag then
                UmaLib.Flags[toggleConfig.Flag] = Toggle
            end
            
            return Toggle
        end
        
        function Tab:CreateSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            sliderConfig.Name = sliderConfig.Name or "Slider"
            sliderConfig.Min = sliderConfig.Min or 0
            sliderConfig.Max = sliderConfig.Max or 100
            sliderConfig.Default = sliderConfig.Default or 50
            sliderConfig.Increment = sliderConfig.Increment or 1
            sliderConfig.Callback = sliderConfig.Callback or function() end
            sliderConfig.Flag = sliderConfig.Flag
            sliderConfig.Save = sliderConfig.Save or false
            
            local Slider = {
                Value = sliderConfig.Default,
                Save = sliderConfig.Save
            }
            
            local dragging = false
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 60)
            SliderFrame.BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Surface
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(1, -20, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = sliderConfig.Name
            SliderLabel.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Text
            SliderLabel.TextSize = 14
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local SliderValue = Instance.new("TextLabel")
            SliderValue.Size = UDim2.new(0, 50, 0, 20)
            SliderValue.Position = UDim2.new(1, -60, 0, 5)
            SliderValue.BackgroundTransparency = 1
            SliderValue.Text = tostring(Slider.Value)
            SliderValue.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Primary
            SliderValue.TextSize = 14
            SliderValue.Font = Enum.Font.GothamBold
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right
            SliderValue.Parent = SliderFrame
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Size = UDim2.new(1, -20, 0, 6)
            SliderBar.Position = UDim2.new(0, 10, 1, -20)
            SliderBar.BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Border
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = SliderFrame
            
            local SliderBarCorner = Instance.new("UICorner")
            SliderBarCorner.CornerRadius = UDim.new(1, 0)
            SliderBarCorner.Parent = SliderBar
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Slider.Value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Primary
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar
            
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill
            
            function Slider:Set(value)
                value = math.clamp(value, sliderConfig.Min, sliderConfig.Max)
                value = math.floor(value / sliderConfig.Increment + 0.5) * sliderConfig.Increment
                Slider.Value = value
                
                SliderValue.Text = tostring(value)
                Tween(SliderFill, {
                    Size = UDim2.new((value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 1, 0)
                }, 0.15):Play()
                
                local success, err = pcall(sliderConfig.Callback, value)
                if not success then
                    warn("Uma UI: Slider callback error - " .. tostring(err))
                end
                
                SaveConfig()
            end
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            SliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local value = sliderConfig.Min + (sliderConfig.Max - sliderConfig.Min) * mousePos
                    Slider:Set(value)
                end
            end)
            
            if sliderConfig.Flag then
                UmaLib.Flags[sliderConfig.Flag] = Slider
            end
            
            return Slider
        end
        
        function Tab:CreateDropdown(dropdownConfig)
            dropdownConfig = dropdownConfig or {}
            dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
            dropdownConfig.Options = dropdownConfig.Options or {}
            dropdownConfig.Default = dropdownConfig.Default or ""
            dropdownConfig.Callback = dropdownConfig.Callback or function() end
            dropdownConfig.Flag = dropdownConfig.Flag
            dropdownConfig.Save = dropdownConfig.Save or false
            
            local Dropdown = {
                Value = dropdownConfig.Default,
                Options = dropdownConfig.Options,
                Open = false,
                Save = dropdownConfig.Save
            }
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
            DropdownFrame.BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Surface
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = TabContent
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, 0, 0, 40)
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Text = ""
            DropdownButton.Parent = DropdownFrame
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(1, -60, 1, 0)
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = dropdownConfig.Name
            DropdownLabel.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Text
            DropdownLabel.TextSize = 14
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownButton
            
            local DropdownValue = Instance.new("TextLabel")
            DropdownValue.Size = UDim2.new(0, 100, 1, 0)
            DropdownValue.Position = UDim2.new(1, -110, 0, 0)
            DropdownValue.BackgroundTransparency = 1
            DropdownValue.Text = Dropdown.Value
            DropdownValue.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].TextSecondary
            DropdownValue.TextSize = 13
            DropdownValue.Font = Enum.Font.Gotham
            DropdownValue.TextXAlignment = Enum.TextXAlignment.Right
            DropdownValue.Parent = DropdownButton
            
            local DropdownIcon = Instance.new("TextLabel")
            DropdownIcon.Size = UDim2.new(0, 20, 0, 20)
            DropdownIcon.Position = UDim2.new(1, -25, 0.5, -10)
            DropdownIcon.BackgroundTransparency = 1
            DropdownIcon.Text = "▼"
            DropdownIcon.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].TextSecondary
            DropdownIcon.TextSize = 10
            DropdownIcon.Font = Enum.Font.GothamBold
            DropdownIcon.Parent = DropdownButton
            
            local DropdownList = Instance.new("ScrollingFrame")
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 0, 40)
            DropdownList.BackgroundTransparency = 1
            DropdownList.BorderSizePixel = 0
            DropdownList.ScrollBarThickness = 3
            DropdownList.ScrollBarImageColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Primary
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropdownList.Parent = DropdownFrame
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.Parent = DropdownList
            
            local ListPadding = Instance.new("UIPadding")
            ListPadding.PaddingTop = UDim.new(0, 5)
            ListPadding.PaddingBottom = UDim.new(0, 5)
            ListPadding.PaddingLeft = UDim.new(0, 10)
            ListPadding.PaddingRight = UDim.new(0, 10)
            ListPadding.Parent = DropdownList
            
            function Dropdown:Refresh(options)
                for _, child in pairs(DropdownList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                Dropdown.Options = options or Dropdown.Options
                
                for _, option in pairs(Dropdown.Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Size = UDim2.new(1, 0, 0, 28)
                    OptionButton.BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Hover
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Text = option
                    OptionButton.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Text
                    OptionButton.TextSize = 13
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.AutoButtonColor = false
                    OptionButton.Parent = DropdownList
                    
                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 4)
                    OptionCorner.Parent = OptionButton
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Primary}, 0.15):Play()
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Hover}, 0.15):Play()
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown:Set(option)
                        Dropdown:Toggle()
                    end)
                end
                
                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
                end)
            end
            
            function Dropdown:Set(value)
                Dropdown.Value = value
                DropdownValue.Text = value
                
                local success, err = pcall(dropdownConfig.Callback, value)
                if not success then
                    warn("Uma UI: Dropdown callback error - " .. tostring(err))
                end
                
                SaveConfig()
            end
            
            function Dropdown:Toggle()
                Dropdown.Open = not Dropdown.Open
                
                local targetSize = Dropdown.Open and math.min(#Dropdown.Options * 30 + 50, 200) or 40
                Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, targetSize)}):Play()
                Tween(DropdownIcon, {Rotation = Dropdown.Open and 180 or 0}):Play()
                
                if Dropdown.Open then
                    DropdownList.Size = UDim2.new(1, 0, 1, -50)
                else
                    wait(0.3)
                    DropdownList.Size = UDim2.new(1, 0, 0, 0)
                end
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                Dropdown:Toggle()
            end)
            
            Dropdown:Refresh()
            
            if dropdownConfig.Flag then
                UmaLib.Flags[dropdownConfig.Flag] = Dropdown
            end
            
            return Dropdown
        end
        
        function Tab:CreateLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 30)
            LabelFrame.BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Surface
            LabelFrame.BorderSizePixel = 0
            LabelFrame.Parent = TabContent
            
            local LabelCorner = Instance.new("UICorner")
            LabelCorner.CornerRadius = UDim.new(0, 6)
            LabelCorner.Parent = LabelFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text or "Label"
            Label.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = LabelFrame
            
            return {
                Set = function(_, newText)
                    Label.Text = newText
                end
            }
        end
        
        function Tab:CreateSection(name)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 25)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Parent = TabContent
            
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, 0, 1, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = name or "Section"
            SectionLabel.TextColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Primary
            SectionLabel.TextSize = 16
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = SectionFrame
            
            local SectionLine = Instance.new("Frame")
            SectionLine.Size = UDim2.new(1, 0, 0, 1)
            SectionLine.Position = UDim2.new(0, 0, 1, -2)
            SectionLine.BackgroundColor3 = UmaLib.Themes[UmaLib.CurrentTheme].Border
            SectionLine.BorderSizePixel = 0
            SectionLine.Parent = SectionFrame
        end
        
        return Tab
    end
    
    -- Load saved configuration
    spawn(function()
        wait(1)
        LoadConfig()
    end)
    
    return Window
end

-- Notification System
function UmaLib:Notify(notifConfig)
    notifConfig = notifConfig or {}
    notifConfig.Title = notifConfig.Title or "Notification"
    notifConfig.Content = notifConfig.Content or ""
    notifConfig.Duration = notifConfig.Duration or 3
    notifConfig.Type = notifConfig.Type or "Info"
    
    local NotificationContainer = game:GetService("CoreGui"):FindFirstChild("UmaNotifications")
    if not NotificationContainer then
        NotificationContainer = Instance.new("ScreenGui")
        NotificationContainer.Name = "UmaNotifications"
        NotificationContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        NotificationContainer.DisplayOrder = 200
        
        if syn and syn.protect_gui then
            syn.protect_gui(NotificationContainer)
            NotificationContainer.Parent = CoreGui
        elseif gethui then
            NotificationContainer.Parent = gethui()
        else
            NotificationContainer.Parent = CoreGui
        end
        
        local Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.Size = UDim2.new(0, 300, 1, 0)
        Container.Position = UDim2.new(1, -310, 0, 10)
        Container.BackgroundTransparency = 1
        Container.Parent = NotificationContainer
        
        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = Container
    end
    
    local Container = NotificationContainer.Container
    
    local colors = {
        Info = self.Themes[self.CurrentTheme].Primary,
        Success = self.Themes[self.CurrentTheme].Success,
        Warning = self.Themes[self.CurrentTheme].Warning,
        Error = self.Themes[self.CurrentTheme].Error
    }
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 0)
    NotifFrame.BackgroundColor3 = self.Themes[self.CurrentTheme].Surface
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = Container
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 8)
    NotifCorner.Parent = NotifFrame
    
    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.BackgroundColor3 = colors[notifConfig.Type] or colors.Info
    Accent.BorderSizePixel = 0
    Accent.Parent = NotifFrame
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 8)
    AccentCorner.Parent = Accent
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = notifConfig.Title
    Title.TextColor3 = self.Themes[self.CurrentTheme].Text
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = NotifFrame
    
    local Content = Instance.new("TextLabel")
    Content.Size = UDim2.new(1, -20, 0, 0)
    Content.Position = UDim2.new(0, 15, 0, 30)
    Content.BackgroundTransparency = 1
    Content.Text = notifConfig.Content
    Content.TextColor3 = self.Themes[self.CurrentTheme].TextSecondary
    Content.TextSize = 12
    Content.Font = Enum.Font.Gotham
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextWrapped = true
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.Parent = NotifFrame
    
    wait()
    local contentHeight = Content.TextBounds.Y
    NotifFrame.Size = UDim2.new(1, 0, 0, contentHeight + 45)
    
    Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, contentHeight + 45)}, 0.3, Enum.EasingStyle.Back):Play()
    
    spawn(function()
        wait(notifConfig.Duration)
        Tween(NotifFrame, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3):Play()
        Tween(Title, {TextTransparency = 1}, 0.3):Play()
        Tween(Content, {TextTransparency = 1}, 0.3):Play()
        Tween(Accent, {BackgroundTransparency = 1}, 0.3):Play()
        wait(0.3)
        NotifFrame:Destroy()
    end)
end

-- Cleanup
function UmaLib:Destroy()
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    
    if game:GetService("CoreGui"):FindFirstChild("UmaUI") then
        game:GetService("CoreGui").UmaUI:Destroy()
    end
    
    if game:GetService("CoreGui"):FindFirstChild("UmaNotifications") then
        game:GetService("CoreGui").UmaNotifications:Destroy()
    end
end

return UmaLib
