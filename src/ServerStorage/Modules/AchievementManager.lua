--[[
	AchievementManager.lua

	Server-side achievement tracking and unlocking system for Homework Destroyer

	Responsibilities:
	- Check achievement requirements
	- Track progress toward achievements
	- Award achievements and their rewards
	- Sync achievement status to clients
	- Handle special/custom achievement logic

	Author: Homework Destroyer Team
	Version: 1.0
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AchievementManager = {}

-- Module references
local AchievementsConfig = require(script.Parent.AchievementsConfig)
local DataManager -- Lazy loaded to avoid circular dependencies

-- Remote events for client communication
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local AchievementUnlockedEvent -- Will be created if doesn't exist

-- Active player session tracking for special achievements
local PlayerSessions = {}

-- ============================================================
-- INITIALIZATION
-- ============================================================

function AchievementManager:Initialize()
	warn("[AchievementManager] Initializing Achievement System...")

	-- Lazy load DataManager
	local ServerScriptService = game:GetService("ServerScriptService")
	DataManager = require(ServerScriptService.DataManager)

	-- Get achievement remote event (created by RemoteEvents module)
	AchievementUnlockedEvent = RemoteEventsFolder:WaitForChild("UnlockAchievement")

	-- Connect to player events
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerJoined(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerLeaving(player)
	end)

	warn("[AchievementManager] Achievement System initialized. Total achievements: " .. AchievementsConfig.GetTotalAchievementCount())
end

-- ============================================================
-- PLAYER SESSION MANAGEMENT
-- ============================================================

function AchievementManager:OnPlayerJoined(player)
	-- Initialize session tracking for special achievements
	PlayerSessions[player.UserId] = {
		Player = player,
		JoinTime = os.time(),

		-- Speed Demon tracking (100 homework in 1 minute)
		SpeedDemonTracker = {
			Destructions = {},
			WindowSize = 60, -- 1 minute
		},

		-- Critical King tracking (50 crits in a row)
		CriticalKingTracker = {
			ConsecutiveCrits = 0,
			Required = 50,
		},

		-- The One tracking (exactly 1M damage)
		TheOneTracker = {
			Watching = true,
		},

		-- Untouchable tracking (boss no-hit)
		UntouchableTracker = {
			InBossFight = false,
			BossName = nil,
			TookDamage = false,
		},
	}

	-- Check time-based achievements
	self:CheckTimeBasedAchievements(player)

	warn("[AchievementManager] Session initialized for " .. player.Name)
end

function AchievementManager:OnPlayerLeaving(player)
	PlayerSessions[player.UserId] = nil
end

-- ============================================================
-- CORE ACHIEVEMENT CHECKING
-- ============================================================

-- Check all achievements for a player
function AchievementManager:CheckAllAchievements(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	local allAchievements = AchievementsConfig.GetAllAchievements()
	local newUnlocks = 0

	for _, achievement in ipairs(allAchievements) do
		if not self:HasAchievement(player, achievement.ID) then
			if self:CheckAchievementRequirement(player, achievement) then
				self:UnlockAchievement(player, achievement.ID)
				newUnlocks = newUnlocks + 1
			end
		end
	end

	return newUnlocks
end

-- Check a specific achievement
function AchievementManager:CheckAchievement(player, achievementID)
	if self:HasAchievement(player, achievementID) then
		return false -- Already unlocked
	end

	local achievement = AchievementsConfig.GetAchievementByID(achievementID)
	if not achievement then
		warn("[AchievementManager] Achievement not found: " .. achievementID)
		return false
	end

	if self:CheckAchievementRequirement(player, achievement) then
		self:UnlockAchievement(player, achievementID)
		return true
	end

	return false
end

-- Check if achievement requirement is met
function AchievementManager:CheckAchievementRequirement(player, achievement)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return false
	end

	local reqType = achievement.RequirementType

	if reqType == "Count" then
		-- Check if a stat has reached a certain value
		local currentValue = self:GetNestedValue(data, achievement.StatToTrack)
		return currentValue >= achievement.RequiredValue

	elseif reqType == "Custom" then
		-- Run custom check function
		if achievement.CustomCheck then
			local success, result = pcall(achievement.CustomCheck, data)
			if success then
				return result
			else
				warn("[AchievementManager] Custom check failed for " .. achievement.ID .. ": " .. tostring(result))
				return false
			end
		end
		return false

	elseif reqType == "Stat" then
		-- Similar to Count but more flexible
		local currentValue = self:GetNestedValue(data, achievement.StatToTrack)
		return currentValue >= achievement.RequiredValue

	elseif reqType == "Collection" then
		-- Check if player has collected specific items
		-- Implementation depends on collection type
		return false
	end

	return false
end

-- Get a nested value from player data (e.g., "LifetimeStats.TotalHomeworkDestroyed")
function AchievementManager:GetNestedValue(data, path)
	local current = data
	for key in string.gmatch(path, "[^%.]+") do
		if type(current) == "table" and current[key] ~= nil then
			current = current[key]
		else
			return 0 -- Return 0 if path doesn't exist
		end
	end
	return current
end

-- ============================================================
-- ACHIEVEMENT UNLOCKING
-- ============================================================

-- Unlock an achievement and award rewards
function AchievementManager:UnlockAchievement(player, achievementID)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return false
	end

	-- Check if already unlocked
	if data.Achievements[achievementID] and data.Achievements[achievementID] ~= false then
		return false
	end

	-- Get achievement config
	local achievement = AchievementsConfig.GetAchievementByID(achievementID)
	if not achievement then
		warn("[AchievementManager] Cannot unlock unknown achievement: " .. achievementID)
		return false
	end

	-- Mark as unlocked with timestamp
	data.Achievements[achievementID] = os.time()

	-- Award rewards
	self:AwardAchievementRewards(player, achievement)

	-- Notify client
	self:NotifyClient(player, achievement)

	-- Save data
	DataManager:SavePlayerData(player)

	warn("[AchievementManager] Achievement unlocked for " .. player.Name .. ": " .. achievement.Name)

	-- Check for True Completionist
	if achievementID ~= "TrueCompletionist" then
		self:CheckAchievement(player, "TrueCompletionist")
	end

	return true
end

-- Award all rewards from an achievement
function AchievementManager:AwardAchievementRewards(player, achievement)
	local data = DataManager:GetPlayerData(player)
	if not data or not achievement.Rewards then
		return
	end

	local rewards = achievement.Rewards

	-- Award Destruction Points
	if rewards.DP then
		DataManager:IncrementPlayerData(player, "DestructionPoints", rewards.DP)
		warn("[AchievementManager] Awarded " .. rewards.DP .. " DP to " .. player.Name)
	end

	-- Award Tool Tokens
	if rewards.ToolTokens then
		DataManager:IncrementPlayerData(player, "ToolUpgradeTokens", rewards.ToolTokens)
		warn("[AchievementManager] Awarded " .. rewards.ToolTokens .. " Tool Tokens to " .. player.Name)
	end

	-- Award Eggs
	if rewards.Eggs then
		for eggType, count in pairs(rewards.Eggs) do
			if data.Eggs[eggType] then
				data.Eggs[eggType] = data.Eggs[eggType] + count
				warn("[AchievementManager] Awarded " .. count .. "x " .. eggType .. " to " .. player.Name)
			end
		end
	end

	-- Award Title
	if rewards.Title then
		-- Store title in player data (UI would display)
		if not data.UnlockedTitles then
			data.UnlockedTitles = {}
		end
		table.insert(data.UnlockedTitles, rewards.Title)
		warn("[AchievementManager] Awarded title '" .. rewards.Title .. "' to " .. player.Name)
	end

	-- Award Multipliers (permanent stat boosts)
	if rewards.Multiplier then
		if not data.PermanentMultipliers then
			data.PermanentMultipliers = {
				Damage = 0,
				DP = 0,
				XP = 0,
				BossDamage = 0,
				MovementSpeed = 0,
				Speed = 0,
				CritChance = 0,
				PetDamage = 0,
				RebirthMultiplier = 0,
				AllZoneDamage = 0,
			}
		end

		local multType = rewards.Multiplier.Type
		local multAmount = rewards.Multiplier.Amount

		if data.PermanentMultipliers[multType] ~= nil then
			data.PermanentMultipliers[multType] = data.PermanentMultipliers[multType] + multAmount
			warn("[AchievementManager] Awarded +" .. (multAmount * 100) .. "% permanent " .. multType .. " to " .. player.Name)
		end
	end

	-- Award Pet Slot
	if rewards.PetSlot then
		if data.Pets.MaxSlots < 6 then
			data.Pets.MaxSlots = data.Pets.MaxSlots + 1
			warn("[AchievementManager] Awarded +1 Pet Slot to " .. player.Name .. " (now " .. data.Pets.MaxSlots .. ")")
		end
	end

	-- Award Unlocks (special features/pets/tools)
	if rewards.Unlock then
		if not data.SpecialUnlocks then
			data.SpecialUnlocks = {}
		end
		table.insert(data.SpecialUnlocks, rewards.Unlock)
		warn("[AchievementManager] Unlocked special feature: " .. rewards.Unlock .. " for " .. player.Name)
	end

	-- Award Aura (visual effects)
	if rewards.Aura then
		if not data.UnlockedAuras then
			data.UnlockedAuras = {}
		end
		table.insert(data.UnlockedAuras, rewards.Aura)
		warn("[AchievementManager] Unlocked aura: " .. rewards.Aura .. " for " .. player.Name)
	end

	-- Award Badge (Roblox badge integration)
	if rewards.Badge then
		-- Would integrate with Roblox BadgeService
		warn("[AchievementManager] Badge awarded: " .. rewards.Badge .. " for " .. player.Name)
	end
end

-- ============================================================
-- CLIENT NOTIFICATION
-- ============================================================

-- Notify client of achievement unlock
function AchievementManager:NotifyClient(player, achievement)
	if not AchievementUnlockedEvent then
		return
	end

	-- Send achievement data to client for UI display
	local achievementData = {
		ID = achievement.ID,
		Name = achievement.Name,
		Description = achievement.Description,
		Category = achievement.Category,
		Icon = achievement.Icon,
		Rewards = achievement.Rewards,
		Timestamp = os.time(),
	}

	AchievementUnlockedEvent:FireClient(player, achievementData)
end

-- ============================================================
-- ACHIEVEMENT QUERIES
-- ============================================================

-- Check if player has an achievement
function AchievementManager:HasAchievement(player, achievementID)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return false
	end

	return data.Achievements[achievementID] and data.Achievements[achievementID] ~= false
end

-- Get all unlocked achievements for a player
function AchievementManager:GetUnlockedAchievements(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return {}
	end

	local unlocked = {}
	for achievementID, timestamp in pairs(data.Achievements) do
		if timestamp ~= false then
			table.insert(unlocked, {
				ID = achievementID,
				Timestamp = timestamp,
			})
		end
	end

	return unlocked
end

-- Get achievement progress (percentage)
function AchievementManager:GetAchievementProgress(player, achievementID)
	local achievement = AchievementsConfig.GetAchievementByID(achievementID)
	if not achievement then
		return 0
	end

	-- If already unlocked, return 100%
	if self:HasAchievement(player, achievementID) then
		return 1.0
	end

	local data = DataManager:GetPlayerData(player)
	if not data then
		return 0
	end

	-- Calculate progress based on requirement type
	if achievement.RequirementType == "Count" or achievement.RequirementType == "Stat" then
		local currentValue = self:GetNestedValue(data, achievement.StatToTrack)
		local requiredValue = achievement.RequiredValue
		return math.min(currentValue / requiredValue, 1.0)
	end

	-- Custom achievements don't have progress tracking
	return 0
end

-- Get total unlocked count
function AchievementManager:GetUnlockedCount(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return 0
	end

	local count = 0
	for _, timestamp in pairs(data.Achievements) do
		if timestamp ~= false then
			count = count + 1
		end
	end

	return count
end

-- ============================================================
-- SPECIAL ACHIEVEMENT TRACKING
-- ============================================================

-- Track homework destruction for Speed Demon
function AchievementManager:OnHomeworkDestroyed(player, timestamp)
	local session = PlayerSessions[player.UserId]
	if not session then
		return
	end

	-- Speed Demon: 100 homework in 1 minute
	local tracker = session.SpeedDemonTracker
	table.insert(tracker.Destructions, timestamp or os.time())

	-- Remove destructions older than 1 minute
	local cutoffTime = (timestamp or os.time()) - tracker.WindowSize
	local validDestructions = {}

	for _, time in ipairs(tracker.Destructions) do
		if time >= cutoffTime then
			table.insert(validDestructions, time)
		end
	end

	tracker.Destructions = validDestructions

	-- Check if requirement met
	if #tracker.Destructions >= 100 then
		local data = DataManager:GetPlayerData(player)
		if data then
			if not data.AchievementProgress then
				data.AchievementProgress = {}
			end
			data.AchievementProgress.SpeedDemonComplete = true
			self:CheckAchievement(player, "SpeedDemon")
		end
	end
end

-- Track critical hits for Critical King
function AchievementManager:OnCriticalHit(player, wasCrit)
	local session = PlayerSessions[player.UserId]
	if not session then
		return
	end

	local tracker = session.CriticalKingTracker

	if wasCrit then
		tracker.ConsecutiveCrits = tracker.ConsecutiveCrits + 1

		if tracker.ConsecutiveCrits >= tracker.Required then
			local data = DataManager:GetPlayerData(player)
			if data then
				if not data.AchievementProgress then
					data.AchievementProgress = {}
				end
				data.AchievementProgress.CriticalKingComplete = true
				self:CheckAchievement(player, "CriticalKing")
			end
		end
	else
		-- Reset streak on non-crit
		tracker.ConsecutiveCrits = 0
	end
end

-- Track damage for The One achievement
function AchievementManager:OnDamageDealt(player, damage)
	local session = PlayerSessions[player.UserId]
	if not session or not session.TheOneTracker.Watching then
		return
	end

	-- Check for exactly 1,000,000 damage
	if damage == 1000000 then
		local data = DataManager:GetPlayerData(player)
		if data then
			if not data.AchievementProgress then
				data.AchievementProgress = {}
			end
			data.AchievementProgress.TheOneComplete = true
			self:CheckAchievement(player, "TheOne")
			session.TheOneTracker.Watching = false -- Only unlock once
		end
	end
end

-- Track boss fights for Untouchable
function AchievementManager:OnBossFightStart(player, bossName, isVoidZone)
	if not isVoidZone then
		return -- Only Void bosses count
	end

	local session = PlayerSessions[player.UserId]
	if not session then
		return
	end

	local tracker = session.UntouchableTracker
	tracker.InBossFight = true
	tracker.BossName = bossName
	tracker.TookDamage = false
end

function AchievementManager:OnPlayerDamagedByBoss(player)
	local session = PlayerSessions[player.UserId]
	if not session then
		return
	end

	local tracker = session.UntouchableTracker
	if tracker.InBossFight then
		tracker.TookDamage = true
	end
end

function AchievementManager:OnBossFightEnd(player, bossDefeated)
	local session = PlayerSessions[player.UserId]
	if not session then
		return
	end

	local tracker = session.UntouchableTracker

	if tracker.InBossFight and bossDefeated and not tracker.TookDamage then
		-- Completed boss without taking damage!
		local data = DataManager:GetPlayerData(player)
		if data then
			if not data.AchievementProgress then
				data.AchievementProgress = {}
			end
			data.AchievementProgress.UntouchableComplete = true
			self:CheckAchievement(player, "Untouchable")
		end
	end

	-- Reset tracker
	tracker.InBossFight = false
	tracker.BossName = nil
	tracker.TookDamage = false
end

-- Track Principal boss defeats
function AchievementManager:OnPrincipalDefeated(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	if not data.LifetimeStats.PrincipalDefeats then
		data.LifetimeStats.PrincipalDefeats = 0
	end

	data.LifetimeStats.PrincipalDefeats = data.LifetimeStats.PrincipalDefeats + 1

	-- Check for Boss Exterminator achievement
	self:CheckAchievement(player, "BossExterminator")
end

-- ============================================================
-- TIME-BASED ACHIEVEMENTS
-- ============================================================

-- Check time-based achievements on player join
function AchievementManager:CheckTimeBasedAchievements(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	-- Night Owl: Play at 3 AM server time
	local currentHour = tonumber(os.date("%H"))
	if currentHour == 3 then
		if not self:HasAchievement(player, "NightOwl") then
			data.Achievements.NightOwl = os.time()
			self:UnlockAchievement(player, "NightOwl")
		end
	end

	-- Old Timer: Return after 30+ days away
	local lastLogin = data.DailyProgress.LastLoginDate or 0
	local daysSinceLogin = (os.time() - lastLogin) / 86400 -- Seconds to days

	if daysSinceLogin >= 30 and not self:HasAchievement(player, "OldTimer") then
		data.Achievements.OldTimer = os.time()
		self:UnlockAchievement(player, "OldTimer")
	end
end

-- ============================================================
-- BATCH CHECKING (for specific events)
-- ============================================================

-- Check all destruction-related achievements
function AchievementManager:CheckDestructionAchievements(player)
	local achievements = AchievementsConfig.GetAchievementsByCategory("Destruction")

	for _, achievement in ipairs(achievements) do
		self:CheckAchievement(player, achievement.ID)
	end
end

-- Check all boss-related achievements
function AchievementManager:CheckBossAchievements(player)
	local achievements = AchievementsConfig.GetAchievementsByCategory("Boss")

	for _, achievement in ipairs(achievements) do
		self:CheckAchievement(player, achievement.ID)
	end
end

-- Check all zone-related achievements
function AchievementManager:CheckZoneAchievements(player)
	local achievements = AchievementsConfig.GetAchievementsByCategory("Zone")

	for _, achievement in ipairs(achievements) do
		self:CheckAchievement(player, achievement.ID)
	end
end

-- Check all rebirth-related achievements
function AchievementManager:CheckRebirthAchievements(player)
	local achievements = AchievementsConfig.GetAchievementsByCategory("Rebirth")

	for _, achievement in ipairs(achievements) do
		self:CheckAchievement(player, achievement.ID)
	end
end

-- Check all collection-related achievements
function AchievementManager:CheckCollectionAchievements(player)
	local achievements = AchievementsConfig.GetAchievementsByCategory("Collection")

	for _, achievement in ipairs(achievements) do
		self:CheckAchievement(player, achievement.ID)
	end
end

-- Check all special achievements
function AchievementManager:CheckSpecialAchievements(player)
	local achievements = AchievementsConfig.GetAchievementsByCategory("Special")

	for _, achievement in ipairs(achievements) do
		self:CheckAchievement(player, achievement.ID)
	end
end

-- ============================================================
-- EASTER EGG / SECRET TRIGGERS
-- ============================================================

-- Manually trigger easter egg achievement
function AchievementManager:TriggerEasterEgg(player)
	local data = DataManager:GetPlayerData(player)
	if not data then
		return
	end

	if not data.AchievementProgress then
		data.AchievementProgress = {}
	end

	data.AchievementProgress.EasterEggFound = true
	self:CheckAchievement(player, "EasterEggHunter")
end

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- Get achievement statistics for a player
function AchievementManager:GetPlayerStats(player)
	local totalAchievements = AchievementsConfig.GetTotalAchievementCount()
	local unlockedCount = self:GetUnlockedCount(player)
	local completionRate = (unlockedCount / totalAchievements) * 100

	return {
		Total = totalAchievements,
		Unlocked = unlockedCount,
		Locked = totalAchievements - unlockedCount,
		CompletionRate = completionRate,
	}
end

-- Get all achievements with player's unlock status
function AchievementManager:GetAllAchievementsWithStatus(player)
	local allAchievements = AchievementsConfig.GetAllAchievements()
	local result = {}

	for _, achievement in ipairs(allAchievements) do
		local isUnlocked = self:HasAchievement(player, achievement.ID)
		local displayInfo = AchievementsConfig.GetDisplayInfo(achievement.ID, isUnlocked)

		if displayInfo then
			displayInfo.Progress = self:GetAchievementProgress(player, achievement.ID)
			table.insert(result, displayInfo)
		end
	end

	return result
end

return AchievementManager
