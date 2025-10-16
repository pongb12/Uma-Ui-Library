local UmaUiLibrary = {
    Flags = {},
    Theme = {
        Default = {
            TextFont = "Default",
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
            PlaceholderColor = Color3.fromRGB(170, 170, 170)
        }
    }
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Release = "1.0"
local NotificationDuration = 6.5
local UmaFolder = "UmaUI"
local ConfigurationFolder = UmaFolder.."/Configurations"
local ConfigurationExtension = ".uma"

local Uma = game:GetObjects("rbxassetid://10804731440")[1]
Uma.Enabled = false

if gethui then
    Uma.Parent = gethui()
elseif syn.protect_gui then 
    syn.protect_gui(Uma)
    Uma.Parent = CoreGui
elseif CoreGui:FindFirstChild("RobloxGui") then
    Uma.Parent = CoreGui:FindFirstChild("RobloxGui")
else
    Uma.Parent = CoreGui
end

if gethui then
    for _, Interface in ipairs(gethui():GetChildren()) do
        if Interface.Name == Uma.Name and Interface ~= Uma then
            Interface.Enabled = false
            Interface.Name = "UmaUI-Old"
        end
    end
else
    for _, Interface in ipairs(CoreGui:GetChildren()) do
        if Interface.Name == Uma.Name and Interface ~= Uma then
            Interface.Enabled = false
            Interface.Name = "UmaUI-Old"
        end
    end
end

local Camera = workspace.CurrentCamera
local Main = Uma.Main
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList

Uma.DisplayOrder = 100
LoadingFrame.Version.Text = Release

local request = (syn and syn.request) or (http and http.request) or http_request
local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local Notifications = Uma.Notifications

local SelectedTheme = UmaUiLibrary.Theme.Default

function UmaUiLibrary:Notify(NotificationSettings)
    spawn(function()
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
                NewAction.BackgroundColor3 = SelectedTheme.NotificationActionsBackground
                if SelectedTheme ~= UmaUiLibrary.Theme.Default then
                    NewAction.TextColor3 = SelectedTheme.TextColor
                end
                NewAction.Name = Action.Name
                NewAction.Visible = true
                NewAction.Parent = Notification.Actions
                NewAction.Text = Action.Name
                NewAction.BackgroundTransparency = 1
                NewAction.TextTransparency = 1
                NewAction.Size = UDim2.new(0, NewAction.TextBounds.X + 27, 0, 36)

                NewAction.MouseButton1Click:Connect(function()
                    local Success, Response = pcall(Action.Callback)
                    if not Success then
                        print("UmaUI | Action Error: "..tostring(Response))
                    end
                    ActionCompleted = true
                end)
            end
        end

        Notification.BackgroundColor3 = SelectedTheme.Background
        Notification.Title.Text = NotificationSettings.Title or "Notification"
        Notification.Title.TextTransparency = 1
        Notification.Title.TextColor3 = SelectedTheme.TextColor
        Notification.Description.Text = NotificationSettings.Content or ""
        Notification.Description.TextTransparency = 1
        Notification.Description.TextColor3 = SelectedTheme.TextColor
        Notification.Icon.ImageColor3 = SelectedTheme.TextColor
        
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

        wait(0.3)
        TweenService:Create(Notification.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        TweenService:Create(Notification.Title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        TweenService:Create(Notification.Description, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.2}):Play()
        wait(0.2)

        if not NotificationSettings.Actions then
            wait(NotificationSettings.Duration or NotificationDuration - 0.5)
        else
            wait(0.8)
            TweenService:Create(Notification, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 295, 0, 132)}):Play()
            wait(0.3)
            for _, Action in ipairs(Notification.Actions:GetChildren()) do
                if Action.ClassName == "TextButton" and Action.Name ~= "Template" then
                    TweenService:Create(Action, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.2}):Play()
                    TweenService:Create(Action, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
                    wait(0.05)
                end
            end
        end

        repeat wait(0.001) until ActionCompleted

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
        
        wait(0.9)
        Notification:Destroy()
    end)
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
    end)

    if Settings.KeySystem then
        if not Settings.KeySettings then
            Passthrough = true
            return
        end

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

    if Settings.KeySystem then
        repeat wait() until Passthrough
    end

    Notifications.Template.Visible = false
    Notifications.Visible = true
    Uma.Enabled = true
    
    wait(0.5)
    TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {ImageTransparency = 0.55}):Play()
    wait(0.1)
    TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

    Elements.Template.LayoutOrder = 100000
    Elements.Template.Visible = false
    Elements.UIPageLayout.FillDirection = Enum.FillDirection.Horizontal
    TabList.Template.Visible = false

    local FirstTab = false
    local Window = {}
    
    function Window:CreateTab(Name, Image)
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
        if not FirstTab then
            Elements.UIPageLayout.Animated = false
            Elements.UIPageLayout:JumpTo(TabPage)
            Elements.UIPageLayout.Animated = true
        end

        local Tab = {}

        function Tab:CreateButton(ButtonSettings)
            local Button = Elements.Template.Button:Clone()
            Button.Name = ButtonSettings.Name
            Button.Title.Text = ButtonSettings.Name
            Button.Visible = true
            Button.Parent = TabPage

            Button.Interact.MouseButton1Click:Connect(function()
                local Success, Response = pcall(ButtonSettings.Callback)
                if not Success then
                    print("UmaUI | Button Error: "..tostring(Response))
                end
            end)

            return {}
        end

        function Tab:CreateToggle(ToggleSettings)
            local Toggle = Elements.Template.Toggle:Clone()
            Toggle.Name = ToggleSettings.Name
            Toggle.Title.Text = ToggleSettings.Name
            Toggle.Visible = true
            Toggle.Parent = TabPage

            Toggle.Interact.MouseButton1Click:Connect(function()
                ToggleSettings.CurrentValue = not ToggleSettings.CurrentValue
                
                if ToggleSettings.CurrentValue then
                    TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
                else
                    TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -40, 0.5, 0)}):Play()
                end

                local Success, Response = pcall(function()
                    ToggleSettings.Callback(ToggleSettings.CurrentValue)
                end)
                
                if not Success then
                    print("UmaUI | Toggle Error: "..tostring(Response))
                end
            end)

            function ToggleSettings:Set(Value)
                ToggleSettings.CurrentValue = Value
                if Value then
                    Toggle.Switch.Indicator.Position = UDim2.new(1, -20, 0.5, 0)
                else
                    Toggle.Switch.Indicator.Position = UDim2.new(1, -40, 0.5, 0)
                end
            end

            return ToggleSettings
        end

        function Tab:CreateSlider(SliderSettings)
            local Slider = Elements.Template.Slider:Clone()
            Slider.Name = SliderSettings.Name
            Slider.Title.Text = SliderSettings.Name
            Slider.Visible = true
            Slider.Parent = TabPage

            Slider.Main.Progress.Size = UDim2.new(0, Slider.Main.AbsoluteSize.X * (SliderSettings.CurrentValue / (SliderSettings.Range[2] - SliderSettings.Range[1])), 1, 0)
            Slider.Main.Information.Text = tostring(SliderSettings.CurrentValue) .. (SliderSettings.Suffix or "")

            return SliderSettings
        end

        function Tab:CreateLabel(LabelText)
            local Label = Elements.Template.Label:Clone()
            Label.Title.Text = LabelText
            Label.Visible = true
            Label.Parent = TabPage
            return {}
        end

        return Tab
    end

    wait(0.7)
    TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.2)
    TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 500, 0, 475)}):Play()

    Topbar.Visible = true
    TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Topbar.Title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

    return Window
end

function UmaUiLibrary:Destroy()
    Uma:Destroy()
end

return UmaUiLibrary
