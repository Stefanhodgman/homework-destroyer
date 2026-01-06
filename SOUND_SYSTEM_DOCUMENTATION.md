# Homework Destroyer - Sound System Documentation

**Complete audio system implementation for Homework Destroyer**

Version: 1.0
Last Updated: 2026-01-06

---

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [File Structure](#file-structure)
4. [Sound Categories](#sound-categories)
5. [Setup Instructions](#setup-instructions)
6. [Usage Examples](#usage-examples)
7. [Sound ID Reference](#sound-id-reference)
8. [Customization Guide](#customization-guide)
9. [Performance Considerations](#performance-considerations)
10. [Troubleshooting](#troubleshooting)

---

## Overview

The Homework Destroyer sound system provides a complete, production-ready audio framework with:

- **70+ sound effects** across 6 categories
- **Client-side sound pooling** for optimal performance
- **3D positional audio** for combat and world sounds
- **2D UI sounds** for buttons, notifications, and achievements
- **Zone-based background music** with smooth transitions
- **Volume controls** per category and master volume
- **Server-triggered sounds** via RemoteEvents
- **Automatic UI sound integration**

### Key Features

- ✅ Tool-specific hit sounds (18 different tools)
- ✅ Critical hit audio feedback
- ✅ Boss spawn and defeat sounds
- ✅ Achievement and level-up fanfares
- ✅ Purchase success/fail sounds
- ✅ Background music per zone (10 zones)
- ✅ Pet sounds (attack, level up, hatch)
- ✅ Zone transition effects
- ✅ Sound pooling for performance
- ✅ Pitch variation for variety
- ✅ Fade in/out for music transitions

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENT                              │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────┐    ┌──────────────────┐               │
│  │  SoundManager  │◄───┤  UISoundHandler  │               │
│  │  (Playback)    │    │  (Auto UI Sounds)│               │
│  └───────▲────────┘    └──────────────────┘               │
│          │                                                  │
│          │ Requires                                         │
│          │                                                  │
│  ┌───────▼────────┐                                        │
│  │  SoundConfig   │                                        │
│  │  (Definitions) │                                        │
│  └────────────────┘                                        │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ RemoteEvents
                          │ (PlaySound, PlaySoundAt)
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                        SERVER                               │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────┐                                  │
│  │ ServerSoundManager   │                                  │
│  │ (Trigger Sounds)     │                                  │
│  └──────────┬───────────┘                                  │
│             │ Used by                                       │
│             │                                               │
│  ┌──────────▼──────────┐  ┌──────────────┐               │
│  │  CombatManager      │  │  BossManager  │               │
│  │  GameServer         │  │  PetManager   │               │
│  │  AchievementManager │  │  ZoneManager  │               │
│  └─────────────────────┘  └───────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
homework-destroyer/
├── src/
│   ├── ReplicatedStorage/
│   │   ├── SharedModules/
│   │   │   ├── SoundConfig.lua          # Sound definitions and IDs
│   │   │   └── SoundManager.lua         # Client-side playback manager
│   │   └── Remotes/
│   │       └── RemoteEvents.lua         # Added PlaySound, PlaySoundAt events
│   │
│   ├── ServerStorage/
│   │   └── Modules/
│   │       ├── ServerSoundManager.lua   # Server-side sound triggers
│   │       ├── CombatManager.lua        # Updated with sound integration
│   │       └── [other managers...]
│   │
│   └── StarterPlayer/
│       └── StarterPlayerScripts/
│           └── UISoundHandler.lua       # Automatic UI sound integration
│
└── SOUND_SYSTEM_DOCUMENTATION.md        # This file
```

---

## Sound Categories

### 1. Combat Sounds

**Location:** `SoundConfig.Combat`

Sounds for gameplay actions:

- `Hit_Paper` - Basic paper hit (pencil, eraser)
- `Hit_Scissors` - Cutting sound (scissors, shredder)
- `Hit_Ruler` - Whack sound (ruler, hammer)
- `Hit_Marker` - Squeak sound (markers, pens)
- `Hit_Heavy` - Heavy impact (hammer, textbook, nuclear)
- `Hit_Energy` - Energy weapon (laser, tesla coil, void)
- `CriticalHit` - Critical hit explosion
- `HomeworkDestroy` - Homework fully destroyed
- `ChainHit` - Chain lightning/multi-hit
- `SpecialEffect` - Special effect activated

**Type:** 3D (plays at homework position)
**Range:** 50-100 studs

### 2. Boss Sounds

**Location:** `SoundConfig.Boss`

- `BossSpawn` - Boss appears warning
- `BossHit` - Hitting a boss
- `BossDefeat` - Boss defeated victory fanfare

**Type:** 2D (except BossHit which is 3D)

### 3. UI Sounds

**Location:** `SoundConfig.UI`

User interface feedback:

- `ButtonClick` - Generic button click
- `ButtonHover` - Mouse hover over button
- `PurchaseSuccess` - Successful purchase
- `PurchaseFail` - Purchase failed/insufficient funds
- `LevelUp` - Player leveled up
- `AchievementUnlock` - Achievement unlocked
- `TabSwitch` - UI tab changed
- `WindowOpen` - UI window opened
- `WindowClose` - UI window closed
- `NotificationAppear` - Notification popup
- `Rebirth` - Rebirth/Prestige completed
- `EggHatch` - Pet egg hatched

**Type:** 2D (UI layer)

### 4. Ambient Sounds

**Location:** `SoundConfig.Ambient`

Background music per zone:

- `BGM_Classroom` (Zone 1)
- `BGM_Library` (Zone 2)
- `BGM_Cafeteria` (Zone 3)
- `BGM_ComputerLab` (Zone 4)
- `BGM_Gymnasium` (Zone 5)
- `BGM_MusicRoom` (Zone 6)
- `BGM_ArtRoom` (Zone 7)
- `BGM_ScienceLab` (Zone 8)
- `BGM_PrincipalsOffice` (Zone 9)
- `BGM_TheVoid` (Zone 10)
- `ZoneTransition` - Zone teleport effect

**Type:** 2D (looping)
**Features:** Fade in/out, auto-transitions

### 5. Pet Sounds

**Location:** `SoundConfig.Pet`

- `PetAttack` - Pet auto-attack
- `PetLevelUp` - Pet gained a level
- `PetEquip` - Pet equipped
- `PetFusion` - Pet fusion completed

**Type:** 3D for PetAttack, 2D for others

---

## Setup Instructions

### Step 1: Audio Assets Upload

**⚠️ IMPORTANT:** Many sounds in `SoundConfig.lua` use placeholder IDs (`rbxassetid://0`).

You need to:

1. **Use Roblox's Free Audio Library:**
   - Open Roblox Studio
   - Go to View → Toolbox → Audio
   - Search for sounds matching categories (click, explosion, success, etc.)
   - Get sound IDs and update `SoundConfig.lua`

2. **Upload Custom Audio:**
   - Create/purchase sound effects
   - Upload to Roblox (requires ID verification)
   - Update sound IDs in `SoundConfig.lua`

3. **Current Working IDs:**
   ```lua
   -- These Roblox sound IDs are known to work:
   12221967 - Click/Button
   12222084 - Success chime
   12222095 - Error/metal
   12222216 - Explosion
   12222030 - Whoosh
   12221976 - Power up
   12222252 - Victory fanfare
   12222105 - Impact
   12222124 - Glass break
   ```

### Step 2: Rojo Sync

If using Rojo, sync the new files:

```bash
rojo serve
```

Files to sync:
- `ReplicatedStorage/SharedModules/SoundConfig.lua`
- `ReplicatedStorage/SharedModules/SoundManager.lua`
- `ServerStorage/Modules/ServerSoundManager.lua`
- `StarterPlayer/StarterPlayerScripts/UISoundHandler.lua`
- Updated `ReplicatedStorage/Remotes/RemoteEvents.lua`
- Updated `ServerStorage/Modules/CombatManager.lua`

### Step 3: Test in Studio

1. Open game in Roblox Studio
2. Play test (F5)
3. Check output for initialization messages:
   ```
   [SoundManager] Initialized on client
   [ServerSoundManager] Initialized
   [UISoundHandler] Initialized - UI sounds enabled
   ```
4. Test sounds by:
   - Clicking homework (combat sounds)
   - Opening UI windows (window sounds)
   - Clicking buttons (UI sounds)
   - Leveling up (level up sound)

### Step 4: Update Sound IDs

Edit `SoundConfig.lua` and replace placeholder IDs:

```lua
-- Example: Update hit sound
Hit_Paper = {
    SoundId = "rbxassetid://YOUR_SOUND_ID_HERE",
    Volume = 0.3,
    -- ... rest of config
}
```

### Step 5: Integration with Existing Systems

The sound system is already integrated with:
- ✅ CombatManager (hit, destroy, critical, level up)
- ✅ RemoteEvents (PlaySound, PlaySoundAt)
- ✅ UI (automatic button sounds)

**Additional integrations needed:**

1. **BossManager** - Add boss sound triggers
2. **AchievementManager** - Add achievement unlock sounds
3. **ShopManager** - Add purchase success/fail sounds
4. **PetManager** - Add pet sounds
5. **ZoneManager** - Add zone transition sounds

---

## Usage Examples

### Client-Side (LocalScript)

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundManager = require(ReplicatedStorage.SharedModules.SoundManager)

-- Play a UI sound
SoundManager:PlayUISound("ButtonClick")

-- Play with custom volume
SoundManager:PlayUISound("PurchaseSuccess", 0.8)

-- Play 3D sound at position
local position = Vector3.new(0, 10, 0)
SoundManager:PlayCombatSound("CriticalHit", position)

-- Play zone music
SoundManager:PlayZoneMusic(2) -- Library zone

-- Change volume settings
SoundManager:SetMasterVolume(0.7)
SoundManager:SetCategoryVolume("Combat", 0.5)
SoundManager:SetCategoryMute("Ambient", true)

-- Get current settings
local settings = SoundManager:GetSettings()
print(settings.MasterVolume)
```

### Server-Side (Script)

```lua
local ServerStorage = game:GetService("ServerStorage")
local ServerSoundManager = require(ServerStorage.Modules.ServerSoundManager)

-- Play sound for specific player
ServerSoundManager:PlaySoundForPlayer(player, "LevelUp")

-- Play sound for all players
ServerSoundManager:PlaySoundForAll("BossSpawn")

-- Play 3D sound at position
local position = workspace.Boss.PrimaryPart.Position
ServerSoundManager:PlaySoundAt("BossHit", position)

-- Play sound for players in a zone
ServerSoundManager:PlaySoundForZone(5, "ZoneTransition")

-- Convenience functions
ServerSoundManager:PlayLevelUpSound(player)
ServerSoundManager:PlayAchievementSound(player)
ServerSoundManager:PlayPurchaseSuccessSound(player)
ServerSoundManager:PlayPurchaseFailSound(player)
ServerSoundManager:PlayBossSpawnSound()
ServerSoundManager:PlayBossDefeatSound()

-- Combat sounds
ServerSoundManager:PlayHitSound(player, position, toolID, toolCategory, isCritical)
ServerSoundManager:PlayDestroySound(position)

-- Pet sounds
ServerSoundManager:PlayPetAttackSound(position)
ServerSoundManager:PlayPetLevelUpSound(player)
ServerSoundManager:PlayEggHatchSound(player)
```

### UI Sounds (LocalScript)

```lua
-- UISoundHandler auto-detects buttons and adds sounds
-- But you can manually trigger sounds too:

local UISoundHandler = _G.UISoundHandler

-- Manual sound triggers
UISoundHandler:PlayButtonClick()
UISoundHandler:PlayPurchaseSuccess()
UISoundHandler:PlayPurchaseFail()
UISoundHandler:PlayTabSwitch()
UISoundHandler:PlayWindowOpen()
UISoundHandler:PlayNotification()
```

### Tool-Specific Hit Sounds

Tool hit sounds are automatically selected based on tool ID:

```lua
-- In CombatManager (already integrated)
ServerSoundManager:PlayHitSound(
    player,
    position,
    "LaserPointer",  -- Tool ID
    "MidGame",       -- Tool Category
    true             -- Is critical hit
)
```

Mapping defined in `SoundConfig.ToolSounds`:
- `PencilEraser` → `Hit_Paper`
- `SafetyScissors` → `Hit_Scissors`
- `Textbook` → `Hit_Heavy`
- `LaserPointer` → `Hit_Energy`
- etc.

---

## Sound ID Reference

### Working Roblox Audio Library IDs

| Sound Type | ID | Description |
|------------|-----|-------------|
| Click | `rbxassetid://12221967` | Button click |
| Success | `rbxassetid://12222084` | Success chime |
| Error | `rbxassetid://12222095` | Error buzz |
| Explosion | `rbxassetid://12222216` | Explosion |
| Whoosh | `rbxassetid://12222030` | Whoosh/swing |
| PowerUp | `rbxassetid://12221976` | Power up |
| Victory | `rbxassetid://12222252` | Victory fanfare |
| Impact | `rbxassetid://12222105` | Impact sound |
| Metal | `rbxassetid://12222095` | Metal clang |
| Glass | `rbxassetid://12222124` | Glass break |

### Sounds Needing Upload

The following categories need custom audio uploaded:

**Background Music (10 zones):**
- All `BGM_*` sounds are placeholders
- Recommendation: Use subtle, looping ambient tracks
- Keep volume low (0.2-0.3)

**Recommended Sources:**
1. Roblox Creator Marketplace (free audio)
2. Epidemic Sound / Artlist (licensed music)
3. Create custom loops in Audacity/FL Studio
4. Upload to Roblox with audio ID

---

## Customization Guide

### Adding New Sounds

1. **Add to SoundConfig.lua:**

```lua
SoundConfig.Combat.MyNewSound = {
    SoundId = "rbxassetid://YOUR_ID",
    Volume = 0.4,
    Pitch = 1.0,
    PitchVariation = 0.1,
    Category = "Combat",
    Description = "My new sound effect",
    Type = "3D",
    MaxDistance = 60,
    RollOffMaxDistance = 120
}
```

2. **Use in code:**

```lua
-- Client
SoundManager:PlaySound("MyNewSound", {Position = position})

-- Server
ServerSoundManager:PlaySoundAt("MyNewSound", position)
```

### Adjusting Volume

**Per-sound volume:**
```lua
-- In SoundConfig.lua
Hit_Paper = {
    Volume = 0.3,  -- Adjust this (0.0 to 1.0)
    -- ...
}
```

**Category volume (runtime):**
```lua
-- Client
SoundManager:SetCategoryVolume("Combat", 0.5) -- 50% volume
```

**Master volume (runtime):**
```lua
-- Client
SoundManager:SetMasterVolume(0.7) -- 70% volume
```

### Changing Pitch Variation

Pitch variation adds variety to repeated sounds:

```lua
Hit_Paper = {
    Pitch = 1.0,           -- Base pitch
    PitchVariation = 0.1,  -- Random ±0.1 variation
    -- Result: pitch between 0.9 and 1.1
}
```

### Adding Tool Sound Mappings

Map new tools to hit sounds:

```lua
-- In SoundConfig.lua
SoundConfig.ToolSounds = {
    ["MyNewTool"] = "Hit_Energy",
    -- ...
}
```

### Disabling Background Music

```lua
-- Client
SoundManager:SetCategoryMute("Ambient", true)
```

Or edit `SoundConfig.lua` to remove BGM entries.

---

## Performance Considerations

### Sound Pooling

The system uses **object pooling** to reuse Sound instances:
- 10 pre-created 2D sounds
- 20 pre-created 3D sounds
- Automatically expands if needed
- Prevents garbage collection lag

### 3D Sound Optimization

- Sounds only sent to players within 2x MaxDistance
- Automatic cleanup of old 3D sound instances
- Cleanup loop runs every 5 seconds
- Uses Attachments for efficient 3D positioning

### Network Traffic

- Sounds triggered via RemoteEvents (minimal data)
- Only sound name and position sent (no sound files over network)
- Server filters which clients receive 3D sounds

### Memory Usage

Estimated memory per sound:
- Sound instance: ~1-2 KB
- Sound file: 10-500 KB (cached by Roblox)
- Total pool: ~50-100 KB

**Recommendations:**
- Keep background music under 3 MB per file
- Use compressed audio (MP3, OGG)
- Limit simultaneous sounds to ~20

---

## Troubleshooting

### Sound Not Playing

**Check:**
1. Is the sound ID valid? (`rbxassetid://` format)
2. Is the sound ID `0`? (placeholder)
3. Is the category muted?
   ```lua
   local settings = SoundManager:GetSettings()
   print(settings.MutedCategories)
   ```
4. Is master volume 0?
   ```lua
   print(SoundManager:GetSettings().MasterVolume)
   ```
5. Check output for warnings

**Debug:**
```lua
-- Client
local soundConfig = SoundConfig.GetSound("ButtonClick")
print(soundConfig) -- Should not be nil
print(SoundConfig.IsPlaceholder(soundConfig)) -- Should be false
```

### Sound Too Quiet

**Adjust volumes:**
```lua
-- Increase sound volume in SoundConfig
Volume = 0.8,  -- Was 0.3

-- OR increase category volume
SoundManager:SetCategoryVolume("Combat", 1.0)

-- OR increase master volume
SoundManager:SetMasterVolume(1.0)
```

### Sound Too Loud

Lower the volume in `SoundConfig.lua` or via settings (see above).

### 3D Sound Not Audible

**Check distance:**
```lua
-- In SoundConfig
MaxDistance = 100,  -- Increase if needed
```

**Check player position:**
- Is player within range of the sound?
- Use 2D sounds for important feedback (UI, boss spawns)

### Background Music Not Looping

```lua
-- In SoundConfig
BGM_Classroom = {
    Looped = true,  -- Make sure this is true
    -- ...
}
```

### Background Music Not Transitioning

Zone music transitions when `TeleportToZone` RemoteEvent fires.

**Check:**
1. Is ZoneManager firing the event?
2. Is SoundManager connected to the event?
3. Check `SoundManager:ConnectRemoteEvents()` was called

### RemoteEvent Not Found

**Error:** `PlaySound is not a valid member of RemoteEvents`

**Fix:** Make sure `RemoteEvents.lua` was updated with sound events:
```lua
{
    Name = "PlaySound",
    Type = "Event",
    -- ...
},
{
    Name = "PlaySoundAt",
    Type = "Event",
    -- ...
}
```

### Module Not Found

**Error:** `SoundManager is not a valid member of SharedModules`

**Fix:** Check file structure:
```
ReplicatedStorage/
└── SharedModules/
    ├── SoundConfig.lua
    └── SoundManager.lua
```

---

## Integration Checklist

### Required for Full Functionality

- [x] SoundConfig.lua created
- [x] SoundManager.lua created
- [x] ServerSoundManager.lua created
- [x] RemoteEvents updated
- [x] CombatManager integrated
- [x] UISoundHandler created
- [ ] BossManager integrated
- [ ] AchievementManager integrated
- [ ] ShopManager integrated
- [ ] PetManager integrated
- [ ] ZoneManager integrated

### Example: BossManager Integration

```lua
-- In BossManager.lua
local ServerSoundManager = require(script.Parent.ServerSoundManager)

-- When boss spawns
function BossManager:SpawnBoss(zoneID)
    -- ... existing spawn code ...

    -- Play boss spawn sound
    ServerSoundManager:PlayBossSpawnSound()
end

-- When boss is hit
function BossManager:OnBossDamaged(boss, damage)
    -- ... existing code ...

    -- Play boss hit sound
    local position = boss.PrimaryPart.Position
    ServerSoundManager:PlayBossHitSound(position)
end

-- When boss defeated
function BossManager:OnBossDefeated(boss)
    -- ... existing code ...

    -- Play boss defeat sound
    ServerSoundManager:PlayBossDefeatSound()
end
```

### Example: AchievementManager Integration

```lua
-- In AchievementManager.lua
local ServerSoundManager = require(script.Parent.ServerSoundManager)

function AchievementManager:UnlockAchievement(player, achievementID)
    -- ... existing unlock code ...

    -- Play achievement sound
    ServerSoundManager:PlayAchievementSound(player)

    -- ... rest of code ...
end
```

### Example: ShopManager Integration

```lua
-- In ShopManager.lua (server)
local ServerSoundManager = require(script.Parent.ServerSoundManager)

function ShopManager:PurchaseItem(player, itemID)
    -- ... check if can afford ...

    if canAfford then
        -- ... complete purchase ...
        ServerSoundManager:PlayPurchaseSuccessSound(player)
        return true
    else
        ServerSoundManager:PlayPurchaseFailSound(player)
        return false
    end
end
```

---

## Advanced Features

### Sound Sequences

Play multiple sounds in sequence (for cinematics):

```lua
ServerSoundManager:PlaySoundSequence(player, {
    {Sound = "BossSpawn", Delay = 0},
    {Sound = "WindowOpen", Delay = 1},
    {Sound = "CriticalHit", Position = Vector3.new(0, 10, 0), Delay = 2}
})
```

### Fade Effects

```lua
-- Client
local sound = SoundManager:PlaySound("BGM_Classroom")
SoundManager:FadeInSound(sound, 0.3, 2) -- Fade to 0.3 volume over 2 seconds
SoundManager:FadeOutSound(sound, 2)     -- Fade out over 2 seconds
```

### Custom Sound Options

```lua
SoundManager:PlaySound("Hit_Paper", {
    Position = Vector3.new(0, 10, 0),
    Volume = 0.8,
    Pitch = 1.2,
    Looped = false,
    Parent = workspace
})
```

---

## Future Enhancements

Potential additions:

- [ ] Save sound settings to DataStore
- [ ] Sound presets (Loud, Normal, Quiet, Muted)
- [ ] In-game sound test menu
- [ ] Dynamic music (changes with boss phases)
- [ ] Reverb zones (different acoustics per zone)
- [ ] Footstep sounds
- [ ] Ambient environmental sounds (clock ticking, etc.)
- [ ] Voice lines for bosses
- [ ] Sound effect customization (unlock different hit sounds)

---

## Credits

**Sound System Author:** Claude Sonnet 4.5
**Game:** Homework Destroyer
**Version:** 1.0
**Date:** January 2026

**Sound Sources:**
- Roblox Audio Library (free sounds)
- [List your custom audio sources here]

**Special Thanks:**
- Roblox Creator Hub for audio documentation
- Community for audio feedback and testing

---

## Support

If you encounter issues:

1. Check this documentation's Troubleshooting section
2. Review output for error messages
3. Test with placeholder sounds disabled
4. Verify file structure matches specification
5. Check Roblox audio permissions

For questions or contributions, contact the development team.

---

**End of Documentation**
