local PerformanceMonitor = {
    Metrics = {
        RenderTime = 0,
        MemoryUsage = 0,
        ElementCount = 0,
        FPS = 0
    }
}

function PerformanceMonitor:Initialize(core)
    self.Core = core
    self:StartMonitoring()
end

function PerformanceMonitor:StartMonitoring()
    local frameCount = 0
    local lastTime = tick()
    
    self.Core.Services.RunService.Heartbeat:Connect(function(deltaTime)
        frameCount = frameCount + 1
        local currentTime = tick()
        
        if currentTime - lastTime >= 1 then
            self.Metrics.FPS = frameCount
            frameCount = 0
            lastTime = currentTime
        end
        
        self.Metrics.RenderTime = deltaTime * 1000
        self.Metrics.MemoryUsage = collectgarbage("count")
        self.Metrics.ElementCount = self:CountActiveElements()
    end)
end

function PerformanceMonitor:CountActiveElements()
    local count = 0
    for _, pool in pairs(self.Core.Performance.ObjectPool) do
        for _ in pairs(pool.Active) do
            count = count + 1
        end
    end
    return count
end

function PerformanceMonitor:GetMetrics()
    return {
        FPS = self.Metrics.FPS,
        RenderTime = math.floor(self.Metrics.RenderTime * 100) / 100,
        MemoryUsage = math.floor(self.Metrics.MemoryUsage * 100) / 100,
        ElementCount = self.Metrics.ElementCount
    }
end

function PerformanceMonitor:CreatePerformanceTab(ui)
    local perfTab = ui:Tab("Performance")
    
    local metrics = perfTab:Section("Live Metrics")
    
    local fpsLabel = metrics:Label("FPS: --")
    local memoryLabel = metrics:Label("Memory: -- MB")
    local renderLabel = metrics:Label("Render Time: -- ms")
    local elementsLabel = metrics:Label("Active Elements: --")
    
    self.Core.Services.RunService.Heartbeat:Connect(function()
        local currentMetrics = self:GetMetrics()
        fpsLabel:Set("FPS: " .. currentMetrics.FPS)
        memoryLabel:Set("Memory: " .. currentMetrics.MemoryUsage .. " MB")
        renderLabel:Set("Render Time: " .. currentMetrics.RenderTime .. " ms")
        elementsLabel:Set("Active Elements: " .. currentMetrics.ElementCount)
    end)
    
    return perfTab
end

return PerformanceMonitor
