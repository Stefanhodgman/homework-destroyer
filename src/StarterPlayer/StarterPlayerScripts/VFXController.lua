--[[
	VFXController.lua
	Client-side visual effects controller for Homework Destroyer

	Handles:
	- Damage numbers display
	- Particle effect creation and management
	- Screen shake and flashes
	- Level up effects
	- Destruction effects

	Performance optimized with object pooling and cleanup
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Modules
local VFXManager = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("VFXManager"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("SoundManager"))

-- Remote events
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DamageDealtEvent = Remotes:WaitForChild("DamageDealt", 10)
local PlayEffectEvent = Remotes:WaitForChild("PlayEffect", 10)
local ShowNotificationEvent = Remotes:WaitForChild("ShowNotification", 10)

-- VFX Controller
local VFXController = {}

-- Object pools for performance
local damageNumberPool = {}
local particlePartPool = {}
local MAX_POOL_SIZE = 20

-- Screen effects state
local isShaking = false
local originalCameraCFrame = nil

--[[
	DAMAGE NUMBERS
--]]

-- Get or create damage number billboard from pool
local function getDamageNumberBillboard()
	if #damageNumberPool > 0 then
		local billboard = table.remove(damageNumberPool)
		billboard.Enabled = true
		return billboard
	end

	-- Create new billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.AlwaysOnTop = true
	billboard.Parent = camera

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "DamageText"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Parent = billboard

	return billboard
end

-- Return damage number billboard to pool
local function returnDamageNumberToPool(billboard)
	if #damageNumberPool < MAX_POOL_SIZE then
		billboard.Enabled = false
		billboard.Adornee = nil
		table.insert(damageNumberPool, billboard)
	else
		billboard:Destroy()
	end
end

-- Create floating damage number
function VFXController.ShowDamageNumber(position, damage, isCritical)
	local config = VFXManager.GetDamageNumberConfig(isCritical)
	local billboard = getDamageNumberBillboard()

	-- Create anchor part
	local anchorPart = Instance.new("Part")
	anchorPart.Transparency = 1
	anchorPart.CanCollide = false
	anchorPart.Anchored = true
	anchorPart.Size = Vector3.new(0.1, 0.1, 0.1)
	anchorPart.Position = position
	anchorPart.Parent = workspace

	-- Configure billboard
	billboard.Adornee = anchorPart
	billboard.StudsOffset = Vector3.new(
		math.random(-config.Spread, config.Spread),
		2,
		math.random(-config.Spread, config.Spread)
	)

	-- Configure text
	local textLabel = billboard:FindFirstChild("DamageText")
	if textLabel then
		textLabel.Text = VFXManager.FormatDamageNumber(damage, isCritical)
		textLabel.Font = config.Font
		textLabel.TextSize = config.TextSize
		textLabel.TextColor3 = config.Color
		textLabel.TextStrokeColor3 = config.StrokeColor
		textLabel.TextStrokeTransparency = config.StrokeTransparency
		textLabel.TextTransparency = 0

		-- Scale effect for critical hits
		if isCritical then
			textLabel.TextScaled = false
			local scaleTween = TweenService:Create(
				textLabel,
				TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{TextSize = config.TextSize}
			)
			textLabel.TextSize = config.TextSize * 0.5
			scaleTween:Play()
		end
	end

	-- Animate upward movement
	local tweenInfo = TweenInfo.new(
		config.Duration,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local targetOffset = Vector3.new(
		billboard.StudsOffset.X,
		billboard.StudsOffset.Y + config.RiseDistance,
		billboard.StudsOffset.Z
	)

	local moveTween = TweenService:Create(billboard, tweenInfo, {StudsOffset = targetOffset})
	moveTween:Play()

	-- Fade out
	if textLabel then
		local fadeDelay = config.Duration * 0.6
		local fadeDuration = config.Duration * 0.4

		task.delay(fadeDelay, function()
			if textLabel and textLabel.Parent then
				local fadeTween = TweenService:Create(
					textLabel,
					TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear),
					{TextTransparency = 1, TextStrokeTransparency = 1}
				)
				fadeTween:Play()
			end
		end)
	end

	-- Cleanup
	task.delay(config.Duration, function()
		if anchorPart and anchorPart.Parent then
			anchorPart:Destroy()
		end
		returnDamageNumberToPool(billboard)
	end)
end

--[[
	PARTICLE EFFECTS
--]]

-- Get or create particle anchor part from pool
local function getParticlePart()
	if #particlePartPool > 0 then
		return table.remove(particlePartPool)
	end

	local part = Instance.new("Part")
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Size = Vector3.new(0.1, 0.1, 0.1)

	return part
end

-- Return particle part to pool
local function returnParticlePartToPool(part)
	if #particlePartPool < MAX_POOL_SIZE then
		-- Clean up any emitters
		for _, child in ipairs(part:GetChildren()) do
			if child:IsA("Attachment") then
				for _, emitter in ipairs(child:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Destroy()
					end
				end
			end
		end

		part.Parent = nil
		table.insert(particlePartPool, part)
	else
		part:Destroy()
	end
end

-- Create particle effect at position
function VFXController.CreateParticleEffect(position, particleConfigs, duration)
	duration = duration or 2

	local part = getParticlePart()
	part.Position = position
	part.Parent = workspace

	local attachment = part:FindFirstChildOfClass("Attachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Parent = part
	end

	-- Create emitters
	local emitters = VFXManager.CreateParticleEmitters(particleConfigs)

	for _, emitter in ipairs(emitters) do
		emitter.Parent = attachment

		-- Emit particles
		if emitter.Rate == 0 then
			-- Burst emission
			local emissionCount = 20
			for _, config in ipairs(particleConfigs) do
				if config.EmissionCount then
					emissionCount = config.EmissionCount
					break
				end
			end
			emitter:Emit(emissionCount)
		else
			-- Continuous emission
			emitter.Enabled = true
			task.delay(duration * 0.3, function()
				if emitter and emitter.Parent then
					emitter.Enabled = false
				end
			end)
		end
	end

	-- Cleanup
	task.delay(duration, function()
		returnParticlePartToPool(part)
	end)
end

-- Show hit particles
function VFXController.ShowHitParticles(position, homeworkType, isCritical)
	local particleConfig = VFXManager.GetHitParticleConfig(homeworkType, isCritical)
	VFXController.CreateParticleEffect(position, particleConfig, isCritical and 1.5 or 1)

	-- Play hit sound
	if isCritical then
		SoundManager:PlayCombatSound("CriticalHit", position)
	else
		local soundName = "Hit_" .. homeworkType
		SoundManager:PlayCombatSound(soundName, position)
	end
end

-- Show destruction particles
function VFXController.ShowDestructionEffect(position, isBoss)
	local particleConfig = VFXManager.GetDestructionParticleConfig(isBoss)
	VFXController.CreateParticleEffect(position, particleConfig, isBoss and 3 or 2)

	-- Play destruction sound
	local soundName = isBoss and "Destroy_Boss" or "Destroy_Normal"
	SoundManager:PlayCombatSound(soundName, position)

	-- Screen shake for destruction
	if isBoss then
		VFXController.ScreenShake("BossDestruction")
		VFXController.ScreenFlash("Boss")
	else
		VFXController.ScreenShake("Destruction")
	end
end

-- Show level up particles
function VFXController.ShowLevelUpEffect()
	local character = player.Character
	if not character or not character.PrimaryPart then
		return
	end

	local rootPart = character.PrimaryPart
	local particleConfig = VFXManager.GetLevelUpParticleConfig()

	-- Create particles at character position
	local part = getParticlePart()
	part.Position = rootPart.Position
	part.Parent = workspace

	local attachment = Instance.new("Attachment")
	attachment.Parent = part

	-- Create emitters
	local emitters = VFXManager.CreateParticleEmitters(particleConfig)

	for _, emitter in ipairs(emitters) do
		emitter.Parent = attachment
		emitter.Enabled = true
	end

	-- Follow character for duration
	local duration = 3
	local startTime = tick()
	local connection

	connection = RunService.Heartbeat:Connect(function()
		if tick() - startTime > duration then
			connection:Disconnect()

			for _, emitter in ipairs(emitters) do
				if emitter and emitter.Parent then
					emitter.Enabled = false
				end
			end

			task.delay(2, function()
				returnParticlePartToPool(part)
			end)

			return
		end

		if character and character.PrimaryPart then
			part.Position = character.PrimaryPart.Position
		end
	end)

	-- Screen flash for level up
	VFXController.ScreenFlash("LevelUp")

	-- Play level up sound
	SoundManager:PlayUISound("LevelUp")
end

--[[
	SCREEN EFFECTS
--]]

-- Screen shake effect
function VFXController.ScreenShake(effectType)
	if isShaking then return end

	local config = VFXManager.GetScreenShakeConfig(effectType)
	if not config then return end

	isShaking = true
	originalCameraCFrame = camera.CFrame

	local startTime = tick()
	local connection

	connection = RunService.RenderStepped:Connect(function()
		local elapsed = tick() - startTime

		if elapsed > config.Duration then
			connection:Disconnect()
			isShaking = false
			return
		end

		-- Calculate shake intensity with falloff
		local progress = elapsed / config.Duration
		local falloff = 1 - progress
		local currentIntensity = config.Intensity * falloff

		-- Generate random offset
		local randomOffset = Vector3.new(
			(math.random() - 0.5) * currentIntensity,
			(math.random() - 0.5) * currentIntensity,
			(math.random() - 0.5) * currentIntensity
		)

		-- Apply shake
		if not camera or camera.CameraType ~= Enum.CameraType.Custom then
			connection:Disconnect()
			isShaking = false
			return
		end

		camera.CFrame = camera.CFrame * CFrame.new(randomOffset)
	end)
end

-- Screen flash effect
function VFXController.ScreenFlash(effectType)
	local config = VFXManager.GetScreenFlashConfig(effectType)
	if not config then return end

	-- Create flash frame
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FlashEffect"
	screenGui.DisplayOrder = 100
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local flashFrame = Instance.new("Frame")
	flashFrame.Size = UDim2.new(1, 0, 1, 0)
	flashFrame.BackgroundColor3 = config.Color
	flashFrame.BackgroundTransparency = config.StartTransparency
	flashFrame.BorderSizePixel = 0
	flashFrame.Parent = screenGui

	-- Fade out
	local fadeTween = TweenService:Create(
		flashFrame,
		TweenInfo.new(config.Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = config.EndTransparency}
	)
	fadeTween:Play()

	-- Cleanup
	Debris:AddItem(screenGui, config.Duration + 0.1)
end

--[[
	EVENT HANDLERS
--]]

-- Handle damage dealt event from server
local function onDamageDealt(damageData)
	if not damageData then return end

	-- Show damage number
	VFXController.ShowDamageNumber(
		damageData.Position,
		damageData.Damage,
		damageData.IsCritical
	)

	-- Show hit particles
	local homeworkType = damageData.HomeworkType or "Paper"
	VFXController.ShowHitParticles(
		damageData.Position,
		homeworkType,
		damageData.IsCritical
	)

	-- Screen shake for critical hits
	if damageData.IsCritical then
		VFXController.ScreenShake("Critical")
	end
end

-- Handle play effect event from server
local function onPlayEffect(effectData)
	if not effectData then return end

	local effectType = effectData.Type
	local position = effectData.Position
	local extraData = effectData.ExtraData or {}

	if effectType == "Destruction" then
		local isBoss = extraData.IsBoss or false
		VFXController.ShowDestructionEffect(position, isBoss)

	elseif effectType == "LevelUp" then
		VFXController.ShowLevelUpEffect()

	elseif effectType == "ScreenShake" then
		local shakeType = extraData.ShakeType or "Critical"
		VFXController.ScreenShake(shakeType)

	elseif effectType == "ScreenFlash" then
		local flashType = extraData.FlashType or "Boss"
		VFXController.ScreenFlash(flashType)

	elseif effectType == "Hit" then
		local homeworkType = extraData.HomeworkType or "Paper"
		local isCritical = extraData.IsCritical or false
		VFXController.ShowHitParticles(position, homeworkType, isCritical)
	end
end

--[[
	INITIALIZATION
--]]

local function initialize()
	print("[VFXController] Initializing...")

	-- Connect to damage dealt event
	if DamageDealtEvent then
		DamageDealtEvent.OnClientEvent:Connect(onDamageDealt)
		print("[VFXController] Connected to DamageDealt event")
	else
		warn("[VFXController] DamageDealt event not found!")
	end

	-- Connect to play effect event
	if PlayEffectEvent then
		PlayEffectEvent.OnClientEvent:Connect(onPlayEffect)
		print("[VFXController] Connected to PlayEffect event")
	else
		warn("[VFXController] PlayEffect event not found!")
	end

	-- Listen for level up notifications
	if ShowNotificationEvent then
		ShowNotificationEvent.OnClientEvent:Connect(function(notifType, title, message, duration)
			if notifType == "LevelUp" then
				VFXController.ShowLevelUpEffect()
			end
		end)
	end

	print("[VFXController] Initialized successfully")
end

-- Initialize when script loads
initialize()

-- Expose controller for debugging
return VFXController
