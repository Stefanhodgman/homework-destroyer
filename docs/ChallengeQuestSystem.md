# Challenge and Quest System Documentation

## Overview

The Challenge and Quest system for Homework Destroyer provides engaging daily/weekly challenges and a comprehensive quest progression system to enhance player retention and engagement.

## System Components

### 1. ChallengeManager.lua (Server-Side)
**Location:** `src/ServerStorage/Modules/ChallengeManager.lua`

Manages all challenge-related functionality including:
- Daily challenge generation and rotation (3 challenges per day)
- Weekly challenge generation (5 challenges per week)
- Challenge progress tracking
- Reward distribution
- Streak bonus system
- Auto-reset at midnight UTC (daily) and Monday midnight UTC (weekly)

### 2. QuestManager.lua (Server-Side)
**Location:** `src/ServerStorage/Modules/QuestManager.lua`

Handles quest progression with:
- Story quest chains (tutorial, main storyline)
- Side quests for exploration
- Zone-specific quests
- Multi-objective tracking
- Quest prerequisite system
- Reward claiming

### 3. ChallengesUI.lua (Client-Side)
**Location:** `src/StarterGui/ChallengesUI.lua`

Provides player interface for:
- Daily/Weekly challenge viewing
- Quest tracking
- Progress visualization
- Reward claiming interface
- Tab-based navigation
- Streak display

---

## Integration Guide

### Step 1: Server Integration

Add to your main server script (e.g., `GameServer.lua`):

```lua
-- Require the managers
local ChallengeManager = require(game.ServerStorage.Modules.ChallengeManager)
local QuestManager = require(game.ServerStorage.Modules.QuestManager)
local DataManager = require(game.ServerScriptService.DataManager)

-- Initialize systems
ChallengeManager:Initialize()
QuestManager:Initialize()

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
    -- Load player data
    local success, playerData = DataManager:LoadPlayerData(player)

    if success then
        -- Initialize challenge system
        playerData = ChallengeManager:InitializePlayer(player, playerData)

        -- Initialize quest system
        playerData = QuestManager:InitializePlayer(player, playerData)
    end
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    ChallengeManager:OnPlayerLeaving(player)
    QuestManager:OnPlayerLeaving(player)
end)
```

### Step 2: Connect Gameplay Events

Update challenge/quest progress when players perform actions:

```lua
-- When player destroys homework
local function OnHomeworkDestroyed(player, homeworkCount, zoneID)
    ChallengeManager:UpdateChallengeProgress(player, "DestroyHomework", homeworkCount, {Zone = zoneID})
    QuestManager:UpdateQuestProgress(player, "DestroyHomework", homeworkCount, {Zone = zoneID})
end

-- When player defeats a boss
local function OnBossDefeated(player)
    ChallengeManager:UpdateChallengeProgress(player, "DefeatBosses", 1)
    QuestManager:UpdateQuestProgress(player, "DestroyBoss", 1)
end

-- When player earns DP
local function OnDPEarned(player, amount)
    ChallengeManager:UpdateChallengeProgress(player, "EarnDP", amount)
    QuestManager:UpdateQuestProgress(player, "EarnDP", amount)
end

-- When player hatches egg
local function OnEggHatched(player)
    ChallengeManager:UpdateChallengeProgress(player, "HatchEggs", 1)
    QuestManager:UpdateQuestProgress(player, "HatchEggs", 1)
end

-- When player deals damage
local function OnDamageDealt(player, damage)
    ChallengeManager:UpdateChallengeProgress(player, "DealDamage", damage)
    QuestManager:UpdateQuestProgress(player, "DealDamage", damage)
end

-- When player lands critical hit
local function OnCriticalHit(player)
    ChallengeManager:UpdateChallengeProgress(player, "CriticalHits", 1)
end

-- When player performs rebirth
local function OnRebirth(player)
    ChallengeManager:UpdateChallengeProgress(player, "Rebirth", 1)
    QuestManager:UpdateQuestProgress(player, "PerformRebirth", 1)
end

-- When player reaches new level
local function OnLevelUp(player, newLevel)
    QuestManager:UpdateQuestProgress(player, "ReachLevel", newLevel)
end

-- When player unlocks zone
local function OnZoneUnlocked(player, zoneID)
    QuestManager:UpdateQuestProgress(player, "UnlockZone", zoneID)
end

-- When player purchases upgrade
local function OnUpgradePurchased(player)
    QuestManager:UpdateQuestProgress(player, "PurchaseUpgrade", 1)
end
```

### Step 3: Remote Event Handlers

Add handlers for reward claiming:

```lua
local RemoteEvents = require(game.ReplicatedStorage.Remotes.RemoteEvents)
local remotes = RemoteEvents.Get()

-- Handle challenge reward claims
remotes.ClaimChallengeReward.OnServerEvent:Connect(function(player, isWeekly, challengeIndex)
    local success, reward = ChallengeManager:ClaimChallengeReward(player, isWeekly, challengeIndex, DataManager)

    if success then
        -- Notify player
        remotes.ShowNotification:FireClient(player, "Success", "Reward Claimed!",
            "You received " .. (reward.DP or 0) .. " DP!", 5)

        -- Send updated data
        local playerData = DataManager:GetPlayerData(player)
        remotes.DataUpdate:FireClient(player, "DestructionPoints", playerData.DestructionPoints)
    end
end)

-- Handle quest acceptance
remotes.AcceptQuest.OnServerEvent:Connect(function(player, questID)
    local success, message = QuestManager:AcceptQuest(player, questID)

    if success then
        remotes.ShowNotification:FireClient(player, "Quest", "Quest Accepted!",
            "Check your progress in the Quests tab", 3)
    else
        remotes.ShowNotification:FireClient(player, "Error", "Cannot Accept", message, 3)
    end
end)

-- Handle quest completion
remotes.CompleteQuest.OnServerEvent:Connect(function(player, questID)
    local success, reward = QuestManager:ClaimQuestReward(player, questID, DataManager)

    if success then
        remotes.ShowNotification:FireClient(player, "Success", "Quest Complete!",
            "You received " .. (reward.DP or 0) .. " DP!", 5)

        -- Send updated data
        local playerData = DataManager:GetPlayerData(player)
        remotes.DataUpdate:FireClient(player, "DestructionPoints", playerData.DestructionPoints)
    end
end)

-- Handle data sync requests
remotes.RequestDataSync.OnServerEvent:Connect(function(player)
    local playerData = DataManager:GetPlayerData(player)

    if playerData then
        local challenges = ChallengeManager:GetPlayerChallenges(player)
        local quests = QuestManager:GetPlayerQuests(player)
        local streak = ChallengeManager:GetDailyStreak(player, playerData)

        -- Send to client (you'll need to add this remote event)
        remotes.SyncChallengeData:FireClient(player,
            challenges and challenges.Daily or {},
            challenges and challenges.Weekly or {},
            quests,
            streak
        )
    end
end)
```

### Step 4: Client Integration

In your main client script:

```lua
local ChallengesUI = require(script.Parent.ChallengesUI)

-- Initialize UI
ChallengesUI:Initialize()

-- Listen for data updates
local RemoteEvents = require(game.ReplicatedStorage.Remotes.RemoteEvents)
local remotes = RemoteEvents.Get()

-- Add this remote event to RemoteEvents.lua configuration
remotes.SyncChallengeData.OnClientEvent:Connect(function(dailyChallenges, weeklyChallenges, quests, streak)
    ChallengesUI:UpdateData(dailyChallenges, weeklyChallenges, quests, streak)
end)
```

### Step 5: Add Remote Event

Add to `RemoteEvents.lua` in the `REMOTE_CONFIGS` table:

```lua
{
    Name = "SyncChallengeData",
    Type = "Event",
    Description = "Server sends challenge/quest data to client",
    Parameters = "dailyChallenges, weeklyChallenges, quests, streak"
},
```

---

## Challenge System Details

### Daily Challenges

**Reset Time:** Midnight UTC (00:00)
**Count:** 3 challenges per day
**Difficulties:** Easy, Medium, Hard

#### Challenge Types:
- **DestroyHomework** - Destroy X homework pages
- **EarnDP** - Earn X Destruction Points
- **HatchEggs** - Hatch X pet eggs
- **PlayTime** - Play for X minutes
- **DealDamage** - Deal X total damage
- **DestroyInZone** - Destroy homework in specific zone
- **DefeatBosses** - Defeat X bosses
- **CriticalHits** - Land X critical hits
- **Rebirth** - Perform rebirth

#### Difficulty Rewards:
- **Easy:** 4,000 - 7,500 DP
- **Medium:** 12,500 - 25,000 DP
- **Hard:** 35,000 - 60,000 DP

#### Completion Bonus:
Complete all 3 daily challenges for bonus reward:
- Base: 15,000 DP
- Streak multiplier: +10% per consecutive day

### Weekly Challenges

**Reset Time:** Monday Midnight UTC
**Count:** 5 challenges per week

#### Weekly Challenge Types:
1. **Weekly Warrior** - Log in 5 different days (100,000 DP + Rare Egg)
2. **Destruction Master** - Destroy 50,000 homework (200,000 DP)
3. **Rebirth Ruler** - Perform 3 rebirths (250,000 DP + Epic Egg)
4. **Boss Exterminator** - Defeat 25 bosses (150,000 DP)
5. **Wealth Builder** - Earn 1,000,000 DP (300,000 DP + Epic Egg)

#### Completion Bonus:
Complete all 5 weekly challenges:
- 500,000 DP
- 1 Legendary Egg

### Streak System

The challenge system tracks consecutive days of completing challenges:

- Streak increases when you complete at least 1 challenge per day
- Streak resets if you miss a day
- Streak bonus applies to completion rewards (10% per day)
- Maximum practical streak bonus: 30+ days for dedicated players

**Example:**
- Day 1 streak: 15,000 DP bonus
- Day 5 streak: 22,500 DP bonus (15,000 × 1.5)
- Day 10 streak: 30,000 DP bonus (15,000 × 2.0)

---

## Quest System Details

### Quest Types

1. **Tutorial Quests**
   - Auto-accept
   - Linear progression
   - Teaches core mechanics
   - Example: First Destruction, Power Upgrade, Your First Pet

2. **Story Quests**
   - Main storyline
   - Auto-accept after prerequisites
   - Guides progression through zones
   - Example: The Assignment Avalanche, Boss Battle, The Path to Rebirth

3. **Side Quests**
   - Optional objectives
   - Manual acceptance required
   - Extra rewards and variety
   - Example: Pet Collector, Building Your Arsenal, Boss Hunter

4. **Zone Quests**
   - Zone-specific challenges
   - Multi-objective requirements
   - Example: Library Master (2,000 homework + 5 bosses)

### Quest Objectives

Quests can have multiple objectives that must all be completed:

```lua
Objectives = {
    {Type = "DestroyHomework", Target = 2000, Description = "Destroy 2,000 homework in Library"},
    {Type = "DestroyBoss", Target = 5, Description = "Defeat Overdue Library Book 5 times"},
}
```

### Quest Prerequisites

Quests unlock based on completing previous quests:

```lua
Prerequisites = {"TUTORIAL_3", "STORY_CLASSROOM_1"}
```

### Quest Status Flow

```
LOCKED → AVAILABLE → IN_PROGRESS → COMPLETED → CLAIMED
```

---

## Customization Guide

### Adding New Daily Challenges

In `ChallengeManager.lua`, add to `DailyChallengePool`:

```lua
{
    Type = ChallengeTypes.YOUR_TYPE,
    Name = "Challenge Name",
    Description = "Challenge description",
    Difficulty = "Medium", -- Easy, Medium, or Hard
    Target = 1000,
    Reward = {DP = 15000, Eggs = {}},
    Weight = 20, -- Higher = more likely to appear
}
```

### Adding New Quest Chains

In `QuestManager.lua`, add to `QuestDatabase`:

```lua
{
    ID = "UNIQUE_QUEST_ID",
    Type = QuestType.STORY, -- or SIDE, ZONE, TUTORIAL
    Name = "Quest Name",
    Description = "Quest description",
    Objectives = {
        {Type = ObjectiveType.DESTROY_HOMEWORK, Target = 500, Description = "Destroy 500 homework"},
    },
    Prerequisites = {"PREVIOUS_QUEST_ID"},
    Rewards = {DP = 25000},
    AutoAccept = false, -- true for story/tutorial
    OrderIndex = 50, -- For UI sorting
}
```

### Adjusting Reset Times

To change when challenges reset, modify constants in `ChallengeManager.lua`:

```lua
local DAILY_RESET_HOUR = 0 -- 0 = Midnight UTC
local WEEKLY_RESET_DAY = 2 -- 2 = Monday (1 = Sunday)
```

---

## UI Customization

### Colors

Modify the `COLORS` table in `ChallengesUI.lua`:

```lua
local COLORS = {
    Background = Color3.fromRGB(30, 30, 40),
    Accent = Color3.fromRGB(100, 200, 255),
    Success = Color3.fromRGB(100, 255, 150),
    -- ... etc
}
```

### Keyboard Shortcut

Default: **C key** to toggle UI

Change in `ChallengesUI.lua`:

```lua
if input.KeyCode == Enum.KeyCode.C then -- Change to any key
    ChallengesUI:Toggle()
end
```

---

## Testing Guide

### Testing Daily Challenges

1. Start the game in Studio
2. Check console for challenge generation messages
3. Complete objectives by triggering gameplay events
4. Verify progress updates in real-time
5. Test reward claiming

### Testing Weekly Challenges

1. Modify `GetWeekStart()` to force reset
2. Complete weekly objectives
3. Test login day tracking
4. Verify completion bonus

### Testing Quests

1. Complete tutorial quests in order
2. Verify prerequisite unlocking
3. Test multi-objective quests
4. Ensure rewards are granted correctly

### Debug Commands

Add to your admin console:

```lua
-- Force daily reset
playerData.DailyProgress.LastChallengeRefresh = 0
ChallengeManager:InitializePlayer(player, playerData)

-- Force weekly reset
playerData.WeeklyProgress.LastChallengeRefresh = 0
ChallengeManager:InitializePlayer(player, playerData)

-- Complete all challenge objectives
for _, challenge in ipairs(challenges.Daily) do
    challenge.Progress = challenge.Target
    challenge.Completed = true
end
```

---

## Performance Considerations

### Server Performance

- Challenges generate only on player login and at reset times
- Progress updates use efficient table lookups
- No polling or continuous checks
- Minimal memory footprint per player

### Client Performance

- UI updates only when visible
- Efficient scrolling frame with canvas size optimization
- Tween animations are lightweight
- No continuous rendering loops

### Data Storage

Each player's challenge/quest data adds approximately:
- Daily challenges: ~500 bytes
- Weekly challenges: ~800 bytes
- Quest progress: ~1-3 KB (depending on active quests)

Total: **~2-4 KB per player**

---

## Troubleshooting

### Challenges Not Generating

**Issue:** Player sees empty challenge list

**Solution:**
1. Check console for initialization errors
2. Verify `DailyProgress` and `WeeklyProgress` exist in player data
3. Ensure `GetDayStart()` and `GetWeekStart()` return correct timestamps

### Progress Not Updating

**Issue:** Challenge/quest objectives don't increase

**Solution:**
1. Verify `UpdateChallengeProgress` is called with correct parameters
2. Check objective type matches (case-sensitive)
3. Ensure player session is initialized
4. Add debug prints to track progress updates

### Rewards Not Claiming

**Issue:** Clicking claim button does nothing

**Solution:**
1. Verify RemoteEvent is connected on server
2. Check DataManager is passed to claim functions
3. Ensure challenge is marked as completed
4. Verify player has active session

### UI Not Showing

**Issue:** UI doesn't appear when toggled

**Solution:**
1. Check `ChallengesUI:Initialize()` was called
2. Verify ScreenGui is parented to PlayerGui
3. Check for z-index conflicts with other UIs
4. Ensure `mainFrame.Visible` is set to true

---

## Best Practices

### Design Guidelines

1. **Balance Difficulty**
   - Easy challenges: Completable in 5-10 minutes
   - Medium challenges: 15-30 minutes
   - Hard challenges: 30-60 minutes

2. **Reward Scaling**
   - Keep rewards proportional to time investment
   - Ensure completion bonuses are meaningful
   - Balance streak bonuses to encourage daily play

3. **Quest Pacing**
   - Tutorial: 3-5 quests, completable in 10 minutes
   - Story: Space out over progression curve
   - Side quests: Optional but rewarding

4. **Player Communication**
   - Use clear, concise descriptions
   - Show progress visually (progress bars)
   - Celebrate completions with notifications

### Retention Optimization

1. **Daily Engagement**
   - 3 challenges creates variety without overwhelming
   - Streak system rewards consistency
   - Quick challenges for time-limited players

2. **Weekly Goals**
   - Larger objectives for dedicated players
   - Login requirement encourages regular returns
   - Completion bonus provides major milestone

3. **Quest Progression**
   - Natural tutorial flow
   - Story quests guide through content
   - Side quests provide optional depth

---

## Future Enhancements

### Potential Features

1. **Challenge Difficulty Scaling**
   - Adjust targets based on player level/rebirth
   - Dynamic reward scaling

2. **Special Event Challenges**
   - Holiday-themed challenges
   - Limited-time bonus challenges
   - Community challenges

3. **Quest Achievements**
   - Completionist badges
   - Speed run rewards
   - Quest milestone tracking

4. **Social Features**
   - Friend challenge competitions
   - Guild/clan quests
   - Leaderboards for challenge completion

5. **Challenge Shop**
   - Spend challenge points on exclusive items
   - Reroll daily challenges (premium feature)
   - Challenge tokens as secondary currency

---

## API Reference

### ChallengeManager API

```lua
-- Initialize player challenges
ChallengeManager:InitializePlayer(player, playerData) -> playerData

-- Update challenge progress
ChallengeManager:UpdateChallengeProgress(player, challengeType, amount, extraData)

-- Claim challenge reward
ChallengeManager:ClaimChallengeReward(player, isWeekly, challengeIndex, DataManager) -> success, reward

-- Get player challenges
ChallengeManager:GetPlayerChallenges(player) -> {Daily = {}, Weekly = {}}

-- Get daily streak
ChallengeManager:GetDailyStreak(player, playerData) -> number

-- Cleanup
ChallengeManager:OnPlayerLeaving(player)
```

### QuestManager API

```lua
-- Initialize player quests
QuestManager:InitializePlayer(player, playerData) -> playerData

-- Accept quest
QuestManager:AcceptQuest(player, questID) -> success, message

-- Update quest progress
QuestManager:UpdateQuestProgress(player, objectiveType, amount, extraData)

-- Claim quest reward
QuestManager:ClaimQuestReward(player, questID, DataManager) -> success, reward

-- Unlock next quests
QuestManager:UnlockNextQuests(player)

-- Get player quests
QuestManager:GetPlayerQuests(player) -> {Tutorial = {}, Story = {}, Side = {}, Zone = {}}

-- Get active quests
QuestManager:GetActiveQuests(player) -> array

-- Cleanup
QuestManager:OnPlayerLeaving(player)
```

### ChallengesUI API

```lua
-- Initialize UI
ChallengesUI:Initialize()

-- Show/hide UI
ChallengesUI:Show()
ChallengesUI:Hide()
ChallengesUI:Toggle()

-- Switch tabs
ChallengesUI:SwitchTab(tabName) -- "Daily", "Weekly", "Quests"

-- Update data
ChallengesUI:UpdateData(dailyChallenges, weeklyChallenges, quests, streak)
```

---

## Version History

**Version 1.0** (Current)
- Initial release
- Daily/Weekly challenges
- Quest system with prerequisites
- Client UI with tab navigation
- Streak bonus system
- Reward claiming

**Planned Updates**
- Challenge difficulty scaling
- Event challenges
- Social features
- Enhanced UI animations

---

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review integration guide
3. Test with debug commands
4. Check console for error messages

## License

Part of the Homework Destroyer game project.
Created for educational and entertainment purposes.
