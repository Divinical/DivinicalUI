-- Unit Frames module for DivinicalUI
local AddonName, DivinicalUI = ...

-- UnitFrames module
local UnitFrames = {}

-- oUF reference
local oUF = DivinicalUI.oUF or _G.oUF

-- Frame storage
local frames = {}

-- Initialize unit frames module
function UnitFrames:Initialize()
    self:CreateStyle()
    self:SpawnFrames()
    self:RegisterEvents()
end

-- Post-initialization
function UnitFrames:PostInitialize()
    -- Called after all modules are loaded
end

-- Create oUF style
function UnitFrames:CreateStyle()
    local function Style(self, unit)
        -- Set size and position
        self:SetSize(DivinicalUI.db.profile.unitframes.player.width, 
                    DivinicalUI.db.profile.unitframes.player.height)
        
        -- Health bar
        self.Health = CreateFrame("StatusBar", nil, self)
        self.Health:SetAllPoints()
        self.Health:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Health:GetStatusBarTexture():SetDrawLayer("ARTWORK")
        
        -- Health background
        self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
        self.Health.bg:SetAllPoints()
        self.Health.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Health.bg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
        
        -- Health text
        self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
        self.Health.value:SetPoint("RIGHT", self.Health, "RIGHT", -2, 0)
        self.Health.value:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 12, "OUTLINE")
        
        -- Power bar
        self.Power = CreateFrame("StatusBar", nil, self)
        self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
        self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -2)
        self.Power:SetHeight(8)
        self.Power:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Power:GetStatusBarTexture():SetDrawLayer("ARTWORK")
        
        -- Power background
        self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
        self.Power.bg:SetAllPoints()
        self.Power.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Power.bg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
        
        -- Power text
        self.Power.value = self.Power:CreateFontString(nil, "OVERLAY")
        self.Power.value:SetPoint("RIGHT", self.Power, "RIGHT", -2, 0)
        self.Power.value:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 10, "OUTLINE")
        
        -- Name text
        self.Name = self:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("LEFT", self.Health, "LEFT", 2, 0)
        self.Name:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 12, "OUTLINE")
        self.Name:SetJustifyH("LEFT")
        
        -- Level text
        self.Level = self:CreateFontString(nil, "OVERLAY")
        self.Level:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -2)
        self.Level:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 10, "OUTLINE")
        
        -- Class icon (for target frame)
        if unit == "target" then
            self.ClassIcon = self:CreateTexture(nil, "OVERLAY")
            self.ClassIcon:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
            self.ClassIcon:SetSize(20, 20)
        end
        
        -- Portrait (optional)
        if DivinicalUI.db.profile.unitframes.player.portrait then
            self.Portrait = CreateFrame("PlayerModel", nil, self)
            self.Portrait:SetPoint("RIGHT", self, "LEFT", -5, 0)
            self.Portrait:SetSize(40, 40)
        end
        
        -- Cast bar
        self.Castbar = CreateFrame("StatusBar", nil, self)
        self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -10)
        self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -10)
        self.Castbar:SetHeight(10)
        self.Castbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        
        self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
        self.Castbar.bg:SetAllPoints()
        self.Castbar.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Castbar.bg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
        
        self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
        self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 2, 0)
        self.Castbar.Text:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 10, "OUTLINE")
        
        self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
        self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", -2, 0)
        self.Castbar.Time:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 10, "OUTLINE")
        
        -- Register with oUF
        self:RegisterForClicks("AnyUp")
        self:SetScript("OnEnter", UnitFrame_OnEnter)
        self:SetScript("OnLeave", UnitFrame_OnLeave)
    end
    
    -- Health color update
    local function UpdateHealthColor(self, unit)
        local r, g, b
        
        if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
            r, g, b = 0.5, 0.5, 0.5
        elseif not UnitIsConnected(unit) then
            r, g, b = 0.5, 0.5, 0.5
        elseif UnitIsPlayer(unit) then
            local class = select(2, UnitClass(unit))
            r, g, b = DivinicalUI.Utils.Colors.GetClassColor(class)
        elseif UnitIsFriend(unit, "player") then
            r, g, b = 0.2, 0.8, 0.2
        else
            local reaction = UnitReaction(unit, "player")
            r, g, b = DivinicalUI.Utils.Colors.GetReactionColor(reaction)
        end
        
        self.Health:SetStatusBarColor(r, g, b)
    end
    
    -- Power color update
    local function UpdatePowerColor(self, unit)
        local powerType = UnitPowerType(unit)
        local r, g, b = DivinicalUI.Utils.Colors.GetPowerColor(powerType)
        self.Power:SetStatusBarColor(r, g, b)
    end
    
    -- Health text update
    local function UpdateHealthText(self, unit)
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        local healthPercent = DivinicalUI.Utils.Math.Round((health / maxHealth) * 100)
        
        if health == maxHealth then
            self.Health.value:SetText("")
        else
            self.Health.value:SetText(DivinicalUI.Utils.Strings.FormatNumber(health) .. " (" .. healthPercent .. "%)")
        end
    end
    
    -- Power text update
    local function UpdatePowerText(self, unit)
        local power = UnitPower(unit)
        local maxPower = UnitPowerMax(unit)
        
        if power == 0 then
            self.Power.value:SetText("")
        else
            self.Power.value:SetText(DivinicalUI.Utils.Strings.FormatNumber(power))
        end
    end
    
    -- Name text update
    local function UpdateNameText(self, unit)
        local name = UnitName(unit)
        if name then
            self.Name:SetText(name)
        end
    end
    
    -- Level text update
    local function UpdateLevelText(self, unit)
        local level = UnitLevel(unit)
        local classification = DivinicalUI.Utils.Units.GetClassification(unit)
        
        if level == -1 then
            self.Level:SetText("??")
        else
            self.Level:SetText(level .. " " .. classification)
        end
    end
    
    -- Hook updates
    oUF:RegisterStyle("DivinicalUI", Style)
    oUF:SetActiveStyle("DivinicalUI")
    
    -- Add post-update functions
    local function PostUpdateHealth(self, unit)
        UpdateHealthColor(self, unit)
        UpdateHealthText(self, unit)
    end
    
    local function PostUpdatePower(self, unit)
        UpdatePowerColor(self, unit)
        UpdatePowerText(self, unit)
    end
    
    local function PostUpdateName(self, unit)
        UpdateNameText(self, unit)
        UpdateLevelText(self, unit)
    end
    
    -- Store post-update functions
    UnitFrames.PostUpdateHealth = PostUpdateHealth
    UnitFrames.PostUpdatePower = PostUpdatePower
    UnitFrames.PostUpdateName = PostUpdateName
end

-- Spawn unit frames
function UnitFrames:SpawnFrames()
    if not oUF then
        DivinicalUI.Utils.Debug.Print("oUF not available, cannot spawn frames", "ERROR")
        return
    end
    
    -- Player frame
    if DivinicalUI.db.profile.unitframes.player.enabled then
        local playerFrame = oUF:Spawn("player", "DivinicalUIPlayerFrame")
        playerFrame:SetPoint(unpack(DivinicalUI.db.profile.unitframes.player.position))
        frames.player = playerFrame
        DivinicalUI.Utils.Debug.Print("Player frame spawned", "DEBUG")
    end
    
    -- Target frame
    if DivinicalUI.db.profile.unitframes.target.enabled then
        local targetFrame = oUF:Spawn("target", "DivinicalUITargetFrame")
        targetFrame:SetPoint(unpack(DivinicalUI.db.profile.unitframes.target.position))
        frames.target = targetFrame
        DivinicalUI.Utils.Debug.Print("Target frame spawned", "DEBUG")
    end
    
    -- Target of Target
    local totFrame = oUF:Spawn("targettarget", "DivinicalUITargetTargetFrame")
    totFrame:SetPoint("TOPLEFT", frames.target, "TOPRIGHT", 5, 0)
    totFrame:SetSize(100, 25)
    frames.targettarget = totFrame
    
    -- Focus frame
    local focusFrame = oUF:Spawn("focus", "DivinicalUIFocusFrame")
    focusFrame:SetPoint("TOPLEFT", frames.player, "BOTTOMLEFT", 0, -50)
    focusFrame:SetSize(150, 30)
    frames.focus = focusFrame
    
    -- Pet frame
    local petFrame = oUF:Spawn("pet", "DivinicalUIPetFrame")
    petFrame:SetPoint("TOPLEFT", frames.player, "TOPRIGHT", 5, 0)
    petFrame:SetSize(100, 25)
    frames.pet = petFrame
end

-- Register events
function UnitFrames:RegisterEvents()
    DivinicalUI.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_HEALTH")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
    DivinicalUI.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

-- Event handlers
function UnitFrames:PLAYER_ENTERING_WORLD()
    -- Update all frames when entering world
    for _, frame in pairs(frames) do
        if frame.UpdateAllElements then
            frame:UpdateAllElements()
        end
    end
end

function UnitFrames:UNIT_HEALTH(unit)
    if frames[unit] and frames[unit].UpdateAllElements then
        frames[unit]:UpdateAllElements()
    end
end

function UnitFrames:UNIT_POWER_UPDATE(unit)
    if frames[unit] and frames[unit].UpdateAllElements then
        frames[unit]:UpdateAllElements()
    end
end

function UnitFrames:PLAYER_TARGET_CHANGED()
    if frames.target and frames.target.UpdateAllElements then
        frames.target:UpdateAllElements()
    end
end

-- Update player frame
function UnitFrames:UpdatePlayerFrame()
    if frames.player then
        frames.player:SetSize(DivinicalUI.db.profile.unitframes.player.width, 
                             DivinicalUI.db.profile.unitframes.player.height)
        frames.player:UpdateAllElements()
    end
end

-- Update target frame
function UnitFrames:UpdateTargetFrame()
    if frames.target then
        frames.target:SetSize(DivinicalUI.db.profile.unitframes.target.width, 
                             DivinicalUI.db.profile.unitframes.target.height)
        frames.target:UpdateAllElements()
    end
end

-- Profile change handler
function UnitFrames:OnProfileChanged(profileName)
    -- Update all frames when profile changes
    for _, frame in pairs(frames) do
        if frame.UpdateAllElements then
            frame:UpdateAllElements()
        end
    end
end

-- Get frame by unit
function UnitFrames:GetFrame(unit)
    return frames[unit]
end

-- Hide Blizzard frames
function UnitFrames:HideBlizzardFrames()
    PlayerFrame:Hide()
    PlayerFrame:SetMovable(true)
    PlayerFrame:SetUserPlaced(true)
    PlayerFrame:SetDontSavePosition(true)
    
    TargetFrame:Hide()
    TargetFrame:SetMovable(true)
    TargetFrame:SetUserPlaced(true)
    TargetFrame:SetDontSavePosition(true)
    
    ComboFrame:Hide()
end

-- Register module
DivinicalUI:RegisterModule("UnitFrames", UnitFrames)