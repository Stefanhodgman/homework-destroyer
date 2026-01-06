--[[
	ChallengeManager.lua

	Manages daily and weekly challenges for Homework Destroyer

	Features:
	- Daily challenges that reset at midnight UTC
	- Weekly challenges that reset on Monday midnight UTC
	- Challenge rotation system
	- Streak bonuses for completing challenges
	- Challenge progress tracking
	- Reward distribution

	Author: Homework Destroyer Team
	Version: 1.0
]]

local ChallengeManager = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local CHALLENGES_PER_DAY = 3
local WEEKLY_CHALLENGES_COUNT = 5
local DAILY_RESET_HOUR = 0 -- Midnight UTC
local WEEKLY_RESET_DAY = 2 -- Monday (1 = Sunday, 2 = Monday, etc.)

-- Challenge Types
local ChallengeTypes = {
	DESTROY_HOMEWORK = "DestroyHomework",
	DESTROY_IN_ZONE = "DestroyInZone",
	DEAL_DAMAGE = "DealDamage",
	USE_TOOL = "UseTool",
	PET_DESTROYS = "PetDestroys",
	DEFEAT_BOSSES = "DefeatBosses",
	EARN_DP = "EarnDP",
	CRITICAL_HITS = "CriticalHits",
	SPEED_CHALLENGE = "SpeedChallenge",
	LOGIN_DAYS = "LoginDays",
	HATCH_EGGS = "HatchEggs",
	REBIRTH = "Rebirth",
	PLAY_TIME = "PlayTime",
}

-- Challenge Pool Definitions
local DailyChallengePool = {
	-- Easy Challenges (Common)
	{
		Type = ChallengeTypes.DESTROY_HOMEWORK,
		Name = "Click Starter",
		Description = "Destroy 500 homework pages",
		Difficulty = "Easy",
		Target = 500,
		Reward = {DP = 5000, Eggs = {}},
		Weight = 30,
	},
	{
		Type = ChallengeTypes.EARN_DP,
		Name = "Quick Login",
		Description = "Earn 10,000 DP",
		Difficulty = "Easy",
		Target = 10000,
		Reward = {DP = 4000, Eggs = {}},
		Weight = 25,
	},
	{
		Type = ChallengeTypes.HATCH_EGGS,
		Name = "Pet Collector",
		Description = "Hatch 1 pet egg",
		Difficulty = "Easy",
		Target = 1,
		Reward = {DP = 7500, Eggs = {}},
		Weight = 20,
	},
	{
		Type = ChallengeTypes.PLAY_TIME,
		Name = "Quick Session",
		Description = "Play for 5 minutes",
		Difficulty = "Easy",
		Target = 300, -- seconds
		Reward = {DP = 4000, Eggs = {}},
		Weight = 25,
	},

	-- Medium Challenges (Uncommon)
	{
		Type = ChallengeTypes.DESTROY_HOMEWORK,
		Name = "Destruction Derby",
		Description = "Destroy 2,500 homework pages",
		Difficulty = "Medium",
		Target = 2500,
		Reward = {DP = 15000, Eggs = {}},
		Weight = 20,
	},
	{
		Type = ChallengeTypes.HATCH_EGGS,
		Name = "Pet Master",
		Description = "Hatch 3 pet eggs",
		Difficulty = "Medium",
		Target = 3,
		Reward = {DP = 20000, Eggs = {}},
		Weight = 15,
	},
	{
		Type = ChallengeTypes.DEAL_DAMAGE,
		Name = "Heavy Hitter",
		Description = "Deal 100,000 total damage",
		Difficulty = "Medium",
		Target = 100000,
		Reward = {DP = 17500, Eggs = {}},
		Weight = 18,
	},
	{
		Type = ChallengeTypes.DESTROY_IN_ZONE,
		Name = "Zone Explorer",
		Description = "Destroy 100 homework in any zone except Classroom",
		Difficulty = "Medium",
		Target = 100,
		ZoneRequirement = 2, -- Must be zone 2+
		Reward = {DP = 12500, Eggs = {}},
		Weight = 15,
	},
	{
		Type = ChallengeTypes.DEFEAT_BOSSES,
		Name = "Boss Hunter",
		Description = "Defeat 2 bosses",
		Difficulty = "Medium",
		Target = 2,
		Reward = {DP = 25000, Eggs = {}},
		Weight = 12,
	},

	-- Hard Challenges (Rare)
	{
		Type = ChallengeTypes.DESTROY_HOMEWORK,
		Name = "Homework Hurricane",
		Description = "Destroy 10,000 homework pages",
		Difficulty = "Hard",
		Target = 10000,
		Reward = {DP = 40000, Eggs = {"Rare"}},
		Weight = 10,
	},
	{
		Type = ChallengeTypes.REBIRTH,
		Name = "Rebirth Champion",
		Description = "Perform 1 rebirth",
		Difficulty = "Hard",
		Target = 1,
		Reward = {DP = 50000, Eggs = {}},
		Weight = 5,
	},
	{
		Type = ChallengeTypes.CRITICAL_HITS,
		Name = "Critical Master",
		Description = "Land 50 critical hits",
		Difficulty = "Hard",
		Target = 50,
		Reward = {DP = 35000, Eggs = {}},
		Weight = 8,
	},
	{
		Type = ChallengeTypes.PLAY_TIME,
		Name = "Marathon Player",
		Description = "Play for 30 minutes in one session",
		Difficulty = "Hard",
		Target = 1800, -- seconds
		Reward = {DP = 45000, Eggs = {}},
		Weight = 7,
	},
	{
		Type = ChallengeTypes.DEFEAT_BOSSES,
		Name = "Boss Slayer",
		Description = "Defeat 5 bosses",
		Difficulty = "Hard",
		Target = 5,
		Reward = {DP = 60000, Eggs = {"Rare"}},
		Weight = 5,
	},
}

-- Weekly Challenge Pool
local WeeklyChallengePool = {
	{
		Type = ChallengeTypes.LOGIN_DAYS,
		Name = "Weekly Warrior",
		Description = "Log in 5 different days",
		Target = 5,
		Reward = {DP = 100000, Eggs = {"Rare"}},
	},
	{
		Type = ChallengeTypes.DESTROY_HOMEWORK,
		Name = "Destruction Master",
		Description = "Destroy 50,000 homework pages total",
		Target = 50000,
		Reward = {DP = 200000, Eggs = {}},
	},
	{
		Type = ChallengeTypes.REBIRTH,
		Name = "Rebirth Ruler",
		Description = "Perform 3 rebirths",
		Target = 3,
		Reward = {DP = 250000, Eggs = {"Epic"}},
	},
	{
		Type = ChallengeTypes.DEFEAT_BOSSES,
		Name = "Boss Exterminator",
		Description = "Defeat 25 bosses",
		Target = 25,
		Reward = {DP = 150000, Eggs = {}},
	},
	{
		Type = ChallengeTypes.EARN_DP,
		Name = "Wealth Builder",
		Description = "Earn 1,000,000 DP",
		Target = 1000000,
		Reward = {DP = 300000, Eggs = {"Epic"}},
	},
}

-- Active challenges storage (per player)
local PlayerChallenges = {}

-- Player daily login tracking for weekly challenge
local PlayerLoginDays = {}

-- Utility Functions

--[[
	Gets the current UTC timestamp
]]
local function GetCurrentTime()
	return os.time()
end

--[[
	Gets the start of the current day (midnight UTC)
]]
local function GetDayStart(timestamp)
	timestamp = timestamp or GetCurrentTime()
	local date = os.date("!*t", timestamp)
	date.hour = 0
	date.min = 0
	date.sec = 0
	return os.time(date)
end

--[[
	Gets the start of the current week (Monday midnight UTC)
]]
local function GetWeekStart(timestamp)
	timestamp = timestamp or GetCurrentTime()
	local date = os.date("!*t", timestamp)

	-- Calculate days to subtract to get to Monday
	local daysToMonday = (date.wday - WEEKLY_RESET_DAY + 7) % 7
	local mondayTimestamp = timestamp - (daysToMonday * 86400)

	-- Set to midnight
	local mondayDate = os.date("!*t", mondayTimestamp)
	mondayDate.hour = 0
	mondayDate.min = 0
	mondayDate.sec = 0

	return os.time(mondayDate)
end

--[[
	Weighted random selection from challenge pool
]]
local function SelectWeightedChallenge(pool, excludedIndices)
	excludedIndices = excludedIndices or {}

	-- Calculate total weight (excluding already selected)
	local totalWeight = 0
	for i, challenge in ipairs(pool) do
		if not table.find(excludedIndices, i) then
			totalWeight = totalWeight + (challenge.Weight or 10)
		end
	end

	if totalWeight == 0 then
		return nil
	end

	-- Random selection
	local random = math.random() * totalWeight
	local currentWeight = 0

	for i, challenge in ipairs(pool) do
		if not table.find(excludedIndices, i) then
			currentWeight = currentWeight + (challenge.Weight or 10)
			if random <= currentWeight then
				return i, challenge
			end
		end
	end

	return nil
end

--[[
	Generates daily challenges for a player
]]
local function GenerateDailyChallenges()
	local challenges = {}
	local selectedIndices = {}

	for i = 1, CHALLENGES_PER_DAY do
		local index, challenge = SelectWeightedChallenge(DailyChallengePool, selectedIndices)

		if challenge then
			table.insert(selectedIndices, index)
			table.insert(challenges, {
				Type = challenge.Type,
				Name = challenge.Name,
				Description = challenge.Description,
				Difficulty = challenge.Difficulty,
				Target = challenge.Target,
				Progress = 0,
				Completed = false,
				Claimed = false,
				Reward = challenge.Reward,
				ZoneRequirement = challenge.ZoneRequirement,
			})
		end
	end

	return challenges
end

--[[
	Generates weekly challenges for a player
]]
local function GenerateWeeklyChallenges()
	local challenges = {}

	for i, challengeTemplate in ipairs(WeeklyChallengePool) do
		if i <= WEEKLY_CHALLENGES_COUNT then
			table.insert(challenges, {
				Type = challengeTemplate.Type,
				Name = challengeTemplate.Name,
				Description = challengeTemplate.Description,
				Target = challengeTemplate.Target,
				Progress = 0,
				Completed = false,
				Claimed = false,
				Reward = challengeTemplate.Reward,
			})
		end
	end

	return challenges
end

-- Public Functions

--[[
	Initialize challenge system for a player
]]
function ChallengeManager:InitializePlayer(player, playerData)
	local userId = player.UserId

	-- Initialize login tracking for weekly challenge
	PlayerLoginDays[userId] = PlayerLoginDays[userId] or {}

	-- Check if we need to refresh challenges
	local currentTime = GetCurrentTime()
	local dayStart = GetDayStart(currentTime)
	local weekStart = GetWeekStart(currentTime)

	-- Initialize or load player challenges
	if not playerData.DailyProgress then
		playerData.DailyProgress = {
			LastChallengeRefresh = 0,
			DailyChallenges = {},
			ChallengesCompletedToday = 0,
			DailyStreakCount = 0,
			LastStreakDate = 0,
		}
	end

	if not playerData.WeeklyProgress then
		playerData.WeeklyProgress = {
			LastChallengeRefresh = 0,
			WeeklyChallenges = {},
			ChallengesCompletedThisWeek = 0,
		}
	end

	-- Check if daily challenges need refresh
	if playerData.DailyProgress.LastChallengeRefresh < dayStart then
		-- New day - generate fresh challenges
		playerData.DailyProgress.DailyChallenges = GenerateDailyChallenges()
		playerData.DailyProgress.LastChallengeRefresh = dayStart
		playerData.DailyProgress.ChallengesCompletedToday = 0

		-- Update streak
		local lastStreakDay = GetDayStart(playerData.DailyProgress.LastStreakDate)
		local yesterdayStart = dayStart - 86400

		if lastStreakDay == yesterdayStart then
			-- Consecutive day
			playerData.DailyProgress.DailyStreakCount = playerData.DailyProgress.DailyStreakCount + 1
		elseif lastStreakDay < yesterdayStart then
			-- Streak broken
			playerData.DailyProgress.DailyStreakCount = 0
		end

		warn(string.format("[ChallengeManager] Generated daily challenges for %s", player.Name))
	end

	-- Check if weekly challenges need refresh
	if playerData.WeeklyProgress.LastChallengeRefresh < weekStart then
		-- New week - generate fresh challenges
		playerData.WeeklyProgress.WeeklyChallenges = GenerateWeeklyChallenges()
		playerData.WeeklyProgress.LastChallengeRefresh = weekStart
		playerData.WeeklyProgress.ChallengesCompletedThisWeek = 0

		-- Reset login day tracking
		PlayerLoginDays[userId] = {}

		warn(string.format("[ChallengeManager] Generated weekly challenges for %s", player.Name))
	end

	-- Track login for weekly challenge
	local today = os.date("!%Y-%m-%d", currentTime)
	if not table.find(PlayerLoginDays[userId], today) then
		table.insert(PlayerLoginDays[userId], today)

		-- Update weekly login challenge progress
		self:UpdateChallengeProgress(player, ChallengeTypes.LOGIN_DAYS, 1)
	end

	-- Store reference
	PlayerChallenges[userId] = {
		Daily = playerData.DailyProgress.DailyChallenges,
		Weekly = playerData.WeeklyProgress.WeeklyChallenges,
	}

	return playerData
end

--[[
	Update challenge progress for a player
]]
function ChallengeManager:UpdateChallengeProgress(player, challengeType, amount, extraData)
	local userId = player.UserId

	if not PlayerChallenges[userId] then
		warn("[ChallengeManager] Player challenges not initialized for: " .. player.Name)
		return
	end

	amount = amount or 1
	extraData = extraData or {}

	-- Update daily challenges
	for _, challenge in ipairs(PlayerChallenges[userId].Daily) do
		if challenge.Type == challengeType and not challenge.Completed then
			-- Check zone requirement if applicable
			if challenge.ZoneRequirement and extraData.Zone then
				if extraData.Zone < challenge.ZoneRequirement then
					continue
				end
			end

			challenge.Progress = math.min(challenge.Progress + amount, challenge.Target)

			-- Check completion
			if challenge.Progress >= challenge.Target then
				challenge.Completed = true
				warn(string.format("[ChallengeManager] %s completed daily challenge: %s", player.Name, challenge.Name))

				-- Fire completion event to client
				local remoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
				remoteEvents.SafeFireClient("ShowNotification", player, "Challenge", "Daily Challenge Complete!", challenge.Name, 5)
			end
		end
	end

	-- Update weekly challenges
	for _, challenge in ipairs(PlayerChallenges[userId].Weekly) do
		if challenge.Type == challengeType and not challenge.Completed then
			challenge.Progress = math.min(challenge.Progress + amount, challenge.Target)

			-- Check completion
			if challenge.Progress >= challenge.Target then
				challenge.Completed = true
				warn(string.format("[ChallengeManager] %s completed weekly challenge: %s", player.Name, challenge.Name))

				-- Fire completion event to client
				local remoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
				remoteEvents.SafeFireClient("ShowNotification", player, "Challenge", "Weekly Challenge Complete!", challenge.Name, 5)
			end
		end
	end
end

--[[
	Claim reward for a completed challenge
]]
function ChallengeManager:ClaimChallengeReward(player, isWeekly, challengeIndex, DataManager)
	local userId = player.UserId

	if not PlayerChallenges[userId] then
		return false, "Challenges not initialized"
	end

	local challengeList = isWeekly and PlayerChallenges[userId].Weekly or PlayerChallenges[userId].Daily
	local challenge = challengeList[challengeIndex]

	if not challenge then
		return false, "Challenge not found"
	end

	if not challenge.Completed then
		return false, "Challenge not completed"
	end

	if challenge.Claimed then
		return false, "Reward already claimed"
	end

	-- Mark as claimed
	challenge.Claimed = true

	-- Award rewards
	if challenge.Reward.DP and challenge.Reward.DP > 0 then
		DataManager:IncrementPlayerData(player, "DestructionPoints", challenge.Reward.DP)
		DataManager:IncrementPlayerData(player, "LifetimeDP", challenge.Reward.DP)
	end

	-- Track completion count
	local playerData = DataManager:GetPlayerData(player)
	if isWeekly then
		playerData.WeeklyProgress.ChallengesCompletedThisWeek = playerData.WeeklyProgress.ChallengesCompletedThisWeek + 1
	else
		playerData.DailyProgress.ChallengesCompletedToday = playerData.DailyProgress.ChallengesCompletedToday + 1
		playerData.DailyProgress.LastStreakDate = GetCurrentTime()
	end

	-- Check for completion bonuses
	if not isWeekly and playerData.DailyProgress.ChallengesCompletedToday >= CHALLENGES_PER_DAY then
		-- All daily challenges complete - bonus reward
		local bonusDP = 15000 * (1 + playerData.DailyProgress.DailyStreakCount * 0.1)
		DataManager:IncrementPlayerData(player, "DestructionPoints", bonusDP)

		local remoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
		remoteEvents.SafeFireClient("ShowNotification", player, "Bonus", "Daily Challenge Bonus!",
			string.format("Completed all challenges! +%d DP (Streak: %d days)", bonusDP, playerData.DailyProgress.DailyStreakCount), 7)
	end

	if isWeekly and playerData.WeeklyProgress.ChallengesCompletedThisWeek >= WEEKLY_CHALLENGES_COUNT then
		-- All weekly challenges complete - bonus reward
		local bonusDP = 500000
		DataManager:IncrementPlayerData(player, "DestructionPoints", bonusDP)

		local remoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
		remoteEvents.SafeFireClient("ShowNotification", player, "Bonus", "Weekly Challenge Bonus!",
			"Completed all weekly challenges! +" .. bonusDP .. " DP + Legendary Egg!", 7)
	end

	warn(string.format("[ChallengeManager] %s claimed reward for %s challenge: %s",
		player.Name, isWeekly and "weekly" or "daily", challenge.Name))

	return true, challenge.Reward
end

--[[
	Get challenge data for a player
]]
function ChallengeManager:GetPlayerChallenges(player)
	local userId = player.UserId

	if not PlayerChallenges[userId] then
		return nil
	end

	return PlayerChallenges[userId]
end

--[[
	Get daily streak count for a player
]]
function ChallengeManager:GetDailyStreak(player, playerData)
	if playerData and playerData.DailyProgress then
		return playerData.DailyProgress.DailyStreakCount or 0
	end
	return 0
end

--[[
	Cleanup when player leaves
]]
function ChallengeManager:OnPlayerLeaving(player)
	local userId = player.UserId

	PlayerChallenges[userId] = nil
	PlayerLoginDays[userId] = nil

	warn(string.format("[ChallengeManager] Cleaned up challenges for %s", player.Name))
end

--[[
	Initialize the Challenge Manager
]]
function ChallengeManager:Initialize()
	-- Get DataManager from global
	local DataManager = require(game:GetService("ServerScriptService").DataManager)

	-- Connect RemoteEvent handlers
	local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
	local remotes = RemoteEvents.Get()

	-- Handle challenge reward claiming
	if remotes.ClaimChallengeReward then
		remotes.ClaimChallengeReward.OnServerEvent:Connect(function(player, isWeekly, challengeIndex)
			local success, reward = ChallengeManager:ClaimChallengeReward(player, isWeekly, challengeIndex, DataManager)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				local title = success and "Reward Claimed!" or "Claim Failed"
				local message = success and string.format("Received %d DP!", reward.DP or 0) or tostring(reward)
				remotes.ShowNotification:FireClient(player, notifType, title, message, 3)
			end

			-- Sync data after claiming
			if success and remotes.DataUpdate then
				local data = DataManager:GetPlayerData(player)
				if data then
					remotes.DataUpdate:FireClient(player, "DestructionPoints", data.DestructionPoints)
				end
			end
		end)
	end

	warn("[ChallengeManager] Challenge system initialized")
	return true
end

return ChallengeManager
