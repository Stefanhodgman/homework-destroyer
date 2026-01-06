--[[
	GamepassManager.lua
	Gamepass system for Homework Destroyer

	Handles:
	- Gamepass purchases and validation
	- Gamepass bonuses and perks
	- Premium benefits
	- Developer product purchases
	- Special bundles

	Integration with ShopManager and core game systems
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GamepassManager = {}
GamepassManager.__index = GamepassManager

-- ========================================
-- GAMEPASS DEFINITIONS
-- ========================================

GamepassManager.Gamepasses = {
	{
		ID = 12345678, -- Replace with actual gamepass ID
		InternalID = "VIPPass",
		Name = "VIP Pass",
		Description = "Unlock exclusive VIP benefits!",
		Price = 299,
		Icon = "rbxassetid://VIP_ICON",
		Benefits = {
			"x1.5 DP Multiplier",
			"x1.25 EXP Multiplier",
			"+2 Pet Equip Slots",
			"VIP Chat Tag",
			"Exclusive VIP Zone Access",
			"Daily VIP Reward (1000 Gems)",
		},
		BonusStats = {
			DPMultiplier = 1.5,
			EXPMultiplier = 1.25,
			PetSlots = 2,
			DailyGems = 1000,
		},
	},
	{
		ID = 12345679,
		InternalID = "AutoClicker",
		Name = "Auto-Clicker",
		Description = "Automatically click for you 24/7!",
		Price = 199,
		Icon = "rbxassetid://AUTO_CLICKER_ICON",
		Benefits = {
			"Auto-click at 5 clicks/second",
			"Works even when AFK",
			"Auto-clicks deal 75% damage",
			"Stackable with rebirth auto-click",
		},
		BonusStats = {
			AutoClickRate = 5,
			AutoClickDamage = 0.75,
			WorksWhenAFK = true,
		},
	},
	{
		ID = 12345680,
		InternalID = "DoubleDP",
		Name = "2x DP",
		Description = "Permanently earn 2x Destruction Points!",
		Price = 449,
		Icon = "rbxassetid://DOUBLE_DP_ICON",
		Benefits = {
			"x2 DP from all sources",
			"x2 DP from bosses",
			"x2 DP from quests",
			"Stacks with VIP and other bonuses",
		},
		BonusStats = {
			DPMultiplier = 2.0,
		},
	},
	{
		ID = 12345681,
		InternalID = "InstantRebirth",
		Name = "Instant Rebirth",
		Description = "Rebirth instantly with no cooldown!",
		Price = 249,
		Icon = "rbxassetid://INSTANT_REBIRTH_ICON",
		Benefits = {
			"Instant rebirth (no waiting)",
			"No rebirth cooldown",
			"+1 Rebirth Token per rebirth",
			"Rebirth anywhere in the game",
		},
		BonusStats = {
			InstantRebirth = true,
			BonusRebirthToken = 1,
		},
	},
	{
		ID = 12345682,
		InternalID = "LuckyEggs",
		Name = "Lucky Eggs",
		Description = "Massively increased egg luck!",
		Price = 399,
		Icon = "rbxassetid://LUCKY_EGGS_ICON",
		Benefits = {
			"+50% better rarity chances",
			"10% chance for bonus pet on hatch",
			"Guaranteed rare or better from basic eggs",
			"Exclusive shiny pet variants",
		},
		BonusStats = {
			EggLuckMultiplier = 1.5,
			BonusPetChance = 0.10,
			MinimumRarity = "Rare",
		},
	},
	{
		ID = 12345683,
		InternalID = "TriplePetSlots",
		Name = "Triple Pet Slots",
		Description = "Equip 3 extra pets at once!",
		Price = 349,
		Icon = "rbxassetid://PET_SLOTS_ICON",
		Benefits = {
			"+3 Pet Equip Slots",
			"Massive power boost",
			"More synergies available",
			"Stackable with VIP slots",
		},
		BonusStats = {
			PetSlots = 3,
		},
	},
	{
		ID = 12345684,
		InternalID = "BossHunter",
		Name = "Boss Hunter",
		Description = "Enhanced boss rewards and spawns!",
		Price = 299,
		Icon = "rbxassetid://BOSS_HUNTER_ICON",
		Benefits = {
			"x2 Boss spawn rate",
			"x3 Boss rewards",
			"Boss spawn notifications",
			"Exclusive boss skins",
		},
		BonusStats = {
			BossSpawnRate = 2.0,
			BossRewardMultiplier = 3.0,
			BossNotifications = true,
		},
	},
}

-- ========================================
-- DEVELOPER PRODUCTS (CONSUMABLES)
-- ========================================

GamepassManager.DeveloperProducts = {
	{
		ID = 1234567890,
		InternalID = "Gems_Small",
		Name = "Small Gem Pack",
		Description = "100 Gems",
		Price = 49,
		Icon = "rbxassetid://GEMS_SMALL_ICON",
		Reward = {Type = "Currency", Currency = "Gems", Amount = 100},
	},
	{
		ID = 1234567891,
		InternalID = "Gems_Medium",
		Name = "Medium Gem Pack",
		Description = "500 Gems (+50 Bonus!)",
		Price = 199,
		Icon = "rbxassetid://GEMS_MEDIUM_ICON",
		Reward = {Type = "Currency", Currency = "Gems", Amount = 550},
		BonusPercent = 10,
	},
	{
		ID = 1234567892,
		InternalID = "Gems_Large",
		Name = "Large Gem Pack",
		Description = "1500 Gems (+300 Bonus!)",
		Price = 499,
		Icon = "rbxassetid://GEMS_LARGE_ICON",
		Reward = {Type = "Currency", Currency = "Gems", Amount = 1800},
		BonusPercent = 20,
		PopularTag = true,
	},
	{
		ID = 1234567893,
		InternalID = "Gems_Mega",
		Name = "Mega Gem Pack",
		Description = "5000 Gems (+1500 Bonus!)",
		Price = 1499,
		Icon = "rbxassetid://GEMS_MEGA_ICON",
		Reward = {Type = "Currency", Currency = "Gems", Amount = 6500},
		BonusPercent = 30,
		BestValueTag = true,
	},
	{
		ID = 1234567894,
		InternalID = "DP_Boost",
		Name = "DP Boost (1 Hour)",
		Description = "x2 DP for 1 hour!",
		Price = 99,
		Icon = "rbxassetid://DP_BOOST_ICON",
		Reward = {Type = "Boost", BoostType = "DP", Multiplier = 2.0, Duration = 3600},
	},
	{
		ID = 1234567895,
		InternalID = "XP_Boost",
		Name = "XP Boost (1 Hour)",
		Description = "x2 XP for 1 hour!",
		Price = 99,
		Icon = "rbxassetid://XP_BOOST_ICON",
		Reward = {Type = "Boost", BoostType = "XP", Multiplier = 2.0, Duration = 3600},
	},
	{
		ID = 1234567896,
		InternalID = "LegendaryEgg",
		Name = "Legendary Egg",
		Description = "Guaranteed legendary pet!",
		Price = 299,
		Icon = "rbxassetid://LEGENDARY_EGG_PRODUCT_ICON",
		Reward = {Type = "Egg", EggID = "LegendaryEgg", Quantity = 1},
	},
	{
		ID = 1234567897,
		InternalID = "ToolUpgradeBundle",
		Name = "Tool Upgrade Bundle",
		Description = "10 Tool Upgrade Tokens!",
		Price = 149,
		Icon = "rbxassetid://TOOL_TOKENS_ICON",
		Reward = {Type = "Currency", Currency = "ToolUpgradeTokens", Amount = 10},
	},
}

-- ========================================
-- INITIALIZATION
-- ========================================

function GamepassManager.new()
	local self = setmetatable({}, GamepassManager)

	self.gamepassCache = {} -- Cache player gamepass ownership
	self.activeBoosts = {} -- Track active boost effects
	self.purchaseCallbacks = {} -- Callbacks for purchase completion

	self:SetupMarketplaceEvents()

	return self
end

-- ========================================
-- MARKETPLACE EVENTS
-- ========================================

function GamepassManager:SetupMarketplaceEvents()
	-- Process receipt for developer products
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		return self:ProcessPurchase(receiptInfo)
	end

	-- Prompt purchase finished
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
		if wasPurchased then
			self:OnGamepassPurchased(player, gamepassId)
		end
	end)

	MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
		local player = Players:GetPlayerByUserId(userId)
		if player and wasPurchased then
			print(string.format("[GAMEPASS] Product %d purchased by %s", productId, player.Name))
		end
	end)
end

-- ========================================
-- GAMEPASS FUNCTIONS
-- ========================================

function GamepassManager:GetGamepassInfo(internalID)
	for _, gamepass in ipairs(self.Gamepasses) do
		if gamepass.InternalID == internalID then
			return gamepass
		end
	end
	return nil
end

function GamepassManager:GetGamepassByID(gamepassID)
	for _, gamepass in ipairs(self.Gamepasses) do
		if gamepass.ID == gamepassID then
			return gamepass
		end
	end
	return nil
end

function GamepassManager:PlayerOwnsGamepass(player, internalID)
	local userId = player.UserId

	-- Check cache first
	if self.gamepassCache[userId] and self.gamepassCache[userId][internalID] ~= nil then
		return self.gamepassCache[userId][internalID]
	end

	local gamepass = self:GetGamepassInfo(internalID)
	if not gamepass then
		warn("[GAMEPASS] Unknown gamepass: " .. tostring(internalID))
		return false
	end

	-- Check ownership via MarketplaceService
	local success, ownsGamepass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, gamepass.ID)
	end)

	if not success then
		warn("[GAMEPASS] Error checking ownership for " .. player.Name .. ": " .. tostring(ownsGamepass))
		return false
	end

	-- Cache result
	if not self.gamepassCache[userId] then
		self.gamepassCache[userId] = {}
	end
	self.gamepassCache[userId][internalID] = ownsGamepass

	return ownsGamepass
end

function GamepassManager:PromptGamepassPurchase(player, internalID)
	local gamepass = self:GetGamepassInfo(internalID)
	if not gamepass then
		return false, "Gamepass not found"
	end

	-- Check if already owned
	if self:PlayerOwnsGamepass(player, internalID) then
		return false, "Already owned"
	end

	-- Prompt purchase
	local success, err = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, gamepass.ID)
	end)

	if not success then
		warn("[GAMEPASS] Error prompting purchase: " .. tostring(err))
		return false, "Purchase prompt failed"
	end

	return true, "Purchase prompted"
end

function GamepassManager:OnGamepassPurchased(player, gamepassID)
	local gamepass = self:GetGamepassByID(gamepassID)
	if not gamepass then
		return
	end

	-- Clear cache
	if self.gamepassCache[player.UserId] then
		self.gamepassCache[player.UserId][gamepass.InternalID] = true
	end

	-- Update player data
	local playerData = self:GetPlayerData(player)
	if playerData then
		if not playerData.Gamepasses then
			playerData.Gamepasses = {}
		end
		playerData.Gamepasses[gamepass.InternalID] = true
	end

	-- Apply immediate benefits
	self:ApplyGamepassBenefits(player, gamepass.InternalID)

	-- Notify player
	print(string.format("[GAMEPASS] %s purchased %s", player.Name, gamepass.Name))

	return true
end

function GamepassManager:ApplyGamepassBenefits(player, internalID)
	local gamepass = self:GetGamepassInfo(internalID)
	if not gamepass then return end

	local playerData = self:GetPlayerData(player)
	if not playerData then return end

	-- Apply one-time benefits
	if gamepass.BonusStats then
		-- Pet slots
		if gamepass.BonusStats.PetSlots then
			playerData.Pets.MaxSlots = (playerData.Pets.MaxSlots or 3) + gamepass.BonusStats.PetSlots
		end

		-- Daily rewards (handled by daily reward system)
		if gamepass.BonusStats.DailyGems then
			-- This will be checked by the daily reward system
		end
	end

	print(string.format("[GAMEPASS] Applied benefits for %s to %s", internalID, player.Name))
end

function GamepassManager:GetAllGamepassesForPlayer(player)
	local gamepasses = {}

	for _, gamepass in ipairs(self.Gamepasses) do
		local owned = self:PlayerOwnsGamepass(player, gamepass.InternalID)

		table.insert(gamepasses, {
			ID = gamepass.InternalID,
			GamepassID = gamepass.ID,
			Name = gamepass.Name,
			Description = gamepass.Description,
			Price = gamepass.Price,
			Icon = gamepass.Icon,
			Benefits = gamepass.Benefits,
			Owned = owned,
		})
	end

	return gamepasses
end

-- ========================================
-- BONUS CALCULATIONS
-- ========================================

function GamepassManager:GetPlayerMultipliers(player)
	local multipliers = {
		DP = 1.0,
		EXP = 1.0,
		AutoClickRate = 0,
		AutoClickDamage = 0,
		EggLuck = 1.0,
		BossRewards = 1.0,
		BossSpawnRate = 1.0,
	}

	-- Check each gamepass and apply bonuses
	for _, gamepass in ipairs(self.Gamepasses) do
		if self:PlayerOwnsGamepass(player, gamepass.InternalID) then
			local stats = gamepass.BonusStats

			if stats.DPMultiplier then
				multipliers.DP = multipliers.DP * stats.DPMultiplier
			end

			if stats.EXPMultiplier then
				multipliers.EXP = multipliers.EXP * stats.EXPMultiplier
			end

			if stats.AutoClickRate then
				multipliers.AutoClickRate = multipliers.AutoClickRate + stats.AutoClickRate
			end

			if stats.AutoClickDamage then
				multipliers.AutoClickDamage = math.max(multipliers.AutoClickDamage, stats.AutoClickDamage)
			end

			if stats.EggLuckMultiplier then
				multipliers.EggLuck = multipliers.EggLuck * stats.EggLuckMultiplier
			end

			if stats.BossRewardMultiplier then
				multipliers.BossRewards = multipliers.BossRewards * stats.BossRewardMultiplier
			end

			if stats.BossSpawnRate then
				multipliers.BossSpawnRate = multipliers.BossSpawnRate * stats.BossSpawnRate
			end
		end
	end

	-- Apply active boosts
	local activeBoosts = self:GetActiveBoosts(player)
	for _, boost in ipairs(activeBoosts) do
		if boost.BoostType == "DP" then
			multipliers.DP = multipliers.DP * boost.Multiplier
		elseif boost.BoostType == "XP" then
			multipliers.EXP = multipliers.EXP * boost.Multiplier
		end
	end

	return multipliers
end

function GamepassManager:HasInstantRebirth(player)
	return self:PlayerOwnsGamepass(player, "InstantRebirth")
end

function GamepassManager:GetExtraPetSlots(player)
	local extraSlots = 0

	for _, gamepass in ipairs(self.Gamepasses) do
		if self:PlayerOwnsGamepass(player, gamepass.InternalID) then
			if gamepass.BonusStats and gamepass.BonusStats.PetSlots then
				extraSlots = extraSlots + gamepass.BonusStats.PetSlots
			end
		end
	end

	return extraSlots
end

function GamepassManager:GetAutoClickRate(player)
	local rate = 0

	for _, gamepass in ipairs(self.Gamepasses) do
		if self:PlayerOwnsGamepass(player, gamepass.InternalID) then
			if gamepass.BonusStats and gamepass.BonusStats.AutoClickRate then
				rate = rate + gamepass.BonusStats.AutoClickRate
			end
		end
	end

	return rate
end

function GamepassManager:GetAutoClickDamagePercent(player)
	local percent = 0

	for _, gamepass in ipairs(self.Gamepasses) do
		if self:PlayerOwnsGamepass(player, gamepass.InternalID) then
			if gamepass.BonusStats and gamepass.BonusStats.AutoClickDamage then
				percent = math.max(percent, gamepass.BonusStats.AutoClickDamage)
			end
		end
	end

	return percent
end

-- ========================================
-- DEVELOPER PRODUCTS
-- ========================================

function GamepassManager:GetProductInfo(internalID)
	for _, product in ipairs(self.DeveloperProducts) do
		if product.InternalID == internalID then
			return product
		end
	end
	return nil
end

function GamepassManager:GetProductByID(productID)
	for _, product in ipairs(self.DeveloperProducts) do
		if product.ID == productID then
			return product
		end
	end
	return nil
end

function GamepassManager:PromptProductPurchase(player, internalID)
	local product = self:GetProductInfo(internalID)
	if not product then
		return false, "Product not found"
	end

	local success, err = pcall(function()
		MarketplaceService:PromptProductPurchase(player, product.ID)
	end)

	if not success then
		warn("[GAMEPASS] Error prompting product purchase: " .. tostring(err))
		return false, "Purchase prompt failed"
	end

	return true, "Purchase prompted"
end

function GamepassManager:ProcessPurchase(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	-- Find player
	local player = Players:GetPlayerByUserId(userId)
	if not player then
		-- Player left, grant on next join
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Get product info
	local product = self:GetProductByID(productId)
	if not product then
		warn("[GAMEPASS] Unknown product ID: " .. tostring(productId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Grant reward
	local success = self:GrantProductReward(player, product)

	if success then
		print(string.format("[GAMEPASS] Granted %s to %s", product.Name, player.Name))
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn(string.format("[GAMEPASS] Failed to grant %s to %s", product.Name, player.Name))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

function GamepassManager:GrantProductReward(player, product)
	local playerData = self:GetPlayerData(player)
	if not playerData then
		return false
	end

	local reward = product.Reward

	if reward.Type == "Currency" then
		-- Grant currency
		if reward.Currency == "Gems" then
			playerData.Gems = (playerData.Gems or 0) + reward.Amount
		elseif reward.Currency == "DestructionPoints" then
			playerData.DestructionPoints = playerData.DestructionPoints + reward.Amount
		elseif reward.Currency == "ToolUpgradeTokens" then
			playerData.ToolUpgradeTokens = (playerData.ToolUpgradeTokens or 0) + reward.Amount
		end

	elseif reward.Type == "Boost" then
		-- Apply boost
		self:ApplyBoost(player, reward.BoostType, reward.Multiplier, reward.Duration)

	elseif reward.Type == "Egg" then
		-- Grant egg
		if not playerData.Eggs then
			playerData.Eggs = {}
		end
		playerData.Eggs[reward.EggID] = (playerData.Eggs[reward.EggID] or 0) + reward.Quantity
	end

	-- Notify player
	self:NotifyPlayer(player, "success", string.format("Received %s!", product.Name))

	return true
end

-- ========================================
-- BOOST SYSTEM
-- ========================================

function GamepassManager:ApplyBoost(player, boostType, multiplier, duration)
	local userId = player.UserId

	if not self.activeBoosts[userId] then
		self.activeBoosts[userId] = {}
	end

	local boost = {
		BoostType = boostType,
		Multiplier = multiplier,
		StartTime = os.time(),
		Duration = duration,
		EndTime = os.time() + duration,
	}

	table.insert(self.activeBoosts[userId], boost)

	-- Schedule boost removal
	task.delay(duration, function()
		self:RemoveBoost(player, boost)
	end)

	self:NotifyPlayer(player, "success", string.format("%dx %s Boost Active! (%d min)", multiplier, boostType, math.floor(duration / 60)))

	print(string.format("[GAMEPASS] Applied %s boost to %s for %d seconds", boostType, player.Name, duration))
end

function GamepassManager:RemoveBoost(player, boost)
	local userId = player.UserId

	if not self.activeBoosts[userId] then return end

	for i, activeBoost in ipairs(self.activeBoosts[userId]) do
		if activeBoost == boost then
			table.remove(self.activeBoosts[userId], i)
			break
		end
	end

	self:NotifyPlayer(player, "info", string.format("%s Boost Expired", boost.BoostType))
end

function GamepassManager:GetActiveBoosts(player)
	local userId = player.UserId
	local currentTime = os.time()

	if not self.activeBoosts[userId] then
		return {}
	end

	-- Filter expired boosts
	local activeBoosts = {}
	for _, boost in ipairs(self.activeBoosts[userId]) do
		if boost.EndTime > currentTime then
			table.insert(activeBoosts, boost)
		end
	end

	return activeBoosts
end

function GamepassManager:GetBoostTimeRemaining(player, boostType)
	local currentTime = os.time()
	local boosts = self:GetActiveBoosts(player)

	for _, boost in ipairs(boosts) do
		if boost.BoostType == boostType then
			return math.max(0, boost.EndTime - currentTime)
		end
	end

	return 0
end

-- ========================================
-- PREMIUM BENEFITS
-- ========================================

function GamepassManager:IsPremiumMember(player)
	-- Check if player has Roblox Premium
	local success, isPremium = pcall(function()
		return player.MembershipType == Enum.MembershipType.Premium
	end)

	if not success then
		return false
	end

	return isPremium
end

function GamepassManager:GetPremiumBenefits()
	return {
		"x1.25 DP Multiplier",
		"x1.15 EXP Multiplier",
		"+1 Pet Equip Slot",
		"Daily Premium Reward (500 Gems)",
		"Exclusive Premium Pets",
		"Premium Chat Badge",
	}
end

function GamepassManager:GetPremiumMultipliers(player)
	if self:IsPremiumMember(player) then
		return {
			DP = 1.25,
			EXP = 1.15,
			PetSlots = 1,
			DailyGems = 500,
		}
	end

	return {
		DP = 1.0,
		EXP = 1.0,
		PetSlots = 0,
		DailyGems = 0,
	}
end

-- ========================================
-- PLAYER DATA HELPERS
-- ========================================

function GamepassManager:GetPlayerData(player)
	-- This should integrate with your DataManager
	-- For now, return a placeholder
	local ServerScriptService = game:GetService("ServerScriptService")
	local DataManager = require(ServerScriptService.DataManager)

	return DataManager:GetPlayerData(player)
end

function GamepassManager:NotifyPlayer(player, notificationType, message)
	-- Send notification to client
	local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
	local remotes = RemoteEvents.Get()

	if remotes.ShowNotification then
		remotes.ShowNotification:FireClient(player, notificationType, "Shop", message, 5)
	end
end

-- ========================================
-- ANALYTICS & LOGGING
-- ========================================

function GamepassManager:LogPurchase(player, itemType, itemID, price)
	print(string.format("[GAMEPASS] %s purchased %s '%s' for %d Robux",
		player.Name,
		itemType,
		itemID,
		price
	))

	-- Here you could send to analytics service
end

-- ========================================
-- PLAYER JOIN/LEAVE HANDLERS
-- ========================================

function GamepassManager:OnPlayerJoined(player)
	-- Initialize cache
	self.gamepassCache[player.UserId] = {}
	self.activeBoosts[player.UserId] = {}

	-- Check all gamepasses
	for _, gamepass in ipairs(self.Gamepasses) do
		self:PlayerOwnsGamepass(player, gamepass.InternalID)
	end

	-- Apply gamepass benefits
	self:ApplyAllGamepassBenefits(player)
end

function GamepassManager:OnPlayerLeaving(player)
	-- Clean up cache
	self.gamepassCache[player.UserId] = nil
	self.activeBoosts[player.UserId] = nil
end

function GamepassManager:ApplyAllGamepassBenefits(player)
	for _, gamepass in ipairs(self.Gamepasses) do
		if self:PlayerOwnsGamepass(player, gamepass.InternalID) then
			self:ApplyGamepassBenefits(player, gamepass.InternalID)
		end
	end
end

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

function GamepassManager:GetAllProducts()
	return self.DeveloperProducts
end

function GamepassManager:GetAllGamepasses()
	return self.Gamepasses
end

function GamepassManager:GetPlayerGamepassCount(player)
	local count = 0

	for _, gamepass in ipairs(self.Gamepasses) do
		if self:PlayerOwnsGamepass(player, gamepass.InternalID) then
			count = count + 1
		end
	end

	return count
end

function GamepassManager:ClearCache(player)
	if player then
		self.gamepassCache[player.UserId] = {}
	else
		self.gamepassCache = {}
	end
end

-- ========================================
-- BUNDLE SYSTEM
-- ========================================

GamepassManager.Bundles = {
	{
		ID = "StarterBundle",
		Name = "Starter Bundle",
		Description = "Perfect for new players! 70% OFF!",
		Price = 299,
		OriginalPrice = 997,
		Icon = "rbxassetid://STARTER_BUNDLE_ICON",
		Items = {
			{Type = "Currency", Currency = "Gems", Amount = 1000},
			{Type = "Currency", Currency = "DestructionPoints", Amount = 50000},
			{Type = "Egg", EggID = "PremiumEgg", Quantity = 3},
			{Type = "Boost", BoostType = "DP", Multiplier = 2, Duration = 7200}, -- 2 hours
		},
		OneTimePurchase = true,
		RequiredLevel = 1,
	},
	{
		ID = "MegaBundle",
		Name = "Mega Power Bundle",
		Description = "Everything you need to dominate! 80% OFF!",
		Price = 999,
		OriginalPrice = 4996,
		Icon = "rbxassetid://MEGA_BUNDLE_ICON",
		Items = {
			{Type = "Currency", Currency = "Gems", Amount = 5000},
			{Type = "Currency", Currency = "ToolUpgradeTokens", Amount = 50},
			{Type = "Egg", EggID = "LegendaryEgg", Quantity = 5},
			{Type = "Egg", EggID = "MythicEgg", Quantity = 2},
			{Type = "Boost", BoostType = "DP", Multiplier = 3, Duration = 86400}, -- 24 hours
			{Type = "Boost", BoostType = "XP", Multiplier = 3, Duration = 86400}, -- 24 hours
		},
		OneTimePurchase = true,
		RequiredLevel = 25,
		PopularTag = true,
	},
}

function GamepassManager:GetAllBundles(player)
	local bundles = {}
	local playerData = self:GetPlayerData(player)

	for _, bundle in ipairs(self.Bundles) do
		local canPurchase = true
		local reason = ""

		-- Check level requirement
		if bundle.RequiredLevel and playerData.Level < bundle.RequiredLevel then
			canPurchase = false
			reason = string.format("Requires Level %d", bundle.RequiredLevel)
		end

		-- Check one-time purchase
		if bundle.OneTimePurchase then
			if playerData.PurchaseHistory and playerData.PurchaseHistory["Bundle_" .. bundle.ID] then
				canPurchase = false
				reason = "Already purchased"
			end
		end

		table.insert(bundles, {
			ID = bundle.ID,
			Name = bundle.Name,
			Description = bundle.Description,
			Price = bundle.Price,
			OriginalPrice = bundle.OriginalPrice,
			Icon = bundle.Icon,
			Items = bundle.Items,
			CanPurchase = canPurchase,
			Reason = reason,
			PopularTag = bundle.PopularTag,
			SavingsPercent = math.floor((1 - bundle.Price / bundle.OriginalPrice) * 100),
		})
	end

	return bundles
end

-- ========================================
-- MODULE SETUP
-- ========================================

-- Create singleton instance
local gamepassManager = GamepassManager.new()

-- Setup player events
Players.PlayerAdded:Connect(function(player)
	gamepassManager:OnPlayerJoined(player)
end)

Players.PlayerRemoving:Connect(function(player)
	gamepassManager:OnPlayerLeaving(player)
end)

return gamepassManager
