--[[
	BossManager.lua

	Manages boss spawning, health tracking, damage handling, and rewards
	for Homework Destroyer

	Responsibilities:
	- Spawn bosses on timers per zone
	- Track boss health and damage
	- Handle boss defeat and loot distribution
	- Manage boss instances across zones
	- Handle player participation tracking
	- Integrate with BossAI for behavior control

	Author: Homework Destroyer Team
	Version: 1.0
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BossManager = {}

-- Module dependencies
local BossConfig = require(script.Parent.BossConfig)
local BossAI = require(script.Parent.BossAI)

-- Would require these in a full implementation
-- local DataManager = require(ServerScriptService.DataManager)
-- local StatsCalculator = require(script.Parent.StatsCalculator)

-- ========================================
-- STATE MANAGEMENT
-- ========================================

-- Active boss instances: [ZoneId] = BossInstance
local ActiveBosses = {}

-- Boss spawn timers: [ZoneId] = {NextSpawn, Timer}
local SpawnTimers = {}

-- Player participation tracking: [BossId][UserId] = {Damage, LastHit}
local ParticipationData = {}

-- Configuration
local CONFIG = {
	-- Spawn settings
	MinPlayersForBoss = 0, -- Minimum players in zone to spawn boss (0 = always spawn)
	MaxBossesPerZone = 1, -- Maximum concurrent bosses per zone

	-- Participation requirements
	MinDamageForLoot = 0.01, -- Must deal at least 1% of boss health for loot
	TopDamagerBonusMultiplier = 1.5, -- Top damager gets 50% bonus rewards

	-- Health regeneration
	BossHealthRegenEnabled = false,
	BossHealthRegenRate = 0.001, -- 0.1% per second if enabled

	-- Combat settings
	DamageNumbersEnabled = true,
	BossImmunityDuration = 2, -- Seconds of immunity on spawn

	-- Respawn settings
	RespawnOnDefeat = true, -- Auto-respawn after interval
	RespawnDelay = 10, -- Seconds before starting respawn timer
}

-- ========================================
-- BOSS INSTANCE CLASS
-- ========================================

local BossInstance = {}
BossInstance.__index = BossInstance

function BossInstance.new(zoneId, bossData, rarity)
	local self = setmetatable({}, BossInstance)

	-- Boss identification
	self.Id = game:GetService("HttpService"):GenerateGUID(false)
	self.ZoneId = zoneId
	self.BossData = bossData
	self.Rarity = rarity or "Normal"

	-- Calculate stats with scaling
	local playersInZone = BossManager:GetPlayersInZone(zoneId)
	local avgLevel, avgRebirth = BossManager:GetAveragePlayerStats(playersInZone)

	local scaledStats = BossConfig.CalculateBossStats(
		bossData,
		#playersInZone,
		avgLevel,
		avgRebirth
	)

	-- Apply rarity multipliers
	local rarityData = BossConfig.Rarities[rarity]
	if rarityData.HealthMultiplier then
		scaledStats.Health = scaledStats.Health * rarityData.HealthMultiplier
	end
	if rarityData.DamageMultiplier then
		scaledStats.Damage = scaledStats.Damage * rarityData.DamageMultiplier
	end

	-- Boss stats
	self.MaxHealth = scaledStats.Health
	self.CurrentHealth = scaledStats.Health
	self.Damage = scaledStats.Damage
	self.Defense = scaledStats.Defense

	-- Boss state
	self.IsAlive = true
	self.IsImmune = true -- Starts immune
	self.SpawnTime = tick()
	self.LastDamageTime = 0
	self.CurrentPhase = 0

	-- Boss model and AI
	self.Model = nil
	self.AIController = nil

	-- Tracking
	self.DamageDealt = {} -- [UserId] = totalDamage
	self.ParticipantCount = 0
	self.TotalDamageReceived = 0

	return self
end

function BossInstance:Spawn(spawnLocation)
	-- Create boss model
	self.Model = self:CreateBossModel()
	if not self.Model then
		warn("[BossManager] Failed to create boss model for " .. self.BossData.Name)
		return false
	end

	-- Position boss
	if spawnLocation then
		self.Model:SetPrimaryPartCFrame(spawnLocation)
	end

	-- Parent to workspace
	self.Model.Parent = workspace.Bosses or workspace

	-- Initialize AI controller
	self.AIController = BossAI.CreateController(self)

	-- Set up health bar
	self:CreateHealthBar()

	-- Start immunity timer
	task.delay(CONFIG.BossImmunityDuration, function()
		if self.IsAlive then
			self.IsImmune = false
		end
	end)

	-- Announce spawn
	BossManager:AnnounceBossSpawn(self)

	-- Initialize participation tracking
	ParticipationData[self.Id] = {}

	warn("[BossManager] Spawned boss: " .. self.BossData.Name .. " (Rarity: " .. self.Rarity .. ")")
	return true
end

function BossInstance:CreateBossModel()
	-- In a real implementation, this would load the actual model
	-- For now, create a placeholder

	local model = Instance.new("Model")
	model.Name = self.BossData.Name

	-- Create main part
	local mainPart = Instance.new("Part")
	mainPart.Name = "HitBox"
	mainPart.Size = Vector3.new(10, 10, 10) * self.BossData.Scale
	mainPart.Anchored = false
	mainPart.CanCollide = true
	mainPart.BrickColor = BrickColor.new("Bright red")
	mainPart.Material = Enum.Material.Neon
	mainPart.Parent = model

	-- Set primary part
	model.PrimaryPart = mainPart

	-- Add health value for tracking
	local healthValue = Instance.new("NumberValue")
	healthValue.Name = "Health"
	healthValue.Value = self.CurrentHealth
	healthValue.Parent = model

	local maxHealthValue = Instance.new("NumberValue")
	maxHealthValue.Name = "MaxHealth"
	maxHealthValue.Value = self.MaxHealth
	maxHealthValue.Parent = model

	-- Add boss identifier
	local bossIdValue = Instance.new("StringValue")
	bossIdValue.Name = "BossId"
	bossIdValue.Value = self.Id
	bossIdValue.Parent = model

	-- Add rarity tag
	local rarityValue = Instance.new("StringValue")
	rarityValue.Name = "Rarity"
	rarityValue.Value = self.Rarity
	rarityValue.Parent = model

	-- In real implementation: Load actual model from ReplicatedStorage
	-- local actualModel = ReplicatedStorage.Models.Bosses[self.BossData.Model]:Clone()

	return model
end

function BossInstance:CreateHealthBar()
	if not self.Model or not self.Model.PrimaryPart then return end

	-- Create billboard GUI for health bar
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthBar"
	billboard.Size = UDim2.new(8, 0, 1, 0)
	billboard.StudsOffset = Vector3.new(0, self.BossData.Scale * 6, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = self.Model.PrimaryPart

	-- Background frame
	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 0.15, 0)
	background.Position = UDim2.new(0, 0, 0, 0)
	background.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	background.BorderSizePixel = 2
	background.Parent = billboard

	-- Health bar
	local healthBar = Instance.new("Frame")
	healthBar.Name = "Bar"
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BackgroundColor3 = BossConfig.Rarities[self.Rarity].HealthBarColor
	healthBar.BorderSizePixel = 0
	healthBar.Parent = background

	-- Boss name label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
	nameLabel.Position = UDim2.new(0, 0, -0.7, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = self.BossData.Name
	nameLabel.TextColor3 = BossConfig.Rarities[self.Rarity].NameColor
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Parent = billboard

	-- Health text
	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.new(1, 0, 1, 0)
	healthText.BackgroundTransparency = 1
	healthText.Text = self:GetHealthText()
	healthText.TextColor3 = Color3.new(1, 1, 1)
	healthText.TextScaled = true
	healthText.Font = Enum.Font.SourceSansBold
	healthText.TextStrokeTransparency = 0.5
	healthText.Parent = background
end

function BossInstance:GetHealthText()
	return string.format("%s / %s",
		BossManager:FormatNumber(self.CurrentHealth),
		BossManager:FormatNumber(self.MaxHealth)
	)
end

function BossInstance:UpdateHealthBar()
	if not self.Model or not self.Model.PrimaryPart then return end

	local billboard = self.Model.PrimaryPart:FindFirstChild("HealthBar")
	if not billboard then return end

	-- Update bar size
	local healthBar = billboard.Frame.Bar
	local healthPercent = self.CurrentHealth / self.MaxHealth
	healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)

	-- Update text
	local healthText = billboard.Frame.HealthText
	healthText.Text = self:GetHealthText()
end

function BossInstance:TakeDamage(damage, player)
	if not self.IsAlive or self.IsImmune then
		return false, "Boss is immune"
	end

	-- Apply defense reduction
	local defenseMultiplier = 1 - (self.Defense / 100)
	defenseMultiplier = math.max(defenseMultiplier, 0.1) -- Minimum 10% damage

	local finalDamage = math.floor(damage * defenseMultiplier)

	-- Apply damage
	self.CurrentHealth = math.max(0, self.CurrentHealth - finalDamage)
	self.LastDamageTime = tick()
	self.TotalDamageReceived = self.TotalDamageReceived + finalDamage

	-- Track player participation
	if player then
		local userId = player.UserId
		if not self.DamageDealt[userId] then
			self.DamageDealt[userId] = 0
			self.ParticipantCount = self.ParticipantCount + 1
		end
		self.DamageDealt[userId] = self.DamageDealt[userId] + finalDamage

		-- Update participation data
		ParticipationData[self.Id][userId] = {
			Damage = self.DamageDealt[userId],
			LastHit = tick(),
			Player = player,
		}
	end

	-- Update health bar
	self:UpdateHealthBar()

	-- Show damage number
	if CONFIG.DamageNumbersEnabled and player then
		BossManager:ShowDamageNumber(self.Model, finalDamage, false)
	end

	-- Check for phase transitions
	self:CheckPhaseTransition()

	-- Check if defeated
	if self.CurrentHealth <= 0 then
		self:OnDefeat()
		return true, "Boss defeated"
	end

	-- Notify AI controller of damage
	if self.AIController then
		self.AIController:OnDamaged(finalDamage, player)
	end

	return true, "Damage dealt"
end

function BossInstance:CheckPhaseTransition()
	if not self.BossData.Mechanics.Phases then return end

	local healthPercent = self.CurrentHealth / self.MaxHealth

	for i, phase in ipairs(self.BossData.Mechanics.Phases) do
		if healthPercent <= phase.HealthThreshold and self.CurrentPhase < i then
			self.CurrentPhase = i
			self:EnterPhase(phase)
			break
		end
	end
end

function BossInstance:EnterPhase(phaseData)
	warn("[BossManager] Boss " .. self.BossData.Name .. " entering phase: " .. phaseData.Name)

	-- Apply phase multipliers
	if phaseData.DamageMultiplier then
		self.Damage = self.Damage * phaseData.DamageMultiplier
	end

	if phaseData.DefenseMultiplier then
		self.Defense = self.Defense * phaseData.DefenseMultiplier
	end

	-- Announce phase change
	if phaseData.Announcement then
		BossManager:AnnounceToZone(self.ZoneId, phaseData.Announcement)
	end

	-- Notify AI controller
	if self.AIController then
		self.AIController:OnPhaseChange(phaseData)
	end
end

function BossInstance:Heal(amount)
	if not self.IsAlive then return end

	self.CurrentHealth = math.min(self.MaxHealth, self.CurrentHealth + amount)
	self:UpdateHealthBar()

	-- Show heal number
	BossManager:ShowDamageNumber(self.Model, amount, true)
end

function BossInstance:OnDefeat()
	if not self.IsAlive then return end

	self.IsAlive = false

	warn("[BossManager] Boss defeated: " .. self.BossData.Name)

	-- Distribute rewards
	self:DistributeRewards()

	-- Announce defeat
	BossManager:AnnounceBossDefeat(self)

	-- Clean up AI
	if self.AIController then
		self.AIController:OnDefeat()
	end

	-- Play defeat effects
	self:PlayDefeatEffects()

	-- Remove boss after delay
	task.delay(5, function()
		self:Destroy()
	end)

	-- Schedule respawn
	if CONFIG.RespawnOnDefeat then
		BossManager:ScheduleBossRespawn(self.ZoneId, CONFIG.RespawnDelay)
	end
end

function BossInstance:DistributeRewards()
	-- Calculate loot based on rarity
	local loot = BossConfig.CalculateLoot(self.BossData, self.Rarity, self.ParticipantCount)

	-- Find top damager
	local topDamager = nil
	local topDamage = 0

	for userId, damage in pairs(self.DamageDealt) do
		if damage > topDamage then
			topDamage = damage
			topDamager = userId
		end
	end

	-- Minimum damage threshold for rewards
	local minDamage = self.MaxHealth * CONFIG.MinDamageForLoot

	-- Distribute to participants
	for userId, damage in pairs(self.DamageDealt) do
		if damage >= minDamage then
			local participantData = ParticipationData[self.Id][userId]
			if participantData and participantData.Player then
				local player = participantData.Player

				-- Calculate participant's share
				local damagePercent = damage / self.TotalDamageReceived
				local dpReward = math.floor(loot.DP * damagePercent)
				local xpReward = math.floor(loot.XP * damagePercent)

				-- Top damager bonus
				if userId == topDamager then
					dpReward = math.floor(dpReward * CONFIG.TopDamagerBonusMultiplier)
					xpReward = math.floor(xpReward * CONFIG.TopDamagerBonusMultiplier)
				end

				-- Award rewards (would integrate with GameServer)
				BossManager:AwardPlayerRewards(player, {
					DP = dpReward,
					XP = xpReward,
					Items = userId == topDamager and loot.Items or {}, -- Only top damager gets item drops
					IsTopDamager = userId == topDamager,
					DamageDealt = damage,
					DamagePercent = damagePercent,
				})
			end
		end
	end

	-- Clean up participation data
	ParticipationData[self.Id] = nil
end

function BossInstance:PlayDefeatEffects()
	if not self.Model or not self.Model.PrimaryPart then return end

	-- Play defeat sound
	if self.BossData.DefeatSound then
		local sound = Instance.new("Sound")
		sound.SoundId = self.BossData.DefeatSound
		sound.Volume = 1
		sound.Parent = self.Model.PrimaryPart
		sound:Play()
		game:GetService("Debris"):AddItem(sound, 5)
	end

	-- Create defeat particles
	if self.BossData.ParticleEffects and self.BossData.ParticleEffects.OnDefeat then
		-- In real implementation: Create particle effects
		-- BossManager:CreateParticleEffect(self.Model.PrimaryPart, self.BossData.ParticleEffects.OnDefeat)
	end

	-- Explosion effect
	local explosion = Instance.new("Explosion")
	explosion.Position = self.Model.PrimaryPart.Position
	explosion.BlastRadius = 30
	explosion.BlastPressure = 0 -- No physics force
	explosion.Parent = workspace
end

function BossInstance:Destroy()
	-- Clean up AI
	if self.AIController then
		self.AIController:Destroy()
		self.AIController = nil
	end

	-- Remove model
	if self.Model then
		self.Model:Destroy()
		self.Model = nil
	end

	-- Remove from active bosses
	ActiveBosses[self.ZoneId] = nil

	-- Clean up participation data
	if ParticipationData[self.Id] then
		ParticipationData[self.Id] = nil
	end
end

-- ========================================
-- BOSS MANAGER FUNCTIONS
-- ========================================

function BossManager:Initialize()
	warn("[BossManager] Initializing Boss Manager...")

	-- Create workspace folder for bosses
	if not workspace:FindFirstChild("Bosses") then
		local bossesFolder = Instance.new("Folder")
		bossesFolder.Name = "Bosses"
		bossesFolder.Parent = workspace
	end

	-- Initialize spawn timers for all zones
	for zoneId = 1, 10 do
		self:InitializeZoneSpawning(zoneId)
	end

	-- Start update loop
	self:StartUpdateLoop()

	warn("[BossManager] Boss Manager initialized!")
end

function BossManager:InitializeZoneSpawning(zoneId)
	local bossData = BossConfig.GetBossForZone(zoneId)
	if not bossData then return end

	local spawnInterval = bossData.SpawnInterval

	SpawnTimers[zoneId] = {
		NextSpawn = tick() + spawnInterval, -- First spawn after interval
		Interval = spawnInterval,
		LastSpawn = 0,
	}

	warn("[BossManager] Initialized spawning for Zone " .. zoneId .. " (Interval: " .. spawnInterval .. "s)")
end

function BossManager:StartUpdateLoop()
	-- Main update loop
	RunService.Heartbeat:Connect(function(deltaTime)
		self:Update(deltaTime)
	end)
end

function BossManager:Update(deltaTime)
	-- Check spawn timers
	for zoneId, timer in pairs(SpawnTimers) do
		if tick() >= timer.NextSpawn then
			-- Check if zone already has a boss
			if not ActiveBosses[zoneId] or not ActiveBosses[zoneId].IsAlive then
				-- Check if there are players in zone
				local playersInZone = self:GetPlayersInZone(zoneId)
				if #playersInZone >= CONFIG.MinPlayersForBoss then
					self:SpawnBoss(zoneId)
				end
			end

			-- Schedule next spawn
			timer.NextSpawn = tick() + timer.Interval
		end
	end

	-- Update active bosses
	for zoneId, boss in pairs(ActiveBosses) do
		if boss.IsAlive and boss.AIController then
			boss.AIController:Update(deltaTime)
		end
	end
end

function BossManager:SpawnBoss(zoneId, forcedRarity)
	local bossData = BossConfig.GetBossForZone(zoneId)
	if not bossData then
		warn("[BossManager] No boss data for zone " .. zoneId)
		return nil
	end

	-- Check if zone already has max bosses
	if ActiveBosses[zoneId] and ActiveBosses[zoneId].IsAlive then
		return nil
	end

	-- Determine rarity
	local rarity = forcedRarity or BossConfig.DetermineBossRarity()

	-- Create boss instance
	local boss = BossInstance.new(zoneId, bossData, rarity)

	-- Get spawn location
	local spawnLocation = self:GetBossSpawnLocation(zoneId)

	-- Spawn the boss
	if boss:Spawn(spawnLocation) then
		ActiveBosses[zoneId] = boss

		-- Update spawn timer
		if SpawnTimers[zoneId] then
			SpawnTimers[zoneId].LastSpawn = tick()
		end

		return boss
	else
		return nil
	end
end

function BossManager:ScheduleBossRespawn(zoneId, delay)
	if not SpawnTimers[zoneId] then return end

	SpawnTimers[zoneId].NextSpawn = tick() + delay
	warn("[BossManager] Scheduled respawn for Zone " .. zoneId .. " in " .. delay .. " seconds")
end

function BossManager:GetBossSpawnLocation(zoneId)
	-- In real implementation, would get spawn point from workspace
	-- For now, return a default position

	local spawnPoints = workspace:FindFirstChild("BossSpawnPoints")
	if spawnPoints then
		local zoneSpawn = spawnPoints:FindFirstChild("Zone" .. zoneId)
		if zoneSpawn and zoneSpawn:IsA("BasePart") then
			return zoneSpawn.CFrame + Vector3.new(0, 10, 0)
		end
	end

	-- Default spawn
	return CFrame.new(0, 50, 0)
end

function BossManager:GetPlayersInZone(zoneId)
	local playersInZone = {}

	for _, player in ipairs(Players:GetPlayers()) do
		-- In real implementation, would check player's current zone
		-- For now, return all players for testing
		-- local playerData = DataManager:GetPlayerData(player)
		-- if playerData and playerData.CurrentZone == zoneId then
		table.insert(playersInZone, player)
		-- end
	end

	return playersInZone
end

function BossManager:GetAveragePlayerStats(players)
	if #players == 0 then return 1, 0 end

	local totalLevel = 0
	local totalRebirth = 0

	for _, player in ipairs(players) do
		-- In real implementation, get from DataManager
		-- local playerData = DataManager:GetPlayerData(player)
		-- totalLevel = totalLevel + (playerData.Level or 1)
		-- totalRebirth = totalRebirth + (playerData.RebirthLevel or 0)

		-- For now, use defaults
		totalLevel = totalLevel + 50
		totalRebirth = totalRebirth + 0
	end

	local avgLevel = math.floor(totalLevel / #players)
	local avgRebirth = math.floor(totalRebirth / #players)

	return avgLevel, avgRebirth
end

function BossManager:AnnounceBossSpawn(boss)
	local message = boss.BossData.SpawnMessage or (boss.BossData.Name .. " has spawned!")

	-- Add rarity prefix
	if boss.Rarity ~= "Normal" then
		message = "[" .. boss.Rarity .. "] " .. message
	end

	self:AnnounceToZone(boss.ZoneId, message)

	-- Play spawn sound
	if boss.BossData.SpawnSound and boss.Model and boss.Model.PrimaryPart then
		local sound = Instance.new("Sound")
		sound.SoundId = boss.BossData.SpawnSound
		sound.Volume = 1
		sound.Parent = boss.Model.PrimaryPart
		sound:Play()
		game:GetService("Debris"):AddItem(sound, 10)
	end
end

function BossManager:AnnounceBossDefeat(boss)
	local message = boss.BossData.Name .. " has been defeated!"

	if boss.Rarity ~= "Normal" then
		message = "[" .. boss.Rarity .. "] " .. message
	end

	self:AnnounceToZone(boss.ZoneId, message)
end

function BossManager:AnnounceToZone(zoneId, message)
	-- In real implementation, send to all players in zone
	warn("[BossManager] Zone " .. zoneId .. " announcement: " .. message)

	-- Would use RemoteEvent to send to clients
	-- local RemoteEvents = ReplicatedStorage.Remotes.RemoteEvents
	-- RemoteEvents.BossAnnouncement:FireAllClients(zoneId, message)
end

function BossManager:AwardPlayerRewards(player, rewards)
	warn(string.format(
		"[BossManager] Awarding %s: %d DP, %d XP, %d items (Top: %s, Damage: %d, Percent: %.1f%%)",
		player.Name,
		rewards.DP,
		rewards.XP,
		#rewards.Items,
		tostring(rewards.IsTopDamager),
		rewards.DamageDealt,
		rewards.DamagePercent * 100
	))

	-- Integrate with GameServer if available
	if _G.GameServer then
		local GameServer = _G.GameServer

		-- Award through GameServer which handles achievements and tracking
		GameServer:OnBossDefeated(player, self.BossData, rewards)
	else
		warn("[BossManager] GameServer not available, rewards not fully processed")
	end

	-- Send reward notification to player
	-- In full implementation, would use RemoteEvent
	-- local RemoteEvents = ReplicatedStorage.Remotes.RemoteEvents
	-- RemoteEvents.BossReward:FireClient(player, rewards)
end

function BossManager:ShowDamageNumber(model, damage, isHeal)
	if not model or not model.PrimaryPart then return end

	-- Create damage billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(4, 0, 2, 0)
	billboard.StudsOffset = Vector3.new(math.random(-2, 2), 5, math.random(-2, 2))
	billboard.AlwaysOnTop = true
	billboard.Parent = model.PrimaryPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = (isHeal and "+" or "-") .. self:FormatNumber(damage)
	label.TextColor3 = isHeal and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.TextStrokeTransparency = 0
	label.Parent = billboard

	-- Animate
	task.spawn(function()
		for i = 1, 10 do
			label.TextTransparency = i / 10
			label.TextStrokeTransparency = i / 10
			billboard.StudsOffset = billboard.StudsOffset + Vector3.new(0, 0.3, 0)
			task.wait(0.05)
		end
		billboard:Destroy()
	end)
end

function BossManager:FormatNumber(num)
	if num >= 1000000000000 then
		return string.format("%.2fT", num / 1000000000000)
	elseif num >= 1000000000 then
		return string.format("%.2fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.2fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.2fK", num / 1000)
	else
		return tostring(math.floor(num))
	end
end

-- ========================================
-- PUBLIC API
-- ========================================

-- Get active boss in zone
function BossManager:GetBossInZone(zoneId)
	return ActiveBosses[zoneId]
end

-- Manually spawn boss (for testing or events)
function BossManager:ForceSpawnBoss(zoneId, rarity)
	return self:SpawnBoss(zoneId, rarity)
end

-- Deal damage to boss (called from combat system)
function BossManager:DamageBoss(bossId, damage, player)
	for _, boss in pairs(ActiveBosses) do
		if boss.Id == bossId then
			return boss:TakeDamage(damage, player)
		end
	end
	return false, "Boss not found"
end

-- Heal boss (for boss abilities)
function BossManager:HealBoss(bossId, amount)
	for _, boss in pairs(ActiveBosses) do
		if boss.Id == bossId then
			boss:Heal(amount)
			return true
		end
	end
	return false
end

-- Remove boss (for admin commands)
function BossManager:RemoveBoss(zoneId)
	if ActiveBosses[zoneId] then
		ActiveBosses[zoneId]:Destroy()
		return true
	end
	return false
end

-- Get all active bosses
function BossManager:GetAllActiveBosses()
	local bosses = {}
	for _, boss in pairs(ActiveBosses) do
		if boss.IsAlive then
			table.insert(bosses, boss)
		end
	end
	return bosses
end

-- Get boss stats (for UI)
function BossManager:GetBossStats(bossId)
	for _, boss in pairs(ActiveBosses) do
		if boss.Id == bossId and boss.IsAlive then
			return {
				Name = boss.BossData.Name,
				Rarity = boss.Rarity,
				CurrentHealth = boss.CurrentHealth,
				MaxHealth = boss.MaxHealth,
				HealthPercent = boss.CurrentHealth / boss.MaxHealth,
				ZoneId = boss.ZoneId,
				Phase = boss.CurrentPhase,
				Participants = boss.ParticipantCount,
			}
		end
	end
	return nil
end

return BossManager
