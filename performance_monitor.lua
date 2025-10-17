local PerformanceMonitor = {
    Metrics = {
        RenderTime = 0,
        MemoryUsage = 0,
        ElementCount = 0,
        FPS = 0,
        LastUpdate = 0
    },
    UpdateInterval = 0.5,
    Initialized = false,
    Connections = {}
}

function PerformanceMonitor:Initialize(core)
    if self.Initialized then
        warn("PerformanceMonitor already initialized")
        return self
    end
    
    if not core then
        warn("PerformanceMonitor: Core is required")
        return nil
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
    
    local connection = RunService.Heartbeat:Connect(function(deltaTime)
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
    
    table.insert(self.Connections, connection)
end

function PerformanceMonitor:CountActiveElements()
    if not self.Core or not self.Core.Performance or not self.Core.Performance.ObjectPool then
        return 0
    end
    
    local count = 0
    for _, pool in pairs(self.Core.Performance.ObjectPool) do
        if pool and type(pool) == "table" and pool.Active and type(pool.Active) == "table" then
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
            if pool and type(pool) == "table" then
                poolStats[elementType] = {
                    Active = 0,
                    Inactive = 0
                }
                
                if pool.Active and type(pool.Active) == "table" then
                    for _ in pairs(pool.Active) do
                        poolStats[elementType].Active = poolStats[elementType].Active + 1
                    end
                end
                
                if pool.Inactive and type(pool.Inactive) == "table" then
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
    local connection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdate >= 1 then
            local currentMetrics = self:GetMetrics()
            
            pcall(function()
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
            end)
            
            lastUpdate = currentTime
        end
    end)
    
    table.insert(self.Connections, connection)
    
    perfTab:Section("Optimization")
    
    perfTab:Button("Collect Garbage", function()
        local beforeMem = collectgarbage("count")
        collectgarbage("collect")
        local afterMem = collectgarbage("count")
        local freed = math.floor((beforeMem - afterMem) / 1024 * 100) / 100
        
        print(string.format("Garbage collected: %.2f MB freed", freed))
        window:Notify("Performance", string.format("Freed %.2f MB", freed), 3)
    end)
    
    perfTab:Button("Clear Unused Pools", function()
        if self.Core and self.Core.Performance and self.Core.Performance.ObjectPool then
            local cleared = 0
            for _, pool in pairs(self.Core.Performance.ObjectPool) do
                if pool and pool.Inactive then
                    cleared = cleared + #pool.Inactive
                    for _, instance in ipairs(pool.Inactive) do
                        pcall(function()
                            instance:Destroy()
                        end)
                    end
                    pool.Inactive = {}
                end
            end
            print("Cleared", cleared, "pooled objects")
            window:Notify("Performance", "Cleared " .. cleared .. " pooled objects", 3)
        end
    end)
    
    perfTab:Button("Reset Metrics", function()
        self:Reset()
        window:Notify("Performance", "Metrics reset", 2)
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
    
    perfTab:Section("Settings")
    
    perfTab:Slider("Update Interval", 0.1, 2, self.UpdateInterval, function(value)
        self:SetUpdateInterval(value)
    end, "s")
    
    return perfTab
end

function PerformanceMonitor:SetUpdateInterval(interval)
    self.UpdateInterval = math.max(0.1, math.min(interval or 0.5, 5))
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

function PerformanceMonitor:Destroy()
    for _, connection in ipairs(self.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    self.Connections = {}
    self.Initialized = false
end

function PerformanceMonitor:GetHealthReport()
    local metrics = self:GetMetrics()
    local report = {
        Status = "Good",
        Issues = {},
        Recommendations = {}
    }
    
    if metrics.FPS < 30 then
        report.Status = "Poor"
        table.insert(report.Issues, "Low FPS detected")
        table.insert(report.Recommendations, "Consider reducing visual effects or clearing unused objects")
    elseif metrics.FPS < 50 then
        report.Status = "Fair"
        table.insert(report.Issues, "FPS could be better")
    end
    
    if metrics.MemoryUsage > 500 then
        report.Status = "Poor"
        table.insert(report.Issues, "High memory usage detected")
        table.insert(report.Recommendations, "Run garbage collection and clear unused pools")
    elseif metrics.MemoryUsage > 250 then
        if report.Status == "Good" then
            report.Status = "Fair"
        end
        table.insert(report.Issues, "Moderate memory usage")
    end
    
    if metrics.RenderTime > 16.67 then
        if report.Status == "Good" then
            report.Status = "Fair"
        end
        table.insert(report.Issues, "High render time (>16ms)")
        table.insert(report.Recommendations, "Optimize rendering or reduce active elements")
    end
    
    if metrics.ElementCount > 100 then
        table.insert(report.Issues, "Many active UI elements")
        table.insert(report.Recommendations, "Consider using object pooling more effectively")
    end
    
    return report
end

return PerformanceMonitor
