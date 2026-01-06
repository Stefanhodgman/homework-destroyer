--[[
	WorldSetup.lua
	Run this ONCE in Roblox Studio Command Bar to create zones and spawn points

	INSTRUCTIONS:
	1. Open HomeworkDestroyer.rbxl in Studio
	2. Open View > Command Bar (or Ctrl + ')
	3. Copy this ENTIRE script
	4. Paste into Command Bar
	5. Press Enter
]]

print("========================================")
print("  HOMEWORK DESTROYER - WORLD SETUP")
print("========================================")

local workspace = game:GetService("Workspace")

-- Zone Configuration
local ZONES = {
	{Name = "Zone1", DisplayName = "The Classroom", Color = Color3.fromRGB(255, 220, 180)},
	{Name = "Zone2", DisplayName = "The Library", Color = Color3.fromRGB(200, 180, 140)},
	{Name = "Zone3", DisplayName = "The Cafeteria", Color = Color3.fromRGB(255, 200, 150)},
	{Name = "Zone4", DisplayName = "Computer Lab", Color = Color3.fromRGB(150, 200, 255)},
	{Name = "Zone5", DisplayName = "Gymnasium", Color = Color3.fromRGB(200, 255, 200)},
	{Name = "Zone6", DisplayName = "Music Room", Color = Color3.fromRGB(255, 180, 255)},
	{Name = "Zone7", DisplayName = "Art Room", Color = Color3.fromRGB(255, 150, 150)},
	{Name = "Zone8", DisplayName = "Science Lab", Color = Color3.fromRGB(150, 255, 200)},
	{Name = "Zone9", DisplayName = "Principal's Office", Color = Color3.fromRGB(100, 100, 100)},
	{Name = "Zone10", DisplayName = "The Void", Color = Color3.fromRGB(50, 0, 100)}
}

-- Create or get Zones folder
local zonesFolder = workspace:FindFirstChild("Zones")
if not zonesFolder then
	zonesFolder = Instance.new("Folder")
	zonesFolder.Name = "Zones"
	zonesFolder.Parent = workspace
	print("[✓] Created Zones folder")
else
	print("[✓] Zones folder already exists")
end

-- Create each zone
for i, zoneData in ipairs(ZONES) do
	print("\n--- Setting up " .. zoneData.DisplayName .. " ---")

	-- Create zone folder
	local zoneFolder = zonesFolder:FindFirstChild(zoneData.Name)
	if not zoneFolder then
		zoneFolder = Instance.new("Folder")
		zoneFolder.Name = zoneData.Name
		zoneFolder.Parent = zonesFolder
	end

	-- Add display name attribute
	zoneFolder:SetAttribute("DisplayName", zoneData.DisplayName)
	zoneFolder:SetAttribute("ZoneID", i)

	-- Create zone boundary (platform)
	local boundary = zoneFolder:FindFirstChild("ZoneBoundary")
	if not boundary then
		boundary = Instance.new("Part")
		boundary.Name = "ZoneBoundary"
		boundary.Size = Vector3.new(100, 1, 100) -- 100x100 platform
		boundary.Position = Vector3.new(i * 150, 0, 0) -- Spread zones out
		boundary.Anchored = true
		boundary.Color = zoneData.Color
		boundary.Material = Enum.Material.SmoothPlastic
		boundary.Transparency = 0
		boundary.TopSurface = Enum.SurfaceType.Smooth
		boundary.BottomSurface = Enum.SurfaceType.Smooth
		boundary.Parent = zoneFolder
		print("[✓] Created zone boundary at position: " .. tostring(boundary.Position))
	end

	-- Set PrimaryPart
	zoneFolder.PrimaryPart = boundary

	-- Create spawn points folder
	local spawnPointsFolder = zoneFolder:FindFirstChild("SpawnPoints")
	if not spawnPointsFolder then
		spawnPointsFolder = Instance.new("Folder")
		spawnPointsFolder.Name = "SpawnPoints"
		spawnPointsFolder.Parent = zoneFolder
	end

	-- Create 15 spawn points in a grid
	local spawnCount = 15
	local gridSize = math.ceil(math.sqrt(spawnCount))
	local spacing = 15 -- Space between spawn points

	for j = 1, spawnCount do
		local spawnPoint = spawnPointsFolder:FindFirstChild("SpawnPoint_" .. j)
		if not spawnPoint then
			spawnPoint = Instance.new("Part")
			spawnPoint.Name = "SpawnPoint_" .. j
			spawnPoint.Size = Vector3.new(2, 0.5, 2)
			spawnPoint.Anchored = true
			spawnPoint.Transparency = 0.8
			spawnPoint.Color = Color3.fromRGB(255, 255, 0) -- Yellow markers
			spawnPoint.Material = Enum.Material.Neon
			spawnPoint.CanCollide = false

			-- Position in grid
			local row = math.floor((j - 1) / gridSize)
			local col = (j - 1) % gridSize
			local offsetX = (col - gridSize/2) * spacing
			local offsetZ = (row - gridSize/2) * spacing

			spawnPoint.Position = boundary.Position + Vector3.new(offsetX, 5, offsetZ)
			spawnPoint.Parent = spawnPointsFolder
		end
	end

	print("[✓] Created " .. spawnCount .. " spawn points")

	-- Create ActiveHomework folder (where spawned homework will go)
	local activeFolder = zoneFolder:FindFirstChild("ActiveHomework")
	if not activeFolder then
		activeFolder = Instance.new("Folder")
		activeFolder.Name = "ActiveHomework"
		activeFolder.Parent = zoneFolder
	end
	print("[✓] Created ActiveHomework folder")

	-- Add zone label (TextLabel above zone)
	local labelPart = zoneFolder:FindFirstChild("ZoneLabel")
	if not labelPart then
		labelPart = Instance.new("Part")
		labelPart.Name = "ZoneLabel"
		labelPart.Size = Vector3.new(0.1, 0.1, 0.1)
		labelPart.Position = boundary.Position + Vector3.new(0, 20, 0)
		labelPart.Anchored = true
		labelPart.Transparency = 1
		labelPart.CanCollide = false

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.Adornee = labelPart
		billboard.AlwaysOnTop = true
		billboard.Parent = labelPart

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 0.5
		textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.Text = zoneData.DisplayName .. " (Zone " .. i .. ")"
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.Parent = billboard

		labelPart.Parent = zoneFolder
		print("[✓] Created zone label")
	end

	print("[✓] " .. zoneData.DisplayName .. " setup complete!")
end

-- Create player spawn location in Zone 1
print("\n--- Setting up Player Spawn ---")
local spawnLocation = workspace:FindFirstChild("SpawnLocation")
if not spawnLocation then
	spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Size = Vector3.new(6, 1, 6)
	spawnLocation.Position = Vector3.new(150, 5, 0) -- In Zone 1
	spawnLocation.Anchored = true
	spawnLocation.Color = Color3.fromRGB(0, 255, 0)
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.Transparency = 0.3
	spawnLocation.CanCollide = true
	spawnLocation.TopSurface = Enum.SurfaceType.Smooth
	spawnLocation.Parent = workspace
	print("[✓] Created player spawn location in Zone 1")
else
	print("[✓] Player spawn already exists")
end

print("\n========================================")
print("  WORLD SETUP COMPLETE!")
print("========================================")
print("\nCreated:")
print("- 10 Zone folders with boundaries")
print("- 150 spawn points (15 per zone)")
print("- ActiveHomework folders for each zone")
print("- Zone labels")
print("- Player spawn location")
print("\nZones are spread horizontally.")
print("Use camera to navigate between them!")
print("========================================")

-- Enable HTTP Requests automatically
local HttpService = game:GetService("HttpService")
if not HttpService.HttpEnabled then
	HttpService.HttpEnabled = true
	print("[✓] Enabled HTTP Requests for MCP plugin")
end

print("\n[READY] Game world is ready for testing!")
print("Press Play to test the game.")
