# Zone Management System Documentation

## Overview

The Zone Management System for Homework Destroyer provides complete zone unlocking, teleportation, and management functionality. This system includes:

1. **ZonesConfig.lua** - Configuration for all 10 zones
2. **ZoneManager.lua** - Server-side zone management
3. **ZoneTeleportUI.lua** - Client-side zone selection UI

## Files Created

### 1. C:/Users/blackbox/Documents/Github/homework-destroyer/src/ServerStorage/Modules/ZonesConfig.lua

Complete configuration for all 10 zones in Homework Destroyer:

**Zone List:**
1. **The Classroom** - Starter zone (Free)
2. **The Library** - 5,000 DP, Level 10
3. **The Cafeteria** - 50,000 DP, Level 25
4. **Computer Lab** - 250,000 DP, Level 35
5. **Gymnasium** - 1,000,000 DP, Level 45
6. **Music Room** - 5,000,000 DP, Level 55
7. **Art Room** - 25,000,000 DP, Level 65
8. **Science Lab** - 100,000,000 DP, Level 75
9. **Principal's Office** - 500,000,000 DP, Level 90, Rebirth 3
10. **The Void** - 10,000,000,000 DP, Level 100, Rebirth 25, Prestige Rank 3

**Each Zone Includes:**
- Unlock requirements (DP, Level, Rebirth, Prestige)
- Spawn location and safe zone radius
- 4 homework types with HP, rewards, and spawn weights
- Boss configuration with attacks and rewards
- Special features (Speed Reading, Lunch Rush, etc.)
- Recommended level range and difficulty tier
- Zone bonuses (DP, XP, spawn rate multipliers)
- Visual/audio settings

**Helper Functions:**
- `GetZone(zoneID)` - Get zone configuration
- `CanUnlockZone(zoneID, playerData)` - Check unlock eligibility
- `GetUnlockedZones(playerData)` - Get player's unlocked zones
- `GetNextZone(playerData)` - Get next available zone
- `ApplyZoneBonuses(zoneID, baseValue, bonusType)` - Calculate bonuses
- `FormatNumber(num)` - Format large numbers for display

### 2. C:/Users/blackbox/Documents/Github/homework-destroyer/src/ServerStorage/Modules/ZoneManager.lua

Server-side zone management system:

**Core Features:**
- Zone initialization and state tracking
- Zone unlocking with requirement validation
- Player teleportation between zones
- Boss spawning and management
- Homework spawning in zones
- Zone event handling
- Player zone tracking

**Key Functions:**
- `Init()` - Initialize zone manager
- `HandleZoneUnlockRequest(player, zoneID)` - Process unlock requests
- `HandleZoneTeleportRequest(player, zoneID)` - Handle teleportation
- `TeleportPlayerToZone(player, zoneID)` - Teleport player
- `SpawnBoss(zoneID)` - Spawn zone boss
- `OnBossDefeated(zoneID, defeatingPlayer)` - Boss defeat handler
- `SpawnHomework(zoneID, homeworkType)` - Spawn homework
- `GetZoneStats(zoneID)` - Get zone statistics

**Zone State Tracking:**
```lua
{
	ID = zoneID,
	Config = zoneConfig,
	ActiveBoss = nil,
	LastBossSpawn = 0,
	ActivePlayers = {},
	HomeworkSpawned = {},
	EventActive = false,
	EventData = {}
}
```

### 3. C:/Users/blackbox/Documents/Github/homework-destroyer/src/StarterGui/ZoneTeleportUI.lua

Client-side zone selection and teleport UI:

**UI Features:**
- Grid view of all 10 zones
- Zone unlock status indicators
- Detailed zone information panel
- Unlock/teleport buttons
- Requirement display
- Difficulty indicators
- Keyboard shortcut (Press 'Z' to open)

**Visual Elements:**
- Zone number badges
- Lock/unlock icons
- Color-coded status (Green = unlocked, Blue = can unlock, Gray = locked)
- Special purple color for The Void (secret zone)
- Difficulty stars (1-10)
- Animated transitions

**Functions:**
- `Init()` - Initialize UI
- `ToggleUI()` - Open/close UI (Press 'Z')
- `SelectZone(zoneID)` - Select and view zone details
- `UnlockZone(zoneID)` - Purchase zone unlock
- `TeleportToZone(zoneID)` - Teleport to zone
- `DisplayZoneDetails(zoneInfo)` - Show zone information

## Remote Events

### Required Remote Events (Add to RemoteEvents.lua)

The system uses these remote events for client-server communication:

**Client → Server:**
- `RequestZoneUnlock` - Request to unlock a zone
- `RequestZoneTeleport` - Request teleportation to a zone
- `RequestZoneInfo` - Request zone details
- `GetUnlockedZones` - Request list of unlocked zones

**Server → Client:**
- `ReceiveZoneInfo` - Send zone information
- `ReceiveUnlockedZones` - Send unlocked zones list
- `ZoneUnlockResult` - Notify unlock result
- `ZoneTeleportResult` - Notify teleport result
- `BossSpawned` - Notify boss spawn
- `BossDefeated` - Notify boss defeat

**Update Required:**
Replace `src/ReplicatedStorage/Remotes/RemoteEvents.lua` with `RemoteEvents_UPDATED.lua` (provided) or manually add the zone-related remote events.

## Integration Guide

### 1. Server Setup (GameServer.lua)

```lua
local ZoneManager = require(ServerStorage.Modules.ZoneManager)

-- Initialize zone manager on server start
ZoneManager.Init()

-- Example: Manually spawn boss in zone
ZoneManager.SpawnBoss(1) -- Spawn boss in Classroom

-- Example: Get zone stats
local stats = ZoneManager.GetZoneStats(1)
print("Zone 1 has", stats.ActivePlayers, "active players")
```

### 2. Client Setup (UIController.lua or similar)

```lua
-- ZoneTeleportUI auto-initializes when required
-- Press 'Z' key to open zone selection UI

-- Or manually control:
local ZoneTeleportUI = require(StarterGui.ZoneTeleportUI)
ZoneTeleportUI.OpenUI()
```

### 3. Player Data Integration

The zone system expects player data to include:

```lua
{
	DestructionPoints = number,
	Level = number,
	RebirthLevel = number,
	PrestigeLevel = number,
	CurrentZone = number,
	UnlockedZones = {zoneID1, zoneID2, ...}
}
```

This matches the existing `PlayerDataTemplate.lua` structure.

### 4. DataManager Integration

Update your DataManager to:
- Save `CurrentZone` and `UnlockedZones`
- Initialize new players with `UnlockedZones = {1}` (Classroom unlocked)
- Handle zone unlock purchases

## Zone Progression Chart

| Zone | Name | DP Cost | Level | Rebirth | Prestige | Difficulty |
|------|------|---------|-------|---------|----------|------------|
| 1 | The Classroom | Free | 1 | - | - | ★☆☆☆☆☆☆☆☆☆ |
| 2 | The Library | 5K | 10 | - | - | ★★☆☆☆☆☆☆☆☆ |
| 3 | The Cafeteria | 50K | 25 | - | - | ★★★☆☆☆☆☆☆☆ |
| 4 | Computer Lab | 250K | 35 | - | - | ★★★★☆☆☆☆☆☆ |
| 5 | Gymnasium | 1M | 45 | - | - | ★★★★★☆☆☆☆☆ |
| 6 | Music Room | 5M | 55 | - | - | ★★★★★★☆☆☆☆ |
| 7 | Art Room | 25M | 65 | - | - | ★★★★★★★☆☆☆ |
| 8 | Science Lab | 100M | 75 | - | - | ★★★★★★★★☆☆ |
| 9 | Principal's Office | 500M | 90 | 3 | - | ★★★★★★★★★☆ |
| 10 | The Void | 10B | 100 | 25 | 3 | ★★★★★★★★★★ |

## Special Features by Zone

1. **Classroom** - Tutorial NPC helper
2. **Library** - Speed Reading event (2x DP every 30 min)
3. **Cafeteria** - Lunch Rush (2x spawns every 20 min)
4. **Computer Lab** - Virus Attack wave event
5. **Gymnasium** - Dodgeball mini-game
6. **Music Room** - Rhythm challenge (3x damage buff)
7. **Art Room** - Creative Burst (random 1x-5x multipliers)
8. **Science Lab** - Chemical Reaction combos
9. **Principal's Office** - Detention survival waves
10. **The Void** - Advanced mechanics (gravity shifts, counter-attacks)

## Boss System

Each zone has a unique boss:
- **Spawn Interval:** 10 minutes (15 min for Principal, 20 min for Void)
- **Spawn Condition:** At least 1 player in zone
- **Rewards:** Large DP and XP bonuses
- **Attacks:** 1-5 unique attacks per boss

**Boss Scaling:**
- Zone 1: 25K HP
- Zone 5: 1.5M HP
- Zone 9: 500M HP
- Zone 10: 100B HP

## Testing Checklist

- [ ] Zone unlocking works with proper DP deduction
- [ ] Teleportation places player at correct spawn point
- [ ] Zone UI displays all zones correctly
- [ ] Requirements validation prevents unauthorized unlocks
- [ ] Boss spawning works on timer
- [ ] Homework spawning respects spawn weights
- [ ] Zone bonuses apply correctly
- [ ] Player zone tracking persists across sessions
- [ ] Multiple players can be in different zones
- [ ] Secret zone (The Void) has special visual effects

## Customization

### Adding New Zones

1. Add zone configuration to `ZonesConfig.lua`:
```lua
ZonesConfig[11] = {
	ID = 11,
	Name = "New Zone",
	-- ... (copy structure from existing zones)
}
```

2. Update `TOTAL_ZONES` constant in `ZoneTeleportUI.lua`

3. Create physical zone model in Workspace under `Workspace/Zones/Zone11`

### Modifying Zone Requirements

Edit unlock requirements in `ZonesConfig.lua`:
```lua
UnlockRequirements = {
	DP = 1000000,
	Level = 50,
	RebirthLevel = 5, -- Optional
	PrestigeRank = 2,  -- Optional
}
```

### Adjusting Zone Bonuses

Modify zone bonuses in config:
```lua
ZoneBonuses = {
	DPMultiplier = 1.5,      -- 1.5x DP in this zone
	XPMultiplier = 1.3,      -- 1.3x XP in this zone
	SpawnRateMultiplier = 1.2, -- 1.2x spawn rate
}
```

## Performance Considerations

- Boss spawning only occurs when players are in zone
- Homework spawning uses weighted random selection
- Zone state is tracked per zone, not per player
- UI updates on-demand, not every frame
- Remote events are batched where possible

## Troubleshooting

**Issue:** UI not opening when pressing 'Z'
- **Solution:** Check that `ZoneTeleportUI.Init()` was called
- **Solution:** Verify UI is enabled: `screenGui.Enabled = true`

**Issue:** Zones not unlocking
- **Solution:** Check player has sufficient DP and meets level requirements
- **Solution:** Verify RemoteEvents are properly initialized

**Issue:** Teleport not working
- **Solution:** Ensure character has HumanoidRootPart
- **Solution:** Check zone spawn locations are valid Vector3 values

**Issue:** Boss not spawning
- **Solution:** Verify at least 1 player is in the zone
- **Solution:** Check boss spawn interval has elapsed

## Future Enhancements

Potential additions to the zone system:
- Zone-specific quests and challenges
- Dynamic zone events (meteor showers, homework storms)
- PvP zones for competitive play
- Zone leaderboards
- Zone-specific pets and tools
- Seasonal zone themes
- Zone achievements and badges
- Zone chat channels
- Zone weather effects
- Zone day/night cycles

## Credits

Zone Management System for Homework Destroyer
- All 10 zones from game design document
- Complete unlock progression system
- Boss and homework spawning
- Full UI with zone selection and details
- Integration-ready with existing systems

---

**Version:** 1.0
**Date:** 2026-01-06
**Compatibility:** Roblox Studio, Homework Destroyer Game
