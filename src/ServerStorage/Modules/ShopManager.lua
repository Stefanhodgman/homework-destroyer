--[[
	ShopManager.lua
	Complete shop system for Homework Destroyer

	Handles 3 main shops:
	1. Tool Shop - Purchase and upgrade weapons/tools
	2. Egg Shop - Purchase pet eggs (8 egg types)
	3. Rebirth Token Shop - Permanent upgrades using rebirth tokens

	Also integrates with GamepassManager for premium purchases
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ShopManager = {}
ShopManager.__index = ShopManager

-- ========================================
-- TOOL SHOP CONFIGURATION
-- ========================================

ShopManager.Tools = {
	-- COMMON TOOLS (Zone 1-2)
	{
		ID = "PencilEraser",
		Name = "Pencil Eraser",
		Description = "Your trusty starting tool for homework destruction!",
		Rarity = "Common",
		BaseDamage = 1,
		CritChance = 0.05, -- 5%
		CritMultiplier = 1.5,
		Cost = 0, -- FREE starter tool
		RequiredLevel = 1,
		RequiredZone = 1,
		UpgradeCost = {Base = 50, Multiplier = 1.5},
		MaxUpgradeLevel = 10,
		UpgradeBonus = 0.1, -- +10% damage per upgrade
		Icon = "rbxassetid://PENCIL_ERASER_ICON",
	},
	{
		ID = "RulerSlap",
		Name = "Ruler Slap",
		Description = "12 inches of pure destruction power!",
		Rarity = "Common",
		BaseDamage = 2,
		CritChance = 0.08,
		CritMultiplier = 1.5,
		Cost = 500,
		RequiredLevel = 3,
		RequiredZone = 1,
		UpgradeCost = {Base = 75, Multiplier = 1.5},
		MaxUpgradeLevel = 10,
		UpgradeBonus = 0.1,
		Icon = "rbxassetid://RULER_ICON",
	},
	{
		ID = "ScissorSlash",
		Name = "Scissor Slash",
		Description = "Cuts through homework like paper!",
		Rarity = "Uncommon",
		BaseDamage = 4,
		CritChance = 0.10,
		CritMultiplier = 1.75,
		Cost = 2500,
		RequiredLevel = 8,
		RequiredZone = 1,
		UpgradeCost = {Base = 150, Multiplier = 1.5},
		MaxUpgradeLevel = 15,
		UpgradeBonus = 0.12,
		Icon = "rbxassetid://SCISSORS_ICON",
	},

	-- UNCOMMON TOOLS (Zone 2-4)
	{
		ID = "StaplerSmash",
		Name = "Stapler Smash",
		Description = "Staples homework assignments into submission!",
		Rarity = "Uncommon",
		BaseDamage = 8,
		CritChance = 0.12,
		CritMultiplier = 1.75,
		Cost = 10000,
		RequiredLevel = 15,
		RequiredZone = 2,
		UpgradeCost = {Base = 300, Multiplier = 1.6},
		MaxUpgradeLevel = 15,
		UpgradeBonus = 0.12,
		Icon = "rbxassetid://STAPLER_ICON",
	},
	{
		ID = "NotebookNuke",
		Name = "Notebook Nuke",
		Description = "A notebook so powerful, it destroys other notebooks!",
		Rarity = "Uncommon",
		BaseDamage = 12,
		CritChance = 0.15,
		CritMultiplier = 2.0,
		Cost = 25000,
		RequiredLevel = 22,
		RequiredZone = 3,
		UpgradeCost = {Base = 500, Multiplier = 1.6},
		MaxUpgradeLevel = 15,
		UpgradeBonus = 0.12,
		Icon = "rbxassetid://NOTEBOOK_ICON",
	},

	-- RARE TOOLS (Zone 4-6)
	{
		ID = "CalculatorCannon",
		Name = "Calculator Cannon",
		Description = "Does the math on homework destruction!",
		Rarity = "Rare",
		BaseDamage = 25,
		CritChance = 0.18,
		CritMultiplier = 2.0,
		Cost = 75000,
		RequiredLevel = 30,
		RequiredZone = 4,
		UpgradeCost = {Base = 1000, Multiplier = 1.7},
		MaxUpgradeLevel = 20,
		UpgradeBonus = 0.15,
		Icon = "rbxassetid://CALCULATOR_ICON",
		SpecialEffect = "Math equations appear on hit",
	},
	{
		ID = "GlueGun",
		Name = "Glue Gun",
		Description = "Sticks homework together then tears it apart!",
		Rarity = "Rare",
		BaseDamage = 35,
		CritChance = 0.20,
		CritMultiplier = 2.25,
		Cost = 150000,
		RequiredLevel = 38,
		RequiredZone = 5,
		UpgradeCost = {Base = 2000, Multiplier = 1.7},
		MaxUpgradeLevel = 20,
		UpgradeBonus = 0.15,
		Icon = "rbxassetid://GLUEGUN_ICON",
	},

	-- EPIC TOOLS (Zone 6-8)
	{
		ID = "LaserPointer",
		Name = "Laser Pointer 3000",
		Description = "High-tech homework annihilation!",
		Rarity = "Epic",
		BaseDamage = 60,
		CritChance = 0.25,
		CritMultiplier = 2.5,
		Cost = 500000,
		RequiredLevel = 50,
		RequiredZone = 6,
		UpgradeCost = {Base = 5000, Multiplier = 1.8},
		MaxUpgradeLevel = 25,
		UpgradeBonus = 0.18,
		Icon = "rbxassetid://LASER_ICON",
		SpecialEffect = "Laser beam visual",
	},
	{
		ID = "TextbookThrower",
		Name = "Textbook Thrower",
		Description = "Fight books with books!",
		Rarity = "Epic",
		BaseDamage = 90,
		CritChance = 0.28,
		CritMultiplier = 2.75,
		Cost = 1000000,
		RequiredLevel = 60,
		RequiredZone = 7,
		UpgradeCost = {Base = 10000, Multiplier = 1.8},
		MaxUpgradeLevel = 25,
		UpgradeBonus = 0.18,
		Icon = "rbxassetid://TEXTBOOK_ICON",
	},

	-- LEGENDARY TOOLS (Zone 8-10)
	{
		ID = "AtomicPen",
		Name = "Atomic Pen",
		Description = "The pen is DEFINITELY mightier than homework!",
		Rarity = "Legendary",
		BaseDamage = 150,
		CritChance = 0.35,
		CritMultiplier = 3.0,
		Cost = 5000000,
		RequiredLevel = 75,
		RequiredZone = 8,
		UpgradeCost = {Base = 25000, Multiplier = 2.0},
		MaxUpgradeLevel = 30,
		UpgradeBonus = 0.20,
		Icon = "rbxassetid://ATOMIC_PEN_ICON",
		SpecialEffect = "Atomic explosion on crit",
	},
	{
		ID = "TheEraser",
		Name = "The Eraser",
		Description = "Legendary eraser that removes homework from existence!",
		Rarity = "Legendary",
		BaseDamage = 250,
		CritChance = 0.40,
		CritMultiplier = 3.5,
		Cost = 15000000,
		RequiredLevel = 85,
		RequiredZone = 9,
		UpgradeCost = {Base = 50000, Multiplier = 2.0},
		MaxUpgradeLevel = 30,
		UpgradeBonus = 0.20,
		Icon = "rbxassetid://THE_ERASER_ICON",
		SpecialEffect = "Erases homework with particles",
	},

	-- MYTHIC TOOLS (Zone 10, High Level)
	{
		ID = "HomeworkDestroyer",
		Name = "Homework Destroyer MK-1",
		Description = "The ultimate homework destruction device!",
		Rarity = "Mythic",
		BaseDamage = 500,
		CritChance = 0.50,
		CritMultiplier = 4.0,
		Cost = 50000000,
		RequiredLevel = 95,
		RequiredZone = 10,
		RequiredRebirth = 5,
		UpgradeCost = {Base = 100000, Multiplier = 2.2},
		MaxUpgradeLevel = 50,
		UpgradeBonus = 0.25,
		Icon = "rbxassetid://DESTROYER_ICON",
		SpecialEffect = "Epic destruction animation",
	},
	{
		ID = "VoidBlade",
		Name = "Void Blade",
		Description = "Channels the power of the homework void!",
		Rarity = "Mythic",
		BaseDamage = 1000,
		CritChance = 0.60,
		CritMultiplier = 5.0,
		Cost = 100000000,
		RequiredLevel = 100,
		RequiredZone = 10,
		RequiredRebirth = 10,
		UpgradeCost = {Base = 250000, Multiplier = 2.5},
		MaxUpgradeLevel = 50,
		UpgradeBonus = 0.30,
		Icon = "rbxassetid://VOID_BLADE_ICON",
		SpecialEffect = "Void energy effect",
	},
}

-- ========================================
-- EGG SHOP CONFIGURATION (8 EGG TYPES)
-- ========================================

ShopManager.Eggs = {
	{
		ID = "BasicEgg",
		Name = "Basic Egg",
		Description = "A simple egg containing common pets",
		Cost = {Currency = "DestructionPoints", Amount = 500},
		Icon = "rbxassetid://BASIC_EGG_ICON",
		HatchTime = 0, -- Instant
		RequiredLevel = 1,
		RequiredZone = 1,
		RarityChances = {
			Common = 70,
			Uncommon = 25,
			Rare = 4.5,
			Epic = 0.5,
			Legendary = 0,
			Mythic = 0,
		},
		PetPool = {"PaperAirplane", "PencilBuddy", "AngryRuler", "HomeworkGremlin"},
	},
	{
		ID = "AdvancedEgg",
		Name = "Advanced Egg",
		Description = "Better odds for uncommon and rare pets",
		Cost = {Currency = "DestructionPoints", Amount = 2500},
		Icon = "rbxassetid://ADVANCED_EGG_ICON",
		HatchTime = 30,
		RequiredLevel = 10,
		RequiredZone = 2,
		RarityChances = {
			Common = 45,
			Uncommon = 35,
			Rare = 15,
			Epic = 4.5,
			Legendary = 0.5,
			Mythic = 0,
		},
		PetPool = {"PencilBuddy", "EraserMonster", "ScissorSpirit", "AngryTextbook", "GradeGoblin"},
	},
	{
		ID = "RareEgg",
		Name = "Rare Egg",
		Description = "High chance for rare and epic pets!",
		Cost = {Currency = "DestructionPoints", Amount = 10000},
		Icon = "rbxassetid://RARE_EGG_ICON",
		HatchTime = 60,
		RequiredLevel = 20,
		RequiredZone = 4,
		RarityChances = {
			Common = 25,
			Uncommon = 40,
			Rare = 25,
			Epic = 8,
			Legendary = 2,
			Mythic = 0,
		},
		PetPool = {"ScissorSpirit", "GlueGolem", "CalculatorBot", "NotebookNinja", "StudyBuddy"},
	},
	{
		ID = "EpicEgg",
		Name = "Epic Egg",
		Description = "Guaranteed rare or better!",
		Cost = {Currency = "DestructionPoints", Amount = 50000},
		Icon = "rbxassetid://EPIC_EGG_ICON",
		HatchTime = 120,
		RequiredLevel = 35,
		RequiredZone = 6,
		RarityChances = {
			Common = 0,
			Uncommon = 30,
			Rare = 40,
			Epic = 22,
			Legendary = 7.5,
			Mythic = 0.5,
		},
		PetPool = {"CalculatorBot", "BackpackBeast", "USBUnicorn", "LibraryGuardian", "ProcrastinationDemon"},
	},
	{
		ID = "LegendaryEgg",
		Name = "Legendary Egg",
		Description = "Epic or better guaranteed!",
		Cost = {Currency = "DestructionPoints", Amount = 250000},
		Icon = "rbxassetid://LEGENDARY_EGG_ICON",
		HatchTime = 180,
		RequiredLevel = 50,
		RequiredZone = 8,
		RarityChances = {
			Common = 0,
			Uncommon = 0,
			Rare = 30,
			Epic = 45,
			Legendary = 22,
			Mythic = 3,
		},
		PetPool = {"GoldenPen", "LibraryGuardian", "VirusViper", "WiFiWizard", "BackpackBeast"},
	},
	{
		ID = "MythicEgg",
		Name = "Mythic Egg",
		Description = "The ultimate egg with highest mythic chance!",
		Cost = {Currency = "DestructionPoints", Amount = 1000000},
		Icon = "rbxassetid://MYTHIC_EGG_ICON",
		HatchTime = 300,
		RequiredLevel = 70,
		RequiredZone = 10,
		RequiredRebirth = 1,
		RarityChances = {
			Common = 0,
			Uncommon = 0,
			Rare = 0,
			Epic = 60,
			Legendary = 32,
			Mythic = 8,
		},
		PetPool = {"WiFiWizard", "TeachersPet", "ProcrastinationDemon", "LibraryGuardian", "GoldenPen"},
	},
	{
		ID = "PremiumEgg",
		Name = "Premium Egg",
		Description = "Premium egg with better rates! (Robux or Gems)",
		Cost = {Currency = "Robux", Amount = 99},
		AlternateCost = {Currency = "Gems", Amount = 150},
		Icon = "rbxassetid://PREMIUM_EGG_ICON",
		HatchTime = 0,
		RequiredLevel = 1,
		RequiredZone = 1,
		RarityChances = {
			Common = 0,
			Uncommon = 15,
			Rare = 40,
			Epic = 30,
			Legendary = 13,
			Mythic = 2,
		},
		PetPool = {"GoldenPen", "BackpackBeast", "VirusViper", "LibraryGuardian", "TeachersPet"},
		IsPremium = true,
	},
	{
		ID = "StarterPack",
		Name = "Starter Pack Egg",
		Description = "One-time purchase! Great value for new players!",
		Cost = {Currency = "Robux", Amount = 199},
		Icon = "rbxassetid://STARTER_PACK_ICON",
		HatchTime = 0,
		RequiredLevel = 1,
		RequiredZone = 1,
		RarityChances = {
			Common = 0,
			Uncommon = 0,
			Rare = 50,
			Epic = 40,
			Legendary = 10,
			Mythic = 0,
		},
		PetPool = {"CalculatorBot", "ScissorSpirit", "StudyBuddy", "NotebookNinja"},
		IsPremium = true,
		OneTimePurchase = true,
		BonusRewards = {
			{Type = "Currency", Currency = "Gems", Amount = 500},
			{Type = "Currency", Currency = "DestructionPoints", Amount = 10000},
			{Type = "Eggs", EggID = "AdvancedEgg", Quantity = 3},
		},
	},
}

-- ========================================
-- REBIRTH TOKEN SHOP (PERMANENT UPGRADES)
-- ========================================

ShopManager.RebirthShop = {
	{
		ID = "StartingBoost",
		Name = "Starting Boost",
		Description = "Start at Level 10 after rebirth instead of Level 1",
		Cost = {Currency = "RebirthTokens", Amount = 5},
		MaxPurchases = 1,
		RequiredRebirth = 1,
		Icon = "rbxassetid://STARTING_BOOST_ICON",
		Category = "Progression",
	},
	{
		ID = "DPSaver",
		Name = "DP Saver",
		Description = "Keep 10% of your DP after rebirth",
		Cost = {Currency = "RebirthTokens", Amount = 10},
		MaxPurchases = 1,
		RequiredRebirth = 2,
		Icon = "rbxassetid://DP_SAVER_ICON",
		Category = "Economy",
	},
	{
		ID = "ZoneSkip",
		Name = "Zone Skip",
		Description = "Start at Zone 3 after rebirth",
		Cost = {Currency = "RebirthTokens", Amount = 15},
		MaxPurchases = 1,
		RequiredRebirth = 3,
		Icon = "rbxassetid://ZONE_SKIP_ICON",
		Category = "Progression",
	},
	{
		ID = "TokenMultiplier",
		Name = "Token Multiplier",
		Description = "+10% Rebirth Tokens earned (stackable, max 5x)",
		Cost = {Currency = "RebirthTokens", Amount = 20},
		MaxPurchases = 5,
		RequiredRebirth = 4,
		Icon = "rbxassetid://TOKEN_MULT_ICON",
		Category = "Economy",
		Stackable = true,
	},
	{
		ID = "SuperAuto",
		Name = "Super Auto-Click",
		Description = "Auto-clicks deal 100% damage instead of 50%",
		Cost = {Currency = "RebirthTokens", Amount = 25},
		MaxPurchases = 1,
		RequiredRebirth = 5,
		Icon = "rbxassetid://SUPER_AUTO_ICON",
		Category = "Combat",
	},
	{
		ID = "PetSlots",
		Name = "Extra Pet Slot",
		Description = "+1 pet equip slot (stackable, max 3 extra)",
		Cost = {Currency = "RebirthTokens", Amount = 30},
		MaxPurchases = 3,
		RequiredRebirth = 6,
		Icon = "rbxassetid://PET_SLOT_ICON",
		Category = "Pets",
		Stackable = true,
	},
	{
		ID = "CritMaster",
		Name = "Crit Master",
		Description = "+15% base crit chance permanently",
		Cost = {Currency = "RebirthTokens", Amount = 40},
		MaxPurchases = 1,
		RequiredRebirth = 7,
		Icon = "rbxassetid://CRIT_MASTER_ICON",
		Category = "Combat",
	},
	{
		ID = "DualWield",
		Name = "Dual Wield",
		Description = "Equip 2 tools at once for 150% total damage",
		Cost = {Currency = "RebirthTokens", Amount = 50},
		MaxPurchases = 1,
		RequiredRebirth = 8,
		Icon = "rbxassetid://DUAL_WIELD_ICON",
		Category = "Combat",
	},
	{
		ID = "EggLuck",
		Name = "Lucky Eggs",
		Description = "+20% better egg rarity chances",
		Cost = {Currency = "RebirthTokens", Amount = 35},
		MaxPurchases = 1,
		RequiredRebirth = 5,
		Icon = "rbxassetid://EGG_LUCK_ICON",
		Category = "Pets",
	},
	{
		ID = "InstantRebirth",
		Name = "Instant Rebirth",
		Description = "Unlock ability to rebirth instantly (no cooldown)",
		Cost = {Currency = "RebirthTokens", Amount = 100},
		MaxPurchases = 1,
		RequiredRebirth = 10,
		Icon = "rbxassetid://INSTANT_REBIRTH_ICON",
		Category = "Progression",
	},
}

-- ========================================
-- INITIALIZATION
-- ========================================

function ShopManager.new()
	local self = setmetatable({}, ShopManager)
	self.purchaseHistory = {} -- Track purchase history for analytics
	return self
end

-- ========================================
-- TOOL SHOP FUNCTIONS
-- ========================================

function ShopManager:GetToolInfo(toolID)
	for _, tool in ipairs(self.Tools) do
		if tool.ID == toolID then
			return tool
		end
	end
	return nil
end

function ShopManager:CanPurchaseTool(playerData, toolID)
	local tool = self:GetToolInfo(toolID)
	if not tool then
		return false, "Tool not found"
	end

	-- Check if already owned
	if table.find(playerData.Tools.Owned, toolID) then
		return false, "Already owned"
	end

	-- Check level requirement
	if playerData.Level < tool.RequiredLevel then
		return false, string.format("Requires Level %d", tool.RequiredLevel)
	end

	-- Check zone requirement
	if tool.RequiredZone and playerData.CurrentZone < tool.RequiredZone then
		return false, string.format("Requires Zone %d", tool.RequiredZone)
	end

	-- Check rebirth requirement
	if tool.RequiredRebirth and playerData.RebirthLevel < tool.RequiredRebirth then
		return false, string.format("Requires Rebirth %d", tool.RequiredRebirth)
	end

	-- Check DP
	if playerData.DestructionPoints < tool.Cost then
		return false, string.format("Insufficient DP (need %d)", tool.Cost)
	end

	return true, "Can purchase"
end

function ShopManager:PurchaseTool(playerData, toolID)
	local canPurchase, message = self:CanPurchaseTool(playerData, toolID)
	if not canPurchase then
		return false, message
	end

	local tool = self:GetToolInfo(toolID)

	-- Deduct cost
	playerData.DestructionPoints = playerData.DestructionPoints - tool.Cost

	-- Add tool to owned
	table.insert(playerData.Tools.Owned, toolID)
	playerData.Tools.UpgradeLevels[toolID] = 0

	-- Log purchase
	self:LogPurchase(playerData, "Tool", toolID, tool.Cost, "DestructionPoints")

	return true, "Tool purchased successfully", {
		toolID = toolID,
		remainingDP = playerData.DestructionPoints,
	}
end

function ShopManager:CalculateToolUpgradeCost(toolID, currentLevel)
	local tool = self:GetToolInfo(toolID)
	if not tool then return nil end

	if currentLevel >= tool.MaxUpgradeLevel then
		return nil -- Max level reached
	end

	return math.floor(tool.UpgradeCost.Base * (tool.UpgradeCost.Multiplier ^ currentLevel))
end

function ShopManager:UpgradeTool(playerData, toolID)
	local tool = self:GetToolInfo(toolID)
	if not tool then
		return false, "Tool not found"
	end

	-- Check if owned
	if not table.find(playerData.Tools.Owned, toolID) then
		return false, "Tool not owned"
	end

	local currentLevel = playerData.Tools.UpgradeLevels[toolID] or 0

	-- Check max level
	if currentLevel >= tool.MaxUpgradeLevel then
		return false, "Max upgrade level reached"
	end

	-- Calculate cost
	local cost = self:CalculateToolUpgradeCost(toolID, currentLevel)
	if not cost then
		return false, "Cannot calculate cost"
	end

	-- Check DP
	if playerData.DestructionPoints < cost then
		return false, string.format("Insufficient DP (need %d)", cost)
	end

	-- Perform upgrade
	playerData.DestructionPoints = playerData.DestructionPoints - cost
	playerData.Tools.UpgradeLevels[toolID] = currentLevel + 1

	self:LogPurchase(playerData, "ToolUpgrade", toolID, cost, "DestructionPoints")

	return true, "Tool upgraded successfully", {
		toolID = toolID,
		newLevel = currentLevel + 1,
		costPaid = cost,
		remainingDP = playerData.DestructionPoints,
	}
end

function ShopManager:GetAllAvailableTools(playerData)
	local tools = {}

	for _, tool in ipairs(self.Tools) do
		local canPurchase, reason = self:CanPurchaseTool(playerData, tool.ID)
		local isOwned = table.find(playerData.Tools.Owned, tool.ID) ~= nil
		local currentUpgradeLevel = playerData.Tools.UpgradeLevels[tool.ID] or 0

		table.insert(tools, {
			ID = tool.ID,
			Name = tool.Name,
			Description = tool.Description,
			Rarity = tool.Rarity,
			BaseDamage = tool.BaseDamage,
			CritChance = tool.CritChance,
			CritMultiplier = tool.CritMultiplier,
			Cost = tool.Cost,
			RequiredLevel = tool.RequiredLevel,
			RequiredZone = tool.RequiredZone,
			RequiredRebirth = tool.RequiredRebirth,
			Icon = tool.Icon,
			CanPurchase = canPurchase,
			Reason = reason,
			IsOwned = isOwned,
			UpgradeLevel = currentUpgradeLevel,
			MaxUpgradeLevel = tool.MaxUpgradeLevel,
			UpgradeCost = isOwned and self:CalculateToolUpgradeCost(tool.ID, currentUpgradeLevel) or nil,
		})
	end

	return tools
end

-- ========================================
-- EGG SHOP FUNCTIONS
-- ========================================

function ShopManager:GetEggInfo(eggID)
	for _, egg in ipairs(self.Eggs) do
		if egg.ID == eggID then
			return egg
		end
	end
	return nil
end

function ShopManager:CanPurchaseEgg(playerData, eggID)
	local egg = self:GetEggInfo(eggID)
	if not egg then
		return false, "Egg not found"
	end

	-- Check level requirement
	if playerData.Level < egg.RequiredLevel then
		return false, string.format("Requires Level %d", egg.RequiredLevel)
	end

	-- Check zone requirement
	if egg.RequiredZone and playerData.CurrentZone < egg.RequiredZone then
		return false, string.format("Requires Zone %d", egg.RequiredZone)
	end

	-- Check rebirth requirement
	if egg.RequiredRebirth and playerData.RebirthLevel < egg.RequiredRebirth then
		return false, string.format("Requires Rebirth %d", egg.RequiredRebirth)
	end

	-- Check one-time purchase
	if egg.OneTimePurchase then
		local purchaseKey = "OneTime_" .. eggID
		if playerData.PurchaseHistory and playerData.PurchaseHistory[purchaseKey] then
			return false, "Already purchased (one-time only)"
		end
	end

	-- Check currency (handled separately for Robux)
	if egg.Cost.Currency == "DestructionPoints" then
		if playerData.DestructionPoints < egg.Cost.Amount then
			return false, string.format("Insufficient DP (need %d)", egg.Cost.Amount)
		end
	elseif egg.Cost.Currency == "Gems" then
		if (playerData.Gems or 0) < egg.Cost.Amount then
			return false, string.format("Insufficient Gems (need %d)", egg.Cost.Amount)
		end
	end

	return true, "Can purchase"
end

function ShopManager:PurchaseEgg(playerData, eggID, useAlternate)
	local egg = self:GetEggInfo(eggID)
	if not egg then
		return false, "Egg not found"
	end

	-- Determine which cost to use
	local cost = egg.Cost
	if useAlternate and egg.AlternateCost then
		cost = egg.AlternateCost
	end

	-- For Robux purchases, this should be handled by GamepassManager
	if cost.Currency == "Robux" then
		return false, "Robux purchases must go through GamepassManager"
	end

	local canPurchase, message = self:CanPurchaseEgg(playerData, eggID)
	if not canPurchase then
		return false, message
	end

	-- Deduct currency
	if cost.Currency == "DestructionPoints" then
		playerData.DestructionPoints = playerData.DestructionPoints - cost.Amount
	elseif cost.Currency == "Gems" then
		playerData.Gems = (playerData.Gems or 0) - cost.Amount
	end

	-- Add egg to inventory
	if not playerData.Eggs then
		playerData.Eggs = {}
	end
	playerData.Eggs[eggID] = (playerData.Eggs[eggID] or 0) + 1

	-- Mark one-time purchase
	if egg.OneTimePurchase then
		if not playerData.PurchaseHistory then
			playerData.PurchaseHistory = {}
		end
		playerData.PurchaseHistory["OneTime_" .. eggID] = os.time()
	end

	-- Add bonus rewards if any
	if egg.BonusRewards then
		for _, reward in ipairs(egg.BonusRewards) do
			if reward.Type == "Currency" then
				if reward.Currency == "Gems" then
					playerData.Gems = (playerData.Gems or 0) + reward.Amount
				elseif reward.Currency == "DestructionPoints" then
					playerData.DestructionPoints = playerData.DestructionPoints + reward.Amount
				end
			elseif reward.Type == "Eggs" then
				playerData.Eggs[reward.EggID] = (playerData.Eggs[reward.EggID] or 0) + reward.Quantity
			end
		end
	end

	self:LogPurchase(playerData, "Egg", eggID, cost.Amount, cost.Currency)

	return true, "Egg purchased successfully", {
		eggID = eggID,
		costPaid = cost.Amount,
		currency = cost.Currency,
		bonusRewards = egg.BonusRewards,
	}
end

function ShopManager:GetAllAvailableEggs(playerData)
	local eggs = {}

	for _, egg in ipairs(self.Eggs) do
		local canPurchase, reason = self:CanPurchaseEgg(playerData, egg.ID)
		local ownedCount = playerData.Eggs and playerData.Eggs[egg.ID] or 0

		table.insert(eggs, {
			ID = egg.ID,
			Name = egg.Name,
			Description = egg.Description,
			Cost = egg.Cost,
			AlternateCost = egg.AlternateCost,
			Icon = egg.Icon,
			HatchTime = egg.HatchTime,
			RequiredLevel = egg.RequiredLevel,
			RequiredZone = egg.RequiredZone,
			RequiredRebirth = egg.RequiredRebirth,
			RarityChances = egg.RarityChances,
			IsPremium = egg.IsPremium,
			OneTimePurchase = egg.OneTimePurchase,
			CanPurchase = canPurchase,
			Reason = reason,
			OwnedCount = ownedCount,
			BonusRewards = egg.BonusRewards,
		})
	end

	return eggs
end

-- ========================================
-- REBIRTH SHOP FUNCTIONS
-- ========================================

function ShopManager:GetRebirthItemInfo(itemID)
	for _, item in ipairs(self.RebirthShop) do
		if item.ID == itemID then
			return item
		end
	end
	return nil
end

function ShopManager:CanPurchaseRebirthItem(playerData, itemID)
	local item = self:GetRebirthItemInfo(itemID)
	if not item then
		return false, "Item not found"
	end

	-- Check rebirth requirement
	if playerData.RebirthLevel < item.RequiredRebirth then
		return false, string.format("Requires Rebirth %d", item.RequiredRebirth)
	end

	-- Check if already purchased max times
	if not playerData.RebirthShop then
		playerData.RebirthShop = {}
	end

	local purchaseCount = playerData.RebirthShop[itemID] or 0
	if purchaseCount >= item.MaxPurchases then
		return false, "Max purchases reached"
	end

	-- Check rebirth tokens
	if playerData.RebirthTokens < item.Cost.Amount then
		return false, string.format("Insufficient Rebirth Tokens (need %d)", item.Cost.Amount)
	end

	return true, "Can purchase"
end

function ShopManager:PurchaseRebirthItem(playerData, itemID)
	local canPurchase, message = self:CanPurchaseRebirthItem(playerData, itemID)
	if not canPurchase then
		return false, message
	end

	local item = self:GetRebirthItemInfo(itemID)

	-- Deduct rebirth tokens
	playerData.RebirthTokens = playerData.RebirthTokens - item.Cost.Amount

	-- Increment purchase count
	if not playerData.RebirthShop then
		playerData.RebirthShop = {}
	end
	playerData.RebirthShop[itemID] = (playerData.RebirthShop[itemID] or 0) + 1

	self:LogPurchase(playerData, "RebirthShop", itemID, item.Cost.Amount, "RebirthTokens")

	return true, "Rebirth item purchased successfully", {
		itemID = itemID,
		purchaseCount = playerData.RebirthShop[itemID],
		remainingTokens = playerData.RebirthTokens,
	}
end

function ShopManager:GetAllRebirthItems(playerData)
	local items = {}

	for _, item in ipairs(self.RebirthShop) do
		local canPurchase, reason = self:CanPurchaseRebirthItem(playerData, item.ID)
		local purchaseCount = playerData.RebirthShop and playerData.RebirthShop[item.ID] or 0

		table.insert(items, {
			ID = item.ID,
			Name = item.Name,
			Description = item.Description,
			Cost = item.Cost,
			MaxPurchases = item.MaxPurchases,
			RequiredRebirth = item.RequiredRebirth,
			Icon = item.Icon,
			Category = item.Category,
			Stackable = item.Stackable,
			CanPurchase = canPurchase,
			Reason = reason,
			PurchaseCount = purchaseCount,
			IsMaxed = purchaseCount >= item.MaxPurchases,
		})
	end

	-- Sort by category
	table.sort(items, function(a, b)
		if a.Category ~= b.Category then
			return a.Category < b.Category
		end
		return a.RequiredRebirth < b.RequiredRebirth
	end)

	return items
end

-- ========================================
-- PURCHASE LOGGING & ANALYTICS
-- ========================================

function ShopManager:LogPurchase(playerData, purchaseType, itemID, cost, currency)
	local logEntry = {
		PlayerID = playerData.UserId,
		Type = purchaseType,
		ItemID = itemID,
		Cost = cost,
		Currency = currency,
		Timestamp = os.time(),
	}

	table.insert(self.purchaseHistory, logEntry)

	print(string.format("[SHOP] %s purchased %s '%s' for %d %s",
		tostring(playerData.UserId or "Unknown"),
		purchaseType,
		itemID,
		cost,
		currency
	))
end

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

function ShopManager:GetShopStats(playerData)
	return {
		ToolsOwned = #playerData.Tools.Owned,
		TotalToolsAvailable = #self.Tools,
		EggsInInventory = self:CountTotalEggs(playerData),
		RebirthItemsPurchased = self:CountRebirthPurchases(playerData),
		TotalRebirthItems = #self.RebirthShop,
	}
end

function ShopManager:CountTotalEggs(playerData)
	if not playerData.Eggs then return 0 end

	local total = 0
	for _, count in pairs(playerData.Eggs) do
		total = total + count
	end
	return total
end

function ShopManager:CountRebirthPurchases(playerData)
	if not playerData.RebirthShop then return 0 end

	local total = 0
	for _, count in pairs(playerData.RebirthShop) do
		total = total + count
	end
	return total
end

return ShopManager
