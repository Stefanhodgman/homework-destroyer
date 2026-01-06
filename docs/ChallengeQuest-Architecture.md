# Challenge & Quest System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        HOMEWORK DESTROYER                        │
│                   Challenge & Quest System                       │
└─────────────────────────────────────────────────────────────────┘

                         ┌──────────────┐
                         │   PLAYER     │
                         │   JOINS      │
                         └──────┬───────┘
                                │
                    ┌───────────▼────────────┐
                    │   DataManager.lua      │
                    │  (Load Player Data)    │
                    └───────────┬────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
        ┌───────▼────────┐ ┌───▼────────┐ ┌───▼────────┐
        │ ChallengeManager│ │ QuestManager│ │   Other    │
        │  :Initialize()  │ │ :Initialize()│ │  Systems   │
        └────────┬────────┘ └──────┬──────┘ └────────────┘
                 │                 │
                 │   Initialize    │
                 │   Player Data   │
                 │                 │
        ┌────────▼────────┐ ┌──────▼──────┐
        │ Generate Daily  │ │ Load Quest  │
        │ & Weekly        │ │ Progress    │
        │ Challenges      │ │             │
        └────────┬────────┘ └──────┬──────┘
                 │                 │
                 └────────┬────────┘
                          │
                  ┌───────▼────────┐
                  │  Send to Client │
                  │  (RemoteEvent)  │
                  └───────┬─────────┘
                          │
                  ┌───────▼─────────┐
                  │  ChallengesUI   │
                  │  Display Data   │
                  └─────────────────┘
```

## Data Flow - Challenge Progress Update

```
┌──────────────┐
│   GAMEPLAY   │
│    EVENT     │ (Player destroys homework)
└──────┬───────┘
       │
       │ OnHomeworkDestroyed(player, count, zone)
       │
┌──────▼────────────────────────────────────────────────┐
│                   GAME SERVER                         │
│                                                       │
│  ChallengeManager:UpdateChallengeProgress(           │
│      player,                                         │
│      "DestroyHomework",                             │
│      count,                                         │
│      {Zone = zoneID}                               │
│  )                                                  │
│                                                     │
│  QuestManager:UpdateQuestProgress(                │
│      player,                                     │
│      "DestroyHomework",                         │
│      count                                      │
│  )                                             │
└──────┬────────────────────────────────────────┘
       │
       │ Check all active challenges/quests
       │ Update progress counters
       │
       ├─ Daily Challenge 1: Progress += count
       ├─ Daily Challenge 2: No match (different type)
       ├─ Daily Challenge 3: Progress += count
       │
       ├─ Weekly Challenge 1: Progress += count
       │
       ├─ Quest TUTORIAL_1: Progress += count ✓ Complete!
       └─ Quest STORY_CLASSROOM_1: Progress += count
       │
       ├─ If Challenge/Quest Completed:
       │  └─ Fire "ShowNotification" to client
       │
       └─ Data automatically saved by DataManager
```

## Data Flow - Reward Claiming

```
┌──────────────┐
│    PLAYER    │
│ Clicks "Claim"│
│   Button     │
└──────┬───────┘
       │
       │ RemoteEvent:FireServer("ClaimChallengeReward", isWeekly, index)
       │
┌──────▼────────────────────────────────────────────────┐
│                   GAME SERVER                         │
│                                                       │
│  1. Validate: Challenge complete? Not claimed?       │
│                                                      │
│  2. Mark as claimed                                 │
│                                                     │
│  3. Award DP via DataManager                       │
│                                                    │
│  4. Check completion bonus                        │
│     - All dailies done? +15k DP bonus            │
│     - Streak bonus applied                       │
│                                                  │
│  5. Unlock next quests (if quest claimed)       │
│                                                 │
│  6. Send notification to client                │
│                                                │
│  7. Send updated data sync                    │
└──────┬───────────────────────────────────────┘
       │
       │ RemoteEvent:FireClient("ShowNotification", ...)
       │ RemoteEvent:FireClient("SyncChallengeData", ...)
       │
┌──────▼────────┐
│  CLIENT UI    │
│               │
│  - Show reward│
│  - Update DP  │
│  - Refresh UI │
└───────────────┘
```

## File Structure

```
homework-destroyer/
│
├── src/
│   ├── ServerStorage/
│   │   └── Modules/
│   │       ├── ChallengeManager.lua    ← Daily/Weekly challenges
│   │       ├── QuestManager.lua        ← Quest progression
│   │       ├── PrestigeManager.lua     (existing)
│   │       ├── StatsCalculator.lua     (existing)
│   │       └── UpgradeManager.lua      (existing)
│   │
│   ├── ServerScriptService/
│   │   ├── DataManager.lua             (existing - stores data)
│   │   └── GameServer.lua              (existing - add integration here)
│   │
│   ├── StarterGui/
│   │   ├── ChallengesUI.lua            ← Client UI for challenges/quests
│   │   ├── UIController.lua            (existing)
│   │   └── UpgradeUI.lua               (existing)
│   │
│   └── ReplicatedStorage/
│       └── Remotes/
│           └── RemoteEvents.lua        (existing - add new events)
│
└── docs/
    ├── ChallengeQuestSystem.md         ← Full documentation
    ├── ChallengeQuest-QuickStart.md    ← 5-minute setup guide
    └── ChallengeQuest-Architecture.md  ← This file
```

## Challenge System Components

### ChallengeManager.lua (Server)

```
┌────────────────────────────────────────┐
│      CHALLENGE MANAGER                 │
├────────────────────────────────────────┤
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Challenge Generation       │    │
│  │                              │    │
│  │  - DailyChallengePool        │    │
│  │  - WeeklyChallengePool       │    │
│  │  - Weighted Selection        │    │
│  │  - 3 Daily, 5 Weekly         │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Reset Logic                │    │
│  │                              │    │
│  │  - GetDayStart()             │    │
│  │  - GetWeekStart()            │    │
│  │  - Auto-reset at midnight    │    │
│  │  - Monday reset for weekly   │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Progress Tracking          │    │
│  │                              │    │
│  │  - UpdateChallengeProgress() │    │
│  │  - Match challenge type      │    │
│  │  - Increment counters        │    │
│  │  - Check completion          │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Streak System              │    │
│  │                              │    │
│  │  - Track consecutive days    │    │
│  │  - +10% bonus per day        │    │
│  │  - Grace period (26 hours)   │    │
│  │  - Streak protection         │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Reward Distribution        │    │
│  │                              │    │
│  │  - ClaimChallengeReward()    │    │
│  │  - Validate completion       │    │
│  │  - Award DP + items          │    │
│  │  - Completion bonuses        │    │
│  └──────────────────────────────┘    │
└────────────────────────────────────────┘
```

### QuestManager.lua (Server)

```
┌────────────────────────────────────────┐
│         QUEST MANAGER                  │
├────────────────────────────────────────┤
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Quest Database             │    │
│  │                              │    │
│  │  - Tutorial Quests (3)       │    │
│  │  - Story Quests (6+)         │    │
│  │  - Side Quests (5+)          │    │
│  │  - Zone Quests (1+)          │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Prerequisite System        │    │
│  │                              │    │
│  │  - MeetsPrerequisites()      │    │
│  │  - Quest unlocking           │    │
│  │  - Dependency chains         │    │
│  │  - Auto-accept system        │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Multi-Objective Tracking   │    │
│  │                              │    │
│  │  - Multiple objectives       │    │
│  │  - Individual progress       │    │
│  │  - All must complete         │    │
│  │  - Partial completion        │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Quest Status Flow          │    │
│  │                              │    │
│  │  LOCKED → AVAILABLE →        │    │
│  │  IN_PROGRESS → COMPLETED →   │    │
│  │  CLAIMED                     │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Quest Progression          │    │
│  │                              │    │
│  │  - UnlockNextQuests()        │    │
│  │  - Chain continuation        │    │
│  │  - Notification system       │    │
│  └──────────────────────────────┘    │
└────────────────────────────────────────┘
```

### ChallengesUI.lua (Client)

```
┌────────────────────────────────────────┐
│        CHALLENGES UI                   │
├────────────────────────────────────────┤
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Main UI Frame              │    │
│  │                              │    │
│  │  - Header (title, streak)    │    │
│  │  - Tab buttons (3)           │    │
│  │  - Content area              │    │
│  │  - Close button              │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Tab System                 │    │
│  │                              │    │
│  │  [Daily] [Weekly] [Quests]   │    │
│  │                              │    │
│  │  - Switch between views      │    │
│  │  - Visual active state       │    │
│  │  - Content filtering         │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Challenge Cards            │    │
│  │                              │    │
│  │  ┌─────────────────────┐     │    │
│  │  │ [EASY] Challenge    │     │    │
│  │  │ Description...      │     │    │
│  │  │ [████████░░] 80%   │     │    │
│  │  │ Reward: 5,000 DP    │     │    │
│  │  │ [CLAIM REWARD]      │     │    │
│  │  └─────────────────────┘     │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Quest Cards                │    │
│  │                              │    │
│  │  ┌─────────────────────┐     │    │
│  │  │ [STORY] Quest Name  │     │    │
│  │  │ Quest description   │     │    │
│  │  │ [✓] Objective 1     │     │    │
│  │  │ [ ] Objective 2     │     │    │
│  │  │ [ACCEPT / CLAIM]    │     │    │
│  │  └─────────────────────┘     │    │
│  └──────────────────────────────┘    │
│                                        │
│  ┌──────────────────────────────┐    │
│  │   Input Handling             │    │
│  │                              │    │
│  │  - C key to toggle           │    │
│  │  - Click handlers            │    │
│  │  - Scroll support            │    │
│  └──────────────────────────────┘    │
└────────────────────────────────────────┘
```

## Data Storage Structure

### PlayerData.DailyProgress

```lua
DailyProgress = {
    LastChallengeRefresh = 1704585600,  -- Timestamp
    ChallengesCompletedToday = 2,       -- Count
    DailyStreakCount = 5,                -- Consecutive days
    LastStreakDate = 1704585600,        -- Timestamp

    DailyChallenges = {
        [1] = {
            Type = "DestroyHomework",
            Name = "Click Starter",
            Description = "Destroy 500 homework",
            Difficulty = "Easy",
            Target = 500,
            Progress = 500,
            Completed = true,
            Claimed = true,
            Reward = {DP = 5000, Eggs = {}}
        },
        [2] = {
            Type = "DefeatBosses",
            Name = "Boss Hunter",
            Description = "Defeat 2 bosses",
            Difficulty = "Medium",
            Target = 2,
            Progress = 1,
            Completed = false,
            Claimed = false,
            Reward = {DP = 25000, Eggs = {}}
        },
        [3] = {...}
    }
}
```

### PlayerData.WeeklyProgress

```lua
WeeklyProgress = {
    LastChallengeRefresh = 1704326400,  -- Monday timestamp
    ChallengesCompletedThisWeek = 1,    -- Count

    WeeklyChallenges = {
        [1] = {
            Type = "LoginDays",
            Name = "Weekly Warrior",
            Description = "Log in 5 different days",
            Target = 5,
            Progress = 3,
            Completed = false,
            Claimed = false,
            Reward = {DP = 100000, Eggs = {"Rare"}}
        },
        [2] = {...},
        ...
    }
}
```

### PlayerData.Quests

```lua
Quests = {
    Progress = {
        ["TUTORIAL_1"] = {
            ID = "TUTORIAL_1",
            Status = "Claimed",
            Objectives = {
                [1] = {
                    Type = "DestroyHomework",
                    Target = 10,
                    Progress = 10,
                    Description = "Destroy 10 homework",
                    Completed = true
                }
            },
            StartTime = 1704500000,
            CompleteTime = 1704500120
        },
        ["STORY_CLASSROOM_1"] = {
            ID = "STORY_CLASSROOM_1",
            Status = "InProgress",
            Objectives = {...},
            StartTime = 1704500130,
            CompleteTime = 0
        },
        ...
    }
}
```

## Integration Points

### 1. Gameplay Events → Challenge/Quest Updates

```
Homework Destroyed  →  UpdateChallengeProgress("DestroyHomework")
                    →  UpdateQuestProgress("DestroyHomework")

Boss Defeated      →  UpdateChallengeProgress("DefeatBosses")
                   →  UpdateQuestProgress("DestroyBoss")

DP Earned          →  UpdateChallengeProgress("EarnDP")
                   →  UpdateQuestProgress("EarnDP")

Egg Hatched        →  UpdateChallengeProgress("HatchEggs")
                   →  UpdateQuestProgress("HatchEggs")

Level Up           →  UpdateQuestProgress("ReachLevel")

Zone Unlocked      →  UpdateQuestProgress("UnlockZone")

Rebirth            →  UpdateChallengeProgress("Rebirth")
                   →  UpdateQuestProgress("PerformRebirth")
```

### 2. Client ↔ Server Communication

```
CLIENT                          SERVER
   │                               │
   │─── RequestDataSync() ────────>│
   │                               │
   │<── SyncChallengeData() ───────│
   │    (daily, weekly, quests)    │
   │                               │
   │─── ClaimChallengeReward() ───>│
   │                               │
   │<── ShowNotification() ────────│
   │<── DataUpdate() ──────────────│
   │                               │
   │─── AcceptQuest() ────────────>│
   │                               │
   │<── ShowNotification() ────────│
   │                               │
   │─── CompleteQuest() ──────────>│
   │                               │
   │<── ShowNotification() ────────│
   │<── DataUpdate() ──────────────│
```

## Performance Characteristics

### Server Load

- **Initialization:** O(n) per player (n = number of challenges/quests)
- **Progress Update:** O(m) where m = active challenges + active quests
- **Reset Check:** O(1) timestamp comparison
- **Memory:** ~2-4 KB per player

### Client Load

- **UI Rendering:** Only when visible
- **Update Frequency:** On-demand (no polling)
- **Memory:** Minimal (single UI instance)

### Network Traffic

- **Initial Sync:** ~5-10 KB (all challenge/quest data)
- **Progress Updates:** Server-side only (no client sync)
- **Reward Claims:** ~100 bytes per request

## Scalability

### Supports:
- Unlimited players (independent player data)
- 100+ challenges in pool (weighted random selection)
- 50+ quests (efficient prerequisite checking)
- Real-time progress updates (event-driven)

### Optimizations:
- Lazy loading (initialize only on login)
- Efficient data structures (hash tables)
- Minimal remote events (batch updates)
- Smart caching (no redundant calculations)

## Security Considerations

### Server-Side Validation

```
✓ All reward claims validated server-side
✓ Progress updates only via server events
✓ No client-side progress manipulation
✓ Completion checks before rewards
✓ Timestamp validation for resets
```

### Anti-Exploit Measures

```
✓ Cannot claim uncompleted challenges
✓ Cannot claim already-claimed rewards
✓ Cannot accept locked quests
✓ Cannot manipulate streak counts
✓ Progress capped at target values
```

## Extensibility

### Easy to Add:

1. **New Challenge Types** - Add to pool, implement tracker
2. **New Quest Chains** - Add to database with prerequisites
3. **Special Events** - Temporary challenge pools
4. **Seasonal Quests** - Time-limited quest chains
5. **Achievement Integration** - Trigger on quest completion
6. **Social Features** - Friend challenges, guild quests

### Modification Points:

- `DailyChallengePool` - Add/modify daily challenges
- `WeeklyChallengePool` - Add/modify weekly challenges
- `QuestDatabase` - Add new quests
- `COLORS` table - Theme customization
- Reset times - Timezone adjustments

---

*Last Updated: January 2026*
*Version: 1.0*
