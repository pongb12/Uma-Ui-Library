# Uma UI Library - Change Log

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
- XOR encryption for configuration files
- Benchmark mode for performance monitoring

### New Features
- Fluent API: UI:Tab("Main"):Section("Combat"):Button("Attack", callback)
- Theme runtime switching: UI:Theme("Dark")
- Plugin system: UmaUI:RegisterPlugin() & UI:Use("Plugin")
- Event hooks: UI:On("OnThemeChanged", callback)
- Mobile responsive design auto-adjusts for small screens
- Zoom functionality with Ctrl+Scroll
- Keybind overlay with visual feedback
- Auto-save configuration every 5 seconds
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

## Version 1.0.0 (2025-10-16)
### Initial Release
- Forked from Rayfield Interface Suite
- Updated default color scheme to dark blue
- Basic UI elements (Button, Toggle, Slider, Label)
- Simple configuration saving
- Notification system
- Tab system
