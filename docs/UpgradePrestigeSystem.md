# Upgrade and Prestige System Documentation

## Overview
This document explains the upgrade and prestige management systems for Homework Destroyer, including usage examples and integration guidelines.

## System Modules

### 1. StatsCalculator.lua
**Location:** `src/ServerStorage/Modules/StatsCalculator.lua`

Handles all player stat calculations including damage, DPS, multipliers, and costs.

#### Key Functions:

```lua
-- Calculate upgrade costs
local cost = StatsCalculator.CalculateUpgradeCost(upgradeName, currentLevel)

-- Calculate final damage with all multipliers
local damage = StatsCalculator.CalculateFinalDamage(playerData, toolData, petData, isCritical, targetType)

-- Get critical hit chance and multiplier
local critChance = StatsCalculator.GetCriticalChance(playerData, toolData)
local critMultiplier = StatsCalculator.GetCriticalMultiplier(playerData)

-- Calculate DP earned with all bonuses
local dpEarned = StatsCalculator.CalculateDPEarned(baseDP, playerData)

-- Calculate auto-click rate and damage
local autoRate = StatsCalculator.CalculateAutoClickRate(playerData)
local autoDamage = StatsCalculator.CalculateAutoClickDamage(playerData, toolData, petData)

-- Get complete player stats summary
local stats = StatsCalculator.GetPlayerStats(playerData, toolData, petData)
```

#### Damage Formula:
```
Final Damage = Base Tool Damage
               x (1 + Damage Upgrades)
               x Tool Rarity Multiplier
               x (1 + Pet Bonus)
               x Rebirth Multiplier
               x Prestige Multiplier
               x Critical Multiplier (if crit)
```

#### DP Earning Formula:
```
DP Earned = Base Homework DP
            x (1 + DP Upgrades)
            x Rebirth DP Multiplier
            x Prestige DP Multiplier
            x Pet DP Bonus
```

---

### 2. UpgradeManager.lua
**Location:** `src/ServerStorage/Modules/UpgradeManager.lua`

Manages upgrade purchases, validation, and effects.

#### Available Upgrades:

**Damage Upgrades:**
- `SharperTools` - +2 base damage per level (50 levels)
- `StrongerArms` - +5% click damage per level (50 levels)
- `CriticalChance` - +1% crit chance per level, max 30% (25 levels)
- `CriticalDamage` - +10% crit multiplier per level (25 levels)
- `PaperWeakness` - +10% damage to paper types per level (20 levels)

**Speed Upgrades:**
- `QuickHands` - -2% click cooldown per level (30 levels)
- `AutoClickSpeed` - +0.1 auto-clicks/sec per level (20 levels, requires Rebirth 1)
- `MovementSpeed` - +3% walk speed per level (15 levels)

**Economy Upgrades:**
- `DPBonus` - +3% DP earned per level (50 levels)
- `LuckyDrops` - +2% rare drop chance per level (20 levels)
- `EggLuck` - +3% pet rarity luck per level (15 levels)

#### Usage Examples:

```lua
local UpgradeManager = require(ServerStorage.Modules.UpgradeManager)
local upgradeManager = UpgradeManager.new()

-- Get upgrade cost
local cost = upgradeManager:GetUpgradeCost("SharperTools", currentLevel)

-- Check if player can purchase upgrade
local canPurchase, message, cost = upgradeManager:CheckUpgradeRequirements(playerData, "StrongerArms")

-- Purchase single upgrade
local success, message, data = upgradeManager:PurchaseUpgrade(playerData, "CriticalChance")

-- Purchase maximum levels (buy max)
local success, message, data = upgradeManager:PurchaseMaxUpgrades(playerData, "DPBonus", 10)

-- Get all available upgrades
local upgrades = upgradeManager:GetAllUpgrades(playerData)

-- Reset upgrades (for rebirth)
upgradeManager:ResetUpgrades(playerData)

-- Validate upgrade integrity (anti-cheat)
local isValid, message = upgradeManager:ValidateUpgradeIntegrity(playerData)
```

#### Anti-Cheat Features:
- Validates all purchases server-side
- Checks DP before and after purchase
- Validates upgrade level bounds
- Checks rebirth requirements
- Logs all purchases for analytics

---

### 3. PrestigeManager.lua
**Location:** `src/ServerStorage/Modules/PrestigeManager.lua`

Handles prestige system including eligibility, bonuses, and progress reset.

#### Prestige Requirements:
- Reach **Rebirth 20**
- Earn **1 Billion** lifetime DP
- Own at least **1 Legendary pet**

#### Prestige Ranks:

| Rank | Name | Requirement | Bonuses |
|------|------|-------------|---------|
| 1 | Homework Hater | Prestige once | +100% all damage |
| 2 | Assignment Annihilator | 5 rebirths post-prestige | +200% DP |
| 3 | Test Terminator | 15 rebirths post-prestige | +50% pet damage, Golden Eraser pet |
| 4 | Scholar Slayer | 30 rebirths post-prestige | +50% pet damage |
| 5 | Education Eliminator | 50 rebirths post-prestige | +50% all stats, Void Zone unlock |
| 6 | HOMEWORK DESTROYER | 100 rebirths post-prestige | x10 all stats, Rainbow name |

#### Usage Examples:

```lua
local PrestigeManager = require(ServerStorage.Modules.PrestigeManager)
local prestigeManager = PrestigeManager.new()

-- Check if prestige is unlocked
local isUnlocked = prestigeManager:IsPrestigeUnlocked(playerData)

-- Check prestige eligibility
local eligible, message = prestigeManager:CheckPrestigeEligibility(playerData)

-- Perform prestige
local success, message, data = prestigeManager:PerformPrestige(playerData)

-- Get prestige bonuses
local bonuses = prestigeManager:GetPrestigeBonuses(playerData)
-- Returns: { damageMultiplier, dpMultiplier, petDamageMultiplier, allStatsMultiplier }

-- Get prestige info
local info = prestigeManager:GetPrestigeInfo(playerData)

-- Track rebirth after prestige (for rank progression)
local rankUp, newRank, rewards = prestigeManager:TrackRebirthAfterPrestige(playerData)

-- Update lifetime stats
prestigeManager:UpdateLifetimeStats(playerData, "TotalDPEarned", dpAmount)
prestigeManager:UpdateLifetimeStats(playerData, "TotalHomeworkDestroyed", 1)
prestigeManager:UpdateLifetimeStats(playerData, "HighestDamageHit", damageDealt)

-- Validate prestige integrity (anti-cheat)
local isValid, message = prestigeManager:ValidatePrestigeIntegrity(playerData)
```

#### What Resets on Prestige:
- Player level (back to 1)
- XP (back to 0)
- Destruction Points (DP)
- Rebirth level (back to 0)
- Zone progress (back to Zone 1)
- All upgrades

#### What You Keep:
- All tools/weapons
- All pets
- Prestige rank and bonuses
- Lifetime stats
- Achievements/badges
- Gamepasses
- Titles and cosmetics

---

## Integration Guide

### Server-Side Setup

```lua
-- ServerScriptService/GameManager.lua
local ServerStorage = game:GetService("ServerStorage")

local StatsCalculator = require(ServerStorage.Modules.StatsCalculator)
local UpgradeManager = require(ServerStorage.Modules.UpgradeManager)
local PrestigeManager = require(ServerStorage.Modules.PrestigeManager)

-- Initialize managers
local upgradeManager = UpgradeManager.new()
local prestigeManager = PrestigeManager.new()

-- Initialize lifetime stats for new players
function InitializeNewPlayer(player, playerData)
    prestigeManager:InitializeLifetimeStats(playerData)
end

-- Handle homework destruction
function OnHomeworkDestroyed(player, playerData, toolData, petData, homeworkData)
    -- Calculate damage
    local isCritical = math.random() < StatsCalculator.GetCriticalChance(playerData, toolData)
    local damage = StatsCalculator.CalculateFinalDamage(playerData, toolData, petData, isCritical, homeworkData.Type)

    -- Calculate DP earned
    local dpEarned = StatsCalculator.CalculateDPEarned(homeworkData.BaseDP, playerData)
    playerData.DP = playerData.DP + dpEarned

    -- Update lifetime stats
    prestigeManager:UpdateLifetimeStats(playerData, "TotalDPEarned", dpEarned)
    prestigeManager:UpdateLifetimeStats(playerData, "TotalHomeworkDestroyed", 1)
    prestigeManager:UpdateLifetimeStats(playerData, "TotalDamageDealt", damage)
    prestigeManager:UpdateLifetimeStats(playerData, "HighestDamageHit", damage)

    return damage, dpEarned, isCritical
end

-- Handle upgrade purchase
function OnUpgradePurchaseRequest(player, playerData, upgradeName)
    local success, message, data = upgradeManager:PurchaseUpgrade(playerData, upgradeName)

    if success then
        -- Save player data
        SavePlayerData(player, playerData)

        -- Update client
        ReplicateToClient(player, "UpgradePurchased", data)
    end

    return success, message
end

-- Handle rebirth
function OnRebirthRequest(player, playerData)
    -- Validate rebirth requirements
    -- ... (implement rebirth validation)

    -- Reset upgrades
    upgradeManager:ResetUpgrades(playerData)

    -- Track rebirth for prestige progression
    if (playerData.PrestigeRank or 0) > 0 then
        local rankUp, newRank, rewards = prestigeManager:TrackRebirthAfterPrestige(playerData)

        if rankUp then
            -- Grant rank-up rewards
            print("Player advanced to Prestige Rank " .. newRank)
        end
    end

    -- Update lifetime stats
    prestigeManager:UpdateLifetimeStats(playerData, "TotalRebirths", 1)
end

-- Handle prestige
function OnPrestigeRequest(player, playerData)
    local success, message, data = prestigeManager:PerformPrestige(playerData)

    if success then
        -- Save player data
        SavePlayerData(player, playerData)

        -- Update client with new bonuses and rewards
        ReplicateToClient(player, "PrestigeComplete", data)
    end

    return success, message, data
end
```

### Client-Side Display

```lua
-- StarterPlayer/StarterPlayerScripts/StatsDisplay.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Request stats from server
function UpdateStatsDisplay()
    local statsData = RequestStatsFromServer()

    -- Update UI
    DamageLabel.Text = "Damage: " .. FormatNumber(statsData.FinalDamage)
    CritChanceLabel.Text = "Crit Chance: " .. math.floor(statsData.CritChance * 100) .. "%"
    DPSLabel.Text = "Papers/Second: " .. FormatNumber(statsData.PapersPerSecond)

    -- Update multipliers
    RebirthMultLabel.Text = "x" .. statsData.RebirthDamageMultiplier
    PrestigeMultLabel.Text = "x" .. statsData.PrestigeDamageMultiplier
end
```

---

## Player Data Structure

```lua
PlayerData = {
    UserId = 123456789,
    Level = 1,
    XP = 0,
    DP = 0,
    Rebirth = 0,
    HighestRebirth = 0,
    PrestigeRank = 0,

    -- Upgrades (upgrade name -> level)
    Upgrades = {
        SharperTools = 10,
        StrongerArms = 5,
        CriticalChance = 3,
        -- ...
    },

    -- Prestige tracking
    PrestigeStats = {
        TotalPrestiges = 1,
        RebirthsSinceFirstPrestige = 5,
        LastPrestigeTimestamp = 1234567890,
    },

    -- Lifetime stats (never reset)
    LifetimeStats = {
        TotalDPEarned = 1500000000,
        TotalHomeworkDestroyed = 50000,
        TotalBossesDefeated = 500,
        TotalDamageDealt = 10000000000,
        TotalClickCount = 100000,
        TotalPlayTime = 36000,
        HighestDamageHit = 500000,
        TotalRebirths = 20,
        TotalPrestiges = 1,
    },

    -- Other data
    Tools = {},
    Pets = {},
    Titles = {},
    -- ...
}
```

---

## Anti-Cheat Validation

Run validation checks periodically and on important events:

```lua
-- Validate on player join
function OnPlayerJoin(player, playerData)
    upgradeManager:ValidateUpgradeIntegrity(playerData)
    prestigeManager:ValidatePrestigeIntegrity(playerData)
end

-- Validate before purchases
function OnPurchaseRequest(player, playerData, item)
    local valid = upgradeManager:ValidateUpgradeIntegrity(playerData)
    if not valid then
        -- Flag for review
        warn("Player " .. player.UserId .. " has invalid upgrade data")
        return false
    end
end

-- Validate periodically (every 5 minutes)
while true do
    wait(300)
    for _, player in ipairs(game.Players:GetPlayers()) do
        local playerData = GetPlayerData(player)
        upgradeManager:ValidateUpgradeIntegrity(playerData)
        prestigeManager:ValidatePrestigeIntegrity(playerData)
    end
end
```

---

## Performance Considerations

1. **Caching**: Both managers include caching systems to reduce calculations
2. **Batch Updates**: Use `PurchaseMaxUpgrades` for bulk purchases
3. **Stat Updates**: Only recalculate stats when they change, not every frame
4. **Client Replication**: Only send stat changes to client, not full recalculations

---

## Testing Checklist

### Upgrades:
- [ ] Purchase single upgrade with exact DP
- [ ] Purchase fails with insufficient DP
- [ ] Max level upgrades can't be purchased
- [ ] Rebirth-locked upgrades can't be purchased without requirement
- [ ] Buy Max purchases correct amount
- [ ] Upgrade effects apply correctly to damage calculations
- [ ] Upgrade reset on rebirth works correctly

### Prestige:
- [ ] Prestige locked until Rebirth 20
- [ ] Can't prestige without 1B lifetime DP
- [ ] Can't prestige without Legendary pet
- [ ] Progress resets correctly on prestige
- [ ] Tools and pets are kept
- [ ] Prestige bonuses apply correctly
- [ ] Rank progression tracks rebirths correctly
- [ ] Rank rewards granted properly
- [ ] Lifetime stats never reset

### Stats:
- [ ] Damage formula calculates correctly
- [ ] Critical hits apply proper multiplier
- [ ] Rebirth multipliers apply
- [ ] Prestige multipliers apply
- [ ] DP bonuses calculate correctly
- [ ] Auto-click rate and damage correct
- [ ] Papers per second accurate

---

## Support

For questions or issues with the upgrade/prestige systems, check:
- Game Design Document: `GameDesign.md`
- Source code comments in each module
- Roblox DevForum: [Homework Destroyer Development Thread]

---

**Version:** 1.0
**Last Updated:** January 2026
**Modules:** StatsCalculator.lua, UpgradeManager.lua, PrestigeManager.lua
