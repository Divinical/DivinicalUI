-- Profile management system for DivinicalUI
local AddonName, DivinicalUI = ...

-- Profiles module
local Profiles = {}

-- Current profile name
local currentProfile = "Default"

-- Profile storage
local profileData = {}

-- Initialize profiles module
function Profiles:Initialize()
    self:LoadProfiles()
    self:SetupProfileEvents()
end

-- Load existing profiles from database
function Profiles:LoadProfiles()
    if not DivinicalUI.db.profiles then
        DivinicalUI.db.profiles = {}
    end
    
    if not DivinicalUI.db.currentProfile then
        DivinicalUI.db.currentProfile = "Default"
    end
    
    currentProfile = DivinicalUI.db.currentProfile
    profileData = DivinicalUI.db.profiles
    
    -- Ensure current profile exists
    if not profileData[currentProfile] then
        profileData[currentProfile] = CopyTable(DivinicalUI.defaults.profile)
    end
end

-- Setup profile-related events
function Profiles:SetupProfileEvents()
    -- Listen for spec changes to potentially switch profiles
    DivinicalUI.eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
end

-- Handle specialization changes
function Profiles:PLAYER_SPECIALIZATION_CHANGED(unitID)
    if unitID == "player" then
        -- Auto-switch profile based on spec (optional feature)
        local specIndex = GetSpecialization()
        if specIndex then
            local _, specName = GetSpecializationInfo(specIndex)
            local specProfile = specName .. " Spec"
            
            -- Auto-create spec profile if it doesn't exist
            if not profileData[specProfile] then
                self:CreateProfile(specProfile, true)
            end
            
            -- Optionally auto-switch to spec profile
            -- self:SwitchProfile(specProfile)
        end
    end
end

-- Create a new profile
function Profiles:CreateProfile(name, copyCurrent)
    if not name or name == "" then
        return false, "Profile name cannot be empty"
    end
    
    if profileData[name] then
        return false, "Profile already exists"
    end
    
    if copyCurrent then
        profileData[name] = CopyTable(profileData[currentProfile])
    else
        profileData[name] = CopyTable(DivinicalUI.defaults.profile)
    end
    
    print("|cff33ff99DivinicalUI|r: Created profile '" .. name .. "'")
    return true
end

-- Delete a profile
function Profiles:DeleteProfile(name)
    if not name or name == "" then
        return false, "Profile name cannot be empty"
    end
    
    if name == "Default" then
        return false, "Cannot delete Default profile"
    end
    
    if name == currentProfile then
        return false, "Cannot delete currently active profile"
    end
    
    if not profileData[name] then
        return false, "Profile does not exist"
    end
    
    profileData[name] = nil
    print("|cff33ff99DivinicalUI|r: Deleted profile '" .. name .. "'")
    return true
end

-- Switch to a different profile
function Profiles:SwitchProfile(name)
    if not name or name == "" then
        return false, "Profile name cannot be empty"
    end
    
    if not profileData[name] then
        return false, "Profile does not exist"
    end
    
    -- Save current profile data
    profileData[currentProfile] = CopyTable(DivinicalUI.db.profile)
    
    -- Switch to new profile
    currentProfile = name
    DivinicalUI.db.currentProfile = name
    DivinicalUI.db.profile = CopyTable(profileData[name])
    
    -- Notify modules of profile change
    for moduleName, module in pairs(DivinicalUI.modules) do
        if module.OnProfileChanged then
            module:OnProfileChanged(name)
        end
    end
    
    print("|cff33ff99DivinicalUI|r: Switched to profile '" .. name .. "'")
    return true
end

-- Get current profile name
function Profiles:GetCurrentProfile()
    return currentProfile
end

-- Get list of all profiles
function Profiles:GetProfileList()
    local list = {}
    for name, _ in pairs(profileData) do
        table.insert(list, name)
    end
    return list
end

-- Copy settings from one profile to another
function Profiles:CopyProfile(fromName, toName)
    if not profileData[fromName] then
        return false, "Source profile does not exist"
    end
    
    if not profileData[toName] then
        return false, "Target profile does not exist"
    end
    
    profileData[toName] = CopyTable(profileData[fromName])
    
    -- If copying to current profile, update active settings
    if toName == currentProfile then
        DivinicalUI.db.profile = CopyTable(profileData[toName])
        
        -- Notify modules of profile change
        for moduleName, module in pairs(DivinicalUI.modules) do
            if module.OnProfileChanged then
                module:OnProfileChanged(currentProfile)
            end
        end
    end
    
    print("|cff33ff99DivinicalUI|r: Copied settings from '" .. fromName .. "' to '" .. toName .. "'")
    return true
end

-- Export profile to string
function Profiles:ExportProfile(name)
    name = name or currentProfile
    
    if not profileData[name] then
        return nil, "Profile does not exist"
    end
    
    local exportData = {
        version = DivinicalUI.version,
        profileName = name,
        timestamp = date("%Y-%m-%d %H:%M:%S"),
        data = profileData[name]
    }
    
    -- Convert to string (simplified serialization)
    local serialized = "DivinicalUI Profile Export\n"
    serialized = serialized .. "Version: " .. exportData.version .. "\n"
    serialized = serialized .. "Profile: " .. exportData.profileName .. "\n"
    serialized = serialized .. "Timestamp: " .. exportData.timestamp .. "\n"
    serialized = serialized .. "Data: " .. strsub(tostring(exportData.data), 1, 1000)
    
    return serialized
end

-- Import profile from string
function Profiles:ImportProfile(data, newName)
    if not data or data == "" then
        return false, "No data to import"
    end
    
    if not strfind(data, "DivinicalUI Profile Export") then
        return false, "Invalid import data format"
    end
    
    -- In a full implementation, this would parse and validate the data
    -- For now, create a new profile with imported settings
    local profileName = newName or "Imported " .. date("%Y%m%d_%H%M%S")
    
    local success, error = self:CreateProfile(profileName, false)
    if not success then
        return false, error
    end
    
    print("|cff33ff99DivinicalUI|r: Imported profile '" .. profileName .. "'")
    return true
end

-- Reset current profile to defaults
function Profiles:ResetCurrentProfile()
    profileData[currentProfile] = CopyTable(DivinicalUI.defaults.profile)
    DivinicalUI.db.profile = CopyTable(profileData[currentProfile])
    
    -- Notify modules of profile change
    for moduleName, module in pairs(DivinicalUI.modules) do
        if module.OnProfileChanged then
            module:OnProfileChanged(currentProfile)
        end
    end
    
    print("|cff33ff99DivinicalUI|r: Reset profile '" .. currentProfile .. "' to defaults")
end

-- Register module
DivinicalUI:RegisterModule("Profiles", Profiles)