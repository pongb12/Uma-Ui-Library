local Window = UmaUiLibrary:CreateWindow({
    Name = "My UI",
    LoadingTitle = "Uma UI Library",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "my_config"
    }
})

local Tab = Window:CreateTab("Main Tab")

local Toggle = Tab:CreateToggle({
    Name = "My Toggle",
    CurrentValue = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end
})

local Button = Tab:CreateButton({
    Name = "My Button",
    Callback = function()
        print("Button clicked!")
    end
})
