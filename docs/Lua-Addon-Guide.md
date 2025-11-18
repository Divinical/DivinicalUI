# WoW Addon Development: Lua Fundamentals & Architecture Guide

## Part 1: Is It Just Lua Scripts? Stack Overview

### Short Answer
**Yes, it's all Lua scripts.** No external build tools, no TypeScript transpilation, no npm packages. However, you may optionally use:

- **XML templates** (optional, for complex UI layouts)
- **LuaLS (Lua Language Server)** (optional, for IDE autocomplete and error checking)
- **Bun/Node.js** (optional, for personal dev tools, NOT for the addon itself)

### What You're Actually Building

A WoW addon is:
1. A folder containing `.lua` and `.xml` files
2. A `.toc` (Table of Contents) metadata file
3. Lua code that runs in the WoW client's embedded Lua interpreter
4. Direct access to WoW's C-implemented Lua API (`CreateFrame`, `GetSpellInfo`, etc.)

**That's it.** No compilation, no bundling, no dependency management.

---

## Part 2: Lua vs. React / Atom Design Principle

### Is Lua Like React?

**No.** Lua is fundamentally different from TypeScript/React:

| Aspect | React/TypeScript | WoW Lua |
|--------|------------------|---------|
| **Paradigm** | Declarative, component-based | Imperative, procedural |
| **State** | Hooks, component state, re-render | Direct manipulation, manual updates |
| **Events** | Event listeners, synthetic events | Event registration, callback handlers |
| **DOM/UI** | Virtual DOM, reconciliation | Direct frame object manipulation |
| **Build step** | Yes (JSX → JavaScript) | No (pure Lua) |
| **Package management** | npm, yarn | None (all code inline) |

**React Example:**
```typescript
function HealthBar({ health, max }) {
  return <div style={{ width: `${(health/max)*100}%` }} />;
}
```

**WoW Lua Equivalent:**
```lua
local healthBar = CreateFrame("StatusBar", "MyHealthBar", parent)
healthBar:SetMinMaxValues(0, max)
healthBar:SetValue(health)
healthBar:SetPoint("TOP", parent, "TOP", 0, -10)
healthBar:SetSize(200, 20)
```

### Do You Use Atomic Design Principles?

**Partially.** WoW UI has a natural hierarchy that resembles atomic design:

**Atomic Design Hierarchy in WoW:**

```
ATOMS:
  - StatusBar (health bar)
  - FontString (text label)
  - Texture (icon, border)
  
MOLECULES:
  - UnitFrame (combines StatusBar + FontString + Textures)
  - ActionButton (combines icon + cooldown + keybind text)
  
ORGANISMS:
  - RaidFrame (combines multiple UnitFrames)
  - ActionBar (combines multiple ActionButtons)
  
TEMPLATES:
  - Complete UI Layout (combines Organisms into cohesive design)
```

**However,** you don't use it as a strict design system like you would in React. Instead, you:

1. Define **reusable frame templates** in Lua or XML
2. Create **factory functions** that generate instances
3. Manually apply styling & positioning

**Example (Factory Function Pattern):**
```lua
-- Atom: Create a single health bar
function ns.CreateHealthBar(name, parent)
  local bar = CreateFrame("StatusBar", name, parent)
  bar:SetHeight(20)
  bar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
  bar:SetStatusBarColor(0.5, 0.5, 0.5)
  return bar
end

-- Molecule: Unit frame combines multiple bars
function ns.CreateUnitFrame(name, parent)
  local frame = CreateFrame("Frame", name, parent)
  frame:SetSize(200, 50)
  
  frame.healthBar = ns.CreateHealthBar(name.."_Health", frame)
  frame.healthBar:SetPoint("TOP", frame, "TOP", 0, 0)
  
  frame.manaBar = ns.CreateHealthBar(name.."_Mana", frame)
  frame.manaBar:SetPoint("TOP", frame.healthBar, "BOTTOM", 0, -5)
  
  return frame
end
```

---

## Part 3: WoW Addon Architecture Deep Dive

### 3.1 The .toc File (Table of Contents)

This is your addon's **manifest**. It tells WoW how to load your addon.

**Minimal Example:**
```
## Interface: 110000
## Title: Prism UI
## Author: YourName
## Version: 1.0.0
## SavedVariables: PrismUIConfig

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

**Breakdown:**
- `## Interface: 110000` — Target WoW patch (11.0.0 = 110000)
- `## SavedVariables: PrismUIConfig` — Which globals to persist to disk
- File list — Order matters! Listed files load in sequence.

### 3.2 The Namespace System

**Problem:** Multiple addons can't both use a global `Config` or `MainFrame` variable. Collisions break the game.

**Solution:** Every addon uses a private namespace (the `ns` variable).

**How It Works:**

```lua
-- In core/init.lua
local addon, ns = ...
-- addon = "PrismUI" (your addon name)
-- ns = {} (empty table, your private namespace)

-- Everything lives here:
ns.config = {}
ns.modules = {}
ns.utils = {}
ns.frames = {}
```

Each file receives the same `ns` table:
```lua
-- In modules/actionBars.lua
local addon, ns = ...
-- Access stuff defined in init.lua
print(ns.config)
print(ns.utils.CreateHealthBar)
```

**Key Rule:** Never define globals. Everything must live in `ns.*`.

### 3.3 Frames, Layers, and Rendering

WoW's UI is built on **Frames** (similar to HTML divs, but with a different architecture).

**Frame Hierarchy:**
```
UIParent (root)
├── ActionBarFrame
│   ├── ActionButton_1
│   ├── ActionButton_2
│   └── ...
├── UnitFramePlayer
│   ├── HealthBar (StatusBar)
│   ├── ManaBar (StatusBar)
│   └── Name (FontString)
└── ...
```

**Creating a Frame:**
```lua
-- Syntax: CreateFrame(frameType, name, parent, inherits)
local myFrame = CreateFrame("Frame", "MyCustomFrame", UIParent)

-- Configure it
myFrame:SetSize(200, 100)
myFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
myFrame:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
myFrame:SetBackdropColor(0, 0, 0, 0.7) -- 70% opaque black
```

**Frame Types:**
- `Frame` — Basic container
- `Button` — Clickable button
- `StatusBar` — Health/mana bar
- `FontString` — Text display
- `Texture` — Image display
- `GameTooltip` — Tooltip popup

### 3.4 Event System

WoW triggers **events** (game state changes). Your addon subscribes to them.

**Common Events:**
```lua
"PLAYER_LOGIN"              -- Player enters world
"COMBAT_LOG_EVENT_UNFILTERED" -- Combat action occurs
"PLAYER_ENTERING_WORLD"     -- Zone change, relog
"PLAYER_TARGET_CHANGED"     -- Target swapped
"SPELL_UPDATE"              -- Spell cooldown changes
"UNIT_HEALTH"               -- Unit's health changed
```

**Registering Events:**
```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SPELL_UPDATE")

-- Handler function
frame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_LOGIN" then
    print("Player logged in!")
  elseif event == "SPELL_UPDATE" then
    print("Spells updated!")
  end
end)
```

**Better Pattern (centralized):**
```lua
-- In modules/eventDispatcher.lua
ns.eventDispatcher = {}
local subscribers = {}

function ns.eventDispatcher:Subscribe(event, callback)
  if not subscribers[event] then
    subscribers[event] = {}
  end
  table.insert(subscribers[event], callback)
end

-- Single frame handles all events
local mainFrame = CreateFrame("Frame")
mainFrame:RegisterEvent("*") -- Register for ALL events

mainFrame:SetScript("OnEvent", function(self, event, ...)
  if subscribers[event] then
    for _, callback in ipairs(subscribers[event]) do
      callback(event, ...)
    end
  end
end)
```

### 3.5 Saved Variables (Persistence)

**Problem:** Your config lives in RAM. On logout, it disappears.

**Solution:** SavedVariables are automatically written to disk on logout.

**Setup:**
```
## SavedVariables: PrismUIConfig
```

Then, any changes to the global `PrismUIConfig` table persist:

```lua
-- First login: PrismUIConfig doesn't exist
if not PrismUIConfig then
  PrismUIConfig = {
    currentProfile = "Default",
    profiles = { Default = { ... } }
  }
end

-- Change it
PrismUIConfig.currentProfile = "Raider"
-- On logout, WoW auto-saves this.
```

### 3.6 The Frame Update Cycle

**NEVER use polling (OnUpdate).** Always use events.

**Wrong:**
```lua
frame:SetScript("OnUpdate", function(self, elapsed)
  -- This fires 60 times per second (performance killer!)
  local health = UnitHealth("player")
  self.healthBar:SetValue(health)
end)
```

**Right:**
```lua
frame:RegisterEvent("UNIT_HEALTH")
frame:SetScript("OnEvent", function(self, event, unit)
  if unit == "player" then
    local health = UnitHealth("player")
    self.healthBar:SetValue(health)
  end
end)
```

---

## Part 4: Data Flow in Your Addon

### 4.1 Startup Sequence

```
1. WoW reads .toc file
2. Files loaded in order (init → constants → utils → modules → run)
3. Each file executes: local addon, ns = ...
4. Modules initialize: ns.modules.ActionBars:Initialize()
5. run.lua fires addon startup event
6. Player sees UI
```

### 4.2 State Management

**Your single source of truth:**
```lua
ns.config = {
  currentProfile = "Default",
  profiles = {
    Default = { 
      actionBars = { enabled = true, count = 6, ... },
      unitFrames = { enabled = true, ... },
      resourceDisplay = { enabled = true, ... }
    }
  }
}
```

**Flow:**
1. User clicks "Enable Action Bars" in config panel
2. Panel calls: `ns.config.profiles[ns.config.currentProfile].actionBars.enabled = true`
3. Panel triggers event: `AddonConfigChanged`
4. ActionBars module listens: "Hey, config changed, rebuild bars!"
5. Module updates frames

### 4.3 Module Communication

Modules communicate **only via events** or by reading `ns.config`.

```lua
-- ActionBars module triggers
ns.eventDispatcher:Subscribe("PLAYER_LEVEL_UP", function()
  ns.eventDispatcher:Dispatch("PLAYER_CHANGED")
end)

-- UnitFrames module listens
ns.eventDispatcher:Subscribe("PLAYER_CHANGED", function()
  ns.unitFrames:Update()
end)
```

---

## Part 5: Quick Reference: Common Operations

### Creating a Draggable Frame

```lua
local frame = CreateFrame("Frame", "MyDraggableFrame", UIParent)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  -- Optional: Save position to SavedVariables
  PrismUIConfig.framePositions.myFrame = {
    x = self:GetLeft(),
    y = self:GetTop()
  }
end)
```

### Updating a Unit Frame

```lua
local function UpdatePlayerFrame()
  local health = UnitHealth("player")
  local maxHealth = UnitHealthMax("player")
  local mana = UnitMana("player")
  local maxMana = UnitManaMax("player")
  
  ns.frames.playerFrame.healthBar:SetMinMaxValues(0, maxHealth)
  ns.frames.playerFrame.healthBar:SetValue(health)
  
  ns.frames.playerFrame.manaBar:SetMinMaxValues(0, maxMana)
  ns.frames.playerFrame.manaBar:SetValue(mana)
end

-- Subscribe to updates
ns.eventDispatcher:Subscribe("UNIT_HEALTH", function(event, unit)
  if unit == "player" then
    UpdatePlayerFrame()
  end
end)
```

### Changing Theme Colors

```lua
ns.themes = {
  sleek_modern = {
    background = { r = 0.1, g = 0.1, b = 0.1, a = 0.9 },
    text = { r = 1, g = 1, b = 1, a = 1 },
    border = { r = 0.3, g = 0.3, b = 0.3, a = 1 }
  }
}

local function ApplyTheme(themeName)
  local theme = ns.themes[themeName]
  -- Apply to all frames
  for frameName, frame in pairs(ns.frames) do
    frame:SetBackdropColor(theme.background.r, theme.background.g, theme.background.b, theme.background.a)
  end
end
```

---

## Part 6: Development Workflow

### Using LuaLS (Optional, Recommended)

Install Lua Language Server in your editor (VS Code, Neovim, etc.). It gives you:
- Autocomplete for WoW API
- Type checking
- Error squiggles

Add a `.luarc.json` in your addon folder:
```json
{
  "runtime.version": "Lua 5.1",
  "workspace.library": [
    "/path/to/wow-api-stubs"
  ]
}
```

### Testing Locally

1. Save addon files to: `C:\Users\YourName\AppData\Local\World of Warcraft\_retail_\Interface\AddOns\PrismUI\`
2. Start WoW, enable addon in addon list
3. Log in to character
4. Test via in-game commands: `/script print(ns.config)`

### Reloading During Development

In-game command to reload UI without restarting:
```
/reload
```

All `.lua` files re-execute, SavedVariables persist.

---

## Part 7: Comparison to Modern Web Development

### Your Background (React/TypeScript)

You're used to:
- Type safety (TypeScript)
- Components (React)
- Hooks (useState, useEffect)
- Package management (npm)
- Hot module replacement

### WoW Lua Equivalent

- **Type safety:** None built-in (but LuaLS helps)
- **Components:** Frame factory functions
- **Hooks:** Event subscriptions (similar to useEffect)
- **Package management:** None (files inline)
- **Hot reload:** `/reload` command (not as fast)

**Bottom line:** You'll miss TypeScript safety and component composition, but the mental model is simple: imperative, event-driven, no virtual DOM magic.

---

## Part 8: FAQ

**Q: Do I need to learn XML?**
A: No. You can build everything in Lua + `CreateFrame()`. XML is optional for complex layouts.

**Q: Can I use existing libraries (Ace3, LibStub)?**
A: Yes, but not in MVP. Stick to pure Lua for simplicity.

**Q: Will my addon break on the next WoW patch?**
A: Possibly. Update the `## Interface` version in .toc, test, and fix any API changes.

**Q: Is Lua performance-critical?**
A: Not for UI. Lua is fast enough. Avoid OnUpdate loops and excessive event handlers.

**Q: Can I share code between addons?**
A: Not officially. Each addon is isolated. You'd need to duplicate code or use libraries like Ace3.

---

## Summary

- **Stack:** Just Lua. No build tools needed.
- **Like React?** No. Imperative, not declarative.
- **Atomic Design?** Loosely yes, via factory functions & reusable templates.
- **Architecture:** Namespace-based (all code in `ns.*`), event-driven, frame-based.
- **Development:** Simple: edit files, `/reload`, test.

You're ready to start coding. The LLM you choose will guide the Lua syntax and patterns.
