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
    Connections = {},
    MemoryHistory = {},
    FPSHistory = {},
    MaxHistorySize = 60
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
            
            self:UpdateHistory()
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

function PerformanceMonitor:UpdateHistory()
    if #self.MemoryHistory >= self.MaxHistorySize then
        table.remove(self.MemoryHistory, 1)
    end
    table.insert(self.MemoryHistory, self.Metrics.MemoryUsage)
    
    if #self.FPSHistory >= self.MaxHistorySize then
        table.remove(self.FPSHistory, 1)
    end
    table.insert(self.FPSHistory, self.Metrics.FPS)
end

function PerformanceMonitor:CountActiveElements()
    if not self.Core or not self.Core.Performance or not self.Core.Performance.ObjectPool then
        return 0
    end
    
    local total = 0
    for _, pool in pairs(self.Core.Performance.ObjectPool) do
        if pool and type(pool) == "table" and pool.ActiveCount then
            total = total + pool.ActiveCount
        end
    end
    return total
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
                    Active = pool.ActiveCount or 0,
                    Inactive = #(pool.Inactive or {})
                }
            end
        end
    end
    
    metrics.PoolStats = poolStats
    metrics.MemoryHistory = self.MemoryHistory
    metrics.FPSHistory = self.FPSHistory
    
    return metrics
end

function PerformanceMonitor:GetMemoryChart()
    if #self.MemoryHistory == 0 then
        return "No data available"
    end
    
    local maxMem = math.max(table.unpack(self.MemoryHistory))
    local chart = "Memory Usage (MB)\n"
    
    for i = math.max(1, #self.MemoryHistory - 20), #self.MemoryHistory do
        local mem = self.MemoryHistory[i]
        local bars = math.floor((mem / maxMem) * 20)
        chart = chart .. string.format("%.1f |%s\n", mem, string.rep("█", bars))
    end
    
    return chart
end

function PerformanceMonitor:GetFPSChart()
    if #self.FPSHistory == 0 then
        return "No data available"
    end
    
    local maxFPS = math.max(table.unpack(self.FPSHistory))
    local chart = "FPS History\n"
    
    for i = math.max(1, #self.FPSHistory - 20), #self.FPSHistory do
        local fps = self.FPSHistory[i]
        local bars = math.floor((fps / maxFPS) * 20)
        chart = chart .. string.format("%3d |%s\n", fps, string.rep("█", bars))
    end
    
    return chart
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
                    local fpsColor = currentMetrics.FPS >= 50 and "✓" or currentMetrics.FPS >= 30 and "⚠" or "✗"
                    fpsLabel:Set(string.format("FPS: %d %s", currentMetrics.FPS, fpsColor))
                end
                
                if memoryLabel and memoryLabel.Set then
                    memoryLabel:Set(string.format("Memory: %.2f MB", currentMetrics.MemoryUsage))
                end
                
                if renderLabel and renderLabel.Set then
                    renderLabel:Set(string.format("Render: %.2f ms", currentMetrics.RenderTime))
                end
                
                if elementsLabel and elementsLabel.Set then
                    elementsLabel:Set(string.format("Elements: %d", currentMetrics.ElementCount))
                end
            end)
            
            lastUpdate = currentTime
        end
    end)
    
    table.insert(self.Connections, connection)
    
    perfTab:Section("Optimization Tools")
    
    perfTab:Button("Collect Garbage", function()
        local beforeMem = collectgarbage("count")
        collectgarbage("collect")
        task.wait(0.1)
        local afterMem = collectgarbage("count")
        local freed = math.floor((beforeMem - afterMem) / 1024 * 100) / 100
        
        print(string.format("Garbage collected: %.2f MB freed", freed))
        window:Notify("Performance", string.format("Freed %.2f MB", freed), 3)
    end)
    
    perfTab:Button("Clear Object Pools", function()
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
            window:Notify("Performance", "Cleared " .. cleared .. " objects", 3)
        end
    end)
    
    perfTab:Button("Reset Metrics", function()
        self:Reset()
        window:Notify("Performance", "Metrics reset", 2)
    end)
    
    perfTab:Button("Show Memory Chart", function()
        print(self:GetMemoryChart())
        window:Notify("Performance", "Memory chart in console", 3)
    end)
    
    perfTab:Button("Show FPS Chart", function()
        print(self:GetFPSChart())
        window:Notify("Performance", "FPS chart in console", 3)
    end)
    
    perfTab:Section("Health Report")
    
    perfTab:Button("Generate Report", function()
        local report = self:GetHealthReport()
        print("=== Performance Health Report ===")
        print("Status:", report.Status)
        print("\nIssues:")
        for _, issue in ipairs(report.Issues) do
            print("  •", issue)
        end
        print("\nRecommendations:")
        for _, rec in ipairs(report.Recommendations) do
            print("  •", rec)
        end
        print("================================")
        
        window:Notify("Health Report", "Status: " .. report.Status, 5)
    end)
    
    perfTab:Section("Settings")
    
    perfTab:Toggle("Detailed Logging", false, function(enabled)
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
    
    perfTab:Slider("Update Interval", 0.1, 2, self.UpdateInterval, function(value)
        self:SetUpdateInterval(value)
    end, "s")
    
    perfTab:Slider("History Size", 10, 120, self.MaxHistorySize, function(value)
        self.MaxHistorySize = math.floor(value)
    end, " samples")
    
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
    self.MemoryHistory = {}
    self.FPSHistory = {}
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
        report.Status = "Critical"
        table.insert(report.Issues, "Very low FPS detected (<30)")
        table.insert(report.Recommendations, "Close other applications or reduce graphics settings")
        table.insert(report.Recommendations, "Clear object pools and run garbage collection")
    elseif metrics.FPS < 50 then
        report.Status = report.Status == "Good" and "Fair" or report.Status
        table.insert(report.Issues, "Low FPS detected (<50)")
        table.insert(report.Recommendations, "Consider optimizing visual effects")
    end
    
    if metrics.MemoryUsage > 500 then
        report.Status = "Critical"
        table.insert(report.Issues, "Very high memory usage (>500MB)")
        table.insert(report.Recommendations, "Run garbage collection immediately")
        table.insert(report.Recommendations, "Clear unused object pools")
    elseif metrics.MemoryUsage > 250 then
        if report.Status == "Good" then
            report.Status = "Fair"
        end
        table.insert(report.Issues, "High memory usage (>250MB)")
        table.insert(report.Recommendations, "Monitor memory usage trends")
    end
    
    if metrics.RenderTime > 16.67 then
        if report.Status == "Good" then
            report.Status = "Fair"
        end
        table.insert(report.Issues, "High render time (>16ms, target 60 FPS)")
        table.insert(report.Recommendations, "Reduce number of active UI elements")
    end
    
    if metrics.ElementCount > 100 then
        table.insert(report.Issues, "High number of active elements (>100)")
        table.insert(report.Recommendations, "Use lazy rendering for off-screen elements")
    end
    
    local avgMemory = 0
    if #self.MemoryHistory > 0 then
        for _, mem in ipairs(self.MemoryHistory) do
            avgMemory = avgMemory + mem
        end
        avgMemory = avgMemory / #self.MemoryHistory
        
        if metrics.MemoryUsage > avgMemory * 1.5 then
            table.insert(report.Issues, "Memory usage spiking above average")
            table.insert(report.Recommendations, "Check for memory leaks")
        end
    end
    
    if #report.Issues == 0 then
        table.insert(report.Issues, "No issues detected - performance is optimal")
    end
    
    return report
end

function PerformanceMonitor:ExportMetrics()
    return {
        CurrentMetrics = self:GetMetrics(),
        DetailedMetrics = self:GetDetailedMetrics(),
        HealthReport = self:GetHealthReport(),
        Timestamp = os.time()
    }
end

return PerformanceMonitor
