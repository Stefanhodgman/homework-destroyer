# Challenge & Quest System - Quick Start Guide

## 5-Minute Integration

### Step 1: Add to GameServer.lua

```lua
local ChallengeManager = require(game.ServerStorage.Modules.ChallengeManager)
local QuestManager = require(game.ServerStorage.Modules.QuestManager)
local DataManager = require(game.ServerScriptService.DataManager)

-- Initialize on server start
ChallengeManager:Initialize()
QuestManager:Initialize()

-- On player join
Players.PlayerAdded:Connect(function(player)
    local success, playerData = DataManager:LoadPlayerData(player)
    if success then
        playerData = ChallengeManager:InitializePlayer(player, playerData)
        playerData = QuestManager:InitializePlayer(player, playerData)
    end
end)

-- On player leave
Players.PlayerRemoving:Connect(function(player)
    ChallengeManager:OnPlayerLeaving(player)
    QuestManager:OnPlayerLeaving(player)
end)
```

### Step 2: Update RemoteEvents.lua

Add to `REMOTE_CONFIGS` array:

```lua
{
    Name = "SyncChallengeData",
    Type = "Event",
    Description = "Server sends challenge/quest data to client",
    Parameters = "dailyChallenges, weeklyChallenges, quests, streak"
},
```

### Step 3: Add Event Handlers

```lua
local RemoteEvents = require(game.ReplicatedStorage.Remotes.RemoteEvents)
local remotes = RemoteEvents.Get()

-- Claim challenge reward
remotes.ClaimChallengeReward.OnServerEvent:Connect(function(player, isWeekly, challengeIndex)
    local success, reward = ChallengeManager:ClaimChallengeReward(player, isWeekly, challengeIndex, DataManager)
    if success then
        remotes.ShowNotification:FireClient(player, "Success", "Reward Claimed!",
            "You received " .. reward.DP .. " DP!", 5)
    end
end)

-- Accept quest
remotes.AcceptQuest.OnServerEvent:Connect(function(player, questID)
    QuestManager:AcceptQuest(player, questID)
end)

-- Complete quest
remotes.CompleteQuest.OnServerEvent:Connect(function(player, questID)
    local success, reward = QuestManager:ClaimQuestReward(player, questID, DataManager)
    if success then
        remotes.ShowNotification:FireClient(player, "Success", "Quest Complete!",
            "You received " .. reward.DP .. " DP!", 5)
    end
end)

-- Sync data
remotes.RequestDataSync.OnServerEvent:Connect(function(player)
    local playerData = DataManager:GetPlayerData(player)
    if playerData then
        local challenges = ChallengeManager:GetPlayerChallenges(player)
        local quests = QuestManager:GetPlayerQuests(player)
        local streak = ChallengeManager:GetDailyStreak(player, playerData)

        remotes.SyncChallengeData:FireClient(player,
            challenges.Daily, challenges.Weekly, quests, streak)
    end
end)
```

### Step 4: Initialize Client UI

In your main client script:

```lua
local ChallengesUI = require(script.Parent.ChallengesUI)
ChallengesUI:Initialize()

-- Listen for data sync
local RemoteEvents = require(game.ReplicatedStorage.Remotes.RemoteEvents)
local remotes = RemoteEvents.Get()

remotes.SyncChallengeData.OnClientEvent:Connect(function(daily, weekly, quests, streak)
    ChallengesUI:UpdateData(daily, weekly, quests, streak)
end)
```

### Step 5: Track Progress

Connect to your existing gameplay code:

```lua
-- When homework destroyed
ChallengeManager:UpdateChallengeProgress(player, "DestroyHomework", count, {Zone = zoneID})
QuestManager:UpdateQuestProgress(player, "DestroyHomework", count)

-- When boss defeated
ChallengeManager:UpdateChallengeProgress(player, "DefeatBosses", 1)
QuestManager:UpdateQuestProgress(player, "DestroyBoss", 1)

-- When DP earned
ChallengeManager:UpdateChallengeProgress(player, "EarnDP", amount)

-- When egg hatched
ChallengeManager:UpdateChallengeProgress(player, "HatchEggs", 1)
QuestManager:UpdateQuestProgress(player, "HatchEggs", 1)

-- When damage dealt
ChallengeManager:UpdateChallengeProgress(player, "DealDamage", damage)

-- When critical hit
ChallengeManager:UpdateChallengeProgress(player, "CriticalHits", 1)

-- When rebirth performed
ChallengeManager:UpdateChallengeProgress(player, "Rebirth", 1)
QuestManager:UpdateQuestProgress(player, "PerformRebirth", 1)

-- When level up
QuestManager:UpdateQuestProgress(player, "ReachLevel", newLevel)

-- When zone unlocked
QuestManager:UpdateQuestProgress(player, "UnlockZone", zoneID)

-- When upgrade purchased
QuestManager:UpdateQuestProgress(player, "PurchaseUpgrade", 1)
```

## Done!

Press **C key** in-game to open the challenges UI.

## Common Update Patterns

### Update Multiple Systems

```lua
local function OnHomeworkDestroyed(player, count, zone)
    -- Update both systems
    ChallengeManager:UpdateChallengeProgress(player, "DestroyHomework", count, {Zone = zone})
    QuestManager:UpdateQuestProgress(player, "DestroyHomework", count)

    -- Update player stats
    DataManager:IncrementPlayerData(player, "TotalHomeworkDestroyed", count)
end
```

### Track Play Time

```lua
-- Add to player session data
spawn(function()
    while player.Parent do
        wait(60) -- Every minute
        ChallengeManager:UpdateChallengeProgress(player, "PlayTime", 60)
        QuestManager:UpdateQuestProgress(player, "PlayTime", 60)
    end
end)
```

## Testing Commands

```lua
-- Force challenge reset
playerData.DailyProgress.LastChallengeRefresh = 0
ChallengeManager:InitializePlayer(player, playerData)

-- Complete all challenges
local challenges = ChallengeManager:GetPlayerChallenges(player)
for _, c in ipairs(challenges.Daily) do
    c.Progress = c.Target
    c.Completed = true
end

-- Unlock all quests
local quests = QuestManager:GetPlayerQuests(player)
for _, questList in pairs(quests) do
    for _, quest in ipairs(questList) do
        quest.Status = "Available"
    end
end
```

## Customization Quick Links

### Add New Challenge Type
Edit: `ChallengeManager.lua` → `DailyChallengePool`

### Add New Quest
Edit: `QuestManager.lua` → `QuestDatabase`

### Change UI Colors
Edit: `ChallengesUI.lua` → `COLORS` table

### Change Reset Times
Edit: `ChallengeManager.lua` → Constants at top

## File Locations

- **Server:** `src/ServerStorage/Modules/ChallengeManager.lua`
- **Server:** `src/ServerStorage/Modules/QuestManager.lua`
- **Client:** `src/StarterGui/ChallengesUI.lua`
- **Docs:** `docs/ChallengeQuestSystem.md` (full documentation)

## Need Help?

See full documentation at: `docs/ChallengeQuestSystem.md`

Key sections:
- Integration Guide (detailed steps)
- API Reference (all function signatures)
- Customization Guide (add content)
- Troubleshooting (common issues)
