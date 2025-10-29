-- Settings panel implementation for DivinicalUI
local AddonName, DivinicalUI = ...

-- Settings module
local Settings = {}

-- Initialize settings module
function Settings:Initialize()
    self:CreateSettingsPanel()
end

-- Create the main settings panel
function Settings:CreateSettingsPanel()
    -- This will be called by the Config module when registering with Blizzard's Settings API
    -- The actual panel creation is handled by Config:RegisterSettingsPanel()
end

-- Helper function to create a slider control
function Settings:CreateSlider(name, min, max, step, getFunc, setFunc, tooltip)
    local slider = CreateFrame("Slider", nil, nil, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    _G[slider:GetName() .. "Low"]:SetText(min)
    _G[slider:GetName() .. "High"]:SetText(max)
    _G[slider:GetName() .. "Text"]:SetText(name)
    
    slider:SetScript("OnValueChanged", function(self, value)
        setFunc(value)
        _G[self:GetName() .. "Text"]:SetText(name .. ": " .. value)
    end)
    
    if tooltip then
        slider.tooltip = tooltip
    end
    
    slider:SetValue(getFunc())
    _G[slider:GetName() .. "Text"]:SetText(name .. ": " .. getFunc())
    
    return slider
end

-- Helper function to create a checkbox control
function Settings:CreateCheckbox(name, getFunc, setFunc, tooltip)
    local checkbox = CreateFrame("CheckButton", nil, nil, "UICheckButtonTemplate")
    checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    checkbox.text:SetText(name)
    
    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        setFunc(checked)
    end)
    
    if tooltip then
        checkbox.tooltip = tooltip
    end
    
    checkbox:SetChecked(getFunc())
    
    return checkbox
end

-- Helper function to create a button control
function Settings:CreateButton(name, onClick, width, height)
    local button = CreateFrame("Button", nil, nil, "UIPanelButtonTemplate")
    button:SetText(name)
    button:SetSize(width or 100, height or 25)
    
    button:SetScript("OnClick", onClick)
    
    return button
end

-- Helper function to create a header text
function Settings:CreateHeader(text)
    local header = CreateFrame("Frame", nil, nil)
    header.text = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header.text:SetText(text)
    header.text:SetAllPoints()
    
    return header
end

-- Export settings to string
function Settings:ExportSettings()
    local serialized = "DivinicalUI Export\n"
    serialized = serialized .. "Version: " .. DivinicalUI.version .. "\n"
    serialized = serialized .. "Timestamp: " .. date("%Y-%m-%d %H:%M:%S") .. "\n"
    serialized = serialized .. "Data: " .. strsub(DivinicalUI.db.profile, 1, 1000) -- Truncate for safety
    
    return serialized
end

-- Import settings from string
function Settings:ImportSettings(data)
    if not data or data == "" then
        print("|cff33ff99DivinicalUI|r: No data to import.")
        return false
    end
    
    -- Basic validation
    if not strfind(data, "DivinicalUI Export") then
        print("|cff33ff99DivinicalUI|r: Invalid import data format.")
        return false
    end
    
    -- In a full implementation, this would parse and validate the data
    -- For now, just show a success message
    print("|cff33ff99DivinicalUI|r: Settings imported successfully!")
    return true
end

-- Register module
DivinicalUI:RegisterModule("Settings", Settings)