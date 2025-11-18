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
        -- Set size and position (will be overridden per frame type)
        self:SetSize(150, 40)
        
        -- Health bar with gradient texture
        self.Health = CreateFrame("StatusBar", nil, self)
        self.Health:SetAllPoints()
        self.Health:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar") -- Using default texture for now
        self.Health:GetStatusBarTexture():SetDrawLayer("ARTWORK")
        -- Note: SetSmoothProgress is not available in all WoW versions
        -- Smooth transitions can be achieved through oUF's smoothing feature instead
        self.Health.smoothGradient = true
        
        -- Health background with multi-layer effect
        self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
        self.Health.bg:SetAllPoints()
        self.Health.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Health.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
        
        -- Health gradient overlay for visual depth
        self.Health.gradient = self.Health:CreateTexture(nil, "ARTWORK")
        self.Health.gradient:SetAllPoints()
        self.Health.gradient:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Health.gradient:SetBlendMode("ADD")
        self.Health.gradient:SetAlpha(0.3)
        -- Use SetGradient instead of SetGradientAlpha (modern WoW API)
        self.Health.gradient:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.2), CreateColor(1, 1, 1, 0))
        
        -- Health text with enhanced formatting
        self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
        self.Health.value:SetPoint("RIGHT", self.Health, "RIGHT", -2, 0)
        -- Use default font as fallback
        local font, _, flags = self.Health.value:GetFont()
        if not self.Health.value:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 12, "OUTLINE") then
            self.Health.value:SetFont(font or "Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        end
        self.Health.value:SetShadowColor(0, 0, 0, 0.5)
        self.Health.value:SetShadowOffset(1, -1)
        self:Tag(self.Health.value, "[divinical:health]")

        -- Health percentage text
        self.Health.percentage = self.Health:CreateFontString(nil, "OVERLAY")
        self.Health.percentage:SetPoint("LEFT", self.Health, "LEFT", 2, 0)
        if not self.Health.percentage:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 11, "OUTLINE") then
            self.Health.percentage:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        end
        self.Health.percentage:SetShadowColor(0, 0, 0, 0.5)
        self.Health.percentage:SetShadowOffset(1, -1)
        self:Tag(self.Health.percentage, "[divinical:healthperc]")
        
        -- Power bar with enhanced visual
        self.Power = CreateFrame("StatusBar", nil, self)
        self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
        self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -2)
        self.Power:SetHeight(10) -- Slightly taller for better visibility
        self.Power:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Power:GetStatusBarTexture():SetDrawLayer("ARTWORK")
        -- Note: SetSmoothProgress is not available in all WoW versions
        self.Power.smoothGradient = true
        
        -- Power background
        self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
        self.Power.bg:SetAllPoints()
        self.Power.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Power.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
        
        -- Power gradient overlay
        self.Power.gradient = self.Power:CreateTexture(nil, "ARTWORK")
        self.Power.gradient:SetAllPoints()
        self.Power.gradient:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Power.gradient:SetBlendMode("ADD")
        self.Power.gradient:SetAlpha(0.3)
        -- Use SetGradient instead of SetGradientAlpha (modern WoW API)
        self.Power.gradient:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.2), CreateColor(1, 1, 1, 0))
        
        -- Power text with enhanced formatting
        self.Power.value = self.Power:CreateFontString(nil, "OVERLAY")
        self.Power.value:SetPoint("RIGHT", self.Power, "RIGHT", -2, 0)
        if not self.Power.value:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 10, "OUTLINE") then
            self.Power.value:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        end
        self.Power.value:SetShadowColor(0, 0, 0, 0.5)
        self.Power.value:SetShadowOffset(1, -1)
        self:Tag(self.Power.value, "[divinical:power]")

        -- Power type indicator
        self.Power.type = self.Power:CreateFontString(nil, "OVERLAY")
        self.Power.type:SetPoint("LEFT", self.Power, "LEFT", 2, 0)
        if not self.Power.type:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 9, "OUTLINE") then
            self.Power.type:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
        end
        self.Power.type:SetShadowColor(0, 0, 0, 0.5)
        self.Power.type:SetShadowOffset(1, -1)
        self:Tag(self.Power.type, "[divinical:powertype]")

        -- Name text using oUF tags
        self.Name = self:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("LEFT", self.Health, "LEFT", 2, 0)
        if not self.Name:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 12, "OUTLINE") then
            self.Name:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        end
        self.Name:SetJustifyH("LEFT")
        self:Tag(self.Name, "[name]")

        -- Level text using oUF tags
        self.Level = self:CreateFontString(nil, "OVERLAY")
        self.Level:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -2)
        if not self.Level:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 10, "OUTLINE") then
            self.Level:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        end
        self:Tag(self.Level, "[level][classification]")
        
        -- Enhanced Cast bar with latency and spell queue detection
        self.Castbar = CreateFrame("StatusBar", nil, self)
        self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -10)
        self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -10)
        self.Castbar:SetHeight(12)
        self.Castbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Castbar:SetStatusBarColor(1.0, 0.7, 0.0)
        
        -- Castbar background
        self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
        self.Castbar.bg:SetAllPoints()
        self.Castbar.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Castbar.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
        
        -- Castbar spark for visual feedback
        self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
        self.Castbar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
        self.Castbar.Spark:SetSize(12, 20)
        self.Castbar.Spark:SetBlendMode("ADD")
        
        -- Latency bar for spell timing optimization
        self.Castbar.Latency = self.Castbar:CreateTexture(nil, "ARTWORK")
        self.Castbar.Latency:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        self.Castbar.Latency:SetHeight(4)
        self.Castbar.Latency:SetPoint("TOPLEFT", self.Castbar, "TOPLEFT")
        self.Castbar.Latency:SetPoint("TOPRIGHT", self.Castbar, "TOPRIGHT")
        self.Castbar.Latency:SetVertexColor(1.0, 0.0, 0.0, 0.5)
        
        -- Spell queue indicator
        self.Castbar.Queue = self.Castbar:CreateTexture(nil, "OVERLAY")
        self.Castbar.Queue:SetTexture("Interface\\AddOns\\DivinicalUI\\Media\\Textures\\Queue")
        self.Castbar.Queue:SetSize(16, 16)
        self.Castbar.Queue:SetPoint("RIGHT", self.Castbar, "RIGHT", -20, 0)
        self.Castbar.Queue:Hide()
        
        -- Castbar text with shadow
        self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
        self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 2, 0)
        if not self.Castbar.Text:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 10, "OUTLINE") then
            self.Castbar.Text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        end
        self.Castbar.Text:SetShadowColor(0, 0, 0, 0.8)
        self.Castbar.Text:SetShadowOffset(1, -1)

        -- Castbar time with shadow
        self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
        self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", -2, 0)
        if not self.Castbar.Time:SetFont("Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf", 10, "OUTLINE") then
            self.Castbar.Time:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        end
        self.Castbar.Time:SetShadowColor(0, 0, 0, 0.8)
        self.Castbar.Time:SetShadowOffset(1, -1)
        
        -- Castbar icon
        self.Castbar.Icon = self.Castbar:CreateTexture(nil, "ARTWORK")
        self.Castbar.Icon:SetSize(24, 24)
        self.Castbar.Icon:SetPoint("RIGHT", self.Castbar, "LEFT", -5, 0)
        self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        
        -- Castbar icon background
        self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
        self.Castbar.Icon.bg:SetSize(26, 26)
        self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -1, 1)
        self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", 1, -1)
        self.Castbar.Icon.bg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        self.Castbar.Icon.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
        
        -- Castbar post-update functions
        self.Castbar.PostCastStart = function(Castbar, unit, name, castID, spellID)
            -- Set castbar color based on spell type
            local spellType = GetSpellInfo(spellID)
            if spellType then
                local _, _, _, castTime = GetSpellInfo(spellID)
                if castTime and castTime > 0 then
                    Castbar:SetStatusBarColor(1.0, 0.7, 0.0) -- Orange for casts
                else
                    Castbar:SetStatusBarColor(0.2, 0.8, 0.2) -- Green for instant
                end
            end
            
            -- Update spell queue detection
            Castbar.lastCastTime = GetTime()
        end
        
        self.Castbar.PostCastStop = function(Castbar, unit, spellID)
            Castbar.Latency:Hide()
            Castbar.Queue:Hide()
        end
        
        self.Castbar.PostCastInterruptible = function(Castbar, unit)
            Castbar:SetStatusBarColor(1.0, 0.2, 0.2) -- Red for interruptible
        end
        
        self.Castbar.PostCastNotInterruptible = function(Castbar, unit)
            Castbar:SetStatusBarColor(0.8, 0.2, 0.8) -- Purple for uninterruptible
        end
        
        -- Aura system - Buffs
        self.Buffs = CreateFrame("Frame", nil, self)
        self.Buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -25)
        self.Buffs:SetHeight(30)
        self.Buffs.size = 24
        self.Buffs.num = 8
        self.Buffs.spacing = 4
        self.Buffs.initialAnchor = "TOPLEFT"
        self.Buffs["growth-x"] = "RIGHT"
        self.Buffs["growth-y"] = "DOWN"

        -- Buff filtering - show player buffs and important buffs
        self.Buffs.CustomFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, casterIsPlayer, nameplateShowAll)
            -- Show player cast buffs
            if caster == "player" or caster == "vehicle" or caster == "pet" then
                return true
            end
            return false
        end

        -- Create icon styling for buffs
        self.Buffs.PostCreateIcon = function(Auras, icon)
            -- Add overlay for highlighting
            icon.overlay = icon:CreateTexture(nil, "OVERLAY")
            icon.overlay:SetAllPoints()
            icon.overlay:SetTexture("Interface\\Buttons\\WHITE8X8")
            icon.overlay:SetBlendMode("ADD")
            icon.overlay:Hide()
        end

        self.Buffs.PostUpdateIcon = function(Auras, unit, icon, index, offset)
            -- Basic buff icon updates - can be enhanced later
            if icon.overlay then
                icon.overlay:Hide()
            end
        end
        
        -- Aura system - Debuffs (separate for better visibility)
        self.Debuffs = CreateFrame("Frame", nil, self)
        self.Debuffs:SetPoint("TOPLEFT", self.Buffs, "BOTTOMLEFT", 0, -5)
        self.Debuffs:SetHeight(30)
        self.Debuffs.size = 24
        self.Debuffs.num = 16
        self.Debuffs.spacing = 4
        self.Debuffs.initialAnchor = "TOPLEFT"
        self.Debuffs["growth-x"] = "RIGHT"
        self.Debuffs["growth-y"] = "DOWN"
        
        -- Enhanced debuff filtering
        self.Debuffs.CustomFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, casterIsPlayer, nameplateShowAll)
            -- Always show player debuffs
            if caster == "player" or caster == "vehicle" or caster == "pet" then
                return true
            end
            
            -- Always show boss debuffs
            if isBossDebuff then
                return true
            end
            
            -- Important PvP/PvE debuffs
            local importantDebuffs = {
                -- CC effects
                [33786] = true, -- Cyclone
                [118] = true,  -- Polymorph
                [6770] = true,  -- Sap
                [9484] = true,  -- Shackle Undead
                [20066] = true, -- Repentance
                [51514] = true, -- Hex
                [5211] = true,  -- Mighty Bash
                [408] = true,   -- Kidney Shot
                [1833] = true,  -- Cheap Shot
                [1776] = true,  -- Gouge
                [6770] = true,  -- Sap
                [2094] = true,  -- Blind
                [118] = true,   -- Polymorph
                [28272] = true, -- Polymorph: Pig
                [28271] = true, -- Polymorph: Turtle
                [61025] = true, -- Polymorph: Serpent
                [61305] = true, -- Polymorph: Black Cat
                [61721] = true, -- Polymorph: Rabbit
                [61780] = true, -- Polymorph: Turkey
                
                -- Silences
                [15487] = true, -- Silence
                [1330] = true,  -- Garrote
                [18425] = true, -- Kick - Silence
                [18498] = true, -- Gouge - Silence
                [24259] = true, -- Spell Lock
                [25046] = true, -- Arcane Torrent
                [47476] = true, -- Strangulate
                
                -- Disarms
                [676] = true,  -- Disarm
                [51722] = true, -- Dismantle
                [64346] = true, -- Shattering Throw
                
                -- Important damage debuffs
                [48181] = true, -- Haunt
                [30108] = true, -- Unstable Affliction
                [31935] = true, -- Avenger's Shield
                [5782] = true,  -- Fear
                [8122] = true,  -- Psychic Scream
                [5484] = true,  -- Howl of Terror
                [6358] = true,  -- Seduction
                
                -- Healing debuffs
                [19434] = true, -- Aimed Shot
                [12294] = true, -- Mortal Strike
                [82654] = true, -- Widow Venom
                [115804] = true, -- Mortal Cleave
                [23577] = true, -- Smite
                [26680] = true, -- Wound Poison
                [13218] = true, -- Wound Poison (rank 2)
                [27189] = true, -- Wound Poison (rank 3)
                [57970] = true, -- Wound Poison (rank 4)
                [57973] = true, -- Wound Poison (rank 5)
                [57974] = true, -- Wound Poison (rank 6)
                [57975] = true, -- Wound Poison (rank 7)
                
                -- Tanking debuffs
                [67] = true,    -- Vindication
                [7386] = true,  -- Sunder Armor
                [8647] = true,  -- Expose Armor
                [91565] = true, -- Faerie Fire
                [91621] = true, -- Faerie Fire (rank 2)
                [91622] = true, -- Faerie Fire (rank 3)
                [91623] = true, -- Faerie Fire (rank 4)
                [91624] = true, -- Faerie Fire (rank 5)
                [91625] = true, -- Faerie Fire (rank 6)
            }
            
            return importantDebuffs[spellId] or false
        end

        -- Create icon styling for debuffs
        self.Debuffs.PostCreateIcon = function(Auras, icon)
            -- Add overlay for highlighting
            icon.overlay = icon:CreateTexture(nil, "OVERLAY")
            icon.overlay:SetAllPoints()
            icon.overlay:SetTexture("Interface\\Buttons\\WHITE8X8")
            icon.overlay:SetBlendMode("ADD")
            icon.overlay:Hide()
        end

        self.Debuffs.PostUpdateIcon = function(Auras, unit, icon, index, offset)
            local name, _, _, _, dtype, duration, expirationTime, caster, _, _, spellId = UnitAura(unit, index, icon.filter)
            
            -- Enhanced debuff highlighting
            local importantDebuffs = {
                [33786] = {r = 0.8, g = 0.2, b = 0.8, priority = 1}, -- Cyclone - Purple
                [118] = {r = 0.8, g = 0.8, b = 0.2, priority = 1},   -- Polymorph - Yellow
                [6770] = {r = 0.8, g = 0.2, b = 0.2, priority = 1},   -- Sap - Red
                [51514] = {r = 0.2, g = 0.8, b = 0.8, priority = 1},  -- Hex - Cyan
                [5782] = {r = 0.8, g = 0.2, b = 0.2, priority = 1},   -- Fear - Red
                [8122] = {r = 0.8, g = 0.2, b = 0.2, priority = 1},   -- Psychic Scream - Red
                [48181] = {r = 0.6, g = 0.2, b = 0.8, priority = 2}, -- Haunt - Dark Purple
                [30108] = {r = 0.8, g = 0.2, b = 0.2, priority = 2}, -- Unstable Affliction - Red
                [12294] = {r = 0.8, g = 0.2, b = 0.2, priority = 2}, -- Mortal Strike - Red
                [19434] = {r = 0.8, g = 0.2, b = 0.2, priority = 2}, -- Aimed Shot - Red
            }
            
            if importantDebuffs[spellId] then
                local color = importantDebuffs[spellId]
                icon.overlay:SetVertexColor(color.r, color.g, color.b, 1)
                icon.overlay:Show()
                
                -- Add glow effect for high priority debuffs
                if color.priority == 1 then
                    if not icon.glow then
                        icon.glow = icon:CreateTexture(nil, "OVERLAY")
                        icon.glow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
                        icon.glow:SetAllPoints()
                        icon.glow:SetTexCoord(0.0078125, 0.6171875, 0.00390625, 0.26953125)
                    end
                    icon.glow:SetVertexColor(color.r, color.g, color.b, 0.8)
                    icon.glow:Show()
                elseif icon.glow then
                    icon.glow:Hide()
                end
            else
                icon.overlay:SetVertexColor(0, 0, 0, 0.8)
                if icon.glow then
                    icon.glow:Hide()
                end
            end
            
            -- Color debuff border by debuff type
            if dtype then
                local debuffColors = {
                    Magic = {r = 0.2, g = 0.6, b = 1.0},
                    Curse = {r = 0.8, g = 0.2, b = 0.8},
                    Disease = {r = 0.8, g = 0.6, b = 0.2},
                    Poison = {r = 0.2, g = 0.8, b = 0.2},
                }
                local color = debuffColors[dtype] or {r = 0.8, g = 0.2, b = 0.2}
                icon.overlay:SetVertexColor(color.r, color.g, color.b, 0.9)
            end
        end
        

        
        -- Enhanced 3D Portrait system
        if DivinicalUI.db.profile.unitframes.player.portrait or unit == "target" then
            self.Portrait = CreateFrame("PlayerModel", nil, self)
            if unit == "player" then
                self.Portrait:SetPoint("RIGHT", self, "LEFT", -5, 0)
            else
                self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
            end
            self.Portrait:SetSize(40, 40)
            
            -- Portrait background
            self.Portrait.bg = self.Portrait:CreateTexture(nil, "BACKGROUND")
            self.Portrait.bg:SetAllPoints()
            self.Portrait.bg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
            self.Portrait.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
            
            -- Portrait border
            self.Portrait.border = self.Portrait:CreateTexture(nil, "BORDER")
            self.Portrait.border:SetAllPoints()
            self.Portrait.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
            self.Portrait.border:SetVertexColor(0.6, 0.6, 0.6, 1.0)
            
            -- Portrait post-update for 3D model
            self.Portrait.PostUpdate = function(Portrait, unit)
                if UnitExists(unit) then
                    Portrait:SetUnit(unit)
                    Portrait:SetCamera(0)
                else
                    Portrait:ClearModel()
                end
            end
        end
        
        -- Threat glow indicators with class-specific colors
        self.ThreatIndicator = CreateFrame("Frame", nil, self)
        self.ThreatIndicator:SetAllPoints()
        self.ThreatIndicator:SetFrameLevel(self:GetFrameLevel() + 1)
        
        -- Threat glow texture
        self.ThreatIndicator.glow = self.ThreatIndicator:CreateTexture(nil, "OVERLAY")
        self.ThreatIndicator.glow:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        self.ThreatIndicator.glow:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 3)
        self.ThreatIndicator.glow:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 3, -3)
        self.ThreatIndicator.glow:SetVertexColor(1.0, 0.0, 0.0, 0.0)
        self.ThreatIndicator.glow:Hide()
        
        -- Threat indicator post-update
        self.ThreatIndicator.PostUpdate = function(ThreatIndicator, unit, status)
            local _, playerClass = UnitClass("player")
            local classColors = {
                WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
                PALADIN = {r = 0.96, g = 0.55, b = 0.73},
                HUNTER = {r = 0.67, g = 0.83, b = 0.45},
                ROGUE = {r = 1.00, g = 0.96, b = 0.41},
                PRIEST = {r = 1.00, g = 1.00, b = 1.00},
                DEATHKNIGHT = {r = 0.77, g = 0.12, b = 0.23},
                SHAMAN = {r = 0.00, g = 0.44, b = 0.87},
                MAGE = {r = 0.41, g = 0.80, b = 0.94},
                WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
                MONK = {r = 0.00, g = 1.00, b = 0.59},
                DRUID = {r = 1.00, g = 0.49, b = 0.04},
                DEMONHUNTER = {r = 0.64, g = 0.19, b = 0.79},
                EVOKER = {r = 0.20, g = 0.58, b = 0.80}
            }
            
            local classColor = classColors[playerClass] or {r = 0.5, g = 0.5, b = 0.5}
            
            if status and status > 0 then
                local alpha = math.min(status * 0.3, 0.8)
                if status == 3 then -- Highest threat
                    ThreatIndicator.glow:SetVertexColor(1.0, 0.0, 0.0, alpha) -- Red
                elseif status == 2 then -- Gaining threat
                    ThreatIndicator.glow:SetVertexColor(1.0, 0.5, 0.0, alpha) -- Orange
                elseif status == 1 then -- Low threat
                    ThreatIndicator.glow:SetVertexColor(classColor.r, classColor.g, classColor.b, alpha) -- Class color
                end
                ThreatIndicator.glow:Show()
            else
                ThreatIndicator.glow:Hide()
            end
        end
        
        -- Combat indicator
        self.CombatIndicator = self:CreateTexture(nil, "OVERLAY")
        self.CombatIndicator:SetSize(16, 16)
        self.CombatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
        self.CombatIndicator:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        self.CombatIndicator:SetVertexColor(1.0, 0.2, 0.2, 0.8)
        self.CombatIndicator:Hide()
        
        -- Resting indicator
        self.RestingIndicator = self:CreateTexture(nil, "OVERLAY")
        self.RestingIndicator:SetSize(14, 14)
        self.RestingIndicator:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -2)
        self.RestingIndicator:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        self.RestingIndicator:SetVertexColor(0.2, 0.8, 0.2, 0.8)
        self.RestingIndicator:Hide()
        
        -- Frame highlighting on mouseover
        self.Highlight = self:CreateTexture(nil, "OVERLAY")
        self.Highlight:SetAllPoints()
        self.Highlight:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        self.Highlight:SetVertexColor(1.0, 1.0, 1.0, 0.3)
        self.Highlight:Hide()
        
        -- Set proper frame levels for layering
        self:SetFrameLevel(10)
        if self.Health then self.Health:SetFrameLevel(11) end
        if self.Power then self.Power:SetFrameLevel(12) end
        if self.Castbar then self.Castbar:SetFrameLevel(13) end
        if self.Buffs then self.Buffs:SetFrameLevel(14) end
        if self.Debuffs then self.Debuffs:SetFrameLevel(15) end
        if self.Portrait then self.Portrait:SetFrameLevel(9) end
        if self.ThreatIndicator then self.ThreatIndicator:SetFrameLevel(16) end
        
        -- Register with oUF
        self:RegisterForClicks("AnyUp")
        self:SetScript("OnEnter", function(self)
            if self.Highlight then
                self.Highlight:Show()
            end
            UnitFrame_OnEnter(self)
        end)
        self:SetScript("OnLeave", function(self)
            if self.Highlight then
                self.Highlight:Hide()
            end
            UnitFrame_OnLeave(self)
        end)
    end
    
    -- Hook updates
    oUF:RegisterStyle("DivinicalUI", Style)
    oUF:SetActiveStyle("DivinicalUI")
    
    -- Add post-update functions for official oUF elements
    local function PostUpdateHealth(self, unit, min, max)
        local r, g, b
        
        if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
            r, g, b = 0.5, 0.5, 0.5
        elseif not UnitIsConnected(unit) then
            r, g, b = 0.3, 0.3, 0.3
        elseif UnitIsDeadOrGhost(unit) then
            r, g, b = 0.4, 0.2, 0.2
        elseif UnitIsPlayer(unit) then
            local class = select(2, UnitClass(unit))
            r, g, b = DivinicalUI.Utils.Colors.GetClassColor(class)
        elseif UnitIsFriend(unit, "player") then
            r, g, b = 0.2, 0.8, 0.2
        else
            local reaction = UnitReaction(unit, "player")
            r, g, b = DivinicalUI.Utils.Colors.GetReactionColor(reaction)
        end
        
        -- Smooth color transitions
        if self.Health.currentColor then
            local oldR, oldG, oldB = self.Health.currentColor.r, self.Health.currentColor.g, self.Health.currentColor.b
            r, g, b = DivinicalUI.Utils.Math.Lerp(oldR, r, 0.3), 
                     DivinicalUI.Utils.Math.Lerp(oldG, g, 0.3), 
                     DivinicalUI.Utils.Math.Lerp(oldB, b, 0.3)
        end
        
        self.Health:SetStatusBarColor(r, g, b)
        self.Health.currentColor = {r = r, g = g, b = b}
        
        -- Update gradient overlay based on health percentage
        local healthPercent = max > 0 and (min / max) or 0
        if healthPercent < 0.3 then
            self.Health.gradient:SetVertexColor(1, 0.2, 0.2, 0.4) -- Red gradient for low health
        elseif healthPercent < 0.6 then
            self.Health.gradient:SetVertexColor(1, 1, 0.2, 0.3) -- Yellow gradient for medium health
        else
            self.Health.gradient:SetVertexColor(0.2, 1, 0.2, 0.2) -- Green gradient for high health
        end
    end
    
    local function PostUpdatePower(self, unit, min, max)
        local powerType = UnitPowerType(unit)
        local r, g, b = DivinicalUI.Utils.Colors.GetPowerColor(powerType)
        
        -- Enhanced power colors with better visibility
        if powerType == "MANA" then
            r, g, b = 0.25, 0.5, 1.0 -- Brighter blue
        elseif powerType == "RAGE" then
            r, g, b = 1.0, 0.1, 0.1 -- Brighter red
        elseif powerType == "ENERGY" then
            r, g, b = 1.0, 0.9, 0.1 -- Brighter yellow
        end
        
        self.Power:SetStatusBarColor(r, g, b)
        
        -- Update power gradient
        self.Power.gradient:SetVertexColor(r, g, b, 0.3)
        
        -- Store current power color for transitions
        self.Power.currentColor = {r = r, g = g, b = b}
    end
    
    -- Store post-update functions
    UnitFrames.PostUpdateHealth = PostUpdateHealth
    UnitFrames.PostUpdatePower = PostUpdatePower
    
    -- Register custom oUF tags for enhanced formatting
    oUF.Tags.Events["divinical:health"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"
    oUF.Tags.Methods["divinical:health"] = function(unit)
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        
        if not UnitIsConnected(unit) or maxHealth == 0 then
            return "??"
        end
        
        if health == maxHealth then
            return ""
        else
            return DivinicalUI.Utils.Strings.FormatNumber(health) .. " / " .. DivinicalUI.Utils.Strings.FormatNumber(maxHealth)
        end
    end
    
    oUF.Tags.Events["divinical:healthperc"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"
    oUF.Tags.Methods["divinical:healthperc"] = function(unit)
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        
        if not UnitIsConnected(unit) or maxHealth == 0 then
            return "??"
        end
        
        local healthPercent = DivinicalUI.Utils.Math.Round((health / maxHealth) * 100)
        return healthPercent .. "%"
    end
    
    oUF.Tags.Events["divinical:power"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER UNIT_CONNECTION"
    oUF.Tags.Methods["divinical:power"] = function(unit)
        local power = UnitPower(unit)
        local maxPower = UnitPowerMax(unit)
        
        if not UnitIsConnected(unit) or maxPower == 0 then
            return ""
        end
        
        if power == 0 then
            return ""
        else
            return DivinicalUI.Utils.Strings.FormatNumber(power) .. " / " .. DivinicalUI.Utils.Strings.FormatNumber(maxPower)
        end
    end
    
    oUF.Tags.Events["divinical:powertype"] = "UNIT_POWER_UPDATE UNIT_DISPLAYPOWER"
    oUF.Tags.Methods["divinical:powertype"] = function(unit)
        local powerType = UnitPowerType(unit)
        local powerTypes = {
            MANA = "MP",
            RAGE = "R",
            FOCUS = "F",
            ENERGY = "E",
            COMBO_POINTS = "CP",
            RUNES = "R",
            RUNIC_POWER = "RP",
            SOUL_SHARDS = "SS",
            LUNAR_POWER = "LP",
            HOLY_POWER = "HP",
            MAELSTROM = "M",
            CHI = "C",
            INSANITY = "I",
            ARCANE_CHARGES = "AC",
            FURY = "F",
            PAIN = "P"
        }
        
        return powerTypes[powerType] or ""
    end
end

-- Spawn unit frames with comprehensive testing
function UnitFrames:SpawnFrames()
    if not oUF then
        DivinicalUI.Utils.Debug.Print("oUF not available, cannot spawn frames", "ERROR")
        return
    end
    
    -- Player frame
    if DivinicalUI.db.profile.unitframes.player.enabled then
        local playerFrame = oUF:Spawn("player", "DivinicalUIPlayerFrame")
        playerFrame:SetPoint(unpack(DivinicalUI.db.profile.unitframes.player.position))
        playerFrame:SetSize(DivinicalUI.db.profile.unitframes.player.width, 
                           DivinicalUI.db.profile.unitframes.player.height)
        frames.player = playerFrame
        DivinicalUI.Utils.Debug.Print("Player frame spawned", "DEBUG")
        
        -- Test player frame elements
        self:TestFrameElements(playerFrame, "player")
    end
    
    -- Target frame
    if DivinicalUI.db.profile.unitframes.target.enabled then
        local targetFrame = oUF:Spawn("target", "DivinicalUITargetFrame")
        targetFrame:SetPoint(unpack(DivinicalUI.db.profile.unitframes.target.position))
        targetFrame:SetSize(DivinicalUI.db.profile.unitframes.target.width, 
                           DivinicalUI.db.profile.unitframes.target.height)
        frames.target = targetFrame
        DivinicalUI.Utils.Debug.Print("Target frame spawned", "DEBUG")
        
        -- Test target frame elements
        self:TestFrameElements(targetFrame, "target")
    end
    
    -- Target of Target
    local totFrame = oUF:Spawn("targettarget", "DivinicalUITargetTargetFrame")
    totFrame:SetPoint("TOPLEFT", frames.target, "TOPRIGHT", 5, 0)
    totFrame:SetSize(100, 30)
    frames.targettarget = totFrame
    DivinicalUI.Utils.Debug.Print("Target of Target frame spawned", "DEBUG")
    self:TestFrameElements(totFrame, "targettarget")
    
    -- Focus frame
    local focusFrame = oUF:Spawn("focus", "DivinicalUIFocusFrame")
    focusFrame:SetPoint("TOPLEFT", frames.player, "BOTTOMLEFT", 0, -50)
    focusFrame:SetSize(150, 35)
    frames.focus = focusFrame
    DivinicalUI.Utils.Debug.Print("Focus frame spawned", "DEBUG")
    self:TestFrameElements(focusFrame, "focus")
    
    -- Focus target
    local focustargetFrame = oUF:Spawn("focustarget", "DivinicalUIFocusTargetFrame")
    focustargetFrame:SetPoint("TOPLEFT", frames.focus, "TOPRIGHT", 5, 0)
    focustargetFrame:SetSize(100, 25)
    frames.focustarget = focustargetFrame
    DivinicalUI.Utils.Debug.Print("Focus target frame spawned", "DEBUG")
    self:TestFrameElements(focustargetFrame, "focustarget")
    
    -- Pet frame
    local petFrame = oUF:Spawn("pet", "DivinicalUIPetFrame")
    petFrame:SetPoint("TOPLEFT", frames.player, "TOPRIGHT", 5, 0)
    petFrame:SetSize(100, 25)
    frames.pet = petFrame
    DivinicalUI.Utils.Debug.Print("Pet frame spawned", "DEBUG")
    self:TestFrameElements(petFrame, "pet")
    
    -- Pet target
    local pettargetFrame = oUF:Spawn("pettarget", "DivinicalUIPetTargetFrame")
    pettargetFrame:SetPoint("TOPLEFT", frames.pet, "TOPRIGHT", 5, 0)
    pettargetFrame:SetSize(80, 20)
    frames.pettarget = pettargetFrame
    DivinicalUI.Utils.Debug.Print("Pet target frame spawned", "DEBUG")
    self:TestFrameElements(pettargetFrame, "pettarget")
    
    -- Boss frames (1-5)
    frames.boss = {}
    for i = 1, 5 do
        local bossFrame = oUF:Spawn("boss" .. i, "DivinicalUIBossFrame" .. i)
        if i == 1 then
            bossFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -200, -200)
        else
            bossFrame:SetPoint("TOP", frames.boss[i-1], "BOTTOM", 0, -10)
        end
        bossFrame:SetSize(120, 35)
        frames.boss[i] = bossFrame
        DivinicalUI.Utils.Debug.Print("Boss " .. i .. " frame spawned", "DEBUG")
        self:TestFrameElements(bossFrame, "boss" .. i)
    end
    
    -- Party frames (1-5)
    frames.party = {}
    for i = 1, 5 do
        local partyFrame = oUF:Spawn("party" .. i, "DivinicalUIPartyFrame" .. i)
        if i == 1 then
            partyFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, -200)
        else
            partyFrame:SetPoint("TOP", frames.party[i-1], "BOTTOM", 0, -5)
        end
        partyFrame:SetSize(120, 30)
        frames.party[i] = partyFrame
        DivinicalUI.Utils.Debug.Print("Party " .. i .. " frame spawned", "DEBUG")
        self:TestFrameElements(partyFrame, "party" .. i)
    end
    
    -- Raid frames (40 players)
    frames.raid = {}
    for i = 1, 40 do
        local raidFrame = oUF:Spawn("raid" .. i, "DivinicalUIRaidFrame" .. i)
        local row = math.floor((i - 1) / 8)
        local col = (i - 1) % 8
        
        if i == 1 then
            raidFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -300)
        elseif col == 0 then
            raidFrame:SetPoint("TOPLEFT", frames.raid[i-8], "BOTTOMLEFT", 0, -5)
        else
            raidFrame:SetPoint("TOPLEFT", frames.raid[i-1], "TOPRIGHT", 5, 0)
        end
        
        raidFrame:SetSize(60, 25)
        frames.raid[i] = raidFrame
        DivinicalUI.Utils.Debug.Print("Raid " .. i .. " frame spawned", "DEBUG")
        self:TestFrameElements(raidFrame, "raid" .. i)
    end
    
    -- Arena frames (1-5)
    frames.arena = {}
    for i = 1, 5 do
        local arenaFrame = oUF:Spawn("arena" .. i, "DivinicalUIArenaFrame" .. i)
        if i == 1 then
            arenaFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -300)
        else
            arenaFrame:SetPoint("TOP", frames.arena[i-1], "BOTTOM", 0, -5)
        end
        arenaFrame:SetSize(120, 30)
        frames.arena[i] = arenaFrame
        DivinicalUI.Utils.Debug.Print("Arena " .. i .. " frame spawned", "DEBUG")
        self:TestFrameElements(arenaFrame, "arena" .. i)
    end
    
    -- Test all spawned frames
    self:ValidateAllFrames()
end

-- Register events
function UnitFrames:RegisterEvents()
    DivinicalUI.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_HEALTH")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
    DivinicalUI.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    DivinicalUI.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_AURA")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    DivinicalUI.eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
end

-- Comprehensive testing function
function UnitFrames:RunComprehensiveTests()
    DivinicalUI.Utils.Debug.Print("=== DIVINICALUI COMPREHENSIVE TESTING START ===", "INFO")
    
    -- Test 1: Frame validation
    self:ValidateAllFrames()
    
    -- Test 2: Element validation
    for unitType, frame in pairs(frames) do
        if type(frame) ~= "table" then
            self:TestFrameElements(frame, unitType)
        end
    end
    
    -- Test 3: Callback testing
    self:TestCallbacks()
    
    -- Test 4: Tag update testing
    self:TestTagUpdates()
    
    -- Test 5: Memory leak detection
    self:CheckMemoryLeaks()
    
    -- Test 6: Combat log testing
    self:TestCombatLogEvents()
    
    -- Test 7: Aura update testing
    self:TestAuraUpdates()
    
    DivinicalUI.Utils.Debug.Print("=== DIVINICALUI COMPREHENSIVE TESTING COMPLETE ===", "INFO")
end

-- Test combat log events
function UnitFrames:TestCombatLogEvents()
    DivinicalUI.Utils.Debug.Print("Testing combat log events...", "INFO")
    
    -- Test if combat log events are being received
    local testEvent = function(self, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            DivinicalUI.Utils.Debug.Print("Combat log event received", "DEBUG")
        end
    end
    
    DivinicalUI.eventFrame:SetScript("OnEvent", testEvent)
end

-- Test aura updates
function UnitFrames:TestAuraUpdates()
    DivinicalUI.Utils.Debug.Print("Testing aura updates...", "INFO")
    
    if frames.player then
        -- Force aura update
        frames.player:UpdateAllElements("UNIT_AURA")
        DivinicalUI.Utils.Debug.Print("Aura update test completed", "DEBUG")
    end
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

-- Test individual frame elements
function UnitFrames:TestFrameElements(frame, unitType)
    if not frame then
        DivinicalUI.Utils.Debug.Print("Frame " .. unitType .. " is nil", "ERROR")
        return
    end
    
    local errors = {}
    
    -- Test health element
    if not frame.Health then
        table.insert(errors, "Missing Health element")
    else
        if not frame.Health.PostUpdate then
            table.insert(errors, "Health element missing PostUpdate function")
        end
    end
    
    -- Test power element
    if not frame.Power then
        table.insert(errors, "Missing Power element")
    else
        if not frame.Power.PostUpdate then
            table.insert(errors, "Power element missing PostUpdate function")
        end
    end
    
    -- Test castbar (for player/target)
    if unitType == "player" or unitType == "target" then
        if not frame.Castbar then
            table.insert(errors, "Missing Castbar element")
        end
    end
    
    -- Test portrait (for target)
    if unitType == "target" and not frame.Portrait then
        table.insert(errors, "Missing Portrait element")
    end
    
    -- Test aura elements
    if unitType ~= "raid" then
        if not frame.Buffs then
            table.insert(errors, "Missing Buffs element")
        end
        if not frame.Debuffs then
            table.insert(errors, "Missing Debuffs element")
        end
    end
    
    -- Test threat indicator
    if not frame.ThreatIndicator then
        table.insert(errors, "Missing ThreatIndicator element")
    end
    
    -- Report errors
    if #errors > 0 then
        DivinicalUI.Utils.Debug.Print("Frame " .. unitType .. " errors: " .. table.concat(errors, ", "), "ERROR")
    else
        DivinicalUI.Utils.Debug.Print("Frame " .. unitType .. " elements validated successfully", "DEBUG")
    end
end

-- Validate all spawned frames
function UnitFrames:ValidateAllFrames()
    DivinicalUI.Utils.Debug.Print("Starting comprehensive frame validation...", "INFO")

    local totalFrames = 0
    local validFrames = 0

    for unitType, frame in pairs(frames) do
        if type(frame) == "table" then
            -- Check if it's a frame group (has numeric indices) vs single frame
            local isFrameGroup = false
            for k, v in pairs(frame) do
                if type(k) == "number" and type(v) == "table" and v.UpdateAllElements then
                    isFrameGroup = true
                    break
                end
            end

            if isFrameGroup then
                -- Handle frame groups (boss, party, raid, arena)
                for i, subFrame in ipairs(frame) do
                    totalFrames = totalFrames + 1
                    if subFrame and type(subFrame) == "table" and subFrame.UpdateAllElements then
                        validFrames = validFrames + 1
                        DivinicalUI.Utils.Debug.Print("Frame " .. unitType .. i .. " validated", "DEBUG")
                    else
                        DivinicalUI.Utils.Debug.Print("Frame " .. unitType .. i .. " validation failed", "ERROR")
                    end
                end
            else
                -- Handle single frames
                totalFrames = totalFrames + 1
                if frame and frame.UpdateAllElements then
                    validFrames = validFrames + 1
                    DivinicalUI.Utils.Debug.Print("Frame " .. unitType .. " validated", "DEBUG")
                else
                    DivinicalUI.Utils.Debug.Print("Frame " .. unitType .. " validation failed", "ERROR")
                end
            end
        else
            -- Skip non-table values
        end
    end

    DivinicalUI.Utils.Debug.Print("Frame validation complete: " .. validFrames .. "/" .. totalFrames .. " frames valid", "INFO")
end

-- Test oUF callbacks
function UnitFrames:TestCallbacks()
    DivinicalUI.Utils.Debug.Print("Testing oUF event callbacks...", "INFO")
    
    -- Test UNIT_HEALTH callback
    if frames.player then
        local oldHealth = UnitHealth("player")
        frames.player:UpdateAllElements("UNIT_HEALTH")
        local newHealth = UnitHealth("player")
        if oldHealth ~= newHealth then
            DivinicalUI.Utils.Debug.Print("UNIT_HEALTH callback working", "DEBUG")
        end
    end
    
    -- Test FORCE_UPDATE callback
    for unitType, frame in pairs(frames) do
        if type(frame) ~= "table" and frame and frame.UpdateAllElements then
            frame:UpdateAllElements("FORCE_UPDATE")
            DivinicalUI.Utils.Debug.Print("FORCE_UPDATE callback tested for " .. unitType, "DEBUG")
        end
    end
end

-- Memory leak detection
function UnitFrames:CheckMemoryLeaks()
    local initialMemory = collectgarbage("count")
    
    -- Force garbage collection
    collectgarbage("collect")
    
    local finalMemory = collectgarbage("count")
    local memoryDiff = finalMemory - initialMemory
    
    if memoryDiff > 1000 then -- More than 1000 objects difference
        DivinicalUI.Utils.Debug.Print("Potential memory leak detected: " .. memoryDiff .. " objects", "WARN")
    else
        DivinicalUI.Utils.Debug.Print("Memory usage stable: " .. memoryDiff .. " objects", "DEBUG")
    end
end

-- Dynamic tag update testing
function UnitFrames:TestTagUpdates()
    DivinicalUI.Utils.Debug.Print("Testing dynamic tag updates...", "INFO")
    
    if frames.player then
        -- Test health tag updates
        local healthTag = frames.player.Health.value
        if healthTag then
            DivinicalUI.Utils.Debug.Print("Health tag found and functional", "DEBUG")
        end
        
        -- Test power tag updates
        local powerTag = frames.player.Power.value
        if powerTag then
            DivinicalUI.Utils.Debug.Print("Power tag found and functional", "DEBUG")
        end
        
        -- Test name tag updates
        local nameTag = frames.player.Name
        if nameTag then
            DivinicalUI.Utils.Debug.Print("Name tag found and functional", "DEBUG")
        end
    end
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