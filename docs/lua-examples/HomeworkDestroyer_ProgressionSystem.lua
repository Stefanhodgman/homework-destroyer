--[[
================================================================================
    HOMEWORK DESTROYER - COMPLETE PROGRESSION AND UPGRADE SYSTEM
    A Roblox Clicker Game Design Document

    Currency: Destruction Points (DP)
    Secondary Currency: Prestige Stars (PS)
    Premium Currency: Golden Erasers (GE)
================================================================================
]]--

local HomeworkDestroyer = {}

--[[
================================================================================
    SECTION 1: TOOL PROGRESSION SYSTEM
================================================================================
    Tools determine base click power and unlock special abilities.
    Each tool has a unique visual effect and sound.
]]--

HomeworkDestroyer.Tools = {
    -- TIER 1: BASIC TOOLS (Classroom Zone)
    [1] = {
        Name = "Bare Hand",
        Cost = 0, -- Starting tool
        BaseDamage = 1,
        ClicksPerSecond = 1,
        CritChance = 0.01, -- 1%
        CritMultiplier = 1.5,
        SpecialAbility = nil,
        Description = "Your trusty hand. Not great, but it's free!",
        RequiredZone = "Classroom",
        RequiredLevel = 1
    },
    [2] = {
        Name = "Pencil",
        Cost = 50,
        BaseDamage = 2,
        ClicksPerSecond = 1.1,
        CritChance = 0.02,
        CritMultiplier = 1.5,
        SpecialAbility = "Poke: 5% chance to deal 3x damage",
        Description = "Sharp enough to destroy homework... and dreams.",
        RequiredZone = "Classroom",
        RequiredLevel = 2
    },
    [3] = {
        Name = "Eraser",
        Cost = 250,
        BaseDamage = 5,
        ClicksPerSecond = 1.2,
        CritChance = 0.03,
        CritMultiplier = 1.75,
        SpecialAbility = "Smudge: Destroys 10% of remaining homework HP",
        Description = "Erases homework from existence!",
        RequiredZone = "Classroom",
        RequiredLevel = 5
    },
    [4] = {
        Name = "Scissors",
        Cost = 1000,
        BaseDamage = 12,
        ClicksPerSecond = 1.3,
        CritChance = 0.05,
        CritMultiplier = 2.0,
        SpecialAbility = "Snip Snip: Every 10th click deals 5x damage",
        Description = "Running with these is encouraged!",
        RequiredZone = "Classroom",
        RequiredLevel = 8
    },

    -- TIER 2: ADVANCED TOOLS (Library Zone)
    [5] = {
        Name = "Paper Shredder",
        Cost = 5000,
        BaseDamage = 30,
        ClicksPerSecond = 1.5,
        CritChance = 0.07,
        CritMultiplier = 2.0,
        SpecialAbility = "Shred Frenzy: 15% chance to destroy 2 homework at once",
        Description = "Industrial-grade homework elimination.",
        RequiredZone = "Library",
        RequiredLevel = 12
    },
    [6] = {
        Name = "Hole Puncher 3000",
        Cost = 15000,
        BaseDamage = 75,
        ClicksPerSecond = 1.6,
        CritChance = 0.08,
        CritMultiplier = 2.25,
        SpecialAbility = "Perforate: Weakens homework, next 5 clicks deal 2x",
        Description = "Punches holes in homework AND logic!",
        RequiredZone = "Library",
        RequiredLevel = 16
    },
    [7] = {
        Name = "Staple Remover of Doom",
        Cost = 50000,
        BaseDamage = 180,
        ClicksPerSecond = 1.8,
        CritChance = 0.10,
        CritMultiplier = 2.5,
        SpecialAbility = "Unstable: Removes all stapled bonus HP from homework",
        Description = "The forbidden office supply.",
        RequiredZone = "Library",
        RequiredLevel = 20
    },

    -- TIER 3: DANGEROUS TOOLS (Principal's Office Zone)
    [8] = {
        Name = "Flamethrower",
        Cost = 200000,
        BaseDamage = 500,
        ClicksPerSecond = 2.0,
        CritChance = 0.12,
        CritMultiplier = 2.75,
        SpecialAbility = "Burn: Deals 50 damage per second for 5 seconds",
        Description = "Fire solves everything. EVERYTHING.",
        RequiredZone = "PrincipalsOffice",
        RequiredLevel = 25
    },
    [9] = {
        Name = "Industrial Acid Spray",
        Cost = 750000,
        BaseDamage = 1500,
        ClicksPerSecond = 2.2,
        CritChance = 0.15,
        CritMultiplier = 3.0,
        SpecialAbility = "Dissolve: Ignores 25% of homework defense",
        Description = "Melts paper AND safety regulations!",
        RequiredZone = "PrincipalsOffice",
        RequiredLevel = 32
    },
    [10] = {
        Name = "Mini Black Hole Generator",
        Cost = 3000000,
        BaseDamage = 5000,
        ClicksPerSecond = 2.5,
        CritChance = 0.18,
        CritMultiplier = 3.5,
        SpecialAbility = "Gravity Well: Pulls in nearby homework, damages all",
        Description = "Bends reality to destroy homework.",
        RequiredZone = "PrincipalsOffice",
        RequiredLevel = 40
    },

    -- TIER 4: LEGENDARY TOOLS (School Board HQ Zone)
    [11] = {
        Name = "Quantum Eraser",
        Cost = 15000000,
        BaseDamage = 20000,
        ClicksPerSecond = 3.0,
        CritChance = 0.22,
        CritMultiplier = 4.0,
        SpecialAbility = "Quantum Delete: 5% chance to instantly destroy homework",
        Description = "Erases homework from all timelines!",
        RequiredZone = "SchoolBoardHQ",
        RequiredLevel = 50
    },
    [12] = {
        Name = "Anti-Homework Laser",
        Cost = 75000000,
        BaseDamage = 80000,
        ClicksPerSecond = 3.5,
        CritChance = 0.25,
        CritMultiplier = 4.5,
        SpecialAbility = "Focused Beam: Hold click to charge, up to 10x damage",
        Description = "Pew pew! No more homework!",
        RequiredZone = "SchoolBoardHQ",
        RequiredLevel = 60
    },
    [13] = {
        Name = "Homework Annihilator 9000",
        Cost = 500000000,
        BaseDamage = 350000,
        ClicksPerSecond = 4.0,
        CritChance = 0.30,
        CritMultiplier = 5.0,
        SpecialAbility = "Annihilate: Destroys all homework on screen once per minute",
        Description = "The ultimate weapon against education!",
        RequiredZone = "SchoolBoardHQ",
        RequiredLevel = 75
    },

    -- TIER 5: MYTHIC TOOLS (Post-Prestige, Requires Prestige Stars)
    [14] = {
        Name = "The Eraser of Legends",
        Cost = 0, -- Costs Prestige Stars instead
        PrestigeCost = 50,
        BaseDamage = 1500000,
        ClicksPerSecond = 5.0,
        CritChance = 0.35,
        CritMultiplier = 6.0,
        SpecialAbility = "Legendary Wipe: Every click has 10% chance to destroy x10 homework",
        Description = "Forged in the fires of detention.",
        RequiredZone = "SchoolBoardHQ",
        RequiredLevel = 100,
        RequiredPrestiges = 5
    },
    [15] = {
        Name = "Cosmic Destroyer",
        Cost = 0,
        PrestigeCost = 200,
        BaseDamage = 10000000,
        ClicksPerSecond = 6.0,
        CritChance = 0.40,
        CritMultiplier = 8.0,
        SpecialAbility = "Supernova: Explodes, dealing damage to all homework for 10 seconds",
        Description = "Harness the power of dying stars!",
        RequiredZone = "SchoolBoardHQ",
        RequiredLevel = 150,
        RequiredPrestiges = 15
    },
    [16] = {
        Name = "The Assignment Ender",
        Cost = 0,
        PrestigeCost = 1000,
        BaseDamage = 100000000,
        ClicksPerSecond = 8.0,
        CritChance = 0.50,
        CritMultiplier = 10.0,
        SpecialAbility = "Final Answer: 1% chance per click to end all homework in zone",
        Description = "The final solution to the homework problem.",
        RequiredZone = "SchoolBoardHQ",
        RequiredLevel = 250,
        RequiredPrestiges = 50
    }
}

--[[
================================================================================
    SECTION 2: STAT UPGRADE SYSTEM
================================================================================
    Players spend Destruction Points to permanently upgrade stats.
    Each upgrade has increasing costs following a formula.
    Cost = BaseCost * (CostMultiplier ^ CurrentLevel)
]]--

HomeworkDestroyer.StatUpgrades = {
    -- CLICK POWER UPGRADES
    ClickPower = {
        Name = "Click Power",
        Description = "Increases damage per click",
        MaxLevel = 500,
        BaseCost = 10,
        CostMultiplier = 1.15,
        BaseBonus = 1, -- +1 damage per level
        BonusMultiplier = 1.05, -- Each level gives 5% more than previous
        Icon = "rbxassetid://clickpower_icon",

        -- Cost examples:
        -- Level 1: 10 DP
        -- Level 10: 40 DP
        -- Level 25: 330 DP
        -- Level 50: 2,668 DP
        -- Level 100: 117,390 DP
        -- Level 200: 22,739,242 DP
        -- Level 500: 8.9 billion DP
    },

    ClickSpeed = {
        Name = "Click Speed",
        Description = "Reduces cooldown between clicks",
        MaxLevel = 100,
        BaseCost = 50,
        CostMultiplier = 1.25,
        BaseBonus = 0.01, -- -1% cooldown per level (min 0.1 seconds)
        BonusMultiplier = 1.0, -- Linear scaling
        Icon = "rbxassetid://clickspeed_icon",

        -- Level 1: 50 DP (99% cooldown)
        -- Level 10: 466 DP (90% cooldown)
        -- Level 25: 12,622 DP (75% cooldown)
        -- Level 50: 3,533,640 DP (50% cooldown)
        -- Level 100: 39.4 billion DP (0% cooldown - instant clicks!)
    },

    CriticalChance = {
        Name = "Critical Chance",
        Description = "Chance to deal critical damage",
        MaxLevel = 50,
        BaseCost = 100,
        CostMultiplier = 1.35,
        BaseBonus = 0.005, -- +0.5% crit chance per level
        BonusMultiplier = 1.0,
        Icon = "rbxassetid://critchance_icon",

        -- Level 1: 100 DP (+0.5%)
        -- Level 10: 2,054 DP (+5%)
        -- Level 25: 285,884 DP (+12.5%)
        -- Level 50: 190 million DP (+25% total crit chance boost)
    },

    CriticalDamage = {
        Name = "Critical Damage",
        Description = "Multiplier for critical hits",
        MaxLevel = 100,
        BaseCost = 150,
        CostMultiplier = 1.20,
        BaseBonus = 0.1, -- +10% crit damage per level
        BonusMultiplier = 1.02,
        Icon = "rbxassetid://critdamage_icon",

        -- Level 1: 150 DP (+10% = 1.6x base)
        -- Level 10: 929 DP (+100% = 2.5x base)
        -- Level 50: 1.37 million DP (+500% = 6.5x base)
        -- Level 100: 1.25 billion DP (+1000% = 11.5x base)
    },

    -- AUTO-DESTROY UPGRADES
    AutoDestroyPower = {
        Name = "Auto-Destroy Power",
        Description = "Damage dealt automatically per second",
        MaxLevel = 250,
        BaseCost = 500,
        CostMultiplier = 1.12,
        BaseBonus = 5, -- +5 auto damage per level
        BonusMultiplier = 1.08,
        Icon = "rbxassetid://autodestroy_icon",
        UnlockRequirement = {Level = 10, Zone = "Classroom"},

        -- Level 1: 500 DP (+5 DPS)
        -- Level 10: 1,552 DP (+50 DPS)
        -- Level 50: 145,841 DP (~2,000 DPS)
        -- Level 100: 4.25 million DP (~50,000 DPS)
        -- Level 250: 14.9 billion DP (~5 million DPS)
    },

    AutoDestroySpeed = {
        Name = "Auto-Destroy Speed",
        Description = "How often auto-destroy triggers",
        MaxLevel = 50,
        BaseCost = 1000,
        CostMultiplier = 1.30,
        BaseBonus = 0.05, -- +5% speed per level (starts at 1/sec, caps at 5/sec)
        BonusMultiplier = 1.0,
        Icon = "rbxassetid://autospeed_icon",
        UnlockRequirement = {Level = 15, Zone = "Classroom"},

        -- Level 1: 1,000 DP (1.05/sec)
        -- Level 10: 13,786 DP (1.5/sec)
        -- Level 25: 705,641 DP (2.25/sec)
        -- Level 50: 497 million DP (3.5/sec)
    },

    -- MULTIPLIER UPGRADES
    DestructionMultiplier = {
        Name = "Destruction Multiplier",
        Description = "Multiplies all destruction points earned",
        MaxLevel = 100,
        BaseCost = 2000,
        CostMultiplier = 1.18,
        BaseBonus = 0.05, -- +5% DP per level
        BonusMultiplier = 1.01,
        Icon = "rbxassetid://multiplier_icon",
        UnlockRequirement = {Level = 20, Zone = "Library"},

        -- Level 1: 2,000 DP (+5%)
        -- Level 10: 10,616 DP (+50%)
        -- Level 50: 10.2 million DP (+250%)
        -- Level 100: 3.17 billion DP (+500%)
    },

    -- SPECIAL UPGRADES
    LuckBoost = {
        Name = "Luck Boost",
        Description = "Increases rare drop rates and bonus events",
        MaxLevel = 75,
        BaseCost = 5000,
        CostMultiplier = 1.22,
        BaseBonus = 0.02, -- +2% luck per level
        BonusMultiplier = 1.0,
        Icon = "rbxassetid://luck_icon",
        UnlockRequirement = {Level = 25, Zone = "Library"},

        -- Level 1: 5,000 DP (+2%)
        -- Level 25: 553,963 DP (+50%)
        -- Level 50: 110 million DP (+100%)
        -- Level 75: 21.8 billion DP (+150%)
    },

    HomeworkMagnet = {
        Name = "Homework Magnet",
        Description = "Automatically collects dropped DP from farther away",
        MaxLevel = 25,
        BaseCost = 3000,
        CostMultiplier = 1.40,
        BaseBonus = 2, -- +2 studs collection range per level
        BonusMultiplier = 1.0,
        Icon = "rbxassetid://magnet_icon",
        UnlockRequirement = {Level = 30, Zone = "Library"},

        -- Level 1: 3,000 DP (+2 studs)
        -- Level 10: 87,169 DP (+20 studs)
        -- Level 25: 75.2 million DP (+50 studs)
    },

    ComboMaster = {
        Name = "Combo Master",
        Description = "Extends combo timer and increases combo bonuses",
        MaxLevel = 50,
        BaseCost = 10000,
        CostMultiplier = 1.25,
        BaseBonus = 0.1, -- +0.1 seconds combo time, +2% combo bonus per level
        BonusMultiplier = 1.0,
        Icon = "rbxassetid://combo_icon",
        UnlockRequirement = {Level = 35, Zone = "PrincipalsOffice"},

        -- Level 1: 10,000 DP
        -- Level 25: 2.64 million DP
        -- Level 50: 7.06 billion DP
    },

    OfflineEarnings = {
        Name = "Offline Earnings",
        Description = "Earn DP while offline (% of auto-destroy rate)",
        MaxLevel = 30,
        BaseCost = 25000,
        CostMultiplier = 1.35,
        BaseBonus = 0.01, -- +1% of auto rate while offline per level
        BonusMultiplier = 1.0,
        Icon = "rbxassetid://offline_icon",
        UnlockRequirement = {Level = 40, Zone = "PrincipalsOffice"},

        -- Level 1: 25,000 DP (1%)
        -- Level 10: 513,532 DP (10%)
        -- Level 20: 20.2 million DP (20%)
        -- Level 30: 795 million DP (30% cap)
    }
}

-- Function to calculate upgrade cost
function HomeworkDestroyer.CalculateUpgradeCost(upgradeType, currentLevel)
    local upgrade = HomeworkDestroyer.StatUpgrades[upgradeType]
    if not upgrade then return nil end
    if currentLevel >= upgrade.MaxLevel then return nil end

    return math.floor(upgrade.BaseCost * (upgrade.CostMultiplier ^ currentLevel))
end

-- Function to calculate total bonus from upgrade
function HomeworkDestroyer.CalculateUpgradeBonus(upgradeType, level)
    local upgrade = HomeworkDestroyer.StatUpgrades[upgradeType]
    if not upgrade then return 0 end

    local totalBonus = 0
    for i = 1, level do
        totalBonus = totalBonus + (upgrade.BaseBonus * (upgrade.BonusMultiplier ^ (i - 1)))
    end
    return totalBonus
end

--[[
================================================================================
    SECTION 3: ZONE UNLOCKING SYSTEM
================================================================================
    Each zone has unique homework types, difficulties, and rewards.
    Zones must be unlocked in order.
]]--

HomeworkDestroyer.Zones = {
    [1] = {
        Name = "Classroom",
        DisplayName = "Mrs. Johnson's Classroom",
        UnlockCost = 0, -- Starting zone
        RequiredLevel = 1,
        RequiredPrestiges = 0,

        -- Zone Modifiers
        DPMultiplier = 1.0,
        HomeworkHP_Min = 10,
        HomeworkHP_Max = 100,
        SpawnRate = 2.0, -- seconds between spawns
        MaxHomework = 5, -- max on screen

        -- Homework Types in this zone
        HomeworkTypes = {
            {Name = "Math Worksheet", HP = 10, DP = 5, Rarity = "Common"},
            {Name = "Spelling Test", HP = 25, DP = 15, Rarity = "Common"},
            {Name = "Reading Assignment", HP = 50, DP = 35, Rarity = "Uncommon"},
            {Name = "Pop Quiz", HP = 100, DP = 80, Rarity = "Rare"}
        },

        -- Zone Boss
        Boss = {
            Name = "The Final Exam",
            HP = 1000,
            DPReward = 500,
            SpawnCondition = "Every 50 homework destroyed",
            SpecialAbility = "Regenerates 5% HP every 10 seconds"
        },

        -- Zone Completion Reward
        CompletionReward = {
            DP = 5000,
            UnlocksZone = "Library",
            BonusMultiplier = 1.05 -- Permanent 5% bonus
        },

        -- Requirements to "complete" zone
        CompletionRequirements = {
            HomeworkDestroyed = 500,
            BossDefeated = 3,
            TotalDPEarned = 10000
        }
    },

    [2] = {
        Name = "Library",
        DisplayName = "The Forbidden Library",
        UnlockCost = 10000,
        RequiredLevel = 15,
        RequiredPrestiges = 0,

        DPMultiplier = 2.5,
        HomeworkHP_Min = 100,
        HomeworkHP_Max = 1000,
        SpawnRate = 1.8,
        MaxHomework = 7,

        HomeworkTypes = {
            {Name = "Book Report", HP = 100, DP = 50, Rarity = "Common"},
            {Name = "Research Paper", HP = 250, DP = 150, Rarity = "Common"},
            {Name = "Bibliography", HP = 500, DP = 350, Rarity = "Uncommon"},
            {Name = "Thesis Draft", HP = 1000, DP = 800, Rarity = "Rare"},
            {Name = "Ancient Textbook", HP = 2000, DP = 2000, Rarity = "Epic"}
        },

        Boss = {
            Name = "The Encyclopedia of Doom",
            HP = 15000,
            DPReward = 10000,
            SpawnCondition = "Every 100 homework destroyed",
            SpecialAbility = "Spawns mini-homework (Footnotes) every 15 seconds"
        },

        CompletionReward = {
            DP = 100000,
            UnlocksZone = "PrincipalsOffice",
            BonusMultiplier = 1.10
        },

        CompletionRequirements = {
            HomeworkDestroyed = 2000,
            BossDefeated = 5,
            TotalDPEarned = 250000
        }
    },

    [3] = {
        Name = "PrincipalsOffice",
        DisplayName = "Principal's Office of Terror",
        UnlockCost = 500000,
        RequiredLevel = 35,
        RequiredPrestiges = 0,

        DPMultiplier = 6.0,
        HomeworkHP_Min = 1000,
        HomeworkHP_Max = 25000,
        SpawnRate = 1.5,
        MaxHomework = 10,

        HomeworkTypes = {
            {Name = "Detention Slip", HP = 1000, DP = 600, Rarity = "Common"},
            {Name = "Parent Conference Form", HP = 3000, DP = 2000, Rarity = "Common"},
            {Name = "Suspension Notice", HP = 8000, DP = 6000, Rarity = "Uncommon"},
            {Name = "Expulsion Papers", HP = 15000, DP = 12000, Rarity = "Rare"},
            {Name = "Permanent Record", HP = 25000, DP = 25000, Rarity = "Epic"},
            {Name = "The Dreaded Report Card", HP = 50000, DP = 60000, Rarity = "Legendary"}
        },

        Boss = {
            Name = "Principal Hardcastle",
            HP = 500000,
            DPReward = 250000,
            SpawnCondition = "Every 200 homework destroyed",
            SpecialAbility = "Calls for backup (spawns 5 detention slips), Immune to crits for 10s"
        },

        CompletionReward = {
            DP = 5000000,
            UnlocksZone = "SchoolBoardHQ",
            BonusMultiplier = 1.20
        },

        CompletionRequirements = {
            HomeworkDestroyed = 5000,
            BossDefeated = 10,
            TotalDPEarned = 10000000
        }
    },

    [4] = {
        Name = "SchoolBoardHQ",
        DisplayName = "School Board Headquarters",
        UnlockCost = 25000000,
        RequiredLevel = 60,
        RequiredPrestiges = 0,

        DPMultiplier = 15.0,
        HomeworkHP_Min = 25000,
        HomeworkHP_Max = 500000,
        SpawnRate = 1.2,
        MaxHomework = 12,

        HomeworkTypes = {
            {Name = "Budget Proposal", HP = 25000, DP = 20000, Rarity = "Common"},
            {Name = "Curriculum Change", HP = 75000, DP = 65000, Rarity = "Common"},
            {Name = "Standardized Test", HP = 150000, DP = 140000, Rarity = "Uncommon"},
            {Name = "Education Reform Bill", HP = 300000, DP = 300000, Rarity = "Rare"},
            {Name = "State Examination", HP = 500000, DP = 550000, Rarity = "Epic"},
            {Name = "National Standards Document", HP = 1000000, DP = 1200000, Rarity = "Legendary"},
            {Name = "The Core Curriculum", HP = 5000000, DP = 7500000, Rarity = "Mythic"}
        },

        Boss = {
            Name = "Superintendent Supreme",
            HP = 25000000,
            DPReward = 15000000,
            SpawnCondition = "Every 500 homework destroyed",
            SpecialAbility = "Policy Shield (75% damage reduction for 20s), Summons 3 Board Members"
        },

        CompletionReward = {
            DP = 500000000,
            UnlocksZone = "SecretZone", -- Post-prestige content
            BonusMultiplier = 1.50
        },

        CompletionRequirements = {
            HomeworkDestroyed = 10000,
            BossDefeated = 20,
            TotalDPEarned = 1000000000
        }
    },

    -- SECRET ZONES (Require Prestiges)
    [5] = {
        Name = "TeacherLounge",
        DisplayName = "The Teacher's Lounge (SECRET)",
        UnlockCost = 0, -- Unlocked via prestige
        RequiredLevel = 50,
        RequiredPrestiges = 3,

        DPMultiplier = 25.0,
        HomeworkHP_Min = 100000,
        HomeworkHP_Max = 2000000,
        SpawnRate = 1.0,
        MaxHomework = 8,

        HomeworkTypes = {
            {Name = "Lesson Plan", HP = 100000, DP = 100000, Rarity = "Uncommon"},
            {Name = "Grade Book", HP = 500000, DP = 550000, Rarity = "Rare"},
            {Name = "Teacher's Edition", HP = 1000000, DP = 1200000, Rarity = "Epic"},
            {Name = "Coffee-Stained Notes", HP = 2000000, DP = 2500000, Rarity = "Legendary"}
        },

        Boss = {
            Name = "The Department Head",
            HP = 100000000,
            DPReward = 75000000,
            SpawnCondition = "Every 250 homework destroyed",
            SpecialAbility = "Staff Meeting (all homework gains shields for 15s)"
        }
    },

    [6] = {
        Name = "EducationDimension",
        DisplayName = "The Education Dimension (MYTHIC)",
        UnlockCost = 0,
        RequiredLevel = 100,
        RequiredPrestiges = 10,

        DPMultiplier = 100.0,
        HomeworkHP_Min = 5000000,
        HomeworkHP_Max = 100000000,
        SpawnRate = 0.8,
        MaxHomework = 15,

        HomeworkTypes = {
            {Name = "Dimensional Worksheet", HP = 5000000, DP = 6000000, Rarity = "Epic"},
            {Name = "Cosmic Essay", HP = 25000000, DP = 35000000, Rarity = "Legendary"},
            {Name = "Reality-Bending Exam", HP = 75000000, DP = 100000000, Rarity = "Mythic"},
            {Name = "The Homework Singularity", HP = 100000000, DP = 150000000, Rarity = "Mythic"}
        },

        Boss = {
            Name = "The Homework God",
            HP = 10000000000, -- 10 billion
            DPReward = 5000000000,
            SpawnCondition = "Every 1000 homework destroyed",
            SpecialAbility = "Creates homework clones, Time manipulation (slows player clicks)"
        }
    }
}

--[[
================================================================================
    SECTION 4: REBIRTH/PRESTIGE SYSTEM
================================================================================
    Prestige resets progress but grants permanent bonuses and Prestige Stars.
]]--

HomeworkDestroyer.PrestigeSystem = {
    -- Base requirement to prestige
    BaseRequirement = 1000000000, -- 1 billion DP lifetime earned
    RequirementMultiplier = 2.5, -- Each prestige requires 2.5x more

    -- Prestige Stars earned per prestige
    BaseStarsEarned = 1,
    StarsPerExtraRequirement = 0.5, -- +0.5 stars per 50% over requirement

    -- What gets reset on prestige
    ResetOnPrestige = {
        "CurrentDP",
        "CurrentLevel", -- Reset to 1
        "AllStatUpgrades", -- Reset to 0
        "ToolsOwned", -- Keep only starting tool
        "ZoneProgress", -- Reset to Classroom
        "Achievements_Temporary" -- Some achievements reset
    },

    -- What is KEPT on prestige
    KeptOnPrestige = {
        "PrestigeStars",
        "PrestigeCount",
        "PrestigeUpgrades",
        "LifetimeStatistics",
        "PermanentAchievements",
        "MythicTools" -- Tools bought with Prestige Stars
    },

    -- Prestige Bonuses (automatic per prestige)
    AutomaticBonuses = {
        DPMultiplier = 0.10, -- +10% DP per prestige
        ClickPowerMultiplier = 0.05, -- +5% click power per prestige
        StartingDP = 1000, -- +1000 starting DP per prestige
        StartingLevel = 0.5 -- +0.5 starting levels per prestige (rounded down)
    },

    -- Prestige requirements table
    PrestigeRequirements = {
        [1] = {LifetimeDP = 1000000000, StarsEarned = 1}, -- 1B
        [2] = {LifetimeDP = 2500000000, StarsEarned = 2}, -- 2.5B
        [3] = {LifetimeDP = 6250000000, StarsEarned = 3}, -- 6.25B
        [4] = {LifetimeDP = 15625000000, StarsEarned = 4}, -- 15.6B
        [5] = {LifetimeDP = 39062500000, StarsEarned = 6}, -- 39B (bonus stars!)
        [6] = {LifetimeDP = 97656250000, StarsEarned = 7}, -- 97.6B
        [7] = {LifetimeDP = 244140625000, StarsEarned = 8}, -- 244B
        [8] = {LifetimeDP = 610351562500, StarsEarned = 10}, -- 610B (bonus!)
        [9] = {LifetimeDP = 1525878906250, StarsEarned = 12}, -- 1.5T
        [10] = {LifetimeDP = 3814697265625, StarsEarned = 15}, -- 3.8T (big bonus!)
        -- Pattern continues with 2.5x multiplier
    }
}

-- Prestige Shop (Spend Prestige Stars here)
HomeworkDestroyer.PrestigeShop = {
    -- PERMANENT UPGRADES
    Upgrades = {
        {
            Name = "Eternal Click Power",
            Description = "Permanently increases base click damage",
            MaxLevel = 50,
            CostPerLevel = {1, 1, 2, 2, 3, 3, 4, 4, 5, 5}, -- Repeating pattern
            BonusPerLevel = 0.10, -- +10% per level
            TotalBonus = 5.0 -- +500% at max level
        },
        {
            Name = "Infinite Wisdom",
            Description = "Start each run with bonus levels",
            MaxLevel = 25,
            CostPerLevel = {2, 2, 3, 3, 4, 5, 5, 6, 7, 8},
            BonusPerLevel = 2, -- +2 starting levels
            TotalBonus = 50 -- Start at level 50
        },
        {
            Name = "Wealthy Scholar",
            Description = "Start each run with bonus DP",
            MaxLevel = 30,
            CostPerLevel = {1, 1, 1, 2, 2, 2, 3, 3, 3, 4},
            BonusPerLevel = 10000, -- +10,000 starting DP
            TotalBonus = 300000 -- Start with 300k DP
        },
        {
            Name = "Auto-Mastery",
            Description = "Permanent auto-destroy DPS bonus",
            MaxLevel = 40,
            CostPerLevel = {2, 2, 3, 3, 4, 4, 5, 5, 6, 6},
            BonusPerLevel = 0.15, -- +15% auto-destroy
            TotalBonus = 6.0 -- +600% auto-destroy
        },
        {
            Name = "Lucky Stars",
            Description = "Permanent luck and crit chance bonus",
            MaxLevel = 20,
            CostPerLevel = {3, 3, 4, 5, 6, 7, 8, 9, 10, 12},
            BonusPerLevel = 0.02, -- +2% luck and crit
            TotalBonus = 0.40 -- +40% at max
        },
        {
            Name = "Zone Skipper",
            Description = "Unlock zones at lower level requirements",
            MaxLevel = 10,
            CostPerLevel = {5, 7, 10, 15, 20, 25, 30, 40, 50, 75},
            BonusPerLevel = 0.10, -- -10% level requirement per level
            TotalBonus = 1.0 -- -100% (instant zone unlocks!)
        },
        {
            Name = "Prestige Momentum",
            Description = "Increases Prestige Stars earned per prestige",
            MaxLevel = 15,
            CostPerLevel = {10, 15, 20, 30, 45, 60, 80, 100, 125, 150},
            BonusPerLevel = 0.20, -- +20% stars per prestige
            TotalBonus = 3.0 -- +300% stars
        },
        {
            Name = "Offline Fortune",
            Description = "Earn Prestige Stars while offline (very slowly)",
            MaxLevel = 5,
            CostPerLevel = {25, 50, 100, 200, 500},
            BonusPerLevel = 0.01, -- +0.01 stars per hour offline
            TotalBonus = 0.05 -- 0.05 stars per hour (1.2 per day)
        }
    },

    -- UNLOCKABLES
    Unlockables = {
        {
            Name = "Teacher's Lounge Access",
            Description = "Unlocks the secret Teacher's Lounge zone",
            Cost = 25,
            RequiredPrestiges = 3,
            Type = "Zone"
        },
        {
            Name = "Education Dimension Portal",
            Description = "Unlocks the mythic Education Dimension",
            Cost = 100,
            RequiredPrestiges = 10,
            Type = "Zone"
        },
        {
            Name = "Time Warp Ability",
            Description = "Active skill: 2x speed for 30 seconds (5 min cooldown)",
            Cost = 15,
            RequiredPrestiges = 2,
            Type = "Ability"
        },
        {
            Name = "Homework Vacuum",
            Description = "Active skill: Pulls all homework to cursor (2 min cooldown)",
            Cost = 30,
            RequiredPrestiges = 4,
            Type = "Ability"
        },
        {
            Name = "Nuclear Option",
            Description = "Active skill: Destroys 50% of all homework HP (10 min cooldown)",
            Cost = 75,
            RequiredPrestiges = 7,
            Type = "Ability"
        },
        {
            Name = "Golden Eraser Converter",
            Description = "Convert Prestige Stars to Golden Erasers (1:10 ratio)",
            Cost = 50,
            RequiredPrestiges = 5,
            Type = "Feature"
        }
    }
}

--[[
================================================================================
    SECTION 5: PLAYER LEVEL AND RANK SYSTEM
================================================================================
    Players gain XP from destroying homework and completing objectives.
    Levels unlock new features and provide stat bonuses.
]]--

HomeworkDestroyer.LevelSystem = {
    MaxLevel = 500,

    -- XP Formula: RequiredXP = BaseXP * (Level ^ Exponent)
    BaseXP = 100,
    Exponent = 1.5,

    -- XP Sources
    XPSources = {
        HomeworkDestroyed = 1, -- Base XP per homework
        HomeworkRarityMultiplier = { -- Multiplied by rarity
            Common = 1,
            Uncommon = 2,
            Rare = 5,
            Epic = 15,
            Legendary = 50,
            Mythic = 200
        },
        BossDefeated = 500,
        ZoneCompleted = 10000,
        AchievementUnlocked = 250,
        DailyLogin = 1000
    },

    -- Level Requirements (examples)
    LevelRequirements = {
        [1] = 0,
        [2] = 100,
        [5] = 559,
        [10] = 3162,
        [15] = 8714,
        [20] = 17889,
        [25] = 31250,
        [30] = 49295,
        [40] = 101193,
        [50] = 176777,
        [75] = 487139,
        [100] = 1000000,
        [150] = 2755676,
        [200] = 5656854,
        [250] = 9882117,
        [300] = 15588457,
        [400] = 31622776,
        [500] = 55901699
    },

    -- Bonuses per level
    BonusesPerLevel = {
        ClickPower = 0.5, -- +0.5% per level
        AutoDestroy = 0.3, -- +0.3% per level
        DPEarned = 0.2, -- +0.2% per level
        MaxHP = 1 -- +1 max combo per level
    },

    -- Milestone Rewards
    Milestones = {
        [5] = {Reward = "Unlock Auto-Destroy feature", DP = 500},
        [10] = {Reward = "Unlock Auto-Destroy Power upgrade", DP = 2000},
        [15] = {Reward = "Unlock Library zone access", DP = 5000},
        [20] = {Reward = "Unlock Destruction Multiplier upgrade", DP = 15000},
        [25] = {Reward = "Unlock Luck Boost upgrade", DP = 50000},
        [30] = {Reward = "Unlock Homework Magnet upgrade", DP = 100000},
        [35] = {Reward = "Unlock Principal's Office zone access", DP = 250000},
        [40] = {Reward = "Unlock Offline Earnings upgrade", DP = 500000},
        [50] = {Reward = "Unlock first Prestige", DP = 2500000},
        [60] = {Reward = "Unlock School Board HQ zone access", DP = 10000000},
        [75] = {Reward = "Unlock Mythic tool slot", DP = 50000000},
        [100] = {Reward = "Unlock Title: Homework Destroyer", DP = 500000000},
        [150] = {Reward = "Unlock Golden skin for tools", DP = 5000000000},
        [200] = {Reward = "Unlock Title: Education's Nemesis", DP = 50000000000},
        [250] = {Reward = "Unlock Celestial tool effects", DP = 500000000000},
        [300] = {Reward = "Unlock Title: The Unteachable", DP = 5000000000000},
        [400] = {Reward = "Unlock Cosmic skin set", DP = 100000000000000},
        [500] = {Reward = "Unlock Title: GOD OF DESTRUCTION", DP = 1000000000000000}
    }
}

-- Rank System (Titles based on total prestiges and level)
HomeworkDestroyer.Ranks = {
    -- Tier 1: No Prestige
    {Name = "Student", MinLevel = 1, MinPrestiges = 0, Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Troublemaker", MinLevel = 10, MinPrestiges = 0, Color = Color3.fromRGB(200, 200, 200)},
    {Name = "Class Clown", MinLevel = 25, MinPrestiges = 0, Color = Color3.fromRGB(255, 200, 100)},
    {Name = "Rebel", MinLevel = 50, MinPrestiges = 0, Color = Color3.fromRGB(255, 150, 50)},

    -- Tier 2: 1-4 Prestiges
    {Name = "Homework Hater", MinLevel = 1, MinPrestiges = 1, Color = Color3.fromRGB(100, 200, 255)},
    {Name = "Assignment Assassin", MinLevel = 25, MinPrestiges = 1, Color = Color3.fromRGB(50, 150, 255)},
    {Name = "Paper Shredder", MinLevel = 50, MinPrestiges = 2, Color = Color3.fromRGB(0, 100, 255)},
    {Name = "Education Eliminator", MinLevel = 75, MinPrestiges = 3, Color = Color3.fromRGB(100, 50, 255)},

    -- Tier 3: 5-9 Prestiges
    {Name = "Scholarly Slayer", MinLevel = 1, MinPrestiges = 5, Color = Color3.fromRGB(200, 100, 255)},
    {Name = "Academic Annihilator", MinLevel = 50, MinPrestiges = 5, Color = Color3.fromRGB(255, 50, 200)},
    {Name = "Curriculum Crusher", MinLevel = 100, MinPrestiges = 7, Color = Color3.fromRGB(255, 0, 150)},

    -- Tier 4: 10+ Prestiges
    {Name = "Destroyer of Knowledge", MinLevel = 1, MinPrestiges = 10, Color = Color3.fromRGB(255, 215, 0)},
    {Name = "Bane of Teachers", MinLevel = 100, MinPrestiges = 15, Color = Color3.fromRGB(255, 100, 0)},
    {Name = "Nightmare of Schools", MinLevel = 200, MinPrestiges = 25, Color = Color3.fromRGB(255, 0, 0)},
    {Name = "GOD OF DESTRUCTION", MinLevel = 500, MinPrestiges = 50, Color = Color3.fromRGB(255, 0, 255)}
}

--[[
================================================================================
    SECTION 6: ACHIEVEMENT AND BADGE SYSTEM
================================================================================
    Achievements provide one-time rewards and track player milestones.
]]--

HomeworkDestroyer.Achievements = {
    -- DESTRUCTION ACHIEVEMENTS
    Destruction = {
        {
            Name = "First Steps",
            Description = "Destroy your first homework",
            Requirement = {HomeworkDestroyed = 1},
            Reward = {DP = 10, XP = 50},
            Rarity = "Common"
        },
        {
            Name = "Getting Started",
            Description = "Destroy 100 homework",
            Requirement = {HomeworkDestroyed = 100},
            Reward = {DP = 500, XP = 250},
            Rarity = "Common"
        },
        {
            Name = "Homework Hunter",
            Description = "Destroy 1,000 homework",
            Requirement = {HomeworkDestroyed = 1000},
            Reward = {DP = 5000, XP = 1000},
            Rarity = "Uncommon"
        },
        {
            Name = "Assignment Annihilator",
            Description = "Destroy 10,000 homework",
            Requirement = {HomeworkDestroyed = 10000},
            Reward = {DP = 100000, XP = 5000},
            Rarity = "Rare"
        },
        {
            Name = "Paper Pulverizer",
            Description = "Destroy 100,000 homework",
            Requirement = {HomeworkDestroyed = 100000},
            Reward = {DP = 2500000, XP = 25000},
            Rarity = "Epic"
        },
        {
            Name = "Education Ender",
            Description = "Destroy 1,000,000 homework",
            Requirement = {HomeworkDestroyed = 1000000},
            Reward = {DP = 100000000, XP = 100000},
            Rarity = "Legendary"
        },
        {
            Name = "The Homework Apocalypse",
            Description = "Destroy 10,000,000 homework",
            Requirement = {HomeworkDestroyed = 10000000},
            Reward = {DP = 10000000000, XP = 1000000, PrestigeStars = 10},
            Rarity = "Mythic"
        }
    },

    -- CLICK ACHIEVEMENTS
    Clicking = {
        {
            Name = "Clicker Novice",
            Description = "Click 100 times",
            Requirement = {TotalClicks = 100},
            Reward = {DP = 25, XP = 25},
            Rarity = "Common"
        },
        {
            Name = "Finger Workout",
            Description = "Click 10,000 times",
            Requirement = {TotalClicks = 10000},
            Reward = {DP = 10000, XP = 2500},
            Rarity = "Uncommon"
        },
        {
            Name = "Carpal Tunnel Champion",
            Description = "Click 1,000,000 times",
            Requirement = {TotalClicks = 1000000},
            Reward = {DP = 5000000, XP = 50000},
            Rarity = "Epic"
        },
        {
            Name = "The Unstoppable Clicker",
            Description = "Click 100,000,000 times",
            Requirement = {TotalClicks = 100000000},
            Reward = {DP = 5000000000, XP = 500000, PrestigeStars = 5},
            Rarity = "Legendary"
        }
    },

    -- DAMAGE ACHIEVEMENTS
    Damage = {
        {
            Name = "Baby Steps",
            Description = "Deal 1,000 total damage",
            Requirement = {TotalDamage = 1000},
            Reward = {DP = 100, XP = 100},
            Rarity = "Common"
        },
        {
            Name = "Getting Stronger",
            Description = "Deal 100,000 total damage",
            Requirement = {TotalDamage = 100000},
            Reward = {DP = 25000, XP = 5000},
            Rarity = "Uncommon"
        },
        {
            Name = "Damage Dealer",
            Description = "Deal 10,000,000 total damage",
            Requirement = {TotalDamage = 10000000},
            Reward = {DP = 2500000, XP = 50000},
            Rarity = "Rare"
        },
        {
            Name = "Destruction Incarnate",
            Description = "Deal 1,000,000,000 total damage",
            Requirement = {TotalDamage = 1000000000},
            Reward = {DP = 500000000, XP = 250000},
            Rarity = "Epic"
        },
        {
            Name = "One Shot Wonder",
            Description = "Deal 1,000,000 damage in a single click",
            Requirement = {SingleClickDamage = 1000000},
            Reward = {DP = 10000000, XP = 25000},
            Rarity = "Rare"
        },
        {
            Name = "Critical Master",
            Description = "Land 10,000 critical hits",
            Requirement = {CriticalHits = 10000},
            Reward = {DP = 1000000, XP = 15000},
            Rarity = "Rare"
        }
    },

    -- CURRENCY ACHIEVEMENTS
    Currency = {
        {
            Name = "Pocket Change",
            Description = "Earn 10,000 total DP",
            Requirement = {LifetimeDP = 10000},
            Reward = {DP = 1000, XP = 500},
            Rarity = "Common"
        },
        {
            Name = "Savings Account",
            Description = "Earn 1,000,000 total DP",
            Requirement = {LifetimeDP = 1000000},
            Reward = {DP = 100000, XP = 10000},
            Rarity = "Uncommon"
        },
        {
            Name = "Millionaire",
            Description = "Have 10,000,000 DP at once",
            Requirement = {CurrentDP = 10000000},
            Reward = {DP = 1000000, XP = 25000},
            Rarity = "Rare"
        },
        {
            Name = "Billionaire",
            Description = "Have 1,000,000,000 DP at once",
            Requirement = {CurrentDP = 1000000000},
            Reward = {DP = 100000000, XP = 100000},
            Rarity = "Epic"
        },
        {
            Name = "Trillionaire",
            Description = "Have 1,000,000,000,000 DP at once",
            Requirement = {CurrentDP = 1000000000000},
            Reward = {DP = 100000000000, XP = 500000, PrestigeStars = 3},
            Rarity = "Legendary"
        }
    },

    -- PROGRESSION ACHIEVEMENTS
    Progression = {
        {
            Name = "Level Up!",
            Description = "Reach level 10",
            Requirement = {Level = 10},
            Reward = {DP = 2500, XP = 1000},
            Rarity = "Common"
        },
        {
            Name = "Rising Star",
            Description = "Reach level 50",
            Requirement = {Level = 50},
            Reward = {DP = 500000, XP = 25000},
            Rarity = "Uncommon"
        },
        {
            Name = "Experienced Destroyer",
            Description = "Reach level 100",
            Requirement = {Level = 100},
            Reward = {DP = 25000000, XP = 100000},
            Rarity = "Rare"
        },
        {
            Name = "Legendary Status",
            Description = "Reach level 250",
            Requirement = {Level = 250},
            Reward = {DP = 5000000000, XP = 500000},
            Rarity = "Epic"
        },
        {
            Name = "Maximum Power",
            Description = "Reach level 500 (max)",
            Requirement = {Level = 500},
            Reward = {DP = 1000000000000, XP = 0, PrestigeStars = 25},
            Rarity = "Mythic"
        }
    },

    -- ZONE ACHIEVEMENTS
    Zones = {
        {
            Name = "Library Card",
            Description = "Unlock the Library zone",
            Requirement = {ZoneUnlocked = "Library"},
            Reward = {DP = 15000, XP = 5000},
            Rarity = "Uncommon"
        },
        {
            Name = "Sent to the Office",
            Description = "Unlock Principal's Office zone",
            Requirement = {ZoneUnlocked = "PrincipalsOffice"},
            Reward = {DP = 1000000, XP = 25000},
            Rarity = "Rare"
        },
        {
            Name = "Going to the Top",
            Description = "Unlock School Board HQ zone",
            Requirement = {ZoneUnlocked = "SchoolBoardHQ"},
            Reward = {DP = 50000000, XP = 100000},
            Rarity = "Epic"
        },
        {
            Name = "Secret Discovered",
            Description = "Unlock Teacher's Lounge secret zone",
            Requirement = {ZoneUnlocked = "TeacherLounge"},
            Reward = {DP = 500000000, XP = 250000, PrestigeStars = 5},
            Rarity = "Legendary"
        },
        {
            Name = "Dimension Hopper",
            Description = "Unlock the Education Dimension",
            Requirement = {ZoneUnlocked = "EducationDimension"},
            Reward = {DP = 50000000000, XP = 1000000, PrestigeStars = 25},
            Rarity = "Mythic"
        }
    },

    -- BOSS ACHIEVEMENTS
    Bosses = {
        {
            Name = "Boss Slayer",
            Description = "Defeat your first boss",
            Requirement = {BossesDefeated = 1},
            Reward = {DP = 1000, XP = 500},
            Rarity = "Common"
        },
        {
            Name = "Boss Hunter",
            Description = "Defeat 10 bosses",
            Requirement = {BossesDefeated = 10},
            Reward = {DP = 50000, XP = 10000},
            Rarity = "Uncommon"
        },
        {
            Name = "Boss Dominator",
            Description = "Defeat 100 bosses",
            Requirement = {BossesDefeated = 100},
            Reward = {DP = 10000000, XP = 100000},
            Rarity = "Rare"
        },
        {
            Name = "Principal Punisher",
            Description = "Defeat Principal Hardcastle",
            Requirement = {SpecificBoss = "Principal Hardcastle"},
            Reward = {DP = 1000000, XP = 50000},
            Rarity = "Rare"
        },
        {
            Name = "Superintendent Slayer",
            Description = "Defeat Superintendent Supreme",
            Requirement = {SpecificBoss = "Superintendent Supreme"},
            Reward = {DP = 50000000, XP = 250000},
            Rarity = "Epic"
        },
        {
            Name = "Godslayer",
            Description = "Defeat The Homework God",
            Requirement = {SpecificBoss = "The Homework God"},
            Reward = {DP = 100000000000, XP = 5000000, PrestigeStars = 50},
            Rarity = "Mythic"
        }
    },

    -- PRESTIGE ACHIEVEMENTS
    Prestige = {
        {
            Name = "Born Again",
            Description = "Prestige for the first time",
            Requirement = {Prestiges = 1},
            Reward = {PrestigeStars = 2, XP = 25000},
            Rarity = "Uncommon"
        },
        {
            Name = "Prestige Veteran",
            Description = "Prestige 5 times",
            Requirement = {Prestiges = 5},
            Reward = {PrestigeStars = 10, XP = 100000},
            Rarity = "Rare"
        },
        {
            Name = "Prestige Master",
            Description = "Prestige 15 times",
            Requirement = {Prestiges = 15},
            Reward = {PrestigeStars = 50, XP = 500000},
            Rarity = "Epic"
        },
        {
            Name = "Eternal Destroyer",
            Description = "Prestige 50 times",
            Requirement = {Prestiges = 50},
            Reward = {PrestigeStars = 250, XP = 2500000},
            Rarity = "Legendary"
        },
        {
            Name = "Prestige Legend",
            Description = "Prestige 100 times",
            Requirement = {Prestiges = 100},
            Reward = {PrestigeStars = 1000, XP = 10000000},
            Rarity = "Mythic"
        }
    },

    -- TOOL ACHIEVEMENTS
    Tools = {
        {
            Name = "Tool Collector",
            Description = "Own 5 different tools",
            Requirement = {ToolsOwned = 5},
            Reward = {DP = 25000, XP = 5000},
            Rarity = "Common"
        },
        {
            Name = "Arsenal Builder",
            Description = "Own 10 different tools",
            Requirement = {ToolsOwned = 10},
            Reward = {DP = 5000000, XP = 50000},
            Rarity = "Rare"
        },
        {
            Name = "Mythic Wielder",
            Description = "Own a Mythic tier tool",
            Requirement = {MythicTools = 1},
            Reward = {DP = 100000000, XP = 250000, PrestigeStars = 10},
            Rarity = "Legendary"
        },
        {
            Name = "Complete Arsenal",
            Description = "Own all tools in the game",
            Requirement = {ToolsOwned = 16},
            Reward = {DP = 10000000000, XP = 1000000, PrestigeStars = 100},
            Rarity = "Mythic"
        }
    },

    -- COMBO ACHIEVEMENTS
    Combos = {
        {
            Name = "Combo Starter",
            Description = "Reach a 10x combo",
            Requirement = {MaxCombo = 10},
            Reward = {DP = 500, XP = 250},
            Rarity = "Common"
        },
        {
            Name = "Combo Master",
            Description = "Reach a 50x combo",
            Requirement = {MaxCombo = 50},
            Reward = {DP = 50000, XP = 10000},
            Rarity = "Uncommon"
        },
        {
            Name = "Combo Legend",
            Description = "Reach a 200x combo",
            Requirement = {MaxCombo = 200},
            Reward = {DP = 5000000, XP = 100000},
            Rarity = "Rare"
        },
        {
            Name = "Combo God",
            Description = "Reach a 1000x combo",
            Requirement = {MaxCombo = 1000},
            Reward = {DP = 1000000000, XP = 500000, PrestigeStars = 15},
            Rarity = "Legendary"
        }
    },

    -- SPECIAL/SECRET ACHIEVEMENTS
    Secret = {
        {
            Name = "Speed Demon",
            Description = "Destroy 100 homework in under 60 seconds",
            Requirement = {Special = "SpeedRun100"},
            Reward = {DP = 100000, XP = 25000},
            Rarity = "Rare",
            Hidden = true
        },
        {
            Name = "No Tool Needed",
            Description = "Defeat a boss using only the Bare Hand tool",
            Requirement = {Special = "BareHandBoss"},
            Reward = {DP = 500000, XP = 50000},
            Rarity = "Epic",
            Hidden = true
        },
        {
            Name = "Night Owl",
            Description = "Play for 1 hour between midnight and 5 AM",
            Requirement = {Special = "NightOwl"},
            Reward = {DP = 25000, XP = 10000},
            Rarity = "Uncommon",
            Hidden = true
        },
        {
            Name = "Patient Player",
            Description = "Wait 24 hours to collect offline earnings",
            Requirement = {Special = "PatientPlayer"},
            Reward = {DP = 1000000, XP = 50000},
            Rarity = "Rare",
            Hidden = true
        },
        {
            Name = "The One",
            Description = "Deal exactly 1,111,111 damage in total",
            Requirement = {Special = "TheOne"},
            Reward = {DP = 1111111, XP = 111111, PrestigeStars = 1},
            Rarity = "Legendary",
            Hidden = true
        }
    }
}

--[[
================================================================================
    SECTION 7: COMBO AND MULTIPLIER SYSTEM
================================================================================
    Active gameplay rewards through combo chains.
]]--

HomeworkDestroyer.ComboSystem = {
    -- Base combo settings
    BaseComboTime = 3.0, -- Seconds to maintain combo
    MaxComboMultiplier = 100.0, -- Cap at 100x

    -- Combo tiers and bonuses
    ComboTiers = {
        {MinCombo = 1, Name = "x1", DPMultiplier = 1.0, Color = Color3.fromRGB(255, 255, 255)},
        {MinCombo = 5, Name = "x5 NICE!", DPMultiplier = 1.2, Color = Color3.fromRGB(200, 255, 200)},
        {MinCombo = 10, Name = "x10 GREAT!", DPMultiplier = 1.5, Color = Color3.fromRGB(150, 255, 150)},
        {MinCombo = 25, Name = "x25 AWESOME!", DPMultiplier = 2.0, Color = Color3.fromRGB(100, 255, 255)},
        {MinCombo = 50, Name = "x50 INCREDIBLE!", DPMultiplier = 3.0, Color = Color3.fromRGB(100, 200, 255)},
        {MinCombo = 100, Name = "x100 LEGENDARY!", DPMultiplier = 5.0, Color = Color3.fromRGB(255, 200, 100)},
        {MinCombo = 250, Name = "x250 MYTHIC!", DPMultiplier = 10.0, Color = Color3.fromRGB(255, 150, 50)},
        {MinCombo = 500, Name = "x500 GODLIKE!", DPMultiplier = 25.0, Color = Color3.fromRGB(255, 100, 100)},
        {MinCombo = 1000, Name = "x1000 UNSTOPPABLE!", DPMultiplier = 100.0, Color = Color3.fromRGB(255, 50, 255)}
    }
}

--[[
================================================================================
    SECTION 8: DAILY/WEEKLY SYSTEMS
================================================================================
    Engagement systems to keep players coming back.
]]--

HomeworkDestroyer.DailySystem = {
    -- Daily Login Rewards (7-day cycle)
    LoginRewards = {
        [1] = {DP = 1000, XP = 500},
        [2] = {DP = 2500, XP = 750},
        [3] = {DP = 5000, XP = 1000},
        [4] = {DP = 10000, XP = 1500},
        [5] = {DP = 25000, XP = 2500},
        [6] = {DP = 50000, XP = 5000},
        [7] = {DP = 100000, XP = 10000, PrestigeStars = 1} -- Weekly bonus
    },

    -- Daily Challenges (randomized)
    DailyChallenges = {
        {
            Name = "Homework Hunter",
            Description = "Destroy 500 homework today",
            Requirement = 500,
            Type = "HomeworkDestroyed",
            Reward = {DP = 25000, XP = 5000}
        },
        {
            Name = "Click Master",
            Description = "Click 2,000 times today",
            Requirement = 2000,
            Type = "Clicks",
            Reward = {DP = 15000, XP = 3000}
        },
        {
            Name = "Damage Dealer",
            Description = "Deal 1,000,000 damage today",
            Requirement = 1000000,
            Type = "Damage",
            Reward = {DP = 50000, XP = 10000}
        },
        {
            Name = "Combo King",
            Description = "Reach a 100x combo",
            Requirement = 100,
            Type = "MaxCombo",
            Reward = {DP = 75000, XP = 15000}
        },
        {
            Name = "Boss Slayer",
            Description = "Defeat 3 bosses today",
            Requirement = 3,
            Type = "BossesDefeated",
            Reward = {DP = 100000, XP = 25000}
        }
    },

    -- Weekly Challenges
    WeeklyChallenges = {
        {
            Name = "Weekly Warrior",
            Description = "Destroy 10,000 homework this week",
            Requirement = 10000,
            Type = "HomeworkDestroyed",
            Reward = {DP = 500000, XP = 100000, PrestigeStars = 2}
        },
        {
            Name = "Dedication",
            Description = "Login 5 days this week",
            Requirement = 5,
            Type = "DaysLoggedIn",
            Reward = {DP = 250000, XP = 50000, PrestigeStars = 1}
        }
    }
}

--[[
================================================================================
    SECTION 9: UPGRADE TREE VISUALIZATION
================================================================================
    How upgrades connect and unlock.
]]--

HomeworkDestroyer.UpgradeTree = {
    --[[
    UPGRADE TREE STRUCTURE:

    Level 1 (Start)
    │
    ├── Click Power (Always available)
    │   └── Critical Chance (Level 15)
    │       └── Critical Damage (Level 20)
    │
    ├── Click Speed (Level 5)
    │   └── Combo Master (Level 35)
    │
    └── Auto-Destroy Power (Level 10)
        ├── Auto-Destroy Speed (Level 15)
        │   └── Offline Earnings (Level 40)
        │
        └── Destruction Multiplier (Level 20)
            └── Luck Boost (Level 25)
                └── Homework Magnet (Level 30)

    ZONE PROGRESSION:

    Classroom (Level 1) ──► Library (Level 15) ──► Principal's Office (Level 35) ──► School Board HQ (Level 60)
                                                                                            │
                                                                                            ▼
                                    Teacher's Lounge (Prestige 3) ◄─────────────────────────┘
                                            │
                                            ▼
                                    Education Dimension (Prestige 10)

    TOOL PROGRESSION:

    Bare Hand ──► Pencil ──► Eraser ──► Scissors
                                            │
    ┌───────────────────────────────────────┘
    │
    └──► Paper Shredder ──► Hole Puncher 3000 ──► Staple Remover of Doom
                                                            │
    ┌───────────────────────────────────────────────────────┘
    │
    └──► Flamethrower ──► Industrial Acid Spray ──► Mini Black Hole Generator
                                                                │
    ┌───────────────────────────────────────────────────────────┘
    │
    └──► Quantum Eraser ──► Anti-Homework Laser ──► Homework Annihilator 9000
                                                                │
                                                                ▼
                                                    [MYTHIC TOOLS - Prestige Required]
                                                    The Eraser of Legends (P5)
                                                    Cosmic Destroyer (P15)
                                                    The Assignment Ender (P50)
    ]]--

    UnlockOrder = {
        -- Format: {UpgradeName, RequiredLevel, RequiredUpgrade, RequiredZone}
        {"ClickPower", 1, nil, "Classroom"},
        {"ClickSpeed", 5, nil, "Classroom"},
        {"AutoDestroyPower", 10, nil, "Classroom"},
        {"AutoDestroySpeed", 15, "AutoDestroyPower", "Classroom"},
        {"CriticalChance", 15, "ClickPower", "Classroom"},
        {"CriticalDamage", 20, "CriticalChance", "Library"},
        {"DestructionMultiplier", 20, "AutoDestroyPower", "Library"},
        {"LuckBoost", 25, "DestructionMultiplier", "Library"},
        {"HomeworkMagnet", 30, "LuckBoost", "Library"},
        {"ComboMaster", 35, "ClickSpeed", "PrincipalsOffice"},
        {"OfflineEarnings", 40, "AutoDestroySpeed", "PrincipalsOffice"}
    }
}

--[[
================================================================================
    SECTION 10: BALANCE FORMULAS AND CALCULATIONS
================================================================================
    Core mathematical formulas for game balance.
]]--

HomeworkDestroyer.BalanceFormulas = {
    -- Homework HP scaling per zone
    -- HP = BaseHP * (1.5 ^ ZoneNumber) * (1 + 0.1 * RarityModifier)
    HomeworkHPFormula = function(baseHP, zoneNumber, rarityModifier)
        return math.floor(baseHP * (1.5 ^ zoneNumber) * (1 + 0.1 * rarityModifier))
    end,

    -- DP reward scaling
    -- DP = BaseDP * ZoneMultiplier * (1 + ComboMultiplier) * (1 + UpgradeMultiplier)
    DPRewardFormula = function(baseDP, zoneMultiplier, comboMultiplier, upgradeMultiplier)
        return math.floor(baseDP * zoneMultiplier * (1 + comboMultiplier) * (1 + upgradeMultiplier))
    end,

    -- Click damage calculation
    -- Damage = (BaseDamage + ToolDamage) * (1 + ClickPowerBonus) * (1 + PrestigeBonus) * CritMultiplier
    ClickDamageFormula = function(baseDamage, toolDamage, clickPowerBonus, prestigeBonus, isCrit, critMultiplier)
        local damage = (baseDamage + toolDamage) * (1 + clickPowerBonus) * (1 + prestigeBonus)
        if isCrit then
            damage = damage * critMultiplier
        end
        return math.floor(damage)
    end,

    -- Auto-destroy DPS calculation
    -- DPS = BaseAutoDPS * (1 + AutoPowerBonus) * (1 + PrestigeAutoBonus) * AutoSpeedMultiplier
    AutoDestroyDPSFormula = function(baseAutoDPS, autoPowerBonus, prestigeAutoBonus, autoSpeedMultiplier)
        return math.floor(baseAutoDPS * (1 + autoPowerBonus) * (1 + prestigeAutoBonus) * autoSpeedMultiplier)
    end,

    -- XP to level formula
    -- XP = BaseXP * (Level ^ 1.5)
    XPToLevelFormula = function(level)
        return math.floor(100 * (level ^ 1.5))
    end,

    -- Prestige requirement formula
    -- RequiredDP = BaseRequirement * (2.5 ^ PrestigeCount)
    PrestigeRequirementFormula = function(prestigeCount)
        return math.floor(1000000000 * (2.5 ^ prestigeCount))
    end
}

--[[
================================================================================
    SECTION 11: EXAMPLE PLAYER PROGRESSION
================================================================================
    Sample progression timeline for balancing reference.
]]--

HomeworkDestroyer.ExampleProgression = {
    --[[
    EARLY GAME (0-30 minutes):
    - Start with Bare Hand, 1 damage per click
    - Destroy Common homework (10-25 HP) for 5-15 DP each
    - Buy Pencil (50 DP) around 5 minutes
    - Reach Level 5, unlock Click Speed
    - Buy Eraser (250 DP) around 15 minutes
    - Reach Level 10, unlock Auto-Destroy
    - Buy first Auto-Destroy levels
    - Unlock Scissors (1,000 DP) around 30 minutes

    MID GAME (30 min - 2 hours):
    - Reach Level 15, unlock Library zone
    - Library costs 10,000 DP to enter
    - Farm Library for 2.5x DP multiplier
    - Buy Paper Shredder (5,000 DP)
    - Reach Level 25, unlock Luck Boost
    - Progress through Library zone
    - Buy Hole Puncher 3000 (15,000 DP)
    - Reach Level 35, unlock Principal's Office

    LATE GAME (2-5 hours):
    - Enter Principal's Office (500,000 DP)
    - Farm 6x DP multiplier zone
    - Buy Flamethrower (200,000 DP)
    - Reach Level 50, unlock first Prestige option
    - Continue farming until 1 billion DP lifetime
    - First Prestige! Earn 1 Prestige Star

    POST-PRESTIGE (5+ hours):
    - Restart with bonuses from Prestige
    - Progress faster with +10% DP, +5% click power
    - Unlock Prestige Shop upgrades
    - Work toward Prestige 5 for Teacher's Lounge
    - Unlock Mythic tools with Prestige Stars
    - Aim for Prestige 10 for Education Dimension

    ENDGAME (20+ hours):
    - Multiple Prestiges completed
    - Farming Education Dimension
    - Working toward defeating The Homework God
    - Collecting all achievements
    - Reaching Level 500
    - Collecting all Mythic tools
    ]]--
}

--[[
================================================================================
    SECTION 12: CONFIGURATION CONSTANTS
================================================================================
    Easy-to-modify constants for game tuning.
]]--

HomeworkDestroyer.Config = {
    -- Starting values
    STARTING_DP = 0,
    STARTING_LEVEL = 1,
    STARTING_TOOL = "Bare Hand",
    STARTING_ZONE = "Classroom",

    -- Click settings
    BASE_CLICK_COOLDOWN = 0.5, -- seconds
    MIN_CLICK_COOLDOWN = 0.1, -- seconds (with max upgrades)

    -- Auto-destroy settings
    BASE_AUTO_INTERVAL = 1.0, -- seconds
    MIN_AUTO_INTERVAL = 0.2, -- seconds (with max upgrades)

    -- Combo settings
    COMBO_BASE_TIME = 3.0, -- seconds
    COMBO_MAX_TIME = 10.0, -- seconds (with max upgrades)

    -- Offline settings
    MAX_OFFLINE_TIME = 24, -- hours
    OFFLINE_EFFICIENCY = 0.5, -- 50% of active rate baseline

    -- Economy multipliers
    ZONE_DP_MULTIPLIERS = {1.0, 2.5, 6.0, 15.0, 25.0, 100.0},
    RARITY_DP_MULTIPLIERS = {1.0, 2.0, 5.0, 15.0, 50.0, 200.0},

    -- Prestige settings
    PRESTIGE_DP_BONUS = 0.10, -- +10% per prestige
    PRESTIGE_CLICK_BONUS = 0.05, -- +5% per prestige
    PRESTIGE_STARTING_DP = 1000, -- +1000 starting DP per prestige
    PRESTIGE_STARTING_LEVEL = 0.5, -- +0.5 levels per prestige

    -- Visual settings
    RARITY_COLORS = {
        Common = Color3.fromRGB(200, 200, 200),
        Uncommon = Color3.fromRGB(100, 255, 100),
        Rare = Color3.fromRGB(100, 150, 255),
        Epic = Color3.fromRGB(200, 100, 255),
        Legendary = Color3.fromRGB(255, 200, 50),
        Mythic = Color3.fromRGB(255, 100, 100)
    }
}

-- Return the module
return HomeworkDestroyer
