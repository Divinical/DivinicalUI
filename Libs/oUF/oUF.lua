-- oUF (Unit Frame framework) - Embedded version for DivinicalUI
-- This is a simplified version of oUF for basic functionality

local _, ns = ...
local oUF = ns.oUF or {}
ns.oUF = oUF

-- Version
oUF.version = "1.12.0"

-- Private variables
local objects = {}
local styles = {}
local activeStyle

-- Helper functions
local function argcheck(value, num, ...)
    assert(type(num) == "number", "Bad argument #2 to 'argcheck' (number expected)")
    
    for i = 1, select("#", ...) do
        if type(value) == select(i, ...) then
            return
        end
    end
    
    local types = string.join(", ", ...)
    local name = string.match(debugstack(2, 2, 0), ": in function [`<](.-)['>]")
    error(string.format("Bad argument #%d to '%s' (%s expected, got %s)", num, name, types, type(value)), 3)
end

-- Style registration
function oUF:RegisterStyle(name, func)
    argcheck(name, 1, "string")
    argcheck(func, 2, "function")
    
    styles[name] = func
end

-- Set active style
function oUF:SetActiveStyle(name)
    argcheck(name, 1, "string")
    
    if not styles[name] then
        error("oUF: Style '" .. name .. "' does not exist")
    end
    
    activeStyle = name
end

-- Spawn unit frames
function oUF:Spawn(unit, name)
    argcheck(unit, 1, "string")
    argcheck(name, 2, "string", "nil")
    
    if not activeStyle then
        error("oUF: No active style has been set")
    end
    
    -- Create the frame
    local frame = CreateFrame("Button", name or "oUF_" .. unit:gsub("^%l", string.upper), UIParent, "SecureUnitButtonTemplate")
    frame.unit = unit
    frame.id = unit
    
    -- Set up secure attributes
    frame:SetAttribute("unit", unit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "menu")
    frame:SetAttribute("toggleForVehicle", true)
    
    -- Register with the header system
    RegisterUnitWatch(frame)
    
    -- Apply the style
    styles[activeStyle](frame, unit)
    
    -- Store the frame
    objects[frame] = true
    
    -- Set up update functions
    frame.UpdateAllElements = function(self)
        if self.Health then
            self.Health:SetMinMaxValues(0, UnitHealthMax(unit))
            self.Health:SetValue(UnitHealth(unit))
        end
        
        if self.Power then
            self.Power:SetMinMaxValues(0, UnitPowerMax(unit))
            self.Power:SetValue(UnitPower(unit))
        end
        
        if self.Name then
            self.Name:SetText(UnitName(unit) or "")
        end
        
        if self.Level then
            self.Level:SetText(UnitLevel(unit) or "")
        end
        
        -- Call post-update functions if they exist
        if ns.modules.UnitFrames then
            if ns.modules.UnitFrames.PostUpdateHealth then
                ns.modules.UnitFrames.PostUpdateHealth(self, unit)
            end
            if ns.modules.UnitFrames.PostUpdatePower then
                ns.modules.UnitFrames.PostUpdatePower(self, unit)
            end
            if ns.modules.UnitFrames.PostUpdateName then
                ns.modules.UnitFrames.PostUpdateName(self, unit)
            end
        end
    end
    
    -- Set up event handling
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
            if self.Health then
                self.Health:SetMinMaxValues(0, UnitHealthMax(unit))
                self.Health:SetValue(UnitHealth(unit))
            end
        elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" then
            if self.Power then
                self.Power:SetMinMaxValues(0, UnitPowerMax(unit))
                self.Power:SetValue(UnitPower(unit))
            end
        elseif event == "UNIT_NAME_UPDATE" then
            if self.Name then
                self.Name:SetText(UnitName(unit) or "")
            end
        elseif event == "UNIT_LEVEL" then
            if self.Level then
                self.Level:SetText(UnitLevel(unit) or "")
            end
        end
    end)
    
    -- Register events
    frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
    frame:RegisterUnitEvent("UNIT_LEVEL", unit)
    
    -- Initial update
    frame:UpdateAllElements()
    
    return frame
end

-- Spawn header for party/raid frames
function oUF:SpawnHeader(name, template, ...)
    argcheck(name, 1, "string")
    argcheck(template, 2, "string", "nil")
    
    local header = CreateFrame("Frame", name, UIParent, template or "SecureGroupHeaderTemplate")
    
    -- Set up header attributes
    header:SetAttribute("template", "SecureUnitButtonTemplate")
    
    -- Apply additional attributes
    for i = 1, select("#", ...) do
        local attribute = select(i, ...)
        if type(attribute) == "table" then
            for key, value in pairs(attribute) do
                header:SetAttribute(key, value)
            end
        end
    end
    
    return header
end

-- Add factory for elements
function oUF:AddElement(name, update, enable, disable)
    argcheck(name, 1, "string")
    argcheck(update, 2, "function", "nil")
    argcheck(enable, 3, "function", "nil")
    argcheck(disable, 4, "function", "nil")
    
    -- Element registration would go here in a full implementation
end

-- Get all objects
function oUF:Objects()
    return pairs(objects)
end

-- Make oUF globally available
_G.oUF = oUF

-- Export to DivinicalUI namespace
DivinicalUI.oUF = oUF

return oUF