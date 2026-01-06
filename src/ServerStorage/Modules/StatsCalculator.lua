--[[
	StatsCalculator.lua
	Calculates all player stats including damage, papers per second, multipliers, and costs
	Handles all stat calculations with proper formulas from GameDesign.md
]]

local StatsCalculator = {}

-- ========================================
-- CONFIGURATION CONSTANTS
-- ========================================

-- Upgrade cost formulas (base * multiplier^level)
local UPGRADE_COSTS = {
	-- Damage Upgrades
	SharperTools = { base = 100, multiplier = 1.5, maxLevel = 50 },
	StrongerArms = { base = 200, multiplier = 1.5, maxLevel = 50 },
	CriticalChance = { base = 500, multiplier = 2, maxLevel = 25 },
	CriticalDamage = { base = 750, multiplier = 2, maxLevel = 25 },
	PaperWeakness = { base = 1000, multiplier = 1.8, maxLevel = 20 },

	-- Speed Upgrades
	QuickHands = { base = 300, multiplier = 1.6, maxLevel = 30 },
	AutoClickSpeed = { base = 5000, multiplier = 2, maxLevel = 20 },
	MovementSpeed = { base = 400, multiplier = 1.5, maxLevel = 15 },

	-- Economy Upgrades
	DPBonus = { base = 150, multiplier = 1.4, maxLevel = 50 },
	LuckyDrops = { base = 2000, multiplier = 1.8, maxLevel = 20 },
	EggLuck = { base = 10000, multiplier = 2, maxLevel = 15 },
}

-- Level rewards and requirements
local LEVEL_XP_REQUIREMENTS = {
	{ range = {1, 10}, perLevel = 100 },
	{ range = {11, 25}, perLevel = 500 },
	{ range = {26, 50}, perLevel = 2000 },
	{ range = {51, 75}, perLevel = 10000 },
	{ range = {76, 100}, perLevel = 50000 },
}

-- Tool rarity multipliers
local TOOL_RARITY_MULTIPLIERS = {
	Common = 1.0,
	Uncommon = 1.25,
	Rare = 1.5,
	Epic = 2.0,
	Legendary = 3.0,
	Mythic = 6.0,
	SECRET = 11.0,
}

-- Rebirth bonuses (multipliers at each rebirth level)
local REBIRTH_BONUSES = {
	[1] = { dp = 1.5, damage = 1.25 },
	[2] = { dp = 2.0, damage = 1.5 },
	[3] = { dp = 2.75, damage = 1.75 },
	[4] = { dp = 3.5, damage = 2.0 },
	[5] = { dp = 4.5, damage = 2.5 },
	[10] = { dp = 10, damage = 5 },
	[15] = { dp = 20, damage = 8 },
	[20] = { dp = 35, damage = 12 },
	[25] = { dp = 50, damage = 15 },
}

-- Prestige bonuses (permanent multipliers)
local PRESTIGE_BONUSES = {
	[1] = { name = "Homework Hater", damageBonus = 2.0 }, -- +100%
	[2] = { name = "Assignment Annihilator", dpBonus = 3.0 }, -- +200%
	[3] = { name = "Test Terminator", petDamageBonus = 1.5 }, -- +50%
	[4] = { name = "Scholar Slayer", petDamageBonus = 1.5 },
	[5] = { name = "Education Eliminator", allStats = 1.5 },
	[6] = { name = "HOMEWORK DESTROYER", allStats = 10.0 }, -- MAX rank
}

-- ========================================
-- UPGRADE COST CALCULATIONS
-- ========================================

function StatsCalculator.CalculateUpgradeCost(upgradeName, currentLevel)
	local upgradeData = UPGRADE_COSTS[upgradeName]
	if not upgradeData then
		warn("Unknown upgrade: " .. tostring(upgradeName))
		return nil
	end

	-- Check max level
	if currentLevel >= upgradeData.maxLevel then
		return nil -- Max level reached
	end

	-- Calculate cost: base * (multiplier ^ currentLevel)
	local cost = math.floor(upgradeData.base * math.pow(upgradeData.multiplier, currentLevel))
	return cost
end

function StatsCalculator.GetUpgradeMaxLevel(upgradeName)
	local upgradeData = UPGRADE_COSTS[upgradeName]
	return upgradeData and upgradeData.maxLevel or 0
end

-- ========================================
-- XP AND LEVEL CALCULATIONS
-- ========================================

function StatsCalculator.GetXPRequiredForLevel(level)
	for _, tier in ipairs(LEVEL_XP_REQUIREMENTS) do
		if level >= tier.range[1] and level <= tier.range[2] then
			return tier.perLevel
		end
	end
	return 50000 -- Default for levels beyond 100
end

function StatsCalculator.GetTotalXPForLevel(targetLevel)
	local totalXP = 0
	for level = 1, targetLevel - 1 do
		totalXP = totalXP + StatsCalculator.GetXPRequiredForLevel(level)
	end
	return totalXP
end

function StatsCalculator.GetLevelFromXP(currentXP)
	local level = 1
	local xpRemaining = currentXP

	while xpRemaining >= StatsCalculator.GetXPRequiredForLevel(level) do
		xpRemaining = xpRemaining - StatsCalculator.GetXPRequiredForLevel(level)
		level = level + 1
		if level > 100 then break end
	end

	return level, xpRemaining
end

-- ========================================
-- DAMAGE CALCULATIONS
-- ========================================

function StatsCalculator.CalculateBaseDamage(playerData, toolData)
	-- Start with tool base damage
	local baseDamage = toolData.BaseDamage or 1

	-- Apply tool rarity multiplier
	local rarityMultiplier = TOOL_RARITY_MULTIPLIERS[toolData.Rarity] or 1.0
	baseDamage = baseDamage * rarityMultiplier

	-- Apply tool upgrade bonus (+15% per upgrade level)
	local toolUpgradeLevel = toolData.UpgradeLevel or 0
	local toolUpgradeBonus = 1 + (toolUpgradeLevel * 0.15)
	baseDamage = baseDamage * toolUpgradeBonus

	return baseDamage
end

function StatsCalculator.CalculateDamageMultipliers(playerData, petData)
	local multipliers = {
		level = 1.0,
		upgrades = 1.0,
		pets = 1.0,
		rebirth = 1.0,
		prestige = 1.0,
		total = 1.0,
	}

	-- Level bonus: +5% base damage per level
	multipliers.level = 1 + (playerData.Level * 0.05)

	-- Upgrade bonuses
	local upgrades = playerData.Upgrades or {}

	-- Sharper Tools: +2 base damage per level (additive)
	local sharperBonus = (upgrades.SharperTools or 0) * 2

	-- Stronger Arms: +5% click damage per level
	local strongerArmsBonus = 1 + ((upgrades.StrongerArms or 0) * 0.05)

	-- Paper Weakness: +10% damage to paper types per level
	local paperWeaknessBonus = 1 + ((upgrades.PaperWeakness or 0) * 0.10)

	multipliers.upgrades = strongerArmsBonus * paperWeaknessBonus

	-- Pet damage bonuses
	if petData and #petData > 0 then
		local petBonus = 0
		for _, pet in ipairs(petData) do
			if pet.Equipped then
				petBonus = petBonus + (pet.DamageBonus or 0)
			end
		end
		multipliers.pets = 1 + petBonus
	end

	-- Rebirth multiplier
	local rebirthLevel = playerData.Rebirth or 0
	multipliers.rebirth = StatsCalculator.GetRebirthDamageMultiplier(rebirthLevel)

	-- Prestige multiplier
	local prestigeRank = playerData.PrestigeRank or 0
	multipliers.prestige = StatsCalculator.GetPrestigeDamageMultiplier(prestigeRank)

	-- Calculate total multiplier
	multipliers.total = multipliers.level * multipliers.upgrades * multipliers.pets * multipliers.rebirth * multipliers.prestige

	return multipliers, sharperBonus
end

function StatsCalculator.CalculateFinalDamage(playerData, toolData, petData, isCritical, targetType)
	-- Get base damage from tool
	local baseDamage = StatsCalculator.CalculateBaseDamage(playerData, toolData)

	-- Get all multipliers
	local multipliers, sharperBonus = StatsCalculator.CalculateDamageMultipliers(playerData, petData)

	-- Add Sharper Tools bonus (additive)
	baseDamage = baseDamage + sharperBonus

	-- Apply all multipliers
	local finalDamage = baseDamage * multipliers.total

	-- Apply critical hit if applicable
	if isCritical then
		local critMultiplier = StatsCalculator.GetCriticalMultiplier(playerData)
		finalDamage = finalDamage * critMultiplier
	end

	-- Apply zone/type bonuses if applicable
	if targetType and toolData.SpecialBonus then
		if toolData.SpecialBonus[targetType] then
			finalDamage = finalDamage * (1 + toolData.SpecialBonus[targetType])
		end
	end

	return math.floor(finalDamage)
end

-- ========================================
-- CRITICAL HIT CALCULATIONS
-- ========================================

function StatsCalculator.GetCriticalChance(playerData, toolData)
	local baseCrit = 0.05 -- 5% base chance

	-- Add critical chance upgrade
	local upgrades = playerData.Upgrades or {}
	local critUpgrade = (upgrades.CriticalChance or 0) * 0.01 -- +1% per level

	-- Add tool critical chance
	local toolCrit = toolData.CritChance or 0

	-- Calculate total (max 95%)
	local totalCrit = math.min(baseCrit + critUpgrade + toolCrit, 0.95)

	return totalCrit
end

function StatsCalculator.GetCriticalMultiplier(playerData)
	local baseMultiplier = 2.0 -- Base 2x damage

	-- Add critical damage upgrade
	local upgrades = playerData.Upgrades or {}
	local critDamageBonus = (upgrades.CriticalDamage or 0) * 0.10 -- +10% per level

	return baseMultiplier + critDamageBonus
end

-- ========================================
-- DP (DESTRUCTION POINTS) CALCULATIONS
-- ========================================

function StatsCalculator.CalculateDPEarned(baseDP, playerData)
	local totalDP = baseDP

	-- DP Bonus upgrade: +3% per level
	local upgrades = playerData.Upgrades or {}
	local dpUpgradeBonus = 1 + ((upgrades.DPBonus or 0) * 0.03)
	totalDP = totalDP * dpUpgradeBonus

	-- Rebirth DP multiplier
	local rebirthLevel = playerData.Rebirth or 0
	local rebirthMultiplier = StatsCalculator.GetRebirthDPMultiplier(rebirthLevel)
	totalDP = totalDP * rebirthMultiplier

	-- Prestige DP multiplier
	local prestigeRank = playerData.PrestigeRank or 0
	local prestigeMultiplier = StatsCalculator.GetPrestigeDPMultiplier(prestigeRank)
	totalDP = totalDP * prestigeMultiplier

	-- Pet DP bonuses
	-- (Would need petData parameter to calculate this)

	return math.floor(totalDP)
end

-- ========================================
-- AUTO-CLICK CALCULATIONS
-- ========================================

function StatsCalculator.CalculateAutoClickRate(playerData)
	local baseRate = 0 -- Unlocked at Rebirth 1

	-- Check if auto-click is unlocked
	if playerData.Rebirth < 1 then
		return 0
	end

	baseRate = 0.5 -- 1 click per 2 seconds (0.5 clicks/sec)

	-- Auto-Click Speed upgrade: +0.1 clicks/sec per level
	local upgrades = playerData.Upgrades or {}
	local autoSpeedBonus = (upgrades.AutoClickSpeed or 0) * 0.1

	-- Max 5 clicks per second
	local totalRate = math.min(baseRate + autoSpeedBonus, 5.0)

	return totalRate
end

function StatsCalculator.CalculateAutoClickDamage(playerData, toolData, petData)
	-- Auto-click deals 50% of manual click damage (or 100% with Super Auto upgrade)
	local baseDamage = StatsCalculator.CalculateFinalDamage(playerData, toolData, petData, false, nil)

	-- Check for Super Auto rebirth shop upgrade
	local autoMultiplier = 0.5
	if playerData.RebirthShop and playerData.RebirthShop.SuperAuto then
		autoMultiplier = 1.0
	end

	return math.floor(baseDamage * autoMultiplier)
end

-- ========================================
-- REBIRTH CALCULATIONS
-- ========================================

function StatsCalculator.GetRebirthDamageMultiplier(rebirthLevel)
	if rebirthLevel == 0 then return 1.0 end

	-- Get bonus for exact rebirth level or interpolate
	local bonus = REBIRTH_BONUSES[rebirthLevel]
	if bonus then
		return bonus.damage
	end

	-- Find closest lower and higher bonuses for interpolation
	local lowerLevel, lowerBonus = 0, 1.0
	local higherLevel, higherBonus = 25, 15.0

	for level, data in pairs(REBIRTH_BONUSES) do
		if level <= rebirthLevel and level > lowerLevel then
			lowerLevel = level
			lowerBonus = data.damage
		end
		if level > rebirthLevel and level < higherLevel then
			higherLevel = level
			higherBonus = data.damage
		end
	end

	-- Linear interpolation
	if higherLevel > lowerLevel then
		local ratio = (rebirthLevel - lowerLevel) / (higherLevel - lowerLevel)
		return lowerBonus + (higherBonus - lowerBonus) * ratio
	end

	return lowerBonus
end

function StatsCalculator.GetRebirthDPMultiplier(rebirthLevel)
	if rebirthLevel == 0 then return 1.0 end

	local bonus = REBIRTH_BONUSES[rebirthLevel]
	if bonus then
		return bonus.dp
	end

	-- Find closest lower and higher bonuses for interpolation
	local lowerLevel, lowerBonus = 0, 1.0
	local higherLevel, higherBonus = 25, 50.0

	for level, data in pairs(REBIRTH_BONUSES) do
		if level <= rebirthLevel and level > lowerLevel then
			lowerLevel = level
			lowerBonus = data.dp
		end
		if level > rebirthLevel and level < higherLevel then
			higherLevel = level
			higherBonus = data.dp
		end
	end

	-- Linear interpolation
	if higherLevel > lowerLevel then
		local ratio = (rebirthLevel - lowerLevel) / (higherLevel - lowerLevel)
		return lowerBonus + (higherBonus - lowerBonus) * ratio
	end

	return lowerBonus
end

-- ========================================
-- PRESTIGE CALCULATIONS
-- ========================================

function StatsCalculator.GetPrestigeDamageMultiplier(prestigeRank)
	if prestigeRank == 0 then return 1.0 end

	local multiplier = 1.0

	-- Apply bonuses for all achieved prestige ranks
	for rank = 1, prestigeRank do
		local bonus = PRESTIGE_BONUSES[rank]
		if bonus then
			if bonus.damageBonus then
				multiplier = multiplier * bonus.damageBonus
			end
			if bonus.allStats then
				multiplier = multiplier * bonus.allStats
			end
		end
	end

	return multiplier
end

function StatsCalculator.GetPrestigeDPMultiplier(prestigeRank)
	if prestigeRank == 0 then return 1.0 end

	local multiplier = 1.0

	-- Apply bonuses for all achieved prestige ranks
	for rank = 1, prestigeRank do
		local bonus = PRESTIGE_BONUSES[rank]
		if bonus then
			if bonus.dpBonus then
				multiplier = multiplier * bonus.dpBonus
			end
			if bonus.allStats then
				multiplier = multiplier * bonus.allStats
			end
		end
	end

	return multiplier
end

function StatsCalculator.GetPrestigePetMultiplier(prestigeRank)
	if prestigeRank == 0 then return 1.0 end

	local multiplier = 1.0

	for rank = 1, prestigeRank do
		local bonus = PRESTIGE_BONUSES[rank]
		if bonus and bonus.petDamageBonus then
			multiplier = multiplier * bonus.petDamageBonus
		end
	end

	return multiplier
end

-- ========================================
-- SPEED CALCULATIONS
-- ========================================

function StatsCalculator.CalculateClickCooldown(playerData)
	local baseCooldown = 0.2 -- 0.2 seconds (5 clicks per second max)

	-- Quick Hands upgrade: -2% click cooldown per level
	local upgrades = playerData.Upgrades or {}
	local cooldownReduction = (upgrades.QuickHands or 0) * 0.02
	cooldownReduction = math.min(cooldownReduction, 0.60) -- Max 60% reduction

	local finalCooldown = baseCooldown * (1 - cooldownReduction)
	return math.max(finalCooldown, 0.05) -- Minimum 0.05 seconds
end

function StatsCalculator.CalculateMovementSpeed(playerData)
	local baseSpeed = 16 -- Roblox default WalkSpeed

	-- Movement Speed upgrade: +3% per level
	local upgrades = playerData.Upgrades or {}
	local speedBonus = 1 + ((upgrades.MovementSpeed or 0) * 0.03)

	return baseSpeed * speedBonus
end

-- ========================================
-- PAPERS PER SECOND (PPS) CALCULATION
-- ========================================

function StatsCalculator.CalculatePapersPerSecond(playerData, toolData, petData)
	local pps = 0

	-- Auto-click contribution
	local autoClickRate = StatsCalculator.CalculateAutoClickRate(playerData)
	local autoClickDamage = StatsCalculator.CalculateAutoClickDamage(playerData, toolData, petData)
	pps = pps + (autoClickRate * autoClickDamage)

	-- Pet auto-attack contribution
	if petData then
		for _, pet in ipairs(petData) do
			if pet.Equipped and pet.AutoAttackDamage then
				local attackRate = 1 / (pet.AutoAttackCooldown or 3) -- attacks per second
				pps = pps + (attackRate * pet.AutoAttackDamage)
			end
		end
	end

	return math.floor(pps)
end

-- ========================================
-- SUMMARY STATS
-- ========================================

function StatsCalculator.GetPlayerStats(playerData, toolData, petData)
	return {
		-- Basic Stats
		Level = playerData.Level,
		XP = playerData.XP,
		XPRequired = StatsCalculator.GetXPRequiredForLevel(playerData.Level),
		DP = playerData.DP,

		-- Damage Stats
		BaseDamage = StatsCalculator.CalculateBaseDamage(playerData, toolData),
		FinalDamage = StatsCalculator.CalculateFinalDamage(playerData, toolData, petData, false, nil),
		CritChance = StatsCalculator.GetCriticalChance(playerData, toolData),
		CritMultiplier = StatsCalculator.GetCriticalMultiplier(playerData),
		CritDamage = StatsCalculator.CalculateFinalDamage(playerData, toolData, petData, true, nil),

		-- Speed Stats
		ClickCooldown = StatsCalculator.CalculateClickCooldown(playerData),
		MovementSpeed = StatsCalculator.CalculateMovementSpeed(playerData),
		AutoClickRate = StatsCalculator.CalculateAutoClickRate(playerData),

		-- Production Stats
		PapersPerSecond = StatsCalculator.CalculatePapersPerSecond(playerData, toolData, petData),

		-- Multipliers
		RebirthDamageMultiplier = StatsCalculator.GetRebirthDamageMultiplier(playerData.Rebirth or 0),
		RebirthDPMultiplier = StatsCalculator.GetRebirthDPMultiplier(playerData.Rebirth or 0),
		PrestigeDamageMultiplier = StatsCalculator.GetPrestigeDamageMultiplier(playerData.PrestigeRank or 0),
		PrestigeDPMultiplier = StatsCalculator.GetPrestigeDPMultiplier(playerData.PrestigeRank or 0),
	}
end

return StatsCalculator
