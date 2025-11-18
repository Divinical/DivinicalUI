-- Configuration framework for DivinicalUI
local AddonName, DivinicalUI = ...

-- Config module
local Config = {}

-- Settings panel reference
local settingsPanel
local settingsCategory

-- Initialize config module
function Config:Initialize()
    self:RegisterSettingsPanel()
end

-- Post-initialization
function Config:PostInitialize()
    -- Called after all modules are loaded
end

-- Register settings panel with Blizzard's Settings API
function Config:RegisterSettingsPanel()
    -- Create a frame for the settings panel (required by Settings API)
    settingsPanel = CreateFrame("Frame")
    settingsPanel.name = "DivinicalUI"

    -- Add content to the panel
    local title = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("DivinicalUI Settings")

    local subtitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Version " .. DivinicalUI.version)

    local description = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    description:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)
    description:SetText("Advanced unit frames and targeting system")

    -- Register with Settings API
    settingsCategory = Settings.RegisterCanvasLayoutCategory(settingsPanel, "DivinicalUI")
    settingsCategory.ID = "DivinicalUI"
    Settings.RegisterAddOnCategory(settingsCategory)
end

-- Open configuration panel
function Config:OpenConfig()
    Settings.OpenToCategory("DivinicalUI")
end

-- Create basic settings options
function Config:CreateOptions()
    local options = {}
    
    -- General section
    table.insert(options, {
        type = "Header",
        name = "General Settings"
    })
    
    table.insert(options, {
        type = "Checkbox",
        name = "Enable Unit Frames",
        tooltip = "Enable or disable all unit frames",
        get = function() return DivinicalUI.db.profile.unitframes.player.enabled end,
        set = function(value) 
            DivinicalUI.db.profile.unitframes.player.enabled = value
            DivinicalUI.db.profile.unitframes.target.enabled = value
        end
    })
    
    -- Player frame section
    table.insert(options, {
        type = "Header",
        name = "Player Frame"
    })
    
    table.insert(options, {
        type = "Slider",
        name = "Width",
        min = 100,
        max = 400,
        step = 10,
        get = function() return DivinicalUI.db.profile.unitframes.player.width end,
        set = function(value) 
            DivinicalUI.db.profile.unitframes.player.width = value
            if DivinicalUI.modules.UnitFrames then
                DivinicalUI.modules.UnitFrames:UpdatePlayerFrame()
            end
        end
    })
    
    table.insert(options, {
        type = "Slider",
        name = "Height",
        min = 20,
        max = 100,
        step = 5,
        get = function() return DivinicalUI.db.profile.unitframes.player.height end,
        set = function(value) 
            DivinicalUI.db.profile.unitframes.player.height = value
            if DivinicalUI.modules.UnitFrames then
                DivinicalUI.modules.UnitFrames:UpdatePlayerFrame()
            end
        end
    })
    
    -- Target frame section
    table.insert(options, {
        type = "Header",
        name = "Target Frame"
    })
    
    table.insert(options, {
        type = "Slider",
        name = "Width",
        min = 100,
        max = 400,
        step = 10,
        get = function() return DivinicalUI.db.profile.unitframes.target.width end,
        set = function(value) 
            DivinicalUI.db.profile.unitframes.target.width = value
            if DivinicalUI.modules.UnitFrames then
                DivinicalUI.modules.UnitFrames:UpdateTargetFrame()
            end
        end
    })
    
    table.insert(options, {
        type = "Slider",
        name = "Height",
        min = 20,
        max = 100,
        step = 5,
        get = function() return DivinicalUI.db.profile.unitframes.target.height end,
        set = function(value) 
            DivinicalUI.db.profile.unitframes.target.height = value
            if DivinicalUI.modules.UnitFrames then
                DivinicalUI.modules.UnitFrames:UpdateTargetFrame()
            end
        end
    })
    
    -- Action buttons
    table.insert(options, {
        type = "Header",
        name = "Actions"
    })
    
    table.insert(options, {
        type = "Button",
        name = "Reset to Defaults",
        func = function()
            DivinicalUI.db.profile = DivinicalUI.defaults.profile
            ReloadUI()
        end
    })
    
    return options
end

-- Register module
DivinicalUI:RegisterModule("Config", Config)