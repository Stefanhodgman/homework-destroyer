--[[
	HomeworkAnimator.lua
	Handles visual animations for homework models

	Responsibilities:
	- Floating/bobbing animation for all homework
	- Boss light pulsing effects
	- Orbiter rotation for boss models
	- Smooth transitions and performance optimization
--]]

local HomeworkAnimator = {}
HomeworkAnimator.__index = HomeworkAnimator

-- Services
local RunService = game:GetService("RunService")

-- Constants
local FLOAT_SPEED = 1.5 -- Speed of bobbing motion
local FLOAT_HEIGHT = 0.8 -- Height of bob in studs
local BOSS_PULSE_SPEED = 2 -- Speed of boss light pulsing
local ORBITER_ROTATION_SPEED = 30 -- Degrees per second for boss orbiters

--[[
	Constructor
	Creates a new HomeworkAnimator to manage all homework animations
--]]
function HomeworkAnimator.new()
	local self = setmetatable({}, HomeworkAnimator)

	self.ActiveHomework = {} -- Track all animated homework
	self.IsRunning = false
	self.UpdateConnection = nil
	self.StartTime = tick()

	return self
end

--[[
	Start the animation system
--]]
function HomeworkAnimator:Start()
	if self.IsRunning then
		return
	end

	self.IsRunning = true
	self.StartTime = tick()

	-- Connect to RunService for smooth animations
	self.UpdateConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self:Update(deltaTime)
	end)

	print("HomeworkAnimator: Started")
end

--[[
	Stop the animation system
--]]
function HomeworkAnimator:Stop()
	if not self.IsRunning then
		return
	end

	self.IsRunning = false

	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
		self.UpdateConnection = nil
	end

	print("HomeworkAnimator: Stopped")
end

--[[
	Register a homework model for animation
--]]
function HomeworkAnimator:RegisterHomework(homeworkModel, isBoss)
	if not homeworkModel or not homeworkModel.PrimaryPart then
		return
	end

	-- Store animation data
	self.ActiveHomework[homeworkModel] = {
		Model = homeworkModel,
		IsBoss = isBoss or false,
		OriginalPosition = homeworkModel.PrimaryPart.Position,
		FloatOffset = math.random() * math.pi * 2, -- Random phase for variety
		Orbiters = {},
		BossLights = {}
	}

	-- If boss, find orbiters and lights
	if isBoss then
		local data = self.ActiveHomework[homeworkModel]

		-- Find orbiters
		for _, child in ipairs(homeworkModel:GetChildren()) do
			if child:IsA("BasePart") and string.match(child.Name, "Orbiter") then
				table.insert(data.Orbiters, {
					Part = child,
					OriginalPosition = child.Position,
					Angle = 0
				})
			end
		end

		-- Find boss pulse lights
		if homeworkModel.PrimaryPart then
			for _, child in ipairs(homeworkModel.PrimaryPart:GetChildren()) do
				if child:IsA("PointLight") and child.Name == "BossPulse" then
					table.insert(data.BossLights, child)
				end
			end
		end
	end
end

--[[
	Unregister a homework model (when destroyed)
--]]
function HomeworkAnimator:UnregisterHomework(homeworkModel)
	self.ActiveHomework[homeworkModel] = nil
end

--[[
	Main update loop - animates all homework
--]]
function HomeworkAnimator:Update(deltaTime)
	local currentTime = tick() - self.StartTime

	-- Clean up destroyed models
	local toRemove = {}
	for model, data in pairs(self.ActiveHomework) do
		if not model or not model.Parent or not model:IsDescendantOf(game) then
			table.insert(toRemove, model)
		end
	end

	for _, model in ipairs(toRemove) do
		self:UnregisterHomework(model)
	end

	-- Animate all active homework
	for model, data in pairs(self.ActiveHomework) do
		if model.PrimaryPart then
			-- Apply floating animation
			self:AnimateFloating(data, currentTime)

			-- Apply boss-specific animations
			if data.IsBoss then
				self:AnimateBossEffects(data, currentTime, deltaTime)
			end
		end
	end
end

--[[
	Animate floating/bobbing motion
--]]
function HomeworkAnimator:AnimateFloating(homeworkData, currentTime)
	local model = homeworkData.Model
	if not model or not model.PrimaryPart then
		return
	end

	-- Calculate sine wave for smooth bobbing
	local phase = currentTime * FLOAT_SPEED + homeworkData.FloatOffset
	local offsetY = math.sin(phase) * FLOAT_HEIGHT

	-- Apply position
	local newPosition = homeworkData.OriginalPosition + Vector3.new(0, offsetY, 0)
	model.PrimaryPart.Position = newPosition
end

--[[
	Animate boss-specific effects (pulsing lights, orbiter rotation)
--]]
function HomeworkAnimator:AnimateBossEffects(homeworkData, currentTime, deltaTime)
	local model = homeworkData.Model
	if not model or not model.PrimaryPart then
		return
	end

	-- Pulse boss lights
	for _, light in ipairs(homeworkData.BossLights) do
		if light and light.Parent then
			-- Sine wave pulsing (brightness 2-5)
			local pulse = math.sin(currentTime * BOSS_PULSE_SPEED) * 0.5 + 0.5
			light.Brightness = 2 + pulse * 3
		end
	end

	-- Rotate orbiters around the boss
	for _, orbiterData in ipairs(homeworkData.Orbiters) do
		if orbiterData.Part and orbiterData.Part.Parent then
			-- Update angle
			orbiterData.Angle = orbiterData.Angle + (ORBITER_ROTATION_SPEED * deltaTime)
			if orbiterData.Angle >= 360 then
				orbiterData.Angle = orbiterData.Angle - 360
			end

			-- Calculate new position relative to boss center
			local bossCenter = model.PrimaryPart.Position
			local radius = (orbiterData.OriginalPosition - bossCenter).Magnitude
			local angleRad = math.rad(orbiterData.Angle)

			-- Calculate offset from original angle
			local originalAngleRad = math.atan2(
				orbiterData.OriginalPosition.Z - bossCenter.Z,
				orbiterData.OriginalPosition.X - bossCenter.X
			)
			local totalAngle = originalAngleRad + angleRad

			-- Apply new position (maintain original Y offset)
			local yOffset = orbiterData.OriginalPosition.Y - bossCenter.Y
			local newPosition = Vector3.new(
				bossCenter.X + math.cos(totalAngle) * radius,
				bossCenter.Y + yOffset,
				bossCenter.Z + math.sin(totalAngle) * radius
			)

			orbiterData.Part.Position = newPosition
		end
	end
end

--[[
	Get count of active animated homework
--]]
function HomeworkAnimator:GetActiveCount()
	local count = 0
	for _ in pairs(self.ActiveHomework) do
		count = count + 1
	end
	return count
end

--[[
	Clear all animations
--]]
function HomeworkAnimator:ClearAll()
	self.ActiveHomework = {}
end

--[[
	Cleanup on destroy
--]]
function HomeworkAnimator:Destroy()
	self:Stop()
	self:ClearAll()
end

return HomeworkAnimator
