--[[
	GameServer.lua

	Main server orchestration script for Homework Destroyer

	Responsibilities:
	- Initialize all game systems
	- Handle player join/leave events
	- Coordinate between different managers
	- Server-side game loop management
	- Boss spawning and zone management
	- Player session initialization

	Author: Homework Destroyer Team
	Version: 1.0
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local GameServer = {}

-- Module references
local DataManager = require(ServerScriptService.DataManager)
local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)

-- Manager modules (load but don't initialize yet to avoid circular deps)
local BossManager = require(ServerStorage.Modules.BossManager)
local PetManager = require(ServerStorage.Modules.PetManager)
local ToolManager = require(ServerStorage.Modules.ToolManager)
local UpgradeManager = require(ServerStorage.Modules.UpgradeManager)
local ZoneManager = require(ServerStorage.Modules.ZoneManager)
local CombatManager = require(ServerStorage.Modules.CombatManager)
local ChallengeManager = require(ServerStorage.Modules.ChallengeManager)
local QuestManager = require(ServerStorage.Modules.QuestManager)
local AchievementManager = require(ServerStorage.Modules.AchievementManager)
local PrestigeManager = require(ServerStorage.Modules.PrestigeManager)
local ShopManager = require(ServerStorage.Modules.ShopManager)
local GamepassManager = require(ServerStorage.Modules.GamepassManager)
local HomeworkSpawner = require(ServerStorage.Modules.HomeworkSpawner)

-- Configuration
local CONFIG = {
	-- Boss spawning
	BossSpawnInterval = 600, -- 10 minutes in seconds
	VoidBossInterval = 1200, -- 20 minutes for void bosses

	-- Player session
	AwardXPThrottle = 0.1, -- Seconds between XP awards
	PlayTimeUpdateInterval = 60, -- Update play time every minute

	-- Zone unlocking costs (DP and Level requirements)
	ZoneUnlocks = {
		[1] = {DP = 0, Level = 1}, -- Classroom (starter)
		[2] = {DP = 5000, Level = 10}, -- Library
		[3] = {DP = 50000, Level = 25}, -- Cafeteria
		[4] = {DP = 250000, Level = 35}, -- Computer Lab
		[5] = {DP = 1000000, Level = 45}, -- Gymnasium
		[6] = {DP = 5000000, Level = 55}, -- Music Room
		[7] = {DP = 25000000, Level = 65}, -- Art Room
		[8] = {DP = 100000000, Level = 75}, -- Science Lab
		[9] = {DP = 500000000, Level = 90}, -- Principal's Office
		[10] = {DP = 10000000000, Level = 100}, -- The Void (requires Rebirth 25 + Prestige III)
	},

	-- XP requirements per level
	XPTable = {
		[1] = {Range = {1, 10}, XPPerLevel = 100},
		[2] = {Range = {11, 25}, XPPerLevel = 500},
		[3] = {Range = {26, 50}, XPPerLevel = 2000},
		[4] = {Range = {51, 75}, XPPerLevel = 10000},
		[5] = {Range = {76, 100}, XPPerLevel = 50000},
	},
}

-- Active player sessions (stores runtime data)
local PlayerSessions = {}

-- Boss spawn timers per zone
local BossTimers = {}

-- Homework spawners per zone
local ZoneHomeworkSpawners = {}

--[[
	Calculates XP required for a specific level
]]
local function GetXPForLevel(level)
	for _, tier in ipairs(CONFIG.XPTable) do
		if level >= tier.Range[1] and level <= tier.Range[2] then
			return tier.XPPerLevel
		end
	end
	return 50000 -- Default for levels above 100
end

--[[
	Calculates total XP needed to reach a level
]]
local function GetTotalXPForLevel(targetLevel)
	local totalXP = 0
	for level = 1, targetLevel - 1 do
		totalXP = totalXP + GetXPForLevel(level)
	end
	return totalXP
end

--[[
	Awards XP to a player and handles level-up
	Returns: levelsGained (number)
]]
function GameServer:AwardXP(player, xpAmount)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return 0
	end

	-- Apply XP multipliers
	local multiplier = 1

	-- Rebirth bonus (not in design doc, but reasonable)
	if data.RebirthLevel > 0 then
		multiplier = multiplier * (1 + (data.RebirthLevel * 0.1))
	end

	local finalXP = math.floor(xpAmount * multiplier)

	-- Add XP
	DataManager:IncrementPlayerData(player, "XP", finalXP)
	data = DataManager:GetPlayerData(player) -- Refresh

	local levelsGained = 0
	local currentLevel = data.Level
	local maxLevel = 100

	-- Check for level-ups
	while currentLevel < maxLevel do
		local xpNeeded = GetXPForLevel(currentLevel)

		if data.XP >= xpNeeded then
			-- Level up!
			data.XP = data.XP - xpNeeded
			data.Level = data.Level + 1
			currentLevel = data.Level
			levelsGained = levelsGained + 1

			-- Award level-up rewards
			self:AwardLevelRewards(player, currentLevel)

			warn("[GameServer] " .. player.Name .. " leveled up to level " .. currentLevel)
		else
			break
		end
	end

	-- Cap XP at max level
	if currentLevel >= maxLevel then
		data.XP = 0
		data.Level = maxLevel
	end

	return levelsGained
end

--[[
	Awards rewards based on level milestones
]]
function GameServer:AwardLevelRewards(player, level)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	-- Every 5 levels: Free pet egg
	if level % 5 == 0 then
		-- Award egg (implementation would depend on inventory system)
		warn("[GameServer] Awarded pet egg to " .. player.Name .. " for reaching level " .. level)
	end

	-- Every 10 levels: Tool upgrade token
	if level % 10 == 0 then
		-- Award tool token
		warn("[GameServer] Awarded tool upgrade token to " .. player.Name .. " for reaching level " .. level)
	end

	-- Specific level unlocks
	if level == 25 then
		data.PetSlots = math.max(data.PetSlots, 2)
		warn("[GameServer] Unlocked Pet Slot 2 for " .. player.Name)
	elseif level == 50 then
		data.PetSlots = math.max(data.PetSlots, 3)
		warn("[GameServer] Unlocked Pet Slot 3 for " .. player.Name)
	elseif level == 75 then
		-- Unlock dual-wield (would need to implement in combat system)
		warn("[GameServer] Unlocked Tool Dual-Wield for " .. player.Name)
	elseif level == 100 then
		-- Unlock rebirth capability
		warn("[GameServer] Unlocked Rebirth for " .. player.Name)
	end
end

--[[
	Awards Destruction Points to a player
	Handles multipliers and tracking
]]
function GameServer:AwardDP(player, dpAmount)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	-- Calculate multipliers
	local multiplier = 1

	-- DP Bonus upgrade
	if data.Upgrades.DPBonus then
		multiplier = multiplier * (1 + (data.Upgrades.DPBonus * 0.03))
	end

	-- Rebirth multiplier
	local rebirthMultipliers = {
		[1] = 1.5, [2] = 2.0, [3] = 2.75, [4] = 3.5, [5] = 4.5,
		[10] = 10, [15] = 20, [20] = 35, [25] = 50
	}

	for rebirth, mult in pairs(rebirthMultipliers) do
		if data.RebirthLevel >= rebirth then
			multiplier = mult
		end
	end

	-- Prestige multiplier
	local prestigeMultipliers = {
		[1] = 2, -- Homework Hater: +100% = x2
		[2] = 3, -- Assignment Annihilator: +200% = x3
	}

	if data.PrestigeRank > 0 and prestigeMultipliers[data.PrestigeRank] then
		multiplier = multiplier * prestigeMultipliers[data.PrestigeRank]
	end

	local finalDP = math.floor(dpAmount * multiplier)

	-- Award DP
	DataManager:IncrementPlayerData(player, "DestructionPoints", finalDP)
	DataManager:IncrementPlayerData(player, "LifetimeDP", finalDP)

	-- Check for DP milestones/achievements
	self:CheckDPAchievements(player)
end

--[[
	Checks and awards DP-related achievements
]]
function GameServer:CheckDPAchievements(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	-- Millionaire achievement
	if data.DestructionPoints >= 1000000 and not DataManager:HasAchievement(player, "Millionaire") then
		DataManager:UnlockAchievement(player, "Millionaire")
		-- Award bonus DP
		DataManager:IncrementPlayerData(player, "DestructionPoints", 100000)
		warn("[GameServer] Unlocked Millionaire achievement for " .. player.Name)
	end

	-- Billionaire achievement
	if data.DestructionPoints >= 1000000000 and not DataManager:HasAchievement(player, "Billionaire") then
		DataManager:UnlockAchievement(player, "Billionaire")
		-- Award bonus DP
		DataManager:IncrementPlayerData(player, "DestructionPoints", 100000000)
		warn("[GameServer] Unlocked Billionaire achievement for " .. player.Name)
	end
end

--[[
	Handles homework destruction
	Awards DP, XP, and checks achievements
]]
function GameServer:OnHomeworkDestroyed(player, homeworkType, damage)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	-- Increment destruction counter
	DataManager:IncrementPlayerData(player, "TotalHomeworkDestroyed", 1)
	DataManager:IncrementPlayerData(player, "TotalClickDamage", damage)

	-- Award DP based on homework type (would be defined elsewhere)
	local dpReward = homeworkType.DPReward or 10
	self:AwardDP(player, dpReward)

	-- Award XP (10% of DP as XP)
	local xpReward = math.floor(dpReward * 0.1)
	self:AwardXP(player, xpReward)

	-- Check destruction achievements
	self:CheckDestructionAchievements(player)
end

--[[
	Checks and awards destruction-count achievements
]]
function GameServer:CheckDestructionAchievements(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	local count = data.TotalHomeworkDestroyed

	local achievements = {
		{Count = 10, ID = "FirstSteps", Reward = 100},
		{Count = 100, ID = "PaperShredder", Reward = 500},
		{Count = 1000, ID = "AssignmentAssassin", Reward = 2500},
		{Count = 10000, ID = "HomeworkHater", Reward = 25000},
		{Count = 100000, ID = "DestructionMachine", Reward = 250000},
		{Count = 1000000, ID = "AnnihilationExpert", Reward = 2500000},
		{Count = 10000000, ID = "ApocalypseBringer", Reward = 25000000},
		{Count = 100000000, ID = "CosmicDestroyer", Reward = 250000000},
		{Count = 1000000000, ID = "RealityBreaker", Reward = 2500000000},
		{Count = 10000000000, ID = "TheDestroyer", Reward = 25000000000},
	}

	for _, achievement in ipairs(achievements) do
		if count >= achievement.Count and not DataManager:HasAchievement(player, achievement.ID) then
			DataManager:UnlockAchievement(player, achievement.ID)
			DataManager:IncrementPlayerData(player, "DestructionPoints", achievement.Reward)
			warn("[GameServer] Unlocked " .. achievement.ID .. " achievement for " .. player.Name)
		end
	end
end

--[[
	Handles boss defeat
	Called by BossManager when distributing rewards
]]
function GameServer:OnBossDefeated(player, bossType, rewards)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	-- Increment boss counter
	DataManager:IncrementPlayerData(player, "TotalBossesDefeated", 1)

	-- Award DP and XP from rewards
	if rewards.DP then
		self:AwardDP(player, rewards.DP)
	end

	if rewards.XP then
		self:AwardXP(player, rewards.XP)
	end

	-- Award items
	if rewards.Items then
		for _, item in ipairs(rewards.Items) do
			self:AwardItem(player, item.Item, item.Amount)
		end
	end

	-- Check boss achievements
	self:CheckBossAchievements(player)

	warn("[GameServer] " .. player.Name .. " defeated boss: " .. (bossType.Name or "Unknown Boss"))
end

--[[
	Awards an item to a player
]]
function GameServer:AwardItem(player, itemId, amount)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	-- Handle different item types
	if itemId == "ToolUpgradeToken" then
		DataManager:IncrementPlayerData(player, "ToolUpgradeTokens", amount)
	elseif itemId == "RebirthTokens" or itemId == "RebirthToken" then
		DataManager:IncrementPlayerData(player, "RebirthTokens", amount)
	elseif itemId == "DestructionPoints" then
		DataManager:IncrementPlayerData(player, "DestructionPoints", amount)
	elseif string.find(itemId, "Egg") then
		-- Handle egg inventory
		if data.Eggs[itemId] then
			data.Eggs[itemId] = data.Eggs[itemId] + amount
		end
	else
		-- Special items (tools, pets, etc.)
		warn("[GameServer] Awarded special item: " .. itemId .. " x" .. amount .. " to " .. player.Name)
		-- Would need to implement tool/pet awarding logic
	end
end

--[[
	Checks and awards boss-related achievements
]]
function GameServer:CheckBossAchievements(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	local count = data.TotalBossesDefeated

	local achievements = {
		{Count = 1, ID = "BossFighter", Reward = 5000},
		{Count = 10, ID = "BossHunter", Reward = 50000},
		{Count = 100, ID = "BossSlayer", Reward = 500000},
		{Count = 1000, ID = "BossNightmare", Reward = 5000000},
	}

	for _, achievement in ipairs(achievements) do
		if count >= achievement.Count and not DataManager:HasAchievement(player, achievement.ID) then
			DataManager:UnlockAchievement(player, achievement.ID)
			DataManager:IncrementPlayerData(player, "DestructionPoints", achievement.Reward)
			warn("[GameServer] Unlocked " .. achievement.ID .. " achievement for " .. player.Name)
		end
	end
end

--[[
	Attempts to unlock a zone for a player
	Returns: success (boolean), message (string)
]]
function GameServer:UnlockZone(player, zoneId)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return false, "No player data"
	end

	-- Check if already unlocked
	if table.find(data.UnlockedZones, zoneId) then
		return false, "Zone already unlocked"
	end

	-- Get requirements
	local requirements = CONFIG.ZoneUnlocks[zoneId]
	if not requirements then
		return false, "Invalid zone"
	end

	-- Check level requirement
	if data.Level < requirements.Level then
		return false, "Level " .. requirements.Level .. " required"
	end

	-- Check DP requirement
	if data.DestructionPoints < requirements.DP then
		return false, "Need " .. requirements.DP .. " DP"
	end

	-- Special requirements for zone 9 (Principal's Office)
	if zoneId == 9 and data.RebirthLevel < 3 then
		return false, "Rebirth 3 required"
	end

	-- Special requirements for zone 10 (The Void)
	if zoneId == 10 then
		if data.RebirthLevel < 25 then
			return false, "Rebirth 25 required"
		end
		if data.PrestigeRank < 3 then
			return false, "Prestige Rank III required"
		end
	end

	-- Deduct DP cost
	DataManager:IncrementPlayerData(player, "DestructionPoints", -requirements.DP)

	-- Unlock zone
	table.insert(data.UnlockedZones, zoneId)

	-- Start homework spawning for this zone
	self:StartZoneSpawning(zoneId)

	-- Check zone achievements
	self:CheckZoneAchievements(player)

	warn("[GameServer] " .. player.Name .. " unlocked zone " .. zoneId)
	return true, "Zone unlocked!"
end

--[[
	Checks and awards zone-related achievements
]]
function GameServer:CheckZoneAchievements(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	local zoneCount = #data.UnlockedZones

	local achievements = {
		{Count = 3, ID = "Explorer", Reward = 10000},
		{Count = 5, ID = "Adventurer", Reward = 100000},
		{Count = 9, ID = "WorldTraveler", Reward = 1000000},
	}

	for _, achievement in ipairs(achievements) do
		if zoneCount >= achievement.Count and not DataManager:HasAchievement(player, achievement.ID) then
			DataManager:UnlockAchievement(player, achievement.ID)
			DataManager:IncrementPlayerData(player, "DestructionPoints", achievement.Reward)
			warn("[GameServer] Unlocked " .. achievement.ID .. " achievement for " .. player.Name)
		end
	end

	-- Void Walker achievement
	if table.find(data.UnlockedZones, 10) and not DataManager:HasAchievement(player, "VoidWalker") then
		DataManager:UnlockAchievement(player, "VoidWalker")
		DataManager:IncrementPlayerData(player, "DestructionPoints", 10000000)
		warn("[GameServer] Unlocked VoidWalker achievement for " .. player.Name)
	end
end

--[[
	Initializes a player session when they join
]]
function GameServer:OnPlayerJoined(player)
	warn("[GameServer] Player joined: " .. player.Name)

	-- Load player data
	local success, data = DataManager:LoadPlayerData(player)

	if not success then
		warn("[GameServer] CRITICAL: Failed to load data for " .. player.Name)
		player:Kick("Failed to load your data. Please try again.")
		return
	end

	-- Update login rewards and streak
	DataManager:UpdateLoginRewards(player)

	-- Create player session
	PlayerSessions[player.UserId] = {
		Player = player,
		JoinTime = os.time(),
		LastXPAward = 0,
		LastPlayTimeUpdate = os.time(),
	}

	-- Initialize player's character/stats based on data
	self:InitializePlayerCharacter(player)

	warn("[GameServer] Session initialized for " .. player.Name)
end

--[[
	Initializes player character stats and equipment
]]
function GameServer:InitializePlayerCharacter(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	-- Wait for character to load
	local character = player.Character or player.CharacterAdded:Wait()

	-- Initialize all player systems
	self:InitializePlayerSystems(player, data)

	-- Set spawn location based on current zone (would need zone spawn points)
	-- This would integrate with workspace zone locations

	-- Initialize stats (these would be stored in the character or player for quick access)
	-- In a real implementation, you might use Attributes or a folder of Values

	warn("[GameServer] Character initialized for " .. player.Name .. " at level " .. data.Level)
end

--[[
	Handles player leaving
]]
function GameServer:OnPlayerLeaving(player)
	warn("[GameServer] Player leaving: " .. player.Name)

	-- Update total play time
	local session = PlayerSessions[player.UserId]
	if session then
		local playTime = os.time() - session.JoinTime
		DataManager:IncrementPlayerData(player, "TotalPlayTime", playTime)
	end

	-- Cleanup manager systems
	ChallengeManager:OnPlayerLeaving(player)
	QuestManager:OnPlayerLeaving(player)

	-- Save and cleanup via DataManager
	DataManager:OnPlayerLeaving(player)

	-- Cleanup session
	PlayerSessions[player.UserId] = nil
end

--[[
	Server heartbeat - updates play time and other periodic tasks
]]
function GameServer:StartServerLoop()
	spawn(function()
		while true do
			wait(CONFIG.PlayTimeUpdateInterval)

			-- Update play time for all active players
			for userId, session in pairs(PlayerSessions) do
				if session.Player and session.Player.Parent then
					local currentTime = os.time()
					local timeSinceLastUpdate = currentTime - session.LastPlayTimeUpdate

					DataManager:IncrementPlayerData(session.Player, "TotalPlayTime", timeSinceLastUpdate)
					session.LastPlayTimeUpdate = currentTime

					-- Check for Marathon Runner achievement (10 hours = 36000 seconds)
					local data = DataManager:GetPlayerData(session.Player)
					if data and data.TotalPlayTime >= 36000 then
						if not DataManager:HasAchievement(session.Player, "MarathonRunner") then
							DataManager:UnlockAchievement(session.Player, "MarathonRunner")
							DataManager:IncrementPlayerData(session.Player, "DestructionPoints", 50000)
							warn("[GameServer] Unlocked MarathonRunner achievement for " .. session.Player.Name)
						end
					end
				end
			end
		end
	end)
end

--[[
	Starts boss spawning system for a specific zone
	DEPRECATED: Now handled by BossManager
]]
function GameServer:InitializeBossSpawning(zoneId)
	-- This function is deprecated, BossManager handles spawning now
	warn("[GameServer] InitializeBossSpawning is deprecated - BossManager handles boss spawning")
end

--[[
	Spawns a boss in the specified zone
	DEPRECATED: Now handled by BossManager
]]
function GameServer:SpawnBoss(zoneId)
	-- This function is deprecated, use BossManager:ForceSpawnBoss instead
	warn("[GameServer] SpawnBoss is deprecated - use BossManager:ForceSpawnBoss(zoneId)")
end

--[[
	Performs a prestige for a player
	Returns: success (boolean), message (string)
]]
function GameServer:PerformPrestige(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return false, "No data found"
	end

	-- Check requirements
	if data.RebirthLevel < 20 then
		return false, "Rebirth 20 required"
	end

	if data.LifetimeDP < 1000000000 then
		return false, "Need 1 billion lifetime DP"
	end

	-- Check for legendary pet (would need pet system integration)
	-- For now, skip this check

	-- Perform prestige
	data.PrestigeRank = data.PrestigeRank + 1

	-- Reset rebirth level but keep prestige bonuses
	data.RebirthLevel = 0
	data.Level = 1
	data.XP = 0
	data.DestructionPoints = 0
	data.UnlockedZones = {1}
	data.CurrentZone = 1

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

	-- Keep tools, pets, achievements, and prestige bonuses

	warn("[GameServer] Prestige completed for " .. player.Name .. " - Prestige Rank " .. data.PrestigeRank)
	return true, "Prestige successful! Rank " .. data.PrestigeRank
end

--[[
	Initialize homework spawners for all zones
]]
function GameServer:InitializeHomeworkSpawners()
	-- Create Zones folder in workspace if it doesn't exist
	local zonesFolder = workspace:FindFirstChild("Zones")
	if not zonesFolder then
		zonesFolder = Instance.new("Folder")
		zonesFolder.Name = "Zones"
		zonesFolder.Parent = workspace
	end

	-- Initialize spawner for each zone
	for zoneID = 1, 10 do
		-- Create or get zone folder
		local zoneFolderName = "Zone" .. zoneID
		local zoneFolder = zonesFolder:FindFirstChild(zoneFolderName)
		if not zoneFolder then
			zoneFolder = Instance.new("Folder")
			zoneFolder.Name = zoneFolderName
			zoneFolder.Parent = zonesFolder
		end

		-- Create spawner instance
		local spawner = HomeworkSpawner.new(zoneID, zoneFolder)
		if spawner then
			ZoneHomeworkSpawners[zoneID] = spawner

			-- Start spawning for Zone 1 (Classroom) immediately since it's unlocked by default
			if zoneID == 1 then
				spawner:Start()
				warn("[GameServer] Started homework spawning in Zone 1 (Classroom)")
			end

			warn(string.format("[GameServer] Initialized HomeworkSpawner for Zone %d", zoneID))
		else
			warn(string.format("[GameServer] Failed to initialize HomeworkSpawner for Zone %d", zoneID))
		end
	end

	-- Set up click detection for homework
	self:SetupHomeworkClickDetection()
end

--[[
	Set up click detection for all homework in all zones
]]
function GameServer:SetupHomeworkClickDetection()
	-- Monitor for new homework being created and connect ClickDetector
	local zonesFolder = workspace:WaitForChild("Zones")

	-- Function to connect click detector to homework model
	local function ConnectHomeworkClick(homeworkModel, zoneID)
		local clickDetector = homeworkModel:FindFirstChildWhichIsA("ClickDetector", true)
		if not clickDetector then
			return
		end

		clickDetector.MouseClick:Connect(function(player)
			local playerData = DataManager:GetPlayerData(player)
			if not playerData then
				return
			end

			local spawner = ZoneHomeworkSpawners[zoneID]
			if not spawner then
				return
			end

			-- Handle the click through CombatManager
			CombatManager.HandleClick(player, homeworkModel, spawner, playerData)
		end)
	end

	-- Connect to existing and future homework
	for zoneID, spawner in pairs(ZoneHomeworkSpawners) do
		local zoneFolder = zonesFolder:FindFirstChild("Zone" .. zoneID)
		if zoneFolder then
			local homeworkFolder = zoneFolder:FindFirstChild("ActiveHomework")
			if homeworkFolder then
				-- Connect to existing homework
				for _, homeworkModel in ipairs(homeworkFolder:GetChildren()) do
					if homeworkModel:IsA("Model") then
						ConnectHomeworkClick(homeworkModel, zoneID)
					end
				end

				-- Connect to future homework
				homeworkFolder.ChildAdded:Connect(function(child)
					if child:IsA("Model") then
						task.wait() -- Wait for click detector to be added
						ConnectHomeworkClick(child, zoneID)
					end
				end)
			end
		end
	end

	warn("[GameServer] Homework click detection set up for all zones")
end

--[[
	Start homework spawning in a specific zone
	Called when a player unlocks a new zone
]]
function GameServer:StartZoneSpawning(zoneID)
	local spawner = ZoneHomeworkSpawners[zoneID]
	if spawner and not spawner.IsRunning then
		spawner:Start()
		warn(string.format("[GameServer] Started homework spawning in Zone %d", zoneID))
		return true
	end
	return false
end

--[[
	Stop homework spawning in a specific zone
]]
function GameServer:StopZoneSpawning(zoneID)
	local spawner = ZoneHomeworkSpawners[zoneID]
	if spawner and spawner.IsRunning then
		spawner:Stop()
		warn(string.format("[GameServer] Stopped homework spawning in Zone %d", zoneID))
		return true
	end
	return false
end

--[[
	Get homework spawner for a zone
]]
function GameServer:GetZoneSpawner(zoneID)
	return ZoneHomeworkSpawners[zoneID]
end

--[[
	Initializes the game server
]]
function GameServer:Initialize()
	warn("[GameServer] Initializing game server...")

	-- Export GameServer to global FIRST to avoid circular dependency issues
	_G.GameServer = GameServer

	-- Initialize RemoteEvents (must be first for other systems to use)
	warn("[GameServer] Initializing RemoteEvents...")
	-- RemoteEvents auto-initializes on require if on server

	-- Initialize DataManager first (no dependencies)
	warn("[GameServer] Initializing DataManager...")
	DataManager:Initialize()

	-- Initialize CombatManager (depends on DataManager)
	warn("[GameServer] Initializing CombatManager...")
	CombatManager.Initialize()

	-- Initialize BossManager (depends on DataManager via GameServer)
	warn("[GameServer] Initializing BossManager...")
	BossManager:Initialize()

	-- Initialize ZoneManager (depends on DataManager)
	warn("[GameServer] Initializing ZoneManager...")
	ZoneManager.Init()

	-- Initialize HomeworkSpawners for all zones
	warn("[GameServer] Initializing HomeworkSpawners...")
	self:InitializeHomeworkSpawners()

	-- Initialize AchievementManager (depends on DataManager)
	warn("[GameServer] Initializing AchievementManager...")
	AchievementManager:Initialize()

	-- Initialize PrestigeManager (depends on DataManager)
	warn("[GameServer] Initializing PrestigeManager...")
	PrestigeManager:Initialize()

	-- Initialize ShopManager (depends on DataManager)
	warn("[GameServer] Initializing ShopManager...")
	ShopManager:Initialize()

	-- Initialize GamepassManager (depends on DataManager)
	warn("[GameServer] Initializing GamepassManager...")
	GamepassManager:Initialize()

	-- Initialize ChallengeManager (depends on DataManager)
	warn("[GameServer] Initializing ChallengeManager...")
	ChallengeManager:Initialize()

	-- Initialize QuestManager (depends on DataManager)
	warn("[GameServer] Initializing QuestManager...")
	QuestManager:Initialize()

	-- Connect RemoteEvent handlers
	warn("[GameServer] Connecting RemoteEvent handlers...")
	self:ConnectRemoteEvents()

	-- Connect player events
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerJoined(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerLeaving(player)
	end)

	-- Handle players already in game (for studio testing)
	for _, player in ipairs(Players:GetPlayers()) do
		self:OnPlayerJoined(player)
	end

	-- Start server loop
	self:StartServerLoop()

	warn("[GameServer] Game server initialized successfully!")
end

--[[
	Connect RemoteEvent handlers for gameplay
]]
function GameServer:ConnectRemoteEvents()
	local remotes = RemoteEvents.Get()

	-- Rebirth event
	if remotes.PerformRebirth then
		remotes.PerformRebirth.OnServerEvent:Connect(function(player)
			local data = DataManager:GetPlayerData(player)
			if not data then return end

			local success, message = DataManager:PerformRebirth(player)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				remotes.ShowNotification:FireClient(player, notifType, success and "Rebirth Complete!" or "Rebirth Failed", message, 5)
			end

			-- Sync full data after rebirth
			if success and remotes.FullDataSync then
				remotes.FullDataSync:FireClient(player, data)
			end
		end)
	end

	-- Prestige event
	if remotes.PerformPrestige then
		remotes.PerformPrestige.OnServerEvent:Connect(function(player)
			local success, message = self:PerformPrestige(player)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				remotes.ShowNotification:FireClient(player, notifType, success and "Prestige Complete!" or "Prestige Failed", message, 5)
			end

			-- Sync full data after prestige
			if success and remotes.FullDataSync then
				local data = DataManager:GetPlayerData(player)
				if data then
					remotes.FullDataSync:FireClient(player, data)
				end
			end
		end)
	end

	-- Zone unlock event
	if remotes.UnlockZone then
		remotes.UnlockZone.OnServerEvent:Connect(function(player, zoneId)
			local success, message = self:UnlockZone(player, zoneId)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				remotes.ShowNotification:FireClient(player, notifType, success and "Zone Unlocked!" or "Unlock Failed", message, 3)
			end

			-- Sync data after unlock
			if success and remotes.DataUpdate then
				local data = DataManager:GetPlayerData(player)
				if data then
					remotes.DataUpdate:FireClient(player, "UnlockedZones", data.UnlockedZones)
					remotes.DataUpdate:FireClient(player, "DestructionPoints", data.DestructionPoints)
				end
			end
		end)
	end

	-- Request data sync
	if remotes.RequestDataSync then
		remotes.RequestDataSync.OnServerEvent:Connect(function(player)
			local data = DataManager:GetPlayerData(player)
			if data and remotes.FullDataSync then
				remotes.FullDataSync:FireClient(player, data)
			end
		end)
	end

	-- Purchase Upgrade event
	if remotes.PurchaseUpgrade then
		remotes.PurchaseUpgrade.OnServerEvent:Connect(function(player, upgradeCategory, upgradeName)
			local data = DataManager:GetPlayerData(player)
			if not data then return end

			-- Call UpgradeManager to handle the purchase
			local success, message = UpgradeManager:PurchaseUpgrade(data, upgradeName)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				local title = success and "Upgrade Purchased!" or "Purchase Failed"
				remotes.ShowNotification:FireClient(player, notifType, title, message, 3)
			end

			-- Sync data after purchase
			if success and remotes.DataUpdate then
				-- Sync the upgrades table and DP
				remotes.DataUpdate:FireClient(player, "Upgrades", data.Upgrades)
				remotes.DataUpdate:FireClient(player, "DestructionPoints", data.DestructionPoints)
			end
		end)
	end

	-- Hatch Egg event
	if remotes.HatchEgg then
		remotes.HatchEgg.OnServerEvent:Connect(function(player, eggType)
			-- Call PetManager to hatch the egg
			local result = PetManager.HatchEgg(player, eggType)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = result.Success and "Success" or "Error"
				local title = result.Success and "Egg Hatched!" or "Hatch Failed"
				local message = result.Message or "Unknown error"
				remotes.ShowNotification:FireClient(player, notifType, title, message, 3)
			end

			-- Sync data after hatching
			if result.Success then
				local data = DataManager:GetPlayerData(player)
				if data and remotes.DataUpdate then
					-- Sync eggs inventory and DP
					remotes.DataUpdate:FireClient(player, "Eggs", data.Eggs)
					remotes.DataUpdate:FireClient(player, "DestructionPoints", data.DestructionPoints)
				end

				-- Send pet data if available
				if result.Pet and remotes.DataUpdate then
					remotes.DataUpdate:FireClient(player, "Pets", result.Pet)
				end
			end
		end)
	end

	-- Equip Pet event
	if remotes.EquipPet then
		remotes.EquipPet.OnServerEvent:Connect(function(player, petID, slotNumber)
			-- Call PetManager to equip the pet
			local result = PetManager.EquipPet(player, petID, slotNumber)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = result.Success and "Success" or "Error"
				local title = result.Success and "Pet Equipped!" or "Equip Failed"
				local message = result.Message or "Unknown error"
				remotes.ShowNotification:FireClient(player, notifType, title, message, 2)
			end

			-- Sync data after equipping
			if result.Success and remotes.DataUpdate then
				local data = DataManager:GetPlayerData(player)
				if data then
					-- Sync equipped pets
					remotes.DataUpdate:FireClient(player, "EquippedPets", data.EquippedPets)
				end
			end
		end)
	end

	-- Purchase Tool event
	if remotes.PurchaseTool then
		remotes.PurchaseTool.OnServerEvent:Connect(function(player, toolID)
			local data = DataManager:GetPlayerData(player)
			if not data then return end

			-- Get the player's ToolManager
			local toolManager = ToolManager.Get(player)
			if not toolManager then
				-- Try to initialize if not found
				toolManager = ToolManager.Initialize(player, data)
			end

			if not toolManager then
				if remotes.ShowNotification then
					remotes.ShowNotification:FireClient(player, "Error", "Purchase Failed", "Tool system not initialized", 3)
				end
				return
			end

			-- Attempt purchase
			local success, message = toolManager:PurchaseTool(toolID)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				local title = success and "Tool Purchased!" or "Purchase Failed"
				remotes.ShowNotification:FireClient(player, notifType, title, message, 3)
			end

			-- Sync data after purchase
			if success and remotes.DataUpdate then
				remotes.DataUpdate:FireClient(player, "Tools", data.Tools)
				remotes.DataUpdate:FireClient(player, "DestructionPoints", data.DestructionPoints)
			end
		end)
	end

	-- Equip Tool event
	if remotes.EquipTool then
		remotes.EquipTool.OnServerEvent:Connect(function(player, toolID, slotNumber)
			local data = DataManager:GetPlayerData(player)
			if not data then return end

			-- Get the player's ToolManager
			local toolManager = ToolManager.Get(player)
			if not toolManager then
				-- Try to initialize if not found
				toolManager = ToolManager.Initialize(player, data)
			end

			if not toolManager then
				if remotes.ShowNotification then
					remotes.ShowNotification:FireClient(player, "Error", "Equip Failed", "Tool system not initialized", 3)
				end
				return
			end

			-- Attempt to equip tool
			local success, message = toolManager:EquipTool(toolID, slotNumber)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				local title = success and "Tool Equipped!" or "Equip Failed"
				remotes.ShowNotification:FireClient(player, notifType, title, message, 2)
			end

			-- Sync data after equipping
			if success and remotes.DataUpdate then
				remotes.DataUpdate:FireClient(player, "Tools", data.Tools)
			end
		end)
	end

	-- Upgrade Tool event
	if remotes.UpgradeTool then
		remotes.UpgradeTool.OnServerEvent:Connect(function(player, toolID)
			local data = DataManager:GetPlayerData(player)
			if not data then return end

			-- Get the player's ToolManager
			local toolManager = ToolManager.Get(player)
			if not toolManager then
				-- Try to initialize if not found
				toolManager = ToolManager.Initialize(player, data)
			end

			if not toolManager then
				if remotes.ShowNotification then
					remotes.ShowNotification:FireClient(player, "Error", "Upgrade Failed", "Tool system not initialized", 3)
				end
				return
			end

			-- Attempt to upgrade tool
			local success, message = toolManager:UpgradeTool(toolID)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				local title = success and "Tool Upgraded!" or "Upgrade Failed"
				remotes.ShowNotification:FireClient(player, notifType, title, message, 3)
			end

			-- Sync data after upgrade
			if success and remotes.DataUpdate then
				remotes.DataUpdate:FireClient(player, "Tools", data.Tools)
				remotes.DataUpdate:FireClient(player, "ToolUpgradeTokens", data.ToolUpgradeTokens)
			end
		end)
	end

	warn("[GameServer] RemoteEvent handlers connected")
end

--[[
	Handle player joining and initialize all their systems
]]
function GameServer:InitializePlayerSystems(player, data)
	-- Initialize ToolManager for player
	local toolManager = ToolManager.Initialize(player, data)

	-- Initialize PetManager for player
	PetManager.InitializePlayer(player)

	-- Initialize ChallengeManager for player
	ChallengeManager:InitializePlayer(player, data)

	-- Initialize QuestManager for player
	QuestManager:InitializePlayer(player, data)

	-- Start homework spawning for all unlocked zones
	for _, zoneID in ipairs(data.UnlockedZones) do
		self:StartZoneSpawning(zoneID)
	end

	warn("[GameServer] Initialized all systems for player: " .. player.Name)
end

return GameServer
