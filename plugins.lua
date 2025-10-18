local UmaPlugins = {}

UmaPlugins.ColorPicker = {
    Name = "ColorPicker",
    Version = "1.1.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("ColorPicker: Invalid parameters")
            return nil
        end
        
        local colorSection = parentTab:Section("Color Settings")
        
        local currentColor = Color3.fromRGB(255, 255, 255)
        
        colorSection:Button("Pick Color", function()
            if core.ShowColorPicker then
                core:ShowColorPicker(function(newColor)
                    currentColor = newColor
                    print("Selected color:", newColor)
                    
                    if core.Events and core.Events.OnElementCreated then
                        core.Events.OnElementCreated:Fire("ColorChanged", newColor)
                    end
                end)
            else
                warn("Color picker not available")
            end
        end)
        
        colorSection:Button("Random Color", function()
            local r = math.random(0, 255)
            local g = math.random(0, 255)
            local b = math.random(0, 255)
            currentColor = Color3.fromRGB(r, g, b)
            print("Random color:", currentColor)
        end)
        
        colorSection:Section("Preset Colors")
        
        local presetColors = {
            {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
            {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
            {Name = "Blue", Color = Color3.fromRGB(0, 0, 255)},
            {Name = "White", Color = Color3.fromRGB(255, 255, 255)},
            {Name = "Black", Color = Color3.fromRGB(0, 0, 0)},
            {Name = "Yellow", Color = Color3.fromRGB(255, 255, 0)},
            {Name = "Cyan", Color = Color3.fromRGB(0, 255, 255)},
            {Name = "Magenta", Color = Color3.fromRGB(255, 0, 255)}
        }
        
        for _, preset in ipairs(presetColors) do
            colorSection:Button(preset.Name, function()
                currentColor = preset.Color
                print("Selected preset:", preset.Name, currentColor)
            end)
        end
        
        return {
            GetCurrentColor = function()
                return currentColor
            end,
            SetColor = function(color)
                if typeof(color) == "Color3" then
                    currentColor = color
                else
                    warn("Invalid color type")
                end
            end,
            GetColorRGB = function()
                return {
                    R = math.floor(currentColor.R * 255),
                    G = math.floor(currentColor.G * 255),
                    B = math.floor(currentColor.B * 255)
                }
            end,
            GetColorHex = function()
                local rgb = {
                    R = math.floor(currentColor.R * 255),
                    G = math.floor(currentColor.G * 255),
                    B = math.floor(currentColor.B * 255)
                }
                return string.format("#%02X%02X%02X", rgb.R, rgb.G, rgb.B)
            end
        }
    end
}

UmaPlugins.PresetManager = {
    Name = "PresetManager",
    Version = "1.1.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("PresetManager: Invalid parameters")
            return nil
        end
        
        local presets = {}
        local currentPreset = nil
        local autoSaveEnabled = false
        local autoSaveInterval = 60
        local lastAutoSave = 0
        local isSaving = false
        local customPresetName = ""
        
        local presetSection = parentTab:Section("Preset Manager")
        
        presetSection:Input("Preset Name", "", function(text)
            customPresetName = text
        end, "Enter preset name...")
        
        presetSection:Button("Save Preset", function()
            if isSaving then
                print("Already saving, please wait...")
                return
            end
            
            isSaving = true
            
            task.spawn(function()
                local presetName = customPresetName ~= "" and customPresetName or "preset_" .. os.time()
                
                if core.ExportConfiguration then
                    local config = core:ExportConfiguration()
                    presets[presetName] = {
                        Name = presetName,
                        Config = config,
                        Timestamp = os.time(),
                        Date = os.date("%Y-%m-%d %H:%M:%S"),
                        Device = core.Device
                    }
                    print("Preset saved:", presetName)
                    
                    if core.Notify then
                        core:Notify({
                            Title = "Preset Manager",
                            Content = "Preset '" .. presetName .. "' saved",
                            Duration = 3
                        })
                    end
                else
                    warn("ExportConfiguration not found")
                end
                
                task.wait(0.5)
                isSaving = false
            end)
        end)
        
        presetSection:Button("Load Latest", function()
            local latestPreset = nil
            local latestTime = 0
            
            for name, preset in pairs(presets) do
                if preset.Timestamp > latestTime then
                    latestTime = preset.Timestamp
                    latestPreset = preset
                end
            end
            
            if latestPreset then
                if core.ImportConfiguration then
                    core:ImportConfiguration(latestPreset.Config)
                    currentPreset = latestPreset.Name
                    print("Preset loaded:", latestPreset.Name)
                    
                    if core.Notify then
                        core:Notify({
                            Title = "Preset Manager",
                            Content = "Loaded: " .. latestPreset.Name,
                            Duration = 3
                        })
                    end
                end
            else
                print("No presets available")
                if core.Notify then
                    core:Notify({
                        Title = "Preset Manager",
                        Content = "No presets available",
                        Duration = 3
                    })
                end
            end
        end)
        
        presetSection:Button("Delete All", function()
            local count = 0
            for _ in pairs(presets) do
                count = count + 1
            end
            
            presets = {}
            currentPreset = nil
            
            print("Deleted", count, "presets")
            if core.Notify then
                core:Notify({
                    Title = "Preset Manager",
                    Content = "Deleted " .. count .. " presets",
                    Duration = 3
                })
            end
        end)
        
        presetSection:Button("List Presets", function()
            print("=== Available Presets ===")
            local count = 0
            for name, preset in pairs(presets) do
                count = count + 1
                local deviceInfo = preset.Device and 
                    (preset.Device.IsMobile and "📱" or preset.Device.IsTablet and "📋" or "💻") or "?"
                print(string.format("%d. %s %s (Saved: %s)", count, deviceInfo, preset.Name, preset.Date))
            end
            if count == 0 then
                print("No presets available")
            end
            print("========================")
        end)
        
        presetSection:Section("Auto-Save")
        
        presetSection:Toggle("Enable Auto-Save", false, function(enabled)
            autoSaveEnabled = enabled
            if enabled then
                print("Auto-save enabled (every", autoSaveInterval, "seconds)")
            else
                print("Auto-save disabled")
            end
        end)
        
        presetSection:Slider("Interval", 10, 300, autoSaveInterval, function(value)
            autoSaveInterval = math.floor(value)
        end, "s")
        
        task.spawn(function()
            local RunService = game:GetService("RunService")
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if autoSaveEnabled and not isSaving then
                    local currentTime = tick()
                    if currentTime - lastAutoSave >= autoSaveInterval then
                        if core.AcquireLock then
                            core:AcquireLock("PresetAutoSave")
                        end
                        
                        isSaving = true
                        
                        task.spawn(function()
                            if core.ExportConfiguration then
                                local presetName = "autosave_" .. os.time()
                                local config = core:ExportConfiguration()
                                presets[presetName] = {
                                    Name = presetName,
                                    Config = config,
                                    Timestamp = os.time(),
                                    Date = os.date("%Y-%m-%d %H:%M:%S"),
                                    AutoSave = true,
                                    Device = core.Device
                                }
                                print("Auto-saved:", presetName)
                            end
                            
                            lastAutoSave = currentTime
                            task.wait(0.5)
                            isSaving = false
                            
                            if core.ReleaseLock then
                                core:ReleaseLock("PresetAutoSave")
                            end
                        end)
                    end
                end
            end)
        end)
        
        return {
            SavePreset = function(name)
                if not name or name == "" then
                    name = "preset_" .. os.time()
                end
                
                if isSaving then
                    return false
                end
                
                if core.ExportConfiguration then
                    presets[name] = {
                        Name = name,
                        Config = core:ExportConfiguration(),
                        Timestamp = os.time(),
                        Date = os.date("%Y-%m-%d %H:%M:%S"),
                        Device = core.Device
                    }
                    return true
                end
                return false
            end,
            
            LoadPreset = function(name)
                if presets[name] then
                    if core.ImportConfiguration then
                        core:ImportConfiguration(presets[name].Config)
                        currentPreset = name
                        return true
                    end
                end
                return false
            end,
            
            DeletePreset = function(name)
                if presets[name] then
                    presets[name] = nil
                    if currentPreset == name then
                        currentPreset = nil
                    end
                    return true
                end
                return false
            end,
            
            ListPresets = function()
                return presets
            end,
            
            GetCurrentPreset = function()
                return currentPreset
            end,
            
            ExportPreset = function(name)
                if presets[name] then
                    return presets[name]
                end
                return nil
            end,
            
            ImportPreset = function(presetData)
                if presetData and presetData.Name and presetData.Config then
                    presets[presetData.Name] = presetData
                    return true
                end
                return false
            end,
            
            CleanupOldAutoSaves = function(keepCount)
                keepCount = keepCount or 5
                local autoSaves = {}
                
                for name, preset in pairs(presets) do
                    if preset.AutoSave then
                        table.insert(autoSaves, preset)
                    end
                end
                
                table.sort(autoSaves, function(a, b)
                    return a.Timestamp > b.Timestamp
                end)
                
                local removed = 0
                for i = keepCount + 1, #autoSaves do
                    presets[autoSaves[i].Name] = nil
                    removed = removed + 1
                end
                
                return removed
            end
        }
    end
}

UmaPlugins.ThemeSwitcher = {
    Name = "ThemeSwitcher",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("ThemeSwitcher: Invalid parameters")
            return nil
        end
        
        local themeSection = parentTab:Section("Theme Switcher")
        
        themeSection:Button("Dark Theme", function()
            if core.ChangeTheme then
                core:ChangeTheme("Default")
            end
        end)
        
        themeSection:Button("Light Theme", function()
            if core.ChangeTheme then
                core:ChangeTheme("Light")
            end
        end)
        
        return {
            SetTheme = function(themeName)
                if core.ChangeTheme then
                    core:ChangeTheme(themeName)
                end
            end
        }
    end
}

UmaPlugins.ConfigIO = {
    Name = "ConfigIO",
    Version = "1.1.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("ConfigIO: Invalid parameters")
            return nil
        end
        
        local configSection = parentTab:Section("Configuration I/O")
        
        configSection:Button("Export to Clipboard", function()
            if core.ExportConfiguration then
                local config = core:ExportConfiguration()
                local HttpService = game:GetService("HttpService")
                
                local success, result = pcall(function()
                    return HttpService:JSONEncode(config)
                end)
                
                if success and result then
                    if setclipboard then
                        setclipboard(result)
                        print("Configuration exported to clipboard")
                        
                        if core.Notify then
                            core:Notify({
                                Title = "Config Export",
                                Content = "Copied to clipboard",
                                Duration = 3
                            })
                        end
                    else
                        warn("Clipboard not supported")
                        print("Config JSON:", result)
                    end
                else
                    warn("Failed to encode configuration")
                end
            end
        end)
        
        configSection:Button("Import from Clipboard", function()
            if getclipboard and core.ImportConfiguration then
                local success, config = pcall(function()
                    local HttpService = game:GetService("HttpService")
                    local clipboardData = getclipboard()
                    
                    if not clipboardData or clipboardData == "" then
                        error("Clipboard is empty")
                    end
                    
                    if #clipboardData > 100000 then
                        error("Clipboard data too large")
                    end
                    
                    local decoded = HttpService:JSONDecode(clipboardData)
                    
                    if type(decoded) ~= "table" then
                        error("Invalid config format")
                    end
                    
                    return decoded
                end)
                
                if success and config then
                    core:ImportConfiguration(config)
                    print("Configuration imported from clipboard")
                    
                    if core.Notify then
                        core:Notify({
                            Title = "Config Import",
                            Content = "Configuration imported",
                            Duration = 3
                        })
                    end
                else
                    warn("Failed to import:", config)
                    if core.Notify then
                        core:Notify({
                            Title = "Config Import",
                            Content = "Failed - Invalid data",
                            Duration = 3
                        })
                    end
                end
            else
                warn("Clipboard not supported")
            end
        end)
        
        configSection:Button("Save to File", function()
            if core.SaveConfiguration then
                core:SaveConfiguration()
                if core.Notify then
                    core:Notify({
                        Title = "Config",
                        Content = "Configuration saved to file",
                        Duration = 3
                    })
                end
            end
        end)
        
        configSection:Button("Load from File", function()
            if core.LoadConfiguration then
                core:LoadConfiguration()
                if core.Notify then
                    core:Notify({
                        Title = "Config",
                        Content = "Configuration loaded",
                        Duration = 3
                    })
                end
            end
        end)
        
        return {}
    end
}

UmaPlugins.DeviceInfo = {
    Name = "DeviceInfo",
    Version = "1.0.0",
    
    Initialize = function(core, parentTab)
        if not core or not parentTab then
            warn("DeviceInfo: Invalid parameters")
            return nil
        end
        
        local deviceSection = parentTab:Section("Device Information")
        
        local device = core.Device or {}
        
        local deviceType = device.IsMobile and "📱 Mobile" or 
                          device.IsTablet and "📋 Tablet" or 
                          "💻 Desktop"
        
        deviceSection:Label("Device: " .. deviceType)
        
        if device.ScreenSize then
            deviceSection:Label(string.format("Screen: %dx%d", 
                math.floor(device.ScreenSize.X), 
                math.floor(device.ScreenSize.Y)))
        end
        
        deviceSection:Label("Touch: " .. (device.TouchEnabled and "✓ Yes" or "✗ No"))
        
        deviceSection:Button("Refresh Info", function()
            if core.DetectDevice then
                core:DetectDevice()
                print("Device info refreshed")
            end
        end)
        
        deviceSection:Section("Performance")
        
        local memLabel = deviceSection:Label("Memory: Calculating...")
        local fpsLabel = deviceSection:Label("FPS: Calculating...")
        
        task.spawn(function()
            while task.wait(2) do
                local mem = math.floor(collectgarbage("count") / 1024 * 100) / 100
                local fps = 60
                
                if core.Performance and core.Performance.FPS then
                    fps = core.Performance.FPS
                end
                
                pcall(function()
                    memLabel:Set(string.format("Memory: %.2f MB", mem))
                    fpsLabel:Set(string.format("FPS: %d", fps))
                end)
            end
        end)
        
        return {}
    end
}

return UmaPlugins
