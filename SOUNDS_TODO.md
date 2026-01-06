# Sound System - Audio Upload TODO

This file tracks which sound effects need to be uploaded or replaced with actual Roblox audio IDs.

---

## Current Status

✅ **Working Sound IDs** (from Roblox free audio library):
- 12221967 - Click/Button
- 12222084 - Success chime
- 12222095 - Error/metal clang
- 12222216 - Explosion
- 12222030 - Whoosh
- 12221976 - Power up
- 12222252 - Victory fanfare
- 12222105 - Impact
- 12222124 - Glass break

⚠️ **Placeholder IDs** (need replacement): All marked as `rbxassetid://0`

---

## Sounds Needing Upload

### Priority 1: Background Music (Zone Ambience)

**All placeholder - need looping ambient tracks:**

1. `BGM_Classroom` (Zone 1) - Light classroom ambience
2. `BGM_Library` (Zone 2) - Quiet library ambience
3. `BGM_Cafeteria` (Zone 3) - Busy cafeteria sounds
4. `BGM_ComputerLab` (Zone 4) - Computer humming/typing
5. `BGM_Gymnasium` (Zone 5) - Gym/sports ambience
6. `BGM_MusicRoom` (Zone 6) - Musical ambience
7. `BGM_ArtRoom` (Zone 7) - Calm art room ambience
8. `BGM_ScienceLab` (Zone 8) - Lab/bubbling sounds
9. `BGM_PrincipalsOffice` (Zone 9) - Tense/dramatic music
10. `BGM_TheVoid` (Zone 10) - Ominous void ambience

**Recommendations:**
- Keep tracks under 3MB each
- Loop seamlessly (no gaps)
- Keep volume subtle (config already set to 0.2-0.3)
- Duration: 1-2 minutes each
- Format: MP3 or OGG

**Sources:**
- Roblox Creator Marketplace (free audio)
- Epidemic Sound (licensed)
- Create in Audacity/FL Studio
- YouTube Audio Library

---

## Sounds Using Working IDs

These sounds are already configured with working Roblox audio IDs:

### Combat Sounds
- ✅ `Hit_Paper` - 12222105 (Impact)
- ✅ `Hit_Scissors` - 12222124 (Glass/cutting)
- ✅ `Hit_Ruler` - 12222030 (Whoosh)
- ✅ `Hit_Marker` - 12221967 (Click)
- ✅ `Hit_Heavy` - 12222095 (Metal clang)
- ✅ `Hit_Energy` - 12221976 (Power up)
- ✅ `CriticalHit` - 12222216 (Explosion)
- ✅ `HomeworkDestroy` - 12222084 (Success)
- ✅ `ChainHit` - 12221967 (Sparkle)
- ✅ `SpecialEffect` - 12221976 (Power up)

### Boss Sounds
- ✅ `BossSpawn` - 12222252 (Victory/dramatic)
- ✅ `BossHit` - 12222095 (Metal clang)
- ✅ `BossDefeat` - 12222252 (Victory fanfare)

### UI Sounds
- ✅ `ButtonClick` - 12221967 (Click)
- ✅ `ButtonHover` - 12221967 (Click)
- ✅ `PurchaseSuccess` - 12222084 (Success)
- ✅ `PurchaseFail` - 12222095 (Error)
- ✅ `LevelUp` - 12221976 (Power up)
- ✅ `AchievementUnlock` - 12222252 (Victory)
- ✅ `TabSwitch` - 12221967 (Click)
- ✅ `WindowOpen` - 12222030 (Whoosh)
- ✅ `WindowClose` - 12222030 (Whoosh)
- ✅ `NotificationAppear` - 12221967 (Click)
- ✅ `Rebirth` - 12222252 (Victory)
- ✅ `EggHatch` - 12222084 (Success)

### Ambient Sounds
- ✅ `ZoneTransition` - 12222030 (Whoosh)

### Pet Sounds
- ✅ `PetAttack` - 12221967 (Click)
- ✅ `PetLevelUp` - 12221976 (Power up)
- ✅ `PetEquip` - 12222084 (Success)
- ✅ `PetFusion` - 12222252 (Victory)

---

## How to Update Sound IDs

### Step 1: Find/Upload Sound

**Option A: Use Roblox Free Audio**
1. Open Roblox Studio
2. View → Toolbox → Audio
3. Search for sound type (e.g., "classroom ambience")
4. Listen and find suitable sound
5. Insert into workspace to get ID
6. Copy the ID number

**Option B: Upload Custom Audio**
1. Create or obtain audio file (MP3, OGG, WAV)
2. Go to Roblox Creator Dashboard
3. Navigate to Development Items → Audio
4. Click "Upload Audio"
5. Upload file and wait for moderation
6. Copy the asset ID

### Step 2: Update SoundConfig.lua

Open `src/ReplicatedStorage/SharedModules/SoundConfig.lua`

Find the sound definition:

```lua
BGM_Classroom = {
    SoundId = "rbxassetid://0",  -- PLACEHOLDER
    -- ...
}
```

Replace with your sound ID:

```lua
BGM_Classroom = {
    SoundId = "rbxassetid://1234567890",  -- Your sound ID
    -- ...
}
```

### Step 3: Test in Studio

1. Start test server (F7)
2. Teleport to the zone or trigger the sound
3. Verify sound plays correctly
4. Adjust volume if needed

---

## Sound Requirements

### General Guidelines

**File Format:**
- MP3 (recommended for music)
- OGG (recommended for SFX)
- WAV (high quality but large)

**File Size:**
- SFX: < 500 KB
- Music: < 3 MB
- Roblox limit: 20 MB per audio

**Quality:**
- Bit rate: 128-192 kbps (sufficient)
- Sample rate: 44.1 kHz

**Length:**
- SFX: 0.1 - 2 seconds
- Music: 1 - 3 minutes (looping)

### Zone Music Specifics

Each zone should have unique ambience matching its theme:

1. **Classroom** - Pencils scratching, papers shuffling, light chatter
2. **Library** - Pages turning, whispers, quiet ambience
3. **Cafeteria** - Plates clattering, conversations, bustling
4. **Computer Lab** - Keyboards typing, fans humming, mice clicking
5. **Gymnasium** - Bouncing balls, squeaking shoes, echoes
6. **Music Room** - Instruments tuning, scales, musical notes
7. **Art Room** - Brushes on canvas, calm creativity
8. **Science Lab** - Beakers bubbling, equipment sounds
9. **Principal's Office** - Clock ticking, tense/dramatic music
10. **The Void** - Ominous drones, ethereal sounds, otherworldly

---

## Testing Checklist

After updating sound IDs:

- [ ] All combat sounds play correctly
- [ ] Hit sounds match tool types
- [ ] Critical hits are distinct and impactful
- [ ] UI sounds provide good feedback
- [ ] Purchase success/fail sounds are clear
- [ ] Level up sound is celebratory
- [ ] Achievement sound is rewarding
- [ ] Boss spawn is dramatic
- [ ] Boss defeat is victorious
- [ ] Zone music loops seamlessly
- [ ] Zone transitions are smooth (fade in/out)
- [ ] Pet sounds are subtle but audible
- [ ] No sounds are too loud or quiet
- [ ] Volume controls work for all categories
- [ ] Mute toggles work correctly

---

## Sound Credits Template

Once you've added sounds, document their sources:

```
Sound Credits for Homework Destroyer
=====================================

Background Music:
- Classroom: [Source] - [License]
- Library: [Source] - [License]
- etc.

Sound Effects:
- Combat sounds: Roblox Free Audio Library
- UI sounds: Roblox Free Audio Library
- Custom sounds: [Your sources]

Licensed Music:
- [If using Epidemic Sound, Artlist, etc.]

Created By:
- [Your name/studio if you created custom audio]
```

---

## Quick Reference: Roblox Audio Upload

**Upload Limits:**
- Unverified: Cannot upload audio
- ID Verified: Can upload audio (20 MB max per file)
- Premium: Same as ID verified

**Approval Time:**
- Usually: Minutes to hours
- Sometimes: Up to 24-48 hours
- Rejected: Check email for moderation notice

**Audio Guidelines:**
- No copyrighted music (unless you own rights)
- No inappropriate content
- No excessive volume/distortion
- Follow Roblox Community Standards

---

## Status Tracking

Update this section as you complete sound uploads:

### Completed
- [x] Core combat sounds (using Roblox free audio)
- [x] Core UI sounds (using Roblox free audio)
- [x] Boss sounds (using Roblox free audio)
- [x] Pet sounds (using Roblox free audio)

### In Progress
- [ ] Zone 1-10 background music

### Not Started
- [ ] (All zone music)

---

## Notes

- The system works perfectly with placeholder sounds disabled
- You can test without background music by setting volume to 0
- Sound pooling is already optimized
- All integration code is complete
- Only asset IDs need updating

**Current Playable:** Yes, with combat/UI sounds working
**Background Music Required:** Optional (game is fully playable without it)

---

**Last Updated:** 2026-01-06
