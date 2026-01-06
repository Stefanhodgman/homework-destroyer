--[[
	ClickHandler.lua
	Client-side click detection and feedback system for Homework Destroyer

	Handles:
	- Click detection on homework objects
	- Visual/audio feedback for clicks
	- Communication with server via RemoteEvents
	- Smooth rapid clicking
	- Critical hit effects
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Wait for RemoteEvents to load
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClickHomeworkEvent = Remotes:WaitForChild("ClickHomework", 5) or Instance.new("RemoteEvent")
if not ClickHomeworkEvent.Parent then
	ClickHomeworkEvent.Name = "ClickHomework"
	ClickHomeworkEvent.Parent = Remotes
end

-- Click cooldown management
local CLICK_COOLDOWN = 0.1 -- 10 clicks per second max
local lastClickTime = 0
local clickCount = 0
local clickComboResetTime = 1 -- Reset combo after 1 second of no clicks

-- Visual effect settings
local DAMAGE_NUMBER_DURATION = 1.5
local PARTICLE_COLORS = {
	Normal = Color3.fromRGB(255, 255, 255),
	Critical = Color3.fromRGB(255, 215, 0), -- Gold
	Paper = Color3.fromRGB(255, 240, 220),
}

-- Sound effect IDs (placeholder - replace with actual Roblox sound IDs)
local SOUNDS = {
	Hit = "rbxassetid://0", -- Rip/crunch sound
	Critical = "rbxassetid://0", -- Boom sound
	Destroy = "rbxassetid://0", -- Cha-ching sound
}

--[[
	Creates floating damage numbers above the homework object
--]]
local function createDamageNumber(position, damage, isCritical)
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = nil
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = camera

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = isCritical and ("CRIT! " .. tostring(damage)) or tostring(damage)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = isCritical and 24 or 18
	textLabel.TextColor3 = isCritical and PARTICLE_COLORS.Critical or Color3.white
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.Parent = billboard

	-- Position the billboard in world space
	billboard.Enabled = true
	local part = Instance.new("Part")
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Position = position
	part.Parent = workspace
	billboard.Adornee = part

	-- Animate the damage number
	local tweenInfo = TweenInfo.new(
		DAMAGE_NUMBER_DURATION,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local tweenGoal = {
		StudsOffset = Vector3.new(math.random(-1, 1), 4, math.random(-1, 1))
	}

	local tween = TweenService:Create(billboard, tweenInfo, tweenGoal)
	tween:Play()

	-- Fade out
	local fadeTween = TweenService:Create(
		textLabel,
		TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, DAMAGE_NUMBER_DURATION - 0.5),
		{TextTransparency = 1, TextStrokeTransparency = 1}
	)
	fadeTween:Play()

	-- Clean up
	Debris:AddItem(part, DAMAGE_NUMBER_DURATION)
	Debris:AddItem(billboard, DAMAGE_NUMBER_DURATION)
end

--[[
	Creates particle effects for hit feedback
--]]
local function createHitParticles(position, isCritical)
	local attachment = Instance.new("Attachment")
	local part = Instance.new("Part")
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Position = position
	part.Parent = workspace
	attachment.Parent = part

	-- Paper tear particles
	local particles = Instance.new("ParticleEmitter")
	particles.Parent = attachment
	particles.Color = ColorSequence.new(isCritical and PARTICLE_COLORS.Critical or PARTICLE_COLORS.Paper)
	particles.Size = NumberSequence.new(0.3, 0.1)
	particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particles.Lifetime = NumberRange.new(0.5, 1)
	particles.Rate = isCritical and 100 or 50
	particles.Speed = NumberRange.new(5, isCritical and 15 or 10)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Enabled = true

	-- Ink splatter particles
	local inkParticles = Instance.new("ParticleEmitter")
	inkParticles.Parent = attachment
	inkParticles.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
	inkParticles.Size = NumberSequence.new(0.2, 0.05)
	inkParticles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	inkParticles.Lifetime = NumberRange.new(0.3, 0.8)
	inkParticles.Rate = 30
	inkParticles.Speed = NumberRange.new(3, 8)
	inkParticles.SpreadAngle = Vector2.new(90, 90)
	inkParticles.Enabled = true

	-- Screen shake for critical hits
	if isCritical then
		local cameraCFrame = camera.CFrame
		local shakeAmount = 0.5
		local shakeDuration = 0.2

		task.spawn(function()
			local startTime = tick()
			while tick() - startTime < shakeDuration do
				local randomOffset = Vector3.new(
					math.random() * shakeAmount - shakeAmount/2,
					math.random() * shakeAmount - shakeAmount/2,
					math.random() * shakeAmount - shakeAmount/2
				)
				camera.CFrame = cameraCFrame * CFrame.new(randomOffset)
				task.wait()
			end
			camera.CFrame = cameraCFrame
		end)
	end

	-- Disable particles after a short burst
	task.wait(0.1)
	particles.Enabled = false
	inkParticles.Enabled = false

	-- Clean up
	Debris:AddItem(part, 2)
end

--[[
	Plays sound effect for click feedback
--]]
local function playSoundEffect(soundId, parent)
	if soundId == "rbxassetid://0" then
		return -- Skip placeholder sounds
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = parent or workspace
	sound:Play()

	Debris:AddItem(sound, 3)
end

--[[
	Handles click on homework object
--]]
local function onHomeworkClick(homeworkObject)
	-- Check cooldown
	local currentTime = tick()
	if currentTime - lastClickTime < CLICK_COOLDOWN then
		return
	end
	lastClickTime = currentTime

	-- Increment click combo
	clickCount = clickCount + 1
	task.delay(clickComboResetTime, function()
		clickCount = math.max(0, clickCount - 1)
	end)

	-- Validate homework object
	if not homeworkObject or not homeworkObject:IsA("Model") or not homeworkObject:FindFirstChild("Health") then
		return
	end

	-- Get click position
	local clickPosition = mouse.Hit.Position

	-- Send click to server
	local success, result = pcall(function()
		return ClickHomeworkEvent:InvokeServer(homeworkObject, clickPosition)
	end)

	if not success then
		warn("Failed to send click to server:", result)
		return
	end

	-- Result contains: {damage = number, isCritical = boolean, destroyed = boolean}
	if result and result.damage then
		-- Create visual feedback
		createDamageNumber(clickPosition, result.damage, result.isCritical)
		createHitParticles(clickPosition, result.isCritical)

		-- Play sound effects
		if result.destroyed then
			playSoundEffect(SOUNDS.Destroy, homeworkObject)
		elseif result.isCritical then
			playSoundEffect(SOUNDS.Critical, homeworkObject)
		else
			playSoundEffect(SOUNDS.Hit, homeworkObject)
		end

		-- Visual feedback on the homework object itself
		if homeworkObject and homeworkObject.PrimaryPart then
			local originalColor = homeworkObject.PrimaryPart.Color
			homeworkObject.PrimaryPart.Color = result.isCritical and PARTICLE_COLORS.Critical or Color3.new(1, 1, 1)

			task.delay(0.1, function()
				if homeworkObject and homeworkObject.PrimaryPart then
					homeworkObject.PrimaryPart.Color = originalColor
				end
			end)
		end
	end
end

--[[
	Checks if target is a homework object
--]]
local function isHomeworkObject(target)
	if not target then return false end

	-- Check if it's part of a homework model
	local model = target:FindFirstAncestorOfClass("Model")
	if model and model:FindFirstChild("HomeworkTag") and model:FindFirstChild("Health") then
		return true, model
	end

	return false
end

--[[
	Main click handler
--]]
local function onMouseClick()
	local target = mouse.Target
	local isHomework, homeworkModel = isHomeworkObject(target)

	if isHomework then
		onHomeworkClick(homeworkModel)
	end
end

--[[
	Initialize click detection
--]]
local function initialize()
	-- Connect mouse click
	mouse.Button1Down:Connect(onMouseClick)

	-- Also support touch on mobile
	UserInputService.TouchTap:Connect(function(touchPositions, gameProcessedEvent)
		if gameProcessedEvent then return end

		local ray = camera:ViewportPointToRay(touchPositions[1].X, touchPositions[1].Y)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {player.Character}

		local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
		if result then
			local isHomework, homeworkModel = isHomeworkObject(result.Instance)
			if isHomework then
				onHomeworkClick(homeworkModel)
			end
		end
	end)

	print("ClickHandler initialized")
end

-- Initialize when script loads
initialize()

-- Expose functions for other scripts if needed
return {
	CreateDamageNumber = createDamageNumber,
	CreateHitParticles = createHitParticles,
}
