# Uma UI Library - Change Log

## Version 2.0.1 (2025-10-17)
### Critical Fixes
- Fixed deprecated Roblox API calls (wait -> task.wait, spawn -> task.spawn, unpack -> table.unpack)
- Fixed Font enum usage (string to Enum.Font.Gotham)
- Added nil safety checks throughout codebase
- Fixed FirstTab initialization bug
- Fixed tab switching with proper MouseButton1Click events
- Fixed memory leak in old UI cleanup

### New Elements
- Input element with placeholder support
- Dropdown element with dynamic options list
- Improved Label with Set() method for dynamic updates

### Performance Improvements
- Optimized PerformanceMonitor update interval (0.5s instead of per-frame)
- Memory usage now correctly displayed in MB
- Added detailed metrics with pool statistics
- Garbage collection and pool cleanup utilities
- Better resource cleanup on destroy

### Enhanced Plugins
- ColorPicker: Added preset colors, random color generator, hex color output
- PresetManager: Auto-save feature (60s interval), timestamp tracking, bulk delete, import/export
- ThemeSwitcher: Quick theme switching plugin
- ConfigIO: Export/import configurations via clipboard

### UI/UX Improvements
- Added window dragging functionality
- Improved slider with smooth mouse dragging
- Better keybind overlay with rounded corners
- Enhanced notification system
- Auto-load configuration 1 second after window creation

### API Additions
- Window:Toggle() - Show/hide UI
- Window:Destroy() - Cleanup and destroy UI
- Tab:Input() - Text input element
- Tab:Dropdown() - Dropdown selection element
- Label:Set() - Update label text dynamically
- UmaUI:ExportConfiguration() - Get current config as table
- UmaUI:ImportConfiguration() - Load config from table
- PerformanceMonitor:GetDetailedMetrics() - Extended performance data
- PerformanceMonitor:SetUpdateInterval() - Configure update frequency
- PerformanceMonitor:Reset() - Reset all metrics

### Breaking Changes
- Configuration files changed from .uma to .json extension
- Removed encryption/decryption functions
- Plugin.Initialize signature changed (added better error handling)

## Version 2.0.0 (2025-10-17)
### Major Enhancements
- Complete architectural redesign with modular system
- Fluent API for chainable syntax
- Advanced theme system with runtime switching
- Plugin support system
- Event hook system (OnThemeChanged, OnConfigLoaded, etc.)
- Object pooling for performance optimization
- Async callback system to prevent UI lag
- Mobile-responsive design with compact mode
- Accessibility features (zoom, high contrast, large fonts)
- Keybind overlay with ESC cancellation
- Multi-profile configuration system

### New Features
- Fluent API: UI:Tab("Main"):Section("Combat"):Button("Attack", callback)
- Theme runtime switching: UI:Theme("Dark")
- Plugin system: UmaUI:RegisterPlugin() & UI:Use("Plugin")
- Event hooks: UI:On("ThemeChanged", callback)
- Mobile responsive design auto-adjusts for small screens
- Zoom functionality with Ctrl+Scroll
- Keybind overlay with visual feedback
- Multi-profile configuration support
- Safe mode with protected callbacks

### Performance Improvements
- Lazy rendering of UI elements
- Object pooling for element reuse
- Async callbacks to prevent UI freeze
- Reduced memory footprint
- Optimized animation system

### Theme System
- Default dark blue theme
- Light theme included
- Custom theme creation support
- Runtime theme switching
- High contrast mode

## Version 1.0.0 (2025-10-14)
### Initial Release
- Forked from Rayfield Interface Suite
- Updated default color scheme to dark blue
- Basic UI elements (Button, Toggle, Slider, Label)
- Simple configuration saving
- Notification system
- Tab system
