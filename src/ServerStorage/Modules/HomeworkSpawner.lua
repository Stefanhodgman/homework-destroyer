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
local TweenService = game:GetService("TweenService")

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
	Create a homework model with proper 3D visuals
--]]
function HomeworkSpawner:CreateHomeworkModel(homeworkData, position)
	local model = Instance.new("Model")
	model.Name = homeworkData.Name

	-- Determine base size multiplier based on homework tier
	local healthTier = homeworkData.Health
	local sizeMultiplier = 1
	if homeworkData.IsBoss then
		sizeMultiplier = 3.5
	elseif healthTier >= 1000000000 then
		sizeMultiplier = 2.8
	elseif healthTier >= 100000000 then
		sizeMultiplier = 2.4
	elseif healthTier >= 10000000 then
		sizeMultiplier = 2.0
	elseif healthTier >= 1000000 then
		sizeMultiplier = 1.7
	elseif healthTier >= 100000 then
		sizeMultiplier = 1.4
	elseif healthTier >= 10000 then
		sizeMultiplier = 1.2
	end

	-- Create model based on type
	if homeworkData.Type == "Paper" then
		self:CreatePaperModel(model, position, homeworkData, sizeMultiplier)
	elseif homeworkData.Type == "Book" then
		self:CreateBookModel(model, position, homeworkData, sizeMultiplier)
	elseif homeworkData.Type == "Digital" then
		self:CreateDigitalModel(model, position, homeworkData, sizeMultiplier)
	elseif homeworkData.Type == "Project" then
		self:CreateProjectModel(model, position, homeworkData, sizeMultiplier)
	elseif homeworkData.Type == "Void" then
		self:CreateVoidModel(model, position, homeworkData, sizeMultiplier)
	elseif homeworkData.Type == "Boss" then
		-- Boss uses enhanced version of zone's primary type
		self:CreateBossModel(model, position, homeworkData, sizeMultiplier)
	else
		-- Fallback to paper
		self:CreatePaperModel(model, position, homeworkData, sizeMultiplier)
	end

	-- Add floating animation to all homework
	self:AddFloatingAnimation(model)

	-- Add boss-specific effects
	if homeworkData.IsBoss then
		self:AddBossEffects(model)
	end

	-- Add click detector to primary part
	if model.PrimaryPart then
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 32
		clickDetector.Parent = model.PrimaryPart
	end

	-- Store homework data in model
	local homeworkValue = Instance.new("ObjectValue")
	homeworkValue.Name = "HomeworkData"
	homeworkValue.Parent = model

	-- Parent to homework folder
	model.Parent = self.HomeworkFolder

	return model
end

--[[
	Create a Paper-type homework model (flat, rectangular sheets)
--]]
function HomeworkSpawner:CreatePaperModel(model, position, homeworkData, sizeMultiplier)
	local baseSize = Vector3.new(3, 0.1, 4) * sizeMultiplier

	-- Main paper sheet
	local paper = Instance.new("Part")
	paper.Name = "Primary"
	paper.Size = baseSize
	paper.Position = position
	paper.Anchored = true
	paper.CanCollide = true
	paper.Material = Enum.Material.SmoothPlastic
	paper.Color = Color3.fromRGB(255, 255, 245) -- Cream paper color

	-- Add slight random rotation for variety
	paper.Orientation = Vector3.new(
		math.random(-15, 15),
		math.random(0, 360),
		math.random(-10, 10)
	)

	paper.Parent = model
	model.PrimaryPart = paper

	-- Add text lines decal to simulate writing
	local decal = Instance.new("Decal")
	decal.Face = Enum.NormalId.Top
	decal.Texture = "rbxasset://textures/ui/LuaApp/icons/ic-blue-line.png"
	decal.Color3 = Color3.fromRGB(0, 0, 0)
	decal.Transparency = 0.5
	decal.Parent = paper

	-- Add a second layer for depth
	local paper2 = Instance.new("Part")
	paper2.Name = "Layer2"
	paper2.Size = baseSize * Vector3.new(0.95, 0.8, 0.95)
	paper2.Position = position + Vector3.new(0.1, -0.05, -0.1)
	paper2.Anchored = true
	paper2.CanCollide = false
	paper2.Material = Enum.Material.SmoothPlastic
	paper2.Color = Color3.fromRGB(250, 250, 240)
	paper2.Orientation = paper.Orientation + Vector3.new(5, 2, -3)
	paper2.Parent = model

	-- Add staple/clip detail for multi-page papers
	if homeworkData.Health > 500 then
		local staple = Instance.new("Part")
		staple.Name = "Staple"
		staple.Size = Vector3.new(0.3, 0.1, 0.1) * sizeMultiplier
		staple.Position = position + Vector3.new(-baseSize.X * 0.35, 0.1, baseSize.Z * 0.4)
		staple.Anchored = true
		staple.CanCollide = false
		staple.Material = Enum.Material.Metal
		staple.Color = Color3.fromRGB(192, 192, 192)
		staple.Parent = model
	end
end

--[[
	Create a Book-type homework model (thick, with spine)
--]]
function HomeworkSpawner:CreateBookModel(model, position, homeworkData, sizeMultiplier)
	local baseSize = Vector3.new(3, 1.2, 4) * sizeMultiplier

	-- Main book body
	local book = Instance.new("Part")
	book.Name = "Primary"
	book.Size = baseSize
	book.Position = position
	book.Anchored = true
	book.CanCollide = true
	book.Material = Enum.Material.SmoothPlastic

	-- Book color variations
	local bookColors = {
		Color3.fromRGB(139, 69, 19),   -- Brown
		Color3.fromRGB(128, 0, 0),     -- Dark red
		Color3.fromRGB(0, 51, 102),    -- Dark blue
		Color3.fromRGB(25, 25, 25),    -- Black
		Color3.fromRGB(85, 107, 47),   -- Olive green
	}
	book.Color = bookColors[math.random(1, #bookColors)]
	book.Orientation = Vector3.new(0, math.random(0, 360), 0)
	book.Parent = model
	model.PrimaryPart = book

	-- Book spine (darker edge)
	local spine = Instance.new("Part")
	spine.Name = "Spine"
	spine.Size = Vector3.new(0.3, baseSize.Y * 0.95, baseSize.Z * 0.98) * sizeMultiplier
	spine.Position = book.Position + Vector3.new(-baseSize.X * 0.5, 0, 0)
	spine.Anchored = true
	spine.CanCollide = false
	spine.Material = Enum.Material.SmoothPlastic
	spine.Color = Color3.new(book.Color.R * 0.6, book.Color.G * 0.6, book.Color.B * 0.6)
	spine.Orientation = book.Orientation
	spine.Parent = model

	-- Book cover texture/detail
	local coverDetail = Instance.new("Part")
	coverDetail.Name = "Cover"
	coverDetail.Size = Vector3.new(baseSize.X * 0.9, 0.05, baseSize.Z * 0.8)
	coverDetail.Position = book.Position + Vector3.new(0, baseSize.Y * 0.5, 0)
	coverDetail.Anchored = true
	coverDetail.CanCollide = false
	coverDetail.Material = Enum.Material.Neon
	coverDetail.Color = Color3.fromRGB(255, 215, 0) -- Gold lettering
	coverDetail.Transparency = 0.3
	coverDetail.Orientation = book.Orientation
	coverDetail.Parent = model

	-- Pages (white edge visible)
	local pages = Instance.new("Part")
	pages.Name = "Pages"
	pages.Size = Vector3.new(baseSize.X * 0.95, baseSize.Y * 0.8, 0.2) * sizeMultiplier
	pages.Position = book.Position + book.CFrame.RightVector * (baseSize.X * 0.45)
	pages.Anchored = true
	pages.CanCollide = false
	pages.Material = Enum.Material.SmoothPlastic
	pages.Color = Color3.fromRGB(255, 255, 240)
	pages.Orientation = book.Orientation
	pages.Parent = model
end

--[[
	Create a Digital-type homework model (screen/tablet appearance)
--]]
function HomeworkSpawner:CreateDigitalModel(model, position, homeworkData, sizeMultiplier)
	local baseSize = Vector3.new(3.5, 0.3, 4.5) * sizeMultiplier

	-- Tablet/device frame
	local device = Instance.new("Part")
	device.Name = "Primary"
	device.Size = baseSize
	device.Position = position
	device.Anchored = true
	device.CanCollide = true
	device.Material = Enum.Material.Plastic
	device.Color = Color3.fromRGB(40, 40, 40) -- Dark gray frame
	device.Orientation = Vector3.new(75, math.random(0, 360), 0) -- Tilted to show screen
	device.Parent = model
	model.PrimaryPart = device

	-- Screen (glowing)
	local screen = Instance.new("Part")
	screen.Name = "Screen"
	screen.Size = Vector3.new(baseSize.X * 0.85, 0.02, baseSize.Z * 0.88)
	screen.Position = position + Vector3.new(0, baseSize.Y * 0.4, 0)
	screen.Anchored = true
	screen.CanCollide = false
	screen.Material = Enum.Material.Neon
	screen.Color = Color3.fromRGB(0, 162, 255) -- Bright blue screen
	screen.Orientation = device.Orientation
	screen.Parent = model

	-- Screen content simulation (darker rectangle)
	local screenContent = Instance.new("Part")
	screenContent.Name = "Content"
	screenContent.Size = Vector3.new(baseSize.X * 0.7, 0.03, baseSize.Z * 0.7)
	screenContent.Position = screen.Position + Vector3.new(0, 0.02, 0)
	screenContent.Anchored = true
	screenContent.CanCollide = false
	screenContent.Material = Enum.Material.Neon
	screenContent.Color = Color3.fromRGB(0, 120, 200)
	screenContent.Transparency = 0.2
	screenContent.Orientation = device.Orientation
	screenContent.Parent = model

	-- Add glowing particles for digital effect
	local particles = Instance.new("ParticleEmitter")
	particles.Name = "DigitalParticles"
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255))
	particles.Size = NumberSequence.new(0.2, 0.05)
	particles.Lifetime = NumberRange.new(1, 2)
	particles.Rate = 5
	particles.Speed = NumberRange.new(1, 2)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Transparency = NumberSequence.new(0.5, 1)
	particles.LightEmission = 1
	particles.Parent = screen
end

--[[
	Create a Project-type homework model (poster board, diorama style)
--]]
function HomeworkSpawner:CreateProjectModel(model, position, homeworkData, sizeMultiplier)
	local baseSize = Vector3.new(5, 4, 0.5) * sizeMultiplier

	-- Main poster board
	local board = Instance.new("Part")
	board.Name = "Primary"
	board.Size = baseSize
	board.Position = position
	board.Anchored = true
	board.CanCollide = true
	board.Material = Enum.Material.SmoothPlastic

	-- Project board colors (construction paper colors)
	local boardColors = {
		Color3.fromRGB(255, 170, 0),   -- Orange
		Color3.fromRGB(255, 100, 100), -- Light red
		Color3.fromRGB(100, 200, 255), -- Light blue
		Color3.fromRGB(150, 255, 150), -- Light green
		Color3.fromRGB(255, 255, 150), -- Light yellow
	}
	board.Color = boardColors[math.random(1, #boardColors)]
	board.Orientation = Vector3.new(0, math.random(0, 360), 0)
	board.Parent = model
	model.PrimaryPart = board

	-- Add multiple decorative elements (simulating project pieces)
	for i = 1, math.min(5, math.floor(sizeMultiplier * 2)) do
		local element = Instance.new("Part")
		element.Name = "Element" .. i
		element.Size = Vector3.new(
			math.random(5, 15) * 0.1 * sizeMultiplier,
			math.random(5, 15) * 0.1 * sizeMultiplier,
			0.1 * sizeMultiplier
		)
		element.Position = board.Position + Vector3.new(
			math.random(-baseSize.X * 3, baseSize.X * 3) * 0.1,
			math.random(-baseSize.Y * 3, baseSize.Y * 3) * 0.1,
			baseSize.Z * 0.5 + 0.1
		)
		element.Anchored = true
		element.CanCollide = false
		element.Material = Enum.Material.SmoothPlastic
		element.Color = boardColors[math.random(1, #boardColors)]
		element.Orientation = board.Orientation + Vector3.new(0, 0, math.random(-5, 5))
		element.Parent = model
	end

	-- Support stand (for standing projects)
	local stand = Instance.new("WedgePart")
	stand.Name = "Stand"
	stand.Size = Vector3.new(baseSize.X * 0.6, baseSize.Y * 0.3, baseSize.Y * 0.3) * sizeMultiplier
	stand.Position = position - Vector3.new(0, baseSize.Y * 0.35, baseSize.Z * 0.4)
	stand.Anchored = true
	stand.CanCollide = false
	stand.Material = Enum.Material.Wood
	stand.Color = Color3.fromRGB(160, 120, 80)
	stand.Orientation = board.Orientation + Vector3.new(0, 0, 90)
	stand.Parent = model
end

--[[
	Create a Void-type homework model (otherworldly appearance)
--]]
function HomeworkSpawner:CreateVoidModel(model, position, homeworkData, sizeMultiplier)
	local baseSize = Vector3.new(4, 4, 4) * sizeMultiplier

	-- Main void core
	local core = Instance.new("Part")
	core.Name = "Primary"
	core.Size = baseSize
	core.Position = position
	core.Anchored = true
	core.CanCollide = true
	core.Shape = Enum.PartType.Ball
	core.Material = Enum.Material.ForceField
	core.Color = Color3.fromRGB(128, 0, 128) -- Deep purple
	core.Transparency = 0.3
	core.Parent = model
	model.PrimaryPart = core

	-- Outer shell rings
	for i = 1, 3 do
		local ring = Instance.new("Part")
		ring.Name = "Ring" .. i
		ring.Size = baseSize * (1 + i * 0.3)
		ring.Position = position
		ring.Anchored = true
		ring.CanCollide = false
		ring.Shape = Enum.PartType.Ball
		ring.Material = Enum.Material.Neon
		ring.Color = Color3.fromRGB(150 - i * 20, 0, 150 + i * 20)
		ring.Transparency = 0.6 + i * 0.1
		ring.Parent = model
	end

	-- Void particles
	local voidParticles = Instance.new("ParticleEmitter")
	voidParticles.Name = "VoidParticles"
	voidParticles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	voidParticles.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 128)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(75, 0, 130)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	}
	voidParticles.Size = NumberSequence.new(1, 3)
	voidParticles.Lifetime = NumberRange.new(2, 4)
	voidParticles.Rate = 20
	voidParticles.Speed = NumberRange.new(0.5, 1.5)
	voidParticles.SpreadAngle = Vector2.new(180, 180)
	voidParticles.Transparency = NumberSequence.new(0, 1)
	voidParticles.LightEmission = 0.8
	voidParticles.Parent = core

	-- Point light for eerie glow
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(128, 0, 128)
	light.Brightness = 2
	light.Range = baseSize.X * 3
	light.Parent = core
end

--[[
	Create a Boss-type homework model (enhanced, intimidating version)
--]]
function HomeworkSpawner:CreateBossModel(model, position, homeworkData, sizeMultiplier)
	local baseSize = Vector3.new(6, 6, 6) * sizeMultiplier

	-- Boss core (imposing central structure)
	local core = Instance.new("Part")
	core.Name = "Primary"
	core.Size = baseSize
	core.Position = position
	core.Anchored = true
	core.CanCollide = true
	core.Material = Enum.Material.Neon
	core.Color = Color3.fromRGB(255, 0, 0) -- Bright red
	core.Parent = model
	model.PrimaryPart = core

	-- Multiple orbiting pieces
	for i = 1, 6 do
		local orbiter = Instance.new("Part")
		orbiter.Name = "Orbiter" .. i
		orbiter.Size = baseSize * 0.3
		local angle = (i / 6) * math.pi * 2
		local radius = baseSize.X * 0.8
		orbiter.Position = position + Vector3.new(
			math.cos(angle) * radius,
			math.sin(angle * 2) * radius * 0.3,
			math.sin(angle) * radius
		)
		orbiter.Anchored = true
		orbiter.CanCollide = false
		orbiter.Material = Enum.Material.Neon
		orbiter.Color = Color3.fromRGB(255, 50, 0)
		orbiter.Transparency = 0.2
		orbiter.Parent = model
	end

	-- Menacing spikes
	for i = 1, 8 do
		local spike = Instance.new("Part")
		spike.Name = "Spike" .. i
		spike.Size = Vector3.new(0.5, baseSize.Y * 0.6, 0.5) * sizeMultiplier
		local angle = (i / 8) * math.pi * 2
		local distance = baseSize.X * 0.6
		spike.Position = position + Vector3.new(
			math.cos(angle) * distance,
			0,
			math.sin(angle) * distance
		)
		spike.Anchored = true
		spike.CanCollide = false
		spike.Material = Enum.Material.Neon
		spike.Color = Color3.fromRGB(200, 0, 0)
		spike.Parent = model
	end

	-- Boss aura particles
	local aura = Instance.new("ParticleEmitter")
	aura.Name = "BossAura"
	aura.Texture = "rbxasset://textures/particles/fire_main.dds"
	aura.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0))
	}
	aura.Size = NumberSequence.new(2, 4)
	aura.Lifetime = NumberRange.new(1, 2)
	aura.Rate = 30
	aura.Speed = NumberRange.new(2, 4)
	aura.SpreadAngle = Vector2.new(180, 180)
	aura.Transparency = NumberSequence.new(0.3, 1)
	aura.LightEmission = 1
	aura.Parent = core

	-- Intense point light
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 0, 0)
	light.Brightness = 5
	light.Range = baseSize.X * 4
	light.Parent = core
end

--[[
	Add floating/bobbing animation to homework
--]]
function HomeworkSpawner:AddFloatingAnimation(model)
	if not model.PrimaryPart then
		return
	end

	-- Create alignment objects for smooth floating
	local attachment = Instance.new("Attachment")
	attachment.Name = "FloatAttachment"
	attachment.Parent = model.PrimaryPart

	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = attachment
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.MaxForce = 10000
	alignPosition.Responsiveness = 10
	alignPosition.Parent = model.PrimaryPart

	-- Store original position
	local originalPos = model.PrimaryPart.Position
	model.PrimaryPart:SetAttribute("OriginalY", originalPos.Y)
	model.PrimaryPart:SetAttribute("FloatOffset", math.random() * math.pi * 2)

	-- Note: The actual floating animation will be handled by a separate script
	-- This sets up the necessary attributes for the animation system
end

--[[
	Add special effects for boss homework
--]]
function HomeworkSpawner:AddBossEffects(model)
	if not model.PrimaryPart then
		return
	end

	-- Add dramatic particle aura
	local auraEmitter = Instance.new("ParticleEmitter")
	auraEmitter.Name = "BossAura"
	auraEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	auraEmitter.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 0))
	}
	auraEmitter.Size = NumberSequence.new(3, 5)
	auraEmitter.Lifetime = NumberRange.new(3, 5)
	auraEmitter.Rate = 15
	auraEmitter.Speed = NumberRange.new(1, 3)
	auraEmitter.Rotation = NumberRange.new(0, 360)
	auraEmitter.RotSpeed = NumberRange.new(-50, 50)
	auraEmitter.SpreadAngle = Vector2.new(180, 180)
	auraEmitter.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	}
	auraEmitter.LightEmission = 0.5
	auraEmitter.Parent = model.PrimaryPart

	-- Add pulsing light effect
	local pulsingLight = Instance.new("PointLight")
	pulsingLight.Name = "BossPulse"
	pulsingLight.Color = Color3.fromRGB(255, 0, 0)
	pulsingLight.Brightness = 3
	pulsingLight.Range = 30
	pulsingLight.Parent = model.PrimaryPart

	-- Note: Light pulsing animation will be handled by a separate animation script
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

		-- Determine target color based on health
		local targetColor
		if healthPercent > 0.5 then
			targetColor = Color3.fromRGB(0, 255, 0) -- Green
		elseif healthPercent > 0.25 then
			targetColor = Color3.fromRGB(255, 255, 0) -- Yellow
		else
			targetColor = Color3.fromRGB(255, 0, 0) -- Red
		end

		-- Smooth tween for health bar size
		local sizeTween = TweenService:Create(
			healthBar,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(healthPercent, 0, 1, 0)}
		)
		sizeTween:Play()

		-- Smooth tween for color change
		if healthBar.BackgroundColor3 ~= targetColor then
			local colorTween = TweenService:Create(
				healthBar,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear),
				{BackgroundColor3 = targetColor}
			)
			colorTween:Play()
		end

		-- Brief flash effect on damage
		if not homeworkInstance.LastHealthUpdateTime or (tick() - homeworkInstance.LastHealthUpdateTime) > 0.1 then
			homeworkInstance.LastHealthUpdateTime = tick()

			-- Flash white briefly
			local originalColor = healthBar.BackgroundColor3
			healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

			task.delay(0.05, function()
				if healthBar and healthBar.Parent then
					local flashTween = TweenService:Create(
						healthBar,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear),
						{BackgroundColor3 = targetColor}
					)
					flashTween:Play()
				end
			end)
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
