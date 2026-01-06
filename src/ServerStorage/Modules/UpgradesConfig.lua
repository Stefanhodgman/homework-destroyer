--[[
	UpgradesConfig.lua
	Complete upgrade system configuration for Homework Destroyer

	Contains all upgrade types with costs, effects, and scaling formulas
	Data-driven design for easy balancing
--]]

local UpgradesConfig = {}

-- Helper function to calculate cost at a given level
local function calculateCost(baseCost, level, exponent)
	return math.floor(baseCost * (exponent ^ level))
end

-- Helper function to calculate total cost to reach a level
local function calculateTotalCost(baseCost, targetLevel, exponent)
	local total = 0
	for i = 0, targetLevel - 1 do
		total = total + calculateCost(baseCost, i, exponent)
	end
	return math.floor(total)
end

--[[
	DAMAGE UPGRADES
	Purchased with Destruction Points (DP)
]]
UpgradesConfig.DamageUpgrades = {
	SharperTools = {
		Name = "Sharper Tools",
		Description = "Sharpen your tools for increased base damage",
		MaxLevel = 50,
		BaseCost = 100,
		CostExponent = 1.5,
		EffectType = "FlatDamage",
		EffectPerLevel = 2,

		GetCost = function(level)
			return calculateCost(100, level, 1.5)
		end,

		GetEffect = function(level)
			return level * 2 -- +2 base damage per level
		end,

		GetDescription = function(level)
			return string.format("+%d base damage", level * 2)
		end
	},

	StrongerArms = {
		Name = "Stronger Arms",
		Description = "Increase your clicking power through strength training",
		MaxLevel = 50,
		BaseCost = 200,
		CostExponent = 1.5,
		EffectType = "PercentDamage",
		EffectPerLevel = 5, -- Percent

		GetCost = function(level)
			return calculateCost(200, level, 1.5)
		end,

		GetEffect = function(level)
			return level * 5 / 100 -- +5% per level as decimal
		end,

		GetDescription = function(level)
			return string.format("+%d%% click damage", level * 5)
		end
	},

	CriticalChance = {
		Name = "Critical Chance",
		Description = "Increase your chance to land devastating critical hits",
		MaxLevel = 25,
		BaseCost = 500,
		CostExponent = 2.0,
		EffectType = "CritChance",
		EffectPerLevel = 1, -- Percent
		BaseValue = 5, -- Base 5% crit chance
		MaxValue = 30, -- Cap at 30%

		GetCost = function(level)
			return calculateCost(500, level, 2.0)
		end,

		GetEffect = function(level)
			local total = 5 + level -- Base 5% + 1% per level
			return math.min(total, 30) / 100 -- Cap at 30%, return as decimal
		end,

		GetDescription = function(level)
			local total = math.min(5 + level, 30)
			return string.format("%d%% critical hit chance (max 30%%)", total)
		end
	},

	CriticalDamage = {
		Name = "Critical Damage",
		Description = "Amplify the damage dealt by critical hits",
		MaxLevel = 25,
		BaseCost = 750,
		CostExponent = 2.0,
		EffectType = "CritMultiplier",
		EffectPerLevel = 10, -- Percent
		BaseMultiplier = 2.0, -- Base 2x damage on crit

		GetCost = function(level)
			return calculateCost(750, level, 2.0)
		end,

		GetEffect = function(level)
			return 2.0 + (level * 0.1) -- Base 2x + 0.1x per level
		end,

		GetDescription = function(level)
			local multiplier = 2.0 + (level * 0.1)
			return string.format("%.1fx critical damage multiplier", multiplier)
		end
	},

	PaperWeakness = {
		Name = "Paper Weakness",
		Description = "Deal extra damage to paper-type homework",
		MaxLevel = 20,
		BaseCost = 1000,
		CostExponent = 1.8,
		EffectType = "TypeBonus",
		EffectPerLevel = 10, -- Percent
		TargetType = "Paper",

		GetCost = function(level)
			return calculateCost(1000, level, 1.8)
		end,

		GetEffect = function(level)
			return level * 10 / 100 -- +10% per level as decimal
		end,

		GetDescription = function(level)
			return string.format("+%d%% damage to paper homework", level * 10)
		end
	}
}

--[[
	SPEED UPGRADES
	Purchased with Destruction Points (DP)
]]
UpgradesConfig.SpeedUpgrades = {
	QuickHands = {
		Name = "Quick Hands",
		Description = "Reduce the cooldown between clicks",
		MaxLevel = 30,
		BaseCost = 300,
		CostExponent = 1.6,
		EffectType = "ClickCooldown",
		EffectPerLevel = 2, -- Percent reduction
		MaxReduction = 60, -- Cap at 60% reduction

		GetCost = function(level)
			return calculateCost(300, level, 1.6)
		end,

		GetEffect = function(level)
			local reduction = math.min(level * 2, 60)
			return reduction / 100 -- Return as decimal
		end,

		GetDescription = function(level)
			local reduction = math.min(level * 2, 60)
			return string.format("-%d%% click cooldown (max 60%%)", reduction)
		end
	},

	AutoClickSpeed = {
		Name = "Auto-Click Speed",
		Description = "Increase the speed of automatic clicking (unlocked at Rebirth 1)",
		MaxLevel = 20,
		BaseCost = 5000,
		CostExponent = 2.0,
		EffectType = "AutoClickRate",
		EffectPerLevel = 0.1, -- Clicks per second
		BaseRate = 0.5, -- Base: 1 click per 2 seconds
		MaxRate = 5.0, -- Max 5 clicks per second
		RequiresRebirth = 1,

		GetCost = function(level)
			return calculateCost(5000, level, 2.0)
		end,

		GetEffect = function(level)
			return math.min(0.5 + (level * 0.1), 5.0) -- Clicks per second
		end,

		GetDescription = function(level)
			local rate = math.min(0.5 + (level * 0.1), 5.0)
			return string.format("%.1f auto-clicks per second (max 5.0)", rate)
		end
	},

	MovementSpeed = {
		Name = "Movement Speed",
		Description = "Move faster around the zones to find homework quicker",
		MaxLevel = 15,
		BaseCost = 400,
		CostExponent = 1.5,
		EffectType = "WalkSpeed",
		EffectPerLevel = 3, -- Percent

		GetCost = function(level)
			return calculateCost(400, level, 1.5)
		end,

		GetEffect = function(level)
			return level * 3 / 100 -- +3% per level as decimal
		end,

		GetDescription = function(level)
			return string.format("+%d%% walk speed", level * 3)
		end
	}
}

--[[
	ECONOMY UPGRADES
	Purchased with Destruction Points (DP)
]]
UpgradesConfig.EconomyUpgrades = {
	DPBonus = {
		Name = "DP Bonus",
		Description = "Earn more Destruction Points from all sources",
		MaxLevel = 50,
		BaseCost = 150,
		CostExponent = 1.4,
		EffectType = "DPMultiplier",
		EffectPerLevel = 3, -- Percent

		GetCost = function(level)
			return calculateCost(150, level, 1.4)
		end,

		GetEffect = function(level)
			return level * 3 / 100 -- +3% per level as decimal
		end,

		GetDescription = function(level)
			return string.format("+%d%% DP earned", level * 3)
		end
	},

	LuckyDrops = {
		Name = "Lucky Drops",
		Description = "Increase your chance to get rare drops from homework",
		MaxLevel = 20,
		BaseCost = 2000,
		CostExponent = 1.8,
		EffectType = "DropChance",
		EffectPerLevel = 2, -- Percent

		GetCost = function(level)
			return calculateCost(2000, level, 1.8)
		end,

		GetEffect = function(level)
			return level * 2 / 100 -- +2% per level as decimal
		end,

		GetDescription = function(level)
			return string.format("+%d%% rare drop chance", level * 2)
		end
	},

	EggLuck = {
		Name = "Egg Luck",
		Description = "Improve your chances of hatching rare pets",
		MaxLevel = 15,
		BaseCost = 10000,
		CostExponent = 2.0,
		EffectType = "PetRarity",
		EffectPerLevel = 3, -- Percent

		GetCost = function(level)
			return calculateCost(10000, level, 2.0)
		end,

		GetEffect = function(level)
			return level * 3 / 100 -- +3% per level as decimal
		end,

		GetDescription = function(level)
			return string.format("+%d%% pet rarity luck", level * 3)
		end
	}
}

--[[
	REBIRTH SHOP UPGRADES
	Purchased with Rebirth Tokens (earned from rebirthing)
	These are permanent and persist through all rebirths
]]
UpgradesConfig.RebirthShopUpgrades = {
	StartingBoost = {
		Name = "Starting Boost",
		Description = "Start each rebirth at Level 10 instead of Level 1",
		Cost = 5, -- Rebirth tokens
		EffectType = "StartLevel",
		EffectValue = 10,
		Stackable = false,
		RequiresRebirth = 1,

		GetDescription = function()
			return "Start at Level 10 after rebirth"
		end
	},

	DPSaver = {
		Name = "DP Saver",
		Description = "Keep a portion of your DP when you rebirth",
		Cost = 10, -- Rebirth tokens
		EffectType = "KeepDP",
		EffectValue = 0.10, -- Keep 10%
		Stackable = false,
		RequiresRebirth = 1,

		GetDescription = function()
			return "Keep 10% of DP through rebirth"
		end
	},

	ZoneSkip = {
		Name = "Zone Skip",
		Description = "Start at Zone 3 (Cafeteria) after rebirth",
		Cost = 15, -- Rebirth tokens
		EffectType = "StartZone",
		EffectValue = 3,
		Stackable = false,
		RequiresRebirth = 3,

		GetDescription = function()
			return "Start at Zone 3 after rebirth"
		end
	},

	SuperAuto = {
		Name = "Super Auto",
		Description = "Auto-clicks deal 100% damage instead of 50%",
		Cost = 20, -- Rebirth tokens
		EffectType = "AutoClickDamage",
		EffectValue = 1.0, -- 100% instead of 0.5 (50%)
		Stackable = false,
		RequiresRebirth = 5,

		GetDescription = function()
			return "Auto-clicks deal full damage"
		end
	},

	TokenMultiplier = {
		Name = "Token Multiplier",
		Description = "Earn 1 extra Rebirth Token per rebirth",
		Cost = 25, -- Rebirth tokens
		EffectType = "TokenBonus",
		EffectValue = 1,
		Stackable = true,
		MaxStacks = 5,
		RequiresRebirth = 10,

		GetDescription = function(stacks)
			stacks = stacks or 0
			return string.format("+%d Rebirth Token per rebirth", stacks)
		end
	}
}

--[[
	REBIRTH LEVEL BONUSES
	Automatic bonuses gained from reaching rebirth milestones
]]
UpgradesConfig.RebirthBonuses = {
	{Level = 0, DPMultiplier = 1.0, DamageMultiplier = 1.0, Unlock = nil},
	{Level = 1, DPMultiplier = 1.5, DamageMultiplier = 1.25, Unlock = "Auto-Click feature"},
	{Level = 2, DPMultiplier = 2.0, DamageMultiplier = 1.5, Unlock = "Pet Slot 4"},
	{Level = 3, DPMultiplier = 2.75, DamageMultiplier = 1.75, Unlock = "Rebirth Shop access"},
	{Level = 4, DPMultiplier = 3.5, DamageMultiplier = 2.0, Unlock = "Pet Slot 5"},
	{Level = 5, DPMultiplier = 4.5, DamageMultiplier = 2.5, Unlock = "Exclusive Zone: Detention"},
	{Level = 10, DPMultiplier = 10, DamageMultiplier = 5, Unlock = "Legendary Tool Chest"},
	{Level = 15, DPMultiplier = 20, DamageMultiplier = 8, Unlock = "Pet Slot 6"},
	{Level = 20, DPMultiplier = 35, DamageMultiplier = 12, Unlock = "Prestige System unlock"},
	{Level = 25, DPMultiplier = 50, DamageMultiplier = 15, Unlock = "Secret Zone: Principal's Vault"}
}

-- Function to get rebirth bonus for a specific level
function UpgradesConfig.GetRebirthBonus(rebirthLevel)
	local bonus = {DPMultiplier = 1.0, DamageMultiplier = 1.0, Unlock = nil}

	-- Find the highest applicable bonus
	for _, rebirthBonus in ipairs(UpgradesConfig.RebirthBonuses) do
		if rebirthLevel >= rebirthBonus.Level then
			bonus = rebirthBonus
		end
	end

	return bonus
end

--[[
	PRESTIGE RANKS
	Unlocked at Rebirth 20
]]
UpgradesConfig.PrestigeRanks = {
	{
		Rank = 1,
		Name = "Homework Hater",
		RomanNumeral = "I",
		Requirement = "Prestige once",
		RebirthsRequired = 0, -- Initial prestige
		Bonus = "+100% all damage",
		BonusType = "DamageMultiplier",
		BonusValue = 1.0 -- +100% = 2x total
	},
	{
		Rank = 2,
		Name = "Assignment Annihilator",
		RomanNumeral = "II",
		Requirement = "5 total rebirths post-prestige",
		RebirthsRequired = 5,
		Bonus = "+200% DP",
		BonusType = "DPMultiplier",
		BonusValue = 2.0 -- +200% = 3x total
	},
	{
		Rank = 3,
		Name = "Test Terminator",
		RomanNumeral = "III",
		Requirement = "15 total rebirths post-prestige",
		RebirthsRequired = 15,
		Bonus = "Exclusive pet: Golden Eraser",
		BonusType = "UnlockPet",
		BonusValue = "GoldenEraser"
	},
	{
		Rank = 4,
		Name = "Scholar Slayer",
		RomanNumeral = "IV",
		Requirement = "30 total rebirths post-prestige",
		RebirthsRequired = 30,
		Bonus = "+50% pet damage",
		BonusType = "PetDamage",
		BonusValue = 0.5
	},
	{
		Rank = 5,
		Name = "Education Eliminator",
		RomanNumeral = "V",
		Requirement = "50 total rebirths post-prestige",
		RebirthsRequired = 50,
		Bonus = "Access to Void Zone",
		BonusType = "UnlockZone",
		BonusValue = "TheVoid"
	},
	{
		Rank = 6,
		Name = "HOMEWORK DESTROYER",
		RomanNumeral = "MAX",
		Requirement = "100 total rebirths post-prestige",
		RebirthsRequired = 100,
		Bonus = "Rainbow name, x10 all stats",
		BonusType = "Ultimate",
		BonusValue = {
			RainbowName = true,
			AllStatsMultiplier = 10
		}
	}
}

-- Function to get prestige rank for a given number of post-prestige rebirths
function UpgradesConfig.GetPrestigeRank(postPrestigeRebirths)
	local currentRank = UpgradesConfig.PrestigeRanks[1]

	for _, rank in ipairs(UpgradesConfig.PrestigeRanks) do
		if postPrestigeRebirths >= rank.RebirthsRequired then
			currentRank = rank
		else
			break
		end
	end

	return currentRank
end

--[[
	LEVEL UNLOCK REWARDS
	Special rewards given at specific level milestones
]]
UpgradesConfig.LevelRewards = {
	-- Every level
	EveryLevel = {
		Type = "DamageBoost",
		Value = 0.05 -- +5% base damage
	},

	-- Every 5 levels
	Every5Levels = {
		Type = "PetEgg",
		Value = "ClassroomEgg"
	},

	-- Every 10 levels
	Every10Levels = {
		Type = "ToolUpgradeToken",
		Value = 1
	},

	-- Specific levels
	SpecificLevels = {
		[25] = {Type = "PetSlot", Value = 2, Description = "Unlock Pet Equip Slot 2"},
		[50] = {Type = "PetSlot", Value = 3, Description = "Unlock Pet Equip Slot 3"},
		[75] = {Type = "ToolDualWield", Value = true, Description = "Unlock Tool Dual-Wield"},
		[100] = {Type = "RebirthUnlock", Value = true, Description = "Unlock Rebirth"}
	}
}

--[[
	HELPER FUNCTIONS
]]

-- Get all upgrades of a specific category
function UpgradesConfig.GetUpgradeCategory(category)
	if category == "Damage" then
		return UpgradesConfig.DamageUpgrades
	elseif category == "Speed" then
		return UpgradesConfig.SpeedUpgrades
	elseif category == "Economy" then
		return UpgradesConfig.EconomyUpgrades
	elseif category == "RebirthShop" then
		return UpgradesConfig.RebirthShopUpgrades
	end
	return nil
end

-- Check if an upgrade can be purchased
function UpgradesConfig.CanPurchaseUpgrade(upgrade, currentLevel, playerDP, rebirthLevel)
	-- Check if max level reached
	if upgrade.MaxLevel and currentLevel >= upgrade.MaxLevel then
		return false, "Max level reached"
	end

	-- Check rebirth requirement
	if upgrade.RequiresRebirth and rebirthLevel < upgrade.RequiresRebirth then
		return false, string.format("Requires Rebirth %d", upgrade.RequiresRebirth)
	end

	-- Check if player can afford
	local cost = upgrade.GetCost(currentLevel)
	if playerDP < cost then
		return false, string.format("Need %d DP", cost)
	end

	return true, "Can purchase"
end

-- Calculate total effect from all upgrades for a player
function UpgradesConfig.CalculateTotalEffects(playerUpgrades)
	local effects = {
		FlatDamage = 0,
		PercentDamage = 0,
		CritChance = 0.05, -- Base 5%
		CritMultiplier = 2.0, -- Base 2x
		ClickCooldownReduction = 0,
		AutoClickRate = 0.5, -- Base 0.5 clicks/sec
		WalkSpeed = 0,
		DPMultiplier = 0,
		DropChance = 0,
		PetRarity = 0,
		PaperBonus = 0
	}

	-- Process damage upgrades
	for upgradeName, level in pairs(playerUpgrades.Damage or {}) do
		local upgrade = UpgradesConfig.DamageUpgrades[upgradeName]
		if upgrade then
			if upgrade.EffectType == "FlatDamage" then
				effects.FlatDamage = effects.FlatDamage + upgrade.GetEffect(level)
			elseif upgrade.EffectType == "PercentDamage" then
				effects.PercentDamage = effects.PercentDamage + upgrade.GetEffect(level)
			elseif upgrade.EffectType == "CritChance" then
				effects.CritChance = upgrade.GetEffect(level)
			elseif upgrade.EffectType == "CritMultiplier" then
				effects.CritMultiplier = upgrade.GetEffect(level)
			elseif upgrade.EffectType == "TypeBonus" and upgrade.TargetType == "Paper" then
				effects.PaperBonus = upgrade.GetEffect(level)
			end
		end
	end

	-- Process speed upgrades
	for upgradeName, level in pairs(playerUpgrades.Speed or {}) do
		local upgrade = UpgradesConfig.SpeedUpgrades[upgradeName]
		if upgrade then
			if upgrade.EffectType == "ClickCooldown" then
				effects.ClickCooldownReduction = upgrade.GetEffect(level)
			elseif upgrade.EffectType == "AutoClickRate" then
				effects.AutoClickRate = upgrade.GetEffect(level)
			elseif upgrade.EffectType == "WalkSpeed" then
				effects.WalkSpeed = effects.WalkSpeed + upgrade.GetEffect(level)
			end
		end
	end

	-- Process economy upgrades
	for upgradeName, level in pairs(playerUpgrades.Economy or {}) do
		local upgrade = UpgradesConfig.EconomyUpgrades[upgradeName]
		if upgrade then
			if upgrade.EffectType == "DPMultiplier" then
				effects.DPMultiplier = effects.DPMultiplier + upgrade.GetEffect(level)
			elseif upgrade.EffectType == "DropChance" then
				effects.DropChance = effects.DropChance + upgrade.GetEffect(level)
			elseif upgrade.EffectType == "PetRarity" then
				effects.PetRarity = effects.PetRarity + upgrade.GetEffect(level)
			end
		end
	end

	return effects
end

return UpgradesConfig
