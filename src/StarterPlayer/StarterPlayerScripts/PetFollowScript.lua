--[[
	PetFollowScript.lua
	Client-side pet following behavior
	Makes pets follow the player smoothly with offset positioning
	Part of the Homework Destroyer Pet System
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Local player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local FOLLOW_DISTANCE = 3 -- Distance from player
local FOLLOW_HEIGHT_OFFSET = 2 -- Height above player
local FOLLOW_SPEED = 0.15 -- Lerp speed (0-1, higher = faster)
local ROTATION_SPEED = 0.1 -- Pet rotation speed
local ORBIT_SPEED = 0.5 -- How fast pets orbit around player
local BOUNCE_HEIGHT = 0.3 -- Bobbing animation height
local BOUNCE_SPEED = 2 -- Bobbing animation speed

-- Pet tracking
local petModels = {}
local petFolder = nil
local orbitAngle = 0

-- ==================== INITIALIZATION ====================

local function initializePetTracking()
	-- Find the player's pet folder in workspace
	petFolder = workspace:FindFirstChild(player.Name .. "_Pets")

	if not petFolder then
		-- Wait for it to be created
		workspace.ChildAdded:Connect(function(child)
			if child.Name == player.Name .. "_Pets" then
				petFolder = child
				setupPetListeners()
			end
		end)
	else
		setupPetListeners()
	end
end

local function setupPetListeners()
	if not petFolder then return end

	-- Track existing pets
	for _, pet in ipairs(petFolder:GetChildren()) do
		if pet:IsA("BasePart") and pet.Name:match("^Pet_Slot") then
			trackPet(pet)
		end
	end

	-- Listen for new pets
	petFolder.ChildAdded:Connect(function(pet)
		if pet:IsA("BasePart") and pet.Name:match("^Pet_Slot") then
			trackPet(pet)
		end
	end)

	-- Listen for removed pets
	petFolder.ChildRemoved:Connect(function(pet)
		untrackPet(pet)
	end)
end

-- ==================== PET TRACKING ====================

local function trackPet(petModel)
	if not petModel:IsA("BasePart") then return end

	-- Get slot index
	local slotInfo = petModel:FindFirstChild("SlotIndex")
	local slotIndex = slotInfo and slotInfo.Value or 1

	-- Initialize pet data
	petModels[petModel] = {
		SlotIndex = slotIndex,
		BaseOffset = Vector3.new(0, 0, 0),
		CurrentOffset = Vector3.new(0, 0, 0),
		BouncePhase = math.random() * math.pi * 2, -- Random start phase for variety
		TargetPosition = Vector3.new(0, 0, 0),
		OrbitAngle = (slotIndex - 1) * (math.pi * 2 / 6) -- Divide circle into 6 slots
	}

	-- Get float height from pet config if available
	local petInfo = petModel:FindFirstChild("PetInfo")
	if petInfo and petInfo.Value and petInfo.Value.FloatHeight then
		petModels[petModel].FloatHeight = petInfo.Value.FloatHeight or FOLLOW_HEIGHT_OFFSET
	else
		petModels[petModel].FloatHeight = FOLLOW_HEIGHT_OFFSET
	end

	print("Now tracking pet in slot " .. slotIndex)
end

local function untrackPet(petModel)
	if petModels[petModel] then
		petModels[petModel] = nil
		print("Stopped tracking pet")
	end
end

-- ==================== POSITION CALCULATION ====================

local function calculatePetPosition(petData, deltaTime)
	if not humanoidRootPart then return Vector3.new(0, 0, 0) end

	-- Update orbit angle
	petData.OrbitAngle = petData.OrbitAngle + (ORBIT_SPEED * deltaTime)

	-- Calculate position around player
	local offsetX = math.cos(petData.OrbitAngle) * FOLLOW_DISTANCE
	local offsetZ = math.sin(petData.OrbitAngle) * FOLLOW_DISTANCE

	-- Calculate bobbing motion
	petData.BouncePhase = petData.BouncePhase + (BOUNCE_SPEED * deltaTime)
	local bounceOffset = math.sin(petData.BouncePhase) * BOUNCE_HEIGHT

	-- Combine offsets
	local basePosition = humanoidRootPart.Position
	local targetPosition = basePosition + Vector3.new(offsetX, petData.FloatHeight + bounceOffset, offsetZ)

	return targetPosition
end

local function calculatePetRotation(petModel, targetPosition)
	if not humanoidRootPart then return CFrame.new() end

	-- Look at player
	local lookVector = (humanoidRootPart.Position - targetPosition).Unit
	local rightVector = Vector3.new(0, 1, 0):Cross(lookVector)
	local upVector = lookVector:Cross(rightVector)

	-- Add gentle rotation
	local rotationAngle = tick() * ROTATION_SPEED
	local rotation = CFrame.fromMatrix(targetPosition, rightVector, upVector) * CFrame.Angles(0, rotationAngle, 0)

	return rotation
end

-- ==================== FOLLOW BEHAVIOR ====================

local function updatePetFollow(deltaTime)
	if not humanoidRootPart then
		-- Try to re-find humanoid root part
		if character and character:FindFirstChild("HumanoidRootPart") then
			humanoidRootPart = character.HumanoidRootPart
		else
			return
		end
	end

	-- Update each pet
	for petModel, petData in pairs(petModels) do
		if petModel and petModel.Parent then
			-- Calculate target position
			local targetPosition = calculatePetPosition(petData, deltaTime)

			-- Smoothly move pet using BodyPosition
			local bodyPosition = petModel:FindFirstChild("BodyPosition")
			if bodyPosition then
				-- Lerp to target position
				bodyPosition.Position = petModel.Position:Lerp(targetPosition, FOLLOW_SPEED)
			else
				-- Fallback: direct CFrame update
				petModel.CFrame = petModel.CFrame:Lerp(CFrame.new(targetPosition), FOLLOW_SPEED)
			end

			-- Update rotation using BodyGyro
			local bodyGyro = petModel:FindFirstChild("BodyGyro")
			if bodyGyro then
				local targetRotation = calculatePetRotation(petModel, targetPosition)
				bodyGyro.CFrame = targetRotation
			end

			-- Store target for debugging
			petData.TargetPosition = targetPosition
		else
			-- Pet was destroyed, clean up
			petModels[petModel] = nil
		end
	end
end

-- ==================== CHARACTER RESPAWN HANDLING ====================

local function onCharacterAdded(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- Wait a moment for pets to be recreated
	wait(0.5)

	-- Reset pet tracking
	petModels = {}
	initializePetTracking()
end

player.CharacterAdded:Connect(onCharacterAdded)

-- ==================== MAIN UPDATE LOOP ====================

local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
	local currentTime = tick()
	local deltaTime = currentTime - lastUpdate
	lastUpdate = currentTime

	-- Update pet following
	updatePetFollow(deltaTime)
end)

-- ==================== ADDITIONAL FEATURES ====================

-- Pet interaction (click to show info)
local function onPetClicked(petModel)
	local petInfo = petModel:FindFirstChild("PetInfo")
	if not petInfo or not petInfo.Value then return end

	local pet = petInfo.Value
	local petData = pet -- This would link to PetConfig in a real implementation

	-- Display pet information (integrate with your UI system)
	print("Pet Info:")
	print("- Name: " .. (pet.PetId or "Unknown"))
	print("- Rarity: " .. (pet.Rarity or "Unknown"))
	print("- Level: " .. (pet.Level or 1))
end

-- Listen for pet clicks
local function setupPetClickDetection(petModel)
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 15
	clickDetector.Parent = petModel

	clickDetector.MouseClick:Connect(function(playerWhoClicked)
		if playerWhoClicked == player then
			onPetClicked(petModel)
		end
	end)
end

-- Enhanced tracking with click detection
local originalTrackPet = trackPet
trackPet = function(petModel)
	originalTrackPet(petModel)
	setupPetClickDetection(petModel)
end

-- ==================== VISUAL EFFECTS ====================

local function addPetParticles(petModel, rarity)
	-- Add particle effects based on rarity
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "RarityParticles"

	if rarity == "Legendary" or rarity == "Mythic" then
		particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particleEmitter.Rate = 20
		particleEmitter.Lifetime = NumberRange.new(0.5, 1)
		particleEmitter.Speed = NumberRange.new(0.5, 1)
		particleEmitter.SpreadAngle = Vector2.new(360, 360)
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 0)
		})

		if rarity == "Mythic" then
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 85, 85))
		else
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 170, 0))
		end

		particleEmitter.Parent = petModel
	end
end

-- Add particles to tracked pets
local originalTrackPetWithParticles = trackPet
trackPet = function(petModel)
	originalTrackPetWithParticles(petModel)

	-- Get rarity from pet info
	local petInfo = petModel:FindFirstChild("PetInfo")
	if petInfo and petInfo.Value and petInfo.Value.Rarity then
		addPetParticles(petModel, petInfo.Value.Rarity)
	end
end

-- ==================== FORMATION MODES ====================

-- Different formation patterns for pets
local FormationModes = {
	Circle = function(slotIndex, totalPets)
		local angle = (slotIndex - 1) * (math.pi * 2 / math.max(totalPets, 1))
		return Vector3.new(
			math.cos(angle) * FOLLOW_DISTANCE,
			0,
			math.sin(angle) * FOLLOW_DISTANCE
		)
	end,

	Line = function(slotIndex, totalPets)
		local offset = (slotIndex - (totalPets / 2)) * 2
		return Vector3.new(offset, 0, -FOLLOW_DISTANCE)
	end,

	VFormation = function(slotIndex, totalPets)
		local side = (slotIndex % 2 == 0) and 1 or -1
		local row = math.floor(slotIndex / 2)
		return Vector3.new(side * row * 2, 0, -row * 2 - FOLLOW_DISTANCE)
	end
}

-- Current formation mode (can be changed via UI)
local currentFormation = "Circle"

-- Update formation in position calculation
local function getFormationOffset(slotIndex)
	local totalPets = 0
	for _ in pairs(petModels) do
		totalPets = totalPets + 1
	end

	local formationFunc = FormationModes[currentFormation] or FormationModes.Circle
	return formationFunc(slotIndex, totalPets)
end

-- ==================== DEBUG VISUALIZATION ====================

local DEBUG_MODE = false -- Set to true to see pet target positions

local function createDebugMarker(position)
	if not DEBUG_MODE then return end

	local marker = Instance.new("Part")
	marker.Name = "DebugMarker"
	marker.Size = Vector3.new(0.5, 0.5, 0.5)
	marker.Anchored = true
	marker.CanCollide = false
	marker.Transparency = 0.5
	marker.Color = Color3.fromRGB(255, 0, 0)
	marker.Position = position
	marker.Parent = workspace
	marker.TopSurface = Enum.SurfaceType.Smooth
	marker.BottomSurface = Enum.SurfaceType.Smooth

	game:GetService("Debris"):AddItem(marker, 0.1)
end

-- ==================== PERFORMANCE OPTIMIZATION ====================

-- Reduce update frequency for distant pets
local function shouldUpdatePet(petModel)
	if not humanoidRootPart then return false end

	local distance = (petModel.Position - humanoidRootPart.Position).Magnitude

	-- Always update close pets
	if distance < FOLLOW_DISTANCE * 2 then
		return true
	end

	-- Update distant pets less frequently
	return tick() % 2 < 0.1 -- ~5% of frames for distant pets
end

-- Enhanced update with performance optimization
local originalUpdatePetFollow = updatePetFollow
updatePetFollow = function(deltaTime)
	if not humanoidRootPart then
		if character and character:FindFirstChild("HumanoidRootPart") then
			humanoidRootPart = character.HumanoidRootPart
		else
			return
		end
	end

	for petModel, petData in pairs(petModels) do
		if petModel and petModel.Parent and shouldUpdatePet(petModel) then
			local targetPosition = calculatePetPosition(petData, deltaTime)

			local bodyPosition = petModel:FindFirstChild("BodyPosition")
			if bodyPosition then
				bodyPosition.Position = petModel.Position:Lerp(targetPosition, FOLLOW_SPEED)
			end

			local bodyGyro = petModel:FindFirstChild("BodyGyro")
			if bodyGyro then
				local targetRotation = calculatePetRotation(petModel, targetPosition)
				bodyGyro.CFrame = targetRotation
			end

			petData.TargetPosition = targetPosition

			-- Debug visualization
			createDebugMarker(targetPosition)
		elseif not petModel or not petModel.Parent then
			petModels[petModel] = nil
		end
	end
end

-- ==================== START SYSTEM ====================

print("Pet Follow System initialized for " .. player.Name)
initializePetTracking()
