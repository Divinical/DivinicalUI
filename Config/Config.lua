-- Configuration framework for DivinicalUI
local AddonName, DivinicalUI = ...

-- Config module
local Config = {}

-- Settings categories storage
Config.categories = {}
Config.panels = {}

-- Preview system state
Config.previewMode = true  -- Enable real-time preview by default
Config.pendingUpdates = {}  -- Queue for debounced updates
Config.updateTimers = {}  -- Timers for debounced updates

-- Initialize config module
function Config:Initialize()
    self:RegisterSettingsPanel()
end

-- Post-initialization
function Config:PostInitialize()
    -- Called after all modules are loaded
end

-- Debounced update function for real-time preview
function Config:SchedulePreviewUpdate(updateKey, updateFunc, delay)
    delay = delay or 0.15  -- Default 150ms debounce

    -- Cancel existing timer if present
    if self.updateTimers[updateKey] then
        self.updateTimers[updateKey]:Cancel()
    end

    -- Store the update function
    self.pendingUpdates[updateKey] = updateFunc

    -- Create new timer
    self.updateTimers[updateKey] = C_Timer.NewTimer(delay, function()
        if self.pendingUpdates[updateKey] and self.previewMode then
            self.pendingUpdates[updateKey]()
            self.pendingUpdates[updateKey] = nil
        end
        self.updateTimers[updateKey] = nil
    end)
end

-- Apply update immediately (for checkboxes and buttons)
function Config:ApplyImmediateUpdate(updateFunc)
    if self.previewMode and updateFunc then
        updateFunc()
    end
end

-- Toggle preview mode
function Config:TogglePreviewMode(enabled)
    self.previewMode = enabled
    if enabled then
        print("|cff33ff99DivinicalUI|r: Real-time preview enabled")
    else
        print("|cff33ff99DivinicalUI|r: Real-time preview disabled. Changes will apply on UI reload.")
    end
end

-- Create a canvas frame for a settings category
function Config:CreateCategoryCanvas(name)
    local canvas = CreateFrame("Frame")
    canvas:SetSize(630, 560)
    canvas.name = name

    -- Add a title
    local title = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(name)
    canvas.title = title

    -- Add a description
    local desc = canvas:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetWidth(600)
    desc:SetJustifyH("LEFT")
    desc:SetText("Configure " .. name .. " settings below.")
    canvas.desc = desc

    -- Create a scroll frame for content
    local scrollFrame = CreateFrame("ScrollFrame", nil, canvas, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -30, 16)
    canvas.scrollFrame = scrollFrame

    -- Create content frame inside scroll
    local content = CreateFrame("Frame")
    content:SetSize(590, 1)
    scrollFrame:SetScrollChild(content)
    canvas.content = content

    -- Track last element position for auto-layout
    canvas.lastY = 0

    return canvas
end

-- Add a control to a canvas
function Config:AddControl(canvas, control, height)
    height = height or 32
    control:SetParent(canvas.content)
    control:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 4, -canvas.lastY)
    canvas.lastY = canvas.lastY + height

    -- Update content height
    canvas.content:SetHeight(math.max(canvas.lastY + 20, 500))
end

-- Register settings panel with Blizzard's Settings API
function Config:RegisterSettingsPanel()
    -- Create General category canvas
    local generalCanvas = self:CreateCategoryCanvas("General")
    generalCanvas.desc:SetText("General addon settings and basic configuration.")
    self:PopulateGeneralSettings(generalCanvas)

    -- Register General category
    local generalCategory = Settings.RegisterCanvasLayoutCategory(generalCanvas, "DivinicalUI")
    generalCategory.ID = "DivinicalUI_General"
    Settings.RegisterAddOnCategory(generalCategory)
    self.categories.general = generalCategory
    self.panels.general = generalCanvas

    -- Create Unit Frames category canvas (overview page)
    local unitFramesCanvas = self:CreateCategoryCanvas("Unit Frames")
    unitFramesCanvas.desc:SetText("Configure unit frame appearance, positioning, and elements.")
    self:PopulateUnitFramesSettings(unitFramesCanvas)

    -- Register Unit Frames as main category
    local unitFramesCategory = Settings.RegisterCanvasLayoutCategory(unitFramesCanvas, "Unit Frames", "DivinicalUI")
    unitFramesCategory.ID = "DivinicalUI_UnitFrames"
    Settings.RegisterAddOnCategory(unitFramesCategory)
    self.categories.unitframes = unitFramesCategory
    self.panels.unitframes = unitFramesCanvas

    -- Create subcategories for different frame types
    self:CreateUnitFrameSubcategory("Player", "DivinicalUI_UnitFrames")
    self:CreateUnitFrameSubcategory("Target", "DivinicalUI_UnitFrames")
    self:CreateUnitFrameSubcategory("Party", "DivinicalUI_UnitFrames")
    self:CreateUnitFrameSubcategory("Raid", "DivinicalUI_UnitFrames")

    -- Create Raid Frames category canvas
    local raidCanvas = self:CreateCategoryCanvas("Raid Frames")
    raidCanvas.desc:SetText("Configure raid frame layout, sorting, and indicators.")
    self:PopulateRaidSettings(raidCanvas)

    local raidCategory = Settings.RegisterCanvasLayoutCategory(raidCanvas, "Raid Frames", "DivinicalUI")
    raidCategory.ID = "DivinicalUI_Raid"
    Settings.RegisterAddOnCategory(raidCategory)
    self.categories.raid = raidCategory
    self.panels.raid = raidCanvas

    -- Create Action Bars category canvas
    local actionBarsCanvas = self:CreateCategoryCanvas("Action Bars")
    actionBarsCanvas.desc:SetText("Configure action bar positioning, visibility, and appearance.")
    self:PopulateActionBarsSettings(actionBarsCanvas)

    local actionBarsCategory = Settings.RegisterCanvasLayoutCategory(actionBarsCanvas, "Action Bars", "DivinicalUI")
    actionBarsCategory.ID = "DivinicalUI_ActionBars"
    Settings.RegisterAddOnCategory(actionBarsCategory)
    self.categories.actionbars = actionBarsCategory
    self.panels.actionbars = actionBarsCanvas

    -- Create Themes category canvas
    local themesCanvas = self:CreateCategoryCanvas("Themes")
    themesCanvas.desc:SetText("Select and customize visual themes for the UI.")
    self:PopulateThemesSettings(themesCanvas)

    local themesCategory = Settings.RegisterCanvasLayoutCategory(themesCanvas, "Themes", "DivinicalUI")
    themesCategory.ID = "DivinicalUI_Themes"
    Settings.RegisterAddOnCategory(themesCategory)
    self.categories.themes = themesCategory
    self.panels.themes = themesCanvas

    -- Create Profiles category canvas
    local profilesCanvas = self:CreateCategoryCanvas("Profiles")
    profilesCanvas.desc:SetText("Manage profiles, import/export settings, and apply presets.")
    self:PopulateProfilesSettings(profilesCanvas)

    local profilesCategory = Settings.RegisterCanvasLayoutCategory(profilesCanvas, "Profiles", "DivinicalUI")
    profilesCategory.ID = "DivinicalUI_Profiles"
    Settings.RegisterAddOnCategory(profilesCategory)
    self.categories.profiles = profilesCategory
    self.panels.profiles = profilesCanvas

    -- Create Advanced category canvas
    local advancedCanvas = self:CreateCategoryCanvas("Advanced")
    advancedCanvas.desc:SetText("Advanced options, performance settings, and developer tools.")
    self:PopulateAdvancedSettings(advancedCanvas)

    local advancedCategory = Settings.RegisterCanvasLayoutCategory(advancedCanvas, "Advanced", "DivinicalUI")
    advancedCategory.ID = "DivinicalUI_Advanced"
    Settings.RegisterAddOnCategory(advancedCategory)
    self.categories.advanced = advancedCategory
    self.panels.advanced = advancedCanvas
end

-- Create a unit frame subcategory dynamically
function Config:CreateUnitFrameSubcategory(frameName, parentID)
    local canvas = self:CreateCategoryCanvas(frameName .. " Frame")
    canvas.desc:SetText("Configure " .. frameName:lower() .. " frame settings and appearance.")

    -- Populate with frame-specific settings
    self:PopulateFrameTypeSettings(canvas, frameName:lower())

    -- Register as subcategory under Unit Frames
    local category = Settings.RegisterCanvasLayoutCategory(canvas, frameName, parentID)
    category.ID = "DivinicalUI_UnitFrames_" .. frameName
    Settings.RegisterAddOnCategory(category)

    -- Store references
    self.categories["unitframes_" .. frameName:lower()] = category
    self.panels["unitframes_" .. frameName:lower()] = canvas

    return category
end

-- Populate frame type specific settings
function Config:PopulateFrameTypeSettings(canvas, frameType)
    -- Enable frame checkbox
    local enableFrame = self:CreateCheckbox(
        "Enable " .. frameType:gsub("^%l", string.upper) .. " Frame",
        function()
            if not DivinicalUI.db.profile.unitframes[frameType] then
                return false
            end
            return DivinicalUI.db.profile.unitframes[frameType].enabled or false
        end,
        function(value)
            if not DivinicalUI.db.profile.unitframes[frameType] then
                DivinicalUI.db.profile.unitframes[frameType] = {}
            end
            DivinicalUI.db.profile.unitframes[frameType].enabled = value
            if DivinicalUI.modules.UnitFrames then
                if DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"] then
                    DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"](DivinicalUI.modules.UnitFrames)
                end
            end
        end,
        "Enable or disable this frame"
    )
    self:AddControl(canvas, enableFrame, 32)

    -- Spacer
    self:AddControl(canvas, CreateFrame("Frame"), 16)

    -- Size header
    local sizeHeader = self:CreateHeader("Size")
    self:AddControl(canvas, sizeHeader, 24)

    -- Width slider
    local widthSlider = self:CreateSlider(
        "Width",
        100, 400, 10,
        function()
            if not DivinicalUI.db.profile.unitframes[frameType] then
                return 200
            end
            return DivinicalUI.db.profile.unitframes[frameType].width or 200
        end,
        function(value)
            if not DivinicalUI.db.profile.unitframes[frameType] then
                DivinicalUI.db.profile.unitframes[frameType] = {}
            end
            DivinicalUI.db.profile.unitframes[frameType].width = value
            if DivinicalUI.modules.UnitFrames then
                if DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"] then
                    DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"](DivinicalUI.modules.UnitFrames)
                end
            end
        end,
        "Frame width in pixels"
    )
    self:AddControl(canvas, widthSlider, 48)

    -- Height slider
    local heightSlider = self:CreateSlider(
        "Height",
        20, 100, 5,
        function()
            if not DivinicalUI.db.profile.unitframes[frameType] then
                return 40
            end
            return DivinicalUI.db.profile.unitframes[frameType].height or 40
        end,
        function(value)
            if not DivinicalUI.db.profile.unitframes[frameType] then
                DivinicalUI.db.profile.unitframes[frameType] = {}
            end
            DivinicalUI.db.profile.unitframes[frameType].height = value
            if DivinicalUI.modules.UnitFrames then
                if DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"] then
                    DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"](DivinicalUI.modules.UnitFrames)
                end
            end
        end,
        "Frame height in pixels"
    )
    self:AddControl(canvas, heightSlider, 48)

    -- Position header
    local posHeader = self:CreateHeader("Position")
    self:AddControl(canvas, posHeader, 24)

    -- X position slider
    local xPosSlider = self:CreateSlider(
        "X Position",
        -1000, 1000, 10,
        function()
            if not DivinicalUI.db.profile.unitframes[frameType] then
                return 0
            end
            return DivinicalUI.db.profile.unitframes[frameType].x or 0
        end,
        function(value)
            if not DivinicalUI.db.profile.unitframes[frameType] then
                DivinicalUI.db.profile.unitframes[frameType] = {}
            end
            DivinicalUI.db.profile.unitframes[frameType].x = value
            if DivinicalUI.modules.UnitFrames then
                if DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"] then
                    DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"](DivinicalUI.modules.UnitFrames)
                end
            end
        end,
        "Horizontal position offset"
    )
    self:AddControl(canvas, xPosSlider, 48)

    -- Y position slider
    local yPosSlider = self:CreateSlider(
        "Y Position",
        -1000, 1000, 10,
        function()
            if not DivinicalUI.db.profile.unitframes[frameType] then
                return 0
            end
            return DivinicalUI.db.profile.unitframes[frameType].y or 0
        end,
        function(value)
            if not DivinicalUI.db.profile.unitframes[frameType] then
                DivinicalUI.db.profile.unitframes[frameType] = {}
            end
            DivinicalUI.db.profile.unitframes[frameType].y = value
            if DivinicalUI.modules.UnitFrames then
                if DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"] then
                    DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"](DivinicalUI.modules.UnitFrames)
                end
            end
        end,
        "Vertical position offset"
    )
    self:AddControl(canvas, yPosSlider, 48)

    -- Colors header
    local colorHeader = self:CreateHeader("Colors")
    self:AddControl(canvas, colorHeader, 24)

    -- Health bar color picker
    local healthColor = self:CreateColorPicker(
        "Health Bar Color",
        function()
            if not DivinicalUI.db.profile.unitframes[frameType] then
                return 0, 1, 0, 1  -- Default green
            end
            local colors = DivinicalUI.db.profile.unitframes[frameType].healthColor or {0, 1, 0, 1}
            return colors[1], colors[2], colors[3], colors[4]
        end,
        function(r, g, b, a)
            if not DivinicalUI.db.profile.unitframes[frameType] then
                DivinicalUI.db.profile.unitframes[frameType] = {}
            end
            DivinicalUI.db.profile.unitframes[frameType].healthColor = {r, g, b, a}
            -- Update frame colors in real-time
            if DivinicalUI.modules.UnitFrames then
                if DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"] then
                    DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"](DivinicalUI.modules.UnitFrames)
                end
            end
        end,
        true,  -- Has alpha
        "Choose the color for the health bar"
    )
    self:AddControl(canvas, healthColor, 36)

    -- Power bar color picker
    local powerColor = self:CreateColorPicker(
        "Power Bar Color",
        function()
            if not DivinicalUI.db.profile.unitframes[frameType] then
                return 0, 0.5, 1, 1  -- Default blue
            end
            local colors = DivinicalUI.db.profile.unitframes[frameType].powerColor or {0, 0.5, 1, 1}
            return colors[1], colors[2], colors[3], colors[4]
        end,
        function(r, g, b, a)
            if not DivinicalUI.db.profile.unitframes[frameType] then
                DivinicalUI.db.profile.unitframes[frameType] = {}
            end
            DivinicalUI.db.profile.unitframes[frameType].powerColor = {r, g, b, a}
            -- Update frame colors in real-time
            if DivinicalUI.modules.UnitFrames then
                if DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"] then
                    DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"](DivinicalUI.modules.UnitFrames)
                end
            end
        end,
        true,  -- Has alpha
        "Choose the color for the power bar"
    )
    self:AddControl(canvas, powerColor, 36)

    -- Media header
    local mediaHeader = self:CreateHeader("Appearance")
    self:AddControl(canvas, mediaHeader, 24)

    -- Font dropdown
    local fontDropdown = self:CreateDropdown(
        "Font",
        {"Pixel", "Arial", "Friz Quadrata", "Morpheus"},  -- Add more fonts as available
        function()
            if not DivinicalUI.db.profile.unitframes[frameType] then
                return "Pixel"
            end
            return DivinicalUI.db.profile.unitframes[frameType].font or "Pixel"
        end,
        function(value)
            if not DivinicalUI.db.profile.unitframes[frameType] then
                DivinicalUI.db.profile.unitframes[frameType] = {}
            end
            DivinicalUI.db.profile.unitframes[frameType].font = value
            -- Update frame font in real-time
            if DivinicalUI.modules.UnitFrames then
                if DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"] then
                    DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"](DivinicalUI.modules.UnitFrames)
                end
            end
        end,
        "Select the font for frame text"
    )
    self:AddControl(canvas, fontDropdown, 50)

    -- Texture dropdown
    local textureDropdown = self:CreateDropdown(
        "Status Bar Texture",
        {"Default", "Smooth", "Minimalist", "Gradient"},
        function()
            if not DivinicalUI.db.profile.unitframes[frameType] then
                return "Default"
            end
            return DivinicalUI.db.profile.unitframes[frameType].texture or "Default"
        end,
        function(value)
            if not DivinicalUI.db.profile.unitframes[frameType] then
                DivinicalUI.db.profile.unitframes[frameType] = {}
            end
            DivinicalUI.db.profile.unitframes[frameType].texture = value
            -- Update frame texture in real-time
            if DivinicalUI.modules.UnitFrames then
                if DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"] then
                    DivinicalUI.modules.UnitFrames["Update" .. frameType:gsub("^%l", string.upper) .. "Frame"](DivinicalUI.modules.UnitFrames)
                end
            end
        end,
        "Select the texture for health/power bars"
    )
    self:AddControl(canvas, textureDropdown, 50)
end

-- Populate General settings
function Config:PopulateGeneralSettings(canvas)
    -- Enable addon checkbox
    local enableAddon = self:CreateCheckbox(
        "Enable DivinicalUI",
        function() return DivinicalUI.db.profile.enabled end,
        function(value)
            DivinicalUI.db.profile.enabled = value
            if value then
                print("|cff33ff99DivinicalUI|r: Addon enabled. Reload UI for changes to take effect.")
            else
                print("|cff33ff99DivinicalUI|r: Addon disabled. Reload UI for changes to take effect.")
            end
        end,
        "Enable or disable the entire addon"
    )
    self:AddControl(canvas, enableAddon, 32)

    -- Debug mode checkbox
    local debugMode = self:CreateCheckbox(
        "Enable Debug Mode",
        function() return DivinicalUI.db.profile.debug end,
        function(value)
            DivinicalUI.db.profile.debug = value
            print("|cff33ff99DivinicalUI|r: Debug mode " .. (value and "enabled" or "disabled"))
        end,
        "Show detailed debug messages in chat"
    )
    self:AddControl(canvas, debugMode, 32)

    -- Spacer
    self:AddControl(canvas, CreateFrame("Frame"), 16)

    -- Header for actions
    local actionsHeader = self:CreateHeader("Actions")
    self:AddControl(canvas, actionsHeader, 24)

    -- Reload UI button
    local reloadButton = self:CreateButton("Reload UI", function()
        ReloadUI()
    end, 120, 25)
    self:AddControl(canvas, reloadButton, 32)

    -- Reset to defaults button
    local resetButton = self:CreateButton("Reset to Defaults", function()
        StaticPopupDialogs["DIVINICALUI_RESET"] = {
            text = "Reset all DivinicalUI settings to defaults?\n\n|cffff0000This cannot be undone!|r",
            button1 = "Reset",
            button2 = "Cancel",
            OnAccept = function()
                DivinicalUI.db.profile = CopyTable(DivinicalUI.defaults.profile)
                print("|cff33ff99DivinicalUI|r: Settings reset to defaults.")
                ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("DIVINICALUI_RESET")
    end, 150, 25)
    self:AddControl(canvas, resetButton, 32)
end

-- Populate Unit Frames settings
function Config:PopulateUnitFramesSettings(canvas)
    -- Enable unit frames
    local enableFrames = self:CreateCheckbox(
        "Enable Unit Frames",
        function() return DivinicalUI.db.profile.unitframes.enabled end,
        function(value)
            DivinicalUI.db.profile.unitframes.enabled = value
            if DivinicalUI.modules.UnitFrames then
                DivinicalUI.modules.UnitFrames:UpdateAllFrames()
            end
        end,
        "Enable or disable all unit frames"
    )
    self:AddControl(canvas, enableFrames, 32)

    -- Spacer
    self:AddControl(canvas, CreateFrame("Frame"), 16)

    -- Player frame header
    local playerHeader = self:CreateHeader("Player Frame")
    self:AddControl(canvas, playerHeader, 24)

    -- Player frame width
    local playerWidth = self:CreateSlider(
        "Width",
        100, 400, 10,
        function() return DivinicalUI.db.profile.unitframes.player.width end,
        function(value)
            DivinicalUI.db.profile.unitframes.player.width = value
            if DivinicalUI.modules.UnitFrames then
                DivinicalUI.modules.UnitFrames:UpdatePlayerFrame()
            end
        end,
        "Player frame width"
    )
    self:AddControl(canvas, playerWidth, 48)

    -- Player frame height
    local playerHeight = self:CreateSlider(
        "Height",
        20, 100, 5,
        function() return DivinicalUI.db.profile.unitframes.player.height end,
        function(value)
            DivinicalUI.db.profile.unitframes.player.height = value
            if DivinicalUI.modules.UnitFrames then
                DivinicalUI.modules.UnitFrames:UpdatePlayerFrame()
            end
        end,
        "Player frame height"
    )
    self:AddControl(canvas, playerHeight, 48)

    -- Target frame header
    local targetHeader = self:CreateHeader("Target Frame")
    self:AddControl(canvas, targetHeader, 24)

    -- Target frame width
    local targetWidth = self:CreateSlider(
        "Width",
        100, 400, 10,
        function() return DivinicalUI.db.profile.unitframes.target.width end,
        function(value)
            DivinicalUI.db.profile.unitframes.target.width = value
            if DivinicalUI.modules.UnitFrames then
                DivinicalUI.modules.UnitFrames:UpdateTargetFrame()
            end
        end,
        "Target frame width"
    )
    self:AddControl(canvas, targetWidth, 48)

    -- Target frame height
    local targetHeight = self:CreateSlider(
        "Height",
        20, 100, 5,
        function() return DivinicalUI.db.profile.unitframes.target.height end,
        function(value)
            DivinicalUI.db.profile.unitframes.target.height = value
            if DivinicalUI.modules.UnitFrames then
                DivinicalUI.modules.UnitFrames:UpdateTargetFrame()
            end
        end,
        "Target frame height"
    )
    self:AddControl(canvas, targetHeight, 48)
end

-- Populate Raid settings (placeholder)
function Config:PopulateRaidSettings(canvas)
    local placeholder = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    placeholder:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 8, -8)
    placeholder:SetText("Raid frame settings coming soon...")
    placeholder:SetTextColor(0.6, 0.6, 0.6)
end

-- Populate Action Bars settings (placeholder)
function Config:PopulateActionBarsSettings(canvas)
    local placeholder = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    placeholder:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 8, -8)
    placeholder:SetText("Action bar settings coming soon...")
    placeholder:SetTextColor(0.6, 0.6, 0.6)
end

-- Populate Themes settings (placeholder)
function Config:PopulateThemesSettings(canvas)
    local placeholder = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    placeholder:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 8, -8)
    placeholder:SetText("Theme selection coming soon...")
    placeholder:SetTextColor(0.6, 0.6, 0.6)
end

-- Populate Profiles settings
function Config:PopulateProfilesSettings(canvas)
    -- Active Profile header
    local activeHeader = self:CreateHeader("Active Profile")
    self:AddControl(canvas, activeHeader, 24)

    -- Profile info text
    local profileInfo = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileInfo:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 8, -(canvas.lastY))
    profileInfo:SetJustifyH("LEFT")
    profileInfo:SetWidth(560)
    local currentProfile = "Default"
    if DivinicalUI.db and DivinicalUI.db.GetCurrentProfile then
        currentProfile = DivinicalUI.db:GetCurrentProfile()
    end
    profileInfo:SetText("Current Profile: |cff33ff99" .. currentProfile .. "|r")
    self:AddControl(canvas, CreateFrame("Frame"), 24)

    -- Profile management buttons
    local newProfileBtn = self:CreateButton("New Profile", function()
        StaticPopupDialogs["DIVINICALUI_NEW_PROFILE"] = {
            text = "Enter new profile name:",
            button1 = "Create",
            button2 = "Cancel",
            hasEditBox = true,
            OnAccept = function(self)
                local profileName = self.editBox:GetText()
                if profileName and profileName ~= "" then
                    DivinicalUI.db:SetProfile(profileName)
                    print("|cff33ff99DivinicalUI|r: Created and switched to profile: " .. profileName)
                    ReloadUI()
                end
            end,
            EditBoxOnEnterPressed = function(self)
                local parent = self:GetParent()
                local profileName = self:GetText()
                if profileName and profileName ~= "" then
                    DivinicalUI.db:SetProfile(profileName)
                    print("|cff33ff99DivinicalUI|r: Created and switched to profile: " .. profileName)
                    parent:Hide()
                    ReloadUI()
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("DIVINICALUI_NEW_PROFILE")
    end, 120, 25)
    newProfileBtn:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 4, -(canvas.lastY))
    canvas.lastY = canvas.lastY + 32

    local deleteProfileBtn = self:CreateButton("Delete Profile", function()
        local currentProfile = DivinicalUI.db:GetCurrentProfile()
        if currentProfile == "Default" then
            print("|cff33ff99DivinicalUI|r: Cannot delete Default profile.")
            return
        end
        StaticPopupDialogs["DIVINICALUI_DELETE_PROFILE"] = {
            text = "Delete profile '" .. currentProfile .. "'?\n\n|cffff0000This cannot be undone!|r",
            button1 = "Delete",
            button2 = "Cancel",
            OnAccept = function()
                DivinicalUI.db:DeleteProfile(currentProfile)
                print("|cff33ff99DivinicalUI|r: Deleted profile: " .. currentProfile)
                ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("DIVINICALUI_DELETE_PROFILE")
    end, 120, 25)
    deleteProfileBtn:SetPoint("LEFT", newProfileBtn, "RIGHT", 8, 0)

    local copyProfileBtn = self:CreateButton("Copy Profile", function()
        local currentProfile = DivinicalUI.db:GetCurrentProfile()
        StaticPopupDialogs["DIVINICALUI_COPY_PROFILE"] = {
            text = "Enter name for profile copy:",
            button1 = "Copy",
            button2 = "Cancel",
            hasEditBox = true,
            OnAccept = function(self)
                local profileName = self.editBox:GetText()
                if profileName and profileName ~= "" then
                    DivinicalUI.db:CopyProfile(profileName)
                    DivinicalUI.db:SetProfile(profileName)
                    print("|cff33ff99DivinicalUI|r: Copied to new profile: " .. profileName)
                    ReloadUI()
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("DIVINICALUI_COPY_PROFILE")
    end, 120, 25)
    copyProfileBtn:SetPoint("LEFT", deleteProfileBtn, "RIGHT", 8, 0)

    -- Spacer
    self:AddControl(canvas, CreateFrame("Frame"), 16)

    -- Preset Profiles header
    local presetHeader = self:CreateHeader("Preset Profiles")
    self:AddControl(canvas, presetHeader, 24)

    -- Info text
    local presetInfo = canvas:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    presetInfo:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 8, -(canvas.lastY))
    presetInfo:SetWidth(560)
    presetInfo:SetJustifyH("LEFT")
    presetInfo:SetText("Apply a preset configuration optimized for your role:")
    presetInfo:SetTextColor(0.8, 0.8, 0.8)
    self:AddControl(canvas, CreateFrame("Frame"), 24)

    -- Preset profile buttons (row 1)
    local tankBtn = self:CreateButton("Tank", function()
        Config:ApplyPresetProfile("Tank")
    end, 100, 25)
    tankBtn:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 4, -(canvas.lastY))

    local healerBtn = self:CreateButton("Healer", function()
        Config:ApplyPresetProfile("Healer")
    end, 100, 25)
    healerBtn:SetPoint("LEFT", tankBtn, "RIGHT", 8, 0)

    local dpsBtn = self:CreateButton("DPS", function()
        Config:ApplyPresetProfile("DPS")
    end, 100, 25)
    dpsBtn:SetPoint("LEFT", healerBtn, "RIGHT", 8, 0)

    self:AddControl(canvas, CreateFrame("Frame"), 32)

    -- Preset profile buttons (row 2)
    local pvpBtn = self:CreateButton("PvP", function()
        Config:ApplyPresetProfile("PvP")
    end, 100, 25)
    pvpBtn:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 4, -(canvas.lastY))

    local simpleBtn = self:CreateButton("Simple", function()
        Config:ApplyPresetProfile("Simple")
    end, 100, 25)
    simpleBtn:SetPoint("LEFT", pvpBtn, "RIGHT", 8, 0)

    local advancedBtn = self:CreateButton("Advanced", function()
        Config:ApplyPresetProfile("Advanced")
    end, 100, 25)
    advancedBtn:SetPoint("LEFT", simpleBtn, "RIGHT", 8, 0)

    self:AddControl(canvas, CreateFrame("Frame"), 32)

    -- Spacer
    self:AddControl(canvas, CreateFrame("Frame"), 16)

    -- Import/Export header
    local importExportHeader = self:CreateHeader("Import / Export")
    self:AddControl(canvas, importExportHeader, 24)

    -- Import/Export info
    local importExportInfo = canvas:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    importExportInfo:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 8, -(canvas.lastY))
    importExportInfo:SetWidth(560)
    importExportInfo:SetJustifyH("LEFT")
    importExportInfo:SetText("Share your configuration with others:")
    importExportInfo:SetTextColor(0.8, 0.8, 0.8)
    self:AddControl(canvas, CreateFrame("Frame"), 24)

    -- Import/Export buttons
    local exportBtn = self:CreateButton("Export Profile", function()
        Config:ShowExportDialog()
    end, 120, 25)
    exportBtn:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 4, -(canvas.lastY))

    local importBtn = self:CreateButton("Import Profile", function()
        Config:ShowImportDialog()
    end, 120, 25)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 8, 0)

    self:AddControl(canvas, CreateFrame("Frame"), 32)
end

-- Populate Advanced settings
function Config:PopulateAdvancedSettings(canvas)
    -- Preview mode header
    local previewHeader = self:CreateHeader("Real-time Preview")
    self:AddControl(canvas, previewHeader, 24)

    -- Enable real-time preview checkbox
    local enablePreview = self:CreateCheckbox(
        "Enable Real-time Preview",
        function() return Config.previewMode end,
        function(value)
            Config:TogglePreviewMode(value)
        end,
        "When enabled, UI changes apply immediately without reload"
    )
    self:AddControl(canvas, enablePreview, 32)

    -- Preview info text
    local previewInfo = canvas:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    previewInfo:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 32, -(canvas.lastY))
    previewInfo:SetWidth(560)
    previewInfo:SetJustifyH("LEFT")
    previewInfo:SetText("Real-time preview updates unit frames instantly as you adjust sliders.\nDisabling this may improve performance on slower systems.")
    previewInfo:SetTextColor(0.8, 0.8, 0.8)
    self:AddControl(canvas, CreateFrame("Frame"), 36)

    -- Spacer
    self:AddControl(canvas, CreateFrame("Frame"), 16)

    -- Placeholder for additional settings
    local placeholder = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    placeholder:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 8, -(canvas.lastY))
    placeholder:SetText("Additional advanced settings coming soon...")
    placeholder:SetTextColor(0.6, 0.6, 0.6)
end

-- Apply a preset profile configuration
function Config:ApplyPresetProfile(presetName)
    StaticPopupDialogs["DIVINICALUI_APPLY_PRESET"] = {
        text = "Apply '" .. presetName .. "' preset profile?\n\nThis will overwrite your current settings.",
        button1 = "Apply",
        button2 = "Cancel",
        OnAccept = function()
            -- TODO: Implement preset profile data and application logic
            -- For now, just show a message
            print("|cff33ff99DivinicalUI|r: Applied " .. presetName .. " preset profile.")
            print("|cff33ff99DivinicalUI|r: Preset profiles coming soon in full implementation!")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("DIVINICALUI_APPLY_PRESET")
end

-- Show export dialog
function Config:ShowExportDialog()
    -- Create export frame if it doesn't exist
    if not self.exportFrame then
        local frame = CreateFrame("Frame", "DivinicalUIExportFrame", UIParent, "DialogBoxFrame")
        frame:SetSize(500, 400)
        frame:SetPoint("CENTER")
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetFrameStrata("DIALOG")

        -- Title
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -16)
        title:SetText("Export Profile")

        -- Scroll frame for export string
        local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 16, -40)
        scrollFrame:SetPoint("BOTTOMRIGHT", -32, 50)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetSize(460, 300)
        editBox:SetFontObject(GameFontHighlight)
        editBox:SetAutoFocus(false)
        editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
        scrollFrame:SetScrollChild(editBox)

        frame.editBox = editBox

        -- Close button
        local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        closeBtn:SetSize(100, 25)
        closeBtn:SetPoint("BOTTOM", 0, 16)
        closeBtn:SetText("Close")
        closeBtn:SetScript("OnClick", function() frame:Hide() end)

        self.exportFrame = frame
    end

    -- Generate export string with profile data
    local profile = DivinicalUI.db.profile
    local profileName = DivinicalUI.db:GetCurrentProfile() or "Default"

    -- Serialize profile data to string
    local serialized = self:SerializeTable(profile, 0)

    -- Create export string with header and data
    local exportString = string.format([[DivinicalUI Profile Export v1.0
Profile Name: %s
Created: %s
Version: %s

-- Paste this entire block into the Import dialog --

return %s]], profileName, date("%Y-%m-%d %H:%M"), DivinicalUI.version, serialized)

    self.exportFrame.editBox:SetText(exportString)
    self.exportFrame.editBox:HighlightText()
    self.exportFrame:Show()
end

-- Serialize a table to a Lua string
function Config:SerializeTable(tbl, indent)
    if type(tbl) ~= "table" then
        if type(tbl) == "string" then
            return string.format("%q", tbl)
        else
            return tostring(tbl)
        end
    end

    local result = "{\n"
    indent = indent or 0
    local indentStr = string.rep("  ", indent + 1)

    for k, v in pairs(tbl) do
        result = result .. indentStr

        -- Handle key
        if type(k) == "number" then
            result = result .. "[" .. k .. "] = "
        elseif type(k) == "string" then
            result = result .. "[" .. string.format("%q", k) .. "] = "
        end

        -- Handle value
        if type(v) == "table" then
            result = result .. self:SerializeTable(v, indent + 1)
        elseif type(v) == "string" then
            result = result .. string.format("%q", v)
        else
            result = result .. tostring(v)
        end

        result = result .. ",\n"
    end

    result = result .. string.rep("  ", indent) .. "}"
    return result
end

-- Show import dialog
function Config:ShowImportDialog()
    -- Create import frame if it doesn't exist
    if not self.importFrame then
        local frame = CreateFrame("Frame", "DivinicalUIImportFrame", UIParent, "DialogBoxFrame")
        frame:SetSize(500, 400)
        frame:SetPoint("CENTER")
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetFrameStrata("DIALOG")

        -- Title
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -16)
        title:SetText("Import Profile")

        -- Scroll frame for import string
        local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 16, -40)
        scrollFrame:SetPoint("BOTTOMRIGHT", -32, 50)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetSize(460, 300)
        editBox:SetFontObject(GameFontHighlight)
        editBox:SetAutoFocus(true)
        editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
        scrollFrame:SetScrollChild(editBox)

        frame.editBox = editBox

        -- Import button
        local importBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        importBtn:SetSize(100, 25)
        importBtn:SetPoint("BOTTOM", -55, 16)
        importBtn:SetText("Import")
        importBtn:SetScript("OnClick", function()
            local importString = frame.editBox:GetText()
            if importString and importString ~= "" then
                -- Parse and validate import string
                local success, profileData = Config:DeserializeProfile(importString)

                if success and profileData then
                    -- Confirm import
                    StaticPopupDialogs["DIVINICALUI_CONFIRM_IMPORT"] = {
                        text = "Import profile settings?\n\nThis will overwrite your current profile!",
                        button1 = "Import",
                        button2 = "Cancel",
                        OnAccept = function()
                            -- Apply imported settings
                            for k, v in pairs(profileData) do
                                DivinicalUI.db.profile[k] = v
                            end
                            print("|cff33ff99DivinicalUI|r: Profile imported successfully!")
                            ReloadUI()
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3,
                    }
                    StaticPopup_Show("DIVINICALUI_CONFIRM_IMPORT")
                    frame:Hide()
                else
                    print("|cffff0000DivinicalUI|r: Invalid import string. Please check and try again.")
                end
            else
                print("|cffff0000DivinicalUI|r: Please paste an export string.")
            end
        end)

        -- Close button
        local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        closeBtn:SetSize(100, 25)
        closeBtn:SetPoint("BOTTOM", 55, 16)
        closeBtn:SetText("Close")
        closeBtn:SetScript("OnClick", function() frame:Hide() end)

        self.importFrame = frame
    end

    self.importFrame.editBox:SetText("")
    self.importFrame:Show()
    self.importFrame.editBox:SetFocus()
end

-- Deserialize imported profile string
function Config:DeserializeProfile(importString)
    -- Extract the Lua code from the import string
    local codeStart = importString:find("return %{")
    if not codeStart then
        return false, nil
    end

    local code = importString:sub(codeStart)

    -- Create a safe environment for loading the profile data
    local env = {}
    local func, err = loadstring(code)

    if not func then
        print("|cffff0000DivinicalUI|r: Parse error: " .. tostring(err))
        return false, nil
    end

    -- Set environment and execute
    setfenv(func, env)
    local success, profileData = pcall(func)

    if not success or type(profileData) ~= "table" then
        print("|cffff0000DivinicalUI|r: Invalid profile data")
        return false, nil
    end

    return true, profileData
end

-- Open configuration panel
function Config:OpenConfig()
    Settings.OpenToCategory("DivinicalUI_General")
end

-- Helper function to create a checkbox control
function Config:CreateCheckbox(name, getFunc, setFunc, tooltip)
    local checkbox = CreateFrame("CheckButton", nil, nil, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetSize(26, 26)

    local text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
    text:SetText(name)
    checkbox.text = text

    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked() and true or false
        setFunc(checked)
    end)

    checkbox:SetChecked(getFunc())

    if tooltip then
        checkbox.tooltipText = tooltip
    end

    return checkbox
end

-- Helper function to create a slider control with debounced real-time preview
function Config:CreateSlider(name, min, max, step, getFunc, setFunc, tooltip)
    -- Generate unique slider name
    if not Config.sliderCount then
        Config.sliderCount = 0
    end
    Config.sliderCount = Config.sliderCount + 1
    local sliderName = "DivinicalUISlider" .. Config.sliderCount

    local slider = CreateFrame("Slider", sliderName, nil, "OptionsSliderTemplate")
    slider:SetWidth(560)
    slider:SetHeight(20)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    -- Generate unique update key for debouncing
    local updateKey = "slider_" .. tostring(slider):gsub("table: ", "")

    -- Set up labels
    _G[sliderName .. "Low"]:SetText(min)
    _G[sliderName .. "High"]:SetText(max)
    _G[sliderName .. "Text"]:SetText(name)

    -- Value changed handler with debounced preview
    slider:SetScript("OnValueChanged", function(self, value, userInput)
        value = math.floor(value / step + 0.5) * step
        _G[sliderName .. "Text"]:SetText(name .. ": " .. value)

        -- Only apply debounced update if user is dragging
        if userInput then
            Config:SchedulePreviewUpdate(updateKey, function()
                setFunc(value)
            end, 0.15)
        end
    end)

    -- Apply immediately on mouse up (when user releases slider)
    slider:SetScript("OnMouseUp", function(self)
        local value = self:GetValue()
        value = math.floor(value / step + 0.5) * step
        setFunc(value)  -- Apply immediately when released
        Config.updateTimers[updateKey] = nil  -- Cancel any pending debounced update
        Config.pendingUpdates[updateKey] = nil
    end)

    -- Initialize value
    local currentValue = getFunc()
    slider:SetValue(currentValue)
    _G[sliderName .. "Text"]:SetText(name .. ": " .. currentValue)

    if tooltip then
        slider.tooltipText = tooltip
    end

    return slider
end

-- Helper function to create a button control
function Config:CreateButton(name, onClick, width, height)
    local button = CreateFrame("Button", nil, nil, "UIPanelButtonTemplate")
    button:SetText(name)
    button:SetSize(width or 120, height or 25)
    button:SetScript("OnClick", onClick)
    return button
end

-- Helper function to create a header text
function Config:CreateHeader(text)
    local frame = CreateFrame("Frame")
    frame:SetSize(560, 20)

    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    header:SetText(text)
    frame.text = header

    return frame
end

-- Helper function to create a color picker control with alpha support
function Config:CreateColorPicker(name, getFunc, setFunc, hasAlpha, tooltip)
    local frame = CreateFrame("Frame")
    frame:SetSize(560, 30)

    -- Label
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", frame, "LEFT", 0, 0)
    label:SetText(name)

    -- Color swatch button
    local swatch = CreateFrame("Button", nil, frame)
    swatch:SetSize(20, 20)
    swatch:SetPoint("RIGHT", frame, "RIGHT", -80, 0)

    -- Swatch background
    local bg = swatch:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 1)
    bg:SetPoint("CENTER")

    -- Swatch color texture
    local color = swatch:CreateTexture(nil, "BORDER")
    color:SetSize(18, 18)
    color:SetPoint("CENTER")

    -- Get current color
    local r, g, b, a = getFunc()
    color:SetColorTexture(r or 1, g or 1, b or 1, a or 1)
    swatch.color = color

    -- Current value display
    local valueText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetPoint("RIGHT", swatch, "LEFT", -8, 0)
    if hasAlpha then
        valueText:SetText(string.format("%.2f, %.2f, %.2f, %.2f", r or 1, g or 1, b or 1, a or 1))
    else
        valueText:SetText(string.format("%.2f, %.2f, %.2f", r or 1, g or 1, b or 1))
    end

    -- Color picker button click handler
    swatch:SetScript("OnClick", function(self)
        local r, g, b, a = getFunc()

        local function OnColorChanged()
            local newR, newG, newB = ColorPickerFrame:GetColorRGB()
            local newA = hasAlpha and ColorPickerFrame:GetColorAlpha() or 1

            -- Update swatch
            color:SetColorTexture(newR, newG, newB, newA)

            -- Update value text
            if hasAlpha then
                valueText:SetText(string.format("%.2f, %.2f, %.2f, %.2f", newR, newG, newB, newA))
            else
                valueText:SetText(string.format("%.2f, %.2f, %.2f", newR, newG, newB))
            end

            -- Apply color
            Config:SchedulePreviewUpdate("colorpicker_" .. name, function()
                setFunc(newR, newG, newB, newA)
            end, 0.1)
        end

        local function OnColorFinished()
            local newR, newG, newB = ColorPickerFrame:GetColorRGB()
            local newA = hasAlpha and ColorPickerFrame:GetColorAlpha() or 1
            setFunc(newR, newG, newB, newA)
        end

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r,
            g = g,
            b = b,
            opacity = hasAlpha and a or nil,
            hasOpacity = hasAlpha,
            swatchFunc = OnColorChanged,
            opacityFunc = hasAlpha and OnColorChanged or nil,
            cancelFunc = function()
                local oldR, oldG, oldB, oldA = getFunc()
                color:SetColorTexture(oldR, oldG, oldB, oldA or 1)
                if hasAlpha then
                    valueText:SetText(string.format("%.2f, %.2f, %.2f, %.2f", oldR, oldG, oldB, oldA))
                else
                    valueText:SetText(string.format("%.2f, %.2f, %.2f", oldR, oldG, oldB))
                end
            end,
            finishedFunc = OnColorFinished,
        })
    end)

    if tooltip then
        swatch:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip)
            GameTooltip:Show()
        end)
        swatch:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    return frame
end

-- Helper function to create a dropdown menu control
function Config:CreateDropdown(name, items, getFunc, setFunc, tooltip)
    local frame = CreateFrame("Frame")
    frame:SetSize(560, 40)

    -- Label
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -8)
    label:SetText(name)

    -- Dropdown button
    local dropdown = CreateFrame("Frame", "DivinicalUIDropdown" .. name, frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -15, -4)

    -- Initialize dropdown
    UIDropDownMenu_SetWidth(dropdown, 200)
    UIDropDownMenu_SetText(dropdown, getFunc())

    -- Dropdown menu initialization function
    local function InitializeDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()

        for i, item in ipairs(items) do
            info.text = item
            info.func = function(self)
                UIDropDownMenu_SetText(dropdown, item)
                setFunc(item)
                Config:ApplyImmediateUpdate(function()
                    -- Apply the selected value immediately
                end)
            end
            info.checked = (getFunc() == item)
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dropdown, InitializeDropdown)

    if tooltip then
        dropdown.tooltipText = tooltip
    end

    return frame
end

-- Register module
DivinicalUI:RegisterModule("Config", Config)
