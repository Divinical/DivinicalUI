# DivinicalUI - WoW Addon Development Plan

## Addon Name: **DivinicalUI**

### Overview
A comprehensive World of Warcraft addon for Retail that provides custom unit frames and advanced targeting features, built to rival and surpass ElvUI with a focused, modern implementation.

---

## Development Phases

### Phase 1: Project Structure & Core Setup
1. Create addon folder structure in your working directory (will need to be copied to WoW later)
2. Set up TOC file with:
   - Interface version: 110205 (Retail 2025)
   - Metadata (Title, Author, Version, Notes)
   - SavedVariables for persistent settings
   - File load order
3. Create core initialization system with event handling
4. Set up namespace and global addon structure

### Phase 2: Configuration System
1. Implement **LibSettings** integration (modern WoW Settings API)
2. Create in-game configuration panel accessible via:
   - `/divinical` or `/div` slash commands
   - Blizzard's Settings menu
3. Set up SavedVariables system for:
   - Profile management (multiple profiles for specs/characters)
   - Import/Export functionality
   - Per-character and account-wide settings
4. Build settings categories:
   - Unit Frame settings (Player, Target, ToT, Focus, Pet, etc.)
   - Raid/Party frame settings
   - Appearance (colors, fonts, textures)
   - Advanced options

### Phase 3: Unit Frame System (Better than ElvUI)
**Using oUF framework as foundation** (industry standard, battle-tested)

1. Create custom oUF layout implementation
2. Implement ALL unit frames:
   - Player frame
   - Target frame
   - Target of Target (ToT)
   - Focus frame
   - Focus Target
   - Pet frame
   - Pet Target
   - Party frames (1-5)
   - Raid frames (1-40)
   - Arena frames (1-5)
   - Boss frames (1-5)
3. Advanced features:
   - Class power displays (combo points, soul shards, holy power, etc.)
   - Cast bars with interrupt tracking
   - Aura/buff/debuff tracking with filtering
   - Threat indicators
   - Range fading
   - Combat fade-in/fade-out
   - Portrait options (3D/2D/Class icons)
   - Health/Power prediction bars

### Phase 4: Targeting System
1. Smart targeting functions:
   - Quick target macros
   - Focus target management
   - Target marking (skull, cross, etc.)
   - Proximity targeting
   - Enemy priority targeting
2. Click-casting support (similar to Clique/Healbot)
3. Target cycling improvements

### Phase 5: Polish & Advanced Features
1. Performance optimization
2. Skin/theme system
3. Drag-and-drop frame positioning
4. Frame anchoring system
5. Testing and debugging tools
6. Documentation

---

## File Structure

```
DivinicalUI/
├── DivinicalUI.toc           # Table of Contents - required by WoW
├── Core.lua                  # Main initialization and event handling
├── Config/
│   ├── Config.lua           # Configuration framework
│   ├── Settings.lua         # Settings panel implementation
│   └── Profiles.lua         # Profile management system
├── Modules/
│   ├── UnitFrames.lua       # Unit frame implementation
│   ├── Targeting.lua        # Targeting system
│   └── Utils.lua            # Utility functions
├── Libs/
│   ├── oUF/                 # oUF framework (embedded)
│   └── LibSettings/         # Settings API library (embedded)
└── Media/
    ├── Textures/            # Custom textures for frames
    └── Fonts/               # Custom fonts
```

---

## Technical Details

### TOC File Format
```toc
## Interface: 110205
## Title: DivinicalUI
## Author: Divinical
## Version: 1.0.0
## Notes: Advanced unit frames and targeting system
## SavedVariables: DivinicalDB
## SavedVariablesPerCharacter: DivinicalCharDB
## OptionalDeps: oUF

# Libraries
Libs\oUF\oUF.xml
Libs\LibSettings\LibSettings.lua

# Core
Core.lua

# Configuration
Config\Config.lua
Config\Settings.lua
Config\Profiles.lua

# Modules
Modules\Utils.lua
Modules\UnitFrames.lua
Modules\Targeting.lua
```

### Core Addon Structure (Lua)
```lua
-- Namespace
local AddonName, DivinicalUI = ...

-- Local references
local _G = _G

-- Addon object
DivinicalUI.version = "1.0.0"
DivinicalUI.modules = {}

-- Event frame
local eventFrame = CreateFrame("Frame")
DivinicalUI.eventFrame = eventFrame

-- Initialization
function DivinicalUI:Initialize()
    -- Load saved variables
    -- Initialize modules
    -- Register events
    -- Setup slash commands
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if DivinicalUI[event] then
        DivinicalUI[event](DivinicalUI, ...)
    end
end)

-- Register core events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
```

---

## Installation Requirements

### What You Need:
- **No npm/bun needed** - Pure Lua/XML
- Text editor (VS Code with WoW Bundle extension recommended)
- WoW Retail client for testing
- Active WoW subscription (for testing)

### Development Workflow:
1. Create and edit files in current directory (`C:\Users\bboar\Desktop\DivinicalUI\`)
2. Test by copying to: `World of Warcraft\_retail_\Interface\AddOns\DivinicalUI\`
3. Launch WoW and test with `/reload` command
4. Debug using:
   - `/fstack` - Frame stack tool
   - `/tinspect` - Frame inspection
   - `/api` - API documentation browser
   - `/console scriptErrors 1` - Enable Lua error display

---

## Key Features (Advantages Over ElvUI)

### Performance:
- Focused scope (frames + targeting only, not entire UI overhaul)
- Modern 2025 WoW API implementation
- Optimized event handling
- Efficient memory usage

### User Experience:
- Integrated with Blizzard's native Settings panel
- Intuitive slash commands
- Drag-and-drop positioning
- Real-time preview of changes
- Profile import/export for easy sharing

### Customization:
- Granular control over every frame element
- Custom layouts per spec/role
- Advanced filtering options
- Theme support
- Addon skinning

### Code Quality:
- Modular architecture
- Well-documented
- Uses industry-standard oUF framework
- Clean separation of concerns
- Easy to extend

---

## Today's Development Focus

### Immediate Goals:
1. Create complete skeleton with:
   - TOC file configured for Retail 2025
   - Core initialization and event system
   - Basic namespace structure
   - Settings framework foundation
   - oUF integration setup
   - Sample player frame implementation

2. Deliverables:
   - Working addon that loads in WoW
   - Basic slash command (`/divinical`)
   - Simple player frame display
   - Foundation for future modules

---

## Resources & References

### Official Documentation:
- WoW API: `/api` command in-game
- Wowpedia: https://wowpedia.fandom.com/wiki/World_of_Warcraft_API
- Warcraft Wiki: https://warcraft.wiki.gg/

### oUF Framework:
- GitHub: https://github.com/oUF-wow/oUF
- CurseForge: https://www.curseforge.com/wow/addons/ouf

### Example Addons to Study:
- oUF_P3lim (clean, readable code)
- Shadowed Unit Frames
- ElvUI (for feature reference)

### Development Tools:
- VS Code Extension: "WoW Bundle"
- In-game: DevTool addon (optional)
- In-game: Spew addon (optional)

---

## Future Enhancements (Post-Launch)

- Action bar customization
- Minimap enhancements
- Nameplate customization
- Aura tracking/alerts
- Cooldown tracking
- Dungeon/Raid tools
- PvP utilities
- Integration with WeakAuras
- Custom media import (textures, fonts, sounds)

---

## Notes

- Frames CANNOT be deleted once created - design for reuse
- Secure frames required for combat actions
- Combat lockdown restrictions apply to certain frame modifications
- Test thoroughly in both combat and non-combat scenarios
- Consider different screen resolutions and UI scales
- Profile system should handle spec changes automatically

---

**Ready to build when you are!**
