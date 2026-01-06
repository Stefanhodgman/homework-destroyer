--[[
	ServerSoundManager.lua
	Server-side sound management for Homework Destroyer

	Responsibilities:
	- Trigger client sounds via RemoteEvents
	- Play sounds for all players or specific players
	- Handle boss/achievement/event sounds
	- Coordinate zone music changes

	Usage:
		local ServerSoundManager = require(ServerStorage.Modules.ServerSoundManager)

		-- Play sound for specific player
		ServerSoundManager:PlaySoundForPlayer(player, "LevelUp")

		-- Play sound for all players
		ServerSoundManager:PlaySoundForAll("BossSpawn")

		-- Play 3D sound at position for nearby players
		ServerSoundManager:PlaySoundAt("HomeworkDestroy", Vector3.new(0, 10, 0))

		-- Play sound for players in a zone
		ServerSoundManager:PlaySoundForZone(2, "ZoneTransition")
]]

local ServerSoundManager = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Modules
-- SoundConfig is in ReplicatedStorage so server can access it
local SoundConfig = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("SoundConfig"))

-- Remote Events (will be initialized)
local RemoteEvents = nil
local PlaySoundEvent = nil
local PlaySoundAtEvent = nil

-- ========================================
-- INITIALIZATION
-- ========================================

function ServerSoundManager:Initialize()
	-- Get remote events
	local remotesFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remotesFolder then
		warn("[ServerSoundManager] RemoteEvents folder not found!")
		return
	end

	-- Get or create PlaySound event
	PlaySoundEvent = remotesFolder:FindFirstChild("PlaySound")
	if not PlaySoundEvent then
		PlaySoundEvent = Instance.new("RemoteEvent")
		PlaySoundEvent.Name = "PlaySound"
		PlaySoundEvent.Parent = remotesFolder
		print("[ServerSoundManager] Created PlaySound RemoteEvent")
	end

	-- Get or create PlaySoundAt event
	PlaySoundAtEvent = remotesFolder:FindFirstChild("PlaySoundAt")
	if not PlaySoundAtEvent then
		PlaySoundAtEvent = Instance.new("RemoteEvent")
		PlaySoundAtEvent.Name = "PlaySoundAt"
		PlaySoundAtEvent.Parent = remotesFolder
		print("[ServerSoundManager] Created PlaySoundAt RemoteEvent")
	end

	-- Load RemoteEvents module for other events
	local RemoteEventsModule = require(ReplicatedStorage.Remotes.RemoteEvents)
	RemoteEvents = RemoteEventsModule.Get()

	print("[ServerSoundManager] Initialized")
end

-- ========================================
-- SOUND PLAYBACK (2D)
-- ========================================

--[[
	Play sound for a specific player
	@param player - Player to play sound for
	@param soundName - Name from SoundConfig
	@param options - Optional table: {Volume = number, Pitch = number}
]]
function ServerSoundManager:PlaySoundForPlayer(player, soundName, options)
	if not player or not player:IsDescendantOf(Players) then
		return
	end

	if not PlaySoundEvent then
		warn("[ServerSoundManager] PlaySound event not initialized")
		return
	end

	-- Validate sound exists
	local soundConfig = SoundConfig.GetSound(soundName)
	if not soundConfig then
		warn(string.format("[ServerSoundManager] Sound '%s' not found", soundName))
		return
	end

	-- Send to client
	local success, err = pcall(function()
		PlaySoundEvent:FireClient(player, soundName, options or {})
	end)

	if not success then
		warn(string.format("[ServerSoundManager] Error playing sound for %s: %s", player.Name, tostring(err)))
	end
end

--[[
	Play sound for all players
	@param soundName - Name from SoundConfig
	@param options - Optional table: {Volume = number, Pitch = number}
]]
function ServerSoundManager:PlaySoundForAll(soundName, options)
	if not PlaySoundEvent then
		warn("[ServerSoundManager] PlaySound event not initialized")
		return
	end

	-- Validate sound exists
	local soundConfig = SoundConfig.GetSound(soundName)
	if not soundConfig then
		warn(string.format("[ServerSoundManager] Sound '%s' not found", soundName))
		return
	end

	-- Send to all clients
	local success, err = pcall(function()
		PlaySoundEvent:FireAllClients(soundName, options or {})
	end)

	if not success then
		warn(string.format("[ServerSoundManager] Error playing sound for all: %s", tostring(err)))
	end
end

--[[
	Play sound for players in a specific zone
	@param zoneID - Zone ID (1-10)
	@param soundName - Name from SoundConfig
	@param options - Optional table
]]
function ServerSoundManager:PlaySoundForZone(zoneID, soundName, options)
	if not PlaySoundEvent then
		return
	end

	-- Get zone folder
	local zonesFolder = workspace:FindFirstChild("Zones")
	if not zonesFolder then
		return
	end

	local zoneFolder = zonesFolder:FindFirstChild("Zone" .. tostring(zoneID))
	if not zoneFolder then
		return
	end

	-- Get zone region (simplified - you may need to adjust based on your zone setup)
	-- For now, play for all players who have this zone unlocked
	for _, player in ipairs(Players:GetPlayers()) do
		-- TODO: Check if player is in this zone
		-- For now, just play for everyone
		self:PlaySoundForPlayer(player, soundName, options)
	end
end

-- ========================================
-- SOUND PLAYBACK (3D)
-- ========================================

--[[
	Play 3D sound at a specific position
	All players within range will hear it
	@param soundName - Name from SoundConfig
	@param position - Vector3 world position
	@param volumeOverride - Optional volume override
]]
function ServerSoundManager:PlaySoundAt(soundName, position, volumeOverride)
	if not PlaySoundAtEvent then
		warn("[ServerSoundManager] PlaySoundAt event not initialized")
		return
	end

	-- Validate sound exists
	local soundConfig = SoundConfig.GetSound(soundName)
	if not soundConfig then
		warn(string.format("[ServerSoundManager] Sound '%s' not found", soundName))
		return
	end

	-- Only play 3D sounds for 3D sound types
	if soundConfig.Type ~= "3D" then
		warn(string.format("[ServerSoundManager] Sound '%s' is not a 3D sound", soundName))
		return
	end

	-- Get max distance for this sound
	local maxDistance = soundConfig.MaxDistance or 100

	-- Send to all clients within range
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character.PrimaryPart then
			local distance = (character.PrimaryPart.Position - position).Magnitude

			if distance <= maxDistance * 2 then -- Send to players within 2x max distance
				local success, err = pcall(function()
					PlaySoundAtEvent:FireClient(player, soundName, position, volumeOverride)
				end)

				if not success then
					warn(string.format("[ServerSoundManager] Error playing 3D sound for %s: %s", player.Name, tostring(err)))
				end
			end
		end
	end
end

--[[
	Play 3D sound at position for specific player
]]
function ServerSoundManager:PlaySoundAtForPlayer(player, soundName, position, volumeOverride)
	if not player or not player:IsDescendantOf(Players) then
		return
	end

	if not PlaySoundAtEvent then
		warn("[ServerSoundManager] PlaySoundAt event not initialized")
		return
	end

	-- Validate sound exists
	local soundConfig = SoundConfig.GetSound(soundName)
	if not soundConfig then
		warn(string.format("[ServerSoundManager] Sound '%s' not found", soundName))
		return
	end

	-- Send to client
	local success, err = pcall(function()
		PlaySoundAtEvent:FireClient(player, soundName, position, volumeOverride)
	end)

	if not success then
		warn(string.format("[ServerSoundManager] Error playing 3D sound for %s: %s", player.Name, tostring(err)))
	end
end

-- ========================================
-- COMBAT SOUNDS
-- ========================================

--[[
	Play homework hit sound
	@param player - Player who clicked
	@param position - Homework position
	@param toolID - Player's equipped tool ID
	@param toolCategory - Tool category
	@param isCritical - Whether this is a critical hit
]]
function ServerSoundManager:PlayHitSound(player, position, toolID, toolCategory, isCritical)
	local soundName

	if isCritical then
		soundName = "CriticalHit"
	else
		-- Get tool-specific sound
		local soundConfig = SoundConfig.GetToolSound(toolID, toolCategory)
		if soundConfig then
			-- Extract sound name from config
			for name, config in pairs(SoundConfig.Combat) do
				if config == soundConfig then
					soundName = name
					break
				end
			end
		end

		soundName = soundName or "Hit_Paper"
	end

	self:PlaySoundAt(soundName, position)
end

--[[
	Play homework destruction sound
]]
function ServerSoundManager:PlayDestroySound(position)
	self:PlaySoundAt("HomeworkDestroy", position)
end

-- ========================================
-- BOSS SOUNDS
-- ========================================

--[[
	Play boss spawn sound for all players
]]
function ServerSoundManager:PlayBossSpawnSound()
	self:PlaySoundForAll("BossSpawn")
end

--[[
	Play boss defeat sound for all players
]]
function ServerSoundManager:PlayBossDefeatSound()
	self:PlaySoundForAll("BossDefeat")
end

--[[
	Play boss hit sound at position
]]
function ServerSoundManager:PlayBossHitSound(position)
	self:PlaySoundAt("BossHit", position)
end

-- ========================================
-- UI/ACHIEVEMENT SOUNDS
-- ========================================

--[[
	Play level up sound for player
]]
function ServerSoundManager:PlayLevelUpSound(player)
	self:PlaySoundForPlayer(player, "LevelUp")
end

--[[
	Play achievement unlock sound for player
]]
function ServerSoundManager:PlayAchievementSound(player)
	self:PlaySoundForPlayer(player, "AchievementUnlock")
end

--[[
	Play rebirth/prestige sound for player
]]
function ServerSoundManager:PlayRebirthSound(player)
	self:PlaySoundForPlayer(player, "Rebirth")
end

--[[
	Play purchase success sound for player
]]
function ServerSoundManager:PlayPurchaseSuccessSound(player)
	self:PlaySoundForPlayer(player, "PurchaseSuccess")
end

--[[
	Play purchase fail sound for player
]]
function ServerSoundManager:PlayPurchaseFailSound(player)
	self:PlaySoundForPlayer(player, "PurchaseFail")
end

-- ========================================
-- PET SOUNDS
-- ========================================

--[[
	Play pet attack sound at position
]]
function ServerSoundManager:PlayPetAttackSound(position)
	self:PlaySoundAt("PetAttack", position, 0.2) -- Quieter since pets attack frequently
end

--[[
	Play pet level up sound for player
]]
function ServerSoundManager:PlayPetLevelUpSound(player)
	self:PlaySoundForPlayer(player, "PetLevelUp")
end

--[[
	Play pet equip sound for player
]]
function ServerSoundManager:PlayPetEquipSound(player)
	self:PlaySoundForPlayer(player, "PetEquip")
end

--[[
	Play pet fusion sound for player
]]
function ServerSoundManager:PlayPetFusionSound(player)
	self:PlaySoundForPlayer(player, "PetFusion")
end

--[[
	Play egg hatch sound for player
]]
function ServerSoundManager:PlayEggHatchSound(player)
	self:PlaySoundForPlayer(player, "EggHatch")
end

-- ========================================
-- ZONE SOUNDS
-- ========================================

--[[
	Play zone transition sound for player
	Also triggers zone music change on client
]]
function ServerSoundManager:PlayZoneTransition(player, newZoneID)
	-- Play transition sound
	self:PlaySoundForPlayer(player, "ZoneTransition")

	-- Client's SoundManager will handle zone music via the TeleportToZone event
	-- which is already fired by ZoneManager, so no additional action needed here
end

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

--[[
	Check if a sound is valid
]]
function ServerSoundManager:IsValidSound(soundName)
	return SoundConfig.GetSound(soundName) ~= nil
end

--[[
	Get all players within range of a position
]]
function ServerSoundManager:GetPlayersInRange(position, range)
	local playersInRange = {}

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character.PrimaryPart then
			local distance = (character.PrimaryPart.Position - position).Magnitude
			if distance <= range then
				table.insert(playersInRange, player)
			end
		end
	end

	return playersInRange
end

--[[
	Play sound for multiple players
]]
function ServerSoundManager:PlaySoundForPlayers(players, soundName, options)
	for _, player in ipairs(players) do
		self:PlaySoundForPlayer(player, soundName, options)
	end
end

-- ========================================
-- BATCH OPERATIONS
-- ========================================

--[[
	Queue multiple sounds to play in sequence
	Useful for cinematic events
]]
function ServerSoundManager:PlaySoundSequence(player, soundSequence)
	task.spawn(function()
		for _, soundData in ipairs(soundSequence) do
			local soundName = soundData.Sound
			local delay = soundData.Delay or 0
			local options = soundData.Options or {}

			if delay > 0 then
				task.wait(delay)
			end

			if soundData.Position then
				self:PlaySoundAtForPlayer(player, soundName, soundData.Position, options.Volume)
			else
				self:PlaySoundForPlayer(player, soundName, options)
			end
		end
	end)
end

--[[
	Example usage of sound sequence:
	ServerSoundManager:PlaySoundSequence(player, {
		{Sound = "BossSpawn", Delay = 0},
		{Sound = "WindowOpen", Delay = 1},
		{Sound = "BossHit", Position = Vector3.new(0, 10, 0), Delay = 2}
	})
]]

return ServerSoundManager
