--[[
	SoundManager.lua
	Client-side sound playback and management for Homework Destroyer

	Responsibilities:
	- Play 2D (UI) and 3D (world) sounds
	- Manage sound volume and settings
	- Handle background music transitions
	- Apply sound effects with pitch variation
	- Pool and cleanup sounds efficiently

	Usage:
		local SoundManager = require(ReplicatedStorage.SharedModules.SoundManager)

		-- Play UI sound
		SoundManager:PlayUISound("ButtonClick")

		-- Play 3D combat sound
		SoundManager:PlayCombatSound("Hit_Paper", workspace.Homework.PrimaryPart.Position)

		-- Play with custom parameters
		SoundManager:PlaySound("CriticalHit", {Position = Vector3.new(0, 10, 0), Volume = 0.8})

		-- Change background music
		SoundManager:PlayZoneMusic(2) -- Library zone

		-- Update settings
		SoundManager:SetMasterVolume(0.7)
		SoundManager:SetCategoryVolume("Combat", 0.5)
]]

local SoundManager = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

-- Modules
local SoundConfig = require(script.Parent.SoundConfig)

-- Local player
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ========================================
-- STATE
-- ========================================

-- Volume settings (saved to player data)
local Settings = {
	MasterVolume = 1.0,
	CategoryVolumes = {
		Combat = 1.0,
		UI = 1.0,
		Ambient = 1.0,
		Boss = 1.0,
		Pet = 1.0
	},
	MutedCategories = {},
	GlobalMute = false
}

-- Sound pool for reusing sound instances
local SoundPool = {}
local PoolSize = {
	["2D"] = 10, -- UI sounds
	["3D"] = 20  -- World sounds
}

-- Currently playing background music
local CurrentBGM = nil
local CurrentZone = nil

-- Active 3D sounds (for cleanup)
local ActiveSounds = {}

-- ========================================
-- INITIALIZATION
-- ========================================

function SoundManager:Initialize()
	-- Create sound pool
	self:CreateSoundPool()

	-- Load settings from player data (if available)
	self:LoadSettings()

	-- Set up cleanup
	self:StartCleanupLoop()

	-- Listen for remote events
	self:ConnectRemoteEvents()

	print("[SoundManager] Initialized on client")
end

-- Create pre-instantiated sound pool
function SoundManager:CreateSoundPool()
	-- 2D sounds (UI)
	SoundPool["2D"] = {}
	for i = 1, PoolSize["2D"] do
		local sound = Instance.new("Sound")
		sound.Parent = SoundService
		sound.Volume = 0
		table.insert(SoundPool["2D"], sound)
	end

	-- 3D sounds (world)
	SoundPool["3D"] = {}
	for i = 1, PoolSize["3D"] do
		local sound = Instance.new("Sound")
		sound.Volume = 0
		-- 3D sounds will be parented to attachments in world
		table.insert(SoundPool["3D"], sound)
	end

	print(string.format("[SoundManager] Created sound pool: %d 2D, %d 3D", PoolSize["2D"], PoolSize["3D"]))
end

-- Load settings from DataStore or defaults
function SoundManager:LoadSettings()
	-- TODO: Load from player data via RemoteFunction
	-- For now, use defaults from SoundConfig
	Settings.MasterVolume = SoundConfig.MasterVolume.Master
	Settings.CategoryVolumes = {
		Combat = SoundConfig.MasterVolume.Combat,
		UI = SoundConfig.MasterVolume.UI,
		Ambient = SoundConfig.MasterVolume.Ambient,
		Boss = SoundConfig.MasterVolume.Boss,
		Pet = 1.0
	}
end

-- Save settings to server
function SoundManager:SaveSettings()
	-- TODO: Send to server via RemoteEvent to save to DataStore
	local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remotes then
		local updateSettingsEvent = remotes:FindFirstChild("UpdateSettings")
		if updateSettingsEvent then
			updateSettingsEvent:FireServer("SoundSettings", Settings)
		end
	end
end

-- ========================================
-- SOUND PLAYBACK
-- ========================================

--[[
	Play a sound by name
	@param soundName - Name from SoundConfig (e.g., "Hit_Paper", "ButtonClick")
	@param options - Optional table: {Position = Vector3, Volume = number, Pitch = number, Parent = Instance}
	@return Sound instance or nil
]]
function SoundManager:PlaySound(soundName, options)
	options = options or {}

	-- Get sound config
	local soundConfig = SoundConfig.GetSound(soundName)
	if not soundConfig then
		warn(string.format("[SoundManager] Sound '%s' not found in SoundConfig", soundName))
		return nil
	end

	-- Skip placeholder sounds
	if SoundConfig.IsPlaceholder(soundConfig) then
		return nil
	end

	-- Check if muted
	if Settings.GlobalMute or Settings.MutedCategories[soundConfig.Category] then
		return nil
	end

	-- Get sound from pool or create new
	local sound = self:GetSoundFromPool(soundConfig.Type)
	if not sound then
		warn("[SoundManager] Failed to get sound from pool")
		return nil
	end

	-- Configure sound
	sound.SoundId = soundConfig.SoundId

	-- Calculate volume
	local categoryVolume = Settings.CategoryVolumes[soundConfig.Category] or 1.0
	local baseVolume = options.Volume or soundConfig.Volume or 0.5
	sound.Volume = baseVolume * categoryVolume * Settings.MasterVolume

	-- Set pitch (with variation)
	sound.Pitch = options.Pitch or SoundConfig.GetRandomPitch(soundConfig)

	-- Set looping
	sound.Looped = options.Looped or soundConfig.Looped or false

	-- Configure 3D properties
	if soundConfig.Type == "3D" then
		sound.RollOffMaxDistance = soundConfig.RollOffMaxDistance or 100
		sound.RollOffMinDistance = 10

		-- Create attachment for 3D positioning
		local position = options.Position or Vector3.new(0, 0, 0)
		local attachment = Instance.new("Attachment")
		local part = Instance.new("Part")
		part.Transparency = 1
		part.CanCollide = false
		part.Anchored = true
		part.Size = Vector3.new(0.1, 0.1, 0.1)
		part.Position = position
		part.Parent = workspace
		attachment.Parent = part

		sound.Parent = attachment

		-- Track for cleanup
		table.insert(ActiveSounds, {Sound = sound, Part = part, EndTime = tick() + 5})
	else
		-- 2D sound
		sound.Parent = options.Parent or SoundService
	end

	-- Play
	sound:Play()

	-- Auto-cleanup if not looping
	if not sound.Looped then
		task.delay(sound.TimeLength / sound.Pitch + 0.5, function()
			if sound and sound.Parent then
				sound:Stop()
				self:ReturnSoundToPool(sound, soundConfig.Type)
			end
		end)
	end

	return sound
end

--[[
	Play a UI sound (2D, no position)
]]
function SoundManager:PlayUISound(soundName, volumeOverride)
	return self:PlaySound(soundName, {
		Volume = volumeOverride
	})
end

--[[
	Play a combat sound (3D, at position)
]]
function SoundManager:PlayCombatSound(soundName, position, volumeOverride)
	return self:PlaySound(soundName, {
		Position = position,
		Volume = volumeOverride
	})
end

--[[
	Play a boss sound (2D, loud)
]]
function SoundManager:PlayBossSound(soundName, volumeOverride)
	return self:PlaySound(soundName, {
		Volume = volumeOverride
	})
end

--[[
	Play tool hit sound based on tool ID
]]
function SoundManager:PlayToolHitSound(toolID, toolCategory, position, isCritical)
	local soundConfig

	if isCritical then
		soundConfig = SoundConfig.Combat.CriticalHit
	else
		soundConfig = SoundConfig.GetToolSound(toolID, toolCategory)
	end

	if not soundConfig then
		return nil
	end

	return self:PlaySound(isCritical and "CriticalHit" or soundConfig.Name or "Hit_Paper", {
		Position = position,
		Volume = isCritical and 0.6 or nil
	})
end

-- ========================================
-- BACKGROUND MUSIC
-- ========================================

--[[
	Play zone background music
	Fades out current music and fades in new music
]]
function SoundManager:PlayZoneMusic(zoneID)
	if CurrentZone == zoneID then
		return -- Already playing this zone's music
	end

	local musicConfig = SoundConfig.GetZoneMusic(zoneID)
	if not musicConfig then
		warn(string.format("[SoundManager] No music configured for zone %d", zoneID))
		return
	end

	-- Skip placeholder music
	if SoundConfig.IsPlaceholder(musicConfig) then
		self:StopBackgroundMusic()
		CurrentZone = zoneID
		return
	end

	-- Check if ambient is muted
	if Settings.GlobalMute or Settings.MutedCategories["Ambient"] then
		self:StopBackgroundMusic()
		CurrentZone = zoneID
		return
	end

	-- Fade out current music
	if CurrentBGM and CurrentBGM.Parent then
		self:FadeOutSound(CurrentBGM, musicConfig.FadeOutTime or 2)
	end

	-- Create new background music
	local newBGM = Instance.new("Sound")
	newBGM.SoundId = musicConfig.SoundId
	newBGM.Looped = true
	newBGM.Volume = 0 -- Start at 0 for fade-in
	newBGM.Parent = SoundService
	newBGM:Play()

	-- Fade in new music
	local targetVolume = musicConfig.Volume * Settings.CategoryVolumes.Ambient * Settings.MasterVolume
	self:FadeInSound(newBGM, targetVolume, musicConfig.FadeInTime or 2)

	CurrentBGM = newBGM
	CurrentZone = zoneID

	print(string.format("[SoundManager] Playing zone %d music", zoneID))
end

--[[
	Stop background music
]]
function SoundManager:StopBackgroundMusic()
	if CurrentBGM and CurrentBGM.Parent then
		self:FadeOutSound(CurrentBGM, 2)
		CurrentBGM = nil
		CurrentZone = nil
	end
end

--[[
	Update background music volume (when settings change)
]]
function SoundManager:UpdateBackgroundMusicVolume()
	if CurrentBGM and CurrentBGM.Parent and CurrentZone then
		local musicConfig = SoundConfig.GetZoneMusic(CurrentZone)
		if musicConfig then
			local targetVolume = musicConfig.Volume * Settings.CategoryVolumes.Ambient * Settings.MasterVolume
			CurrentBGM.Volume = targetVolume
		end
	end
end

-- ========================================
-- VOLUME CONTROL
-- ========================================

--[[
	Set master volume (0.0 to 1.0)
]]
function SoundManager:SetMasterVolume(volume)
	Settings.MasterVolume = math.clamp(volume, 0, 1)
	self:UpdateBackgroundMusicVolume()
	self:SaveSettings()
end

--[[
	Set category volume (0.0 to 1.0)
]]
function SoundManager:SetCategoryVolume(category, volume)
	Settings.CategoryVolumes[category] = math.clamp(volume, 0, 1)

	-- Update background music if ambient category changed
	if category == "Ambient" then
		self:UpdateBackgroundMusicVolume()
	end

	self:SaveSettings()
end

--[[
	Mute/unmute a category
]]
function SoundManager:SetCategoryMute(category, muted)
	Settings.MutedCategories[category] = muted

	-- Stop background music if ambient muted
	if category == "Ambient" and muted then
		self:StopBackgroundMusic()
	elseif category == "Ambient" and not muted and CurrentZone then
		self:PlayZoneMusic(CurrentZone)
	end

	self:SaveSettings()
end

--[[
	Global mute toggle
]]
function SoundManager:SetGlobalMute(muted)
	Settings.GlobalMute = muted

	if muted then
		self:StopBackgroundMusic()
	elseif not muted and CurrentZone then
		self:PlayZoneMusic(CurrentZone)
	end

	self:SaveSettings()
end

--[[
	Get current settings
]]
function SoundManager:GetSettings()
	return Settings
end

-- ========================================
-- SOUND POOLING
-- ========================================

--[[
	Get a sound from the pool
]]
function SoundManager:GetSoundFromPool(soundType)
	local pool = SoundPool[soundType]
	if not pool then
		return nil
	end

	-- Find available sound
	for _, sound in ipairs(pool) do
		if not sound.IsPlaying then
			return sound
		end
	end

	-- No available sounds, create a new one
	local sound = Instance.new("Sound")
	if soundType == "2D" then
		sound.Parent = SoundService
	end
	table.insert(pool, sound)

	return sound
end

--[[
	Return sound to pool
]]
function SoundManager:ReturnSoundToPool(sound, soundType)
	if not sound then
		return
	end

	-- Stop and reset
	sound:Stop()
	sound.Volume = 0
	sound.Looped = false

	-- Re-parent 2D sounds to SoundService
	if soundType == "2D" then
		sound.Parent = SoundService
	else
		-- 3D sounds: cleanup attachment and part
		if sound.Parent and sound.Parent:IsA("Attachment") then
			local part = sound.Parent.Parent
			if part then
				part:Destroy()
			end
		end
		sound.Parent = nil
	end
end

-- ========================================
-- SOUND EFFECTS (Fade, etc.)
-- ========================================

--[[
	Fade in a sound
]]
function SoundManager:FadeInSound(sound, targetVolume, duration)
	if not sound or not sound.Parent then
		return
	end

	duration = duration or 1

	local tween = TweenService:Create(
		sound,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{Volume = targetVolume}
	)

	tween:Play()
end

--[[
	Fade out a sound (and destroy after)
]]
function SoundManager:FadeOutSound(sound, duration)
	if not sound or not sound.Parent then
		return
	end

	duration = duration or 1

	local tween = TweenService:Create(
		sound,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{Volume = 0}
	)

	tween:Play()

	-- Destroy after fade
	task.delay(duration, function()
		if sound and sound.Parent then
			sound:Stop()
			sound:Destroy()
		end
	end)
end

-- ========================================
-- CLEANUP
-- ========================================

--[[
	Cleanup loop for removing old 3D sounds
]]
function SoundManager:StartCleanupLoop()
	task.spawn(function()
		while true do
			task.wait(5) -- Run every 5 seconds

			local currentTime = tick()

			-- Clean up old sounds
			for i = #ActiveSounds, 1, -1 do
				local soundData = ActiveSounds[i]
				if currentTime >= soundData.EndTime then
					-- Cleanup
					if soundData.Sound then
						soundData.Sound:Stop()
						self:ReturnSoundToPool(soundData.Sound, "3D")
					end
					if soundData.Part then
						soundData.Part:Destroy()
					end

					table.remove(ActiveSounds, i)
				end
			end
		end
	end)
end

-- ========================================
-- REMOTE EVENTS
-- ========================================

--[[
	Connect to server sound events
]]
function SoundManager:ConnectRemoteEvents()
	local remotes = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remotes then
		warn("[SoundManager] RemoteEvents folder not found")
		return
	end

	-- PlaySound event (server tells client to play a sound)
	local playSoundEvent = remotes:FindFirstChild("PlaySound")
	if playSoundEvent and playSoundEvent:IsA("RemoteEvent") then
		playSoundEvent.OnClientEvent:Connect(function(soundName, options)
			self:PlaySound(soundName, options)
		end)
	end

	-- PlaySoundAt event (play 3D sound at position)
	local playSoundAtEvent = remotes:FindFirstChild("PlaySoundAt")
	if playSoundAtEvent and playSoundAtEvent:IsA("RemoteEvent") then
		playSoundAtEvent.OnClientEvent:Connect(function(soundName, position, volumeOverride)
			self:PlayCombatSound(soundName, position, volumeOverride)
		end)
	end

	-- ZoneChanged event (change background music)
	local zoneChangedEvent = remotes:FindFirstChild("TeleportToZone")
	if zoneChangedEvent and zoneChangedEvent:IsA("RemoteEvent") then
		zoneChangedEvent.OnClientEvent:Connect(function(zoneID)
			self:PlayZoneMusic(zoneID)
		end)
	end

	print("[SoundManager] Connected to remote events")
end

-- ========================================
-- AUTO-INITIALIZE
-- ========================================

-- Initialize when script loads
SoundManager:Initialize()

return SoundManager
