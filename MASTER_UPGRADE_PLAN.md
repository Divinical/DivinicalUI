# DivinicalUI - Master Upgrade Plan to Best-in-Class (MIDNIGHT-COMPLIANT)
## The Ultimate WoW UI Addon - Complete Overhaul Strategy

> **Vision**: Create a WoW UI addon that combines ElvUI's polish, GW2UI's aesthetic beauty, and Bartender 4's functionality - while being lighter, faster, and more intuitive than all of them.

> **⚠️ UPDATED FOR MIDNIGHT**: This plan focuses on UI customization and visual presentation, fully compliant with Blizzard's new API restrictions that prevent combat automation.

---

## Executive Summary

After reviewing your codebase and researching the competition (ElvUI, GW2UI, Bartender 4), here's my assessment as a 15-year WoW addon veteran:

### ✅ What You've Built Well
- Solid modular architecture with clean separation of concerns
- Professional event-driven system
- Comprehensive utility libraries
- Smart targeting system with history
- Profile management foundation
- oUF integration started

### ❌ Critical Gaps vs. Competition
1. **Missing Media Assets** - No fonts, textures, or visual polish
2. **Incomplete oUF Implementation** - Framework referenced but not fully embedded
3. **Basic Settings Panel** - Lacks the deep customization users expect
4. **No Raid/Party Frames** - Critical feature for any serious UI addon
5. **No Action Bar System** - This will be your KILLER FEATURE
6. **No Visual Themes** - Competition offers multiple skins/themes
7. **Limited Nameplate Customization** - Essential for modern gameplay
8. **No Performance Monitoring** - Users want FPS/memory tracking
9. **Missing Import/Export** - Profile sharing is essential for community growth

---

## The Winning Strategy: "The Trinity Approach"

### 1. **Performance First** (Beat ElvUI)
- Target: < 3MB memory footprint
- < 0.5% CPU usage in combat
- Lazy loading for all non-critical modules
- Event throttling and batching
- Frame pooling and recycling

### 2. **Beauty Second** (Match GW2UI)
- Modern, clean aesthetic with multiple themes
- Smooth animations and transitions
- Professional texture work
- Class-colored everything (optional)
- Dark mode by default

### 3. **Customization Third** (Beat Bartender 4)
- Every pixel customizable
- Drag-and-drop everything
- Live preview of changes
- Preset layouts for common roles
- Easiest action bar setup in WoW

---

## ⚠️ Midnight API Changes - What This Means for DivinicalUI

### What Blizzard Confirmed
**✅ ALLOWED (Focus Here)**:
- All UI customization (frames, nameplates, action bars, panels)
- Visual presentation changes (styling, positioning, colors)
- Information display (showing combat data in custom ways)

**❌ RESTRICTED (Avoid)**:
- Real-time combat automation
- Automated decision-making during combat
- WeakAuras-style conditional logic for combat advantages

### Our Strategic Response
**Make Action Bars Your Killer Feature** - Bartender 4 hasn't been significantly updated in years, users find it confusing, and action bar customization is 100% Midnight-compliant. You can own this space.

---

## Phase 1: Foundation Fixes (Week 1-2)

### Priority 1.1: Complete oUF Integration
**Problem**: oUF is referenced but not fully functional

**Solution**:
```
Tasks:
□ Download and embed latest oUF framework (v11.x for TWW)
□ Include all oUF elements:
  - oUF.lua (core)
  - elements/ directory (health, power, auras, castbar, etc.)
  - Create oUF.xml that properly loads everything
□ Test oUF initialization in Core.lua
□ Verify all unit spawning works correctly
□ Add oUF element tags (dynamic text formatting)
□ Implement oUF element callbacks properly
```

**Why This Matters**: Without proper oUF, your unit frames will be buggy and limited. oUF is battle-tested and handles all the edge cases you'll miss.

### Priority 1.2: Create Professional Media Library
**Problem**: Missing fonts and textures makes UI look amateurish

**Solution**:
```
Media/
├── Fonts/
│   ├── Expressway.ttf         # Main UI font (clean, readable)
│   ├── PT_Sans_Narrow.ttf     # Numbers font (compact)
│   ├── Roadway.ttf            # Header font (bold)
│   └── SourceCodePro.ttf      # Monospace for debug
├── Textures/
│   ├── StatusBars/
│   │   ├── Aluminium.tga      # Default statusbar
│   │   ├── Gradient.tga       # Alternative
│   │   ├── Smooth.tga         # Clean look
│   │   └── Minimalistic.tga   # Flat design
│   ├── Borders/
│   │   ├── Glow.tga           # Glowing border
│   │   ├── Clean.tga          # Simple border
│   │   └── Shadow.tga         # Drop shadow
│   ├── Backdrops/
│   │   ├── Solid.tga          # Solid background
│   │   ├── Gradient.tga       # Gradient background
│   │   └── Transparent.tga    # Semi-transparent
│   └── Icons/
│       ├── Classes/           # Class icons (all 13 classes)
│       ├── Roles/             # Tank/Healer/DPS icons
│       └── Powers/            # Mana, rage, energy, etc.
└── Sounds/
    └── notification.ogg       # Alert sound
```

**Resources**:
- SharedMedia library integration (provides 100+ fonts/textures)
- Create custom textures in GIMP/Photoshop (256x32 TGA format)
- Use Blizzard's built-in textures as fallbacks

### Priority 1.3: Fix Settings Panel Implementation
**Problem**: Settings.lua is incomplete, Config.lua lacks actual UI

**Solution**:
```lua
-- Implement using Blizzard's modern Settings API (11.0+)
□ Create proper Settings canvas with AceGUI or custom frames
□ Category system:
  - General
  - Unit Frames (subcategories for each frame type)
  - Raid/Party
  - Nameplates
  - Action Bars
  - Themes
  - Profiles
  - Advanced
□ Each setting needs:
  - Clear label and tooltip
  - Instant preview (no /reload needed)
  - Reset to default button
  - Import/export button
□ Add search functionality (filter 3000+ options)
□ Add preset profiles (Tank, Healer, DPS, PvP)
```

---

## Phase 2: Core Features (Week 3-4)

### Priority 2.1: Complete Unit Frame System
**Current**: Only player and target frames
**Needed**: All 11 frame types

```
□ Player Frame
  - Health bar with prediction
  - Power bar with class-specific handling
  - Alternative power bar (boss encounters)
  - Class power display (combo points, soul shards, etc.)
  - Cast bar with spell icon and interrupt shield
  - Buffs/debuffs with filtering
  - Portrait (3D model, 2D texture, or class icon)
  - Combat indicator
  - Resting indicator
  - PvP icon
  - Role icon (tank/healer/dps)
  - Item level display
  - Combat text integration

□ Target Frame
  - All player frame features PLUS:
  - Enemy cast bar with interrupt detection
  - Threat meter
  - Quest icon
  - Classification (rare, elite, boss)
  - Enemy buffs/debuffs with expiration timers
  - Target of target frame (mini version)

□ Focus Frame
  - Clone of target frame but for focus target
  - Essential for arena/PvP
  - Focus target of target

□ Pet Frame
  - Health/power
  - Pet happiness (hunter)
  - Pet abilities cooldown tracker
  - Pet target frame

□ Party Frames (1-5 members)
  - Compact horizontal or vertical layout
  - Role icons
  - Health bars with incoming heals
  - Debuff highlighting (dispellable)
  - Range fading
  - Ready check icons
  - Resurrection indicators
  - Quick target on click
  - Mouse-over casting support (Clique/Healbot style)

□ Raid Frames (1-40 members)
  - Grid-style layout (8 groups x 5 members)
  - Role sorting (tanks -> healers -> dps)
  - Range-based opacity
  - Debuff highlighting with priority system
  - Incoming heals prediction
  - Health deficit mode
  - Threat coloring
  - Mana bars for healers
  - Group indicators
  - Raid icons (skull, cross, etc.)
  - Click-casting integration
  - Separate 10/20/40 man layouts

□ Arena Frames (1-5 opponents)
  - Trinket tracking
  - DR (diminishing returns) tracker
  - Spec detection
  - Cast bar with interrupt tracking

□ Boss Frames (1-5 bosses)
  - Large, prominent display
  - Important debuffs only
  - Cast bars for all bosses
  - Alternative power bars
  - Threat indicators

□ Target of Target
  - Mini frame showing target's target
  - Essential for tanking

□ Pet Target
  - Shows pet's target

□ Focus Target
  - Shows focus's target
```

**Key Differentiator**: Smart Filtering
- Automatic buff/debuff filtering based on:
  - Your class (show relevant buffs)
  - Your role (tanks see threat, healers see dispellable)
  - Content type (raid vs dungeon vs PvP)
  - Custom whitelist/blacklist

### Priority 2.2: Action Bar System (🔥 KILLER FEATURE)
**Why**: ElvUI dominates because it replaces EVERYTHING. You need this.
**Goal**: Beat Bartender 4 with better UX, easier setup, and more customization.

#### Core Action Bars (Match Bartender 4)
```
□ Main Action Bar (1-12 buttons)
□ Bottom Action Bars (2-6, fully configurable)
□ Right Action Bars (1-2, vertical stacking)
□ Pet Action Bar (with pet ability cooldowns)
□ Stance/Form Bar (stance dancing support)
□ Possess/Vehicle Bar (automatic switching)
□ Micro Menu Bar (character, spells, talents, etc.)
□ Bag Bar (with individual bag buttons)
□ Extra Action Button (boss abilities)
□ Zone Action Button (special zone abilities)
```

#### Standard Features per Bar (Bartender Parity)
```
□ Positioning & Layout
  - Full drag and drop positioning
  - Precise X/Y coordinate input
  - Scale (50% - 200%)
  - Button size (custom dimensions)
  - Spacing/padding between buttons
  - Rows and columns configuration
  - Anchor point selection

□ Visibility System
  - Show/hide in combat
  - Show/hide with target
  - Show/hide in vehicle
  - Show/hide based on stealth
  - Show/hide in pet battle
  - Show/hide in instance type (raid, dungeon, arena, etc.)
  - Mouse-over fading (with fade delay)
  - Alpha transparency settings

□ Button Customization
  - Keybind display (show/hide, custom format)
  - Macro name display
  - Cooldown text (size, position, format)
  - Proc glow (spell became available)
  - Range coloring (red when out of range)
  - Resource coloring (red when not enough mana/energy)
  - Button skins and borders
  - Icon zoom and padding

□ State Management
  - Page switching (combat, stealth, mounted, etc.)
  - Override bar handling
  - Action bar paging conditions
  - Modifier key support (shift/ctrl/alt pages)
```

#### 🎯 BEYOND Bartender 4 (Your Competitive Advantages)

**1. Superior UX (Easiest Action Bar Setup in WoW)**
```
□ Visual Bar Editor
  - Click and drag bars on screen with visible handles
  - Real-time preview (no /reload needed)
  - Snap-to-grid with guidelines
  - Visual alignment helpers
  - Undo/redo support
  - "Lock/Unlock" toggle for quick editing

□ Setup Wizard & Presets
  - First-time guided setup
  - Role-based presets (Tank, Healer, DPS, PvP)
  - Resolution-aware positioning (auto-adjusts for 1080p/1440p/4K)
  - Class-specific layouts (account for class resources)
  - "Simple" vs "Advanced" mode toggle
  - One-click restore to default

□ Intuitive Settings Interface
  - Per-bar configuration tabs (not nested menus)
  - Visual bar selector (click the bar you want to edit)
  - Instant preview of all changes
  - Clear labels and tooltips (no jargon)
  - "Popular settings" section for common tweaks
```

**2. Advanced Customization (Power User Features)**
```
□ Per-Button Customization
  - Individual button overrides (size, position, visibility)
  - Custom button groups (visually separate related abilities)
  - Button priority ordering (important abilities highlighted)
  - Per-button glow/highlight rules
  - Custom button labels (rename for clarity)

□ Smart Features
  - Auto-hide empty buttons (dynamic sizing)
  - Auto-sort buttons (by cooldown, usage, type)
  - Visual charge counters (multi-charge abilities)
  - Stacks display for charges
  - Enhanced proc detection (not automation, just visual)
  - Ready-state highlighting (ability just became available)
  - Cooldown progress bars (alternative to spiral)

□ Visual Enhancement
  - Multiple button skin themes (flat, glossy, minimal, etc.)
  - Custom border colors for button types
  - Ability categorization colors (offensive=red, defensive=blue, etc.)
  - Smooth animations (hover, click, proc)
  - Range indicators with gradient colors
  - Resource cost indicators (insufficient resources = visual warning)
  - Global cooldown pulse effect
```

**3. Modern Features Bartender Lacks**
```
□ Profile System
  - Save unlimited custom profiles
  - Per-character or account-wide
  - Import/export individual bars (not just full profiles)
  - Share profiles via export strings
  - Community preset library integration
  - Streamer/pro player profile imports

□ Conditional Display System
  - Advanced visibility rules (UI-only, no combat automation)
  - Show bar when in specific zone/instance
  - Show bar based on player level
  - Show bar for specific specialization only
  - Talent-based visibility (show bar if talent selected)

□ Integration Features
  - Seamless theme integration with unit frames
  - Consistent styling across all UI elements
  - Color scheme auto-sync
  - Font consistency
  - Texture/border matching

□ Quality of Life
  - Grid-based button snapping
  - Batch editing (edit multiple bars at once)
  - Copy settings from one bar to another
  - Quick templates (3x4 grid, 1x12 row, etc.)
  - Button assignment helper (auto-populate recommended abilities)
  - Keybind conflict detection
```

**4. Performance Advantages**
```
□ Optimization
  - Lazy loading (bars load only when needed)
  - Efficient update loops (only update visible bars)
  - Smart event handling (batched updates)
  - Memory pooling for buttons
  - Texture atlas for faster rendering
  - Target: 50% less memory than Bartender 4
```

#### Implementation Strategy
```
Phase 1: Core Framework (Week 1)
- Implement SecureActionButton foundation
- Create bar positioning system
- Build basic settings interface

Phase 2: Feature Parity (Week 2)
- Match all Bartender 4 core features
- Implement visibility conditions
- Add state management

Phase 3: Innovation (Week 3)
- Build visual editor
- Add smart features
- Create preset system

Phase 4: Polish (Week 4)
- Performance optimization
- User testing and refinement
- Documentation
```

#### Marketing Angle
**"Bartender 4, but actually easy to use"**
- Side-by-side comparison video
- "Set up your bars in 2 minutes" challenge
- Testimonials from Bartender 4 refugees
- Feature comparison chart showing innovations

**Implementation**: Build on Blizzard's SecureActionButton framework with custom management layer

### Priority 2.3: Nameplate System
**Why**: Modern WoW requires good nameplates for M+, raids, PvP

```
□ Friendly Nameplates
  - Health bars
  - Role icons
  - Class colors
  - Guild name display
  - Custom name format

□ Enemy Nameplates
  - Health bars with current health text
  - Cast bars with interrupt shield
  - Important debuffs only
  - Threat coloring (tank mode vs DPS mode)
  - Class colors for players
  - Quest indicators
  - Rare/elite indicators
  - Execute range indicator (< 20% health)
  - Target highlighting (bright border)
  - Focus highlighting
  - Personal resource display (on target nameplate)

□ Customization
  - Size and scale
  - Visibility distance
  - Stacking behavior
  - Clickthrough (can't click nameplates)
  - Combat-only display
  - Filter by name (hide specific mobs)
```

### Priority 2.4: Visual Information Display (Midnight-Compliant)
**Why**: Players need to see their buffs/cooldowns clearly
**Note**: Focus on PRESENTATION, not automation

```
□ Personal Buff/Debuff Display
  - Larger, cleaner icons for YOUR important buffs
  - Customizable icon positions and sizes
  - Configurable filtering (show/hide specific auras)
  - Stack count and duration displays
  - Visual warnings for missing buffs (no flask, no food)
  - Dispel highlighting (show dispellable debuffs)
  - Custom icon arrangements (grid, row, priority-based)

□ Cooldown Display
  - Icon-based cooldown tracking (visual only)
  - Group display (offensive, defensive, utility)
  - Ready notifications (visual pulse when ready)
  - Remaining time display
  - Charge-based ability tracking

□ Resource Display
  - Class-specific resource bars (combo points, soul shards, runes, etc.)
  - Alternative power bars (for boss fights)
  - Configurable positioning and styling
  - Visual thresholds (highlight at 5 combo points, etc.)
  
□ Proc Indicators
  - Visual-only proc tracking (button glows on action bars)
  - No conditional logic, just presentation of game state
  - Highlight when abilities become empowered/ready
  - Customizable glow styles
```

**Implementation**: Use LibCustomGlow for glow effects, focus on visual presentation only

---

## Phase 3: Advanced Features (Week 5-6)

### Priority 3.1: Theme System
**Why**: Aesthetic choice drives adoption

```
Themes/
├── Default/
│   └── theme.lua              # Dark theme, teal accents
├── Classic/
│   └── theme.lua              # Blizzard-style blue
├── Minimal/
│   └── theme.lua              # Flat, monochrome
├── GW2/
│   └── theme.lua              # Guild Wars 2 style
├── FFXIV/
│   └── theme.lua              # Final Fantasy style
└── Custom/
    └── theme.lua              # User can edit

Theme structure:
{
  name = "Default",
  colors = {
    primary = {0.2, 0.8, 0.8},
    background = {0.05, 0.05, 0.05, 0.9},
    border = {0.3, 0.3, 0.3},
    health = {0.2, 0.8, 0.2},
    power = {0.2, 0.4, 0.8},
    -- ... 50+ colors
  },
  textures = {
    statusbar = "Aluminium",
    border = "Glow",
    backdrop = "Solid",
  },
  fonts = {
    main = "Expressway",
    number = "PT Sans Narrow",
    header = "Roadway",
  },
  layout = {
    playerFrame = {x = -200, y = -200, scale = 1.0},
    targetFrame = {x = 200, y = -200, scale = 1.0},
    -- ... all frame positions
  }
}
```

### Priority 3.2: Minimap Enhancement
**Why**: Every UI addon customizes minimap

```
□ Customizable shape (square, circle, rounded)
□ Customizable size and scale
□ Combat fade
□ Zoom buttons
□ Calendar button
□ Tracking button
□ Dungeon difficulty indicator
□ Mail indicator
□ Clock (12hr/24hr/server time)
□ Coordinates display (X, Y)
□ Gathering node tracker (ore, herbs)
□ Move and scale
```

### Priority 3.3: Bag System
**Why**: Quality of life feature

```
□ Unified bag (all bags as one)
□ Bank integration
□ Search bar
□ Item level display
□ Rarity coloring
□ Auto-sort
□ Auto-vendor grey items
□ Custom categories (consumables, gear, quest items)
□ Bag slots display
□ Currency display
□ Bag bar (show/hide individual bags)
```

### Priority 3.4: Tooltip Enhancement
**Why**: Small feature but high impact

```
□ Item level on gear
□ Vendor price
□ Already known (transmog, toys, pets)
□ Guild rank
□ Mythic+ score (for players)
□ Health values (numerical)
□ Target information (who are they targeting)
□ Spell ID (for developers)
□ Anchor position (cursor, top, bottom, etc.)
□ Custom styling (colors, borders, backdrop)
```

### Priority 3.5: Chat Enhancement
**Why**: Social experience matters

```
□ Move and resize chat
□ Custom channel colors
□ Chat copy (Ctrl+C to copy text)
□ URL detection (clickable links)
□ Spam filter
□ Chat fading options
□ Custom timestamps
□ Chat history (persist between sessions)
□ Tab management
```

---

## Phase 4: Content-Specific Features (Week 7-8)

### Priority 4.1: Mythic+ UI Elements (Midnight-Compliant)
**Why**: M+ is core endgame content
**Focus**: Information display only, no automation

```
□ Dungeon Information Display
  - % progress bar to 100%
  - Timer display with milestone markers (+3, +2, +1 time thresholds)
  - Death counter with visual warnings
  - Current affix display (icons and tooltips)
  - Pull count tracker
  - Dungeon map integration

□ Visual Helpers (UI Only)
  - Enemy forces % tooltips (show % value on mouseover)
  - Custom nameplate styling for priority targets
  - Objective tracker styling and positioning
  - Timer position and appearance customization
  - Clear, readable progress displays
```

### Priority 4.2: Raid UI Tools (Midnight-Compliant)
**Why**: Raiding is still huge
**Focus**: Information presentation, not automation

```
□ Raid Information Display
  - Cooldown tracking display (visual representation of used cooldowns)
  - Consumable status indicators (who has buffs)
  - Ready check visualization
  - Pull timer integration (DBM/BigWigs)
  
□ Loot Information
  - Loot roll tracking
  - Loot history display
  - Item level comparison tooltips
```

### Priority 4.3: PvP UI Tools (Midnight-Compliant)
**Why**: PvP players are loyal users
**Focus**: Visual information only

```
□ Arena UI Elements
  - Enemy spec display
  - Trinket status indicators (visual only)
  - Arena preparation timer
  - Enemy health percentage displays

□ Battleground UI
  - Objective status displays
  - Flag carrier information
  - Score tracking
  - Map integration
```

---

## Phase 5: Polish & Optimization (Week 9-10)

### Priority 5.1: Performance Optimization
**Target**: Be the FASTEST UI addon

```
□ Lazy Loading
  - Only load raid frames when in raid
  - Only load arena frames when in arena
  - Only load M+ tools when in dungeon

□ Event Throttling
  - Batch multiple UNIT_HEALTH events into one update
  - Throttle frequent events (OnUpdate -> 0.1s intervals)

□ Frame Pooling
  - Reuse raid frames instead of creating/destroying
  - Pool buff icons for reuse

□ Texture Optimization
  - Compress all textures
  - Use shared textures where possible

□ Database Optimization
  - Use local variables instead of global lookups
  - Cache frequently accessed values
  - Minimize SavedVariables writes

□ Code Optimization
  - Profile with WoW's profiler
  - Optimize hot paths (update loops)
  - Remove debug code in release builds

□ Memory Management
  - Garbage collection hints
  - Nil unused references
  - Clear old combat logs
```

### Priority 5.2: Quality of Life Features

```
□ Auto-repair (with guild bank if available)
□ Auto-summon pet (hunter, warlock)
□ Auto-screenshot on achievements
□ Vendor greys automatically
□ Durability warning
□ Low health/mana warning
□ Combat state indicator
□ AFK mode (dim screen)
```

### Priority 5.3: Installation Wizard
**Why**: First impression matters

```
□ Welcome screen with addon info
□ Role selection (Tank, Healer, DPS, PvP)
□ Preset layout based on role
□ Resolution detection and auto-positioning
□ Feature tour (highlight each UI element)
□ Quick settings overview
□ Links to documentation/Discord
□ Skip option for advanced users
```

### Priority 5.4: Import/Export System
**Why**: Community sharing drives adoption

```
□ Export current profile to string
□ Import profile from string
□ Share profiles via Discord/forums
□ Online profile repository (like WeakAuras)
□ Version compatibility checking
□ Backup/restore settings
□ Cloud sync (optional, via external service)
```

### Priority 5.5: Developer Tools
**Why**: Power users will love this

```
□ /fstack equivalent (frame stack tool)
□ Event logger (see all events firing)
□ Performance profiler
□ Memory usage tracker
□ Lua error handler (Bugsack-style)
□ Reload UI button
□ Reset profile button
□ Debug mode toggle
```

---

## Phase 6: Community & Marketing (Week 11-12)

### Priority 6.1: Documentation
```
□ User guide (getting started)
□ Feature documentation (what each setting does)
□ FAQ (common questions)
□ Troubleshooting guide
□ Video tutorials (YouTube)
□ API documentation (for developers)
□ Changelog (what's new in each version)
```

### Priority 6.2: Distribution
```
□ CurseForge (primary)
□ Wago Addons (secondary)
□ WoWInterface (legacy)
□ GitHub (source code)
□ Own website (landing page)
```

### Priority 6.3: Community Building
```
□ Discord server
□ Subreddit
□ Twitter/X account
□ YouTube channel (tutorials)
□ Streamer partnerships (pay streamers to use it)
□ Content creator program (create profiles)
```

### Priority 6.4: Marketing Strategy
```
□ Competitive comparison chart (DivinicalUI vs ElvUI vs Bartender)
□ Feature highlights video
□ Before/after screenshots
□ Testimonials from beta testers
□ "Why switch from ElvUI/Bartender" article
□ SEO optimization ("best wow ui addon")
□ Paid ads on WoWHead/MMO-Champion
□ Submit to "best addons" lists
```

---

## Technical Architecture Improvements

### Recommended File Structure (Final)
```
DivinicalUI/
├── DivinicalUI.toc
├── Core.lua
├── Config/
│   ├── Config.lua
│   ├── Settings.lua
│   ├── Profiles.lua
│   ├── Installer.lua          # NEW: First-time setup
│   └── ImportExport.lua       # NEW: Profile sharing
├── Modules/
│   ├── UnitFrames/
│   │   ├── Core.lua
│   │   ├── Player.lua
│   │   ├── Target.lua
│   │   ├── Focus.lua
│   │   ├── Pet.lua
│   │   ├── Party.lua
│   │   ├── Raid.lua
│   │   ├── Arena.lua
│   │   ├── Boss.lua
│   │   └── Layouts.lua
│   ├── ActionBars/            # NEW - KILLER FEATURE
│   │   ├── Core.lua
│   │   ├── MainBar.lua
│   │   ├── BottomBars.lua
│   │   ├── RightBars.lua
│   │   ├── PetBar.lua
│   │   ├── StanceBar.lua
│   │   ├── MicroMenu.lua
│   │   ├── BagBar.lua
│   │   ├── VisualEditor.lua   # Drag-and-drop editor
│   │   └── Presets.lua        # Role-based presets
│   ├── Nameplates/            # NEW
│   │   ├── Core.lua
│   │   ├── Friendly.lua
│   │   └── Enemy.lua
│   ├── Auras/                 # NEW - Visual only
│   │   ├── Core.lua
│   │   ├── Buffs.lua
│   │   ├── Debuffs.lua
│   │   └── Cooldowns.lua
│   ├── Minimap/               # NEW
│   ├── Bags/                  # NEW
│   ├── Tooltip/               # NEW
│   ├── Chat/                  # NEW
│   ├── MythicPlus/            # NEW - UI display only
│   ├── Raid/                  # NEW - UI display only
│   ├── PvP/                   # NEW - UI display only
│   ├── Targeting.lua
│   └── Utils.lua
├── Libs/
│   ├── oUF/                   # FIXED: Full implementation
│   ├── LibSharedMedia/        # NEW: Font/texture library
│   ├── LibCustomGlow/         # NEW: Glow effects
│   ├── LibAuraInfo/           # NEW: Aura data
│   └── AceGUI/                # NEW: UI framework
├── Media/                     # NEW: All assets
│   ├── Fonts/
│   ├── Textures/
│   └── Sounds/
├── Themes/                    # NEW: Theme system
│   ├── Default.lua
│   ├── Classic.lua
│   ├── Minimal.lua
│   └── GW2.lua
└── Locale/                    # NEW: Translations
    ├── enUS.lua
    ├── deDE.lua
    ├── frFR.lua
    └── zhCN.lua
```

### Code Quality Improvements

```lua
-- Use proper localization
local L = DivinicalUI.L

-- Use proper namespacing
local AddonName, DivinicalUI = ...

-- Cache globals for performance
local _G = _G
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower

-- Use proper error handling
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        DivinicalUI:LogError("Error in function: " .. tostring(result))
    end
    return success, result
end

-- Use proper event handling with cleanup
local function RegisterEvents(frame, events, handler)
    for _, event in ipairs(events) do
        frame:RegisterEvent(event)
    end
    frame:SetScript("OnEvent", handler)
end

-- Use proper frame cleanup
local function ReleaseFrame(frame)
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetParent(nil)
    frame:UnregisterAllEvents()
end
```

---

## Success Metrics

### Launch Targets (3 months)
- 10,000 downloads on CurseForge
- 4.5+ star rating
- < 5% bug report rate
- Active Discord community (500+ members)

### 6 Month Targets
- 100,000 downloads
- Top 10 UI addon on CurseForge
- Featured on WoWHead/Icy Veins addon guides
- 5+ streamer partnerships
- 1000+ Discord members

### 1 Year Targets
- 500,000 downloads
- Top 5 UI addon (compete with ElvUI, Bartender, Shadowed)
- Self-sustaining community (users helping users)
- Patreon/sponsorship revenue
- Recognized as best-in-class for action bars

---

## The "Killer Features" Strategy

To truly stand out, pick 3 features to be BEST-IN-CLASS at:

### Option A: Action Bar King 👑 (RECOMMENDED)
- **Easiest** action bar setup in WoW
- **Most customizable** without being overwhelming
- **Best performance** among action bar addons
- Marketing: "Bartender 4, but you can actually understand it"

### Option B: Performance King 👑
- Fastest UI addon (provable benchmarks)
- Lowest memory usage
- Best for low-end PCs
- Marketing: "ElvUI performance with better looks"

### Option C: Aesthetic King 👑
- Most beautiful UI addon
- Best themes and customization
- Smooth animations
- Marketing: "Make your WoW look like a modern MMO"

**My Recommendation**: Go with **Option A (Action Bars) + Option B (Performance)**
- Action bars are used by 100% of players
- Bartender 4 is overdue for disruption
- Performance is measurable and competitive
- Both are 100% Midnight-compliant

---

## Risk Assessment & Mitigation

### Risk 1: "Why switch from Bartender/ElvUI?"
**Mitigation**:
- Built-in migration tool (import Bartender settings)
- Side-by-side comparison video
- "Try for 30 minutes" challenge
- Focus on pain points (complexity, outdated UI)

### Risk 2: "Midnight API breaks features"
**Mitigation**:
- Focus on UI presentation only (100% compliant)
- Clear documentation of what works
- No false promises about combat automation

### Risk 3: "Development burnout"
**Mitigation**:
- Modular design (can pause non-critical features)
- Focus on action bars first (killer feature)
- Community contributions (open source)

### Risk 4: "Compatibility issues"
**Mitigation**:
- Extensive testing on PTR/Beta
- Compatibility layer for popular addons
- Clear documentation of conflicts

---

## Development Tools & Resources

### Essential Tools
- **WoW AddOn Studio** (VS Code extension)
- **DevTool** (in-game addon for debugging)
- **BugSack** (Lua error catcher)
- **ViragDevTool** (variable inspector)
- **FrameXML Browser** (see Blizzard's code)

### Learning Resources
- Wowpedia API documentation
- Warcraft Wiki (updated WoW API)
- WoWInterface forums
- CurseForge developer Discord
- Study Bartender 4 source code (GitHub)
- Study oUF documentation

### Testing Checklist
```
□ Test on all classes (13 classes)
□ Test on all specs (different class power types)
□ Test in all content:
  - Questing
  - Dungeons
  - Mythic+
  - LFR / Normal / Heroic / Mythic raids
  - Arena (2v2, 3v3)
  - Battlegrounds
  - World PvP
□ Test at different resolutions
□ Test at different UI scales
□ Test with other popular addons:
  - DBM/BigWigs
  - Details!
  - Pawn
  - TomTom
  - HandyNotes
  - All The Things
```

---

## Timeline Summary

| Week | Phase | Deliverables |
|------|-------|--------------|
| 1-2 | Foundation | oUF fixed, media added, settings panel working |
| 3-4 | Core Features | All unit frames, **action bars** (priority), nameplates |
| 5-6 | Advanced | Themes, minimap, bags, tooltips, visual displays |
| 7-8 | Content | M+ UI, raid UI, PvP UI (display only) |
| 9-10 | Polish | Optimization, installer, import/export |
| 11-12 | Launch | Documentation, distribution, marketing |

**Total**: 12 weeks (3 months) to MVP (Minimum Viable Product)

---

## Immediate Next Steps (Start Here)

### Week 1 - Day 1 Tasks
1. ✅ Download latest oUF from GitHub
2. ✅ Extract to Libs/oUF/ directory
3. ✅ Fix oUF.xml load order
4. ✅ Test player frame spawn
5. ✅ Download SharedMedia library
6. ✅ Create Media/Fonts/ directory
7. ✅ Add 3-4 fonts (Expressway, PT Sans, etc.)
8. ✅ Test font loading in player frame
9. ✅ Create Media/Textures/StatusBars/
10. ✅ Add 2-3 statusbar textures

### Week 1 - Day 2-3 Tasks
1. Fix Settings.lua to create actual UI
2. Add sliders for player frame size
3. Add color picker for health bar
4. Test live updates (no /reload)
5. Add "Reset to Default" button

### Week 1 - Day 4-5 Tasks
1. Implement target frame fully
2. Add cast bar to target
3. Add buff/debuff icons
4. Add threat meter
5. Test in actual combat

### Week 2 - Action Bar Foundation
1. Research SecureActionButton API
2. Create ActionBars module structure
3. Implement basic main action bar
4. Add drag-and-drop positioning
5. Test bar visibility and state switching

By end of Week 2, you should have:
- ✅ Working player and target frames (pretty)
- ✅ Settings panel (usable)
- ✅ Custom fonts and textures
- ✅ Basic action bar framework
- ✅ Confidence in the foundation

---

## Final Thoughts: What Makes a UI Addon "Must-Have"

After 15 years of using and building WoW addons, here's what I've learned:

### 1. **It Has To "Just Work"**
- No errors on load
- No weird positioning issues
- Works with default settings (tweaking is optional)

### 2. **It Has To Look Good**
- Players judge in the first 5 seconds
- If it looks amateurish, they uninstall
- Modern > Nostalgic (for retail WoW)

### 3. **It Has To Be Fast**
- If it drops FPS, players blame it (even if it's not your fault)
- Memory usage is visible in game
- Load times matter

### 4. **It Has To Be Unique**
- If it's just "ElvUI but slightly different," why switch?
- Find your niche: best action bars, best for healers, best performance
- Own that niche completely

### 5. **It Has To Have Community**
- Discord where users help each other
- Streamers and YouTubers using it
- Shared profiles on Wago/CurseForge
- Regular updates and engagement

### 6. **It Has To Be Midnight-Ready**
- No combat automation promises
- Focus on what Blizzard explicitly allows
- Be the addon that "works perfectly with Midnight"

---

## Conclusion

Your current codebase is a **solid foundation** (7/10), but to compete with ElvUI and Bartender (9/10), you need to:

1. **Fix the fundamentals** (oUF, media, settings) - Week 1-2
2. **Dominate action bars** (easier than Bartender, prettier than ElvUI) - Week 3-4
3. **Match feature parity** (all unit frames, nameplates) - Week 5-6  
4. **Add differentiators** (performance, themes, visual presentation) - Week 7-10
5. **Polish and launch** (installer, docs, marketing) - Week 11-12

**The winning formula**:
- Bartender 4's functionality, but **actually easy to use**
- ElvUI's completeness, but **better performance**
- Beautiful aesthetic that **makes WoW feel modern**
- 100% Midnight-compliant (no broken features)

You've got the skills and the start. Now it's execution time.

**Let's build the action bar system that everyone will want to use.**

---

_This plan was updated for Midnight API compliance. Focus on UI presentation over automation, and make action bars your killer feature. The market is ready for a Bartender 4 successor._

🔥 **NOW GO BUILD IT** 🔥
