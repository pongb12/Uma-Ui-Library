local UmaPlugins = {}

UmaPlugins.ColorPicker = {
    Initialize = function(core, parentTab)
        local colorSection = parentTab:Section("Color Settings")
        
        local currentColor = Color3.fromRGB(255, 255, 255)
        
        colorSection:Button("Pick Color", function()
            core:ShowColorPicker(function(newColor)
                currentColor = newColor
                print("Selected color:", newColor)
            end)
        end)
        
        return {
            GetCurrentColor = function()
                return currentColor
            end,
            SetColor = function(color)
                currentColor = color
            end
        }
    end
}

UmaPlugins.PresetManager = {
    Initialize = function(core, parentTab)
        local presets = {}
        
        local presetSection = parentTab:Section("Presets")
        
        presetSection:Button("Save Preset", function()
            local presetName = "preset_" .. os.time()
            presets[presetName] = core:ExportConfiguration()
            print("Preset saved:", presetName)
        end)
        
        presetSection:Button("Load Preset", function()
            for name, config in pairs(presets) do
                core:ImportConfiguration(config)
                print("Preset loaded:", name)
                break
            end
        end)
        
        return {
            SavePreset = function(name)
                presets[name] = core:ExportConfiguration()
            end,
            LoadPreset = function(name)
                if presets[name] then
                    core:ImportConfiguration(presets[name])
                end
            end,
            ListPresets = function()
                return presets
            end
        }
    end
}

return UmaPlugins
