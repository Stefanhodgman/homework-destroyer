--[[
	ToolManager.lua
	Server-side tool/weapon management system for Homework Destroyer

	Handles:
	- Tool ownership and inventory
	- Tool purchasing from shop
	- Tool upgrades using tokens
	- Tool equipping (including dual-wield)
	- Combat integration and damage calculation
	- Special effect application
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ToolManager = {}
ToolManager.__index = ToolManager

-- Module Dependencies
local ToolsConfig = require(script.Parent.ToolsConfig)
local StatsCalculator = require(script.Parent.StatsCalculator)
local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)

-- Active tool managers (one per player)
local activeManagers = {}

-- ========================================
-- CONSTRUCTOR
-- ========================================

function ToolManager.new(player, playerData)
	local self = setmetatable({}, ToolManager)

	self.Player = player
	self.PlayerData = playerData

	-- Initialize tools data if not exists
	if not self.PlayerData.Tools then
		self.PlayerData.Tools = {
			Owned = {"PencilEraser"}, -- Start with free tool
			Equipped = "PencilEraser",
			EquippedSecondary = nil,
			UpgradeLevels = {
				PencilEraser = 0
			}
		}
	end

	-- Track active special effects
	self.ActiveEffects = {}

	-- Damage tracking for boss fights
	self.BossDamageDealt = {}

	print(string.format("[ToolManager] Initialized for player %s", player.Name))
	return self
end

-- Get or create tool manager for a player
function ToolManager.Get(player)
	if not activeManagers[player] then
		warn(string.format("[ToolManager] No manager found for %s", player.Name))
		return nil
	end
	return activeManagers[player]
end

-- Initialize manager for a player
function ToolManager.Initialize(player, playerData)
	if activeManagers[player] then
		activeManagers[player]:Cleanup()
	end

	activeManagers[player] = ToolManager.new(player, playerData)
	return activeManagers[player]
end

-- ========================================
-- TOOL SHOP METHODS
-- ========================================

-- Get all tools available for purchase
function ToolManager:GetAvailableTools()
	return ToolsConfig.GetAvailableTools(
		self.PlayerData.Level,
		self.PlayerData.CurrentZone,
		self.PlayerData.RebirthLevel or 0,
		self.PlayerData.PrestigeLevel or 0
	)
end

-- Purchase a tool
function ToolManager:PurchaseTool(toolID)
	local tool = ToolsConfig.GetTool(toolID)
	if not tool then
		return false, "Tool not found"
	end

	-- Check if can purchase
	local canPurchase, reason = ToolsConfig.CanPurchaseTool(toolID, self.PlayerData)
	if not canPurchase then
		return false, reason
	end

	-- Deduct DP
	self.PlayerData.DestructionPoints = self.PlayerData.DestructionPoints - tool.Cost

	-- Add to owned tools
	table.insert(self.PlayerData.Tools.Owned, toolID)

	-- Initialize upgrade level
	self.PlayerData.Tools.UpgradeLevels[toolID] = 0

	-- Log purchase
	print(string.format("[ToolManager] %s purchased %s for %d DP",
		self.Player.Name, tool.Name, tool.Cost))

	-- Update client
	self:SyncToolData()

	-- Check achievements
	self:CheckToolAchievements()

	return true, string.format("Purchased %s!", tool.Name)
end

-- ========================================
-- TOOL EQUIP METHODS
-- ========================================

-- Equip a tool (primary or secondary for dual-wield)
function ToolManager:EquipTool(toolID, slotNumber)
	slotNumber = slotNumber or 1

	-- Check if tool is owned
	local isOwned = false
	for _, ownedID in ipairs(self.PlayerData.Tools.Owned) do
		if ownedID == toolID then
			isOwned = true
			break
		end
	end

	if not isOwned then
		return false, "Tool not owned"
	end

	-- Check dual-wield unlock (Level 75)
	if slotNumber == 2 then
		if self.PlayerData.Level < 75 then
			return false, "Dual-wield unlocks at Level 75"
		end
	end

	-- Equip the tool
	if slotNumber == 1 then
		self.PlayerData.Tools.Equipped = toolID
	elseif slotNumber == 2 then
		self.PlayerData.Tools.EquippedSecondary = toolID
	else
		return false, "Invalid slot number (must be 1 or 2)"
	end

	-- Log equip
	local tool = ToolsConfig.GetTool(toolID)
	print(string.format("[ToolManager] %s equipped %s in slot %d",
		self.Player.Name, tool.Name, slotNumber))

	-- Update client
	self:SyncToolData()

	return true, string.format("Equipped %s!", tool.Name)
end

-- Unequip secondary tool
function ToolManager:UnequipSecondary()
	self.PlayerData.Tools.EquippedSecondary = nil
	self:SyncToolData()
	return true, "Unequipped secondary tool"
end

-- Get currently equipped tool(s)
function ToolManager:GetEquippedTools()
	local primary = ToolsConfig.GetTool(self.PlayerData.Tools.Equipped)
	local secondary = nil

	if self.PlayerData.Tools.EquippedSecondary then
		secondary = ToolsConfig.GetTool(self.PlayerData.Tools.EquippedSecondary)
	end

	return primary, secondary
end

-- ========================================
-- TOOL UPGRADE METHODS
-- ========================================

-- Upgrade a tool using tokens
function ToolManager:UpgradeTool(toolID)
	-- Check if tool is owned
	local isOwned = false
	for _, ownedID in ipairs(self.PlayerData.Tools.Owned) do
		if ownedID == toolID then
			isOwned = true
			break
		end
	end

	if not isOwned then
		return false, "Tool not owned"
	end

	-- Get current upgrade level
	local currentLevel = self.PlayerData.Tools.UpgradeLevels[toolID] or 0

	-- Check max level
	if currentLevel >= ToolsConfig.MaxUpgradeLevel then
		return false, "Tool is already at max level"
	end

	-- Get upgrade cost
	local cost = ToolsConfig.GetToolUpgradeCost(currentLevel)
	if not cost then
		return false, "Cannot upgrade further"
	end

	-- Check if player has enough tokens
	if self.PlayerData.ToolUpgradeTokens < cost then
		return false, string.format("Need %d Tool Upgrade Tokens", cost)
	end

	-- Deduct tokens
	self.PlayerData.ToolUpgradeTokens = self.PlayerData.ToolUpgradeTokens - cost

	-- Upgrade tool
	self.PlayerData.Tools.UpgradeLevels[toolID] = currentLevel + 1

	-- Log upgrade
	local tool = ToolsConfig.GetTool(toolID)
	print(string.format("[ToolManager] %s upgraded %s to level %d (cost: %d tokens)",
		self.Player.Name, tool.Name, currentLevel + 1, cost))

	-- Update client
	self:SyncToolData()

	return true, string.format("Upgraded %s to level %d!", tool.Name, currentLevel + 1)
end

-- Get upgrade info for a tool
function ToolManager:GetToolUpgradeInfo(toolID)
	local tool = ToolsConfig.GetTool(toolID)
	if not tool then
		return nil
	end

	local currentLevel = self.PlayerData.Tools.UpgradeLevels[toolID] or 0
	local cost = ToolsConfig.GetToolUpgradeCost(currentLevel)

	local currentDamage = ToolsConfig.CalculateToolDamage(tool, currentLevel)
	local nextDamage = ToolsConfig.CalculateToolDamage(tool, currentLevel + 1)

	local currentSpeed = ToolsConfig.CalculateToolSpeed(tool, currentLevel)
	local nextSpeed = ToolsConfig.CalculateToolSpeed(tool, currentLevel + 1)

	return {
		CurrentLevel = currentLevel,
		MaxLevel = ToolsConfig.MaxUpgradeLevel,
		UpgradeCost = cost,
		CurrentDamage = currentDamage,
		NextDamage = nextDamage,
		CurrentSpeed = currentSpeed,
		NextSpeed = nextSpeed,
		CanUpgrade = cost ~= nil and self.PlayerData.ToolUpgradeTokens >= cost
	}
end

-- ========================================
-- COMBAT INTEGRATION
-- ========================================

-- Calculate damage for a click/hit
function ToolManager:CalculateClickDamage(targetHomework, isCritical)
	local primaryTool = ToolsConfig.GetTool(self.PlayerData.Tools.Equipped)
	if not primaryTool then
		return 0
	end

	local upgradeLevel = self.PlayerData.Tools.UpgradeLevels[primaryTool.ID] or 0
	local baseDamage = ToolsConfig.CalculateToolDamage(primaryTool, upgradeLevel)

	-- Apply player stats multipliers
	local multipliers = StatsCalculator.CalculateDamageMultipliers(self.PlayerData, nil)
	local totalDamage = baseDamage * multipliers.total

	-- Apply critical hit
	if isCritical then
		local critMultiplier = StatsCalculator.GetCriticalMultiplier(self.PlayerData)
		totalDamage = totalDamage * critMultiplier
	end

	-- Apply tool-specific bonuses
	if primaryTool.SpecialEffect then
		totalDamage = self:ApplySpecialEffectDamage(totalDamage, primaryTool, targetHomework)
	end

	-- Apply rarity crit bonus
	local rarity = ToolsConfig.Rarities[primaryTool.Rarity]
	if rarity.CritBonus > 0 and isCritical then
		totalDamage = totalDamage * (1 + rarity.CritBonus)
	end

	-- If dual-wielding, add secondary weapon damage
	if self.PlayerData.Tools.EquippedSecondary then
		local secondaryDamage = self:CalculateSecondaryDamage(targetHomework, isCritical)
		totalDamage = totalDamage + secondaryDamage
	end

	return math.floor(totalDamage)
end

-- Calculate secondary weapon damage (for dual-wield)
function ToolManager:CalculateSecondaryDamage(targetHomework, isCritical)
	local secondaryTool = ToolsConfig.GetTool(self.PlayerData.Tools.EquippedSecondary)
	if not secondaryTool then
		return 0
	end

	local upgradeLevel = self.PlayerData.Tools.UpgradeLevels[secondaryTool.ID] or 0
	local baseDamage = ToolsConfig.CalculateToolDamage(secondaryTool, upgradeLevel)

	-- Secondary weapon deals 50% damage
	baseDamage = baseDamage * 0.5

	-- Apply player stats multipliers
	local multipliers = StatsCalculator.CalculateDamageMultipliers(self.PlayerData, nil)
	local totalDamage = baseDamage * multipliers.total

	-- Apply critical hit
	if isCritical then
		local critMultiplier = StatsCalculator.GetCriticalMultiplier(self.PlayerData)
		totalDamage = totalDamage * critMultiplier
	end

	return math.floor(totalDamage)
end

-- Apply special effect damage modifications
function ToolManager:ApplySpecialEffectDamage(baseDamage, tool, targetHomework)
	local effect = tool.SpecialEffect
	if not effect then
		return baseDamage
	end

	-- Type-based bonuses
	if effect.Type == "TypeBonus" and targetHomework then
		if targetHomework.Type == effect.Target then
			baseDamage = baseDamage * (1 + effect.Bonus)
		end
	end

	-- Zone-based bonuses
	if effect.Type == "ZoneBonus" then
		-- Would need zone data to apply this
		-- For now, just return base damage
	end

	-- Boss damage bonus
	if effect.Type == "BossEffect" and targetHomework then
		if targetHomework.IsBoss then
			baseDamage = baseDamage * (1 + effect.BossDamageBonus)
		end
	end

	-- Mark bonus (if target is marked)
	if effect.Type == "Mark" then
		if self.ActiveEffects[targetHomework] and self.ActiveEffects[targetHomework].Marked then
			baseDamage = baseDamage * (1 + effect.Bonus)
		end
	end

	return baseDamage
end

-- Apply special effects on click
function ToolManager:ApplySpecialEffects(targetHomework, damage)
	local primaryTool = ToolsConfig.GetTool(self.PlayerData.Tools.Equipped)
	if not primaryTool or not primaryTool.SpecialEffect then
		return
	end

	local effect = primaryTool.SpecialEffect

	-- Instant kill chance
	if effect.Type == "InstantKill" then
		if targetHomework.Type == effect.Target and not targetHomework.IsBoss then
			if math.random() <= effect.Chance then
				-- Signal instant kill
				return "InstantKill"
			end
		end
	end

	-- Mark effect
	if effect.Type == "Mark" then
		self:MarkTarget(targetHomework, effect.Duration)
	end

	-- Damage over time
	if effect.Type == "DamageOverTime" then
		self:ApplyDOT(targetHomework, effect.DPS, effect.Duration)
	end

	-- Corrode effect
	if effect.Type == "Corrode" then
		self:ApplyCorrode(targetHomework, effect.HPReduction, effect.Duration)
	end

	-- Stun effect (bosses)
	if effect.Type == "BossEffect" and targetHomework.IsBoss then
		if effect.StunDuration then
			self:StunTarget(targetHomework, effect.StunDuration)
		end
	end

	return nil
end

-- Mark a target for bonus damage
function ToolManager:MarkTarget(target, duration)
	if not self.ActiveEffects[target] then
		self.ActiveEffects[target] = {}
	end

	self.ActiveEffects[target].Marked = true

	-- Remove mark after duration
	task.delay(duration, function()
		if self.ActiveEffects[target] then
			self.ActiveEffects[target].Marked = false
		end
	end)
end

-- Apply damage over time
function ToolManager:ApplyDOT(target, dps, duration)
	local endTime = tick() + duration
	local connection

	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if tick() >= endTime or not target or not target.Parent then
			connection:Disconnect()
			return
		end

		-- Apply DOT damage (would integrate with homework health system)
		if target:FindFirstChild("Health") then
			target.Health.Value = target.Health.Value - (dps * 0.1) -- Heartbeat is ~60fps
		end
	end)
end

-- Apply corrode effect
function ToolManager:ApplyCorrode(target, hpReduction, duration)
	if not target:FindFirstChild("Health") then
		return
	end

	local totalReduction = target.Health.Value * hpReduction
	local reductionPerTick = totalReduction / (duration * 10) -- 10 ticks per second

	local endTime = tick() + duration
	local connection

	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if tick() >= endTime or not target or not target.Parent then
			connection:Disconnect()
			return
		end

		target.Health.Value = target.Health.Value - reductionPerTick
	end)
end

-- Stun a target
function ToolManager:StunTarget(target, duration)
	-- Set stunned attribute
	target:SetAttribute("Stunned", true)

	task.delay(duration, function()
		if target and target.Parent then
			target:SetAttribute("Stunned", false)
		end
	end)
end

-- Get critical hit chance
function ToolManager:GetCriticalChance()
	local primaryTool = ToolsConfig.GetTool(self.PlayerData.Tools.Equipped)
	if not primaryTool then
		return 0.05 -- Base 5%
	end

	return StatsCalculator.GetCriticalChance(self.PlayerData, {
		CritChance = ToolsConfig.Rarities[primaryTool.Rarity].CritBonus
	})
end

-- Check if a click should be a critical hit
function ToolManager:RollCritical()
	local critChance = self:GetCriticalChance()
	return math.random() <= critChance
end

-- ========================================
-- MULTI-TARGET EFFECTS
-- ========================================

-- Get additional targets for multi-hit tools
function ToolManager:GetAdditionalTargets(primaryTarget, allTargets)
	local primaryTool = ToolsConfig.GetTool(self.PlayerData.Tools.Equipped)
	if not primaryTool or not primaryTool.SpecialEffect then
		return {}
	end

	local effect = primaryTool.SpecialEffect
	local additionalTargets = {}

	-- Multi-hit (hits multiple targets at once)
	if effect.Type == "MultiHit" and effect.Targets then
		local count = 0
		for _, target in ipairs(allTargets) do
			if target ~= primaryTarget and count < effect.Targets - 1 then
				table.insert(additionalTargets, target)
				count = count + 1
			end
		end
	end

	-- Chain lightning (bounces to nearby targets)
	if effect.Type == "ChainLightning" and effect.Targets then
		local count = 0
		for _, target in ipairs(allTargets) do
			if target ~= primaryTarget and count < effect.Targets then
				table.insert(additionalTargets, {
					Target = target,
					DamageMultiplier = effect.DamagePercent
				})
				count = count + 1
			end
		end
	end

	-- Bounce (bounces between targets)
	if effect.Type == "Bounce" and effect.BounceTargets then
		local count = 0
		for _, target in ipairs(allTargets) do
			if target ~= primaryTarget and count < effect.BounceTargets - 1 then
				table.insert(additionalTargets, target)
				count = count + 1
			end
		end
	end

	return additionalTargets
end

-- ========================================
-- DATA SYNC
-- ========================================

-- Sync tool data to client
function ToolManager:SyncToolData()
	local dataUpdate = RemoteEvents.GetEvent("DataUpdate")
	if dataUpdate then
		dataUpdate:FireClient(self.Player, "Tools", self.PlayerData.Tools)
		dataUpdate:FireClient(self.Player, "ToolUpgradeTokens", self.PlayerData.ToolUpgradeTokens)
	end
end

-- ========================================
-- ACHIEVEMENTS
-- ========================================

-- Check tool-related achievements
function ToolManager:CheckToolAchievements()
	local ownedCount = #self.PlayerData.Tools.Owned
	local totalTools = ToolsConfig.GetTotalToolCount()

	-- Tool Collector: Own 5 different tools
	if ownedCount >= 5 and not self.PlayerData.Achievements.ToolCollector then
		self:UnlockAchievement("ToolCollector")
	end

	-- Arsenal Builder: Own 10 different tools
	if ownedCount >= 10 and not self.PlayerData.Achievements.ArsenalBuilder then
		self:UnlockAchievement("ArsenalBuilder")
	end

	-- Weapon Master: Own all tools
	if ownedCount >= totalTools and not self.PlayerData.Achievements.WeaponMaster then
		self:UnlockAchievement("WeaponMaster")
	end
end

-- Unlock achievement
function ToolManager:UnlockAchievement(achievementID)
	self.PlayerData.Achievements[achievementID] = os.time()

	local unlockEvent = RemoteEvents.GetEvent("UnlockAchievement")
	if unlockEvent then
		unlockEvent:FireClient(self.Player, achievementID, {})
	end

	print(string.format("[ToolManager] %s unlocked achievement: %s", self.Player.Name, achievementID))
end

-- ========================================
-- BOSS DROP SYSTEM
-- ========================================

-- Handle boss defeat and check for tool drops
function ToolManager:OnBossDefeated(bossName)
	-- Check all tools for boss drop requirements
	for toolID, tool in pairs(ToolsConfig.Tools) do
		if tool.RequiresBossDrop and tool.RequiresBossDrop.BossName == bossName then
			-- Check if already owned
			local isOwned = false
			for _, ownedID in ipairs(self.PlayerData.Tools.Owned) do
				if ownedID == toolID then
					isOwned = true
					break
				end
			end

			if not isOwned then
				-- Roll for drop
				if math.random() <= tool.RequiresBossDrop.DropChance then
					-- Grant tool
					table.insert(self.PlayerData.Tools.Owned, toolID)
					self.PlayerData.Tools.UpgradeLevels[toolID] = 0

					-- Notify player
					local notification = RemoteEvents.GetEvent("ShowNotification")
					if notification then
						notification:FireClient(self.Player, "Legendary",
							"BOSS DROP!",
							string.format("You received %s!", tool.Name),
							10)
					end

					print(string.format("[ToolManager] %s received %s from boss drop!",
						self.Player.Name, tool.Name))

					self:SyncToolData()
				end
			end
		end
	end
end

-- ========================================
-- CLEANUP
-- ========================================

function ToolManager:Cleanup()
	-- Clear active effects
	for target, effects in pairs(self.ActiveEffects) do
		effects = nil
	end

	self.ActiveEffects = {}
	self.BossDamageDealt = {}

	print(string.format("[ToolManager] Cleaned up for player %s", self.Player.Name))
end

-- Remove manager when player leaves
game.Players.PlayerRemoving:Connect(function(player)
	if activeManagers[player] then
		activeManagers[player]:Cleanup()
		activeManagers[player] = nil
	end
end)

-- ========================================
-- REMOTE EVENT HANDLERS
-- ========================================

-- Handle tool purchase requests
local purchaseToolEvent = RemoteEvents.GetEvent("PurchaseTool")
if purchaseToolEvent then
	purchaseToolEvent.OnServerEvent:Connect(function(player, toolID)
		local manager = ToolManager.Get(player)
		if manager then
			local success, message = manager:PurchaseTool(toolID)

			local notification = RemoteEvents.GetEvent("ShowNotification")
			if notification then
				notification:FireClient(player, success and "Success" or "Error",
					success and "Tool Purchased!" or "Purchase Failed",
					message,
					3)
			end
		end
	end)
end

-- Handle tool equip requests
local equipToolEvent = RemoteEvents.GetEvent("EquipTool")
if equipToolEvent then
	equipToolEvent.OnServerEvent:Connect(function(player, toolID, slotNumber)
		local manager = ToolManager.Get(player)
		if manager then
			local success, message = manager:EquipTool(toolID, slotNumber)

			local notification = RemoteEvents.GetEvent("ShowNotification")
			if notification then
				notification:FireClient(player, success and "Success" or "Error",
					success and "Tool Equipped!" or "Equip Failed",
					message,
					2)
			end
		end
	end)
end

-- Handle tool upgrade requests
local upgradeToolEvent = RemoteEvents.GetEvent("UpgradeTool")
if upgradeToolEvent then
	upgradeToolEvent.OnServerEvent:Connect(function(player, toolID)
		local manager = ToolManager.Get(player)
		if manager then
			local success, message = manager:UpgradeTool(toolID)

			local notification = RemoteEvents.GetEvent("ShowNotification")
			if notification then
				notification:FireClient(player, success and "Success" or "Error",
					success and "Tool Upgraded!" or "Upgrade Failed",
					message,
					3)
			end
		end
	end)
end

return ToolManager
