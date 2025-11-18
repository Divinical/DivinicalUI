# DivinicalUI - Product Requirements Document
## Part 1: Executive Overview & Market Analysis

**Version:** 2.0  
**Date:** October 29, 2025  
**Status:** Pre-Development  

---

## Executive Summary

**DivinicalUI** is a next-generation World of Warcraft UI addon designed specifically for the post-Midnight expansion era. Unlike legacy addons that rely on complex combat logic (which Blizzard is phasing out), DivinicalUI focuses on visual excellence, performance, and seamless integration with Blizzard's new native combat systems.

### Core Value Proposition
> "When Midnight breaks the old addons, DivinicalUI will be ready. Beautiful. Fast. Future-proof."

### Target Market
- Players seeking ElvUI alternatives (frustrated with bloat/complexity)
- New/returning players wanting modern, clean UI
- Performance-focused players (competitive M+/raiding)
- Streamers/content creators who need aesthetically pleasing UI
- Players preparing for Midnight expansion

### Success Metrics
- 10,000 downloads within 3 months of launch
- 4.5+ star rating on CurseForge
- Top 10 UI addon by Midnight launch
- 100,000+ downloads within 6 months of Midnight

---

## 1. Market Analysis & Competitive Landscape

### 1.1 Current Market State (October 2025)

**Market Size:**
- 7+ million active WoW subscribers (Retail)
- ~85% use UI addons (industry estimate)
- UI addon category: 500M+ total downloads on CurseForge

**Market Leaders:**
1. **ElvUI** - 100M+ downloads, dominant market leader
2. **Bartender4** - 50M+ downloads, action bar specialist
3. **Shadowed Unit Frames** - 25M+ downloads, unit frame specialist
4. **GW2UI** - 2.4M+ downloads, aesthetic niche

### 1.2 Competitive Analysis

#### ElvUI (Market Leader)
**Strengths:**
- Comprehensive all-in-one solution
- Large plugin ecosystem
- Strong community (Discord, forums)
- Well-documented
- 15+ years of development

**Weaknesses:**
- Bloated (10MB+ memory footprint)
- Steep learning curve (3000+ settings)
- Slow performance on low-end systems
- Not on CurseForge (manual installation)
- Legacy codebase vulnerable to Midnight API changes
- **Complex combat logic will break in Patch 12.0**

**Market Share:** ~40% of UI addon users

#### GW2UI
**Strengths:**
- Beautiful Guild Wars 2-inspired design
- Unique aesthetic
- Available on CurseForge
- Minimalist approach

**Weaknesses:**
- Limited customization
- Smaller feature set
- Less active development
- Compatibility issues

**Market Share:** ~5% of UI addon users

#### LUI (Loui UI)
**Strengths:**
- Extreme customization (3000+ options)
- 200+ textures
- Feature-complete

**Weaknesses:**
- Complex setup process
- Smaller community
- Overwhelming for new users
- Potential Midnight API issues

**Market Share:** ~3% of UI addon users

### 1.3 Market Opportunity: The Midnight Disruption

**Blizzard's October 2025 Announcement:**

> "At an undetermined point in the future, WoW will stop allowing add-ons to read combat events or auras for decision-making purposes."

**Impact on Competition:**
- ElvUI's complex combat logic will require complete rewrite
- WeakAuras community will fragment (conditional triggers broken)
- Damage meters limited to display-only
- Smart nameplate filtering will stop working
- Boss mods (DBM/BigWigs) must rebuild from scratch

**Our Opportunity:**
1. **Level playing field** - All addons must adapt to Midnight
2. **First-mover advantage** - Build for Midnight from day one
3. **Capture fleeing users** - Users abandoning broken addons
4. **Blizzard UI wrapper** - Style Blizzard's new (ugly) native combat UI
5. **Simpler codebase** - No complex combat logic = faster, more stable

**Market Gaps:**
- No major UI addon built specifically for Midnight API
- Lack of lightweight, beautiful alternatives to ElvUI
- Poor integration with Blizzard's upcoming native features
- Need for performance-focused UI addons

---

## 2. User Personas

### 2.1 "Competitive Chris" (Primary)
- **Demographics:** Male, 25-35, plays 20+ hours/week
- **Content:** Mythic raiding, high M+ keys (20+), some PvP
- **Current UI:** ElvUI, frustrated with performance issues
- **Pain Points:**
  - FPS drops in 20-man raids (UI overhead)
  - Complex ElvUI configuration takes hours
  - Worried about Midnight breaking current setup
- **Goals:**
  - Maximize performance (high FPS)
  - Clean, minimal UI that shows critical info only
  - Easy to set up and maintain
- **Quote:** *"I don't need 3000 options. I need something that works and doesn't tank my FPS."*

### 2.2 "Aesthetic Ashley" (Primary)
- **Demographics:** Female, 20-30, casual/moderate player (10 hours/week)
- **Content:** Normal/Heroic raiding, low M+ keys, pet battles, transmog
- **Current UI:** GW2UI or heavily customized Blizzard UI
- **Pain Points:**
  - Default UI is ugly but ElvUI is too complicated
  - Wants beautiful UI without spending hours configuring
  - Struggles with addon conflicts
- **Goals:**
  - Gorgeous UI out of the box
  - Matches her stream aesthetic
  - Multiple themes for different characters
- **Quote:** *"I want my UI to look as good as my transmog. Why is that so hard?"*

### 2.3 "Newbie Nathan" (Secondary)
- **Demographics:** Male, 18-25, just started WoW (< 6 months)
- **Content:** Leveling, Normal dungeons, LFR
- **Current UI:** Default Blizzard UI + maybe 1-2 basic addons
- **Pain Points:**
  - Overwhelmed by addon complexity
  - Doesn't know what UI addons even do
  - Afraid of "breaking" his game with wrong settings
- **Goals:**
  - Simple installation (one click)
  - Works immediately with sensible defaults
  - Can customize later as he learns
- **Quote:** *"I just want a better UI without spending my entire weekend setting it up."*

### 2.4 "Streamer Sarah" (Primary)
- **Demographics:** Female, 25-35, streams 15+ hours/week
- **Content:** Variety (M+, raids, achievement hunting, mount farming)
- **Current UI:** Custom ElvUI profile, WeakAuras packs
- **Pain Points:**
  - UI looks outdated on stream
  - Viewers constantly ask "what UI is that?"
  - Worried Midnight will break entire setup
- **Goals:**
  - Professional-looking UI for brand
  - Easy to share profiles with viewers
  - Future-proof for Midnight
- **Quote:** *"My UI is part of my brand. I need it to look amazing and work reliably."*

---

## 3. Product Vision & Strategy

### 3.1 Vision Statement

**"DivinicalUI is the beautiful, lightning-fast UI addon built for World of Warcraft's future. When Midnight changes everything, we'll be the addon that just works."**

### 3.2 Core Principles

1. **Performance First**
   - Target: < 3MB memory baseline
   - Target: < 0.5% CPU in combat
   - Lazy loading for all non-critical features
   - No FPS drops, ever

2. **Beauty by Default**
   - Gorgeous out of the box
   - Professional themes included
   - Smooth animations and transitions
   - Every pixel matters

3. **Simplicity in Complexity**
   - Works perfectly with zero configuration
   - Deep customization for power users
   - Progressive disclosure (simple → advanced)
   - Never overwhelm users

4. **Future-Proof Design**
   - Built for Midnight API from day one
   - No reliance on deprecated combat APIs
   - Wrapper-based architecture for Blizzard features
   - Graceful degradation if APIs change

5. **Community-Driven**
   - Profile sharing (import/export)
   - Active Discord community
   - User feedback shapes development
   - Open development roadmap

### 3.3 Product Positioning

**Positioning Statement:**
> "For WoW players who want a beautiful, high-performance UI without ElvUI's complexity, DivinicalUI is the modern UI addon that combines stunning visuals with rock-solid performance. Unlike legacy addons vulnerable to Midnight's API changes, DivinicalUI is built from the ground up for WoW's future."

**Key Differentiators:**
1. **Midnight-Ready:** Built for Patch 12.0 API from day one
2. **Performance King:** Provably faster than ElvUI (benchmarks)
3. **Beautiful by Default:** Professional themes, no configuration needed
4. **Blizzard Integration:** Wraps and styles native UI features
5. **Simple Power:** Works immediately, customizable deeply

### 3.4 Three-Phase Strategy

#### Phase 1: Pre-Midnight Launch (Months 1-4)
**Goal:** Establish market presence as "best visual UI addon"
- Launch with core features (unit frames, action bars, themes)
- Focus on beauty and performance
- Build community (Discord, Reddit)
- Partner with streamers for visibility
- **Success: 10,000 downloads, 4.5+ stars**

#### Phase 2: Midnight Preparation (Months 5-6)
**Goal:** Be first addon fully compatible with Midnight
- Extensive testing on Midnight Alpha/Beta/PTR
- Build Blizzard UI wrapper system
- "Midnight-ready" marketing campaign
- **Success: Day 1 Midnight compatibility**

#### Phase 3: Midnight Launch (Month 7+)
**Goal:** Dominate market share during addon chaos
- Be FIRST with full Midnight support
- Capture users fleeing broken addons
- ElvUI migration tool (import settings)
- **Success: 100,000 downloads, Top 5 UI addon**

---

## 4. The Midnight Challenge

### 4.1 What Blizzard is Changing

**From Blizzard's Official Post (October 2025):**

> "Addons will no longer be able to use combat information to drive custom logic or make decisions for you."

### 4.2 What's Allowed vs. Restricted

#### ✅ ALLOWED (Display & Styling)
- Move, resize, recolor UI elements
- Change fonts, textures, borders
- Apply themes and skins
- Show health bars, buff icons, cast bars
- User-defined rules (manual spell ID assignments)

#### ❌ RESTRICTED (Logic & Automation)
- Conditional logic based on combat ("If health < 20%, show warning")
- Decision-making ("Use ability X now")
- Automatic filtering ("Hide unimportant buffs")
- Combat event reading for logic

### 4.3 DivinicalUI's Compliance Strategy

**Philosophy: "Display, Don't Decide"**

We build features that DISPLAY information (allowed) but never make DECISIONS (restricted).

**Example - Boss Warning Wrapper (Compliant):**
```lua
-- COMPLIANT: Restyle Blizzard's boss warning
function DivinicalUI.Wrapper:StyleBossWarning(blizzFrame)
    -- Blizzard says "Boss is casting Flame Breath"
    -- We don't analyze it, we just make it pretty
    
    local styled = CreateFrame("Frame", nil, UIParent)
    styled.text:SetText(blizzFrame:GetText()) -- Copy Blizzard's text
    styled.text:SetFont(DivinicalUI.Media.Fonts.Header, 24) -- Restyle
    styled:SetPoint("CENTER", 0, 200) -- Reposition
    LibCustomGlow.ButtonGlow_Start(styled) -- Add glow
    
    -- No decision-making, just styling
end
```

---

## 5. Competitive Advantage

### 5.1 Comparison Chart

| Feature | DivinicalUI | ElvUI | GW2UI | LUI |
|---------|-------------|-------|-------|-----|
| Memory (Idle) | < 3MB | 8-12MB | 5-8MB | 10-15MB |
| CPU (Combat) | < 0.5% | 0.8-1.2% | 0.5-0.8% | 1.0-1.5% |
| Setup Time | < 3 min | 30-60 min | 5 min | 60+ min |
| Themes Included | 5 | 0 | 1 | 3 |
| Midnight-Ready | ✅ Yes | ❓ TBD | ❓ TBD | ❓ TBD |
| CurseForge | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes |
| Settings Count | 500+ | 3000+ | 200+ | 3000+ |
| Complexity | Medium | High | Low | Very High |

### 5.2 The Winning Formula

```
Beautiful UI (GW2UI-level aesthetics)
+ High Performance (50% faster than ElvUI)
+ Midnight-Ready (Day 1 compatibility)
+ Simple Setup (3 minutes vs 30 minutes)
+ Community Support (Discord, streamers, docs)
= Market Leader
```

---

**[Continue to Part 2: Technical Specifications & Features →](PRD_PART2_TECHNICAL.md)**
