-- Targeting system for DivinicalUI
local AddonName, DivinicalUI = ...

-- Targeting module
local Targeting = {}

-- Target history
local targetHistory = {}
local maxHistorySize = 10

-- Focus management
local focusHistory = {}

-- Initialize targeting module
function Targeting:Initialize()
    self:RegisterEvents()
    self:SetupTargetingMacros()
end

-- Post-initialization
function Targeting:PostInitialize()
    -- Called after all modules are loaded
end

-- Register events
function Targeting:RegisterEvents()
    DivinicalUI.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    DivinicalUI.eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_TARGET")
end

-- Setup targeting macros
function Targeting:SetupTargetingMacros()
    -- Create macro for quick target cycling
    local macroIndex = GetMacroIndexByName("DivinicalTargetCycle")
    if macroIndex == 0 then
        CreateMacro("DivinicalTargetCycle", "INV_MISC_QUESTIONMARK", 
                   "/script DivinicalUI.modules.Targeting:CycleTarget()", nil)
    end
    
    -- Create macro for focus target
    local focusMacroIndex = GetMacroIndexByName("DivinicalFocusTarget")
    if focusMacroIndex == 0 then
        CreateMacro("DivinicalFocusTarget", "INV_MISC_QUESTIONMARK", 
                   "/script DivinicalUI.modules.Targeting:FocusTarget()", nil)
    end
    
    -- Create macro for target marking
    local markMacroIndex = GetMacroIndexByName("DivinicalMarkTarget")
    if markMacroIndex == 0 then
        CreateMacro("DivinicalMarkTarget", "INV_MISC_QUESTIONMARK", 
                   "/script DivinicalUI.modules.Targeting:MarkTarget(8)", nil) -- Skull by default
    end
end

-- Event handlers
function Targeting:PLAYER_TARGET_CHANGED()
    local targetName = UnitName("target")
    local targetGUID = UnitGUID("target")
    
    if targetName and targetGUID then
        -- Add to target history
        self:AddToTargetHistory(targetName, targetGUID)
        
        -- Print target info (optional)
        if DivinicalUI.db.profile.targeting and DivinicalUI.db.profile.targeting.showTargetInfo then
            local level = UnitLevel("target")
            local classification = DivinicalUI.modules.Utils.Units.GetClassification("target")
            local health = DivinicalUI.modules.Utils.Units.GetHealthPercent("target")
            
            print("|cff33ff99DivinicalUI|r Target: " .. targetName .. 
                  " (Level " .. level .. " " .. classification .. 
                  ", " .. DivinicalUI.modules.Utils.Math.Round(health) .. "% HP)")
        end
    end
end

function Targeting:PLAYER_FOCUS_CHANGED()
    local focusName = UnitName("focus")
    local focusGUID = UnitGUID("focus")
    
    if focusName and focusGUID then
        -- Add to focus history
        self:AddToFocusHistory(focusName, focusGUID)
        
        -- Print focus info (optional)
        if DivinicalUI.db.profile.targeting and DivinicalUI.db.profile.targeting.showFocusInfo then
            print("|cff33ff99DivinicalUI|r Focus: " .. focusName)
        end
    end
end

function Targeting:UNIT_TARGET(unit)
    if unit == "player" then
        -- Player's target changed (alternative to PLAYER_TARGET_CHANGED)
    end
end

-- Add target to history
function Targeting:AddToTargetHistory(name, guid)
    -- Remove existing entry if present
    for i, entry in ipairs(targetHistory) do
        if entry.guid == guid then
            table.remove(targetHistory, i)
            break
        end
    end
    
    -- Add to front of history
    table.insert(targetHistory, 1, {
        name = name,
        guid = guid,
        time = time()
    })
    
    -- Limit history size
    while #targetHistory > maxHistorySize do
        table.remove(targetHistory)
    end
end

-- Add focus to history
function Targeting:AddToFocusHistory(name, guid)
    -- Remove existing entry if present
    for i, entry in ipairs(focusHistory) do
        if entry.guid == guid then
            table.remove(focusHistory, i)
            break
        end
    end
    
    -- Add to front of history
    table.insert(focusHistory, 1, {
        name = name,
        guid = guid,
        time = time()
    })
    
    -- Limit history size
    while #focusHistory > 5 do
        table.remove(focusHistory)
    end
end

-- Cycle through target history
function Targeting:CycleTarget()
    if #targetHistory < 2 then
        DivinicalUI.modules.Utils.Debug.Print("Not enough targets in history to cycle", "WARN")
        return
    end
    
    -- Find current target in history
    local currentIndex = 0
    local currentGUID = UnitGUID("target")
    
    if currentGUID then
        for i, entry in ipairs(targetHistory) do
            if entry.guid == currentGUID then
                currentIndex = i
                break
            end
        end
    end
    
    -- Select next target in history
    local nextIndex = currentIndex + 1
    if nextIndex > #targetHistory then
        nextIndex = 1
    end
    
    local nextTarget = targetHistory[nextIndex]
    if nextTarget then
        -- Try to target by name (simplified approach)
        TargetUnit(nextTarget.name)
    end
end

-- Focus current target
function Targeting:FocusTarget()
    if UnitExists("target") then
        FocusUnit("target")
        DivinicalUI.modules.Utils.Debug.Print("Focused: " .. UnitName("target"), "INFO")
    else
        DivinicalUI.modules.Utils.Debug.Print("No target to focus", "WARN")
    end
end

-- Mark current target
function Targeting:MarkTarget(raidIcon)
    if not raidIcon then raidIcon = 8 end -- Default to skull
    
    if UnitExists("target") and UnitIsPlayer("target") == false then
        SetRaidTarget("target", raidIcon)
        local iconNames = {"Star", "Circle", "Diamond", "Triangle", "Moon", "Square", "Cross", "Skull"}
        local iconName = iconNames[raidIcon] or "Unknown"
        DivinicalUI.modules.Utils.Debug.Print("Marked " .. UnitName("target") .. " with " .. iconName, "INFO")
    else
        DivinicalUI.modules.Utils.Debug.Print("Cannot mark target (no target or target is player)", "WARN")
    end
end

-- Target by name
function Targeting:TargetByName(name)
    if not name or name == "" then
        return false
    end
    
    -- Try exact match first
    if UnitName("target") == name then
        return true
    end
    
    -- Search through nearby units
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) and UnitName(unit) == name then
            TargetUnit(unit)
            return true
        end
    end
    
    -- Try targeting by name (may not work in combat)
    TargetByName(name)
    return UnitName("target") == name
end

-- Target lowest health enemy
function Targeting:TargetLowestHealth()
    local lowestHealth = 100
    local lowestUnit = nil
    
    -- Check nameplates
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) and UnitCanAttack("player", unit) and not UnitIsDead(unit) then
            local health = DivinicalUI.modules.Utils.Units.GetHealthPercent(unit)
            if health < lowestHealth then
                lowestHealth = health
                lowestUnit = unit
            end
        end
    end
    
    if lowestUnit then
        TargetUnit(lowestUnit)
        return true
    end
    
    return false
end

-- Target nearest enemy
function Targeting:TargetNearestEnemy()
    TargetNearestEnemy()
    return UnitExists("target") and UnitCanAttack("player", "target")
end

-- Clear target
function Targeting:ClearTarget()
    ClearTarget()
end

-- Clear focus
function Targeting:ClearFocus()
    ClearFocus()
end

-- Get target history
function Targeting:GetTargetHistory()
    return targetHistory
end

-- Get focus history
function Targeting:GetFocusHistory()
    return focusHistory
end

-- Smart targeting based on context
function Targeting:SmartTarget()
    -- If no target, target nearest enemy
    if not UnitExists("target") then
        return self:TargetNearestEnemy()
    end
    
    -- If current target is dead, target nearest enemy
    if UnitIsDead("target") then
        return self:TargetNearestEnemy()
    end
    
    -- If current target is friendly, target nearest enemy
    if UnitIsFriend("target", "player") then
        return self:TargetNearestEnemy()
    end
    
    -- Otherwise, cycle to next enemy
    return self:CycleTarget()
end

-- Proximity targeting (find enemies within range)
function Targeting:TargetInRange(range)
    range = range or 10
    
    local closestUnit = nil
    local closestDistance = range + 1
    
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) and UnitCanAttack("player", unit) and not UnitIsDead(unit) then
            local distance = DivinicalUI.modules.Utils.Units.IsInRange(unit, 1) and 0 or range + 1
            if distance < closestDistance then
                closestDistance = distance
                closestUnit = unit
            end
        end
    end
    
    if closestUnit then
        TargetUnit(closestUnit)
        return true
    end
    
    return false
end

-- Profile change handler
function Targeting:OnProfileChanged(profileName)
    -- Update targeting settings when profile changes
    DivinicalUI.modules.Utils.Debug.Print("Targeting module profile changed to: " .. profileName, "DEBUG")
end

-- Register module
DivinicalUI:RegisterModule("Targeting", Targeting)