--[[
	BossConfig.lua

	Configuration for all boss homework types in Homework Destroyer
	Defines boss stats, behaviors, loot drops, and special mechanics for each zone

	Author: Homework Destroyer Team
	Version: 1.0
]]

local BossConfig = {}

-- ========================================
-- BOSS RARITY TIERS
-- ========================================

BossConfig.Rarities = {
	Normal = {
		NameColor = Color3.fromRGB(255, 255, 255),
		HealthBarColor = Color3.fromRGB(200, 50, 50),
		LootMultiplier = 1.0,
		SpawnChance = 1.0, -- Always spawns
	},
	Elite = {
		NameColor = Color3.fromRGB(255, 215, 0),
		HealthBarColor = Color3.fromRGB(255, 215, 0),
		LootMultiplier = 2.5,
		SpawnChance = 0.15, -- 15% chance
		HealthMultiplier = 1.5,
		DamageMultiplier = 1.5,
	},
	Legendary = {
		NameColor = Color3.fromRGB(255, 140, 0),
		HealthBarColor = Color3.fromRGB(255, 140, 0),
		LootMultiplier = 5.0,
		SpawnChance = 0.03, -- 3% chance
		HealthMultiplier = 2.5,
		DamageMultiplier = 2.0,
	},
}

-- ========================================
-- BOSS DEFINITIONS BY ZONE
-- ========================================

BossConfig.Bosses = {
	-- ========================================
	-- ZONE 1: THE CLASSROOM
	-- ========================================
	[1] = {
		ID = "MondayMorningTest",
		Name = "Monday Morning Test",
		Description = "The dreaded test that starts every week",

		-- Stats
		BaseHealth = 25000,
		BaseDamage = 50, -- Damage boss deals to players if it has attacks
		DefenseRating = 0, -- 0% damage reduction

		-- Spawn Settings
		SpawnInterval = 600, -- 10 minutes in seconds
		SpawnMessage = "A Monday Morning Test has appeared in the Classroom!",
		SpawnSound = "rbxassetid://1234567890", -- Would be actual sound ID

		-- Loot
		BaseDPReward = 5000,
		ExperienceReward = 500,

		-- Loot Table (additional drops)
		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 0.10, Amount = 1}, -- 10% chance
			{Item = "ClassroomEgg", Chance = 0.25, Amount = 1}, -- 25% chance
			{Item = "DestructionPoints", Chance = 1.0, Amount = 1000}, -- Bonus DP
		},

		-- Boss Mechanics
		Mechanics = {
			Type = "Stationary", -- Doesn't move
			AttackPattern = "None", -- Early boss, no special attacks
			SpecialAbilities = {},
		},

		-- Visual Settings
		Model = "MondayTest", -- Name of model in workspace or ReplicatedStorage
		Scale = 1.5,
		ParticleEffects = {
			Ambient = "PaperSwirl",
			OnHit = "PaperTear",
			OnDefeat = "PaperExplosion",
		},

		-- Audio
		AmbientSound = nil,
		HitSound = "rbxassetid://1234567891",
		DefeatSound = "rbxassetid://1234567892",

		-- Requirements
		RequiredLevel = 1,
		RequiredRebirth = 0,
	},

	-- ========================================
	-- ZONE 2: THE LIBRARY
	-- ========================================
	[2] = {
		ID = "OverdueLibraryBook",
		Name = "Overdue Library Book",
		Description = "A book so overdue, late fees have become sentient",

		BaseHealth = 75000,
		BaseDamage = 100,
		DefenseRating = 5, -- 5% damage reduction

		SpawnInterval = 600,
		SpawnMessage = "An Overdue Library Book has materialized in the Library!",
		SpawnSound = "rbxassetid://1234567893",

		BaseDPReward = 15000,
		ExperienceReward = 1500,

		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 0.12, Amount = 1},
			{Item = "LibraryEgg", Chance = 0.30, Amount = 1},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 3000},
			{Item = "RareGuaranteedEgg", Chance = 0.05, Amount = 1}, -- 5% rare egg
		},

		Mechanics = {
			Type = "Wandering", -- Moves around slowly
			AttackPattern = "PaperThrow", -- Throws pages at players
			SpecialAbilities = {
				{
					Name = "Knowledge Shield",
					Description = "Gains temporary 20% damage reduction",
					Cooldown = 30,
					Duration = 10,
					Effect = "DefenseBoost",
					Value = 0.20,
				},
			},
		},

		Model = "LibraryBook",
		Scale = 2.0,
		ParticleEffects = {
			Ambient = "FloatingPages",
			OnHit = "PageRip",
			OnDefeat = "BookExplosion",
		},

		AmbientSound = "rbxassetid://1234567894",
		HitSound = "rbxassetid://1234567895",
		DefeatSound = "rbxassetid://1234567896",

		RequiredLevel = 10,
		RequiredRebirth = 0,
	},

	-- ========================================
	-- ZONE 3: THE CAFETERIA
	-- ========================================
	[3] = {
		ID = "CafeteriaMysteryMeat",
		Name = "Cafeteria Mystery Meat",
		Description = "Nobody knows what it is, but it's angry",

		BaseHealth = 200000,
		BaseDamage = 200,
		DefenseRating = 10,

		SpawnInterval = 600,
		SpawnMessage = "The Cafeteria Mystery Meat has emerged!",
		SpawnSound = "rbxassetid://1234567897",

		BaseDPReward = 50000,
		ExperienceReward = 5000,

		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 0.15, Amount = 1},
			{Item = "CafeteriaEgg", Chance = 0.35, Amount = 2},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 10000},
			{Item = "RareGuaranteedEgg", Chance = 0.08, Amount = 1},
		},

		Mechanics = {
			Type = "Aggressive", -- Chases nearest player
			AttackPattern = "FoodSplatter",
			SpecialAbilities = {
				{
					Name = "Lunch Rush",
					Description = "Summons 3 smaller homework minions",
					Cooldown = 45,
					Duration = 20,
					Effect = "SummonMinions",
					Value = 3,
				},
				{
					Name = "Mystery Buff",
					Description = "Randomly gains damage or speed boost",
					Cooldown = 30,
					Duration = 15,
					Effect = "RandomBuff",
					Value = 0.30, -- 30% buff
				},
			},
		},

		Model = "MysteryMeat",
		Scale = 2.5,
		ParticleEffects = {
			Ambient = "Slime",
			OnHit = "Splatter",
			OnDefeat = "MeatExplosion",
		},

		AmbientSound = "rbxassetid://1234567898",
		HitSound = "rbxassetid://1234567899",
		DefeatSound = "rbxassetid://1234567900",

		RequiredLevel = 25,
		RequiredRebirth = 0,
	},

	-- ========================================
	-- ZONE 4: COMPUTER LAB
	-- ========================================
	[4] = {
		ID = "BlueScreenOfDoom",
		Name = "Blue Screen of Doom",
		Description = "ERROR: HOMEWORK.EXE has stopped responding",

		BaseHealth = 500000,
		BaseDamage = 400,
		DefenseRating = 15,

		SpawnInterval = 600,
		SpawnMessage = "CRITICAL ERROR: Blue Screen of Doom detected!",
		SpawnSound = "rbxassetid://1234567901",

		BaseDPReward = 150000,
		ExperienceReward = 15000,

		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 0.20, Amount = 2},
			{Item = "TechEgg", Chance = 0.40, Amount = 2},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 30000},
			{Item = "EpicGuaranteedEgg", Chance = 0.10, Amount = 1},
		},

		Mechanics = {
			Type = "Teleporting", -- Teleports around the zone
			AttackPattern = "ErrorSpam",
			SpecialAbilities = {
				{
					Name = "System Crash",
					Description = "AoE attack that damages all nearby players",
					Cooldown = 40,
					Duration = 3,
					Effect = "AreaDamage",
					Value = 500, -- Damage amount
					Radius = 30, -- Studs
				},
				{
					Name = "Firewall",
					Description = "Becomes immune to damage briefly",
					Cooldown = 60,
					Duration = 5,
					Effect = "Invulnerable",
					Value = 1.0,
				},
				{
					Name = "Virus Spread",
					Description = "Reduces player damage by 25% for 10 seconds",
					Cooldown = 35,
					Duration = 10,
					Effect = "PlayerDebuff",
					Value = 0.25,
				},
			},
		},

		Model = "BlueScreen",
		Scale = 3.0,
		ParticleEffects = {
			Ambient = "StaticGlitch",
			OnHit = "DigitalFragments",
			OnDefeat = "SystemShutdown",
		},

		AmbientSound = "rbxassetid://1234567902",
		HitSound = "rbxassetid://1234567903",
		DefeatSound = "rbxassetid://1234567904",

		RequiredLevel = 35,
		RequiredRebirth = 0,
	},

	-- ========================================
	-- ZONE 5: GYMNASIUM
	-- ========================================
	[5] = {
		ID = "CoachsFitnessTest",
		Name = "Coach's Impossible Fitness Test",
		Description = "100 push-ups, 100 sit-ups, 100 squats... impossible!",

		BaseHealth = 1500000,
		BaseDamage = 600,
		DefenseRating = 20,

		SpawnInterval = 600,
		SpawnMessage = "Drop and give me INFINITE! Coach's Fitness Test is here!",
		SpawnSound = "rbxassetid://1234567905",

		BaseDPReward = 500000,
		ExperienceReward = 50000,

		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 0.25, Amount = 2},
			{Item = "ScienceEgg", Chance = 0.45, Amount = 3},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 100000},
			{Item = "EpicGuaranteedEgg", Chance = 0.15, Amount = 1},
			{Item = "LegendaryGuaranteedEgg", Chance = 0.05, Amount = 1},
		},

		Mechanics = {
			Type = "PhaseChange", -- Changes behavior at health thresholds
			AttackPattern = "PhysicalAssault",
			SpecialAbilities = {
				{
					Name = "Whistle Blow",
					Description = "Stuns all players in range for 2 seconds",
					Cooldown = 45,
					Duration = 2,
					Effect = "StunPlayers",
					Value = 1.0,
					Radius = 40,
				},
				{
					Name = "Motivational Speech",
					Description = "Heals for 10% max health",
					Cooldown = 90,
					Duration = 1,
					Effect = "SelfHeal",
					Value = 0.10,
				},
				{
					Name = "Dodgeball Barrage",
					Description = "Rapid-fire projectile attack",
					Cooldown = 30,
					Duration = 8,
					Effect = "ProjectileBarrage",
					Value = 100, -- Damage per hit
					ProjectileCount = 20,
				},
			},

			-- Phase Changes
			Phases = {
				{
					HealthThreshold = 0.66, -- At 66% health
					Name = "Cardio Phase",
					SpeedMultiplier = 1.5,
					DamageMultiplier = 1.2,
					Announcement = "Coach is picking up the pace!",
				},
				{
					HealthThreshold = 0.33, -- At 33% health
					Name = "Final Exam Phase",
					SpeedMultiplier = 2.0,
					DamageMultiplier = 1.5,
					DefenseMultiplier = 1.3,
					Announcement = "Coach is going ALL OUT!",
				},
			},
		},

		Model = "CoachBoss",
		Scale = 3.5,
		ParticleEffects = {
			Ambient = "Sweat",
			OnHit = "WhistleBlow",
			OnDefeat = "ExerciseComplete",
		},

		AmbientSound = "rbxassetid://1234567906",
		HitSound = "rbxassetid://1234567907",
		DefeatSound = "rbxassetid://1234567908",

		RequiredLevel = 45,
		RequiredRebirth = 0,
	},

	-- ========================================
	-- ZONE 6: MUSIC ROOM
	-- ========================================
	[6] = {
		ID = "DiscordantSymphony",
		Name = "Discordant Symphony",
		Description = "An orchestra of chaos and cacophony",

		BaseHealth = 5000000,
		BaseDamage = 800,
		DefenseRating = 25,

		SpawnInterval = 600,
		SpawnMessage = "The Discordant Symphony begins its terrible performance!",
		SpawnSound = "rbxassetid://1234567909",

		BaseDPReward = 1500000,
		ExperienceReward = 150000,

		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 0.30, Amount = 3},
			{Item = "ArtEgg", Chance = 0.50, Amount = 3},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 300000},
			{Item = "EpicGuaranteedEgg", Chance = 0.20, Amount = 1},
			{Item = "LegendaryGuaranteedEgg", Chance = 0.08, Amount = 1},
		},

		Mechanics = {
			Type = "Rhythmic", -- Attacks follow rhythm patterns
			AttackPattern = "MusicalWaves",
			SpecialAbilities = {
				{
					Name = "Sonic Blast",
					Description = "Devastating sound wave damages and knockbacks players",
					Cooldown = 35,
					Duration = 2,
					Effect = "SonicWave",
					Value = 800,
					Radius = 50,
					Knockback = 60,
				},
				{
					Name = "Crescendo",
					Description = "Damage increases over time",
					Cooldown = 60,
					Duration = 20,
					Effect = "RampingDamage",
					Value = 0.05, -- 5% increase per second
				},
				{
					Name = "Sharp Notes",
					Description = "Summons musical note projectiles",
					Cooldown = 25,
					Duration = 12,
					Effect = "HomingProjectiles",
					Value = 150,
					ProjectileCount = 8,
				},
			},
		},

		Model = "Symphony",
		Scale = 4.0,
		ParticleEffects = {
			Ambient = "MusicalNotes",
			OnHit = "SoundWave",
			OnDefeat = "FinalChord",
		},

		AmbientSound = "rbxassetid://1234567910",
		HitSound = "rbxassetid://1234567911",
		DefeatSound = "rbxassetid://1234567912",

		RequiredLevel = 55,
		RequiredRebirth = 0,
	},

	-- ========================================
	-- ZONE 7: ART ROOM
	-- ========================================
	[7] = {
		ID = "MonstrousMasterpiece",
		Name = "Monstrous Masterpiece",
		Description = "A painting that became self-aware... and angry",

		BaseHealth = 20000000,
		BaseDamage = 1200,
		DefenseRating = 30,

		SpawnInterval = 600,
		SpawnMessage = "The Monstrous Masterpiece has come to life!",
		SpawnSound = "rbxassetid://1234567913",

		BaseDPReward = 6000000,
		ExperienceReward = 600000,

		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 0.35, Amount = 4},
			{Item = "ArtEgg", Chance = 0.60, Amount = 4},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 1000000},
			{Item = "LegendaryGuaranteedEgg", Chance = 0.12, Amount = 1},
			{Item = "MythicGuaranteedEgg", Chance = 0.03, Amount = 1},
		},

		Mechanics = {
			Type = "Shapeshifter", -- Changes forms during battle
			AttackPattern = "Creative",
			SpecialAbilities = {
				{
					Name = "Paint Splash",
					Description = "Slows players hit by 40% for 8 seconds",
					Cooldown = 30,
					Duration = 8,
					Effect = "SlowPlayers",
					Value = 0.40,
					Radius = 35,
				},
				{
					Name = "Abstract Form",
					Description = "Becomes harder to hit (50% evasion)",
					Cooldown = 60,
					Duration = 12,
					Effect = "Evasion",
					Value = 0.50,
				},
				{
					Name = "Artistic Vision",
					Description = "Creates illusory copies that attack players",
					Cooldown = 90,
					Duration = 30,
					Effect = "SummonClones",
					Value = 3, -- Number of clones
					CloneHealth = 0.20, -- 20% of boss health each
				},
			},

			Forms = {
				{Name = "Cubist", DefenseBonus = 0.20, SpeedPenalty = 0.10},
				{Name = "Impressionist", SpeedBonus = 0.30, DefensePenalty = 0.10},
				{Name = "Abstract", EvasionBonus = 0.25, DamageBonus = 0.15},
			},
		},

		Model = "Masterpiece",
		Scale = 5.0,
		ParticleEffects = {
			Ambient = "PaintDrips",
			OnHit = "ColorSplash",
			OnDefeat = "CanvasRip",
		},

		AmbientSound = "rbxassetid://1234567914",
		HitSound = "rbxassetid://1234567915",
		DefeatSound = "rbxassetid://1234567916",

		RequiredLevel = 65,
		RequiredRebirth = 0,
	},

	-- ========================================
	-- ZONE 8: SCIENCE LAB
	-- ========================================
	[8] = {
		ID = "FailedExperiment",
		Name = "Failed Experiment",
		Description = "What happens when chemistry goes VERY wrong",

		BaseHealth = 75000000,
		BaseDamage = 1800,
		DefenseRating = 35,

		SpawnInterval = 600,
		SpawnMessage = "WARNING: Failed Experiment has breached containment!",
		SpawnSound = "rbxassetid://1234567917",

		BaseDPReward = 25000000,
		ExperienceReward = 2500000,

		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 0.40, Amount = 5},
			{Item = "ScienceEgg", Chance = 0.70, Amount = 5},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 5000000},
			{Item = "LegendaryGuaranteedEgg", Chance = 0.20, Amount = 1},
			{Item = "MythicGuaranteedEgg", Chance = 0.05, Amount = 1},
		},

		Mechanics = {
			Type = "Elemental", -- Uses elemental attacks
			AttackPattern = "Chemical",
			SpecialAbilities = {
				{
					Name = "Acid Rain",
					Description = "DoT effect on entire zone",
					Cooldown = 45,
					Duration = 15,
					Effect = "ZoneDoT",
					Value = 100, -- Damage per second
				},
				{
					Name = "Explosive Reaction",
					Description = "Massive explosion when hit below 50% health",
					Cooldown = 120,
					Duration = 1,
					Effect = "CounterExplosion",
					Value = 2000,
					Radius = 60,
					Trigger = 0.50, -- Triggers at 50% health
				},
				{
					Name = "Toxic Cloud",
					Description = "Reduces player healing by 75%",
					Cooldown = 40,
					Duration = 20,
					Effect = "HealingDebuff",
					Value = 0.75,
					Radius = 45,
				},
				{
					Name = "Mutation",
					Description = "Adapts to damage type, gaining resistance",
					Cooldown = 30,
					Duration = 15,
					Effect = "AdaptiveDefense",
					Value = 0.30, -- 30% resistance to last damage source
				},
			},
		},

		Model = "Experiment",
		Scale = 6.0,
		ParticleEffects = {
			Ambient = "BubblingChemicals",
			OnHit = "ChemicalSplash",
			OnDefeat = "LabExplosion",
		},

		AmbientSound = "rbxassetid://1234567918",
		HitSound = "rbxassetid://1234567919",
		DefeatSound = "rbxassetid://1234567920",

		RequiredLevel = 75,
		RequiredRebirth = 0,
	},

	-- ========================================
	-- ZONE 9: PRINCIPAL'S OFFICE
	-- ========================================
	[9] = {
		ID = "ThePrincipal",
		Name = "THE PRINCIPAL",
		Description = "The ultimate authority figure and your final obstacle",

		BaseHealth = 500000000,
		BaseDamage = 3000,
		DefenseRating = 45,

		SpawnInterval = 900, -- 15 minutes
		SpawnMessage = "ATTENTION: THE PRINCIPAL has entered the office!",
		SpawnSound = "rbxassetid://1234567921",

		BaseDPReward = 200000000,
		ExperienceReward = 20000000,

		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 0.50, Amount = 10},
			{Item = "PrincipalEgg", Chance = 0.80, Amount = 5},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 50000000},
			{Item = "LegendaryGuaranteedEgg", Chance = 0.30, Amount = 2},
			{Item = "MythicGuaranteedEgg", Chance = 0.10, Amount = 1},
			{Item = "PrincipalsGoldenPen", Chance = 0.01, Amount = 1}, -- Special tool drop
		},

		Mechanics = {
			Type = "MultiphaseEnraged", -- Complex multi-phase boss
			AttackPattern = "Authoritative",
			SpecialAbilities = {
				{
					Name = "Detention",
					Description = "Traps player in bubble, preventing movement",
					Cooldown = 50,
					Duration = 8,
					Effect = "ImmobilizePlayer",
					Value = 1.0,
				},
				{
					Name = "Suspension",
					Description = "Kicks player out of zone temporarily",
					Cooldown = 120,
					Duration = 10,
					Effect = "Banish",
					Value = 1.0,
				},
				{
					Name = "Call Security",
					Description = "Summons security homework minions",
					Cooldown = 60,
					Duration = 40,
					Effect = "SummonMinions",
					Value = 5,
					MinionType = "SecurityGuard",
				},
				{
					Name = "Authority Aura",
					Description = "Intimidates players, reducing their damage by 30%",
					Cooldown = 45,
					Duration = 15,
					Effect = "PlayerDebuff",
					Value = 0.30,
					Radius = 80,
				},
				{
					Name = "Permanent Record",
					Description = "Marks player for increased damage taken",
					Cooldown = 90,
					Duration = 25,
					Effect = "VulnerabilityMark",
					Value = 0.40, -- 40% more damage taken
				},
			},

			Phases = {
				{
					HealthThreshold = 0.75,
					Name = "Stern Warning",
					SpeedMultiplier = 1.1,
					DamageMultiplier = 1.2,
					Announcement = "THE PRINCIPAL is giving you a stern warning!",
				},
				{
					HealthThreshold = 0.50,
					Name = "Detention Notice",
					SpeedMultiplier = 1.3,
					DamageMultiplier = 1.5,
					DefenseMultiplier = 1.2,
					Announcement = "THE PRINCIPAL is writing you up!",
					AbilityCooldownReduction = 0.25, -- 25% faster abilities
				},
				{
					HealthThreshold = 0.25,
					Name = "FINAL SUSPENSION",
					SpeedMultiplier = 1.5,
					DamageMultiplier = 2.0,
					DefenseMultiplier = 1.5,
					Announcement = "THE PRINCIPAL IS FURIOUS!",
					AbilityCooldownReduction = 0.50, -- 50% faster abilities
					Enraged = true,
				},
			},
		},

		Model = "Principal",
		Scale = 7.0,
		ParticleEffects = {
			Ambient = "AuthorityGlow",
			OnHit = "DisciplineStrike",
			OnDefeat = "OfficeCollapse",
		},

		AmbientSound = "rbxassetid://1234567922",
		HitSound = "rbxassetid://1234567923",
		DefeatSound = "rbxassetid://1234567924",

		RequiredLevel = 90,
		RequiredRebirth = 3,
	},

	-- ========================================
	-- ZONE 10: THE VOID (SECRET ENDGAME)
	-- ========================================
	[10] = {
		ID = "HomeworkOverlord",
		Name = "HOMEWORK OVERLORD",
		Description = "The manifestation of all homework ever assigned",

		BaseHealth = 100000000000, -- 100 billion
		BaseDamage = 5000,
		DefenseRating = 60,

		SpawnInterval = 1200, -- 20 minutes
		SpawnMessage = "REALITY FRACTURES... THE HOMEWORK OVERLORD AWAKENS!",
		SpawnSound = "rbxassetid://1234567925",

		BaseDPReward = 50000000000, -- 50 billion
		ExperienceReward = 50000000,

		LootTable = {
			{Item = "ToolUpgradeToken", Chance = 1.0, Amount = 25},
			{Item = "VoidEgg", Chance = 1.0, Amount = 10},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 10000000000},
			{Item = "MythicGuaranteedEgg", Chance = 0.50, Amount = 3},
			{Item = "VoidEraser", Chance = 0.001, Amount = 1}, -- 0.1% chance for SECRET tool
			{Item = "RebirthTokens", Chance = 1.0, Amount = 5},
		},

		Mechanics = {
			Type = "VoidBoss", -- Ultimate endgame boss
			AttackPattern = "Apocalyptic",
			SpecialAbilities = {
				{
					Name = "Homework Storm",
					Description = "Meteors of homework rain from the sky",
					Cooldown = 40,
					Duration = 10,
					Effect = "MeteorStorm",
					Value = 800,
					MeteorCount = 50,
				},
				{
					Name = "Reality Warp",
					Description = "Teleports all players randomly and disorients them",
					Cooldown = 60,
					Duration = 5,
					Effect = "ScramblePlayers",
					Value = 1.0,
				},
				{
					Name = "Void Consume",
					Description = "Drains player health and converts to boss health",
					Cooldown = 90,
					Duration = 8,
					Effect = "HealthDrain",
					Value = 500, -- HP drained per second
					ConversionRate = 0.50, -- 50% converted to boss healing
				},
				{
					Name = "Assignment Overload",
					Description = "Creates clones of all players' worst homework",
					Cooldown = 120,
					Duration = 60,
					Effect = "SummonElites",
					Value = 10,
					EliteHealth = 10000000,
				},
				{
					Name = "Dimensional Shift",
					Description = "Becomes immune and resets position",
					Cooldown = 180,
					Duration = 10,
					Effect = "PhaseShift",
					Value = 1.0,
				},
				{
					Name = "Gravity Manipulation",
					Description = "Inverts gravity, making players float",
					Cooldown = 75,
					Duration = 15,
					Effect = "GravityInvert",
					Value = 1.0,
				},
			},

			Phases = {
				{
					HealthThreshold = 0.90,
					Name = "Awakening",
					DamageMultiplier = 1.1,
					Announcement = "The Overlord stirs...",
				},
				{
					HealthThreshold = 0.75,
					Name = "Rising Power",
					SpeedMultiplier = 1.2,
					DamageMultiplier = 1.3,
					Announcement = "Homework energy surges!",
				},
				{
					HealthThreshold = 0.50,
					Name = "Full Power",
					SpeedMultiplier = 1.4,
					DamageMultiplier = 1.6,
					DefenseMultiplier = 1.3,
					Announcement = "THE OVERLORD REACHES FULL POWER!",
					AbilityCooldownReduction = 0.30,
				},
				{
					HealthThreshold = 0.25,
					Name = "DESPERATE FURY",
					SpeedMultiplier = 1.8,
					DamageMultiplier = 2.5,
					DefenseMultiplier = 1.6,
					Announcement = "REALITY CRUMBLES! THE OVERLORD IS DESPERATE!",
					AbilityCooldownReduction = 0.60,
					Enraged = true,
					CounterAttack = true, -- Boss attacks back when hit
				},
				{
					HealthThreshold = 0.10,
					Name = "FINAL STAND",
					SpeedMultiplier = 2.0,
					DamageMultiplier = 3.0,
					DefenseMultiplier = 2.0,
					Announcement = "THIS IS THE END! DESTROY OR BE DESTROYED!",
					AbilityCooldownReduction = 0.75,
					Enraged = true,
					Berserk = true, -- All abilities on rapid cooldown
					CounterAttack = true,
				},
			},

			-- Environmental hazards active during fight
			EnvironmentalHazards = {
				{Name = "VoidZone", Damage = 200, Interval = 2},
				{Name = "HomeworkRain", Damage = 150, Interval = 5},
				{Name = "RealityCrack", Damage = 300, Interval = 10},
			},
		},

		Model = "Overlord",
		Scale = 10.0,
		ParticleEffects = {
			Ambient = "VoidEnergy",
			OnHit = "RealityShatter",
			OnDefeat = "DimensionalCollapse",
		},

		AmbientSound = "rbxassetid://1234567926",
		HitSound = "rbxassetid://1234567927",
		DefeatSound = "rbxassetid://1234567928",

		RequiredLevel = 100,
		RequiredRebirth = 25,
		RequiredPrestige = 3,
	},
}

-- ========================================
-- SPECIAL BOSS EVENTS
-- ========================================

BossConfig.SpecialBosses = {
	-- Weekend Boss Event
	UltimateFinalExam = {
		ID = "UltimateFinalExam",
		Name = "Ultimate Final Exam",
		Description = "The boss required for first rebirth",

		BaseHealth = 1000000,
		BaseDamage = 500,
		DefenseRating = 15,

		SpawnCondition = "PlayerLevel100", -- Only spawns for level 100 players
		SpawnLocation = "Classroom", -- Spawns in Zone 1
		SpawnMessage = "The Ultimate Final Exam awaits you!",

		BaseDPReward = 100000,
		ExperienceReward = 0, -- No XP since player is max level

		LootTable = {
			{Item = "RebirthToken", Chance = 1.0, Amount = 1},
			{Item = "DestructionPoints", Chance = 1.0, Amount = 50000},
			{Item = "EpicGuaranteedEgg", Chance = 0.50, Amount = 1},
		},

		Mechanics = {
			Type = "RebirthGate",
			AttackPattern = "FinalExam",
			SpecialAbilities = {
				{
					Name = "Pop Quiz",
					Description = "Rapid fire questions (projectiles)",
					Cooldown = 20,
					Duration = 8,
					Effect = "ProjectileBarrage",
					Value = 100,
					ProjectileCount = 30,
				},
			},
		},

		Model = "FinalExam",
		Scale = 4.0,

		RequiredLevel = 100,
		RequiredToRebirth = true,
	},

	-- Seasonal Event Boss (Example)
	WinterHomeworkMountain = {
		ID = "WinterHomeworkMountain",
		Name = "Winter Homework Mountain",
		Description = "All the homework assigned over winter break",

		BaseHealth = 50000000,
		BaseDamage = 1500,
		DefenseRating = 25,

		EventOnly = true,
		EventName = "WinterBreak",

		BaseDPReward = 10000000,
		ExperienceReward = 1000000,

		LootTable = {
			{Item = "Snowball", Chance = 1.0, Amount = 1}, -- Special event pet
			{Item = "CandyCaneDestroyer", Chance = 0.05, Amount = 1}, -- Event tool
			{Item = "WinterBox", Chance = 0.80, Amount = 3},
		},
	},
}

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

-- Get boss configuration for a zone
function BossConfig.GetBossForZone(zoneId)
	return BossConfig.Bosses[zoneId]
end

-- Calculate boss stats with scaling
function BossConfig.CalculateBossStats(bossData, playerCount, averageLevel, averageRebirth)
	local stats = {
		Health = bossData.BaseHealth,
		Damage = bossData.BaseDamage,
		Defense = bossData.DefenseRating,
	}

	-- Scale based on player count (10% increase per additional player)
	if playerCount > 1 then
		local playerScaling = 1 + ((playerCount - 1) * 0.10)
		stats.Health = stats.Health * playerScaling
		stats.Damage = stats.Damage * playerScaling
	end

	-- Scale based on average player level (1% increase per level above minimum)
	local levelRequirement = bossData.RequiredLevel or 1
	if averageLevel > levelRequirement then
		local levelScaling = 1 + ((averageLevel - levelRequirement) * 0.01)
		stats.Health = stats.Health * levelScaling
	end

	-- Scale based on average rebirth (25% increase per rebirth)
	if averageRebirth > 0 then
		local rebirthScaling = 1 + (averageRebirth * 0.25)
		stats.Health = stats.Health * rebirthScaling
		stats.Damage = stats.Damage * rebirthScaling
	end

	return stats
end

-- Determine boss rarity on spawn
function BossConfig.DetermineBossRarity()
	local rand = math.random()

	if rand <= BossConfig.Rarities.Legendary.SpawnChance then
		return "Legendary", BossConfig.Rarities.Legendary
	elseif rand <= BossConfig.Rarities.Elite.SpawnChance then
		return "Elite", BossConfig.Rarities.Elite
	else
		return "Normal", BossConfig.Rarities.Normal
	end
end

-- Calculate loot rewards
function BossConfig.CalculateLoot(bossData, rarity, participantCount)
	local loot = {}
	local rarityData = BossConfig.Rarities[rarity]

	-- Base DP reward
	local dpReward = bossData.BaseDPReward * (rarityData.LootMultiplier or 1.0)
	loot.DP = math.floor(dpReward)

	-- XP reward
	loot.XP = bossData.ExperienceReward

	-- Process loot table
	loot.Items = {}
	for _, drop in ipairs(bossData.LootTable) do
		-- Apply rarity multiplier to drop chance
		local dropChance = drop.Chance * (rarityData.LootMultiplier or 1.0)
		dropChance = math.min(dropChance, 1.0) -- Cap at 100%

		if math.random() <= dropChance then
			table.insert(loot.Items, {
				Item = drop.Item,
				Amount = drop.Amount or 1,
			})
		end
	end

	return loot
end

-- Get boss spawn interval
function BossConfig.GetSpawnInterval(zoneId)
	local bossData = BossConfig.Bosses[zoneId]
	return bossData and bossData.SpawnInterval or 600
end

-- Check if player meets boss requirements
function BossConfig.CanPlayerFightBoss(playerData, bossData)
	-- Check level
	if playerData.Level < (bossData.RequiredLevel or 1) then
		return false, "Level too low"
	end

	-- Check rebirth
	if playerData.RebirthLevel < (bossData.RequiredRebirth or 0) then
		return false, "Rebirth requirement not met"
	end

	-- Check prestige (for Void boss)
	if bossData.RequiredPrestige and playerData.PrestigeRank < bossData.RequiredPrestige then
		return false, "Prestige requirement not met"
	end

	return true, "Eligible"
end

return BossConfig
