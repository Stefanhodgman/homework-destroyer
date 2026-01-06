--[[
	DataManager.lua

	Handles all player data persistence for Homework Destroyer

	Features:
	- Player data loading/saving with DataStore
	- Session data management
	- Auto-save functionality
	- Error handling and retry logic
	- Data migration support for version updates

	Author: Homework Destroyer Team
	Version: 1.0
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataManager = {}

-- Constants
local DATASTORE_NAME = "PlayerDataV1"
local AUTO_SAVE_INTERVAL = 300 -- Auto-save every 5 minutes
local MAX_RETRY_ATTEMPTS = 3
local RETRY_DELAY = 1

-- Data version for migration support
local DATA_VERSION = 1

-- Check if running in Studio
local IS_STUDIO = RunService:IsStudio()

-- DataStore instance (nil if in Studio)
local PlayerDataStore = nil
if not IS_STUDIO then
	PlayerDataStore = DataStoreService:GetDataStore(DATASTORE_NAME)
end

-- Mock data storage for Studio testing
local MockDataStore = {}

-- Active sessions: stores player data while in-game
local ActiveSessions = {}

-- Default player data template
local DEFAULT_DATA = {
	-- Meta
	DataVersion = DATA_VERSION,

	-- Progression
	Level = 1,
	XP = 0,
	DestructionPoints = 0,
	LifetimeDP = 0, -- For prestige requirements

	-- Rebirth & Prestige
	RebirthLevel = 0,
	RebirthTokens = 0,
	PrestigeRank = 0,
	TotalRebirths = 0, -- Lifetime counter

	-- Stats
	TotalHomeworkDestroyed = 0,
	TotalBossesDefeated = 0,
	TotalClickDamage = 0,
	TotalPlayTime = 0, -- In seconds

	-- Unlocks
	UnlockedZones = {1}, -- Start with Classroom unlocked
	CurrentZone = 1,

	-- Tools/Weapons
	OwnedTools = {
		{ToolId = 1, UpgradeLevel = 0} -- Start with Pencil Eraser
	},
	EquippedTool = 1,

	-- Pets
	OwnedPets = {},
	EquippedPets = {}, -- Array of pet IDs currently equipped
	PetSlots = 1, -- Number of available slots

	-- Upgrades (levels purchased)
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

	-- Rebirth Shop Purchases
	RebirthShop = {
		StartingBoost = false,
		DPSaver = false,
		ZoneSkip = false,
		SuperAuto = false,
	},

	-- Achievements
	UnlockedAchievements = {},

	-- Daily/Weekly Systems
	LoginStreak = 0,
	LastLoginDate = 0, -- Unix timestamp
	DailyChallengesCompleted = {},
	LastChallengeReset = 0,

	-- Settings
	Settings = {
		DamageNumbers = true,
		SoundEffects = true,
		Music = true,
		Particles = true,
	},
}

--[[
	Recursively merges default data with loaded data
	This ensures new fields are added when the game updates
]]
local function MergeWithDefaults(loaded, defaults)
	local merged = {}

	-- First, copy all default values
	for key, value in pairs(defaults) do
		if type(value) == "table" then
			merged[key] = MergeWithDefaults(loaded[key] or {}, value)
		else
			merged[key] = value
		end
	end

	-- Then, overwrite with loaded values
	for key, value in pairs(loaded) do
		if type(value) == "table" and type(defaults[key]) == "table" then
			-- Already merged above
		else
			merged[key] = value
		end
	end

	return merged
end

--[[
	Migrates old data versions to current version
]]
local function MigrateData(data)
	local currentVersion = data.DataVersion or 0

	-- Example migration (for future use)
	if currentVersion < 1 then
		-- Migration code for version 0 -> 1
		data.DataVersion = 1
	end

	-- Add more migrations as needed

	return data
end

--[[
	Loads player data with retry logic
	Returns: success (boolean), data (table) or error message (string)
]]
function DataManager:LoadPlayerData(player)
	local userId = player.UserId
	local key = "Player_" .. userId

	-- STUDIO MODE: Use mock storage
	if IS_STUDIO then
		warn("[DataManager] [STUDIO MODE] Loading mock data for: " .. player.Name)

		local data = MockDataStore[key]
		if not data then
			-- New player - create default data
			data = {}
			for k, v in pairs(DEFAULT_DATA) do
				data[k] = v
			end
			MockDataStore[key] = data
		end

		-- Store in active session
		ActiveSessions[userId] = {
			Data = data,
			Player = player,
			LastSaveTime = os.time(),
			Loaded = true,
		}

		return true, data
	end

	-- LIVE MODE: Use real DataStore
	-- Try loading with retry logic
	for attempt = 1, MAX_RETRY_ATTEMPTS do
		local success, result = pcall(function()
			return PlayerDataStore:GetAsync(key)
		end)

		if success then
			local data

			if result == nil then
				-- New player
				warn("[DataManager] New player detected: " .. player.Name)
				data = {}
				for key, value in pairs(DEFAULT_DATA) do
					data[key] = value
				end
			else
				-- Existing player - merge with defaults and migrate
				warn("[DataManager] Loading data for player: " .. player.Name)
				data = MigrateData(result)
				data = MergeWithDefaults(data, DEFAULT_DATA)
			end

			-- Store in active session
			ActiveSessions[userId] = {
				Data = data,
				Player = player,
				LastSaveTime = os.time(),
				Loaded = true,
			}

			return true, data
		else
			warn("[DataManager] Load attempt " .. attempt .. " failed for " .. player.Name .. ": " .. tostring(result))

			if attempt < MAX_RETRY_ATTEMPTS then
				wait(RETRY_DELAY * attempt) -- Exponential backoff
			end
		end
	end

	-- All attempts failed
	return false, "Failed to load data after " .. MAX_RETRY_ATTEMPTS .. " attempts"
end

--[[
	Saves player data with retry logic
	Returns: success (boolean), error message (string or nil)
]]
function DataManager:SavePlayerData(player)
	local userId = player.UserId
	local key = "Player_" .. userId

	local session = ActiveSessions[userId]
	if not session or not session.Loaded then
		return false, "No active session found"
	end

	local data = session.Data

	-- Update metadata
	data.DataVersion = DATA_VERSION

	-- STUDIO MODE: Save to mock storage
	if IS_STUDIO then
		MockDataStore[key] = data
		session.LastSaveTime = os.time()
		warn("[DataManager] [STUDIO MODE] Mock saved data for: " .. player.Name)
		return true, nil
	end

	-- LIVE MODE: Use real DataStore
	-- Try saving with retry logic
	for attempt = 1, MAX_RETRY_ATTEMPTS do
		local success, result = pcall(function()
			PlayerDataStore:SetAsync(key, data)
		end)

		if success then
			session.LastSaveTime = os.time()
			warn("[DataManager] Successfully saved data for: " .. player.Name)
			return true, nil
		else
			warn("[DataManager] Save attempt " .. attempt .. " failed for " .. player.Name .. ": " .. tostring(result))

			if attempt < MAX_RETRY_ATTEMPTS then
				wait(RETRY_DELAY * attempt)
			end
		end
	end

	return false, "Failed to save data after " .. MAX_RETRY_ATTEMPTS .. " attempts"
end

--[[
	Gets the active session data for a player
	Returns: data table or nil
]]
function DataManager:GetPlayerData(player)
	local userId = player.UserId
	local session = ActiveSessions[userId]

	if session and session.Loaded then
		return session.Data
	end

	return nil
end

--[[
	Updates a specific field in player data
	Supports nested tables using dot notation (e.g., "Settings.Music")
]]
function DataManager:UpdatePlayerData(player, field, value)
	local data = self:GetPlayerData(player)

	if not data then
		warn("[DataManager] Cannot update data - no active session for: " .. player.Name)
		return false
	end

	-- Handle nested fields
	local keys = string.split(field, ".")
	local current = data

	for i = 1, #keys - 1 do
		if not current[keys[i]] then
			current[keys[i]] = {}
		end
		current = current[keys[i]]
	end

	current[keys[#keys]] = value
	return true
end

--[[
	Increments a numeric field by a given amount
]]
function DataManager:IncrementPlayerData(player, field, amount)
	local data = self:GetPlayerData(player)

	if not data then
		warn("[DataManager] Cannot increment data - no active session for: " .. player.Name)
		return false
	end

	-- Handle nested fields
	local keys = string.split(field, ".")
	local current = data

	for i = 1, #keys - 1 do
		if not current[keys[i]] then
			current[keys[i]] = {}
		end
		current = current[keys[i]]
	end

	local key = keys[#keys]
	current[key] = (current[key] or 0) + amount
	return true
end

--[[
	Adds an achievement to player's unlocked achievements
]]
function DataManager:UnlockAchievement(player, achievementId)
	local data = self:GetPlayerData(player)

	if not data then
		return false
	end

	if not table.find(data.UnlockedAchievements, achievementId) then
		table.insert(data.UnlockedAchievements, achievementId)
		return true
	end

	return false -- Already unlocked
end

--[[
	Checks if player has unlocked an achievement
]]
function DataManager:HasAchievement(player, achievementId)
	local data = self:GetPlayerData(player)

	if not data then
		return false
	end

	return table.find(data.UnlockedAchievements, achievementId) ~= nil
end

--[[
	Handles player leaving - saves data and cleans up session
]]
function DataManager:OnPlayerLeaving(player)
	local userId = player.UserId

	-- Save data one final time
	local success, err = self:SavePlayerData(player)

	if not success then
		warn("[DataManager] CRITICAL: Failed to save data for leaving player " .. player.Name .. ": " .. tostring(err))
		-- In production, you might want to log this to analytics
	end

	-- Clean up session
	ActiveSessions[userId] = nil
	warn("[DataManager] Session cleaned up for: " .. player.Name)
end

--[[
	Auto-save loop - saves all active sessions periodically
]]
function DataManager:StartAutoSave()
	spawn(function()
		while true do
			wait(AUTO_SAVE_INTERVAL)

			local saveCount = 0
			for userId, session in pairs(ActiveSessions) do
				if session.Loaded and session.Player then
					local success = self:SavePlayerData(session.Player)
					if success then
						saveCount = saveCount + 1
					end
				end
			end

			if saveCount > 0 then
				warn("[DataManager] Auto-save completed for " .. saveCount .. " players")
			end
		end
	end)
end

--[[
	Emergency save all - called on server shutdown
]]
function DataManager:SaveAllPlayers()
	warn("[DataManager] Emergency save initiated for all players")

	local saveCount = 0
	local failCount = 0

	for userId, session in pairs(ActiveSessions) do
		if session.Loaded and session.Player then
			local success = self:SavePlayerData(session.Player)
			if success then
				saveCount = saveCount + 1
			else
				failCount = failCount + 1
			end
		end
	end

	warn("[DataManager] Emergency save complete: " .. saveCount .. " succeeded, " .. failCount .. " failed")
end

--[[
	Performs a rebirth for a player
	This resets specific data while preserving rebirth progress
]]
function DataManager:PerformRebirth(player)
	local data = self:GetPlayerData(player)

	if not data then
		return false, "No data found"
	end

	-- Check if player meets requirements
	if data.Level < 100 then
		return false, "Must be level 100"
	end

	-- Check DP cost (increases with rebirth level)
	local rebirthCost = 10000000 * (1.5 ^ data.RebirthLevel)
	if data.DestructionPoints < rebirthCost then
		return false, "Not enough DP"
	end

	-- Perform rebirth
	data.RebirthLevel = data.RebirthLevel + 1
	data.TotalRebirths = data.TotalRebirths + 1
	data.RebirthTokens = data.RebirthTokens + 1

	-- Add bonus tokens at milestones
	if data.RebirthLevel % 5 == 0 then
		data.RebirthTokens = data.RebirthTokens + 2
	end
	if data.RebirthLevel % 10 == 0 then
		data.RebirthTokens = data.RebirthTokens + 5
	end

	-- Calculate what to keep
	local dpToKeep = 0
	if data.RebirthShop.DPSaver then
		dpToKeep = math.floor(data.DestructionPoints * 0.1)
	end

	local startingLevel = 1
	if data.RebirthShop.StartingBoost then
		startingLevel = 10
	end

	local startingZone = 1
	if data.RebirthShop.ZoneSkip then
		startingZone = 3
	end

	-- Reset data
	data.Level = startingLevel
	data.XP = 0
	data.DestructionPoints = dpToKeep
	data.CurrentZone = startingZone

	-- Reset upgrades
	data.Upgrades = {
		SharperTools = 0,
		StrongerArms = 0,
		CriticalChance = 0,
		CriticalDamage = 0,
		PaperWeakness = 0,
		QuickHands = 0,
		AutoClickSpeed = 0,
		MovementSpeed = 0,
		DPBonus = 0,
		LuckyDrops = 0,
		EggLuck = 0,
	}

	-- Reset zone unlocks (keep rebirth shop benefits)
	if data.RebirthShop.ZoneSkip then
		data.UnlockedZones = {1, 2, 3}
	else
		data.UnlockedZones = {1}
	end

	-- Keep tools and pets (as per design doc)

	warn("[DataManager] Rebirth completed for " .. player.Name .. " - Now at Rebirth " .. data.RebirthLevel)
	return true, "Rebirth successful"
end

--[[
	Updates daily login rewards and streak
]]
function DataManager:UpdateLoginRewards(player)
	local data = self:GetPlayerData(player)

	if not data then
		return
	end

	local currentTime = os.time()
	local lastLogin = data.LastLoginDate
	local dayInSeconds = 86400

	-- Check if it's a new day
	if currentTime - lastLogin >= dayInSeconds then
		local daysSinceLastLogin = math.floor((currentTime - lastLogin) / dayInSeconds)

		if daysSinceLastLogin == 1 then
			-- Consecutive day - increment streak
			data.LoginStreak = data.LoginStreak + 1
		elseif daysSinceLastLogin > 1 then
			-- Streak broken
			data.LoginStreak = 1
		end

		data.LastLoginDate = currentTime

		warn("[DataManager] Login streak for " .. player.Name .. ": " .. data.LoginStreak .. " days")
	end
end

--[[
	Initialize the DataManager
]]
function DataManager:Initialize()
	warn("[DataManager] Initializing...")

	-- Start auto-save system
	self:StartAutoSave()

	-- Handle server shutdown
	game:BindToClose(function()
		warn("[DataManager] Server shutting down - saving all player data")
		self:SaveAllPlayers()
		wait(3) -- Give time for saves to complete
	end)

	warn("[DataManager] Initialized successfully")
end

return DataManager
