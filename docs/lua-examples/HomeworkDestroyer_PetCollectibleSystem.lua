--[[
    ============================================================================
    HOMEWORK DESTROYER - PET & COLLECTIBLE SYSTEM
    Complete Game Design Document & Implementation Reference
    ============================================================================

    This module defines the complete pet and collectible system for
    "Homework Destroyer" - a Roblox clicker game where players destroy
    homework to earn points and progress.

    Version: 1.0.0
    Last Updated: 2026-01-06
    ============================================================================
--]]

local PetSystem = {}

--============================================================================
-- SECTION 1: RARITY TIER DEFINITIONS
--============================================================================
--[[
    Rarity tiers determine pet power, appearance effects, and drop rates.
    Each tier has associated visual effects and stat multiplier ranges.
--]]

PetSystem.RarityTiers = {
    Common = {
        Order = 1,
        Color = Color3.fromRGB(180, 180, 180),      -- Gray
        GlowIntensity = 0,
        ParticleEffect = nil,
        StatMultiplierRange = {Min = 1.0, Max = 1.5},
        FusionShardsOnDelete = 1,
        DisplayName = "Common",
        BorderImage = "rbxassetid://COMMON_BORDER",
    },

    Uncommon = {
        Order = 2,
        Color = Color3.fromRGB(76, 175, 80),        -- Green
        GlowIntensity = 0.2,
        ParticleEffect = "SmallSparkle",
        StatMultiplierRange = {Min = 1.5, Max = 2.5},
        FusionShardsOnDelete = 3,
        DisplayName = "Uncommon",
        BorderImage = "rbxassetid://UNCOMMON_BORDER",
    },

    Rare = {
        Order = 3,
        Color = Color3.fromRGB(33, 150, 243),       -- Blue
        GlowIntensity = 0.4,
        ParticleEffect = "BlueGlow",
        StatMultiplierRange = {Min = 2.5, Max = 5.0},
        FusionShardsOnDelete = 10,
        DisplayName = "Rare",
        BorderImage = "rbxassetid://RARE_BORDER",
    },

    Epic = {
        Order = 4,
        Color = Color3.fromRGB(156, 39, 176),       -- Purple
        GlowIntensity = 0.6,
        ParticleEffect = "PurpleAura",
        StatMultiplierRange = {Min = 5.0, Max = 10.0},
        FusionShardsOnDelete = 25,
        DisplayName = "Epic",
        BorderImage = "rbxassetid://EPIC_BORDER",
    },

    Legendary = {
        Order = 5,
        Color = Color3.fromRGB(255, 193, 7),        -- Gold
        GlowIntensity = 0.8,
        ParticleEffect = "GoldenRays",
        StatMultiplierRange = {Min = 10.0, Max = 25.0},
        FusionShardsOnDelete = 75,
        DisplayName = "Legendary",
        BorderImage = "rbxassetid://LEGENDARY_BORDER",
    },

    Mythic = {
        Order = 6,
        Color = Color3.fromRGB(255, 0, 128),        -- Pink/Magenta
        GlowIntensity = 1.0,
        ParticleEffect = "RainbowCosmic",
        StatMultiplierRange = {Min = 25.0, Max = 50.0},
        FusionShardsOnDelete = 200,
        DisplayName = "Mythic",
        BorderImage = "rbxassetid://MYTHIC_BORDER",
    },

    -- Special tier for event/limited pets
    Secret = {
        Order = 7,
        Color = Color3.fromRGB(0, 255, 255),        -- Cyan
        GlowIntensity = 1.0,
        ParticleEffect = "HolographicShimmer",
        StatMultiplierRange = {Min = 30.0, Max = 75.0},
        FusionShardsOnDelete = 500,  -- Cannot be deleted normally
        DisplayName = "???",
        BorderImage = "rbxassetid://SECRET_BORDER",
        Tradeable = false,  -- Most secret pets are untradeable
    },
}

--============================================================================
-- SECTION 2: PET TYPE DEFINITIONS
--============================================================================
--[[
    All pets in the game, organized by thematic category.
    Each pet has base stats that scale with rarity and level.

    Pet Stat Types:
    - ClickPower: Multiplier to click damage
    - AutoClick: Clicks per second automatically
    - CritChance: % chance for critical hits
    - CritDamage: Multiplier when critical hit occurs
    - HomeworkDamage: Bonus damage to specific homework types
    - CoinBonus: % increase to coin drops
    - ExpBonus: % increase to experience gained
    - LuckBonus: Increases rare drop chances
--]]

PetSystem.PetTypes = {

    --========================================================================
    -- PAPER & WRITING CATEGORY
    --========================================================================

    PaperAirplane = {
        Id = "paper_airplane",
        DisplayName = "Paper Airplane",
        Description = "A folded friend that swoops in to help destroy homework!",
        Category = "Paper",
        AvailableRarities = {"Common", "Uncommon", "Rare", "Epic"},
        ModelId = "rbxassetid://PAPER_AIRPLANE_MODEL",

        BaseStats = {
            ClickPower = 1.1,
            AutoClick = 0.5,
            CritChance = 2,
        },

        -- Stats scale with rarity multiplier
        ScalableStats = {"ClickPower", "AutoClick"},

        -- Special ability (only activates at Epic rarity)
        SpecialAbility = {
            Name = "Flyby Attack",
            Description = "Every 30 seconds, deals 10x click damage to all homework on screen",
            Cooldown = 30,
            Effect = "AoEDamage",
            Multiplier = 10,
            RequiredRarity = "Epic",
        },

        -- Egg sources where this pet can be found
        EggSources = {"BasicEgg", "PaperEgg"},

        -- Animation set
        IdleAnimation = "Float",
        FollowBehavior = "Orbit",
    },

    PencilBuddy = {
        Id = "pencil_buddy",
        DisplayName = "Pencil Buddy",
        Description = "Sharp and ready to write off your homework problems!",
        Category = "Writing",
        AvailableRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary"},
        ModelId = "rbxassetid://PENCIL_BUDDY_MODEL",

        BaseStats = {
            ClickPower = 1.2,
            AutoClick = 0.3,
            CritChance = 5,
            CritDamage = 1.5,
        },

        ScalableStats = {"ClickPower", "CritDamage"},

        SpecialAbility = {
            Name = "Sharp Point",
            Description = "Critical hits deal 3x damage instead of normal crit multiplier",
            Cooldown = 0,  -- Passive
            Effect = "CritBoost",
            Multiplier = 3,
            RequiredRarity = "Legendary",
        },

        EggSources = {"BasicEgg", "WritingEgg"},
        IdleAnimation = "Bounce",
        FollowBehavior = "Follow",
    },

    EraserMonster = {
        Id = "eraser_monster",
        DisplayName = "Eraser Monster",
        Description = "This hungry creature eats mistakes... and homework!",
        Category = "Writing",
        AvailableRarities = {"Uncommon", "Rare", "Epic", "Legendary"},
        ModelId = "rbxassetid://ERASER_MONSTER_MODEL",

        BaseStats = {
            ClickPower = 1.3,
            AutoClick = 1.0,
            HomeworkDamage = {
                Written = 1.5,  -- 50% bonus to written homework
            },
        },

        ScalableStats = {"ClickPower", "AutoClick"},

        SpecialAbility = {
            Name = "Clean Sweep",
            Description = "Every 45 seconds, instantly destroys the weakest homework on screen",
            Cooldown = 45,
            Effect = "InstantKill",
            TargetType = "LowestHP",
            RequiredRarity = "Epic",
        },

        EggSources = {"WritingEgg", "MonsterEgg"},
        IdleAnimation = "Chomp",
        FollowBehavior = "Follow",
    },

    InkBlob = {
        Id = "ink_blob",
        DisplayName = "Ink Blob",
        Description = "A sentient splash of ink that smudges homework into oblivion!",
        Category = "Writing",
        AvailableRarities = {"Rare", "Epic", "Legendary", "Mythic"},
        ModelId = "rbxassetid://INK_BLOB_MODEL",

        BaseStats = {
            ClickPower = 1.5,
            AutoClick = 2.0,
            CritChance = 8,
            HomeworkDamage = {
                Written = 2.0,
                Printed = 1.25,
            },
        },

        ScalableStats = {"ClickPower", "AutoClick", "CritChance"},

        SpecialAbility = {
            Name = "Ink Explosion",
            Description = "Every 60 seconds, covers all homework in ink dealing 25% of their max HP",
            Cooldown = 60,
            Effect = "PercentDamage",
            DamagePercent = 0.25,
            RequiredRarity = "Legendary",
        },

        EggSources = {"WritingEgg", "PremiumEgg"},
        IdleAnimation = "Wobble",
        FollowBehavior = "Float",
    },

    GoldenPen = {
        Id = "golden_pen",
        DisplayName = "Golden Pen",
        Description = "The legendary pen that's mightier than any homework!",
        Category = "Writing",
        AvailableRarities = {"Legendary", "Mythic"},
        ModelId = "rbxassetid://GOLDEN_PEN_MODEL",

        BaseStats = {
            ClickPower = 2.0,
            AutoClick = 3.0,
            CritChance = 15,
            CritDamage = 2.5,
            CoinBonus = 25,
        },

        ScalableStats = {"ClickPower", "AutoClick", "CritDamage", "CoinBonus"},

        SpecialAbility = {
            Name = "Golden Hour",
            Description = "Every 2 minutes, doubles all damage and coins for 10 seconds",
            Cooldown = 120,
            Duration = 10,
            Effect = "DoubleAll",
            RequiredRarity = "Legendary",
        },

        EggSources = {"PremiumEgg", "MythicEgg"},
        IdleAnimation = "Spin",
        FollowBehavior = "Orbit",
    },

    --========================================================================
    -- SCHOOL SUPPLIES CATEGORY
    --========================================================================

    AngryRuler = {
        Id = "angry_ruler",
        DisplayName = "Angry Ruler",
        Description = "12 inches of pure homework-destroying fury!",
        Category = "Supplies",
        AvailableRarities = {"Common", "Uncommon", "Rare"},
        ModelId = "rbxassetid://ANGRY_RULER_MODEL",

        BaseStats = {
            ClickPower = 1.15,
            AutoClick = 0.25,
            CritChance = 3,
            CritDamage = 1.75,
        },

        ScalableStats = {"ClickPower", "CritDamage"},

        SpecialAbility = nil,  -- No special ability

        EggSources = {"BasicEgg", "SuppliesEgg"},
        IdleAnimation = "Measure",
        FollowBehavior = "Follow",
    },

    ScissorSpirit = {
        Id = "scissor_spirit",
        DisplayName = "Scissor Spirit",
        Description = "Cuts through homework like it's construction paper!",
        Category = "Supplies",
        AvailableRarities = {"Uncommon", "Rare", "Epic"},
        ModelId = "rbxassetid://SCISSOR_SPIRIT_MODEL",

        BaseStats = {
            ClickPower = 1.4,
            AutoClick = 0.75,
            CritChance = 12,
            CritDamage = 2.0,
        },

        ScalableStats = {"ClickPower", "CritChance", "CritDamage"},

        SpecialAbility = {
            Name = "Paper Cut",
            Description = "25% chance on click to deal triple damage to paper-based homework",
            Cooldown = 0,  -- Passive proc chance
            Effect = "ConditionalDamage",
            ProcChance = 0.25,
            Multiplier = 3,
            TargetType = "Paper",
            RequiredRarity = "Epic",
        },

        EggSources = {"SuppliesEgg"},
        IdleAnimation = "Snip",
        FollowBehavior = "Follow",
    },

    GlueGolem = {
        Id = "glue_golem",
        DisplayName = "Glue Golem",
        Description = "Sticky, strong, and surprisingly helpful!",
        Category = "Supplies",
        AvailableRarities = {"Rare", "Epic", "Legendary"},
        ModelId = "rbxassetid://GLUE_GOLEM_MODEL",

        BaseStats = {
            ClickPower = 1.25,
            AutoClick = 1.5,
            -- Defensive/utility focus
            ExpBonus = 10,
        },

        ScalableStats = {"ClickPower", "AutoClick", "ExpBonus"},

        SpecialAbility = {
            Name = "Sticky Situation",
            Description = "Homework takes 15% longer to escape (extends visible time)",
            Cooldown = 0,  -- Passive
            Effect = "SlowEscape",
            SlowPercent = 0.15,
            RequiredRarity = "Rare",
        },

        EggSources = {"SuppliesEgg", "MonsterEgg"},
        IdleAnimation = "Stretch",
        FollowBehavior = "Follow",
    },

    CalculatorBot = {
        Id = "calculator_bot",
        DisplayName = "Calculator Bot",
        Description = "Computes the optimal way to destroy math homework!",
        Category = "Supplies",
        AvailableRarities = {"Rare", "Epic", "Legendary", "Mythic"},
        ModelId = "rbxassetid://CALCULATOR_BOT_MODEL",

        BaseStats = {
            ClickPower = 1.35,
            AutoClick = 2.5,
            CritChance = 10,
            HomeworkDamage = {
                Math = 3.0,  -- Massive bonus vs math homework
            },
            ExpBonus = 15,
        },

        ScalableStats = {"ClickPower", "AutoClick", "HomeworkDamage"},

        SpecialAbility = {
            Name = "Calculate Weakness",
            Description = "Shows damage numbers and reveals homework HP bars permanently",
            Cooldown = 0,  -- Passive
            Effect = "RevealHP",
            RequiredRarity = "Rare",
        },

        EggSources = {"SuppliesEgg", "TechEgg", "PremiumEgg"},
        IdleAnimation = "Compute",
        FollowBehavior = "Orbit",
    },

    BackpackBeast = {
        Id = "backpack_beast",
        DisplayName = "Backpack Beast",
        Description = "A backpack that came alive and now hates homework as much as you!",
        Category = "Supplies",
        AvailableRarities = {"Epic", "Legendary", "Mythic"},
        ModelId = "rbxassetid://BACKPACK_BEAST_MODEL",

        BaseStats = {
            ClickPower = 2.0,
            AutoClick = 4.0,
            CritChance = 15,
            CritDamage = 2.0,
            CoinBonus = 20,
            ExpBonus = 20,
        },

        ScalableStats = {"ClickPower", "AutoClick", "CoinBonus", "ExpBonus"},

        SpecialAbility = {
            Name = "Supply Surge",
            Description = "Every 90 seconds, spawns 3 random supply pets to help for 15 seconds",
            Cooldown = 90,
            Duration = 15,
            Effect = "SummonHelpers",
            HelperCount = 3,
            HelperCategory = "Supplies",
            RequiredRarity = "Epic",
        },

        EggSources = {"PremiumEgg", "MythicEgg"},
        IdleAnimation = "Rustle",
        FollowBehavior = "Follow",
    },

    --========================================================================
    -- BOOK & PAPER CATEGORY
    --========================================================================

    AngryTextbook = {
        Id = "angry_textbook",
        DisplayName = "Angry Textbook",
        Description = "A textbook that's tired of being used for homework!",
        Category = "Books",
        AvailableRarities = {"Common", "Uncommon", "Rare", "Epic"},
        ModelId = "rbxassetid://ANGRY_TEXTBOOK_MODEL",

        BaseStats = {
            ClickPower = 1.2,
            AutoClick = 0.5,
            HomeworkDamage = {
                Reading = 1.5,
            },
            ExpBonus = 5,
        },

        ScalableStats = {"ClickPower", "AutoClick", "ExpBonus"},

        SpecialAbility = {
            Name = "Pop Quiz",
            Description = "Every 40 seconds, deals bonus damage equal to your current combo",
            Cooldown = 40,
            Effect = "ComboDamage",
            RequiredRarity = "Epic",
        },

        EggSources = {"BasicEgg", "BookEgg"},
        IdleAnimation = "Flap",
        FollowBehavior = "Float",
    },

    NotebookNinja = {
        Id = "notebook_ninja",
        DisplayName = "Notebook Ninja",
        Description = "Silent, swift, and deadly to any assignment!",
        Category = "Books",
        AvailableRarities = {"Uncommon", "Rare", "Epic", "Legendary"},
        ModelId = "rbxassetid://NOTEBOOK_NINJA_MODEL",

        BaseStats = {
            ClickPower = 1.5,
            AutoClick = 1.0,
            CritChance = 20,
            CritDamage = 2.5,
        },

        ScalableStats = {"ClickPower", "CritChance", "CritDamage"},

        SpecialAbility = {
            Name = "Shadow Strike",
            Description = "Critical hits have 50% chance to instantly reset click cooldown",
            Cooldown = 0,  -- Passive
            Effect = "CooldownReset",
            ProcChance = 0.5,
            RequiredRarity = "Legendary",
        },

        EggSources = {"BookEgg", "SuppliesEgg"},
        IdleAnimation = "Stealth",
        FollowBehavior = "Teleport",
    },

    LibraryGuardian = {
        Id = "library_guardian",
        DisplayName = "Library Guardian",
        Description = "An ancient tome that protects students from excessive homework!",
        Category = "Books",
        AvailableRarities = {"Legendary", "Mythic"},
        ModelId = "rbxassetid://LIBRARY_GUARDIAN_MODEL",

        BaseStats = {
            ClickPower = 2.5,
            AutoClick = 5.0,
            CritChance = 18,
            CritDamage = 3.0,
            HomeworkDamage = {
                Reading = 3.0,
                Written = 2.0,
            },
            ExpBonus = 50,
        },

        ScalableStats = {"ClickPower", "AutoClick", "CritDamage", "ExpBonus"},

        SpecialAbility = {
            Name = "Knowledge Bomb",
            Description = "Every 2 minutes, destroys all homework below 50% HP",
            Cooldown = 120,
            Effect = "ExecuteBelow",
            HPThreshold = 0.5,
            RequiredRarity = "Legendary",
        },

        EggSources = {"PremiumEgg", "MythicEgg"},
        IdleAnimation = "Levitate",
        FollowBehavior = "Float",
    },

    --========================================================================
    -- CREATURE CATEGORY
    --========================================================================

    HomeworkGremlin = {
        Id = "homework_gremlin",
        DisplayName = "Homework Gremlin",
        Description = "A mischievous creature that loves causing homework chaos!",
        Category = "Creatures",
        AvailableRarities = {"Common", "Uncommon", "Rare"},
        ModelId = "rbxassetid://HOMEWORK_GREMLIN_MODEL",

        BaseStats = {
            ClickPower = 1.1,
            AutoClick = 0.75,
            CritChance = 8,
            LuckBonus = 5,
        },

        ScalableStats = {"ClickPower", "AutoClick", "LuckBonus"},

        SpecialAbility = nil,

        EggSources = {"BasicEgg", "MonsterEgg"},
        IdleAnimation = "Cackle",
        FollowBehavior = "Bounce",
    },

    GradeGoblin = {
        Id = "grade_goblin",
        DisplayName = "Grade Goblin",
        Description = "Steals grades from homework and gives them to you!",
        Category = "Creatures",
        AvailableRarities = {"Uncommon", "Rare", "Epic"},
        ModelId = "rbxassetid://GRADE_GOBLIN_MODEL",

        BaseStats = {
            ClickPower = 1.2,
            AutoClick = 1.0,
            CoinBonus = 15,
            LuckBonus = 10,
        },

        ScalableStats = {"ClickPower", "CoinBonus", "LuckBonus"},

        SpecialAbility = {
            Name = "Grade Theft",
            Description = "5% chance on homework destruction to get 3x coins",
            Cooldown = 0,  -- Passive
            Effect = "BonusCoins",
            ProcChance = 0.05,
            Multiplier = 3,
            RequiredRarity = "Epic",
        },

        EggSources = {"MonsterEgg"},
        IdleAnimation = "Sneak",
        FollowBehavior = "Follow",
    },

    StudyBuddy = {
        Id = "study_buddy",
        DisplayName = "Study Buddy",
        Description = "A friendly spirit that makes destroying homework more efficient!",
        Category = "Creatures",
        AvailableRarities = {"Rare", "Epic", "Legendary"},
        ModelId = "rbxassetid://STUDY_BUDDY_MODEL",

        BaseStats = {
            ClickPower = 1.4,
            AutoClick = 2.0,
            ExpBonus = 30,
            CoinBonus = 10,
        },

        ScalableStats = {"ClickPower", "AutoClick", "ExpBonus"},

        SpecialAbility = {
            Name = "Study Session",
            Description = "While equipped, gain 2% more EXP for every other pet you have equipped",
            Cooldown = 0,  -- Passive
            Effect = "StackingBonus",
            BonusType = "ExpBonus",
            BonusPerPet = 0.02,
            RequiredRarity = "Rare",
        },

        EggSources = {"MonsterEgg", "PremiumEgg"},
        IdleAnimation = "Read",
        FollowBehavior = "Follow",
    },

    ProcrastinationDemon = {
        Id = "procrastination_demon",
        DisplayName = "Procrastination Demon",
        Description = "Embodies the power of 'I'll do it later' to destroy homework NOW!",
        Category = "Creatures",
        AvailableRarities = {"Epic", "Legendary", "Mythic"},
        ModelId = "rbxassetid://PROCRASTINATION_DEMON_MODEL",

        BaseStats = {
            ClickPower = 2.0,
            AutoClick = 5.0,
            CritChance = 20,
            CritDamage = 3.0,
            -- Gets stronger the longer you play
        },

        ScalableStats = {"ClickPower", "AutoClick", "CritChance"},

        SpecialAbility = {
            Name = "Last Minute Rush",
            Description = "Damage increases by 1% for every minute played this session (max 100%)",
            Cooldown = 0,  -- Passive
            Effect = "TimeScaling",
            BonusPerMinute = 0.01,
            MaxBonus = 1.0,
            RequiredRarity = "Epic",
        },

        EggSources = {"MonsterEgg", "PremiumEgg", "MythicEgg"},
        IdleAnimation = "Yawn",
        FollowBehavior = "Lazy",
    },

    --========================================================================
    -- TECH & DIGITAL CATEGORY
    --========================================================================

    USBUnicorn = {
        Id = "usb_unicorn",
        DisplayName = "USB Unicorn",
        Description = "A magical flash drive that corrupts homework files!",
        Category = "Tech",
        AvailableRarities = {"Rare", "Epic", "Legendary"},
        ModelId = "rbxassetid://USB_UNICORN_MODEL",

        BaseStats = {
            ClickPower = 1.6,
            AutoClick = 2.5,
            CritChance = 12,
            HomeworkDamage = {
                Digital = 2.5,
            },
        },

        ScalableStats = {"ClickPower", "AutoClick", "HomeworkDamage"},

        SpecialAbility = {
            Name = "Data Corruption",
            Description = "Digital homework has 10% chance to be instantly destroyed on click",
            Cooldown = 0,  -- Passive
            Effect = "InstantKillChance",
            ProcChance = 0.1,
            TargetType = "Digital",
            RequiredRarity = "Epic",
        },

        EggSources = {"TechEgg"},
        IdleAnimation = "Glow",
        FollowBehavior = "Orbit",
    },

    VirusViper = {
        Id = "virus_viper",
        DisplayName = "Virus Viper",
        Description = "A digital snake that infects and destroys online homework!",
        Category = "Tech",
        AvailableRarities = {"Epic", "Legendary", "Mythic"},
        ModelId = "rbxassetid://VIRUS_VIPER_MODEL",

        BaseStats = {
            ClickPower = 2.0,
            AutoClick = 4.0,
            CritChance = 15,
            CritDamage = 2.5,
            HomeworkDamage = {
                Digital = 3.0,
                Online = 3.0,
            },
        },

        ScalableStats = {"ClickPower", "AutoClick", "CritDamage"},

        SpecialAbility = {
            Name = "System Crash",
            Description = "Every 75 seconds, deals 50% of total damage dealt in last 30 seconds to all digital homework",
            Cooldown = 75,
            Effect = "StoredDamage",
            DamagePercent = 0.5,
            TrackingWindow = 30,
            TargetType = "Digital",
            RequiredRarity = "Legendary",
        },

        EggSources = {"TechEgg", "PremiumEgg"},
        IdleAnimation = "Slither",
        FollowBehavior = "Circuit",
    },

    WiFiWizard = {
        Id = "wifi_wizard",
        DisplayName = "Wi-Fi Wizard",
        Description = "Channels the power of internet connectivity to blast homework!",
        Category = "Tech",
        AvailableRarities = {"Legendary", "Mythic"},
        ModelId = "rbxassetid://WIFI_WIZARD_MODEL",

        BaseStats = {
            ClickPower = 2.5,
            AutoClick = 6.0,
            CritChance = 18,
            CritDamage = 3.0,
            HomeworkDamage = {
                Digital = 4.0,
                Online = 5.0,
            },
            LuckBonus = 25,
        },

        ScalableStats = {"ClickPower", "AutoClick", "CritDamage", "LuckBonus"},

        SpecialAbility = {
            Name = "Download Complete",
            Description = "Every 3 minutes, grants 30 seconds of auto-destroying the weakest homework every 2 seconds",
            Cooldown = 180,
            Duration = 30,
            Effect = "AutoDestroy",
            Interval = 2,
            TargetType = "LowestHP",
            RequiredRarity = "Legendary",
        },

        EggSources = {"TechEgg", "MythicEgg"},
        IdleAnimation = "Broadcast",
        FollowBehavior = "Float",
    },

    --========================================================================
    -- SPECIAL/SECRET CATEGORY
    --========================================================================

    TeachersPet = {
        Id = "teachers_pet",
        DisplayName = "Teacher's Pet",
        Description = "Ironically, this teacher's pet HATES homework!",
        Category = "Special",
        AvailableRarities = {"Mythic", "Secret"},
        ModelId = "rbxassetid://TEACHERS_PET_MODEL",

        BaseStats = {
            ClickPower = 3.0,
            AutoClick = 8.0,
            CritChance = 25,
            CritDamage = 4.0,
            CoinBonus = 50,
            ExpBonus = 75,
            LuckBonus = 30,
        },

        ScalableStats = {"ClickPower", "AutoClick", "CritDamage", "CoinBonus", "ExpBonus"},

        SpecialAbility = {
            Name = "Extra Credit",
            Description = "All stats are boosted by 25%, and every homework destroyed has 1% chance to drop a pet egg",
            Cooldown = 0,  -- Passive
            Effect = "StatBoost+EggDrop",
            StatBoostPercent = 0.25,
            EggDropChance = 0.01,
            RequiredRarity = "Mythic",
        },

        EggSources = {"MythicEgg"},  -- Very rare
        IdleAnimation = "Proud",
        FollowBehavior = "Loyal",
    },

    PrincipalsPanic = {
        Id = "principals_panic",
        DisplayName = "Principal's Panic",
        Description = "Even the principal fears this legendary homework destroyer!",
        Category = "Special",
        AvailableRarities = {"Secret"},
        ModelId = "rbxassetid://PRINCIPALS_PANIC_MODEL",

        BaseStats = {
            ClickPower = 5.0,
            AutoClick = 15.0,
            CritChance = 30,
            CritDamage = 5.0,
            HomeworkDamage = {
                All = 2.0,  -- Bonus to ALL homework types
            },
            CoinBonus = 100,
            ExpBonus = 100,
            LuckBonus = 50,
        },

        ScalableStats = {"ClickPower", "AutoClick", "CritDamage", "CoinBonus", "ExpBonus"},

        SpecialAbility = {
            Name = "School's Out",
            Description = "Every 5 minutes, destroys ALL homework on screen and grants 2x rewards for 30 seconds",
            Cooldown = 300,
            Duration = 30,
            Effect = "ClearScreen+DoubleRewards",
            RequiredRarity = "Secret",
        },

        EggSources = {},  -- Cannot be hatched, only from special events
        ObtainMethod = "Event",
        IdleAnimation = "Authority",
        FollowBehavior = "Lead",
    },
}

--============================================================================
-- SECTION 3: EGG SYSTEM
--============================================================================
--[[
    Eggs are the primary method of obtaining pets.
    Each egg has:
    - Cost (in-game currency or Robux)
    - Hatch time (can be skipped)
    - Pet pool with rarity-weighted chances
    - Visual appearance during hatching
--]]

PetSystem.Eggs = {

    --========================================================================
    -- FREE/BASIC EGGS
    --========================================================================

    BasicEgg = {
        Id = "basic_egg",
        DisplayName = "Basic Egg",
        Description = "A simple egg containing common school supply pets.",

        Cost = {
            Currency = "Coins",
            Amount = 500,
        },

        HatchTime = 0,  -- Instant

        ModelId = "rbxassetid://BASIC_EGG_MODEL",
        HatchAnimation = "StandardHatch",

        -- Rarity chances (must sum to 100)
        RarityChances = {
            Common = 70.0,
            Uncommon = 25.0,
            Rare = 4.5,
            Epic = 0.5,
            Legendary = 0,
            Mythic = 0,
        },

        -- Specific pets available in this egg
        AvailablePets = {
            "PaperAirplane",
            "PencilBuddy",
            "AngryRuler",
            "AngryTextbook",
            "HomeworkGremlin",
        },

        -- Player limits
        DailyLimit = nil,  -- No limit
        RequiredLevel = 1,
    },

    --========================================================================
    -- SPECIALTY EGGS
    --========================================================================

    WritingEgg = {
        Id = "writing_egg",
        DisplayName = "Writing Egg",
        Description = "Contains pets that specialize in destroying written homework!",

        Cost = {
            Currency = "Coins",
            Amount = 2500,
        },

        HatchTime = 30,  -- 30 seconds
        SkipCost = {Currency = "Gems", Amount = 5},

        ModelId = "rbxassetid://WRITING_EGG_MODEL",
        HatchAnimation = "InkSplash",

        RarityChances = {
            Common = 45.0,
            Uncommon = 35.0,
            Rare = 15.0,
            Epic = 4.5,
            Legendary = 0.5,
            Mythic = 0,
        },

        AvailablePets = {
            "PaperAirplane",
            "PencilBuddy",
            "EraserMonster",
            "InkBlob",
            "GoldenPen",
        },

        DailyLimit = nil,
        RequiredLevel = 5,
    },

    SuppliesEgg = {
        Id = "supplies_egg",
        DisplayName = "School Supplies Egg",
        Description = "Packed with useful school supply companions!",

        Cost = {
            Currency = "Coins",
            Amount = 5000,
        },

        HatchTime = 60,  -- 1 minute
        SkipCost = {Currency = "Gems", Amount = 10},

        ModelId = "rbxassetid://SUPPLIES_EGG_MODEL",
        HatchAnimation = "BackpackBurst",

        RarityChances = {
            Common = 35.0,
            Uncommon = 40.0,
            Rare = 18.0,
            Epic = 6.0,
            Legendary = 1.0,
            Mythic = 0,
        },

        AvailablePets = {
            "AngryRuler",
            "ScissorSpirit",
            "GlueGolem",
            "CalculatorBot",
            "NotebookNinja",
        },

        DailyLimit = nil,
        RequiredLevel = 10,
    },

    BookEgg = {
        Id = "book_egg",
        DisplayName = "Enchanted Book Egg",
        Description = "Contains mystical book-based pets with powerful abilities!",

        Cost = {
            Currency = "Coins",
            Amount = 10000,
        },

        HatchTime = 120,  -- 2 minutes
        SkipCost = {Currency = "Gems", Amount = 20},

        ModelId = "rbxassetid://BOOK_EGG_MODEL",
        HatchAnimation = "PageFlutter",

        RarityChances = {
            Common = 25.0,
            Uncommon = 40.0,
            Rare = 25.0,
            Epic = 8.0,
            Legendary = 2.0,
            Mythic = 0,
        },

        AvailablePets = {
            "AngryTextbook",
            "NotebookNinja",
            "LibraryGuardian",
        },

        DailyLimit = nil,
        RequiredLevel = 15,
    },

    MonsterEgg = {
        Id = "monster_egg",
        DisplayName = "Monster Egg",
        Description = "Home to mischievous creatures that love destroying homework!",

        Cost = {
            Currency = "Coins",
            Amount = 15000,
        },

        HatchTime = 180,  -- 3 minutes
        SkipCost = {Currency = "Gems", Amount = 30},

        ModelId = "rbxassetid://MONSTER_EGG_MODEL",
        HatchAnimation = "ScaryReveal",

        RarityChances = {
            Common = 20.0,
            Uncommon = 35.0,
            Rare = 30.0,
            Epic = 12.0,
            Legendary = 2.8,
            Mythic = 0.2,
        },

        AvailablePets = {
            "EraserMonster",
            "HomeworkGremlin",
            "GradeGoblin",
            "StudyBuddy",
            "ProcrastinationDemon",
            "GlueGolem",
        },

        DailyLimit = nil,
        RequiredLevel = 20,
    },

    TechEgg = {
        Id = "tech_egg",
        DisplayName = "Tech Egg",
        Description = "Digital pets that excel at destroying online homework!",

        Cost = {
            Currency = "Coins",
            Amount = 25000,
        },

        HatchTime = 240,  -- 4 minutes
        SkipCost = {Currency = "Gems", Amount = 50},

        ModelId = "rbxassetid://TECH_EGG_MODEL",
        HatchAnimation = "DigitalGlitch",

        RarityChances = {
            Common = 0,
            Uncommon = 30.0,
            Rare = 40.0,
            Epic = 22.0,
            Legendary = 7.5,
            Mythic = 0.5,
        },

        AvailablePets = {
            "CalculatorBot",
            "USBUnicorn",
            "VirusViper",
            "WiFiWizard",
        },

        DailyLimit = nil,
        RequiredLevel = 30,
    },

    --========================================================================
    -- PREMIUM EGGS (Robux or Premium Currency)
    --========================================================================

    PremiumEgg = {
        Id = "premium_egg",
        DisplayName = "Premium Egg",
        Description = "A golden egg with significantly better odds for rare pets!",

        Cost = {
            Currency = "Gems",
            Amount = 100,
        },
        -- Alternative Robux cost
        RobuxCost = 75,

        HatchTime = 0,  -- Instant for premium

        ModelId = "rbxassetid://PREMIUM_EGG_MODEL",
        HatchAnimation = "GoldenBurst",

        RarityChances = {
            Common = 0,
            Uncommon = 15.0,
            Rare = 40.0,
            Epic = 30.0,
            Legendary = 13.0,
            Mythic = 2.0,
        },

        AvailablePets = {
            "GoldenPen",
            "InkBlob",
            "CalculatorBot",
            "BackpackBeast",
            "StudyBuddy",
            "ProcrastinationDemon",
            "USBUnicorn",
            "VirusViper",
            "LibraryGuardian",
        },

        DailyLimit = 10,  -- Max 10 per day to prevent excessive spending
        RequiredLevel = 1,
    },

    MythicEgg = {
        Id = "mythic_egg",
        DisplayName = "Mythic Egg",
        Description = "The rarest egg with a guaranteed Epic or better pet!",

        Cost = {
            Currency = "Gems",
            Amount = 500,
        },
        RobuxCost = 299,

        HatchTime = 0,

        ModelId = "rbxassetid://MYTHIC_EGG_MODEL",
        HatchAnimation = "CosmicExplosion",

        RarityChances = {
            Common = 0,
            Uncommon = 0,
            Rare = 0,
            Epic = 60.0,
            Legendary = 32.0,
            Mythic = 8.0,
        },

        AvailablePets = {
            "GoldenPen",
            "BackpackBeast",
            "ProcrastinationDemon",
            "LibraryGuardian",
            "WiFiWizard",
            "TeachersPet",
        },

        DailyLimit = 3,
        RequiredLevel = 25,
    },

    --========================================================================
    -- SPECIAL/EVENT EGGS
    --========================================================================

    StarterEgg = {
        Id = "starter_egg",
        DisplayName = "Starter Egg",
        Description = "A free egg for new students! Contains your first pet.",

        Cost = {
            Currency = "Free",
            Amount = 0,
        },

        HatchTime = 0,

        ModelId = "rbxassetid://STARTER_EGG_MODEL",
        HatchAnimation = "WelcomeBurst",

        RarityChances = {
            Common = 60.0,
            Uncommon = 35.0,
            Rare = 5.0,
            Epic = 0,
            Legendary = 0,
            Mythic = 0,
        },

        AvailablePets = {
            "PaperAirplane",
            "PencilBuddy",
            "HomeworkGremlin",
        },

        -- One-time only
        LifetimeLimit = 1,
        RequiredLevel = 1,
    },
}

--============================================================================
-- SECTION 4: PET MECHANICS & STATS
--============================================================================
--[[
    Detailed breakdown of how pet stats work and affect gameplay.
--]]

PetSystem.Mechanics = {

    --========================================================================
    -- AUTO-CLICK SYSTEM
    --========================================================================
    AutoClick = {
        Description = "Pets automatically click on homework at specified intervals",

        -- Base clicks per second for each rarity tier
        BaseRates = {
            Common = 0.5,      -- 1 click every 2 seconds
            Uncommon = 1.0,    -- 1 click per second
            Rare = 2.0,        -- 2 clicks per second
            Epic = 3.5,        -- 3.5 clicks per second
            Legendary = 5.0,   -- 5 clicks per second
            Mythic = 8.0,      -- 8 clicks per second
            Secret = 12.0,     -- 12 clicks per second
        },

        -- Damage per auto-click (percentage of player's click damage)
        DamagePercent = {
            Common = 0.25,     -- 25% of player click
            Uncommon = 0.35,   -- 35%
            Rare = 0.50,       -- 50%
            Epic = 0.65,       -- 65%
            Legendary = 0.80,  -- 80%
            Mythic = 1.00,     -- 100% (full player click)
            Secret = 1.25,     -- 125%
        },

        -- Maximum auto-click damage cap (prevents overflow)
        MaxAutoClicksPerSecond = 50,  -- Combined from all pets
    },

    --========================================================================
    -- CLICK POWER MULTIPLIERS
    --========================================================================
    ClickPower = {
        Description = "Multiplies the player's base click damage",

        -- How multipliers stack from multiple pets
        StackingMethod = "Additive",  -- Multipliers add together
        -- Example: 1.5x + 1.3x + 1.2x = 4.0x total (not multiplicative)

        -- Base multiplier caps by rarity
        MaxMultiplier = {
            Common = 2.0,
            Uncommon = 3.5,
            Rare = 6.0,
            Epic = 12.0,
            Legendary = 25.0,
            Mythic = 50.0,
            Secret = 100.0,
        },
    },

    --========================================================================
    -- CRITICAL HIT SYSTEM
    --========================================================================
    Critical = {
        Description = "Chance for clicks to deal bonus damage",

        -- Base crit stats
        BaseCritChance = 5,      -- 5% without pets
        BaseCritDamage = 1.5,    -- 1.5x damage on crit

        -- Caps
        MaxCritChance = 75,      -- 75% max crit chance
        MaxCritDamage = 10.0,    -- 10x max crit damage

        -- Pet crit contribution stacking
        CritChanceStacking = "Additive",
        CritDamageStacking = "Additive",
    },

    --========================================================================
    -- BONUS SYSTEMS
    --========================================================================
    Bonuses = {
        -- Coin bonus
        CoinBonus = {
            StackingMethod = "Additive",
            MaxBonus = 500,  -- 500% max coin bonus
        },

        -- Experience bonus
        ExpBonus = {
            StackingMethod = "Additive",
            MaxBonus = 300,  -- 300% max EXP bonus
        },

        -- Luck bonus (affects egg hatching and drops)
        LuckBonus = {
            StackingMethod = "Diminishing",  -- Each point worth less
            DiminishingFactor = 0.95,        -- 95% of previous point
            MaxBonus = 200,                  -- 200% max luck bonus
        },
    },
}

--============================================================================
-- SECTION 5: PET LEVELING & FUSION SYSTEM
--============================================================================
--[[
    Pets can be leveled up and fused to become stronger.
--]]

PetSystem.Leveling = {

    --========================================================================
    -- EXPERIENCE SYSTEM
    --========================================================================
    MaxLevel = 50,

    -- EXP required per level (base, scales with level)
    BaseExpPerLevel = 100,
    ExpScalingFactor = 1.15,  -- Each level needs 15% more EXP

    -- EXP formula: BaseExpPerLevel * (ExpScalingFactor ^ (Level - 1))
    -- Level 1->2: 100 EXP
    -- Level 10->11: 100 * 1.15^9 = ~352 EXP
    -- Level 25->26: 100 * 1.15^24 = ~2,890 EXP
    -- Level 49->50: 100 * 1.15^48 = ~86,800 EXP

    -- How pets gain EXP
    ExpSources = {
        HomeworkDestroyed = 1,      -- 1 EXP per homework destroyed while equipped
        BossDefeated = 50,          -- 50 EXP per boss defeated
        QuestCompleted = 25,        -- 25 EXP per quest completed
        DailyLogin = 100,           -- 100 EXP to all equipped pets on daily login
    },

    -- Stat increase per level
    StatGainPerLevel = {
        ClickPower = 0.02,    -- +2% per level
        AutoClick = 0.015,    -- +1.5% per level
        CritChance = 0.1,     -- +0.1% per level
        CritDamage = 0.01,    -- +1% per level
        CoinBonus = 0.5,      -- +0.5% per level
        ExpBonus = 0.5,       -- +0.5% per level
        LuckBonus = 0.25,     -- +0.25% per level
    },

    -- Visual changes at level milestones
    LevelMilestones = {
        [10] = {Effect = "SmallAura", NamePrefix = ""},
        [25] = {Effect = "MediumAura", NamePrefix = "Enhanced "},
        [40] = {Effect = "LargeAura", NamePrefix = "Superior "},
        [50] = {Effect = "MaxAura", NamePrefix = "Ultimate "},
    },
}

PetSystem.Fusion = {

    --========================================================================
    -- BASIC FUSION (Combine duplicates for upgrades)
    --========================================================================

    BasicFusion = {
        Description = "Combine 3 identical pets to create 1 stronger version",

        RequiredPets = 3,  -- Need 3 of the same pet

        -- Result options
        Results = {
            -- Same rarity but higher level
            SameRarityLevelBoost = {
                Chance = 70,
                LevelBoost = 10,  -- +10 levels
            },

            -- Upgrade to next rarity (if available for that pet)
            RarityUpgrade = {
                Chance = 25,
                LevelReset = true,  -- Starts at level 1
            },

            -- Shiny/Golden version (same rarity, 1.5x stats)
            ShinyVersion = {
                Chance = 5,
                StatMultiplier = 1.5,
                VisualEffect = "Shiny",
            },
        },

        -- Cost
        FusionCost = {
            Currency = "Coins",
            BaseAmount = 1000,
            RarityMultiplier = {
                Common = 1,
                Uncommon = 2,
                Rare = 5,
                Epic = 15,
                Legendary = 50,
                Mythic = 200,
            },
        },
    },

    --========================================================================
    -- CROSS-FUSION (Combine different pets)
    --========================================================================

    CrossFusion = {
        Description = "Combine 5 different pets for a chance at a random better pet",

        RequiredPets = 5,
        RequireDifferent = true,
        RequireSameRarity = true,  -- All 5 must be same rarity

        -- Result: Random pet of next rarity tier
        GuaranteedUpgrade = true,

        -- Bonus chance for double upgrade (skip a rarity)
        DoubleUpgradeChance = 5,  -- 5% chance

        -- Cost
        FusionCost = {
            Currency = "Gems",
            BaseAmount = 10,
            RarityMultiplier = {
                Common = 1,
                Uncommon = 2,
                Rare = 5,
                Epic = 15,
                Legendary = 50,
            },
        },

        -- Cannot cross-fuse Mythic pets
        MaxInputRarity = "Legendary",
    },

    --========================================================================
    -- SHARDS SYSTEM
    --========================================================================

    Shards = {
        Description = "Delete pets for shards, use shards to craft specific pets",

        -- Shards gained from deleting pets
        ShardsPerRarity = {
            Common = 1,
            Uncommon = 3,
            Rare = 10,
            Epic = 25,
            Legendary = 75,
            Mythic = 200,
            Secret = 0,  -- Cannot delete Secret pets
        },

        -- Shards needed to craft a pet of each rarity
        CraftCost = {
            Common = 5,
            Uncommon = 15,
            Rare = 50,
            Epic = 150,
            Legendary = 500,
            Mythic = 2000,
        },

        -- Crafting gives random pet of chosen rarity
        -- OR specific pet at 3x cost
        SpecificPetMultiplier = 3,
    },

    --========================================================================
    -- ENCHANTING SYSTEM
    --========================================================================

    Enchanting = {
        Description = "Add special enchantments to pets for bonus effects",

        MaxEnchantments = 3,  -- Max enchants per pet

        EnchantmentTypes = {
            SpeedBoost = {
                Name = "Swift",
                Effect = "AutoClick speed +25%",
                Cost = {Gems = 50},
                Stackable = false,
            },

            PowerBoost = {
                Name = "Mighty",
                Effect = "Click power +15%",
                Cost = {Gems = 50},
                Stackable = true,  -- Can have multiple
                MaxStacks = 3,
            },

            LuckyStrike = {
                Name = "Lucky",
                Effect = "Crit chance +10%",
                Cost = {Gems = 75},
                Stackable = false,
            },

            GoldRush = {
                Name = "Greedy",
                Effect = "Coin bonus +20%",
                Cost = {Gems = 60},
                Stackable = true,
                MaxStacks = 2,
            },

            Vampiric = {
                Name = "Vampiric",
                Effect = "1% of damage dealt restores combo meter",
                Cost = {Gems = 100},
                Stackable = false,
            },

            Explosive = {
                Name = "Explosive",
                Effect = "5% chance for clicks to deal AoE damage",
                Cost = {Gems = 150},
                Stackable = false,
            },
        },

        -- Remove enchantment cost
        RemovalCost = {Gems = 25},
    },
}

--============================================================================
-- SECTION 6: INVENTORY & EQUIP SYSTEM
--============================================================================

PetSystem.Inventory = {

    --========================================================================
    -- STORAGE LIMITS
    --========================================================================

    BaseStorage = {
        Free = 50,           -- Free players start with 50 slots
        Premium = 100,       -- Premium pass holders get 100 slots
    },

    -- Additional storage upgrades
    StorageUpgrades = {
        {
            Slots = 25,
            Cost = {Gems = 50},
        },
        {
            Slots = 25,
            Cost = {Gems = 100},
        },
        {
            Slots = 50,
            Cost = {Gems = 200},
        },
        {
            Slots = 50,
            Cost = {Gems = 400},
        },
        {
            Slots = 100,
            Cost = {Gems = 800},
        },
    },

    MaxStorage = 500,  -- Absolute maximum

    --========================================================================
    -- EQUIP LIMITS
    --========================================================================

    BaseEquipSlots = {
        Free = 3,            -- Free players can equip 3 pets
        Premium = 5,         -- Premium pass holders can equip 5
    },

    -- Additional equip slots from upgrades
    EquipSlotUpgrades = {
        {
            Slots = 1,
            Cost = {Gems = 100},
            RequiredLevel = 10,
        },
        {
            Slots = 1,
            Cost = {Gems = 250},
            RequiredLevel = 25,
        },
        {
            Slots = 1,
            Cost = {Gems = 500},
            RequiredLevel = 40,
        },
        {
            Slots = 1,
            Cost = {Gems = 1000},
            RequiredLevel = 60,
        },
        {
            Slots = 1,
            Cost = {Gems = 2000},
            RequiredLevel = 80,
        },
    },

    MaxEquipSlots = 10,  -- Absolute maximum

    --========================================================================
    -- SORTING & FILTERING
    --========================================================================

    SortOptions = {
        "Rarity",            -- By rarity (highest first)
        "Level",             -- By level (highest first)
        "Power",             -- By total stat power
        "Recent",            -- By acquisition date
        "Alphabetical",      -- By name A-Z
        "Equipped",          -- Equipped pets first
        "Favorited",         -- Favorited pets first
    },

    FilterOptions = {
        "All",
        "Equipped",
        "Favorited",
        "Common",
        "Uncommon",
        "Rare",
        "Epic",
        "Legendary",
        "Mythic",
        "Secret",
        "Shiny",
        "Category",  -- Submenu for pet categories
    },

    --========================================================================
    -- PET MANAGEMENT
    --========================================================================

    Features = {
        Favorite = true,          -- Mark pets as favorites (protected from deletion)
        Lock = true,              -- Lock pets (cannot be traded or deleted)
        Nickname = true,          -- Custom nicknames (max 20 characters)
        QuickEquip = true,        -- Double-click to equip/unequip
        BulkDelete = true,        -- Select multiple for deletion
        BulkFusion = true,        -- Auto-select duplicates for fusion
        AutoEquipBest = true,     -- Button to equip highest power pets
    },
}

--============================================================================
-- SECTION 7: TRADING SYSTEM
--============================================================================

PetSystem.Trading = {

    --========================================================================
    -- TRADING REQUIREMENTS
    --========================================================================

    Requirements = {
        MinLevel = 15,                    -- Must be level 15 to trade
        AccountAge = 3,                   -- Account must be 3+ days old
        EmailVerified = true,             -- Roblox email verification required
        TwoFactorAuth = false,            -- 2FA recommended but not required
        PremiumRequired = false,          -- Free players can trade
    },

    --========================================================================
    -- TRADING RULES
    --========================================================================

    Rules = {
        MaxPetsPerTrade = 6,              -- Max 6 pets per side of trade
        MaxTradesPerDay = 20,             -- 20 trades per day limit
        TradeCooldown = 60,               -- 60 seconds between trades

        -- Value protection (prevents massively unfair trades)
        ValueProtection = {
            Enabled = true,
            MaxValueDifference = 0.5,     -- Max 50% value difference allowed
            WarningThreshold = 0.25,      -- Warn at 25% difference
        },
    },

    --========================================================================
    -- TRADEABILITY RESTRICTIONS
    --========================================================================

    Restrictions = {
        -- Pets that cannot be traded
        Untradeable = {
            "PrincipalsPanic",            -- Secret event pet
            -- Event pets added here
        },

        -- Restrictions by rarity
        RarityRestrictions = {
            Secret = {
                Tradeable = false,        -- Most Secret pets untradeable
            },
        },

        -- Time-locked (cannot trade for X hours after obtaining)
        TimeLock = {
            Enabled = true,
            Duration = 24,                -- 24 hour trade lock on new pets
            ExemptSources = {"Trading"},  -- Traded pets exempt from relock
        },

        -- Level requirements to trade higher rarities
        RarityLevelRequirements = {
            Common = 15,
            Uncommon = 15,
            Rare = 20,
            Epic = 30,
            Legendary = 40,
            Mythic = 50,
        },
    },

    --========================================================================
    -- TRADE VALUE SYSTEM
    --========================================================================

    ValueSystem = {
        -- Base values by rarity
        BaseValues = {
            Common = 1,
            Uncommon = 5,
            Rare = 25,
            Epic = 100,
            Legendary = 500,
            Mythic = 2500,
            Secret = 10000,
        },

        -- Modifiers
        Modifiers = {
            Shiny = 3.0,           -- Shiny pets worth 3x
            MaxLevel = 2.0,        -- Level 50 pets worth 2x
            Enchanted = 1.25,      -- Per enchantment +25%
            Limited = 5.0,         -- Limited/Event pets worth 5x
        },
    },

    --========================================================================
    -- TRADE HISTORY
    --========================================================================

    History = {
        Enabled = true,
        MaxRecords = 100,                 -- Keep last 100 trades
        DisplayInfo = {
            "TradePartner",
            "PetsGiven",
            "PetsReceived",
            "Timestamp",
            "TradeValue",
        },
    },

    --========================================================================
    -- SCAM PREVENTION
    --========================================================================

    ScamPrevention = {
        ConfirmationTimer = 5,            -- 5 second confirm delay
        DoubleConfirm = true,             -- Require typing "CONFIRM"
        ShowValueWarning = true,          -- Warn about value differences
        ShowRarityMismatch = true,        -- Warn if giving higher rarity
        ReportSystem = true,              -- Enable trade reports
    },
}

--============================================================================
-- SECTION 8: OBTAINING PETS - ALL METHODS
--============================================================================

PetSystem.ObtainMethods = {

    --========================================================================
    -- EGGS (Primary method - see Section 3 for details)
    --========================================================================

    Eggs = {
        Description = "Hatch pets from eggs purchased with coins or gems",
        -- See PetSystem.Eggs for full details
    },

    --========================================================================
    -- CODES
    --========================================================================

    Codes = {
        Description = "Redeem special codes for free pets and items",

        -- Active codes (would be managed server-side)
        ActiveCodes = {
            HOMEWORK2026 = {
                Reward = {Type = "Pet", PetId = "PaperAirplane", Rarity = "Rare"},
                Uses = "Unlimited",
                Expires = "2026-12-31",
            },
            STUDYHARD = {
                Reward = {Type = "Egg", EggId = "PremiumEgg", Quantity = 1},
                Uses = "Unlimited",
                Expires = "2026-06-01",
            },
            SECRETPET = {
                Reward = {Type = "Pet", PetId = "HomeworkGremlin", Rarity = "Epic", Shiny = true},
                Uses = 1000,  -- First 1000 redemptions only
                Expires = nil,  -- Never expires
            },
        },

        -- Code limits per player
        MaxCodesPerDay = 5,
        CodeCooldown = 10,  -- Seconds between code attempts
    },

    --========================================================================
    -- ACHIEVEMENTS
    --========================================================================

    Achievements = {
        Description = "Earn pets by completing achievements",

        PetRewards = {
            FirstHomework = {
                Achievement = "Destroy your first homework",
                Reward = {Type = "Egg", EggId = "StarterEgg"},
            },

            Destroyer100 = {
                Achievement = "Destroy 100 homework",
                Reward = {Type = "Pet", PetId = "EraserMonster", Rarity = "Uncommon"},
            },

            Destroyer1000 = {
                Achievement = "Destroy 1,000 homework",
                Reward = {Type = "Pet", PetId = "ScissorSpirit", Rarity = "Rare"},
            },

            Destroyer10000 = {
                Achievement = "Destroy 10,000 homework",
                Reward = {Type = "Pet", PetId = "GlueGolem", Rarity = "Epic"},
            },

            Destroyer100000 = {
                Achievement = "Destroy 100,000 homework",
                Reward = {Type = "Pet", PetId = "BackpackBeast", Rarity = "Legendary"},
            },

            CollectorBronze = {
                Achievement = "Collect 10 unique pets",
                Reward = {Type = "Egg", EggId = "SuppliesEgg", Quantity = 3},
            },

            CollectorSilver = {
                Achievement = "Collect 25 unique pets",
                Reward = {Type = "Pet", PetId = "CalculatorBot", Rarity = "Epic"},
            },

            CollectorGold = {
                Achievement = "Collect 50 unique pets",
                Reward = {Type = "Pet", PetId = "TeachersPet", Rarity = "Mythic"},
            },

            LevelMaster = {
                Achievement = "Get a pet to level 50",
                Reward = {Type = "Title", TitleId = "PetMaster"},
            },

            FusionExpert = {
                Achievement = "Successfully fuse 50 pets",
                Reward = {Type = "Pet", PetId = "StudyBuddy", Rarity = "Legendary"},
            },
        },
    },

    --========================================================================
    -- PURCHASES (Robux/Gems)
    --========================================================================

    Purchases = {
        Description = "Direct pet purchases with premium currency",

        -- Rotating shop with direct pet purchases
        PetShop = {
            RefreshInterval = 86400,  -- 24 hours

            Slots = {
                {
                    Type = "RandomRare",
                    Cost = {Gems = 75},
                },
                {
                    Type = "RandomEpic",
                    Cost = {Gems = 200},
                },
                {
                    Type = "Featured",  -- Specific featured pet
                    Cost = {Gems = 500},
                },
            },
        },

        -- Bundles
        Bundles = {
            StarterBundle = {
                Description = "Perfect for new players!",
                Cost = {Robux = 199},
                Contents = {
                    {Type = "Pet", PetId = "PencilBuddy", Rarity = "Epic"},
                    {Type = "Pet", PetId = "EraserMonster", Rarity = "Rare"},
                    {Type = "Egg", EggId = "PremiumEgg", Quantity = 3},
                    {Type = "Currency", Currency = "Gems", Amount = 100},
                },
                OneTimePurchase = true,
            },

            MegaBundle = {
                Description = "Massive value for serious collectors!",
                Cost = {Robux = 999},
                Contents = {
                    {Type = "Pet", PetId = "GoldenPen", Rarity = "Legendary"},
                    {Type = "Pet", PetId = "LibraryGuardian", Rarity = "Legendary"},
                    {Type = "Egg", EggId = "MythicEgg", Quantity = 5},
                    {Type = "Currency", Currency = "Gems", Amount = 1000},
                    {Type = "EquipSlot", Amount = 2},
                },
                OneTimePurchase = true,
            },
        },
    },

    --========================================================================
    -- DAILY/WEEKLY REWARDS
    --========================================================================

    DailyRewards = {
        Description = "Login rewards include pets on special days",

        Schedule = {
            Day7 = {Type = "Egg", EggId = "SuppliesEgg"},
            Day14 = {Type = "Pet", PetId = "GradeGoblin", Rarity = "Rare"},
            Day21 = {Type = "Egg", EggId = "PremiumEgg"},
            Day28 = {Type = "Pet", PetId = "NotebookNinja", Rarity = "Epic"},
            Day30 = {Type = "Egg", EggId = "MythicEgg"},
        },
    },
}

--============================================================================
-- SECTION 9: LIMITED & EVENT PETS (FOMO System)
--============================================================================

PetSystem.LimitedPets = {

    --========================================================================
    -- SEASONAL EVENTS
    --========================================================================

    SeasonalEvents = {

        BackToSchool = {
            Name = "Back to School Event",
            Duration = {Start = "September 1", End = "September 15"},
            RecurringYearly = true,

            ExclusivePets = {
                NewYearNerd = {
                    Id = "new_year_nerd",
                    DisplayName = "New Year Nerd",
                    Description = "A studious spirit ready for a fresh academic year!",
                    Rarity = "Legendary",
                    BaseStats = {
                        ClickPower = 2.2,
                        AutoClick = 4.5,
                        ExpBonus = 100,  -- Double EXP!
                    },
                    ObtainMethod = "Event egg only",
                    Tradeable = true,
                    ReturnsNextYear = true,
                },
            },

            ExclusiveEgg = {
                Id = "back_to_school_egg",
                Cost = {Coins = 15000},
                RarityChances = {
                    Common = 0,
                    Uncommon = 30,
                    Rare = 40,
                    Epic = 22,
                    Legendary = 8,  -- Higher legendary chance!
                },
            },
        },

        Halloween = {
            Name = "Halloween Homework Horror",
            Duration = {Start = "October 20", End = "November 5"},
            RecurringYearly = true,

            ExclusivePets = {
                SpookyScantron = {
                    Id = "spooky_scantron",
                    DisplayName = "Spooky Scantron",
                    Description = "A haunted test sheet that terrorizes homework!",
                    Rarity = "Epic",
                    BaseStats = {
                        ClickPower = 1.8,
                        AutoClick = 3.0,
                        CritChance = 25,
                        HomeworkDamage = {Test = 3.0},
                    },
                    ObtainMethod = "Halloween egg",
                    Tradeable = true,
                    ReturnsNextYear = true,
                },

                PhantomProfessor = {
                    Id = "phantom_professor",
                    DisplayName = "Phantom Professor",
                    Description = "The ghost of a teacher who assigns NO homework!",
                    Rarity = "Mythic",
                    BaseStats = {
                        ClickPower = 3.5,
                        AutoClick = 7.0,
                        CritChance = 20,
                        CritDamage = 4.0,
                        HomeworkDamage = {All = 1.5},
                    },
                    ObtainMethod = "0.5% from Halloween egg",
                    Tradeable = true,
                    ReturnsNextYear = true,
                },
            },

            ExclusiveEgg = {
                Id = "halloween_egg",
                Cost = {Coins = 20000},
                SpecialDrop = {PetId = "PhantomProfessor", Chance = 0.5},
            },
        },

        WinterBreak = {
            Name = "Winter Break Blitz",
            Duration = {Start = "December 15", End = "January 5"},
            RecurringYearly = true,

            ExclusivePets = {
                SnowflakeScholar = {
                    Id = "snowflake_scholar",
                    DisplayName = "Snowflake Scholar",
                    Description = "A frosty friend who freezes homework solid!",
                    Rarity = "Legendary",
                    BaseStats = {
                        ClickPower = 2.5,
                        AutoClick = 5.0,
                        CoinBonus = 50,
                    },
                    SpecialAbility = {
                        Name = "Freeze Frame",
                        Description = "Every 60s, freezes all homework for 5s (cannot escape)",
                    },
                    ObtainMethod = "Winter egg",
                    Tradeable = true,
                    ReturnsNextYear = true,
                },

                HolidayHomeworkHater = {
                    Id = "holiday_homework_hater",
                    DisplayName = "Holiday Homework Hater",
                    Description = "NO homework during the holidays!",
                    Rarity = "Secret",
                    BaseStats = {
                        ClickPower = 4.0,
                        AutoClick = 10.0,
                        CritChance = 25,
                        CritDamage = 4.0,
                        CoinBonus = 75,
                        ExpBonus = 75,
                    },
                    ObtainMethod = "0.1% from Winter egg OR complete all winter quests",
                    Tradeable = false,
                    ReturnsNextYear = false,  -- Different version each year!
                },
            },
        },

        SummerVacation = {
            Name = "Summer Vacation Celebration",
            Duration = {Start = "June 15", End = "July 15"},
            RecurringYearly = true,

            ExclusivePets = {
                BeachBinder = {
                    Id = "beach_binder",
                    DisplayName = "Beach Binder",
                    Description = "A sun-loving binder that destroys summer assignments!",
                    Rarity = "Epic",
                    BaseStats = {
                        ClickPower = 1.9,
                        AutoClick = 3.5,
                        CoinBonus = 30,
                    },
                    ObtainMethod = "Summer egg",
                    Tradeable = true,
                    ReturnsNextYear = true,
                },

                VacationVibes = {
                    Id = "vacation_vibes",
                    DisplayName = "Vacation Vibes",
                    Description = "Pure summer energy that melts homework away!",
                    Rarity = "Mythic",
                    BaseStats = {
                        ClickPower = 3.0,
                        AutoClick = 8.0,
                        CritChance = 22,
                        CritDamage = 3.5,
                        LuckBonus = 50,
                    },
                    ObtainMethod = "Summer event boss drop (5%)",
                    Tradeable = true,
                    ReturnsNextYear = true,
                },
            },
        },
    },

    --========================================================================
    -- ONE-TIME EXCLUSIVE EVENTS
    --========================================================================

    OneTimeEvents = {

        LaunchEvent = {
            Name = "Grand Opening Celebration",
            Duration = {Start = "Launch", End = "Launch + 30 days"},
            RecurringYearly = false,

            ExclusivePets = {
                FoundersFriend = {
                    Id = "founders_friend",
                    DisplayName = "Founder's Friend",
                    Description = "A legendary companion for day-one players!",
                    Rarity = "Secret",
                    BaseStats = {
                        ClickPower = 3.0,
                        AutoClick = 6.0,
                        CritChance = 20,
                        CritDamage = 3.0,
                        CoinBonus = 50,
                        ExpBonus = 50,
                    },
                    SpecialAbility = {
                        Name = "Founder's Fortune",
                        Description = "Passive 10% chance for bonus rewards on any action",
                    },
                    ObtainMethod = "Play during launch month",
                    Tradeable = false,  -- Permanently untradeable
                    NeverReturns = true,
                },
            },
        },

        MillionPlayers = {
            Name = "1 Million Players Celebration",
            Duration = {Start = "Milestone", End = "Milestone + 7 days"},
            RecurringYearly = false,

            ExclusivePets = {
                MillionaireMascot = {
                    Id = "millionaire_mascot",
                    DisplayName = "Millionaire Mascot",
                    Description = "Celebrating 1 million homework destroyers!",
                    Rarity = "Legendary",
                    BaseStats = {
                        ClickPower = 2.5,
                        AutoClick = 5.0,
                        CoinBonus = 100,
                    },
                    ObtainMethod = "Free claim during event",
                    Tradeable = true,
                    NeverReturns = true,
                },
            },
        },
    },

    --========================================================================
    -- ROTATING LIMITED SHOP
    --========================================================================

    RotatingShop = {
        Description = "Limited pets available for short windows",

        RefreshSchedule = "Weekly",
        AvailabilityWindow = 168,  -- 168 hours (7 days)

        -- Example rotating pets
        RotatingPets = {
            RainbowRuler = {
                Id = "rainbow_ruler",
                DisplayName = "Rainbow Ruler",
                Description = "A colorful ruler that measures up to any homework!",
                Rarity = "Legendary",
                Cost = {Gems = 750},
                AppearanceFrequency = "Monthly",
                BaseStats = {
                    ClickPower = 2.3,
                    AutoClick = 4.5,
                    CritChance = 18,
                    LuckBonus = 30,
                },
            },

            DiamondDictionary = {
                Id = "diamond_dictionary",
                DisplayName = "Diamond Dictionary",
                Description = "Contains the definition of DESTRUCTION!",
                Rarity = "Mythic",
                Cost = {Gems = 1500},
                AppearanceFrequency = "Quarterly",
                BaseStats = {
                    ClickPower = 3.2,
                    AutoClick = 7.0,
                    CritChance = 22,
                    CritDamage = 3.5,
                    ExpBonus = 60,
                },
            },
        },

        -- Countdown display to create urgency
        ShowCountdown = true,
        ShowRemainingStock = true,  -- "Only 500 left!" messaging
    },

    --========================================================================
    -- BATTLE PASS / SEASON PASS PETS
    --========================================================================

    SeasonPass = {
        Description = "Exclusive pets from seasonal battle passes",

        Structure = {
            FreeTrack = {
                -- Free pets at certain levels
                Level10 = {Type = "Egg", EggId = "SuppliesEgg"},
                Level30 = {Type = "Pet", PetId = "HomeworkGremlin", Rarity = "Rare"},
                Level50 = {Type = "Egg", EggId = "PremiumEgg"},
            },

            PremiumTrack = {
                Cost = {Robux = 499},

                -- Premium-exclusive pets
                Level1 = {Type = "Pet", PetId = "SeasonalExclusive", Rarity = "Epic"},
                Level25 = {Type = "Pet", PetId = "SeasonalMid", Rarity = "Legendary"},
                Level50 = {Type = "Pet", PetId = "SeasonalFinal", Rarity = "Mythic"},
                Level60 = {Type = "Pet", PetId = "SeasonalPrestige", Rarity = "Secret"},
            },
        },

        SeasonDuration = 90,  -- 90 days per season
        NeverReturns = true,  -- Season pass pets never return
    },

    --========================================================================
    -- FOMO MECHANICS SUMMARY
    --========================================================================

    FOMOStrategies = {

        -- Countdown timers on everything limited
        Countdowns = {
            EventEnd = true,
            ShopRefresh = true,
            SeasonPassEnd = true,
            LimitedStock = true,
        },

        -- Social proof
        SocialProof = {
            ShowPlayersWhoOwn = true,    -- "1,234 players own this pet!"
            ShowRecentPurchases = true,  -- "Player123 just bought this!"
            LeaderboardExclusives = true, -- Top players get exclusive pets
        },

        -- Scarcity messaging
        Scarcity = {
            LimitedQuantity = true,       -- "Only 1,000 available!"
            LastChance = true,            -- "Last day to get this pet!"
            NeverReturns = true,          -- "This pet will NEVER return!"
        },

        -- Regret avoidance
        RegretAvoidance = {
            ShowWhatYouMissed = true,     -- Show expired limited pets grayed out
            TradeValue = true,            -- Show how valuable limited pets become
            CollectionCompletion = true,  -- "You're missing 3 limited pets!"
        },
    },
}

--============================================================================
-- SECTION 10: UTILITY FUNCTIONS & CALCULATIONS
--============================================================================

-- Calculate total pet power for sorting/comparison
function PetSystem.CalculatePetPower(pet)
    local basePower = 0
    local rarityMultiplier = PetSystem.RarityTiers[pet.Rarity].StatMultiplierRange.Max

    -- Sum all base stats
    for statName, statValue in pairs(pet.BaseStats) do
        if type(statValue) == "number" then
            basePower = basePower + statValue
        end
    end

    -- Apply rarity multiplier
    basePower = basePower * rarityMultiplier

    -- Apply level scaling
    local levelMultiplier = 1 + ((pet.Level or 1) - 1) * 0.02
    basePower = basePower * levelMultiplier

    -- Apply shiny bonus
    if pet.IsShiny then
        basePower = basePower * 1.5
    end

    return math.floor(basePower * 100) / 100
end

-- Calculate egg hatch result
function PetSystem.RollEggHatch(eggId, luckBonus)
    local egg = PetSystem.Eggs[eggId]
    if not egg then return nil end

    luckBonus = luckBonus or 0

    -- Roll for rarity with luck bonus
    local roll = math.random() * 100
    local adjustedRoll = roll - (luckBonus * 0.1)  -- Luck shifts roll down

    local cumulative = 0
    local selectedRarity = "Common"

    -- Iterate in reverse order (Mythic first) for luck to favor rares
    local rarityOrder = {"Mythic", "Secret", "Legendary", "Epic", "Rare", "Uncommon", "Common"}

    for _, rarity in ipairs(rarityOrder) do
        cumulative = cumulative + (egg.RarityChances[rarity] or 0)
        if adjustedRoll <= cumulative then
            selectedRarity = rarity
            break
        end
    end

    -- Select random pet of that rarity from egg's pool
    local availablePets = {}
    for _, petId in ipairs(egg.AvailablePets) do
        local petData = PetSystem.PetTypes[petId]
        if petData then
            for _, availRarity in ipairs(petData.AvailableRarities) do
                if availRarity == selectedRarity then
                    table.insert(availablePets, petId)
                    break
                end
            end
        end
    end

    if #availablePets == 0 then
        -- Fallback: return any pet from egg at next available rarity
        return PetSystem.RollEggHatch(eggId, luckBonus)
    end

    local selectedPet = availablePets[math.random(1, #availablePets)]

    -- Shiny chance (base 1%, +0.01% per luck point)
    local shinyChance = 1 + (luckBonus * 0.01)
    local isShiny = math.random() * 100 < shinyChance

    return {
        PetId = selectedPet,
        Rarity = selectedRarity,
        IsShiny = isShiny,
        Level = 1,
    }
end

-- Calculate fusion result
function PetSystem.CalculateFusionResult(inputPets)
    if #inputPets < 3 then return nil end

    local fusionType = "Basic"
    local firstPet = inputPets[1]

    -- Check if all same pet (basic fusion)
    local allSame = true
    for i = 2, #inputPets do
        if inputPets[i].PetId ~= firstPet.PetId then
            allSame = false
            break
        end
    end

    if allSame and #inputPets == 3 then
        -- Basic fusion
        local roll = math.random() * 100

        if roll <= 70 then
            -- Same rarity, level boost
            return {
                PetId = firstPet.PetId,
                Rarity = firstPet.Rarity,
                Level = math.min((firstPet.Level or 1) + 10, PetSystem.Leveling.MaxLevel),
                IsShiny = firstPet.IsShiny,
            }
        elseif roll <= 95 then
            -- Rarity upgrade
            local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}
            local currentIndex = 1
            for i, r in ipairs(rarities) do
                if r == firstPet.Rarity then
                    currentIndex = i
                    break
                end
            end

            local newRarity = rarities[math.min(currentIndex + 1, #rarities)]

            return {
                PetId = firstPet.PetId,
                Rarity = newRarity,
                Level = 1,
                IsShiny = false,
            }
        else
            -- Shiny version
            return {
                PetId = firstPet.PetId,
                Rarity = firstPet.Rarity,
                Level = firstPet.Level or 1,
                IsShiny = true,
            }
        end
    end

    return nil
end

-- Calculate equipped pet bonuses
function PetSystem.CalculateEquippedBonuses(equippedPets)
    local bonuses = {
        ClickPower = 1.0,
        AutoClickRate = 0,
        AutoClickDamage = 0,
        CritChance = 5,  -- Base crit chance
        CritDamage = 1.5,  -- Base crit damage
        CoinBonus = 0,
        ExpBonus = 0,
        LuckBonus = 0,
        HomeworkDamage = {},
    }

    for _, pet in ipairs(equippedPets) do
        local petData = PetSystem.PetTypes[pet.PetId]
        if petData then
            local rarityMultiplier = PetSystem.RarityTiers[pet.Rarity].StatMultiplierRange.Max
            local levelMultiplier = 1 + ((pet.Level or 1) - 1) * 0.02
            local shinyMultiplier = pet.IsShiny and 1.5 or 1

            local totalMultiplier = rarityMultiplier * levelMultiplier * shinyMultiplier

            -- Apply stats
            for stat, value in pairs(petData.BaseStats) do
                if type(value) == "number" then
                    if stat == "ClickPower" then
                        bonuses.ClickPower = bonuses.ClickPower + (value * totalMultiplier - 1)
                    elseif stat == "AutoClick" then
                        bonuses.AutoClickRate = bonuses.AutoClickRate + (value * totalMultiplier)
                    elseif stat == "CritChance" then
                        bonuses.CritChance = bonuses.CritChance + (value * totalMultiplier)
                    elseif stat == "CritDamage" then
                        bonuses.CritDamage = bonuses.CritDamage + (value * totalMultiplier - 1)
                    elseif stat == "CoinBonus" then
                        bonuses.CoinBonus = bonuses.CoinBonus + (value * totalMultiplier)
                    elseif stat == "ExpBonus" then
                        bonuses.ExpBonus = bonuses.ExpBonus + (value * totalMultiplier)
                    elseif stat == "LuckBonus" then
                        bonuses.LuckBonus = bonuses.LuckBonus + (value * totalMultiplier)
                    end
                elseif type(value) == "table" and stat == "HomeworkDamage" then
                    for hwType, dmgBonus in pairs(value) do
                        bonuses.HomeworkDamage[hwType] = (bonuses.HomeworkDamage[hwType] or 1) + (dmgBonus - 1)
                    end
                end
            end
        end
    end

    -- Apply caps
    bonuses.CritChance = math.min(bonuses.CritChance, PetSystem.Mechanics.Critical.MaxCritChance)
    bonuses.CritDamage = math.min(bonuses.CritDamage, PetSystem.Mechanics.Critical.MaxCritDamage)
    bonuses.AutoClickRate = math.min(bonuses.AutoClickRate, PetSystem.Mechanics.AutoClick.MaxAutoClicksPerSecond)
    bonuses.CoinBonus = math.min(bonuses.CoinBonus, PetSystem.Mechanics.Bonuses.CoinBonus.MaxBonus)
    bonuses.ExpBonus = math.min(bonuses.ExpBonus, PetSystem.Mechanics.Bonuses.ExpBonus.MaxBonus)
    bonuses.LuckBonus = math.min(bonuses.LuckBonus, PetSystem.Mechanics.Bonuses.LuckBonus.MaxBonus)

    return bonuses
end

--============================================================================
-- SECTION 11: CONFIGURATION SUMMARY
--============================================================================

PetSystem.ConfigSummary = {
    --[[
    QUICK REFERENCE:

    RARITY TIERS (6 + 1 Secret):
    - Common: Gray, 1.0-1.5x stats, 1 shard
    - Uncommon: Green, 1.5-2.5x stats, 3 shards
    - Rare: Blue, 2.5-5.0x stats, 10 shards
    - Epic: Purple, 5.0-10.0x stats, 25 shards
    - Legendary: Gold, 10.0-25.0x stats, 75 shards
    - Mythic: Pink, 25.0-50.0x stats, 200 shards
    - Secret: Cyan, 30.0-75.0x stats, untradeable

    EGG PRICES:
    - Basic Egg: 500 Coins (70% Common)
    - Writing Egg: 2,500 Coins (45% Common)
    - Supplies Egg: 5,000 Coins (35% Common)
    - Book Egg: 10,000 Coins (25% Common)
    - Monster Egg: 15,000 Coins (20% Common, 0.2% Mythic)
    - Tech Egg: 25,000 Coins (0% Common, 0.5% Mythic)
    - Premium Egg: 100 Gems (2% Mythic)
    - Mythic Egg: 500 Gems (8% Mythic, Epic guaranteed minimum)

    PET LIMITS:
    - Base Storage: 50 slots (100 premium)
    - Max Storage: 500 slots
    - Base Equip: 3 slots (5 premium)
    - Max Equip: 10 slots

    LEVELING:
    - Max Level: 50
    - EXP scales 15% per level
    - +2% stats per level

    FUSION:
    - Basic: 3 same pets = upgrade
    - Cross: 5 different = random upgrade
    - 70% level boost / 25% rarity up / 5% shiny

    TRADING:
    - Level 15+ required
    - 3-day account age
    - 24-hour trade lock on new pets
    - Max 6 pets per trade side

    FOMO EVENTS:
    - 4 Seasonal (Back to School, Halloween, Winter, Summer)
    - Launch exclusive (Founder's Friend)
    - Milestone celebrations
    - Weekly rotating shop
    - 90-day season pass
    --]]
}

return PetSystem
