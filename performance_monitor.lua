local PerformanceMonitor = {
    Metrics = {
        RenderTime = 0,
        MemoryUsage = 0,
        ElementCount = 0,
        FPS = 0,
        LastUpdate = 0
    },
    UpdateInterval = 0.5,
    Initialized = false
}

function PerformanceMonitor:Initialize(core)
    if self.Initialized then
        warn("PerformanceMonitor already initialized")
        return
    end
    
    self.Core = core
    self.Initialized = true
    self:StartMonitoring()
    
    return self
end

function PerformanceMonitor:StartMonitoring()
    if not self.Core then
        warn("PerformanceMonitor: Core not found")
        return
    end
    
    local frameCount = 0
    local lastTime = tick()
    local RunService = game:GetService("RunService")
    
    RunService.Heartbeat:Connect(function(deltaTime)
        frameCount = frameCount + 1
        local currentTime = tick()
        

        if currentTime - lastTime >= 1 then
            self.Metrics.FPS = frameCount
            frameCount = 0
            lastTime = currentTime
        end
        

        if currentTime - self.Metrics.LastUpdate >= self.UpdateInterval then
            self.Metrics.RenderTime = deltaTime * 1000
            self.Metrics.MemoryUsage = collectgarbage("count") / 1024 
            self.Metrics.ElementCount = self:CountActiveElements()
            self.Metrics.LastUpdate = currentTime
        end
    end)
end

function PerformanceMonitor:CountActiveElements()
    if not self.Core or not self.Core.Performance or not self.Core.Performance.ObjectPool then
        return 0
    end
    
    local count = 0
    for _, pool in pairs(self.Core.Performance.ObjectPool) do
        if pool and pool.Active then
            for _ in pairs(pool.Active) do
                count = count + 1
            end
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

function PerformanceMonitor:GetDetailedMetrics()
    local metrics = self:GetMetrics()
    

    local poolStats = {}
    if self.Core and self.Core.Performance and self.Core.Performance.ObjectPool then
        for elementType, pool in pairs(self.Core.Performance.ObjectPool) do
            if pool then
                poolStats[elementType] = {
                    Active = 0,
                    Inactive = 0
                }
                
                if pool.Active then
                    for _ in pairs(pool.Active) do
                        poolStats[elementType].Active = poolStats[elementType].Active + 1
                    end
                end
                
                if pool.Inactive then
                    poolStats[elementType].Inactive = #pool.Inactive
                end
            end
        end
    end
    
    metrics.PoolStats = poolStats
    return metrics
end

function PerformanceMonitor:CreatePerformanceTab(window)
    if not window or not window.Tab then
        warn("Invalid window object provided to CreatePerformanceTab")
        return nil
    end
    
    local perfTab = window:Tab("Performance", "")
    
    perfTab:Section("Live Metrics")
    
    local fpsLabel = perfTab:Label("FPS: --")
    local memoryLabel = perfTab:Label("Memory: -- MB")
    local renderLabel = perfTab:Label("Render Time: -- ms")
    local elementsLabel = perfTab:Label("Active Elements: --")
    
    local RunService = game:GetService("RunService")
    

    local lastUpdate = 0
    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdate >= 1 then
            local currentMetrics = self:GetMetrics()
            
            if fpsLabel and fpsLabel.Set then
                fpsLabel:Set("FPS: " .. currentMetrics.FPS)
            end
            
            if memoryLabel and memoryLabel.Set then
                memoryLabel:Set("Memory: " .. currentMetrics.MemoryUsage .. " MB")
            end
            
            if renderLabel and renderLabel.Set then
                renderLabel:Set("Render Time: " .. currentMetrics.RenderTime .. " ms")
            end
            
            if elementsLabel and elementsLabel.Set then
                elementsLabel:Set("Active Elements: " .. currentMetrics.ElementCount)
            end
            
            lastUpdate = currentTime
        end
    end)
    

    perfTab:Section("Optimization")
    
    perfTab:Button("Collect Garbage", function()
        collectgarbage("collect")
        window:Notify("Performance", "Garbage collection completed", 3)
    end)
    
    perfTab:Button("Clear Unused Pools", function()
        if self.Core and self.Core.Performance and self.Core.Performance.ObjectPool then
            local cleared = 0
            for _, pool in pairs(self.Core.Performance.ObjectPool) do
                if pool and pool.Inactive then
                    cleared = cleared + #pool.Inactive
                    pool.Inactive = {}
                end
            end
            window:Notify("Performance", "Cleared " .. cleared .. " pooled objects", 3)
        end
    end)
    
    perfTab:Toggle("Show Detailed Stats", false, function(enabled)
        if enabled then
            local detailed = self:GetDetailedMetrics()
            print("=== Detailed Performance Stats ===")
            print("FPS:", detailed.FPS)
            print("Memory:", detailed.MemoryUsage, "MB")
            print("Render Time:", detailed.RenderTime, "ms")
            print("Active Elements:", detailed.ElementCount)
            print("\nPool Statistics:")
            for elementType, stats in pairs(detailed.PoolStats) do
                print(string.format("  %s: %d active, %d pooled", elementType, stats.Active, stats.Inactive))
            end
            print("================================")
        end
    end)
    
    return perfTab
end

function PerformanceMonitor:SetUpdateInterval(interval)
    self.UpdateInterval = math.max(0.1, interval or 0.5)
end

function PerformanceMonitor:GetFPS()
    return self.Metrics.FPS
end

function PerformanceMonitor:GetMemoryUsage()
    return self.Metrics.MemoryUsage
end

function PerformanceMonitor:Reset()
    self.Metrics = {
        RenderTime = 0,
        MemoryUsage = 0,
        ElementCount = 0,
        FPS = 0,
        LastUpdate = 0
    }
end

return PerformanceMonitor
