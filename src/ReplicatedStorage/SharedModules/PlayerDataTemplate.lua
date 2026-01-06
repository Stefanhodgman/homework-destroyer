--[[
	PlayerDataTemplate.lua
	Default player data structure for Homework Destroyer

	This template defines the initial state for new players
	and serves as a reference for all player data fields
--]]

local PlayerDataTemplate = {}

-- Default player data structure
PlayerDataTemplate.Default = {
	-- Currency
	DestructionPoints = 0, -- Main currency (DP)
	RebirthTokens = 0, -- Earned from rebirthing

	-- Progression
	Level = 1,
	Experience = 0,
	RebirthLevel = 0, -- Number of times player has rebirthed
	PrestigeLevel = 0, -- Unlocked at Rebirth 20
	PostPrestigeRebirths = 0, -- Rebirths after prestiging

	-- Lifetime Statistics
	LifetimeStats = {
		TotalDestructionPoints = 0, -- Total DP earned all-time
		TotalHomeworkDestroyed = 0, -- Total homework destroyed
		TotalBossesDefeated = 0, -- Total bosses defeated
		TotalClicks = 0, -- Total manual clicks
		TotalPlayTime = 0, -- Total seconds played
		TotalRebirths = 0, -- Total rebirths performed
		HighestDamageDealt = 0, -- Highest single damage number
		FastestHomeworkDestroy = 0, -- Fastest homework destruction (seconds)
	},

	-- Upgrade Levels
	-- All upgrades start at level 0
	-- FLAT STRUCTURE: All upgrades are direct children of Upgrades table
	Upgrades = {
		-- Damage Upgrades
		SharperTools = 0,
		StrongerArms = 0,
		CriticalChance = 0,
		CriticalDamage = 0,
		PaperWeakness = 0,
		-- Speed Upgrades
		QuickHands = 0,
		AutoClickSpeed = 0,
		MovementSpeed = 0,
		-- Economy Upgrades
		DPBonus = 0,
		LuckyDrops = 0,
		EggLuck = 0,
	},

	-- Rebirth Shop Purchases (permanent upgrades)
	RebirthShop = {
		StartingBoost = false, -- Start at Level 10
		DPSaver = false, -- Keep 10% of DP
		ZoneSkip = false, -- Start at Zone 3
		SuperAuto = false, -- Auto-clicks deal 100% damage
		TokenMultiplier = 0, -- Number of times purchased (stackable, max 5)
	},

	-- Current Zone
	CurrentZone = 1, -- Starts in Zone 1 (Classroom)
	UnlockedZones = {1}, -- Array of unlocked zone IDs

	-- Tools/Weapons Inventory
	Tools = {
		Owned = {"PencilEraser"}, -- Array of owned tool IDs (starts with free tool)
		Equipped = "PencilEraser", -- Currently equipped tool
		EquippedSecondary = nil, -- Dual-wield tool (unlocked at Level 75)
		UpgradeLevels = {
			-- ToolID = upgradeLevel (0-10)
			PencilEraser = 0,
		},
	},

	-- Tool Upgrade Tokens
	ToolUpgradeTokens = 0, -- Currency for upgrading tools

	-- Pet System
	Pets = {
		Owned = {}, -- Array of owned pet data: {ID, Level, XP, Rarity}
		Equipped = {}, -- Array of equipped pet IDs (up to 6 slots)
		MaxSlots = 1, -- Unlocked pet equip slots (starts at 1)
	},

	-- Eggs Inventory
	Eggs = {
		ClassroomEgg = 0,
		LibraryEgg = 0,
		CafeteriaEgg = 0,
		ArtEgg = 0,
		ScienceEgg = 0,
		TechEgg = 0,
		PrincipalEgg = 0,
		VoidEgg = 0,
		-- Special eggs
		RareGuaranteedEgg = 0,
		EpicGuaranteedEgg = 0,
		LegendaryGuaranteedEgg = 0,
		MythicGuaranteedEgg = 0,
	},

	-- Achievements/Badges
	Achievements = {
		-- Achievement ID = timestamp unlocked (or false if not unlocked)
		-- Destruction
		FirstSteps = false,
		PaperShredder = false,
		AssignmentAssassin = false,
		HomeworkHater = false,
		DestructionMachine = false,
		AnnihilationExpert = false,
		ApocalypseBringer = false,
		CosmicDestroyer = false,
		RealityBreaker = false,
		TheDestroyer = false,

		-- Boss
		BossFighter = false,
		BossHunter = false,
		BossSlayer = false,
		BossNightmare = false,
		BossExterminator = false,

		-- Zone
		Explorer = false,
		Adventurer = false,
		WorldTraveler = false,
		VoidWalker = false,
		MasterOfAll = false,

		-- Rebirth
		BornAgain = false,
		CycleBreaker = false,
		EternalStudent = false,
		TimeLord = false,
		InfiniteLoop = false,

		-- Collection
		ToolCollector = false,
		ArsenalBuilder = false,
		WeaponMaster = false,
		PetLover = false,
		PetHoarder = false,
		LegendaryTamer = false,
		MythicMaster = false,

		-- Special
		SpeedDemon = false,
		CriticalKing = false,
		Untouchable = false,
		Millionaire = false,
		Billionaire = false,
		TrueCompletionist = false,

		-- Secret
		NightOwl = false,
		MarathonRunner = false,
		OldTimer = false,
		EasterEggHunter = false,
		TheOne = false,
	},

	-- Daily/Weekly Progress
	DailyProgress = {
		LastLoginDate = 0, -- Timestamp of last login
		LoginStreak = 0, -- Current consecutive login days
		LastDailyRewardClaimed = 0, -- Day number (1-7) of last claimed reward

		-- Daily Challenges (reset at midnight UTC)
		DailyChallenges = {
			-- Populated by server on login
			-- {Type, Target, Progress, Completed, Reward}
		},
		ChallengesCompletedToday = 0,
		LastChallengeRefresh = 0, -- Timestamp of last challenge refresh
	},

	WeeklyProgress = {
		CurrentEvent = nil, -- Current weekly event name
		EventProgress = 0, -- Progress in current event
		EventRewardsClaimed = {}, -- Array of claimed reward tiers
	},

	-- Settings/Preferences
	Settings = {
		-- Visual Settings
		ShowDamageNumbers = true,
		ShowCritEffects = true,
		ShowParticles = true,
		ReducedMotion = false,

		-- Audio Settings
		MasterVolume = 1.0, -- 0.0 to 1.0
		MusicVolume = 0.7,
		SFXVolume = 1.0,

		-- Gameplay Settings
		AutoEquipBestTool = false,
		AutoEquipBestPet = false,
		ShowTutorials = true,
		ConfirmExpensivePurchases = true, -- Confirm purchases over 1M DP

		-- UI Settings
		CompactUI = false,
		ShowLeaderboard = true,
		ShowPlayerList = true,
	},

	-- Tutorial Progress
	Tutorial = {
		Completed = false,
		CurrentStep = 0,
		StepsCompleted = {},
	},

	-- Quest Progress (if implementing quest system)
	Quests = {
		Active = {}, -- Array of active quest IDs
		Completed = {}, -- Array of completed quest IDs
		Progress = {}, -- QuestID = progress value
	},

	-- Seasonal Event Data
	SeasonalEvents = {
		-- EventID = {Participated = bool, Progress = number, RewardsClaimed = {}}
	},

	-- Misc Data
	LastSave = 0, -- Timestamp of last data save
	DataVersion = 1, -- For handling data migrations
	JoinDate = 0, -- Timestamp of when player first joined

	-- Premium/Gamepass Status
	Gamepasses = {
		VIPPass = false,
		AutoClicker = false,
		PetSlotExpansion = false,
		DoubleDP = false,
		InstantRebirth = false,
	},
}

--[[
	HELPER FUNCTIONS
]]

-- Create a deep copy of the default data for a new player
function PlayerDataTemplate.CreateNew()
	local newData = {}

	-- Deep copy the default template
	for key, value in pairs(PlayerDataTemplate.Default) do
		if type(value) == "table" then
			newData[key] = PlayerDataTemplate.DeepCopy(value)
		else
			newData[key] = value
		end
	end

	-- Set initial timestamps
	local currentTime = os.time()
	newData.JoinDate = currentTime
	newData.LastSave = currentTime
	newData.DailyProgress.LastLoginDate = currentTime

	return newData
end

-- Deep copy a table
function PlayerDataTemplate.DeepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = PlayerDataTemplate.DeepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

-- Merge saved data with template (for handling new fields in updates)
function PlayerDataTemplate.MergeWithTemplate(savedData)
	local merged = PlayerDataTemplate.CreateNew()

	-- Recursively merge saved data into template
	local function merge(template, saved)
		for key, value in pairs(saved) do
			if template[key] ~= nil then
				if type(value) == "table" and type(template[key]) == "table" then
					merge(template[key], value)
				else
					template[key] = value
				end
			end
		end
	end

	merge(merged, savedData)
	return merged
end

-- Validate player data structure
function PlayerDataTemplate.Validate(data)
	if type(data) ~= "table" then
		return false, "Data is not a table"
	end

	-- Check for required fields
	local requiredFields = {
		"DestructionPoints",
		"Level",
		"RebirthLevel",
		"Upgrades",
		"Tools",
		"Pets",
		"Settings"
	}

	for _, field in ipairs(requiredFields) do
		if data[field] == nil then
			return false, string.format("Missing required field: %s", field)
		end
	end

	-- Validate data types
	if type(data.DestructionPoints) ~= "number" then
		return false, "DestructionPoints must be a number"
	end

	if type(data.Level) ~= "number" or data.Level < 1 then
		return false, "Level must be a positive number"
	end

	if type(data.RebirthLevel) ~= "number" or data.RebirthLevel < 0 then
		return false, "RebirthLevel must be a non-negative number"
	end

	return true, "Valid"
end

-- Get a specific value from player data safely
function PlayerDataTemplate.GetValue(data, path)
	-- Path is a dot-separated string like "Upgrades.SharperTools" or "Settings.MasterVolume"
	local current = data
	for key in string.gmatch(path, "[^%.]+") do
		if type(current) ~= "table" then
			return nil
		end
		current = current[key]
	end
	return current
end

-- Set a specific value in player data safely
function PlayerDataTemplate.SetValue(data, path, value)
	local keys = {}
	for key in string.gmatch(path, "[^%.]+") do
		table.insert(keys, key)
	end

	local current = data
	for i = 1, #keys - 1 do
		local key = keys[i]
		if type(current[key]) ~= "table" then
			current[key] = {}
		end
		current = current[key]
	end

	current[keys[#keys]] = value
	return true
end

-- Reset data for rebirth
function PlayerDataTemplate.ResetForRebirth(data, rebirthShopUpgrades)
	-- Reset level and XP
	data.Level = rebirthShopUpgrades.StartingBoost and 10 or 1
	data.Experience = 0

	-- Reset or reduce DP
	if rebirthShopUpgrades.DPSaver then
		data.DestructionPoints = math.floor(data.DestructionPoints * 0.1)
	else
		data.DestructionPoints = 0
	end

	-- Reset zone progress
	if rebirthShopUpgrades.ZoneSkip then
		data.CurrentZone = 3
		data.UnlockedZones = {1, 2, 3}
	else
		data.CurrentZone = 1
		data.UnlockedZones = {1}
	end

	-- Reset all upgrades (flat structure)
	for upgradeName, _ in pairs(data.Upgrades) do
		data.Upgrades[upgradeName] = 0
	end

	-- Keep tools, pets, achievements, rebirth shop purchases, gamepasses
	-- Everything else is reset

	return data
end

-- Calculate experience required for next level
function PlayerDataTemplate.GetXPRequiredForLevel(level)
	if level <= 10 then
		return 100
	elseif level <= 25 then
		return 500
	elseif level <= 50 then
		return 2000
	elseif level <= 75 then
		return 10000
	elseif level <= 100 then
		return 50000
	else
		-- Beyond level 100 (shouldn't normally happen before rebirth)
		return 100000
	end
end

-- Calculate total XP needed to reach a level from level 1
function PlayerDataTemplate.GetTotalXPForLevel(targetLevel)
	local total = 0
	for level = 1, targetLevel - 1 do
		total = total + PlayerDataTemplate.GetXPRequiredForLevel(level)
	end
	return total
end

return PlayerDataTemplate
