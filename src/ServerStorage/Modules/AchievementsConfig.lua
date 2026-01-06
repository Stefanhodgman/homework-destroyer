--[[
	AchievementsConfig.lua

	Defines all achievements for Homework Destroyer
	Based on GameDesign.md specifications

	Achievement Categories:
	- Destruction (10 achievements)
	- Boss (5 achievements)
	- Zone (5 achievements)
	- Rebirth (5 achievements)
	- Collection (7 achievements)
	- Special (5 achievements)
	- Secret (5 achievements)

	Total: 42 achievements

	Author: Homework Destroyer Team
	Version: 1.0
]]

local AchievementsConfig = {}

--[[
	Achievement Structure:
	{
		ID = "UniqueAchievementID",
		Name = "Display Name",
		Description = "What the player must do",
		Category = "Destruction/Boss/Zone/Rebirth/Collection/Special/Secret",
		Icon = "rbxassetid://...", -- Optional
		Hidden = boolean, -- True for secret achievements

		-- Requirement (one of these):
		RequirementType = "Count/Stat/Collection/Custom",
		StatToTrack = "PlayerData.Path.To.Stat",
		RequiredValue = number,
		CustomCheck = function(playerData) return boolean end,

		-- Rewards
		Rewards = {
			DP = number,
			ToolTokens = number,
			Eggs = {EggType = count},
			Title = "Title Name",
			Badge = "BadgeName", -- For Roblox badge integration
			Multiplier = {Type = "Damage/DP/XP", Amount = 0.05}, -- Permanent 5% boost
			Unlock = "FeatureName", -- Special unlocks
			Aura = "AuraName", -- Visual effect
			PetSlot = true, -- Adds a pet slot
		}
	}
]]

-- ============================================================
-- DESTRUCTION ACHIEVEMENTS (10)
-- ============================================================

AchievementsConfig.Destruction = {
	{
		ID = "FirstSteps",
		Name = "First Steps",
		Description = "Destroy 10 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 10,

		Rewards = {
			DP = 100,
			Title = "Beginner",
		}
	},

	{
		ID = "PaperShredder",
		Name = "Paper Shredder",
		Description = "Destroy 100 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 100,

		Rewards = {
			DP = 500,
		}
	},

	{
		ID = "AssignmentAssassin",
		Name = "Assignment Assassin",
		Description = "Destroy 1,000 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 1000,

		Rewards = {
			DP = 2500,
			Multiplier = {Type = "Damage", Amount = 0.05}, -- +5% permanent damage
		}
	},

	{
		ID = "HomeworkHater",
		Name = "Homework Hater",
		Description = "Destroy 10,000 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 10000,

		Rewards = {
			DP = 25000,
			Eggs = {UncommonGuaranteedEgg = 1},
		}
	},

	{
		ID = "DestructionMachine",
		Name = "Destruction Machine",
		Description = "Destroy 100,000 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 100000,

		Rewards = {
			DP = 250000,
			Eggs = {RareGuaranteedEgg = 1},
		}
	},

	{
		ID = "AnnihilationExpert",
		Name = "Annihilation Expert",
		Description = "Destroy 1,000,000 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 1000000,

		Rewards = {
			DP = 2500000,
			Eggs = {EpicGuaranteedEgg = 1},
			Title = "Expert",
		}
	},

	{
		ID = "ApocalypseBringer",
		Name = "Apocalypse Bringer",
		Description = "Destroy 10,000,000 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 10000000,

		Rewards = {
			DP = 25000000,
			Eggs = {LegendaryGuaranteedEgg = 1},
		}
	},

	{
		ID = "CosmicDestroyer",
		Name = "Cosmic Destroyer",
		Description = "Destroy 100,000,000 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 100000000,

		Rewards = {
			DP = 250000000,
			Eggs = {MythicGuaranteedEgg = 1},
			Title = "Cosmic",
		}
	},

	{
		ID = "RealityBreaker",
		Name = "Reality Breaker",
		Description = "Destroy 1,000,000,000 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 1000000000,

		Rewards = {
			DP = 2500000000,
			Aura = "Reality",
		}
	},

	{
		ID = "TheDestroyer",
		Name = "THE DESTROYER",
		Description = "Destroy 10,000,000,000 homework",
		Category = "Destruction",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalHomeworkDestroyed",
		RequiredValue = 10000000000,

		Rewards = {
			DP = 25000000000,
			Title = "THE DESTROYER",
			Aura = "RainbowName",
		}
	},
}

-- ============================================================
-- BOSS ACHIEVEMENTS (5)
-- ============================================================

AchievementsConfig.Boss = {
	{
		ID = "BossFighter",
		Name = "Boss Fighter",
		Description = "Defeat any boss",
		Category = "Boss",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalBossesDefeated",
		RequiredValue = 1,

		Rewards = {
			DP = 5000,
		}
	},

	{
		ID = "BossHunter",
		Name = "Boss Hunter",
		Description = "Defeat 10 bosses",
		Category = "Boss",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalBossesDefeated",
		RequiredValue = 10,

		Rewards = {
			DP = 50000,
			Multiplier = {Type = "BossDamage", Amount = 0.10}, -- +10% boss damage permanent
		}
	},

	{
		ID = "BossSlayer",
		Name = "Boss Slayer",
		Description = "Defeat 100 bosses",
		Category = "Boss",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalBossesDefeated",
		RequiredValue = 100,

		Rewards = {
			DP = 500000,
			Title = "Slayer",
		}
	},

	{
		ID = "BossNightmare",
		Name = "Boss Nightmare",
		Description = "Defeat 1,000 bosses",
		Category = "Boss",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalBossesDefeated",
		RequiredValue = 1000,

		Rewards = {
			DP = 5000000,
			Unlock = "BossThemePet", -- Special boss-themed pet
		}
	},

	{
		ID = "BossExterminator",
		Name = "Boss Exterminator",
		Description = "Defeat THE PRINCIPAL 100 times",
		Category = "Boss",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return (playerData.LifetimeStats.PrincipalDefeats or 0) >= 100
		end,

		Rewards = {
			DP = 50000000,
			Title = "Principal's Nightmare",
			Badge = "GoldenBadge",
		}
	},
}

-- ============================================================
-- ZONE ACHIEVEMENTS (5)
-- ============================================================

AchievementsConfig.Zone = {
	{
		ID = "Explorer",
		Name = "Explorer",
		Description = "Unlock 3 zones",
		Category = "Zone",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return #playerData.UnlockedZones >= 3
		end,

		Rewards = {
			DP = 10000,
		}
	},

	{
		ID = "Adventurer",
		Name = "Adventurer",
		Description = "Unlock 5 zones",
		Category = "Zone",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return #playerData.UnlockedZones >= 5
		end,

		Rewards = {
			DP = 100000,
			Multiplier = {Type = "MovementSpeed", Amount = 0.10}, -- +10% movement speed
		}
	},

	{
		ID = "WorldTraveler",
		Name = "World Traveler",
		Description = "Unlock all main zones (1-9)",
		Category = "Zone",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			if #playerData.UnlockedZones < 9 then
				return false
			end
			-- Check for zones 1-9
			for i = 1, 9 do
				if not table.find(playerData.UnlockedZones, i) then
					return false
				end
			end
			return true
		end,

		Rewards = {
			DP = 1000000,
			Title = "Traveler",
		}
	},

	{
		ID = "VoidWalker",
		Name = "Void Walker",
		Description = "Enter The Void (Zone 10)",
		Category = "Zone",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return table.find(playerData.UnlockedZones, 10) ~= nil
		end,

		Rewards = {
			DP = 10000000,
			Aura = "VoidParticles",
		}
	},

	{
		ID = "MasterOfAll",
		Name = "Master of All",
		Description = "Complete all zone challenges",
		Category = "Zone",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			-- Would check for zone-specific challenge completion
			return (playerData.ZoneChallengesCompleted or 0) >= 10
		end,

		Rewards = {
			DP = 100000000,
			Title = "Master",
			Multiplier = {Type = "AllZoneDamage", Amount = 0.25}, -- +25% damage in all zones
		}
	},
}

-- ============================================================
-- REBIRTH ACHIEVEMENTS (5)
-- ============================================================

AchievementsConfig.Rebirth = {
	{
		ID = "BornAgain",
		Name = "Born Again",
		Description = "Complete your first rebirth",
		Category = "Rebirth",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalRebirths",
		RequiredValue = 1,

		Rewards = {
			DP = 10000,
			Title = "Reborn",
		}
	},

	{
		ID = "CycleBreaker",
		Name = "Cycle Breaker",
		Description = "Reach Rebirth 5",
		Category = "Rebirth",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "RebirthLevel",
		RequiredValue = 5,

		Rewards = {
			DP = 100000,
			Multiplier = {Type = "RebirthMultiplier", Amount = 0.10}, -- +10% rebirth multiplier
		}
	},

	{
		ID = "EternalStudent",
		Name = "Eternal Student",
		Description = "Reach Rebirth 10",
		Category = "Rebirth",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "RebirthLevel",
		RequiredValue = 10,

		Rewards = {
			DP = 1000000,
			Unlock = "ExclusiveRebirthPet",
		}
	},

	{
		ID = "TimeLord",
		Name = "Time Lord",
		Description = "Reach Rebirth 25",
		Category = "Rebirth",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "RebirthLevel",
		RequiredValue = 25,

		Rewards = {
			DP = 10000000,
			Title = "Time Lord",
		}
	},

	{
		ID = "InfiniteLoop",
		Name = "Infinite Loop",
		Description = "Reach Rebirth 50",
		Category = "Rebirth",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "RebirthLevel",
		RequiredValue = 50,

		Rewards = {
			DP = 100000000,
			Aura = "Infinite",
			Multiplier = {Type = "XP", Amount = 1.0}, -- Permanent 2x XP (100% = double)
		}
	},
}

-- ============================================================
-- COLLECTION ACHIEVEMENTS (7)
-- ============================================================

AchievementsConfig.Collection = {
	{
		ID = "ToolCollector",
		Name = "Tool Collector",
		Description = "Own 5 different tools",
		Category = "Collection",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return #playerData.Tools.Owned >= 5
		end,

		Rewards = {
			DP = 5000,
		}
	},

	{
		ID = "ArsenalBuilder",
		Name = "Arsenal Builder",
		Description = "Own 10 different tools",
		Category = "Collection",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return #playerData.Tools.Owned >= 10
		end,

		Rewards = {
			DP = 50000,
			Unlock = "ToolInventoryExpansion",
		}
	},

	{
		ID = "WeaponMaster",
		Name = "Weapon Master",
		Description = "Own all tools",
		Category = "Collection",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return #playerData.Tools.Owned >= 18 -- 18 total tools in game
		end,

		Rewards = {
			DP = 5000000,
			Title = "Weapon Master",
		}
	},

	{
		ID = "PetLover",
		Name = "Pet Lover",
		Description = "Own 5 different pets",
		Category = "Collection",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return #playerData.Pets.Owned >= 5
		end,

		Rewards = {
			DP = 5000,
			PetSlot = true, -- +1 pet slot
		}
	},

	{
		ID = "PetHoarder",
		Name = "Pet Hoarder",
		Description = "Own 15 different pets",
		Category = "Collection",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return #playerData.Pets.Owned >= 15
		end,

		Rewards = {
			DP = 100000,
			Multiplier = {Type = "PetDamage", Amount = 0.15}, -- +15% pet damage
		}
	},

	{
		ID = "LegendaryTamer",
		Name = "Legendary Tamer",
		Description = "Own 3 Legendary pets",
		Category = "Collection",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			local legendaryCount = 0
			for _, pet in ipairs(playerData.Pets.Owned) do
				if pet.Rarity == "Legendary" then
					legendaryCount = legendaryCount + 1
				end
			end
			return legendaryCount >= 3
		end,

		Rewards = {
			DP = 1000000,
		}
	},

	{
		ID = "MythicMaster",
		Name = "Mythic Master",
		Description = "Own a Mythic pet",
		Category = "Collection",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			for _, pet in ipairs(playerData.Pets.Owned) do
				if pet.Rarity == "Mythic" then
					return true
				end
			end
			return false
		end,

		Rewards = {
			DP = 10000000,
			Title = "Mythic Master",
		}
	},
}

-- ============================================================
-- SPECIAL ACHIEVEMENTS (5)
-- ============================================================

AchievementsConfig.Special = {
	{
		ID = "SpeedDemon",
		Name = "Speed Demon",
		Description = "Destroy 100 homework in 1 minute",
		Category = "Special",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			-- Checked by server during gameplay session tracking
			return (playerData.AchievementProgress.SpeedDemonComplete or false)
		end,

		Rewards = {
			DP = 25000,
			Multiplier = {Type = "Speed", Amount = 0.05}, -- Permanent +5% speed
		}
	},

	{
		ID = "CriticalKing",
		Name = "Critical King",
		Description = "Land 50 critical hits in a row",
		Category = "Special",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			-- Tracked during gameplay sessions
			return (playerData.AchievementProgress.CriticalKingComplete or false)
		end,

		Rewards = {
			DP = 50000,
			Multiplier = {Type = "CritChance", Amount = 0.05}, -- +5% permanent crit
		}
	},

	{
		ID = "Untouchable",
		Name = "Untouchable",
		Description = "Defeat a boss without taking damage (Void only)",
		Category = "Special",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return (playerData.AchievementProgress.UntouchableComplete or false)
		end,

		Rewards = {
			DP = 1000000,
			Title = "Untouchable",
		}
	},

	{
		ID = "Millionaire",
		Name = "Millionaire",
		Description = "Accumulate 1,000,000 DP at once",
		Category = "Special",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "DestructionPoints",
		RequiredValue = 1000000,

		Rewards = {
			DP = 100000, -- Bonus DP
		}
	},

	{
		ID = "Billionaire",
		Name = "Billionaire",
		Description = "Accumulate 1,000,000,000 DP at once",
		Category = "Special",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Count",
		StatToTrack = "DestructionPoints",
		RequiredValue = 1000000000,

		Rewards = {
			DP = 100000000, -- Bonus DP
			Badge = "Billionaire",
		}
	},
}

-- ============================================================
-- SECRET ACHIEVEMENTS (5)
-- ============================================================

AchievementsConfig.Secret = {
	{
		ID = "NightOwl",
		Name = "Night Owl",
		Description = "Play at 3 AM server time",
		Category = "Secret",
		Icon = "rbxassetid://0",
		Hidden = true,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			-- Checked by server when player is active
			return (playerData.Achievements.NightOwl ~= false)
		end,

		Rewards = {
			DP = 10000,
			Title = "Night Owl",
		}
	},

	{
		ID = "MarathonRunner",
		Name = "Marathon Runner",
		Description = "Play for 10 hours total",
		Category = "Secret",
		Icon = "rbxassetid://0",
		Hidden = true,

		RequirementType = "Count",
		StatToTrack = "LifetimeStats.TotalPlayTime",
		RequiredValue = 36000, -- 10 hours in seconds

		Rewards = {
			DP = 50000,
		}
	},

	{
		ID = "OldTimer",
		Name = "Old Timer",
		Description = "Return after 30+ days away",
		Category = "Secret",
		Icon = "rbxassetid://0",
		Hidden = true,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			-- Checked by server on login
			return (playerData.Achievements.OldTimer ~= false)
		end,

		Rewards = {
			DP = 100000,
			Unlock = "ReturneeGiftBox",
		}
	},

	{
		ID = "EasterEggHunter",
		Name = "Easter Egg Hunter",
		Description = "Find the hidden classroom message",
		Category = "Secret",
		Icon = "rbxassetid://0",
		Hidden = true,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return (playerData.AchievementProgress.EasterEggFound or false)
		end,

		Rewards = {
			DP = 25000,
			Unlock = "SecretPet_???",
		}
	},

	{
		ID = "TheOne",
		Name = "The One",
		Description = "Deal exactly 1,000,000 damage in one hit",
		Category = "Secret",
		Icon = "rbxassetid://0",
		Hidden = true,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			return (playerData.AchievementProgress.TheOneComplete or false)
		end,

		Rewards = {
			DP = 500000,
			Title = "The One",
		}
	},
}

-- ============================================================
-- TRUE COMPLETIONIST (Meta Achievement)
-- ============================================================

AchievementsConfig.Meta = {
	{
		ID = "TrueCompletionist",
		Name = "True Completionist",
		Description = "Earn all other achievements",
		Category = "Special",
		Icon = "rbxassetid://0",
		Hidden = false,

		RequirementType = "Custom",
		CustomCheck = function(playerData)
			-- Count total unlocked achievements (excluding this one)
			local unlockedCount = 0
			for achievementID, timestamp in pairs(playerData.Achievements) do
				if achievementID ~= "TrueCompletionist" and timestamp ~= false then
					unlockedCount = unlockedCount + 1
				end
			end
			-- 42 total achievements (excluding TrueCompletionist)
			return unlockedCount >= 42
		end,

		Rewards = {
			DP = 1000000000,
			Title = "Completionist",
			Aura = "RainbowCompletionist",
			Unlock = "UniqueDestroySound",
		}
	},
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- Combine all achievements into one flat table
function AchievementsConfig.GetAllAchievements()
	local allAchievements = {}

	-- Helper function to add achievements from a category
	local function addCategory(category)
		for _, achievement in ipairs(category) do
			table.insert(allAchievements, achievement)
		end
	end

	addCategory(AchievementsConfig.Destruction)
	addCategory(AchievementsConfig.Boss)
	addCategory(AchievementsConfig.Zone)
	addCategory(AchievementsConfig.Rebirth)
	addCategory(AchievementsConfig.Collection)
	addCategory(AchievementsConfig.Special)
	addCategory(AchievementsConfig.Secret)
	addCategory(AchievementsConfig.Meta)

	return allAchievements
end

-- Get achievement by ID
function AchievementsConfig.GetAchievementByID(achievementID)
	local allAchievements = AchievementsConfig.GetAllAchievements()

	for _, achievement in ipairs(allAchievements) do
		if achievement.ID == achievementID then
			return achievement
		end
	end

	return nil
end

-- Get all achievements in a category
function AchievementsConfig.GetAchievementsByCategory(category)
	local categoryMap = {
		Destruction = AchievementsConfig.Destruction,
		Boss = AchievementsConfig.Boss,
		Zone = AchievementsConfig.Zone,
		Rebirth = AchievementsConfig.Rebirth,
		Collection = AchievementsConfig.Collection,
		Special = AchievementsConfig.Special,
		Secret = AchievementsConfig.Secret,
		Meta = AchievementsConfig.Meta,
	}

	return categoryMap[category] or {}
end

-- Get total achievement count
function AchievementsConfig.GetTotalAchievementCount()
	return #AchievementsConfig.GetAllAchievements()
end

-- Get achievement display info (respects hidden status)
function AchievementsConfig.GetDisplayInfo(achievementID, isUnlocked)
	local achievement = AchievementsConfig.GetAchievementByID(achievementID)

	if not achievement then
		return nil
	end

	-- If hidden and not unlocked, return mystery info
	if achievement.Hidden and not isUnlocked then
		return {
			ID = achievementID,
			Name = "???",
			Description = "This is a secret achievement. Keep playing to discover it!",
			Category = "Secret",
			Icon = "rbxassetid://0", -- Mystery icon
			Hidden = true,
			Unlocked = false,
		}
	end

	-- Return full info
	return {
		ID = achievement.ID,
		Name = achievement.Name,
		Description = achievement.Description,
		Category = achievement.Category,
		Icon = achievement.Icon,
		Hidden = achievement.Hidden,
		Unlocked = isUnlocked,
		Rewards = achievement.Rewards,
	}
end

return AchievementsConfig
