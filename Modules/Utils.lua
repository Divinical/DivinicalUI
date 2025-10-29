-- Utility functions for DivinicalUI
local AddonName, DivinicalUI = ...

-- Utils module
local Utils = {}

-- Color utilities
Utils.Colors = {}

-- RGB to hex conversion
function Utils.Colors.RGBToHex(r, g, b)
    return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- Hex to RGB conversion
function Utils.Colors.HexToRGB(hex)
    if type(hex) ~= "string" then return 1, 1, 1 end
    
    local r, g, b = hex:match("|cff(%x%x)(%x%x)(%x%x)")
    if r and g and b then
        return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255
    end
    
    return 1, 1, 1
end

-- Get class color
function Utils.Colors.GetClassColor(class)
    local colors = RAID_CLASS_COLORS[class]
    if colors then
        return colors.r, colors.g, colors.b
    end
    return 1, 1, 1
end

-- Get reaction color
function Utils.Colors.GetReactionColor(reaction)
    local colors = {
        [1] = {0.8, 0.2, 0.2}, -- Hostile
        [2] = {0.8, 0.4, 0.2}, -- Unfriendly
        [3] = {0.8, 0.8, 0.2}, -- Neutral
        [4] = {0.2, 0.8, 0.2}, -- Friendly
        [5] = {0.2, 0.8, 0.2}, -- Honored
        [6] = {0.2, 0.8, 0.2}, -- Revered
        [7] = {0.2, 0.8, 0.2}, -- Exalted
        [8] = {0.2, 0.8, 0.2}, -- Paragon
    }
    
    local color = colors[reaction] or colors[3]
    return color[1], color[2], color[3]
end

-- Power type colors
function Utils.Colors.GetPowerColor(powerType)
    local colors = {
        MANA = {0.2, 0.4, 0.8},
        RAGE = {0.8, 0.2, 0.2},
        FOCUS = {1.0, 0.5, 0.25},
        ENERGY = {1.0, 0.8, 0.2},
        COMBO_POINTS = {1.0, 0.8, 0.2},
        RUNES = {0.5, 0.5, 0.5},
        RUNIC_POWER = {0.2, 0.6, 0.8},
        SOUL_SHARDS = {0.6, 0.2, 0.8},
        LUNAR_POWER = {0.8, 0.8, 0.2},
        HOLY_POWER = {0.8, 0.6, 0.2},
        MAELSTROM = {0.2, 0.6, 0.8},
        CHI = {0.8, 0.6, 0.2},
        INSANITY = {0.6, 0.2, 0.8},
        ARCANE_CHARGES = {0.2, 0.6, 0.8},
        FURY = {0.8, 0.2, 0.2},
        PAIN = {1.0, 0.5, 0.25}
    }
    
    local color = colors[powerType] or {0.5, 0.5, 0.5}
    return color[1], color[2], color[3]
end

-- String utilities
Utils.Strings = {}

-- Format number with commas
function Utils.Strings.FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fm", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fk", num / 1000)
    else
        return tostring(num)
    end
end

-- Truncate string
function Utils.Strings.Truncate(text, maxLength)
    if not text then return "" end
    if #text <= maxLength then return text end
    return text:sub(1, maxLength - 3) .. "..."
end

-- Capitalize first letter
function Utils.Strings.Capitalize(text)
    if not text or text == "" then return text end
    return text:sub(1, 1):upper() .. text:sub(2):lower()
end

-- Table utilities
Utils.Tables = {}

-- Deep copy table
function Utils.Tables.DeepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = Utils.Tables.DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

-- Check if table contains value
function Utils.Tables.Contains(table, value)
    for _, v in pairs(table) do
        if v == value then return true end
    end
    return false
end

-- Get table size
function Utils.Tables.Size(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Math utilities
Utils.Math = {}

-- Round number
function Utils.Math.Round(num, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(num * mult + 0.5) / mult
end

-- Clamp number between min and max
function Utils.Math.Clamp(num, min, max)
    return math.max(min, math.min(max, num))
end

-- Lerp between two values
function Utils.Math.Lerp(from, to, progress)
    return from + (to - from) * progress
end

-- Frame utilities
Utils.Frames = {}

-- Create backdrop table
function Utils.Frames.CreateBackdrop(edgeSize, edgeFile, bgFile)
    return {
        edgeFile = edgeFile or "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = edgeSize or 16,
        bgFile = bgFile or "Interface\\DialogFrame\\UI-DialogBox-Background",
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
end

-- Set frame position
function Utils.Frames.SetPosition(frame, anchor, relativeTo, relativePoint, x, y)
    frame:ClearAllPoints()
    if relativeTo then
        frame:SetPoint(anchor or "TOPLEFT", relativeTo, relativePoint or "TOPLEFT", x or 0, y or 0)
    else
        frame:SetPoint(anchor or "TOPLEFT", x or 0, y or 0)
    end
end

-- Create font string
function Utils.Frames.CreateFontString(parent, name, font, size, flags)
    local fontString = parent:CreateFontString(name or nil, "OVERLAY")
    fontString:SetFont(font or "Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 
                      size or 12, 
                      flags or "OUTLINE")
    return fontString
end

-- Unit utilities
Utils.Units = {}

-- Get unit health percentage
function Utils.Units.GetHealthPercent(unit)
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    if maxHealth == 0 then return 0 end
    return (health / maxHealth) * 100
end

-- Get unit power percentage
function Utils.Units.GetPowerPercent(unit)
    local power = UnitPower(unit)
    local maxPower = UnitPowerMax(unit)
    if maxPower == 0 then return 0 end
    return (power / maxPower) * 100
end

-- Check if unit is dead or ghost
function Utils.Units.IsDeadOrGhost(unit)
    return UnitIsDead(unit) or UnitIsGhost(unit)
end

-- Check if unit is in range
function Utils.Units.IsInRange(unit, range)
    return UnitInRange(unit) and CheckInteractDistance(unit, range)
end

-- Get unit classification
function Utils.Units.GetClassification(unit)
    local classification = UnitClassification(unit)
    if classification == "worldboss" then
        return "Boss"
    elseif classification == "rareelite" then
        return "Rare+"
    elseif classification == "elite" then
        return "Elite"
    elseif classification == "rare" then
        return "Rare"
    else
        return "Normal"
    end
end

-- Debug utilities
Utils.Debug = {}

-- Print debug message
function Utils.Debug.Print(message, level)
    level = level or "INFO"
    local colors = {
        INFO = "|cff33ff99",
        WARN = "|cffffff00",
        ERROR = "|cffff0000",
        DEBUG = "|cff999999"
    }
    
    local color = colors[level] or colors.INFO
    print(color .. "[DivinicalUI] " .. level .. ":|r " .. tostring(message))
end

-- Print table contents
function Utils.Debug.PrintTable(table, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    
    for key, value in pairs(table) do
        if type(value) == "table" then
            print(prefix .. tostring(key) .. ":")
            Utils.Debug.PrintTable(value, indent + 1)
        else
            print(prefix .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

-- Initialize utils module
function Utils:Initialize()
    self.Debug.Print("Utils module initialized", "DEBUG")
end

-- Register module
DivinicalUI:RegisterModule("Utils", Utils)