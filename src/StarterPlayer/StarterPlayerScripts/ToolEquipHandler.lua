--[[
	ToolEquipHandler.lua
	Client-side tool/weapon handling for Homework Destroyer

	Handles:
	- Visual tool representation (3D models in player's hands)
	- Tool animations and effects
	- Dual-wield display
	- Tool switching and hotkeys
	- Click attack animations
	- Special effect particles
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ToolEquipHandler = {}

-- Module Dependencies
local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)

-- Local player reference
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Tool models storage
local equippedToolModels = {
	Primary = nil,
	Secondary = nil
}

-- Current tool data
local currentToolData = {
	Primary = nil,
	Secondary = nil
}

-- Animation tracks
local animationTracks = {
	PrimarySwing = nil,
	SecondarySwing = nil,
	Idle = nil,
	DualWieldIdle = nil
}

-- Tool visual settings
local TOOL_SETTINGS = {
	PrimaryOffset = CFrame.new(0.5, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)),
	SecondaryOffset = CFrame.new(-0.5, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)),
	SwingDuration = 0.2,
	SwingRotation = 120, -- degrees
}

-- Click tracking
local lastClickTime = 0
local clickCooldown = 0.2 -- Default cooldown
local isSwinging = false

-- Effect colors for rarities
local RARITY_COLORS = {
	Common = Color3.fromRGB(255, 255, 255),
	Uncommon = Color3.fromRGB(30, 255, 0),
	Rare = Color3.fromRGB(0, 112, 221),
	Epic = Color3.fromRGB(163, 53, 238),
	Legendary = Color3.fromRGB(255, 128, 0),
	Mythic = Color3.fromRGB(255, 0, 0),
	SECRET = Color3.fromRGB(255, 255, 255) -- Will have rainbow effect
}

-- ========================================
-- INITIALIZATION
-- ========================================

function ToolEquipHandler.Initialize()
	print("[ToolEquipHandler] Initializing...")

	-- Update character reference if respawned
	player.CharacterAdded:Connect(function(newCharacter)
		character = newCharacter
		humanoid = character:WaitForChild("Humanoid")
		ToolEquipHandler.ClearAllTools()
	end)

	-- Listen for tool data updates from server
	local dataUpdate = RemoteEvents.GetEvent("DataUpdate")
	if dataUpdate then
		dataUpdate.OnClientEvent:Connect(function(dataType, newValue)
			if dataType == "Tools" then
				ToolEquipHandler.OnToolDataUpdate(newValue)
			end
		end)
	end

	-- Setup input handling
	ToolEquipHandler.SetupInputHandling()

	print("[ToolEquipHandler] Initialized successfully")
end

-- ========================================
-- TOOL EQUIPPING
-- ========================================

-- Update equipped tools based on server data
function ToolEquipHandler.OnToolDataUpdate(toolData)
	-- Clear existing tools
	ToolEquipHandler.ClearAllTools()

	-- Equip primary tool
	if toolData.Equipped then
		ToolEquipHandler.EquipTool(toolData.Equipped, "Primary", toolData.UpgradeLevels[toolData.Equipped] or 0)
	end

	-- Equip secondary tool (dual-wield)
	if toolData.EquippedSecondary then
		ToolEquipHandler.EquipTool(toolData.EquippedSecondary, "Secondary", toolData.UpgradeLevels[toolData.EquippedSecondary] or 0)
	end
end

-- Equip a tool visually
function ToolEquipHandler.EquipTool(toolID, slot, upgradeLevel)
	if not character or not character.Parent then
		return
	end

	-- Store tool data
	local toolData = {
		ID = toolID,
		Slot = slot,
		UpgradeLevel = upgradeLevel
	}

	if slot == "Primary" then
		currentToolData.Primary = toolData
	else
		currentToolData.Secondary = toolData
	end

	-- Create visual tool model
	local toolModel = ToolEquipHandler.CreateToolModel(toolID, slot, upgradeLevel)

	if toolModel then
		-- Attach to character
		ToolEquipHandler.AttachToolToCharacter(toolModel, slot)

		-- Store reference
		if slot == "Primary" then
			equippedToolModels.Primary = toolModel
		else
			equippedToolModels.Secondary = toolModel
		end

		-- Play equip effect
		ToolEquipHandler.PlayEquipEffect(toolModel, toolID)
	end

	-- Update idle animation
	ToolEquipHandler.UpdateIdleAnimation()
end

-- Create visual tool model
function ToolEquipHandler.CreateToolModel(toolID, slot, upgradeLevel)
	-- In a full implementation, this would load actual 3D models
	-- For now, create a simple placeholder

	local toolModel = Instance.new("Model")
	toolModel.Name = toolID .. "_" .. slot

	-- Create handle part
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.3, 1.5, 0.3)
	handle.Material = Enum.Material.Neon
	handle.CanCollide = false
	handle.Anchored = false

	-- Color based on rarity (would get from ToolsConfig in real implementation)
	local rarityColor = RARITY_COLORS.Common
	if upgradeLevel >= 5 then
		rarityColor = RARITY_COLORS.Rare
	elseif upgradeLevel >= 8 then
		rarityColor = RARITY_COLORS.Epic
	end
	handle.Color = rarityColor

	handle.Parent = toolModel

	-- Add weld placeholder
	local weld = Instance.new("Weld")
	weld.Name = "ToolWeld"
	weld.Part0 = handle
	weld.Parent = handle

	-- Add particle effect for upgraded tools
	if upgradeLevel > 0 then
		local particle = Instance.new("ParticleEmitter")
		particle.Name = "UpgradeParticle"
		particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particle.Color = ColorSequence.new(rarityColor)
		particle.Size = NumberSequence.new(0.1)
		particle.Lifetime = NumberRange.new(0.5, 1)
		particle.Rate = 5 + (upgradeLevel * 2)
		particle.Speed = NumberRange.new(1, 2)
		particle.Parent = handle
	end

	return toolModel
end

-- Attach tool model to character
function ToolEquipHandler.AttachToolToCharacter(toolModel, slot)
	if not character or not character.Parent then
		return
	end

	local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
	local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftHand")

	if not rightArm then
		warn("[ToolEquipHandler] Cannot find right arm!")
		return
	end

	local handle = toolModel:FindFirstChild("Handle")
	if not handle then
		warn("[ToolEquipHandler] Tool has no handle!")
		return
	end

	local weld = handle:FindFirstChild("ToolWeld")
	if not weld then
		warn("[ToolEquipHandler] Tool has no weld!")
		return
	end

	-- Attach to appropriate hand
	if slot == "Primary" then
		weld.Part1 = rightArm
		weld.C1 = TOOL_SETTINGS.PrimaryOffset
	elseif slot == "Secondary" then
		if leftArm then
			weld.Part1 = leftArm
			weld.C1 = TOOL_SETTINGS.SecondaryOffset
		else
			warn("[ToolEquipHandler] Cannot find left arm for dual-wield!")
			return
		end
	end

	-- Parent to character
	toolModel.Parent = character
end

-- Clear all equipped tools
function ToolEquipHandler.ClearAllTools()
	if equippedToolModels.Primary then
		equippedToolModels.Primary:Destroy()
		equippedToolModels.Primary = nil
	end

	if equippedToolModels.Secondary then
		equippedToolModels.Secondary:Destroy()
		equippedToolModels.Secondary = nil
	end

	currentToolData.Primary = nil
	currentToolData.Secondary = nil
end

-- ========================================
-- ANIMATIONS
-- ========================================

-- Update idle animation based on equipped tools
function ToolEquipHandler.UpdateIdleAnimation()
	-- Stop existing idle animations
	if animationTracks.Idle then
		animationTracks.Idle:Stop()
		animationTracks.Idle = nil
	end

	if animationTracks.DualWieldIdle then
		animationTracks.DualWieldIdle:Stop()
		animationTracks.DualWieldIdle = nil
	end

	-- Play appropriate idle animation
	if currentToolData.Secondary then
		-- Dual-wield idle
		ToolEquipHandler.PlayAnimation("DualWieldIdle", true)
	elseif currentToolData.Primary then
		-- Single tool idle
		ToolEquipHandler.PlayAnimation("Idle", true)
	end
end

-- Play swing animation
function ToolEquipHandler.PlaySwingAnimation(slot)
	if isSwinging then
		return
	end

	isSwinging = true

	local toolModel = slot == "Primary" and equippedToolModels.Primary or equippedToolModels.Secondary
	if not toolModel then
		isSwinging = false
		return
	end

	local handle = toolModel:FindFirstChild("Handle")
	if not handle then
		isSwinging = false
		return
	end

	-- Create swing animation with TweenService
	local weld = handle:FindFirstChild("ToolWeld")
	if weld then
		local originalC1 = weld.C1
		local swingC1 = originalC1 * CFrame.Angles(math.rad(TOOL_SETTINGS.SwingRotation), 0, 0)

		-- Swing forward
		local swingForward = TweenService:Create(
			weld,
			TweenInfo.new(TOOL_SETTINGS.SwingDuration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{C1 = swingC1}
		)

		-- Swing back
		local swingBack = TweenService:Create(
			weld,
			TweenInfo.new(TOOL_SETTINGS.SwingDuration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{C1 = originalC1}
		)

		swingForward:Play()
		swingForward.Completed:Connect(function()
			swingBack:Play()
		end)

		swingBack.Completed:Connect(function()
			isSwinging = false
		end)
	else
		isSwinging = false
	end

	-- Play whoosh sound
	ToolEquipHandler.PlaySwingSound(handle)

	-- Create swing trail effect
	ToolEquipHandler.CreateSwingTrail(handle)
end

-- Play animation helper
function ToolEquipHandler.PlayAnimation(animName, loop)
	-- In a full implementation, this would load actual animations
	-- For now, just store a placeholder

	if not humanoid then
		return
	end

	-- Would load animation from catalog or create custom animations
	-- animationTracks[animName] = humanoid:LoadAnimation(animation)
	-- if animationTracks[animName] then
	--     animationTracks[animName].Looped = loop or false
	--     animationTracks[animName]:Play()
	-- end
end

-- ========================================
-- VISUAL EFFECTS
-- ========================================

-- Play equip effect
function ToolEquipHandler.PlayEquipEffect(toolModel, toolID)
	local handle = toolModel:FindFirstChild("Handle")
	if not handle then
		return
	end

	-- Create flash effect
	local flash = Instance.new("PointLight")
	flash.Brightness = 5
	flash.Range = 10
	flash.Color = handle.Color
	flash.Parent = handle

	-- Fade out light
	task.spawn(function()
		for i = 1, 10 do
			flash.Brightness = flash.Brightness * 0.8
			task.wait(0.05)
		end
		flash:Destroy()
	end)

	-- Play equip sound
	local equipSound = Instance.new("Sound")
	equipSound.SoundId = "rbxasset://sounds/unsheath.wav"
	equipSound.Volume = 0.5
	equipSound.Parent = handle
	equipSound:Play()

	equipSound.Ended:Connect(function()
		equipSound:Destroy()
	end)
end

-- Play swing sound
function ToolEquipHandler.PlaySwingSound(handle)
	local swingSound = Instance.new("Sound")
	swingSound.SoundId = "rbxasset://sounds/swordslash.wav"
	swingSound.Volume = 0.3
	swingSound.Pitch = 1 + math.random(-10, 10) / 100 -- Slight pitch variation
	swingSound.Parent = handle
	swingSound:Play()

	swingSound.Ended:Connect(function()
		swingSound:Destroy()
	end)
end

-- Create swing trail effect
function ToolEquipHandler.CreateSwingTrail(handle)
	-- Create a trail effect
	local trail = Instance.new("Trail")
	trail.Lifetime = 0.3
	trail.Color = ColorSequence.new(handle.Color)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.WidthScale = NumberSequence.new(1)

	-- Create attachments for trail
	local attachment0 = Instance.new("Attachment")
	attachment0.Position = Vector3.new(0, -handle.Size.Y / 2, 0)
	attachment0.Parent = handle

	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0, handle.Size.Y / 2, 0)
	attachment1.Parent = handle

	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Parent = handle

	-- Remove trail after swing
	task.delay(TOOL_SETTINGS.SwingDuration + 0.5, function()
		trail.Enabled = false
		task.wait(trail.Lifetime)
		trail:Destroy()
		attachment0:Destroy()
		attachment1:Destroy()
	end)
end

-- Create hit effect at position
function ToolEquipHandler.CreateHitEffect(position, isCritical)
	local hitPart = Instance.new("Part")
	hitPart.Size = Vector3.new(1, 1, 1)
	hitPart.Position = position
	hitPart.Anchored = true
	hitPart.CanCollide = false
	hitPart.Transparency = 1
	hitPart.Parent = workspace

	-- Create particle emitter
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particles.Color = ColorSequence.new(isCritical and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 100, 100))
	particles.Size = NumberSequence.new(isCritical and 2 or 1)
	particles.Lifetime = NumberRange.new(0.3, 0.5)
	particles.Rate = 100
	particles.Speed = NumberRange.new(5, 10)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Parent = hitPart

	-- Emit particles
	particles:Emit(isCritical and 30 or 15)

	-- Play hit sound
	local hitSound = Instance.new("Sound")
	hitSound.SoundId = isCritical and "rbxasset://sounds/electronicpingshort.wav" or "rbxasset://sounds/button.wav"
	hitSound.Volume = 0.5
	hitSound.Pitch = isCritical and 0.8 or 1.2
	hitSound.Parent = hitPart
	hitSound:Play()

	-- Cleanup
	task.delay(2, function()
		hitPart:Destroy()
	end)
end

-- ========================================
-- INPUT HANDLING
-- ========================================

function ToolEquipHandler.SetupInputHandling()
	-- Handle mouse clicks for attacking
	local mouse = player:GetMouse()

	mouse.Button1Down:Connect(function()
		ToolEquipHandler.OnClickAttack()
	end)

	-- Handle hotkeys for tool switching (1 and 2 keys)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		-- Key 1: Request primary tool slot
		if input.KeyCode == Enum.KeyCode.One then
			-- Would open tool selection UI for primary slot
		end

		-- Key 2: Request secondary tool slot (if dual-wield unlocked)
		if input.KeyCode == Enum.KeyCode.Two then
			-- Would open tool selection UI for secondary slot
		end
	end)
end

-- Handle click attack
function ToolEquipHandler.OnClickAttack()
	-- Check cooldown
	local currentTime = tick()
	if currentTime - lastClickTime < clickCooldown then
		return
	end

	lastClickTime = currentTime

	-- Play swing animation
	if currentToolData.Primary then
		ToolEquipHandler.PlaySwingAnimation("Primary")
	end

	-- Play secondary swing if dual-wielding
	if currentToolData.Secondary then
		task.delay(0.1, function() -- Slight delay for dual-wield effect
			ToolEquipHandler.PlaySwingAnimation("Secondary")
		end)
	end

	-- This would integrate with the main click handler to detect what homework was clicked
	-- The actual damage calculation and application happens on the server
end

-- Update click cooldown (called by main game when stats change)
function ToolEquipHandler.UpdateClickCooldown(newCooldown)
	clickCooldown = newCooldown
end

-- ========================================
-- SPECIAL EFFECT DISPLAYS
-- ========================================

-- Show special effect notification
function ToolEquipHandler.ShowSpecialEffect(effectType, position)
	if effectType == "InstantKill" then
		-- Create dramatic instant kill effect
		local explosion = Instance.new("Explosion")
		explosion.Position = position
		explosion.BlastRadius = 5
		explosion.BlastPressure = 0
		explosion.Parent = workspace

		-- Visual effect
		local effectPart = Instance.new("Part")
		effectPart.Size = Vector3.new(5, 5, 5)
		effectPart.Position = position
		effectPart.Anchored = true
		effectPart.CanCollide = false
		effectPart.Material = Enum.Material.Neon
		effectPart.Color = Color3.fromRGB(255, 0, 0)
		effectPart.Transparency = 0.5
		effectPart.Parent = workspace

		-- Tween fade out
		local tween = TweenService:Create(
			effectPart,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Transparency = 1, Size = Vector3.new(10, 10, 10)}
		)

		tween:Play()
		tween.Completed:Connect(function()
			effectPart:Destroy()
		end)
	elseif effectType == "Mark" then
		-- Create mark indicator above target
		-- Would create a UI billboard or particle effect
	elseif effectType == "Corrode" then
		-- Create corrosion particle effect
		-- Would show acid/corrosion particles on target
	end
end

-- ========================================
-- DUAL-WIELD DISPLAY
-- ========================================

-- Check if dual-wield is active
function ToolEquipHandler.IsDualWielding()
	return currentToolData.Primary ~= nil and currentToolData.Secondary ~= nil
end

-- Get equipped tool count
function ToolEquipHandler.GetEquippedToolCount()
	local count = 0
	if currentToolData.Primary then count = count + 1 end
	if currentToolData.Secondary then count = count + 1 end
	return count
end

-- ========================================
-- PUBLIC API
-- ========================================

-- Get current tool data (for UI display)
function ToolEquipHandler.GetCurrentToolData()
	return {
		Primary = currentToolData.Primary,
		Secondary = currentToolData.Secondary,
		IsDualWielding = ToolEquipHandler.IsDualWielding()
	}
end

-- Manually trigger hit effect (called by click handler when hit lands)
function ToolEquipHandler.OnHitLanded(position, isCritical)
	ToolEquipHandler.CreateHitEffect(position, isCritical)
end

-- Auto-initialize when script runs
ToolEquipHandler.Initialize()

return ToolEquipHandler
