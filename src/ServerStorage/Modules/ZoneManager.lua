--[[
	ZoneManager.lua
	Server-side zone management for Homework Destroyer

	Handles:
	- Zone unlocking
	- Zone teleportation
	- Spawn point management
	- Zone-specific events and features
	- Boss spawning
	- Homework spawning in zones

	Depends on:
	- ZonesConfig
	- RemoteEvents
]]

local ZoneManager = {}
ZoneManager.__index = ZoneManager

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Modules
local ZonesConfig = require(ServerStorage.Modules.ZonesConfig)
local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)

-- Constants
local SAFE_TELEPORT_OFFSET = Vector3.new(0, 5, 0)
local ZONE_TRANSITION_DURATION = 0.5
local BOSS_SPAWN_OFFSET = Vector3.new(0, 10, 0)

-- Zone state tracking
ZoneManager.ActiveZones = {}
ZoneManager.BossTimers = {}
ZoneManager.EventTimers = {}
ZoneManager.PlayerZones = {} -- Track which zone each player is in

--[[
	Initialize the Zone Manager
]]
function ZoneManager.Init()
	print("[ZoneManager] Initializing Zone Manager...")

	-- Set up all zones
	for zoneID = 1, ZonesConfig.GetTotalZones() do
		ZoneManager.InitializeZone(zoneID)
	end

	-- Connect remote events
	ZoneManager.ConnectRemoteEvents()

	-- Start zone update loop
	ZoneManager.StartZoneUpdateLoop()

	print("[ZoneManager] Zone Manager initialized successfully!")
	return true
end

--[[
	Initialize a specific zone
]]
function ZoneManager.InitializeZone(zoneID)
	local zoneConfig = ZonesConfig.GetZone(zoneID)
	if not zoneConfig then
		warn("[ZoneManager] Cannot initialize invalid zone:", zoneID)
		return false
	end

	-- Create zone state
	ZoneManager.ActiveZones[zoneID] = {
		ID = zoneID,
		Config = zoneConfig,
		ActiveBoss = nil,
		LastBossSpawn = 0,
		ActivePlayers = {},
		HomeworkSpawned = {},
		EventActive = false,
		EventData = {},
	}

	print(string.format("[ZoneManager] Initialized Zone %d: %s", zoneID, zoneConfig.Name))
	return true
end

--[[
	Connect all remote events for zone management
]]
function ZoneManager.ConnectRemoteEvents()
	local remotes = RemoteEvents.Get()

	-- Zone unlock request
	if remotes.UnlockZone then
		remotes.UnlockZone.OnServerEvent:Connect(function(player, zoneID)
			ZoneManager.HandleZoneUnlockRequest(player, zoneID)
		end)
	end

	-- Zone teleport request
	if remotes.TeleportToZone then
		remotes.TeleportToZone.OnServerEvent:Connect(function(player, zoneID)
			ZoneManager.HandleZoneTeleportRequest(player, zoneID)
		end)
	end

	print("[ZoneManager] Remote events connected")
end

--[[
	Handle zone unlock request from player
]]
function ZoneManager.HandleZoneUnlockRequest(player, zoneID)
	-- This is now handled by GameServer:UnlockZone
	-- ZoneManager just manages zone state and teleportation
	warn("[ZoneManager] Zone unlock should be handled by GameServer, not ZoneManager directly")
end

--[[
	Handle zone teleport request from player
]]
function ZoneManager.HandleZoneTeleportRequest(player, zoneID)
	-- Get player data from DataManager if available
	local DataManager = require(game.ServerScriptService.DataManager)
	local playerData = DataManager:GetPlayerData(player)

	if not playerData then
		warn("[ZoneManager] Player data not found for " .. player.Name)
		return
	end

	-- Check if zone is unlocked
	local isUnlocked = false
	for _, unlockedID in ipairs(playerData.UnlockedZones) do
		if unlockedID == zoneID then
			isUnlocked = true
			break
		end
	end

	if not isUnlocked then
		warn("[ZoneManager] Zone " .. zoneID .. " not unlocked for " .. player.Name)
		return
	end

	-- Get zone configuration
	local zoneConfig = ZonesConfig.GetZone(zoneID)
	if not zoneConfig then
		warn("[ZoneManager] Invalid zone: " .. zoneID)
		return
	end

	-- Teleport player
	local success = ZoneManager.TeleportPlayerToZone(player, zoneID)
	if success then
		-- Update player's current zone
		playerData.CurrentZone = zoneID

		-- Track player in zone
		ZoneManager.AddPlayerToZone(player, zoneID)

		print(string.format("[ZoneManager] Teleported %s to Zone %d: %s", player.Name, zoneID, zoneConfig.Name))
	else
		warn("[ZoneManager] Failed to teleport " .. player.Name .. " to zone " .. zoneID)
	end
end

--[[
	Teleport a player to a specific zone
]]
function ZoneManager.TeleportPlayerToZone(player, zoneID)
	local character = player.Character
	if not character then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return false
	end

	local zoneConfig = ZonesConfig.GetZone(zoneID)
	if not zoneConfig then
		return false
	end

	-- Calculate spawn position
	local spawnPosition = zoneConfig.SpawnLocation + SAFE_TELEPORT_OFFSET

	-- Find zone model in workspace (optional - if you have physical zone models)
	local zoneModel = workspace:FindFirstChild("Zones") and workspace.Zones:FindFirstChild("Zone" .. zoneID)
	if zoneModel and zoneModel:FindFirstChild("SpawnPoint") then
		spawnPosition = zoneModel.SpawnPoint.Position + SAFE_TELEPORT_OFFSET
	end

	-- Teleport player
	humanoidRootPart.CFrame = CFrame.new(spawnPosition)

	-- Visual effect (optional)
	ZoneManager.PlayTeleportEffect(character, spawnPosition)

	-- Update player's zone tracking
	ZoneManager.PlayerZones[player.UserId] = zoneID

	return true
end

--[[
	Play teleport visual effect
]]
function ZoneManager.PlayTeleportEffect(character, position)
	-- Create particle effect at destination
	local effect = Instance.new("Part")
	effect.Name = "TeleportEffect"
	effect.Anchored = true
	effect.CanCollide = false
	effect.Size = Vector3.new(6, 6, 6)
	effect.Position = position
	effect.Transparency = 1
	effect.Parent = workspace

	-- Add particle emitter
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Rate = 100
	particles.Lifetime = NumberRange.new(0.5, 1)
	particles.Speed = NumberRange.new(5, 10)
	particles.SpreadAngle = Vector2.new(360, 360)
	particles.Parent = effect

	-- Clean up after effect
	game:GetService("Debris"):AddItem(effect, 2)
end

--[[
	Add player to zone tracking
]]
function ZoneManager.AddPlayerToZone(player, zoneID)
	local zone = ZoneManager.ActiveZones[zoneID]
	if not zone then
		return
	end

	-- Remove player from other zones
	for id, z in pairs(ZoneManager.ActiveZones) do
		z.ActivePlayers[player.UserId] = nil
	end

	-- Add to current zone
	zone.ActivePlayers[player.UserId] = {
		Player = player,
		JoinedAt = tick(),
	}

	print(string.format("[ZoneManager] Player %s joined zone %d", player.Name, zoneID))
end

--[[
	Remove player from zone tracking
]]
function ZoneManager.RemovePlayerFromZone(player, zoneID)
	local zone = ZoneManager.ActiveZones[zoneID]
	if not zone then
		return
	end

	zone.ActivePlayers[player.UserId] = nil
	print(string.format("[ZoneManager] Player %s left zone %d", player.Name, zoneID))
end

--[[
	Get spawn point for zone
]]
function ZoneManager.GetZoneSpawnPoint(zoneID)
	local zoneConfig = ZonesConfig.GetZone(zoneID)
	if not zoneConfig then
		return Vector3.new(0, 50, 0) -- Default spawn
	end

	local spawnPosition = zoneConfig.SpawnLocation + SAFE_TELEPORT_OFFSET

	-- Check for physical spawn point in workspace
	local zoneModel = workspace:FindFirstChild("Zones") and workspace.Zones:FindFirstChild("Zone" .. zoneID)
	if zoneModel and zoneModel:FindFirstChild("SpawnPoint") then
		return zoneModel.SpawnPoint.Position
	end

	return spawnPosition
end

--[[
	Send zone info to client
]]
function ZoneManager.SendZoneInfo(player, zoneID)
	local zoneConfig = ZonesConfig.GetZone(zoneID)
	if not zoneConfig then
		return
	end

	local playerData = ZoneManager.GetPlayerData(player)
	if not playerData then
		return
	end

	-- Check if unlocked
	local isUnlocked = false
	for _, unlockedID in ipairs(playerData.UnlockedZones) do
		if unlockedID == zoneID then
			isUnlocked = true
			break
		end
	end

	-- Check if can unlock
	local canUnlock, reason = ZonesConfig.CanUnlockZone(zoneID, playerData)

	-- Send zone info to client
	RemoteEvents.ReceiveZoneInfo:FireClient(player, {
		ZoneID = zoneID,
		Name = zoneConfig.Name,
		Description = zoneConfig.Description,
		IsUnlocked = isUnlocked,
		CanUnlock = canUnlock,
		UnlockReason = reason,
		Requirements = zoneConfig.UnlockRequirements,
		RecommendedLevel = zoneConfig.RecommendedLevel,
		DifficultyTier = zoneConfig.DifficultyTier,
	})
end

--[[
	Send unlocked zones list to client
]]
function ZoneManager.SendUnlockedZones(player)
	local playerData = ZoneManager.GetPlayerData(player)
	if not playerData then
		return
	end

	local unlockedZones = {}
	for _, zoneID in ipairs(playerData.UnlockedZones) do
		local config = ZonesConfig.GetZone(zoneID)
		if config then
			table.insert(unlockedZones, {
				ID = zoneID,
				Name = config.Name,
				Description = config.Description,
			})
		end
	end

	RemoteEvents.ReceiveUnlockedZones:FireClient(player, unlockedZones)
end

--[[
	Spawn boss in zone
]]
function ZoneManager.SpawnBoss(zoneID)
	local zone = ZoneManager.ActiveZones[zoneID]
	if not zone then
		return
	end

	-- Don't spawn if boss already exists
	if zone.ActiveBoss then
		return
	end

	local bossConfig = zone.Config.Boss
	if not bossConfig then
		return
	end

	-- Check if any players are in the zone
	local playerCount = 0
	for _ in pairs(zone.ActivePlayers) do
		playerCount = playerCount + 1
	end

	if playerCount == 0 then
		-- No players in zone, skip boss spawn
		return
	end

	-- Create boss spawn location
	local spawnPosition = bossConfig.SpawnLocation + BOSS_SPAWN_OFFSET

	-- Check for boss spawn point in workspace
	local zoneModel = workspace:FindFirstChild("Zones") and workspace.Zones:FindFirstChild("Zone" .. zoneID)
	if zoneModel and zoneModel:FindFirstChild("BossSpawn") then
		spawnPosition = zoneModel.BossSpawn.Position
	end

	-- Create boss data (this would integrate with an enemy/homework spawning system)
	zone.ActiveBoss = {
		Name = bossConfig.Name,
		HP = bossConfig.HP,
		MaxHP = bossConfig.HP,
		DPReward = bossConfig.DPReward,
		XPReward = bossConfig.XPReward,
		Position = spawnPosition,
		SpawnedAt = tick(),
		Attacks = bossConfig.Attacks,
	}

	zone.LastBossSpawn = tick()

	-- Notify all players in zone
	for _, playerData in pairs(zone.ActivePlayers) do
		RemoteEvents.BossSpawned:FireClient(playerData.Player, {
			ZoneID = zoneID,
			BossName = bossConfig.Name,
			BossHP = bossConfig.HP,
		})
	end

	print(string.format("[ZoneManager] Spawned boss '%s' in Zone %d", bossConfig.Name, zoneID))
end

--[[
	Boss defeated handler
]]
function ZoneManager.OnBossDefeated(zoneID, defeatingPlayer)
	local zone = ZoneManager.ActiveZones[zoneID]
	if not zone or not zone.ActiveBoss then
		return
	end

	local boss = zone.ActiveBoss
	local rewards = {
		DP = boss.DPReward,
		XP = boss.XPReward,
	}

	-- Reward the defeating player
	if defeatingPlayer then
		local playerData = ZoneManager.GetPlayerData(defeatingPlayer)
		if playerData then
			playerData.DestructionPoints = playerData.DestructionPoints + rewards.DP
			playerData.Experience = playerData.Experience + rewards.XP
			playerData.LifetimeStats.TotalBossesDefeated = playerData.LifetimeStats.TotalBossesDefeated + 1

			-- Notify player
			RemoteEvents.BossDefeated:FireClient(defeatingPlayer, {
				BossName = boss.Name,
				Rewards = rewards,
			})
		end
	end

	-- Clear boss
	zone.ActiveBoss = nil

	print(string.format("[ZoneManager] Boss '%s' defeated in Zone %d by %s", boss.Name, zoneID, defeatingPlayer.Name))
end

--[[
	Start zone update loop for boss spawning and events
]]
function ZoneManager.StartZoneUpdateLoop()
	-- Run on server heartbeat
	RunService.Heartbeat:Connect(function()
		local currentTime = tick()

		for zoneID, zone in pairs(ZoneManager.ActiveZones) do
			-- Boss spawning
			local bossConfig = zone.Config.Boss
			if bossConfig then
				local timeSinceLastBoss = currentTime - zone.LastBossSpawn
				if timeSinceLastBoss >= bossConfig.SpawnInterval then
					ZoneManager.SpawnBoss(zoneID)
				end
			end

			-- Zone events (special features)
			-- This would handle timed events like Speed Reading, Lunch Rush, etc.
			-- Implementation depends on specific event types
		end
	end)

	print("[ZoneManager] Zone update loop started")
end

--[[
	Spawn homework in zone (integrated with homework spawning system)
]]
function ZoneManager.SpawnHomework(zoneID, homeworkType)
	local zone = ZoneManager.ActiveZones[zoneID]
	if not zone then
		return nil
	end

	-- Find homework type in zone config
	local homeworkConfig = nil
	for _, hw in ipairs(zone.Config.HomeworkTypes) do
		if hw.Name == homeworkType or not homeworkType then
			homeworkConfig = hw
			break
		end
	end

	if not homeworkConfig then
		return nil
	end

	-- Calculate spawn position in zone
	local spawnPosition = zone.Config.SpawnLocation + Vector3.new(
		math.random(-20, 20),
		5,
		math.random(-20, 20)
	)

	-- Create homework data (would integrate with homework/enemy system)
	local homework = {
		Name = homeworkConfig.Name,
		HP = homeworkConfig.HP,
		MaxHP = homeworkConfig.HP,
		DPReward = homeworkConfig.DPReward,
		XPReward = homeworkConfig.XPReward,
		Position = spawnPosition,
		ZoneID = zoneID,
		SpawnedAt = tick(),
	}

	table.insert(zone.HomeworkSpawned, homework)

	return homework
end

--[[
	Get random homework type from zone based on spawn weights
]]
function ZoneManager.GetRandomHomeworkType(zoneID)
	local zone = ZoneManager.ActiveZones[zoneID]
	if not zone then
		return nil
	end

	local homeworkTypes = zone.Config.HomeworkTypes
	if not homeworkTypes or #homeworkTypes == 0 then
		return nil
	end

	-- Calculate total weight
	local totalWeight = 0
	for _, hw in ipairs(homeworkTypes) do
		totalWeight = totalWeight + hw.SpawnWeight
	end

	-- Random selection based on weight
	local random = math.random() * totalWeight
	local currentWeight = 0

	for _, hw in ipairs(homeworkTypes) do
		currentWeight = currentWeight + hw.SpawnWeight
		if random <= currentWeight then
			return hw.Name
		end
	end

	-- Fallback to first type
	return homeworkTypes[1].Name
end

--[[
	Get player's current zone
]]
function ZoneManager.GetPlayerZone(player)
	return ZoneManager.PlayerZones[player.UserId] or 1 -- Default to Zone 1
end

--[[
	Handle player joining game
]]
function ZoneManager.OnPlayerAdded(player)
	-- Teleport to their current zone or spawn zone
	local playerData = ZoneManager.GetPlayerData(player)
	if playerData then
		local currentZone = playerData.CurrentZone or 1

		-- Wait for character to load
		player.CharacterAdded:Connect(function(character)
			wait(0.5) -- Small delay to ensure character is fully loaded
			ZoneManager.TeleportPlayerToZone(player, currentZone)
		end)

		-- If character already exists
		if player.Character then
			wait(0.5)
			ZoneManager.TeleportPlayerToZone(player, currentZone)
		end
	end
end

--[[
	Handle player leaving game
]]
function ZoneManager.OnPlayerRemoving(player)
	-- Remove from zone tracking
	for zoneID, zone in pairs(ZoneManager.ActiveZones) do
		zone.ActivePlayers[player.UserId] = nil
	end

	ZoneManager.PlayerZones[player.UserId] = nil
end

--[[
	Get player data (mock function - would integrate with DataManager)
]]
function ZoneManager.GetPlayerData(player)
	-- This would normally get data from DataManager
	-- For now, return a mock structure
	if not player:FindFirstChild("PlayerData") then
		return nil
	end

	-- In production, this would be:
	-- return DataManager.GetPlayerData(player)

	-- Mock data for testing
	return {
		DestructionPoints = player:FindFirstChild("PlayerData"):FindFirstChild("DP") and player.PlayerData.DP.Value or 0,
		Level = player:FindFirstChild("PlayerData"):FindFirstChild("Level") and player.PlayerData.Level.Value or 1,
		RebirthLevel = player:FindFirstChild("PlayerData"):FindFirstChild("Rebirth") and player.PlayerData.Rebirth.Value or 0,
		PrestigeLevel = player:FindFirstChild("PlayerData"):FindFirstChild("Prestige") and player.PlayerData.Prestige.Value or 0,
		CurrentZone = player:FindFirstChild("PlayerData"):FindFirstChild("CurrentZone") and player.PlayerData.CurrentZone.Value or 1,
		UnlockedZones = {1}, -- Would be loaded from actual data
		Experience = 0,
		LifetimeStats = {
			TotalBossesDefeated = 0,
		},
	}
end

--[[
	Get zone statistics
]]
function ZoneManager.GetZoneStats(zoneID)
	local zone = ZoneManager.ActiveZones[zoneID]
	if not zone then
		return nil
	end

	local playerCount = 0
	for _ in pairs(zone.ActivePlayers) do
		playerCount = playerCount + 1
	end

	return {
		ZoneID = zoneID,
		Name = zone.Config.Name,
		ActivePlayers = playerCount,
		HasActiveBoss = zone.ActiveBoss ~= nil,
		HomeworkCount = #zone.HomeworkSpawned,
		EventActive = zone.EventActive,
	}
end

--[[
	Clear all homework in zone
]]
function ZoneManager.ClearZoneHomework(zoneID)
	local zone = ZoneManager.ActiveZones[zoneID]
	if not zone then
		return
	end

	zone.HomeworkSpawned = {}
	print(string.format("[ZoneManager] Cleared all homework in Zone %d", zoneID))
end

-- Connect player events
Players.PlayerAdded:Connect(function(player)
	ZoneManager.OnPlayerAdded(player)
end)

Players.PlayerRemoving:Connect(function(player)
	ZoneManager.OnPlayerRemoving(player)
end)

return ZoneManager
