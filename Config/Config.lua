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

-- Populate Profiles settings (placeholder)
function Config:PopulateProfilesSettings(canvas)
    local placeholder = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    placeholder:SetPoint("TOPLEFT", canvas.content, "TOPLEFT", 8, -8)
    placeholder:SetText("Profile management coming soon...")
    placeholder:SetTextColor(0.6, 0.6, 0.6)
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
    local slider = CreateFrame("Slider", nil, nil, "OptionsSliderTemplate")
    slider:SetWidth(560)
    slider:SetHeight(20)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    -- Generate unique update key for debouncing
    local updateKey = "slider_" .. tostring(slider):gsub("table: ", "")

    -- Set up labels
    _G[slider:GetName() .. "Low"]:SetText(min)
    _G[slider:GetName() .. "High"]:SetText(max)
    _G[slider:GetName() .. "Text"]:SetText(name)

    -- Value changed handler with debounced preview
    slider:SetScript("OnValueChanged", function(self, value, userInput)
        value = math.floor(value / step + 0.5) * step
        _G[self:GetName() .. "Text"]:SetText(name .. ": " .. value)

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
    _G[slider:GetName() .. "Text"]:SetText(name .. ": " .. currentValue)

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

-- Register module
DivinicalUI:RegisterModule("Config", Config)
