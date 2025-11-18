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
        }
    }
}

-- Initialize database
local function InitializeDatabase()
    if not DivinicalDB then
        DivinicalDB = {}
    end
    
    if not DivinicalDB.profile then
        DivinicalDB.profile = {}
    end
    
    -- Merge defaults
    for key, value in pairs(defaults.profile) do
        if DivinicalDB.profile[key] == nil then
            DivinicalDB.profile[key] = value
        end
    end
    
    DivinicalUI.db = DivinicalDB
end

-- Module registration
function DivinicalUI:RegisterModule(name, module)
    self.modules[name] = module
    -- Expose module at top level for easy access (e.g., DivinicalUI.Utils)
    self[name] = module
    -- Don't initialize immediately - will be done in Initialize() in the correct order
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
        if msg == "" then
            print("|cff33ff99DivinicalUI|r Commands:")
            print("/div config - Open configuration")
            print("/div reset - Reset to defaults")
            print("/div reload - Reload UI")
        elseif msg == "config" then
            if self.modules.Config and self.modules.Config.OpenConfig then
                self.modules.Config:OpenConfig()
            else
                print("Configuration module not loaded yet.")
            end
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
end

-- Register core events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")