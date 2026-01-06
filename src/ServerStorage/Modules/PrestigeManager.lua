--[[
	PrestigeManager.lua
	Prestige system for Homework Destroyer
	Handles prestige eligibility, bonuses, progress reset, and lifetime stats
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local PrestigeManager = {}
PrestigeManager.__index = PrestigeManager

-- Import StatsCalculator
local StatsCalculator = require(ServerStorage.Modules.StatsCalculator)

-- ========================================
-- PRESTIGE CONFIGURATION
-- ========================================

-- Prestige unlock requirements
local PRESTIGE_UNLOCK_REQUIREMENTS = {
	minimumRebirth = 20,
	lifetimeDP = 1000000000, -- 1 Billion
	legendaryPetsRequired = 1,
}

-- Prestige rank definitions
local PRESTIGE_RANKS = {
	{
		rank = 1,
		name = "Homework Hater",
		requirement = {
			type = "prestige_once",
			description = "Complete your first Prestige",
		},
		bonuses = {
			damageMultiplier = 2.0, -- +100% all damage
		},
		rewards = {
			title = "Homework Hater",
		},
	},
	{
		rank = 2,
		name = "Assignment Annihilator",
		requirement = {
			type = "rebirths_post_prestige",
			count = 5,
			description = "Complete 5 total rebirths after your first Prestige",
		},
		bonuses = {
			dpMultiplier = 3.0, -- +200% DP
		},
		rewards = {
			title = "Assignment Annihilator",
		},
	},
	{
		rank = 3,
		name = "Test Terminator",
		requirement = {
			type = "rebirths_post_prestige",
			count = 15,
			description = "Complete 15 total rebirths after your first Prestige",
		},
		bonuses = {
			petDamageMultiplier = 1.5, -- +50% pet damage
		},
		rewards = {
			title = "Test Terminator",
			pet = "GoldenEraser",
		},
	},
	{
		rank = 4,
		name = "Scholar Slayer",
		requirement = {
			type = "rebirths_post_prestige",
			count = 30,
			description = "Complete 30 total rebirths after your first Prestige",
		},
		bonuses = {
			petDamageMultiplier = 1.5, -- Additional +50% pet damage
		},
		rewards = {
			title = "Scholar Slayer",
		},
	},
	{
		rank = 5,
		name = "Education Eliminator",
		requirement = {
			type = "rebirths_post_prestige",
			count = 50,
			description = "Complete 50 total rebirths after your first Prestige",
		},
		bonuses = {
			allStatsMultiplier = 1.5, -- +50% to all stats
		},
		rewards = {
			title = "Education Eliminator",
			zoneUnlock = "VoidZone",
		},
	},
	{
		rank = 6,
		name = "HOMEWORK DESTROYER",
		requirement = {
			type = "rebirths_post_prestige",
			count = 100,
			description = "Complete 100 total rebirths after your first Prestige",
		},
		bonuses = {
			allStatsMultiplier = 10.0, -- x10 all stats
		},
		rewards = {
			title = "HOMEWORK DESTROYER",
			nameEffect = "Rainbow",
			aura = "DestroyerAura",
		},
	},
}

-- ========================================
-- INITIALIZATION
-- ========================================

function PrestigeManager.new()
	local self = setmetatable({}, PrestigeManager)
	self.prestigeCache = {} -- Cache for prestige data
	return self
end

-- ========================================
-- ELIGIBILITY CHECKS
-- ========================================

function PrestigeManager:IsPrestigeUnlocked(playerData)
	-- Check if player has ever reached Rebirth 20
	local hasReachedRebirth20 = (playerData.HighestRebirth or 0) >= PRESTIGE_UNLOCK_REQUIREMENTS.minimumRebirth

	return hasReachedRebirth20
end

function PrestigeManager:CheckPrestigeEligibility(playerData)
	local requirements = PRESTIGE_UNLOCK_REQUIREMENTS
	local issues = {}

	-- Check rebirth requirement
	local currentRebirth = playerData.Rebirth or 0
	if currentRebirth < requirements.minimumRebirth then
		table.insert(issues, string.format("Must reach Rebirth %d (currently Rebirth %d)",
			requirements.minimumRebirth, currentRebirth))
	end

	-- Check lifetime DP requirement
	local lifetimeDP = playerData.LifetimeStats and playerData.LifetimeStats.TotalDPEarned or 0
	if lifetimeDP < requirements.lifetimeDP then
		table.insert(issues, string.format("Must earn %s lifetime DP (currently %s)",
			self:FormatNumber(requirements.lifetimeDP),
			self:FormatNumber(lifetimeDP)))
	end

	-- Check legendary pet requirement
	local legendaryPetCount = self:CountLegendaryPets(playerData)
	if legendaryPetCount < requirements.legendaryPetsRequired then
		table.insert(issues, string.format("Must own at least %d Legendary pet(s) (currently %d)",
			requirements.legendaryPetsRequired, legendaryPetCount))
	end

	-- Return eligibility status
	if #issues > 0 then
		return false, table.concat(issues, "\n")
	end

	return true, "Eligible for Prestige!"
end

function PrestigeManager:CountLegendaryPets(playerData)
	if not playerData.Pets then
		return 0
	end

	local count = 0
	for _, pet in ipairs(playerData.Pets) do
		if pet.Rarity == "Legendary" or pet.Rarity == "Mythic" then
			count = count + 1
		end
	end

	return count
end

-- ========================================
-- PRESTIGE EXECUTION
-- ========================================

function PrestigeManager:PerformPrestige(playerData)
	-- First-time prestige check
	local isFirstPrestige = (playerData.PrestigeRank or 0) == 0

	-- Validate eligibility (only for first prestige)
	if isFirstPrestige then
		local eligible, message = self:CheckPrestigeEligibility(playerData)
		if not eligible then
			return false, "Not eligible for Prestige: " .. message
		end
	else
		-- For subsequent prestiges, just check if at Rebirth 20+
		if (playerData.Rebirth or 0) < 20 then
			return false, "Must reach Rebirth 20 to Prestige again"
		end
	end

	-- Store current stats before reset
	local prePrestigeStats = self:CapturePrePrestigeStats(playerData)

	-- Reset progress
	self:ResetProgressForPrestige(playerData)

	-- Update prestige tracking
	if not playerData.PrestigeStats then
		playerData.PrestigeStats = {
			TotalPrestiges = 0,
			RebirthsSinceFirstPrestige = 0,
			LastPrestigeTimestamp = 0,
		}
	end

	playerData.PrestigeStats.TotalPrestiges = playerData.PrestigeStats.TotalPrestiges + 1
	playerData.PrestigeStats.LastPrestigeTimestamp = os.time()

	-- Check for rank advancement
	local newRank = self:CalculatePrestigeRank(playerData)
	local rankChanged = newRank > (playerData.PrestigeRank or 0)
	playerData.PrestigeRank = newRank

	-- Grant rewards for new rank
	local rewards = {}
	if rankChanged then
		rewards = self:GrantPrestigeRankRewards(playerData, newRank)
	end

	-- Log prestige
	self:LogPrestige(playerData, prePrestigeStats, newRank, rankChanged)

	-- Clear cache
	if playerData.UserId then
		self.prestigeCache[playerData.UserId] = nil
	end

	return true, "Prestige complete!", {
		prestigeCount = playerData.PrestigeStats.TotalPrestiges,
		currentRank = newRank,
		rankChanged = rankChanged,
		rewards = rewards,
		bonuses = self:GetPrestigeBonuses(playerData),
	}
end

-- ========================================
-- PROGRESS RESET
-- ========================================

function PrestigeManager:ResetProgressForPrestige(playerData)
	-- Reset level and XP
	playerData.Level = 1
	playerData.XP = 0

	-- Reset DP
	playerData.DP = 0

	-- Reset rebirth
	playerData.Rebirth = 0

	-- Reset zone progress
	playerData.CurrentZone = 1
	playerData.UnlockedZones = { 1 }

	-- Reset upgrades
	playerData.Upgrades = {}

	-- Note: Tools, Pets, Prestige rank, and Lifetime stats are KEPT
	print(string.format("[PRESTIGE] Reset progress for player %s", tostring(playerData.UserId or "Unknown")))
end

function PrestigeManager:CapturePrePrestigeStats(playerData)
	return {
		Level = playerData.Level,
		Rebirth = playerData.Rebirth,
		DP = playerData.DP,
		TotalUpgradeLevels = self:CountTotalUpgradeLevels(playerData),
	}
end

function PrestigeManager:CountTotalUpgradeLevels(playerData)
	local total = 0
	if playerData.Upgrades then
		for _, level in pairs(playerData.Upgrades) do
			total = total + level
		end
	end
	return total
end

-- ========================================
-- PRESTIGE RANK CALCULATION
-- ========================================

function PrestigeManager:CalculatePrestigeRank(playerData)
	local currentRank = playerData.PrestigeRank or 0

	-- Check each rank's requirements
	for _, rankData in ipairs(PRESTIGE_RANKS) do
		if rankData.rank > currentRank then
			if self:MeetsRankRequirement(playerData, rankData) then
				currentRank = rankData.rank
			else
				-- Stop checking once we find a requirement we don't meet
				break
			end
		end
	end

	return currentRank
end

function PrestigeManager:MeetsRankRequirement(playerData, rankData)
	local req = rankData.requirement

	if req.type == "prestige_once" then
		-- Rank 1: Just prestige once
		return (playerData.PrestigeStats and playerData.PrestigeStats.TotalPrestiges or 0) >= 1

	elseif req.type == "rebirths_post_prestige" then
		-- Ranks 2-6: Complete X rebirths after first prestige
		local rebirthsSincePrestige = playerData.PrestigeStats and playerData.PrestigeStats.RebirthsSinceFirstPrestige or 0
		return rebirthsSincePrestige >= req.count
	end

	return false
end

function PrestigeManager:GetNextRank(playerData)
	local currentRank = playerData.PrestigeRank or 0

	-- Find next rank
	for _, rankData in ipairs(PRESTIGE_RANKS) do
		if rankData.rank > currentRank then
			return rankData
		end
	end

	return nil -- Already at max rank
end

-- ========================================
-- PRESTIGE BONUSES
-- ========================================

function PrestigeManager:GetPrestigeBonuses(playerData)
	local bonuses = {
		damageMultiplier = 1.0,
		dpMultiplier = 1.0,
		petDamageMultiplier = 1.0,
		allStatsMultiplier = 1.0,
	}

	local currentRank = playerData.PrestigeRank or 0

	-- Apply bonuses from all achieved ranks
	for _, rankData in ipairs(PRESTIGE_RANKS) do
		if rankData.rank <= currentRank then
			if rankData.bonuses.damageMultiplier then
				bonuses.damageMultiplier = bonuses.damageMultiplier * rankData.bonuses.damageMultiplier
			end
			if rankData.bonuses.dpMultiplier then
				bonuses.dpMultiplier = bonuses.dpMultiplier * rankData.bonuses.dpMultiplier
			end
			if rankData.bonuses.petDamageMultiplier then
				bonuses.petDamageMultiplier = bonuses.petDamageMultiplier * rankData.bonuses.petDamageMultiplier
			end
			if rankData.bonuses.allStatsMultiplier then
				bonuses.allStatsMultiplier = bonuses.allStatsMultiplier * rankData.bonuses.allStatsMultiplier
			end
		end
	end

	return bonuses
end

function PrestigeManager:GrantPrestigeRankRewards(playerData, rank)
	local rankData = PRESTIGE_RANKS[rank]
	if not rankData then
		return {}
	end

	local rewards = {}

	-- Grant title
	if rankData.rewards.title then
		if not playerData.Titles then
			playerData.Titles = {}
		end
		table.insert(playerData.Titles, rankData.rewards.title)
		playerData.CurrentTitle = rankData.rewards.title
		table.insert(rewards, { type = "Title", value = rankData.rewards.title })
	end

	-- Grant pet
	if rankData.rewards.pet then
		if not playerData.Pets then
			playerData.Pets = {}
		end
		-- Add the special pet (e.g., Golden Eraser)
		table.insert(rewards, { type = "Pet", value = rankData.rewards.pet })
	end

	-- Grant zone unlock
	if rankData.rewards.zoneUnlock then
		table.insert(rewards, { type = "ZoneUnlock", value = rankData.rewards.zoneUnlock })
	end

	-- Grant name effect
	if rankData.rewards.nameEffect then
		playerData.NameEffect = rankData.rewards.nameEffect
		table.insert(rewards, { type = "NameEffect", value = rankData.rewards.nameEffect })
	end

	-- Grant aura
	if rankData.rewards.aura then
		if not playerData.Auras then
			playerData.Auras = {}
		end
		table.insert(playerData.Auras, rankData.rewards.aura)
		playerData.CurrentAura = rankData.rewards.aura
		table.insert(rewards, { type = "Aura", value = rankData.rewards.aura })
	end

	return rewards
end

-- ========================================
-- LIFETIME STATS TRACKING
-- ========================================

function PrestigeManager:InitializeLifetimeStats(playerData)
	if not playerData.LifetimeStats then
		playerData.LifetimeStats = {
			TotalDPEarned = 0,
			TotalHomeworkDestroyed = 0,
			TotalBossesDefeated = 0,
			TotalDamageDealt = 0,
			TotalClickCount = 0,
			TotalPlayTime = 0,
			HighestDamageHit = 0,
			TotalRebirths = 0,
			TotalPrestiges = 0,
		}
	end
end

function PrestigeManager:UpdateLifetimeStats(playerData, statName, amount)
	self:InitializeLifetimeStats(playerData)

	if statName == "HighestDamageHit" then
		-- For "highest" stats, only update if new value is higher
		if amount > playerData.LifetimeStats[statName] then
			playerData.LifetimeStats[statName] = amount
		end
	else
		-- For cumulative stats, add to existing value
		playerData.LifetimeStats[statName] = (playerData.LifetimeStats[statName] or 0) + amount
	end
end

function PrestigeManager:GetLifetimeStats(playerData)
	self:InitializeLifetimeStats(playerData)
	return playerData.LifetimeStats
end

-- ========================================
-- POST-PRESTIGE REBIRTH TRACKING
-- ========================================

function PrestigeManager:TrackRebirthAfterPrestige(playerData)
	-- Track rebirths completed after first prestige (for rank progression)
	if not playerData.PrestigeStats then
		playerData.PrestigeStats = {
			TotalPrestiges = 0,
			RebirthsSinceFirstPrestige = 0,
			LastPrestigeTimestamp = 0,
		}
	end

	-- Only track if player has prestiged at least once
	if (playerData.PrestigeStats.TotalPrestiges or 0) > 0 then
		playerData.PrestigeStats.RebirthsSinceFirstPrestige = (playerData.PrestigeStats.RebirthsSinceFirstPrestige or 0) + 1

		-- Check if this rebirth advances prestige rank
		local oldRank = playerData.PrestigeRank or 0
		local newRank = self:CalculatePrestigeRank(playerData)

		if newRank > oldRank then
			playerData.PrestigeRank = newRank
			local rewards = self:GrantPrestigeRankRewards(playerData, newRank)

			print(string.format("[PRESTIGE] Player %s advanced to Prestige Rank %d: %s",
				tostring(playerData.UserId or "Unknown"),
				newRank,
				PRESTIGE_RANKS[newRank].name
			))

			return true, newRank, rewards
		end
	end

	return false, nil, {}
end

-- ========================================
-- PRESTIGE INFO
-- ========================================

function PrestigeManager:GetPrestigeInfo(playerData)
	local currentRank = playerData.PrestigeRank or 0
	local nextRankData = self:GetNextRank(playerData)

	local info = {
		isUnlocked = self:IsPrestigeUnlocked(playerData),
		isEligible = false,
		eligibilityMessage = "",
		currentRank = currentRank,
		currentRankName = currentRank > 0 and PRESTIGE_RANKS[currentRank].name or "None",
		bonuses = self:GetPrestigeBonuses(playerData),
		stats = playerData.PrestigeStats,
		nextRank = nil,
	}

	-- Check eligibility
	local eligible, message = self:CheckPrestigeEligibility(playerData)
	info.isEligible = eligible
	info.eligibilityMessage = message

	-- Next rank info
	if nextRankData then
		info.nextRank = {
			rank = nextRankData.rank,
			name = nextRankData.name,
			requirement = nextRankData.requirement.description,
			progress = self:GetRankProgress(playerData, nextRankData),
			rewards = nextRankData.rewards,
		}
	end

	return info
end

function PrestigeManager:GetRankProgress(playerData, rankData)
	local req = rankData.requirement

	if req.type == "prestige_once" then
		return {
			current = (playerData.PrestigeStats and playerData.PrestigeStats.TotalPrestiges or 0) >= 1 and 1 or 0,
			required = 1,
			percentage = (playerData.PrestigeStats and playerData.PrestigeStats.TotalPrestiges or 0) >= 1 and 100 or 0,
		}
	elseif req.type == "rebirths_post_prestige" then
		local current = playerData.PrestigeStats and playerData.PrestigeStats.RebirthsSinceFirstPrestige or 0
		return {
			current = current,
			required = req.count,
			percentage = math.floor((current / req.count) * 100),
		}
	end

	return { current = 0, required = 1, percentage = 0 }
end

-- ========================================
-- ANTI-CHEAT VALIDATION
-- ========================================

function PrestigeManager:ValidatePrestigeIntegrity(playerData)
	local issues = {}

	-- Validate prestige rank
	local currentRank = playerData.PrestigeRank or 0
	if currentRank < 0 or currentRank > #PRESTIGE_RANKS then
		table.insert(issues, string.format("Invalid prestige rank: %d", currentRank))
		playerData.PrestigeRank = math.clamp(currentRank, 0, #PRESTIGE_RANKS)
	end

	-- Validate prestige rank requirements
	if currentRank > 0 then
		for rank = 1, currentRank do
			local rankData = PRESTIGE_RANKS[rank]
			if not self:MeetsRankRequirement(playerData, rankData) then
				table.insert(issues, string.format("Does not meet requirements for Rank %d: %s", rank, rankData.name))
				-- Reset to highest valid rank
				playerData.PrestigeRank = rank - 1
				break
			end
		end
	end

	-- Validate lifetime stats (can't be negative)
	if playerData.LifetimeStats then
		for statName, value in pairs(playerData.LifetimeStats) do
			if value < 0 then
				table.insert(issues, string.format("Negative lifetime stat: %s = %d", statName, value))
				playerData.LifetimeStats[statName] = 0
			end
		end
	end

	if #issues > 0 then
		warn(string.format("[ANTI-CHEAT] Found %d prestige integrity issues for player %s",
			#issues,
			tostring(playerData.UserId or "Unknown")
		))
		return false, table.concat(issues, "; ")
	end

	return true, "Prestige data valid"
end

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

function PrestigeManager:FormatNumber(number)
	-- Format large numbers with suffixes (K, M, B, T)
	local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
	local suffixIndex = 1

	while number >= 1000 and suffixIndex < #suffixes do
		number = number / 1000
		suffixIndex = suffixIndex + 1
	end

	if suffixIndex == 1 then
		return tostring(math.floor(number))
	else
		return string.format("%.2f%s", number, suffixes[suffixIndex])
	end
end

function PrestigeManager:LogPrestige(playerData, prePrestigeStats, newRank, rankChanged)
	local logMessage = string.format(
		"[PRESTIGE] Player %s completed Prestige #%d | Rank: %d (%s) | Pre-Prestige: Level %d, Rebirth %d, %s DP",
		tostring(playerData.UserId or "Unknown"),
		playerData.PrestigeStats.TotalPrestiges,
		newRank,
		rankChanged and "RANK UP!" or "Same Rank",
		prePrestigeStats.Level,
		prePrestigeStats.Rebirth,
		self:FormatNumber(prePrestigeStats.DP)
	)
	print(logMessage)
end

function PrestigeManager:GetAllPrestigeRanks()
	local ranks = {}
	for _, rankData in ipairs(PRESTIGE_RANKS) do
		table.insert(ranks, {
			rank = rankData.rank,
			name = rankData.name,
			requirement = rankData.requirement.description,
			bonuses = rankData.bonuses,
			rewards = rankData.rewards,
		})
	end
	return ranks
end

return PrestigeManager
