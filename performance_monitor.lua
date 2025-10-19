local PerformanceMonitor = {
    Version = "3.0.0",
    Metrics = {
        RenderTime = 0,
        MemoryUsage = 0,
        ElementCount = 0,
        FPS = 0,
        LastUpdate = 0,
        PeakMemory = 0,
        AverageRenderTime = 0
    },
    UpdateInterval = 0.5,
    Initialized = false,
    Connections = setmetatable({}, {__mode = "v"}),
    MemoryHistory = {},
    FPSHistory = {},
    RenderHistory = {},
    MaxHistorySize = 120,
    AlertThresholds = {
        CriticalMemory = 400,
        WarningMemory = 250,
        CriticalFPS = 20,
        WarningFPS = 40
    }
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
    local renderTimes = {}
    local RunService = game:GetService("RunService")
    
    local connection = RunService.Heartbeat:Connect(function(deltaTime)
        frameCount = frameCount + 1
        local currentTime = tick()
        
        table.insert(renderTimes, deltaTime * 1000)
        if #renderTimes > 60 then
            table.remove(renderTimes, 1)
        end
        
        if currentTime - lastTime >= 1 then
            self.Metrics.FPS = frameCount
            frameCount = 0
            lastTime = currentTime
            
            self:UpdateHistory()
            self:CheckThresholds()
        end
        
        if currentTime - self.Metrics.LastUpdate >= self.UpdateInterval then
            self.Metrics.RenderTime = deltaTime * 1000
            self.Metrics.MemoryUsage = collectgarbage("count") / 1024
            self.Metrics.ElementCount = self:CountActiveElements()
            self.Metrics.LastUpdate = currentTime
            
            if self.Metrics.MemoryUsage > self.Metrics.PeakMemory then
                self.Metrics.PeakMemory = self.Metrics.MemoryUsage
            end
            
            local totalRender = 0
            for _, rt in ipairs(renderTimes) do
                totalRender = totalRender + rt
            end
            self.Metrics.AverageRenderTime = #renderTimes > 0 and (totalRender / #renderTimes) or 0
        end
    end)
    
    table.insert(self.Connections, connection)
end

function PerformanceMonitor:CheckThresholds()
    if not self.Core then return end
    
    if self.Metrics.MemoryUsage >= self.AlertThresholds.CriticalMemory then
        warn("🚨 CRITICAL: Memory usage", self.Metrics.MemoryUsage, "MB")
        if self.Core.PerformCleanup then
            self.Core:PerformCleanup()
        end
    elseif self.Metrics.MemoryUsage >= self.AlertThresholds.WarningMemory then
        warn("⚠️ WARNING: High memory usage", self.Metrics.MemoryUsage, "MB")
    end
    
    if self.Metrics.FPS <= self.AlertThresholds.CriticalFPS then
        warn("🚨 CRITICAL: Low FPS", self.Metrics.FPS)
    elseif self.Metrics.FPS <= self.AlertThresholds.WarningFPS then
        warn("⚠️ WARNING: FPS dropping", self.Metrics.FPS)
    end
end

function PerformanceMonitor:UpdateHistory()
    if #self.MemoryHistory >= self.MaxHistorySize then
        table.remove(self.MemoryHistory, 1)
    end
    table.insert(self.MemoryHistory, {
        value = self.Metrics.MemoryUsage,
        timestamp = os.time()
    })
    
    if #self.FPSHistory >= self.MaxHistorySize then
        table.remove(self.FPSHistory, 1)
    end
    table.insert(self.FPSHistory, {
        value = self.Metrics.FPS,
        timestamp = os.time()
    })
    
    if #self.RenderHistory >= self.MaxHistorySize then
        table.remove(self.RenderHistory, 1)
    end
    table.insert(self.RenderHistory, {
        value = self.Metrics.RenderTime,
        timestamp = os.time()
    })
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
        AverageRenderTime = math.floor(self.Metrics.AverageRenderTime * 100) / 100,
        MemoryUsage = math.floor(self.Metrics.MemoryUsage * 100) / 100,
        PeakMemory = math.floor(self.Metrics.PeakMemory * 100) / 100,
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
    metrics.MemoryTrend = self:CalculateTrend(self.MemoryHistory)
    metrics.FPSTrend = self:CalculateTrend(self.FPSHistory)
    
    return metrics
end

function PerformanceMonitor:CalculateTrend(history)
    if #history < 10 then return "Insufficient data" end
    
    local recent = {}
    for i = math.max(1, #history - 9), #history do
        table.insert(recent, history[i].value)
    end
    
    local sum = 0
    for _, v in ipairs(recent) do
        sum = sum + v
    end
    local avg = sum / #recent
    
    local currentAvg = (recent[#recent] + recent[#recent - 1]) / 2
    
    if currentAvg > avg * 1.1 then
        return "Increasing ↑"
    elseif currentAvg < avg * 0.9 then
        return "Decreasing ↓"
    else
        return "Stable →"
    end
end

function PerformanceMonitor:GetHealthReport()
    local metrics = self:GetMetrics()
    local report = {
        Status = "Excellent",
        Score = 100,
        Issues = {},
        Recommendations = {},
        Details = {}
    }
    
    if metrics.FPS < self.AlertThresholds.CriticalFPS then
        report.Status = "Critical"
        report.Score = math.max(0, report.Score - 40)
        table.insert(report.Issues, "Critical FPS: " .. metrics.FPS .. " (target: 60)")
        table.insert(report.Recommendations, "Close background applications")
        table.insert(report.Recommendations, "Reduce graphics quality")
    elseif metrics.FPS < self.AlertThresholds.WarningFPS then
        report.Status = "Warning"
        report.Score = math.max(0, report.Score - 20)
        table.insert(report.Issues, "Low FPS: " .. metrics.FPS)
        table.insert(report.Recommendations, "Optimize visual effects")
    end
    
    if metrics.MemoryUsage > self.AlertThresholds.CriticalMemory then
        report.Status = "Critical"
        report.Score = math.max(0, report.Score - 40)
        table.insert(report.Issues, "Critical memory: " .. metrics.MemoryUsage .. "MB")
        table.insert(report.Recommendations, "Run garbage collection")
        table.insert(report.Recommendations, "Clear object pools")
    elseif metrics.MemoryUsage > self.AlertThresholds.WarningMemory then
        if report.Status == "Excellent" then
            report.Status = "Warning"
        end
        report.Score = math.max(0, report.Score - 15)
        table.insert(report.Issues, "High memory: " .. metrics.MemoryUsage .. "MB")
        table.insert(report.Recommendations, "Monitor memory usage")
    end
    
    if metrics.RenderTime > 16.67 then
        report.Score = math.max(0, report.Score - 10)
        table.insert(report.Issues, "High render time: " .. metrics.RenderTime .. "ms")
        table.insert(report.Recommendations, "Reduce active elements")
    end
    
    if metrics.ElementCount > 150 then
        report.Score = math.max(0, report.Score - 10)
        table.insert(report.Issues, "High element count: " .. metrics.ElementCount)
        table.insert(report.Recommendations, "Use lazy rendering")
    end
    
    report.Details = {
        FPS = metrics.FPS,
        Memory = metrics.MemoryUsage,
        PeakMemory = metrics.PeakMemory,
        RenderTime = metrics.RenderTime,
        Elements = metrics.ElementCount,
        MemoryTrend = self:CalculateTrend(self.MemoryHistory),
        FPSTrend = self:CalculateTrend(self.FPSHistory)
    }
    
    if #report.Issues == 0 then
        table.insert(report.Issues, "All systems optimal")
        table.insert(report.Recommendations, "Performance is excellent")
    end
    
    return report
end

function PerformanceMonitor:CreatePerformanceTab(window)
    if not window or not window.Tab then
        warn("Invalid window object")
        return nil
    end
    
    local perfTab = window:Tab("Performance")
    
    perfTab:Section("Live Metrics")
    
    local fpsLabel = perfTab:Label("FPS: --")
    local memoryLabel = perfTab:Label("Memory: -- MB")
    local renderLabel = perfTab:Label("Render: -- ms")
    local elementsLabel = perfTab:Label("Elements: --")
    local peakMemLabel = perfTab:Label("Peak Memory: -- MB")
    
    local RunService = game:GetService("RunService")
    local lastUpdate = 0
    
    local connection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdate >= 1 then
            local metrics = self:GetMetrics()
            
            pcall(function()
                local fpsIcon = metrics.FPS >= 50 and "✓" or metrics.FPS >= 30 and "⚠" or "✗"
                fpsLabel:Set(string.format("FPS: %d %s", metrics.FPS, fpsIcon))
                
                local memIcon = metrics.MemoryUsage < 250 and "✓" or metrics.MemoryUsage < 400 and "⚠" or "✗"
                memoryLabel:Set(string.format("Memory: %.2f MB %s", metrics.MemoryUsage, memIcon))
                
                renderLabel:Set(string.format("Render: %.2f ms (Avg: %.2f)", metrics.RenderTime, metrics.AverageRenderTime))
                elementsLabel:Set(string.format("Elements: %d", metrics.ElementCount))
                peakMemLabel:Set(string.format("Peak Memory: %.2f MB", metrics.PeakMemory))
            end)
            
            lastUpdate = currentTime
        end
    end)
    
    table.insert(self.Connections, connection)
    
    perfTab:Section("Optimization")
    
    perfTab:Button("Collect Garbage", function()
        local before = collectgarbage("count")
        collectgarbage("collect")
        task.wait(0.1)
        local after = collectgarbage("count")
        local freed = (before - after) / 1024
        
        print(string.format("GC: %.2f MB freed", freed))
        window:Notify("Performance", string.format("Freed %.2f MB", freed), 3)
    end)
    
    perfTab:Button("Clear Pools", function()
        if self.Core and self.Core.PerformCleanup then
            self.Core:PerformCleanup()
            window:Notify("Performance", "Pools cleared", 3)
        end
    end)
    
    perfTab:Button("Reset Peak Memory", function()
        self.Metrics.PeakMemory = self.Metrics.MemoryUsage
        window:Notify("Performance", "Peak memory reset", 2)
    end)
    
    perfTab:Button("Generate Report", function()
        local report = self:GetHealthReport()
        print("=== Performance Report ===")
        print("Status:", report.Status)
        print("Score:", report.Score .. "/100")
        print("\nIssues:")
        for _, issue in ipairs(report.Issues) do
            print("  •", issue)
        end
        print("\nRecommendations:")
        for _, rec in ipairs(report.Recommendations) do
            print("  •", rec)
        end
        print("\nDetails:")
        print("  FPS:", report.Details.FPS, "-", report.Details.FPSTrend)
        print("  Memory:", report.Details.Memory, "MB -", report.Details.MemoryTrend)
        print("  Peak Memory:", report.Details.PeakMemory, "MB")
        print("========================")
        
        window:Notify("Report", "Status: " .. report.Status .. " (" .. report.Score .. "/100)", 5)
    end)
    
    perfTab:Section("Settings")
    
    perfTab:Slider("Update Rate", 0.1, 2, self.UpdateInterval, function(value)
        self:SetUpdateInterval(value)
    end, "s")
    
    perfTab:Slider("History Size", 30, 300, self.MaxHistorySize, function(value)
        self.MaxHistorySize = math.floor(value)
    end, " samples")
    
    perfTab:Toggle("Auto Cleanup", false, function(enabled)
        if enabled and self.Core then
            task.spawn(function()
                while enabled do
                    task.wait(60)
                    if self.Metrics.MemoryUsage > 200 then
                        self.Core:PerformCleanup()
                        collectgarbage("collect")
                    end
                end
            end)
        end
    end)
    
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
        LastUpdate = 0,
        PeakMemory = 0,
        AverageRenderTime = 0
    }
    self.MemoryHistory = {}
    self.FPSHistory = {}
    self.RenderHistory = {}
end

function PerformanceMonitor:Destroy()
    for _, connection in pairs(self.Connections) do
        pcall(function()
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end)
    end
    
    self.Connections = setmetatable({}, {__mode = "v"})
    self.Initialized = false
end

function PerformanceMonitor:ExportMetrics()
    return {
        CurrentMetrics = self:GetMetrics(),
        DetailedMetrics = self:GetDetailedMetrics(),
        HealthReport = self:GetHealthReport(),
        History = {
            Memory = self.MemoryHistory,
            FPS = self.FPSHistory,
            Render = self.RenderHistory
        },
        Timestamp = os.time(),
        Version = self.Version
    }
end

return PerformanceMonitor
