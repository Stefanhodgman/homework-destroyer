# Achievement System Integration Guide

## Overview

The Achievement System for Homework Destroyer includes:
- **42 total achievements** across 7 categories
- Automatic tracking and unlocking
- Client-side notification system
- Comprehensive reward distribution
- Special achievement tracking (Speed Demon, Critical King, etc.)

---

## Files Created

### 1. `src/ServerStorage/Modules/AchievementsConfig.lua`
- Defines all 42 achievements
- Categories: Destruction, Boss, Zone, Rebirth, Collection, Special, Secret, Meta
- Reward structures for each achievement
- Utility functions for querying achievements

### 2. `src/ServerStorage/Modules/AchievementManager.lua`
- Server-side achievement tracking and unlocking
- Automatic checking on player actions
- Special achievement session tracking
- Reward distribution
- Integration with DataManager

### 3. `src/StarterGui/AchievementNotification.lua`
- Client-side notification UI system
- Animated achievement popups
- Notification queue management
- Category-specific styling
- Sound effects

---

## Achievement Categories

### Destruction Achievements (10)
Track total homework destroyed across all time.

| Achievement | Requirement | Key Reward |
|-------------|-------------|------------|
| First Steps | 10 homework | 100 DP, "Beginner" title |
| Paper Shredder | 100 homework | 500 DP |
| Assignment Assassin | 1,000 homework | 2,500 DP, +5% permanent damage |
| Homework Hater | 10,000 homework | 25,000 DP, Uncommon egg |
| Destruction Machine | 100,000 homework | 250,000 DP, Rare egg |
| Annihilation Expert | 1,000,000 homework | 2.5M DP, Epic egg, "Expert" title |
| Apocalypse Bringer | 10,000,000 homework | 25M DP, Legendary egg |
| Cosmic Destroyer | 100,000,000 homework | 250M DP, Mythic egg, "Cosmic" title |
| Reality Breaker | 1,000,000,000 homework | 2.5B DP, "Reality" aura |
| THE DESTROYER | 10,000,000,000 homework | 25B DP, "THE DESTROYER" title, rainbow name |

### Boss Achievements (5)
Track bosses defeated.

| Achievement | Requirement | Key Reward |
|-------------|-------------|------------|
| Boss Fighter | 1 boss | 5,000 DP |
| Boss Hunter | 10 bosses | 50,000 DP, +10% permanent boss damage |
| Boss Slayer | 100 bosses | 500,000 DP, "Slayer" title |
| Boss Nightmare | 1,000 bosses | 5M DP, special boss-themed pet |
| Boss Exterminator | Defeat THE PRINCIPAL 100x | 50M DP, "Principal's Nightmare" title |

### Zone Achievements (5)
Track zone progression.

| Achievement | Requirement | Key Reward |
|-------------|-------------|------------|
| Explorer | Unlock 3 zones | 10,000 DP |
| Adventurer | Unlock 5 zones | 100,000 DP, +10% movement speed |
| World Traveler | Unlock all zones 1-9 | 1M DP, "Traveler" title |
| Void Walker | Enter The Void (Zone 10) | 10M DP, void particles aura |
| Master of All | Complete all zone challenges | 100M DP, "Master" title, +25% all-zone damage |

### Rebirth Achievements (5)
Track rebirth progression.

| Achievement | Requirement | Key Reward |
|-------------|-------------|------------|
| Born Again | Complete first rebirth | 10,000 DP, "Reborn" title |
| Cycle Breaker | Reach Rebirth 5 | 100,000 DP, +10% rebirth multiplier |
| Eternal Student | Reach Rebirth 10 | 1M DP, exclusive rebirth pet |
| Time Lord | Reach Rebirth 25 | 10M DP, "Time Lord" title |
| Infinite Loop | Reach Rebirth 50 | 100M DP, "Infinite" aura, permanent 2x XP |

### Collection Achievements (7)
Track tool and pet collection.

| Achievement | Requirement | Key Reward |
|-------------|-------------|------------|
| Tool Collector | Own 5 tools | 5,000 DP |
| Arsenal Builder | Own 10 tools | 50,000 DP, inventory expansion |
| Weapon Master | Own all 18 tools | 5M DP, "Weapon Master" title |
| Pet Lover | Own 5 pets | 5,000 DP, +1 pet slot |
| Pet Hoarder | Own 15 pets | 100,000 DP, +15% pet damage |
| Legendary Tamer | Own 3 Legendary pets | 1M DP |
| Mythic Master | Own a Mythic pet | 10M DP, "Mythic Master" title |

### Special Achievements (5)
Skill-based challenges.

| Achievement | Requirement | Key Reward |
|-------------|-------------|------------|
| Speed Demon | Destroy 100 homework in 1 minute | 25,000 DP, +5% permanent speed |
| Critical King | Land 50 critical hits in a row | 50,000 DP, +5% permanent crit |
| Untouchable | Defeat Void boss without damage | 1M DP, "Untouchable" title |
| Millionaire | Accumulate 1,000,000 DP at once | 100,000 bonus DP |
| Billionaire | Accumulate 1,000,000,000 DP at once | 100M bonus DP, badge |

### Secret Achievements (5)
Hidden achievements revealed on unlock.

| Achievement | Requirement | Key Reward |
|-------------|-------------|------------|
| Night Owl | Play at 3 AM server time | 10,000 DP, "Night Owl" title |
| Marathon Runner | Play for 10 hours total | 50,000 DP |
| Old Timer | Return after 30+ days away | 100,000 DP, returnee gift box |
| Easter Egg Hunter | Find hidden classroom message | 25,000 DP, secret pet |
| The One | Deal exactly 1,000,000 damage | 500,000 DP, "The One" title |

### Meta Achievement (1)
The ultimate achievement.

| Achievement | Requirement | Key Reward |
|-------------|-------------|------------|
| True Completionist | Earn all other 42 achievements | 1B DP, "Completionist" title, rainbow aura, unique sound |

---

## Integration with GameServer

### In GameServer.lua

Add achievement initialization:

```lua
-- At the top with other module requires
local AchievementManager = require(ServerStorage.Modules.AchievementManager)

-- In GameServer:Initialize()
function GameServer:Initialize()
	-- ... existing code ...

	-- Initialize Achievement System
	AchievementManager:Initialize()

	-- ... rest of initialization ...
end
```

### Tracking Homework Destruction

```lua
function GameServer:OnHomeworkDestroyed(player, homeworkType, damage)
	-- ... existing DP/XP code ...

	-- Track for achievements
	AchievementManager:OnHomeworkDestroyed(player, os.time())
	AchievementManager:CheckDestructionAchievements(player)
end
```

### Tracking Boss Defeats

```lua
function GameServer:OnBossDefeated(player, bossType)
	-- ... existing reward code ...

	-- Track for achievements
	if bossType.Name == "THE PRINCIPAL" then
		AchievementManager:OnPrincipalDefeated(player)
	end

	AchievementManager:CheckBossAchievements(player)
end
```

### Tracking Critical Hits

```lua
function CombatManager:ProcessClick(player, target, damage, isCrit)
	-- ... existing damage code ...

	-- Track critical hits
	AchievementManager:OnCriticalHit(player, isCrit)

	-- Track damage for "The One" achievement
	AchievementManager:OnDamageDealt(player, damage)
end
```

### Tracking Zone Unlocks

```lua
function GameServer:UnlockZone(player, zoneId)
	-- ... existing unlock code ...

	-- Check zone achievements
	AchievementManager:CheckZoneAchievements(player)
end
```

### Tracking Rebirth

```lua
function PrestigeManager:PerformRebirth(player)
	-- ... existing rebirth code ...

	-- Check rebirth achievements
	AchievementManager:CheckRebirthAchievements(player)
end
```

### Tracking Collection

```lua
function ToolManager:PurchaseTool(player, toolID)
	-- ... existing purchase code ...

	-- Check collection achievements
	AchievementManager:CheckCollectionAchievements(player)
end

function PetManager:HatchEgg(player, eggType)
	-- ... existing hatching code ...

	-- Check collection achievements
	AchievementManager:CheckCollectionAchievements(player)
end
```

### Tracking Special Achievements

```lua
-- Boss fight tracking
function BossManager:OnBossFightStart(player, boss)
	local isVoidZone = (boss.ZoneID == 10)
	AchievementManager:OnBossFightStart(player, boss.Name, isVoidZone)
end

function BossManager:OnPlayerDamaged(player, damageSource)
	if damageSource.Type == "Boss" then
		AchievementManager:OnPlayerDamagedByBoss(player)
	end
end

function BossManager:OnBossFightEnd(player, bossDefeated)
	AchievementManager:OnBossFightEnd(player, bossDefeated)
end

-- Easter egg trigger (place in world as ClickDetector)
local easterEggPart = workspace.Classroom.HiddenMessage
easterEggPart.ClickDetector.MouseClick:Connect(function(player)
	AchievementManager:TriggerEasterEgg(player)
end)
```

---

## Client-Side Setup

The client notification system is automatically initialized when the script loads.

### Manual Testing

You can test the notification system:

```lua
-- In the developer console (client-side):
local AchievementNotification = require(game.Players.LocalPlayer.PlayerGui.AchievementNotification)
AchievementNotification:TestNotification()
```

---

## API Reference

### AchievementManager (Server)

#### Core Functions

```lua
-- Initialize the system
AchievementManager:Initialize()

-- Check all achievements for a player
AchievementManager:CheckAllAchievements(player) -> newUnlockCount

-- Check a specific achievement
AchievementManager:CheckAchievement(player, achievementID) -> unlocked (boolean)

-- Manually unlock an achievement
AchievementManager:UnlockAchievement(player, achievementID) -> success (boolean)

-- Check if player has achievement
AchievementManager:HasAchievement(player, achievementID) -> hasIt (boolean)
```

#### Category-Specific Checking

```lua
AchievementManager:CheckDestructionAchievements(player)
AchievementManager:CheckBossAchievements(player)
AchievementManager:CheckZoneAchievements(player)
AchievementManager:CheckRebirthAchievements(player)
AchievementManager:CheckCollectionAchievements(player)
AchievementManager:CheckSpecialAchievements(player)
```

#### Special Achievement Tracking

```lua
-- Track homework destruction for Speed Demon
AchievementManager:OnHomeworkDestroyed(player, timestamp)

-- Track critical hits for Critical King
AchievementManager:OnCriticalHit(player, wasCrit)

-- Track damage for The One
AchievementManager:OnDamageDealt(player, damage)

-- Track boss fights for Untouchable
AchievementManager:OnBossFightStart(player, bossName, isVoidZone)
AchievementManager:OnPlayerDamagedByBoss(player)
AchievementManager:OnBossFightEnd(player, bossDefeated)

-- Track Principal defeats
AchievementManager:OnPrincipalDefeated(player)

-- Trigger easter egg
AchievementManager:TriggerEasterEgg(player)
```

#### Query Functions

```lua
-- Get unlocked achievements
AchievementManager:GetUnlockedAchievements(player) -> array of {ID, Timestamp}

-- Get achievement progress (0.0 to 1.0)
AchievementManager:GetAchievementProgress(player, achievementID) -> progress

-- Get unlock count
AchievementManager:GetUnlockedCount(player) -> count

-- Get player stats
AchievementManager:GetPlayerStats(player) -> {Total, Unlocked, Locked, CompletionRate}

-- Get all achievements with status
AchievementManager:GetAllAchievementsWithStatus(player) -> array of achievement data
```

### AchievementsConfig

```lua
-- Get all achievements
AchievementsConfig.GetAllAchievements() -> array

-- Get achievement by ID
AchievementsConfig.GetAchievementByID(achievementID) -> achievement or nil

-- Get achievements by category
AchievementsConfig.GetAchievementsByCategory(category) -> array

-- Get total count
AchievementsConfig.GetTotalAchievementCount() -> number

-- Get display info (respects hidden status)
AchievementsConfig.GetDisplayInfo(achievementID, isUnlocked) -> displayData
```

### AchievementNotification (Client)

```lua
-- Queue a notification (usually called by server)
AchievementNotification:QueueNotification(achievementData)

-- Test notification (for debugging)
AchievementNotification:TestNotification()

-- Clear queue
AchievementNotification:ClearQueue()

-- Get queue size
AchievementNotification:GetQueueSize() -> number
```

---

## Reward Types

### DP Rewards
Automatically added to player's DestructionPoints.

### Tool Tokens
Added to player's ToolUpgradeTokens for upgrading tools.

### Eggs
Added to player's egg inventory (specific types).

### Titles
Added to player's UnlockedTitles array (UI can display).

### Multipliers
Permanent stat boosts stored in `PermanentMultipliers`:
- Damage
- DP
- XP
- BossDamage
- MovementSpeed
- Speed
- CritChance
- PetDamage
- RebirthMultiplier
- AllZoneDamage

### Pet Slots
Increases `Pets.MaxSlots` (capped at 6).

### Unlocks
Special features/items stored in `SpecialUnlocks` array.

### Auras
Visual effects stored in `UnlockedAuras` array.

### Badges
Roblox badge integration (requires BadgeService setup).

---

## Data Structure

Achievements are stored in PlayerData:

```lua
PlayerData.Achievements = {
	FirstSteps = 1672531200, -- timestamp when unlocked
	PaperShredder = 1672617600,
	-- ... other unlocked achievements

	-- Locked achievements are set to false
	TheDestroyer = false,
}

-- Progress tracking for special achievements
PlayerData.AchievementProgress = {
	SpeedDemonComplete = false,
	CriticalKingComplete = false,
	UntouchableComplete = false,
	TheOneComplete = false,
	EasterEggFound = false,
}

-- Special counters
PlayerData.LifetimeStats.PrincipalDefeats = 0
PlayerData.ZoneChallengesCompleted = 0
```

---

## Performance Considerations

1. **Batch Checking**: Use category-specific checking rather than `CheckAllAchievements()` when possible
2. **Event-Driven**: Achievements are checked on specific events, not every frame
3. **Client Queueing**: Multiple simultaneous unlocks are queued and displayed sequentially
4. **Session Tracking**: Special achievements use session-specific trackers that reset on disconnect

---

## Testing Checklist

- [ ] Achievement unlocks correctly when requirement met
- [ ] Rewards are properly awarded
- [ ] Client notification displays properly
- [ ] Multiple unlocks queue correctly
- [ ] Hidden achievements show as "???" until unlocked
- [ ] Progress tracking works for count-based achievements
- [ ] Special achievements track correctly (Speed Demon, Critical King, etc.)
- [ ] True Completionist unlocks only when all others complete
- [ ] Permanent multipliers are applied correctly
- [ ] Data persists across sessions

---

## Future Enhancements

Potential additions to the system:

1. **Achievement Points**: Assign point values to achievements for prestige
2. **Showcase System**: Let players display favorite achievements on profile
3. **Leaderboards**: Track who unlocks achievements first
4. **Achievement Quests**: Multi-step achievement chains
5. **Seasonal Achievements**: Time-limited achievements for events
6. **Difficulty Tiers**: Bronze/Silver/Gold versions of achievements
7. **Social Integration**: Share achievement unlocks with friends
8. **Roblox Badge Integration**: Award official Roblox badges

---

## Support

For issues or questions about the Achievement System:
1. Check console for warning/error messages
2. Verify RemoteEvents are properly initialized
3. Ensure DataManager is saving/loading achievement data
4. Test with `AchievementManager:CheckAllAchievements(player)` manually

---

**Version**: 1.0
**Last Updated**: 2026-01-06
**Total Achievements**: 43 (42 + True Completionist)
