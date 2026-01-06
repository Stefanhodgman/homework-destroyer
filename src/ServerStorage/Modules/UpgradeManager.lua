--[[
	UpgradeManager.lua
	Server-side upgrade logic for Homework Destroyer
	Handles upgrade purchases, validation, and stat bonuses
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local UpgradeManager = {}
UpgradeManager.__index = UpgradeManager

-- Import StatsCalculator
local StatsCalculator = require(ServerStorage.Modules.StatsCalculator)

-- ========================================
-- UPGRADE DEFINITIONS
-- ========================================

local UPGRADE_DEFINITIONS = {
	-- Damage Upgrades
	SharperTools = {
		name = "Sharper Tools",
		description = "+2 base damage per level",
		category = "Damage",
		maxLevel = 50,
		costFormula = { base = 100, multiplier = 1.5 },
		effectPerLevel = 2,
		effectType = "additive_damage",
	},
	StrongerArms = {
		name = "Stronger Arms",
		description = "+5% click damage per level",
		category = "Damage",
		maxLevel = 50,
		costFormula = { base = 200, multiplier = 1.5 },
		effectPerLevel = 0.05,
		effectType = "multiplicative_damage",
	},
	CriticalChance = {
		name = "Critical Chance",
		description = "+1% crit chance per level (max 30%)",
		category = "Damage",
		maxLevel = 25,
		costFormula = { base = 500, multiplier = 2 },
		effectPerLevel = 0.01,
		effectType = "crit_chance",
	},
	CriticalDamage = {
		name = "Critical Damage",
		description = "+10% crit multiplier per level",
		category = "Damage",
		maxLevel = 25,
		costFormula = { base = 750, multiplier = 2 },
		effectPerLevel = 0.10,
		effectType = "crit_multiplier",
	},
	PaperWeakness = {
		name = "Paper Weakness",
		description = "+10% damage to paper types per level",
		category = "Damage",
		maxLevel = 20,
		costFormula = { base = 1000, multiplier = 1.8 },
		effectPerLevel = 0.10,
		effectType = "paper_damage",
	},

	-- Speed Upgrades
	QuickHands = {
		name = "Quick Hands",
		description = "-2% click cooldown per level",
		category = "Speed",
		maxLevel = 30,
		costFormula = { base = 300, multiplier = 1.6 },
		effectPerLevel = -0.02,
		effectType = "click_cooldown",
	},
	AutoClickSpeed = {
		name = "Auto-Click Speed",
		description = "+0.1 auto-clicks/sec per level",
		category = "Speed",
		maxLevel = 20,
		costFormula = { base = 5000, multiplier = 2 },
		effectPerLevel = 0.1,
		effectType = "auto_click_rate",
		requiresRebirth = 1, -- Unlocked at Rebirth 1
	},
	MovementSpeed = {
		name = "Movement Speed",
		description = "+3% walk speed per level",
		category = "Speed",
		maxLevel = 15,
		costFormula = { base = 400, multiplier = 1.5 },
		effectPerLevel = 0.03,
		effectType = "movement_speed",
	},

	-- Economy Upgrades
	DPBonus = {
		name = "DP Bonus",
		description = "+3% DP earned per level",
		category = "Economy",
		maxLevel = 50,
		costFormula = { base = 150, multiplier = 1.4 },
		effectPerLevel = 0.03,
		effectType = "dp_multiplier",
	},
	LuckyDrops = {
		name = "Lucky Drops",
		description = "+2% rare drop chance per level",
		category = "Economy",
		maxLevel = 20,
		costFormula = { base = 2000, multiplier = 1.8 },
		effectPerLevel = 0.02,
		effectType = "drop_chance",
	},
	EggLuck = {
		name = "Egg Luck",
		description = "+3% pet rarity luck per level",
		category = "Economy",
		maxLevel = 15,
		costFormula = { base = 10000, multiplier = 2 },
		effectPerLevel = 0.03,
		effectType = "pet_luck",
	},
}

-- ========================================
-- INITIALIZATION
-- ========================================

function UpgradeManager.new()
	local self = setmetatable({}, UpgradeManager)
	self.upgradeCache = {} -- Cache for player upgrade data
	return self
end

-- ========================================
-- DATA VALIDATION
-- ========================================

function UpgradeManager:ValidatePlayerData(playerData)
	if not playerData then
		return false, "Invalid player data"
	end

	if not playerData.DP or playerData.DP < 0 then
		return false, "Invalid DP amount"
	end

	if not playerData.Upgrades then
		playerData.Upgrades = {}
	end

	return true, "Valid"
end

function UpgradeManager:ValidateUpgrade(upgradeName)
	if not UPGRADE_DEFINITIONS[upgradeName] then
		return false, "Unknown upgrade: " .. tostring(upgradeName)
	end

	return true, UPGRADE_DEFINITIONS[upgradeName]
end

-- ========================================
-- UPGRADE COST CALCULATIONS
-- ========================================

function UpgradeManager:GetUpgradeCost(upgradeName, currentLevel)
	local isValid, upgradeData = self:ValidateUpgrade(upgradeName)
	if not isValid then
		return nil
	end

	if currentLevel >= upgradeData.maxLevel then
		return nil -- Max level reached
	end

	-- Use StatsCalculator for cost calculation
	return StatsCalculator.CalculateUpgradeCost(upgradeName, currentLevel)
end

function UpgradeManager:GetUpgradeInfo(upgradeName)
	local isValid, upgradeData = self:ValidateUpgrade(upgradeName)
	if not isValid then
		return nil
	end

	return {
		Name = upgradeData.name,
		Description = upgradeData.description,
		Category = upgradeData.category,
		MaxLevel = upgradeData.maxLevel,
		EffectPerLevel = upgradeData.effectPerLevel,
		EffectType = upgradeData.effectType,
		RequiresRebirth = upgradeData.requiresRebirth or 0,
	}
end

-- ========================================
-- UPGRADE REQUIREMENTS CHECK
-- ========================================

function UpgradeManager:CheckUpgradeRequirements(playerData, upgradeName)
	local isValid, upgradeData = self:ValidateUpgrade(upgradeName)
	if not isValid then
		return false, upgradeData -- upgradeData contains error message
	end

	-- Check rebirth requirement
	if upgradeData.requiresRebirth then
		local playerRebirth = playerData.Rebirth or 0
		if playerRebirth < upgradeData.requiresRebirth then
			return false, string.format("Requires Rebirth %d", upgradeData.requiresRebirth)
		end
	end

	-- Check max level
	local currentLevel = playerData.Upgrades[upgradeName] or 0
	if currentLevel >= upgradeData.maxLevel then
		return false, "Max level reached"
	end

	-- Check DP cost
	local cost = self:GetUpgradeCost(upgradeName, currentLevel)
	if not cost then
		return false, "Cannot calculate cost"
	end

	if playerData.DP < cost then
		return false, string.format("Insufficient DP (need %d, have %d)", cost, playerData.DP)
	end

	return true, "Requirements met", cost
end

-- ========================================
-- UPGRADE PURCHASE
-- ========================================

function UpgradeManager:PurchaseUpgrade(playerData, upgradeName)
	-- Validate player data
	local isValidData, errorMsg = self:ValidatePlayerData(playerData)
	if not isValidData then
		return false, errorMsg
	end

	-- Check requirements
	local canPurchase, message, cost = self:CheckUpgradeRequirements(playerData, upgradeName)
	if not canPurchase then
		return false, message
	end

	-- Get current level
	local currentLevel = playerData.Upgrades[upgradeName] or 0

	-- Double-check DP (anti-cheat)
	if playerData.DP < cost then
		warn(string.format("[ANTI-CHEAT] Player attempted upgrade without sufficient DP: %s", tostring(playerData.UserId)))
		return false, "Insufficient DP"
	end

	-- Deduct cost
	playerData.DP = playerData.DP - cost

	-- Increment upgrade level
	playerData.Upgrades[upgradeName] = currentLevel + 1

	-- Clear cache for this player
	if playerData.UserId then
		self.upgradeCache[playerData.UserId] = nil
	end

	-- Log purchase for analytics
	self:LogUpgradePurchase(playerData, upgradeName, currentLevel + 1, cost)

	return true, "Upgrade purchased", {
		upgradeName = upgradeName,
		newLevel = currentLevel + 1,
		costPaid = cost,
		remainingDP = playerData.DP,
	}
end

function UpgradeManager:LogUpgradePurchase(playerData, upgradeName, newLevel, cost)
	-- Log to console (in production, send to analytics service)
	print(string.format("[UPGRADE] Player %s purchased %s (Level %d) for %d DP",
		tostring(playerData.UserId or "Unknown"),
		upgradeName,
		newLevel,
		cost
	))
end

-- ========================================
-- BATCH UPGRADE (BUY MAX)
-- ========================================

function UpgradeManager:PurchaseMaxUpgrades(playerData, upgradeName, maxPurchases)
	maxPurchases = maxPurchases or 100 -- Default limit

	local purchaseCount = 0
	local totalCost = 0
	local results = {}

	-- Keep buying until we can't afford more or hit max purchases
	for i = 1, maxPurchases do
		local success, message, data = self:PurchaseUpgrade(playerData, upgradeName)

		if success then
			purchaseCount = purchaseCount + 1
			totalCost = totalCost + data.costPaid
			table.insert(results, data)
		else
			-- Stop if we can't buy more
			break
		end
	end

	if purchaseCount > 0 then
		return true, string.format("Purchased %d levels", purchaseCount), {
			purchaseCount = purchaseCount,
			totalCost = totalCost,
			finalLevel = playerData.Upgrades[upgradeName],
			remainingDP = playerData.DP,
		}
	else
		return false, "Could not purchase any upgrades"
	end
end

-- ========================================
-- UPGRADE EFFECT CALCULATION
-- ========================================

function UpgradeManager:CalculateUpgradeEffect(upgradeName, level)
	local isValid, upgradeData = self:ValidateUpgrade(upgradeName)
	if not isValid then
		return 0
	end

	return upgradeData.effectPerLevel * level
end

function UpgradeManager:GetAllUpgradeEffects(playerData)
	local effects = {
		damage = {
			additive = 0,
			multiplicative = 1.0,
		},
		critical = {
			chance = 0,
			multiplier = 0,
		},
		speed = {
			clickCooldownReduction = 0,
			autoClickRate = 0,
			movementSpeedMultiplier = 1.0,
		},
		economy = {
			dpMultiplier = 1.0,
			dropChance = 0,
			petLuck = 0,
		},
	}

	if not playerData.Upgrades then
		return effects
	end

	-- Calculate each upgrade's contribution
	for upgradeName, level in pairs(playerData.Upgrades) do
		local upgradeData = UPGRADE_DEFINITIONS[upgradeName]
		if upgradeData and level > 0 then
			local effect = self:CalculateUpgradeEffect(upgradeName, level)

			-- Apply effect based on type
			if upgradeData.effectType == "additive_damage" then
				effects.damage.additive = effects.damage.additive + effect
			elseif upgradeData.effectType == "multiplicative_damage" then
				effects.damage.multiplicative = effects.damage.multiplicative * (1 + effect)
			elseif upgradeData.effectType == "crit_chance" then
				effects.critical.chance = effects.critical.chance + effect
			elseif upgradeData.effectType == "crit_multiplier" then
				effects.critical.multiplier = effects.critical.multiplier + effect
			elseif upgradeData.effectType == "click_cooldown" then
				effects.speed.clickCooldownReduction = effects.speed.clickCooldownReduction + math.abs(effect)
			elseif upgradeData.effectType == "auto_click_rate" then
				effects.speed.autoClickRate = effects.speed.autoClickRate + effect
			elseif upgradeData.effectType == "movement_speed" then
				effects.speed.movementSpeedMultiplier = effects.speed.movementSpeedMultiplier * (1 + effect)
			elseif upgradeData.effectType == "dp_multiplier" then
				effects.economy.dpMultiplier = effects.economy.dpMultiplier * (1 + effect)
			elseif upgradeData.effectType == "drop_chance" then
				effects.economy.dropChance = effects.economy.dropChance + effect
			elseif upgradeData.effectType == "pet_luck" then
				effects.economy.petLuck = effects.economy.petLuck + effect
			end
		end
	end

	return effects
end

-- ========================================
-- RESET UPGRADES (FOR REBIRTH)
-- ========================================

function UpgradeManager:ResetUpgrades(playerData)
	if not playerData then
		return false, "Invalid player data"
	end

	-- Clear all upgrades
	playerData.Upgrades = {}

	-- Clear cache
	if playerData.UserId then
		self.upgradeCache[playerData.UserId] = nil
	end

	print(string.format("[UPGRADE] Reset all upgrades for player %s", tostring(playerData.UserId or "Unknown")))

	return true, "Upgrades reset"
end

-- ========================================
-- GET ALL AVAILABLE UPGRADES
-- ========================================

function UpgradeManager:GetAllUpgrades(playerData)
	local upgrades = {}

	for upgradeName, upgradeData in pairs(UPGRADE_DEFINITIONS) do
		local currentLevel = playerData.Upgrades[upgradeName] or 0
		local cost = self:GetUpgradeCost(upgradeName, currentLevel)
		local canAfford = cost and playerData.DP >= cost
		local isMaxed = currentLevel >= upgradeData.maxLevel

		-- Check rebirth requirement
		local meetsRequirement = true
		if upgradeData.requiresRebirth then
			meetsRequirement = (playerData.Rebirth or 0) >= upgradeData.requiresRebirth
		end

		table.insert(upgrades, {
			id = upgradeName,
			name = upgradeData.name,
			description = upgradeData.description,
			category = upgradeData.category,
			currentLevel = currentLevel,
			maxLevel = upgradeData.maxLevel,
			cost = cost,
			canAfford = canAfford,
			isMaxed = isMaxed,
			meetsRequirement = meetsRequirement,
			effectPerLevel = upgradeData.effectPerLevel,
			effectType = upgradeData.effectType,
		})
	end

	-- Sort by category, then by cost
	table.sort(upgrades, function(a, b)
		if a.category ~= b.category then
			return a.category < b.category
		end
		return (a.cost or math.huge) < (b.cost or math.huge)
	end)

	return upgrades
end

-- ========================================
-- REFUND UPGRADE (ADMIN/DEBUG)
-- ========================================

function UpgradeManager:RefundUpgrade(playerData, upgradeName, levels)
	levels = levels or 1

	local currentLevel = playerData.Upgrades[upgradeName] or 0
	if currentLevel < levels then
		return false, "Not enough levels to refund"
	end

	-- Calculate refund amount (50% of cost)
	local refundAmount = 0
	for i = 1, levels do
		local levelToRefund = currentLevel - i + 1
		local cost = self:GetUpgradeCost(upgradeName, levelToRefund - 1)
		if cost then
			refundAmount = refundAmount + math.floor(cost * 0.5)
		end
	end

	-- Apply refund
	playerData.Upgrades[upgradeName] = currentLevel - levels
	playerData.DP = playerData.DP + refundAmount

	-- Clear cache
	if playerData.UserId then
		self.upgradeCache[playerData.UserId] = nil
	end

	return true, string.format("Refunded %d levels for %d DP", levels, refundAmount), {
		refundedLevels = levels,
		refundAmount = refundAmount,
		newLevel = playerData.Upgrades[upgradeName],
	}
end

-- ========================================
-- ANTI-CHEAT VALIDATION
-- ========================================

function UpgradeManager:ValidateUpgradeIntegrity(playerData)
	local issues = {}

	if not playerData.Upgrades then
		return true, "No upgrades to validate"
	end

	-- Check each upgrade
	for upgradeName, level in pairs(playerData.Upgrades) do
		local upgradeData = UPGRADE_DEFINITIONS[upgradeName]

		-- Check if upgrade exists
		if not upgradeData then
			table.insert(issues, string.format("Unknown upgrade: %s", upgradeName))
			playerData.Upgrades[upgradeName] = nil
			continue
		end

		-- Check level bounds
		if level < 0 or level > upgradeData.maxLevel then
			table.insert(issues, string.format("%s has invalid level: %d (max: %d)", upgradeName, level, upgradeData.maxLevel))
			playerData.Upgrades[upgradeName] = math.clamp(level, 0, upgradeData.maxLevel)
		end

		-- Check rebirth requirement
		if upgradeData.requiresRebirth and (playerData.Rebirth or 0) < upgradeData.requiresRebirth then
			table.insert(issues, string.format("%s requires Rebirth %d", upgradeName, upgradeData.requiresRebirth))
			playerData.Upgrades[upgradeName] = 0
		end
	end

	if #issues > 0 then
		warn(string.format("[ANTI-CHEAT] Found %d upgrade integrity issues for player %s",
			#issues,
			tostring(playerData.UserId or "Unknown")
		))
		return false, table.concat(issues, "; ")
	end

	return true, "All upgrades valid"
end

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

function UpgradeManager:GetUpgradesByCategory(category)
	local upgrades = {}

	for upgradeName, upgradeData in pairs(UPGRADE_DEFINITIONS) do
		if upgradeData.category == category then
			table.insert(upgrades, {
				id = upgradeName,
				data = upgradeData,
			})
		end
	end

	return upgrades
end

function UpgradeManager:GetTotalUpgradeLevel(playerData)
	local total = 0

	if playerData.Upgrades then
		for _, level in pairs(playerData.Upgrades) do
			total = total + level
		end
	end

	return total
end

return UpgradeManager
