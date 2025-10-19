local UmaPlugins = {
    Version = "3.0.0"
}

UmaPlugins.DeviceInfo = {
    Name = "DeviceInfo",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("DeviceInfo: Invalid parameters")
            return nil
        end
        
        parentTab:Section("Device Information")
        
        local device = core.Device or {}
        
        local deviceType = device.IsMobile and "📱 Mobile" or 
                          device.IsTablet and "📋 Tablet" or 
                          "💻 Desktop"
        
        parentTab:Label("Device: " .. deviceType)
        
        if device.ScreenSize then
            parentTab:Label(string.format("Screen: %dx%d", 
                math.floor(device.ScreenSize.X), 
                math.floor(device.ScreenSize.Y)))
        end
        
        parentTab:Label("Touch: " .. (device.TouchEnabled and "✓ Enabled" or "✗ Disabled"))
        
        parentTab:Button("Refresh Info", function()
            if core.DetectDevice then
                core:DetectDevice()
                print("Device info refreshed")
            end
        end)
        
        parentTab:Section("System Stats")
        
        local memLabel = parentTab:Label("Memory: Calculating...")
        local fpsLabel = parentTab:Label("FPS: Calculating...")
        local timeLabel = parentTab:Label("Uptime: 0s")
        
        local startTime = tick()
        
        task.spawn(function()
            while task.wait(2) do
                local mem = math.floor(collectgarbage("count") / 1024 * 100) / 100
                local fps = 60
                
                if core.Performance and core.Performance.FPS then
                    fps = core.Performance.FPS
                end
                
                local uptime = math.floor(tick() - startTime)
                
                pcall(function()
                    memLabel:Set(string.format("Memory: %.2f MB", mem))
                    fpsLabel:Set(string.format("FPS: %d", fps))
                    timeLabel:Set(string.format("Uptime: %ds", uptime))
                end)
            end
        end)
        
        return {}
    end
}

UmaPlugins.ConfigManager = {
    Name = "ConfigManager",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("ConfigManager: Invalid parameters")
            return nil
        end
        
        parentTab:Section("Configuration")
        
        parentTab:Button("Export to Clipboard", function()
            if setclipboard then
                local config = {
                    Version = core.Version,
                    SessionId = core.SessionId,
                    Device = core.Device,
                    Flags = core.Flags,
                    Timestamp = os.time()
                }
                
                local success, json = pcall(function()
                    return game:GetService("HttpService"):JSONEncode(config)
                end)
                
                if success then
                    setclipboard(json)
                    print("Config exported to clipboard")
                else
                    warn("Export failed:", json)
                end
            else
                warn("Clipboard not supported")
            end
        end)
        
        parentTab:Button("Import from Clipboard", function()
            if getclipboard then
                local success, config = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(getclipboard())
                end)
                
                if success and config and config.Flags then
                    for name, data in pairs(config.Flags) do
                        if core.Flags[name] and core.Flags[name].Set then
                            pcall(function()
                                core.Flags[name]:Set(data.CurrentValue or data)
                            end)
                        end
                    end
                    print("Config imported")
                else
                    warn("Import failed")
                end
            else
                warn("Clipboard not supported")
            end
        end)
        
        parentTab:Button("Reset All", function()
            for name, element in pairs(core.Flags) do
                if element and element.Set then
                    pcall(function()
                        if element.Type == "Toggle" then
                            element:Set(false)
                        elseif element.Type == "Slider" then
                            element:Set(element.Range and element.Range[1] or 0)
                        elseif element.Type == "Input" then
                            element:Set("")
                        end
                    end)
                end
            end
            print("All settings reset")
        end)
        
        return {}
    end
}

UmaPlugins.ErrorViewer = {
    Name = "ErrorViewer",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("ErrorViewer: Invalid parameters")
            return nil
        end
        
        local errors = {}
        local maxErrors = 50
        
        parentTab:Section("Error Tracking")
        
        local errorCount = parentTab:Label("Errors: 0")
        
        local originalTrack = core.TrackError
        core.TrackError = function(self, err, stack, location, severity)
            table.insert(errors, 1, {
                error = tostring(err),
                location = location,
                severity = severity,
                timestamp = os.time()
            })
            
            if #errors > maxErrors then
                table.remove(errors)
            end
            
            errorCount:Set(string.format("Errors: %d", #errors))
            
            return originalTrack(self, err, stack, location, severity)
        end
        
        parentTab:Button("View Errors", function()
            print("=== Recent Errors ===")
            for i, err in ipairs(errors) do
                if i > 10 then break end
                print(string.format("%d. [%s] %s (%s)", 
                    i, 
                    err.severity or "?", 
                    err.error:sub(1, 50), 
                    err.location or "Unknown"))
            end
            print("===================")
        end)
        
        parentTab:Button("Clear Errors", function()
            errors = {}
            errorCount:Set("Errors: 0")
            print("Error history cleared")
        end)
        
        parentTab:Toggle("Auto Report", false, function(enabled)
            core.Configuration.ErrorTracking = enabled
            print("Error tracking:", enabled and "ON" or "OFF")
        end)
        
        return {
            GetErrors = function()
                return errors
            end,
            ClearErrors = function()
                errors = {}
                errorCount:Set("Errors: 0")
            end
        }
    end
}

UmaPlugins.Shortcuts = {
    Name = "Shortcuts",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("Shortcuts: Invalid parameters")
            return nil
        end
        
        local shortcuts = {}
        
        parentTab:Section("Keyboard Shortcuts")
        
        parentTab:Label("Available Shortcuts:")
        parentTab:Label("• Ctrl+H: Toggle UI")
        parentTab:Label("• Ctrl+R: Reset Config")
        parentTab:Label("• Ctrl+C: Cleanup")
        
        local UserInputService = game:GetService("UserInputService")
        
        local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or 
                        UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            
            if ctrl then
                if input.KeyCode == Enum.KeyCode.H then
                    print("Toggle UI shortcut")
                elseif input.KeyCode == Enum.KeyCode.R then
                    print("Reset config shortcut")
                elseif input.KeyCode == Enum.KeyCode.C then
                    if core.PerformCleanup then
                        core:PerformCleanup()
                        collectgarbage("collect")
                        print("Cleanup performed")
                    end
                end
            end
        end)
        
        table.insert(core.Internal.EventConnections, connection)
        
        return {}
    end
}

UmaPlugins.ThemeCustomizer = {
    Name = "ThemeCustomizer",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("ThemeCustomizer: Invalid parameters")
            return nil
        end
        
        parentTab:Section("Theme Options")
        
        parentTab:Button("Dark Mode", function()
            if core.ApplyTheme then
                core:ApplyTheme({
                    TextColor = Color3.fromRGB(240, 240, 240),
                    Background = Color3.fromRGB(20, 20, 25),
                    Topbar = Color3.fromRGB(30, 30, 40),
                    ElementBackground = Color3.fromRGB(30, 30, 40)
                })
            end
        end)
        
        parentTab:Button("Light Mode", function()
            if core.ApplyTheme then
                core:ApplyTheme({
                    TextColor = Color3.fromRGB(50, 50, 50),
                    Background = Color3.fromRGB(245, 245, 245),
                    Topbar = Color3.fromRGB(230, 230, 230),
                    ElementBackground = Color3.fromRGB(255, 255, 255)
                })
            end
        end)
        
        parentTab:Button("OLED Black", function()
            if core.ApplyTheme then
                core:ApplyTheme({
                    TextColor = Color3.fromRGB(255, 255, 255),
                    Background = Color3.fromRGB(0, 0, 0),
                    Topbar = Color3.fromRGB(10, 10, 10),
                    ElementBackground = Color3.fromRGB(15, 15, 15)
                })
            end
        end)
        
        return {}
    end
}

UmaPlugins.QuickActions = {
    Name = "QuickActions",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("QuickActions: Invalid parameters")
            return nil
        end
        
        parentTab:Section("Quick Actions")
        
        parentTab:Button("🗑️ Full Cleanup", function()
            if core.PerformCleanup then
                core:PerformCleanup()
            end
            collectgarbage("collect")
            print("Full cleanup completed")
        end)
        
        parentTab:Button("📊 System Info", function()
            local mem = collectgarbage("count") / 1024
            local fps = core.Performance and core.Performance.FPS or 0
            
            print("=== System Info ===")
            print("Memory:", string.format("%.2f MB", mem))
            print("FPS:", fps)
            print("Version:", core.Version)
            print("Device:", core.Device.IsMobile and "Mobile" or "Desktop")
            print("=================")
        end)
        
        parentTab:Button("🔄 Restart UI", function()
            print("UI restart not implemented")
        end)
        
        parentTab:Button("💾 Emergency Save", function()
            print("Emergency save triggered")
        end)
        
        return {}
    end
}

return UmaPlugins
