# Modular WoW UI Addon - Product Requirements Document (PRD)

## 1. Product Overview

**Name:** [To be determined - e.g., "Prism UI"]

**Scope:** A lightweight, modular UI framework that replaces or augments the default Blizzard UI with customizable action bars, unit frames, resource displays, and profile management. Compliant with Blizzard's addon TNC and future combat addon restrictions.

**Target Audience:** Raiding players, solo/open-world adventurers, PvP competitors (all classes supported).

**Phase:** MVP (Minimum Viable Product) targeting 1-2 day delivery.

---

## 2. MVP Feature Set (Phase 1 - Deliverable)

### 2.1 Core Infrastructure
- **Frame Manager System:** Central registry for all UI elements with anchoring, positioning, and scaling.
- **Profile System:** Save/load complete UI layouts via profile switching (no in-game editor needed for MVP).
- **Namespace Architecture:** Modular Lua structure ensuring no global variable pollution.
- **Event Dispatcher:** Centralized event handling for game state changes.

### 2.2 UI Modules (MVP)
1. **Action Bars Module**
   - Customizable number of bars (1-6)
   - Bar positioning: top, bottom, left, right, custom anchors
   - Keybind display (customizable font size, position, color)
   - Button styling: size, border style, cooldown ring visibility
   - Bar visibility toggles: in-combat, out-of-combat, stance-specific

2. **Unit Frames Module**
   - Player frame (health, mana, status indicators)
   - Target frame (health, mana, target-of-target)
   - Focus frame (optional)
   - Pet frame
   - Scalable, repositionable
   - Health bar coloring (class-based or custom)

3. **Resource Display Module**
   - Class-specific primary resource (Insanity, Mana, Rage, Energy, etc.)
   - Visual display options: bar, circle, numeric text
   - Customizable colors and thresholds
   - Secondary resource tracking (optional)

4. **Minimap Module**
   - Repositionable minimap
   - Zoomable
   - Toggle visibility

5. **Configuration Panel**
   - Main menu with module toggles (enable/disable each module)
   - Profile selection dropdown
   - Import/export profile as text string
   - Reset to defaults button
   - No per-element fine-tuning in MVP (settings applied globally per module)

---

## 3. Strict Architectural Rules

### 3.1 Code Organization

```
AddonName/
├── AddonName.toc              # Metadata file (required)
├── core/
│   ├── init.lua              # Initialization & namespace setup
│   ├── constants.lua         # Global constants, frame names, defaults
│   └── utils.lua             # Utility functions (positioning, math, etc.)
├── modules/
│   ├── frameManager.lua      # Core frame registry & positioning system
│   ├── profiles.lua          # Profile save/load logic
│   ├── eventDispatcher.lua   # Event registration & handling
│   ├── actionBars.lua        # Action bar creation & logic
│   ├── unitFrames.lua        # Unit frame creation & updates
│   ├── resourceDisplay.lua   # Resource visualization
│   ├── minimap.lua           # Minimap repositioning
│   └── config.lua            # Configuration panel UI
└── run.lua                   # Bootstrap & addon startup
```

### 3.2 File Execution Order (in .toc file)

Files must be loaded in dependency order:

```
core/init.lua
core/constants.lua
core/utils.lua
modules/frameManager.lua
modules/profiles.lua
modules/eventDispatcher.lua
modules/actionBars.lua
modules/unitFrames.lua
modules/resourceDisplay.lua
modules/minimap.lua
modules/config.lua
run.lua
```

**Why order matters:** Each module depends on previously loaded modules. `run.lua` fires last to initialize everything.

### 3.3 Namespace & Global Variable Rules

**CRITICAL:**
- All addon code runs in a namespace `ns` (passed as second argument to each Lua file).
- **Never create global variables** (except through explicit addon registration with Blizzard).
- Use `local addon, ns = ...` at the top of every file to access the namespace.
- All functions, tables, and state live in `ns.*`, not in global scope.

**Example:**
```lua
local addon, ns = ...

-- Correct: Lives in namespace
ns.MyFunction = function()
  print("Hello")
end

-- WRONG: Creates a global
function MyFunction()
  print("Hello")
end
```

### 3.4 Frame Naming Convention

All custom frames must use a prefixed naming scheme to avoid collisions:

```lua
local FRAME_PREFIX = "PrismUI_"

-- Frame names follow pattern: PrismUI_[Module]_[ElementType]_[Number]
-- Examples:
-- PrismUI_ActionBars_Bar_1
-- PrismUI_UnitFrames_Player
-- PrismUI_UnitFrames_Target
-- PrismUI_Config_Panel
```

### 3.5 Module Interface Contract

Every module must expose:

```lua
ns.modules.ModuleName = {
  Initialize = function() end,    -- Called on addon load
  Shutdown = function() end,      -- Called on addon unload (for cleanup)
  GetStatus = function() end,     -- Returns "enabled" or "disabled"
  ResetToDefaults = function() end -- Resets module to defaults
}
```

### 3.6 Configuration Data Structure

All configuration lives in a single table, saved to `SavedVariables`:

```lua
ns.config = {
  profile = "Default",
  profiles = {
    Default = {
      actionBars = { enabled = true, count = 6, ... },
      unitFrames = { enabled = true, scale = 1.0, ... },
      resourceDisplay = { enabled = true, ... },
      minimap = { enabled = true, ... },
      theme = "sleek_modern"
    }
  },
  themes = { /* theme definitions */ }
}
```

**Single source of truth:** All state flows through this table. No scattered module-specific SavedVariables.

### 3.7 Event Handling Rules

- **Centralized:** All WoW events registered in `eventDispatcher.lua`.
- **No inline event handlers:** Modules subscribe to events, not register directly.

```lua
-- Good: Module subscribes via dispatcher
ns.eventDispatcher:Subscribe("PLAYER_LEVEL_UP", function()
  ns.unitFrames:Update()
end)

-- Bad: Direct registration
frame:RegisterEvent("PLAYER_LEVEL_UP")
```

### 3.8 Frame Creation Rules

- Use `CreateFrame()` only in module initialization.
- Store all created frames in a module-local table for reference.
- Never modify Blizzard's default frames directly (create overlays if needed).
- Apply anchoring immediately after frame creation (no dangling frames).

### 3.9 Performance & Memory Rules

- **No polling:** Never use `OnUpdate` scripts. Use event-driven updates only.
- **Texture recycling:** Reuse textures/regions instead of recreating them.
- **Lazy loading:** Don't create frames for disabled modules.
- **Garbage collection:** Unregister events, nullify references on shutdown.

### 3.10 Compliance & Future-Proofing Rules

- **No combat automation:** UI never suggests or triggers spells automatically.
- **No combat event parsing for rotation advice:** Can display cooldown timers, but not "cast X now."
- **Modular approach:** If combat addons are banned, non-combat modules (UI layout, profiles, config) remain functional.
- **Version checking:** Check WoW patch version in `.toc` file and warn users of incompatibility.

---

## 4. Data Persistence

### 4.1 SavedVariables Setup

In `.toc` file:

```
## SavedVariables: PrismUIConfig
```

This automatically saves `PrismUIConfig` (a global table) to disk on logout.

### 4.2 Profile Storage Format

```lua
PrismUIConfig = {
  currentProfile = "Default",
  profiles = {
    Default = { /* full config */ },
    Raider = { /* full config */ },
    PvP = { /* full config */ }
  }
}
```

Profiles are JSON-serializable for export/import.

---

## 5. Configuration Panel Spec (MVP)

### 5.1 Layout

- Single window, 400x600 pixels
- Sections for each module (Action Bars, Unit Frames, etc.)
- Each section has:
  - Toggle to enable/disable module
  - Key settings (2-3 sliders or dropdowns max per module)
  - "Reset to Defaults" button
- Bottom: Profile selector, Import/Export buttons

### 5.2 Interaction

- Right-click any frame to bring up config panel
- Command: `/prismui config` or `/pu config`
- All changes apply immediately (no "Apply" button needed)
- Profile switches reload addon (brief UI flash)

---

## 6. Design Tokens (Theme System)

### 6.1 "Sleek Modern" Theme

```lua
colors = {
  background = { r = 0.1, g = 0.1, b = 0.1, a = 0.9 },
  border = { r = 0.3, g = 0.3, b = 0.3, a = 1 },
  text = { r = 1, g = 1, b = 1, a = 1 },
  healthGood = { r = 0.1, g = 0.8, b = 0.1, a = 1 },
  healthLow = { r = 0.8, g = 0.1, b = 0.1, a = 1 }
}
fonts = {
  default = "Fonts/FRIZQT__.TTF",
  size = 12
}
spacing = { padding = 5, margin = 10 }
borders = { width = 1, style = "solid" }
```

### 6.2 "WoW Classic" Theme

Similar, but with warmer colors closer to Blizzard's default UI.

### 6.3 "Minimalist" Theme

Transparent backgrounds, smaller text, ultra-compact layouts.

---

## 7. MVP Deliverables Checklist

- [ ] `.toc` file with correct interface version & SavedVariables
- [ ] All 7 core files (init, constants, utils, frameManager, profiles, eventDispatcher, run)
- [ ] Action Bars module (basic version: 6 bars, positioning, keybinds)
- [ ] Unit Frames module (player, target only; scalable)
- [ ] Resource Display module (class-specific; 2 display modes)
- [ ] Minimap module (repositionable)
- [ ] Profiles module (save/load via SavedVariables)
- [ ] Config panel (toggle modules, select profiles, import/export)
- [ ] 1 complete theme ("Sleek Modern")
- [ ] Basic error handling & logging
- [ ] README with installation & basic commands

---

## 8. Non-MVP (Phase 2+)

- [ ] Raid frames
- [ ] Cast bar
- [ ] Buff/debuff tracker
- [ ] Threat bar
- [ ] Damage/healing numbers overlay
- [ ] Additional themes
- [ ] Per-element fine-tuning in config
- [ ] WeakAura-style trigger system for advanced users
- [ ] Preset layouts for each playstyle (Raider, Solo, PvP)

---

## 9. Testing Strategy

- Load addon in game, test frame positioning via drag-to-move.
- Verify profiles save/load correctly via logout → login.
- Test all module toggles enable/disable correctly.
- Check for memory leaks (monitor addon memory in-game).
- Verify no global variable pollution (check `_G` table).

---

## 10. Deployment

- Package as `.zip` with folder structure.
- Name: `PrismUI_v1.0.0.zip`
- Upload to CurseForge + WoWInterface.
- Include `README.md` with installation steps, commands, and known limitations.

---

## 11. Success Criteria

✓ Addon loads without errors.
✓ All 4 core modules initialize and are usable.
✓ Profiles save and load correctly.
✓ Config panel is navigable and functional.
✓ Complies with Blizzard TNC (no paid content, no combat automation).
✓ No global variable pollution.
✓ Frames are repositionable and scalable.
✓ Addon persists across game restarts.
