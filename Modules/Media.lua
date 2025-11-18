-- Media library module for DivinicalUI
local AddonName, DivinicalUI = ...

-- Media module
local Media = {}

-- LibSharedMedia reference
local LSM

-- Initialize LibSharedMedia
local function InitializeLSM()
    if not LibStub then return end
    LSM = LibStub:GetLibrary("LibSharedMedia-3.0", true)
end

-- Media storage
Media.fonts = {}
Media.textures = {}
Media.sounds = {}
Media.borders = {}
Media.statusbars = {}

-- Initialize media library
function Media:Initialize()
    InitializeLSM()
    self:RegisterFonts()
    self:RegisterTextures()
    self:RegisterSounds()
    self:RegisterBorders()
    self:RegisterStatusBars()
    
    DivinicalUI.modules.Utils.Debug.Print("Media library initialized", "INFO")
end

-- Register fonts with LibSharedMedia
function Media:RegisterFonts()
    if not LSM then
        DivinicalUI.modules.Utils.Debug.Print("LibSharedMedia not available, skipping font registration", "WARN")
        return
    end

    -- Register default font
    local defaultFont = "Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Font.ttf"
    LSM:Register("font", "DivinicalUI Default", defaultFont)

    -- Register Expressway font
    local expresswayFont = "Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Expressway.ttf"
    LSM:Register("font", "Expressway", expresswayFont)
    Media.fonts.expressway = expresswayFont

    -- Register PT Sans font
    local ptSansFont = "Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\PTSans.ttf"
    LSM:Register("font", "PT Sans", ptSansFont)
    Media.fonts.ptsans = ptSansFont

    -- Register pixel font for UI elements
    local pixelFont = "Interface\\AddOns\\DivinicalUI\\Media\\Fonts\\Pixel.ttf"
    LSM:Register("font", "DivinicalUI Pixel", pixelFont)
    Media.fonts.pixel = pixelFont

    -- Set default fonts
    Media.fonts.default = defaultFont
    Media.fonts.normal = LSM:GetDefault("font") or defaultFont
    Media.fonts.bold = LSM:Fetch("font", "Arial Bold", true) or defaultFont
    Media.fonts.small = LSM:Fetch("font", "Arial Narrow", true) or defaultFont

    DivinicalUI.modules.Utils.Debug.Print("Fonts registered with LibSharedMedia", "DEBUG")
end

-- Register textures with LibSharedMedia
function Media:RegisterTextures()
    if not LSM then
        DivinicalUI.modules.Utils.Debug.Print("LibSharedMedia not available, skipping texture registration", "WARN")
        return
    end

    -- Register status bar textures
    local aluminiumTexture = "Interface\\AddOns\\DivinicalUI\\Media\\Textures\\Aluminium"
    LSM:Register("statusbar", "Aluminium", aluminiumTexture)
    Media.textures.aluminium = aluminiumTexture

    local gradientTexture = "Interface\\AddOns\\DivinicalUI\\Media\\Textures\\Gradient"
    LSM:Register("statusbar", "DivinicalUI Gradient", gradientTexture)
    Media.textures.gradient = gradientTexture

    -- Register glow texture
    local glowTexture = "Interface\\AddOns\\DivinicalUI\\Media\\Textures\\Glow"
    LSM:Register("background", "DivinicalUI Glow", glowTexture)
    Media.textures.glow = glowTexture

    -- Set default textures
    Media.textures.default = "Interface\\TargetingFrame\\UI-StatusBar"
    Media.textures.normal = LSM:GetDefault("statusbar") or Media.textures.default
    Media.textures.background = "Interface\\DialogFrame\\UI-DialogBox-Background"

    DivinicalUI.modules.Utils.Debug.Print("Textures registered with LibSharedMedia", "DEBUG")
end

-- Register sounds with LibSharedMedia
function Media:RegisterSounds()
    if not LSM then
        DivinicalUI.modules.Utils.Debug.Print("LibSharedMedia not available, skipping sound registration", "WARN")
        return
    end

    -- Register custom sounds
    local alertSound = "Interface\\AddOns\\DivinicalUI\\Media\\Sounds\\Alert.ogg"
    LSM:Register("sound", "DivinicalUI Alert", alertSound)
    Media.sounds.alert = alertSound

    local readySound = "Interface\\AddOns\\DivinicalUI\\Media\\Sounds\\Ready.ogg"
    LSM:Register("sound", "DivinicalUI Ready", readySound)
    Media.sounds.ready = readySound

    -- Set default sounds
    Media.sounds.default = LSM:GetDefault("sound") or "Sound\\Interface\\RaidWarning.ogg"
    Media.sounds.raidwarning = "Interface\\AddOns\\DivinicalUI\\Media\\Sounds\\RaidWarning.ogg"
    Media.sounds.whisper = "Interface\\AddOns\\DivinicalUI\\Media\\Sounds\\Whisper.ogg"

    DivinicalUI.modules.Utils.Debug.Print("Sounds registered with LibSharedMedia", "DEBUG")
end

-- Register borders with LibSharedMedia
function Media:RegisterBorders()
    if not LSM then
        DivinicalUI.modules.Utils.Debug.Print("LibSharedMedia not available, skipping border registration", "WARN")
        return
    end

    -- Register glow border
    local glowBorder = "Interface\\AddOns\\DivinicalUI\\Media\\Borders\\Glow"
    LSM:Register("border", "DivinicalUI Glow", glowBorder)
    Media.borders.glow = glowBorder

    -- Register clean border
    local cleanBorder = "Interface\\AddOns\\DivinicalUI\\Media\\Borders\\Clean"
    LSM:Register("border", "DivinicalUI Clean", cleanBorder)
    Media.borders.clean = cleanBorder

    -- Register pixel border
    local pixelBorder = "Interface\\AddOns\\DivinicalUI\\Media\\Borders\\Pixel"
    LSM:Register("border", "DivinicalUI Pixel", pixelBorder)
    Media.borders.pixel = pixelBorder

    -- Set default borders
    Media.borders.default = "Interface\\Minimap\\MiniMap-TrackingBorder"
    Media.borders.normal = LSM:GetDefault("border") or Media.borders.default

    DivinicalUI.modules.Utils.Debug.Print("Borders registered with LibSharedMedia", "DEBUG")
end

-- Register status bars with LibSharedMedia
function Media:RegisterStatusBars()
    if not LSM then
        DivinicalUI.modules.Utils.Debug.Print("LibSharedMedia not available, skipping statusbar registration", "WARN")
        return
    end

    -- Register aluminium status bar
    local aluminiumBar = "Interface\\AddOns\\DivinicalUI\\Media\\Textures\\Aluminium"
    LSM:Register("statusbar", "DivinicalUI Aluminium", aluminiumBar)
    Media.statusbars.aluminium = aluminiumBar

    -- Register gradient status bar
    local gradientBar = "Interface\\AddOns\\DivinicalUI\\Media\\Textures\\Gradient"
    LSM:Register("statusbar", "DivinicalUI Gradient", gradientBar)
    Media.statusbars.gradient = gradientBar

    -- Set default status bars
    Media.statusbars.default = "Interface\\TargetingFrame\\UI-StatusBar"
    Media.statusbars.normal = LSM:GetDefault("statusbar") or Media.statusbars.default

    DivinicalUI.modules.Utils.Debug.Print("Status bars registered with LibSharedMedia", "DEBUG")
end

-- File existence checking removed - LibSharedMedia handles missing files gracefully

-- Get font with fallback
function Media:GetFont(fontName, size, flags)
    if not fontName then
        fontName = Media.fonts.normal
    end

    local font = LSM and LSM:Fetch("font", fontName, true) or Media.fonts.default
    return font, size or 12, flags or "OUTLINE"
end

-- Get texture with fallback
function Media:GetTexture(textureName)
    if not textureName then
        textureName = Media.textures.normal
    end

    return LSM and LSM:Fetch("statusbar", textureName, true) or Media.textures.default
end

-- Get sound with fallback
function Media:GetSound(soundName)
    if not soundName then
        soundName = Media.sounds.default
    end

    return LSM and LSM:Fetch("sound", soundName, true) or Media.sounds.default
end

-- Get border with fallback
function Media:GetBorder(borderName)
    if not borderName then
        borderName = Media.borders.normal
    end

    return LSM and LSM:Fetch("border", borderName, true) or Media.borders.default
end

-- Play sound with error handling
function Media:PlaySound(soundName)
    local sound = self:GetSound(soundName)
    if sound then
        PlaySound(sound, "Master")
    else
        DivinicalUI.modules.Utils.Debug.Print("Sound not found: " .. tostring(soundName), "WARN")
    end
end

-- Create font string with media font
function Media:CreateFontString(parent, name, fontName, size, flags)
    local font, fontSize, fontFlags = self:GetFont(fontName, size, flags)
    local fontString = parent:CreateFontString(name, "OVERLAY")
    fontString:SetFont(font, fontSize, fontFlags)
    fontString:SetShadowColor(0, 0, 0, 0.5)
    fontString:SetShadowOffset(1, -1)
    return fontString
end

-- Create status bar with media texture
function Media:CreateStatusBar(parent, name, textureName)
    local texture = self:GetTexture(textureName)
    local statusBar = CreateFrame("StatusBar", name, parent)
    statusBar:SetStatusBarTexture(texture)
    return statusBar
end

-- Create backdrop with media border
function Media:CreateBackdrop(edgeSize, borderName, bgFile)
    local border = self:GetBorder(borderName)
    return {
        edgeFile = border,
        edgeSize = edgeSize or 16,
        bgFile = bgFile or "Interface\\DialogFrame\\UI-DialogBox-Background",
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
end

-- Get class icon
function Media:GetClassIcon(class)
    class = class and class:upper()
    if not class then return nil end
    
    local classIcons = {
        WARRIOR = "Interface\\Icons\\Ability_Warrior_SavageBlow",
        PALADIN = "Interface\\Icons\\Spell_Holy_SealOfMight",
        HUNTER = "Interface\\Icons\\Ability_Hunter_RapidFire",
        ROGUE = "Interface\\Icons\\Ability_Stealth",
        PRIEST = "Interface\\Icons\\Spell_Holy_InnerFire",
        DEATHKNIGHT = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
        SHAMAN = "Interface\\Icons\\Spell_Nature_BloodLust",
        MAGE = "Interface\\Icons\\Spell_Frost_IceStorm",
        WARLOCK = "Interface\\Icons\\Spell_Shadow_CurseOfTounges",
        MONK = "Interface\\Icons\\Ability_Monk_QuiveringPalm",
        DRUID = "Interface\\Icons\\Spell_Nature_Regeneration",
        DEMONHUNTER = "Interface\\Icons\\Ability_DemonHunter_FelMomentum",
        EVOKER = "Interface\\Icons\\Ability_Evoke_ImaginedFlight"
    }
    
    return classIcons[class] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Get role icon
function Media:GetRoleIcon(role)
    local roleIcons = {
        TANK = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
        HEALER = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
        DAMAGER = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
    }
    
    local coords = {
        TANK = {0, 0.25, 0, 0.25},
        HEALER = {0.25, 0.5, 0, 0.25},
        DAMAGER = {0.5, 0.75, 0, 0.25}
    }
    
    return roleIcons[role], coords[role]
end

-- Get power type icon
function Media:GetPowerIcon(powerType)
    local powerIcons = {
        MANA = "Interface\\Icons\\Spell_Frost_IceStorm",
        RAGE = "Interface\\Icons\\Ability_Warrior_BloodRage",
        FOCUS = "Interface\\Icons\\Ability_Hunter_FocusedAim",
        ENERGY = "Interface\\Icons\\Ability_Rogue_Energy",
        COMBO_POINTS = "Interface\\Icons\\Ability_Rogue_SliceDice",
        RUNES = "Interface\\Icons\\Spell_Deathknight_BloodPlague",
        RUNIC_POWER = "Interface\\Icons\\INV_Sword_07",
        SOUL_SHARDS = "Interface\\Icons\\Spell_Warlock_SoulLink",
        LUNAR_POWER = "Interface\\Icons\\Spell_Druid_Starfall",
        HOLY_POWER = "Interface\\Icons\\Spell_Holy_DivinePurpose",
        MAELSTROM = "Interface\\Icons\\Spell_Shaman_MaelstromWeapon",
        CHI = "Interface\\Icons\\Ability_Monk_Jab",
        INSANITY = "Interface\\Icons\\Spell_Shadow_MindTwist",
        ARCANE_CHARGES = "Interface\\Icons\\Spell_Arcane_Blast",
        FURY = "Interface\\Icons\\Ability_DemonHunter_FelMomentum",
        PAIN = "Interface\\Icons\\Ability_DemonHunter_FelMomentum"
    }
    
    return powerIcons[powerType] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Post-initialization
function Media:PostInitialize()
    -- Called after all modules are loaded
    DivinicalUI.modules.Utils.Debug.Print("Media library post-initialization complete", "INFO")
end

-- Register module
DivinicalUI:RegisterModule("Media", Media)