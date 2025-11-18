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

-- Database defaults
local defaults = {
    profile = {
        unitframes = {
            player = {
                enabled = true,
                width = 200,
                height = 50,
                position = {"CENTER", -200, -200}
            },
            target = {
                enabled = true,
                width = 200,
                height = 50,
                position = {"CENTER", 200, -200}
            }
        },
        colors = {
            health = {0.2, 0.8, 0.2},
            power = {0.2, 0.4, 0.8},
            reaction = {
                [1] = {0.8, 0.2, 0.2}, -- Hostile
                [2] = {0.8, 0.4, 0.2}, -- Unfriendly
                [3] = {0.8, 0.8, 0.2}, -- Neutral
                [4] = {0.2, 0.8, 0.2}, -- Friendly
                [5] = {0.2, 0.8, 0.2}, -- Honored
                [6] = {0.2, 0.8, 0.2}, -- Revered
                [7] = {0.2, 0.8, 0.2}, -- Exalted
            }
        },
        sounds = {
            enabled = true,
            lowHealth = true,
            targetChanged = true,
            combatLog = false,
            volume = 1.0
        }
    }
}

-- Initialize database with profile support
local function InitializeDatabase()
    if not DivinicalDB then
        DivinicalDB = {}
    end

    -- Initialize profiles structure
    if not DivinicalDB.profiles then
        DivinicalDB.profiles = {}
    end

    -- Set current profile (default to "Default")
    if not DivinicalDB.currentProfile then
        DivinicalDB.currentProfile = "Default"
    end

    -- Ensure current profile exists
    if not DivinicalDB.profiles[DivinicalDB.currentProfile] then
        DivinicalDB.profiles[DivinicalDB.currentProfile] = {}
    end

    -- Set active profile reference
    DivinicalDB.profile = DivinicalDB.profiles[DivinicalDB.currentProfile]

    -- Merge defaults into active profile
    for key, value in pairs(defaults.profile) do
        if DivinicalDB.profile[key] == nil then
            DivinicalDB.profile[key] = value
        end
    end

    -- Create database object with profile management methods
    local db = {
        profile = DivinicalDB.profile,
        profiles = DivinicalDB.profiles,

        -- Get current profile name
        GetCurrentProfile = function(self)
            return DivinicalDB.currentProfile
        end,

        -- Set/switch to a profile
        SetProfile = function(self, profileName)
            if not DivinicalDB.profiles[profileName] then
                -- Create new profile with defaults
                DivinicalDB.profiles[profileName] = {}
                for key, value in pairs(defaults.profile) do
                    DivinicalDB.profiles[profileName][key] = CopyTable(value)
                end
            end

            DivinicalDB.currentProfile = profileName
            DivinicalDB.profile = DivinicalDB.profiles[profileName]
            self.profile = DivinicalDB.profile
        end,

        -- Delete a profile
        DeleteProfile = function(self, profileName)
            if profileName == "Default" then
                return false
            end

            DivinicalDB.profiles[profileName] = nil

            -- Switch to Default if deleting current profile
            if DivinicalDB.currentProfile == profileName then
                self:SetProfile("Default")
            end

            return true
        end,

        -- Copy a profile
        CopyProfile = function(self, targetName, sourceName)
            sourceName = sourceName or DivinicalDB.currentProfile

            if not DivinicalDB.profiles[sourceName] then
                return false
            end

            DivinicalDB.profiles[targetName] = CopyTable(DivinicalDB.profiles[sourceName])
            return true
        end,

        -- Get list of all profile names
        GetProfiles = function(self)
            local profileList = {}
            for name, _ in pairs(DivinicalDB.profiles) do
                table.insert(profileList, name)
            end
            return profileList
        end
    }

    DivinicalUI.db = db
end

-- Deep copy a table with circular reference protection
function CopyTable(src, dest, seen)
    if type(src) ~= "table" then
        return src
    end

    -- Avoid infinite recursion by tracking seen tables
    seen = seen or {}
    if seen[src] then
        return seen[src]
    end

    dest = dest or {}
    seen[src] = dest

    for k, v in pairs(src) do
        -- Skip metatables to avoid circular references
        if k ~= "__index" and k ~= "__newindex" then
            if type(v) == "table" then
                dest[k] = CopyTable(v, nil, seen)
            else
                dest[k] = v
            end
        end
    end

    return dest
end

-- Module registration
function DivinicalUI:RegisterModule(name, module)
    self.modules[name] = module
    -- Module initialization happens in DivinicalUI:Initialize() after database is ready
end

-- Initialization
function DivinicalUI:Initialize()
    -- Initialize database
    InitializeDatabase()

    -- Initialize Utils module first (required by other modules)
    if self.modules.Utils and self.modules.Utils.Initialize then
        self.modules.Utils:Initialize()
    end

    -- Load other modules
    for name, module in pairs(self.modules) do
        if name ~= "Utils" and module.Initialize then
            module:Initialize()
        end
    end

    -- Setup slash commands
    self:SetupSlashCommands()

    print("|cff33ff99DivinicalUI|r v" .. self.version .. " loaded!")
end

-- Slash command setup
function DivinicalUI:SetupSlashCommands()
    SLASH_DIVINICAL1 = "/divinical"
    SLASH_DIVINICAL2 = "/div"
    
    SlashCmdList["DIVINICAL"] = function(msg)
        if msg == "" or msg == "config" then
            -- Open config panel
            if self.modules.Config and self.modules.Config.OpenConfig then
                self.modules.Config:OpenConfig()
            else
                print("Configuration module not loaded yet.")
            end
        elseif msg == "help" then
            print("|cff33ff99DivinicalUI|r Commands:")
            print("/div - Open configuration")
            print("/div config - Open configuration")
            print("/div reset - Reset to defaults")
            print("/div reload - Reload UI")
        elseif msg == "reset" then
            DivinicalDB = nil
            ReloadUI()
        elseif msg == "reload" then
            ReloadUI()
        end
    end
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if DivinicalUI[event] then
        DivinicalUI[event](DivinicalUI, ...)
    end
end)

-- ADDON_LOADED event
function DivinicalUI:ADDON_LOADED(addonName)
    if addonName == AddonName then
        self:Initialize()
    end
end

-- PLAYER_LOGIN event
function DivinicalUI:PLAYER_LOGIN()
    -- Final initialization after player data is available
    for name, module in pairs(self.modules) do
        if module.PostInitialize then
            module:PostInitialize()
        end
    end
    
    -- Initialize sound system
    self:InitializeSoundSystem()
end

-- Sound system initialization
function DivinicalUI:InitializeSoundSystem()
    -- Register sound events if enabled
    if self.db.profile.sounds.enabled then
        eventFrame:RegisterEvent("UNIT_HEALTH")
        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        if self.modules.Utils then
            self.modules.Utils.Debug.Print("Sound system initialized", "INFO")
        end
    end
end

-- Play sound with volume control
function DivinicalUI:PlaySound(soundName)
    if not self.db.profile.sounds.enabled then return end
    
    if self.modules.Media and self.modules.Media.PlaySound then
        self.modules.Media:PlaySound(soundName)
    end
end

-- UNIT_HEALTH event - low health warning
function DivinicalUI:UNIT_HEALTH(unit, ...)
    if unit == "player" and self.db.profile.sounds.lowHealth then
        local health = UnitHealth(unit) / UnitHealthMax(unit)
        if health <= 0.2 and health > 0 then
            self:PlaySound("DivinicalUI Alert")
        end
    end
end

-- PLAYER_TARGET_CHANGED event
function DivinicalUI:PLAYER_TARGET_CHANGED()
    if self.db.profile.sounds.targetChanged then
        if UnitExists("target") then
            local reaction = UnitReaction("target", "player")
            if reaction and reaction <= 3 then -- Hostile, Unfriendly, or Neutral
                self:PlaySound("DivinicalUI Ready")
            end
        end
    end
end

-- COMBAT_LOG_EVENT_UNFILTERED event
function DivinicalUI:COMBAT_LOG_EVENT_UNFILTERED()
    if not self.db.profile.sounds.combatLog then return end
    
    local timestamp, event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo()
    
    -- Play sound for important combat events
    if event == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player") then
        self:PlaySound("DivinicalUI Alert")
    elseif event == "UNIT_DIED" and destGUID == UnitGUID("target") then
        self:PlaySound("DivinicalUI Ready")
    end
end

-- Register core events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")