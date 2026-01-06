--[[
	HomeworkSpawner.lua
	Handles spawning of homework objects in zones

	Responsibilities:
	- Spawn homework objects at designated spawn points
	- Manage spawn rates and timers per zone
	- Handle boss spawning on intervals
	- Cleanup destroyed homework
	- Track active homework count per zone
--]]

local HomeworkSpawner = {}
HomeworkSpawner.__index = HomeworkSpawner

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Modules
local HomeworkConfig = require(script.Parent.HomeworkConfig)

-- Constants
local HOMEWORK_FOLDER_NAME = "ActiveHomework"
local SPAWN_POINTS_FOLDER_NAME = "SpawnPoints"
local CLEANUP_INTERVAL = 10 -- Clean up every 10 seconds

--[[
	Constructor
	Creates a new HomeworkSpawner instance for a specific zone
--]]
function HomeworkSpawner.new(zoneID, zoneFolder)
	local self = setmetatable({}, HomeworkSpawner)

	self.ZoneID = zoneID
	self.ZoneConfig = HomeworkConfig.GetZone(zoneID)
	self.ZoneFolder = zoneFolder

	if not self.ZoneConfig then
		warn(string.format("HomeworkSpawner: Invalid zone ID %d", zoneID))
		return nil
	end

	-- Active homework tracking
	self.ActiveHomework = {}
	self.HomeworkCount = 0

	-- Spawn timers
	self.LastSpawnTime = 0
	self.LastBossSpawnTime = 0
	self.LastCleanupTime = 0

	-- Spawn points
	self.SpawnPoints = {}
	self:InitializeSpawnPoints()

	-- Create homework folder in zone
	self.HomeworkFolder = zoneFolder:FindFirstChild(HOMEWORK_FOLDER_NAME)
	if not self.HomeworkFolder then
		self.HomeworkFolder = Instance.new("Folder")
		self.HomeworkFolder.Name = HOMEWORK_FOLDER_NAME
		self.HomeworkFolder.Parent = zoneFolder
	end

	-- Running state
	self.IsRunning = false
	self.UpdateConnection = nil

	return self
end

--[[
	Initialize spawn points from zone folder
--]]
function HomeworkSpawner:InitializeSpawnPoints()
	local spawnPointsFolder = self.ZoneFolder:FindFirstChild(SPAWN_POINTS_FOLDER_NAME)

	if not spawnPointsFolder then
		warn(string.format("HomeworkSpawner: No spawn points folder found for zone %d", self.ZoneID))
		-- Create default spawn point at zone origin
		local defaultPoint = {
			Position = self.ZoneFolder.PrimaryPart and self.ZoneFolder.PrimaryPart.Position or Vector3.new(0, 5, 0),
			Radius = self.ZoneConfig.SpawnRadius
		}
		table.insert(self.SpawnPoints, defaultPoint)
		return
	end

	-- Collect all spawn point parts
	for _, spawnPoint in ipairs(spawnPointsFolder:GetChildren()) do
		if spawnPoint:IsA("BasePart") or spawnPoint:IsA("Attachment") then
			local position = spawnPoint:IsA("BasePart") and spawnPoint.Position or spawnPoint.WorldPosition
			table.insert(self.SpawnPoints, {
				Position = position,
				Radius = self.ZoneConfig.SpawnRadius,
				SpawnPart = spawnPoint
			})
		end
	end

	if #self.SpawnPoints == 0 then
		warn(string.format("HomeworkSpawner: No valid spawn points found for zone %d", self.ZoneID))
	end
end

--[[
	Start spawning homework in this zone
--]]
function HomeworkSpawner:Start()
	if self.IsRunning then
		return
	end

	self.IsRunning = true
	self.LastSpawnTime = tick()
	self.LastBossSpawnTime = tick()
	self.LastCleanupTime = tick()

	-- Connect to RunService for update loop
	self.UpdateConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self:Update(deltaTime)
	end)

	print(string.format("HomeworkSpawner: Started for zone %d (%s)", self.ZoneID, self.ZoneConfig.Name))
end

--[[
	Stop spawning homework
--]]
function HomeworkSpawner:Stop()
	if not self.IsRunning then
		return
	end

	self.IsRunning = false

	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
		self.UpdateConnection = nil
	end

	print(string.format("HomeworkSpawner: Stopped for zone %d (%s)", self.ZoneID, self.ZoneConfig.Name))
end

--[[
	Update loop - handles spawn timing
--]]
function HomeworkSpawner:Update(deltaTime)
	local currentTime = tick()

	-- Regular homework spawning
	if currentTime - self.LastSpawnTime >= self.ZoneConfig.SpawnInterval then
		self:TrySpawnHomework()
		self.LastSpawnTime = currentTime
	end

	-- Boss spawning
	if currentTime - self.LastBossSpawnTime >= self.ZoneConfig.BossSpawnInterval then
		self:SpawnBoss()
		self.LastBossSpawnTime = currentTime
	end

	-- Periodic cleanup
	if currentTime - self.LastCleanupTime >= CLEANUP_INTERVAL then
		self:CleanupInvalidHomework()
		self.LastCleanupTime = currentTime
	end
end

--[[
	Try to spawn regular homework if under limit
--]]
function HomeworkSpawner:TrySpawnHomework()
	-- Check if we're at spawn limit
	if self.HomeworkCount >= self.ZoneConfig.MaxHomeworkSpawns then
		return
	end

	-- Get random homework (exclude bosses)
	local homeworkData = HomeworkConfig.GetRandomHomework(self.ZoneID, false)
	if not homeworkData then
		return
	end

	-- Spawn the homework
	self:SpawnHomework(homeworkData)
end

--[[
	Spawn boss homework
--]]
function HomeworkSpawner:SpawnBoss()
	-- Get boss homework for this zone
	local bossData = HomeworkConfig.GetBossHomework(self.ZoneID)
	if not bossData then
		return
	end

	-- Check if boss already exists
	for _, homework in pairs(self.ActiveHomework) do
		if homework.Data and homework.Data.IsBoss then
			return -- Boss already spawned
		end
	end

	-- Spawn the boss
	self:SpawnHomework(bossData, true)

	print(string.format("HomeworkSpawner: Boss '%s' spawned in zone %d", bossData.Name, self.ZoneID))
end

--[[
	Spawn a homework object
--]]
function HomeworkSpawner:SpawnHomework(homeworkData, isBoss)
	-- Get random spawn point
	if #self.SpawnPoints == 0 then
		warn("HomeworkSpawner: No spawn points available")
		return nil
	end

	local spawnPoint = self.SpawnPoints[math.random(1, #self.SpawnPoints)]

	-- Calculate random position within spawn radius
	local angle = math.random() * math.pi * 2
	local distance = math.random() * spawnPoint.Radius
	local offsetX = math.cos(angle) * distance
	local offsetZ = math.sin(angle) * distance

	local spawnPosition = spawnPoint.Position + Vector3.new(offsetX, 0, offsetZ)

	-- Create homework model (placeholder for now - will be replaced with actual models)
	local homeworkModel = self:CreateHomeworkModel(homeworkData, spawnPosition)
	if not homeworkModel then
		return nil
	end

	-- Store homework data
	local homeworkInstance = {
		Model = homeworkModel,
		Data = homeworkData,
		CurrentHealth = homeworkData.Health,
		MaxHealth = homeworkData.Health,
		SpawnTime = tick(),
		IsBoss = isBoss or homeworkData.IsBoss,
		UniqueID = game:GetService("HttpService"):GenerateGUID(false)
	}

	-- Add to tracking
	self.ActiveHomework[homeworkModel] = homeworkInstance
	self.HomeworkCount = self.HomeworkCount + 1

	-- Set up health bar and other UI
	self:SetupHomeworkUI(homeworkInstance)

	return homeworkInstance
end

--[[
	Create a homework model (placeholder implementation)
--]]
function HomeworkSpawner:CreateHomeworkModel(homeworkData, position)
	-- Create a simple part as placeholder
	-- In production, this would clone from a template model
	local model = Instance.new("Model")
	model.Name = homeworkData.Name

	local part = Instance.new("Part")
	part.Name = "Primary"
	part.Size = homeworkData.IsBoss and Vector3.new(8, 8, 8) or Vector3.new(4, 4, 4)
	part.Position = position
	part.Anchored = true
	part.CanCollide = true

	-- Color based on type
	if homeworkData.IsBoss then
		part.Color = Color3.fromRGB(255, 0, 0) -- Red for bosses
		part.Material = Enum.Material.Neon
	elseif homeworkData.Type == "Paper" then
		part.Color = Color3.fromRGB(255, 255, 255) -- White for paper
	elseif homeworkData.Type == "Book" then
		part.Color = Color3.fromRGB(139, 69, 19) -- Brown for books
	elseif homeworkData.Type == "Digital" then
		part.Color = Color3.fromRGB(0, 162, 255) -- Blue for digital
	elseif homeworkData.Type == "Project" then
		part.Color = Color3.fromRGB(255, 170, 0) -- Orange for projects
	elseif homeworkData.Type == "Void" then
		part.Color = Color3.fromRGB(128, 0, 128) -- Purple for void
		part.Material = Enum.Material.Neon
	end

	part.Parent = model
	model.PrimaryPart = part

	-- Add click detector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 32 -- Increased for better accessibility
	clickDetector.Parent = part

	-- Store homework data in model
	local homeworkValue = Instance.new("ObjectValue")
	homeworkValue.Name = "HomeworkData"
	homeworkValue.Parent = model

	-- Parent to homework folder
	model.Parent = self.HomeworkFolder

	return model
end

--[[
	Set up UI elements for homework (health bar, etc.)
--]]
function HomeworkSpawner:SetupHomeworkUI(homeworkInstance)
	local model = homeworkInstance.Model
	if not model or not model.PrimaryPart then
		return
	end

	-- Create billboard GUI for health bar
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "HealthBar"
	billboardGui.Size = UDim2.new(4, 0, 0.5, 0)
	billboardGui.StudsOffset = Vector3.new(0, homeworkInstance.IsBoss and 6 or 3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = model.PrimaryPart

	-- Background frame
	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	background.BorderSizePixel = 2
	background.BorderColor3 = Color3.fromRGB(0, 0, 0)
	background.Parent = billboardGui

	-- Health bar fill
	local healthBar = Instance.new("Frame")
	healthBar.Name = "Fill"
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BackgroundColor3 = homeworkInstance.IsBoss and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = background

	-- Health text
	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.new(1, 0, 1, 0)
	healthText.BackgroundTransparency = 1
	healthText.Text = string.format("%s - %d HP", homeworkInstance.Data.Name, homeworkInstance.MaxHealth)
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.TextScaled = true
	healthText.Font = Enum.Font.GothamBold
	healthText.Parent = background
end

--[[
	Update homework health bar
--]]
function HomeworkSpawner:UpdateHomeworkHealth(homeworkInstance)
	local model = homeworkInstance.Model
	if not model or not model.PrimaryPart then
		return
	end

	local billboardGui = model.PrimaryPart:FindFirstChild("HealthBar")
	if not billboardGui then
		return
	end

	local healthBar = billboardGui:FindFirstChild("Frame") and billboardGui.Frame:FindFirstChild("Fill")
	local healthText = billboardGui:FindFirstChild("Frame") and billboardGui.Frame:FindFirstChild("HealthText")

	if healthBar then
		local healthPercent = homeworkInstance.CurrentHealth / homeworkInstance.MaxHealth
		healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)

		-- Change color based on health
		if healthPercent > 0.5 then
			healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
		elseif healthPercent > 0.25 then
			healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
		else
			healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
		end
	end

	if healthText then
		healthText.Text = string.format("%s - %d/%d HP",
			homeworkInstance.Data.Name,
			math.floor(homeworkInstance.CurrentHealth),
			homeworkInstance.MaxHealth)
	end
end

--[[
	Remove a homework object
--]]
function HomeworkSpawner:RemoveHomework(homeworkModel)
	local homeworkInstance = self.ActiveHomework[homeworkModel]
	if not homeworkInstance then
		return
	end

	-- Remove from tracking
	self.ActiveHomework[homeworkModel] = nil
	self.HomeworkCount = math.max(0, self.HomeworkCount - 1)

	-- Destroy model
	if homeworkModel and homeworkModel.Parent then
		homeworkModel:Destroy()
	end
end

--[[
	Clean up invalid homework (destroyed models, etc.)
--]]
function HomeworkSpawner:CleanupInvalidHomework()
	local toRemove = {}

	for model, instance in pairs(self.ActiveHomework) do
		if not model or not model.Parent or not model:IsDescendantOf(game) then
			table.insert(toRemove, model)
		end
	end

	for _, model in ipairs(toRemove) do
		self:RemoveHomework(model)
	end

	if #toRemove > 0 then
		print(string.format("HomeworkSpawner: Cleaned up %d invalid homework in zone %d", #toRemove, self.ZoneID))
	end
end

--[[
	Get homework instance from model
--]]
function HomeworkSpawner:GetHomeworkInstance(homeworkModel)
	return self.ActiveHomework[homeworkModel]
end

--[[
	Get all active homework in zone
--]]
function HomeworkSpawner:GetAllActiveHomework()
	local homework = {}
	for _, instance in pairs(self.ActiveHomework) do
		table.insert(homework, instance)
	end
	return homework
end

--[[
	Get active homework count
--]]
function HomeworkSpawner:GetHomeworkCount()
	return self.HomeworkCount
end

--[[
	Destroy all homework in zone
--]]
function HomeworkSpawner:ClearAllHomework()
	for model, _ in pairs(self.ActiveHomework) do
		if model and model.Parent then
			model:Destroy()
		end
	end

	self.ActiveHomework = {}
	self.HomeworkCount = 0

	print(string.format("HomeworkSpawner: Cleared all homework in zone %d", self.ZoneID))
end

--[[
	Cleanup on destroy
--]]
function HomeworkSpawner:Destroy()
	self:Stop()
	self:ClearAllHomework()

	if self.HomeworkFolder then
		self.HomeworkFolder:Destroy()
	end
end

return HomeworkSpawner
