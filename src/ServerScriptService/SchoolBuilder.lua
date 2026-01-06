--[[
	SchoolBuilder.lua

	Creates and manages the central school building for Homework Destroyer

	Features:
	- Multi-story school building positioned at world center
	- Multiple classrooms with proper furnishing
	- Hallways connecting rooms
	- Windows, doors, and architectural details
	- Proper materials (brick, concrete, glass)
	- School decorations (flagpole, sign, etc.)
	- Interior and exterior lighting
	- Professional appearance with proper proportions

	Author: Homework Destroyer Team
	Version: 1.0
]]

local SchoolBuilder = {}

-- Services
local Workspace = game:GetService("Workspace")

-- Constants
local SCHOOL_POSITION = Vector3.new(0, 0, -100) -- Center X, set back from spawn
local COLORS = {
	-- Exterior
	BrickRed = Color3.fromRGB(138, 86, 74),
	BrickDark = Color3.fromRGB(98, 64, 54),
	Concrete = Color3.fromRGB(189, 190, 192),
	RoofDark = Color3.fromRGB(58, 60, 62),
	DoorBrown = Color3.fromRGB(91, 62, 45),
	WindowFrame = Color3.fromRGB(245, 245, 245),
	Glass = Color3.fromRGB(173, 216, 230),

	-- Interior
	Floor = Color3.fromRGB(218, 213, 195),
	WallWhite = Color3.fromRGB(242, 243, 244),
	Chalkboard = Color3.fromRGB(45, 62, 50),
	WoodDesk = Color3.fromRGB(159, 129, 112),
	MetalGray = Color3.fromRGB(149, 151, 153),

	-- Decorative
	GrassGreen = Color3.fromRGB(106, 157, 85),
	SignBlue = Color3.fromRGB(52, 93, 169),
	FlagPoleGray = Color3.fromRGB(170, 170, 170),
}

--[[
	Create a part with common properties
]]
local function CreatePart(name, size, position, color, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

--[[
	Create a transparent part (for structure/anchoring)
]]
local function CreateInvisiblePart(name, size, position, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Parent = parent
	return part
end

--[[
	Create a window with frame and glass
]]
local function CreateWindow(position, rotation, parent)
	local windowModel = Instance.new("Model")
	windowModel.Name = "Window"
	windowModel.Parent = parent

	-- Window frame
	local frame = CreatePart(
		"Frame",
		Vector3.new(0.4, 4, 3),
		position,
		COLORS.WindowFrame,
		Enum.Material.SmoothPlastic,
		windowModel
	)
	frame.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)

	-- Glass pane
	local glass = CreatePart(
		"Glass",
		Vector3.new(0.2, 3.5, 2.5),
		position,
		COLORS.Glass,
		Enum.Material.Glass,
		windowModel
	)
	glass.Transparency = 0.6
	glass.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)
	glass.CanCollide = false

	return windowModel
end

--[[
	Create a door with frame
]]
local function CreateDoor(position, rotation, parent)
	local doorModel = Instance.new("Model")
	doorModel.Name = "Door"
	doorModel.Parent = parent

	-- Door frame
	local frame = CreatePart(
		"Frame",
		Vector3.new(0.5, 7, 4.5),
		position,
		COLORS.Concrete,
		Enum.Material.Concrete,
		doorModel
	)
	frame.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)

	-- Door itself
	local door = CreatePart(
		"Door",
		Vector3.new(0.3, 6.5, 4),
		position,
		COLORS.DoorBrown,
		Enum.Material.Wood,
		doorModel
	)
	door.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)

	-- Door handle
	local handle = CreatePart(
		"Handle",
		Vector3.new(0.4, 0.3, 0.3),
		position + Vector3.new(0, 0, 1.5),
		COLORS.MetalGray,
		Enum.Material.Metal,
		doorModel
	)
	handle.Shape = Enum.PartType.Ball
	handle.CFrame = CFrame.new(position + Vector3.new(0, 0, 1.5)) * CFrame.Angles(0, math.rad(rotation), 0)

	return doorModel
end

--[[
	Create a ceiling light
]]
local function CreateCeilingLight(position, parent)
	local lightModel = Instance.new("Model")
	lightModel.Name = "CeilingLight"
	lightModel.Parent = parent

	-- Light fixture
	local fixture = CreatePart(
		"Fixture",
		Vector3.new(3, 0.3, 1.5),
		position,
		COLORS.WallWhite,
		Enum.Material.SmoothPlastic,
		lightModel
	)

	-- Add light source
	local light = Instance.new("PointLight")
	light.Brightness = 0.5
	light.Range = 20
	light.Color = Color3.fromRGB(255, 244, 214)
	light.Parent = fixture

	-- Add surface light for better effect
	local surfaceLight = Instance.new("SurfaceLight")
	surfaceLight.Brightness = 0.3
	surfaceLight.Range = 15
	surfaceLight.Face = Enum.NormalId.Bottom
	surfaceLight.Color = Color3.fromRGB(255, 244, 214)
	surfaceLight.Parent = fixture

	return lightModel
end

--[[
	Create a desk with chair
]]
local function CreateDesk(position, rotation, parent)
	local deskModel = Instance.new("Model")
	deskModel.Name = "Desk"
	deskModel.Parent = parent

	-- Desktop
	local desktop = CreatePart(
		"Desktop",
		Vector3.new(3, 0.3, 2),
		position,
		COLORS.WoodDesk,
		Enum.Material.Wood,
		deskModel
	)
	desktop.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)

	-- Legs (4 corners)
	local legPositions = {
		Vector3.new(1.3, -1.35, 0.8),
		Vector3.new(-1.3, -1.35, 0.8),
		Vector3.new(1.3, -1.35, -0.8),
		Vector3.new(-1.3, -1.35, -0.8),
	}

	for i, offset in ipairs(legPositions) do
		local leg = CreatePart(
			"Leg" .. i,
			Vector3.new(0.3, 2.4, 0.3),
			position + offset,
			COLORS.MetalGray,
			Enum.Material.Metal,
			deskModel
		)
		leg.CFrame = CFrame.new(position + offset) * CFrame.Angles(0, math.rad(rotation), 0)
	end

	return deskModel
end

--[[
	Create a chalkboard
]]
local function CreateChalkboard(position, rotation, parent)
	local boardModel = Instance.new("Model")
	boardModel.Name = "Chalkboard"
	boardModel.Parent = parent

	-- Board surface
	local board = CreatePart(
		"Board",
		Vector3.new(0.2, 4, 6),
		position,
		COLORS.Chalkboard,
		Enum.Material.SmoothPlastic,
		boardModel
	)
	board.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)

	-- Frame
	local frame = CreatePart(
		"Frame",
		Vector3.new(0.3, 4.5, 6.5),
		position + Vector3.new(-0.1, 0, 0),
		COLORS.WoodDesk,
		Enum.Material.Wood,
		boardModel
	)
	frame.CFrame = CFrame.new(position + Vector3.new(-0.1, 0, 0)) * CFrame.Angles(0, math.rad(rotation), 0)

	return boardModel
end

--[[
	Build a single classroom
]]
local function BuildClassroom(centerPos, classroomNum, parent)
	local classroom = Instance.new("Model")
	classroom.Name = "Classroom" .. classroomNum
	classroom.Parent = parent

	-- Room dimensions: 20 wide x 8 tall x 15 deep
	local roomSize = Vector3.new(20, 8, 15)

	-- Floor
	CreatePart(
		"Floor",
		Vector3.new(roomSize.X, 0.5, roomSize.Z),
		centerPos + Vector3.new(0, -roomSize.Y/2, 0),
		COLORS.Floor,
		Enum.Material.Concrete,
		classroom
	)

	-- Ceiling
	CreatePart(
		"Ceiling",
		Vector3.new(roomSize.X, 0.5, roomSize.Z),
		centerPos + Vector3.new(0, roomSize.Y/2, 0),
		COLORS.WallWhite,
		Enum.Material.SmoothPlastic,
		classroom
	)

	-- Add ceiling lights (3 lights across the room)
	for i = -1, 1 do
		CreateCeilingLight(
			centerPos + Vector3.new(i * 6, roomSize.Y/2 - 0.5, 0),
			classroom
		)
	end

	-- Chalkboard at front of room
	CreateChalkboard(
		centerPos + Vector3.new(0, 0, -roomSize.Z/2 + 0.5),
		0,
		classroom
	)

	-- Desks arranged in rows (4 rows, 3 desks per row)
	for row = 1, 4 do
		for col = 1, 3 do
			local deskPos = centerPos + Vector3.new(
				(col - 2) * 5, -- Spread across width
				-roomSize.Y/2 + 1.5, -- Above floor
				-roomSize.Z/2 + 5 + row * 3 -- Rows going back
			)
			CreateDesk(deskPos, 0, classroom)
		end
	end

	return classroom
end

--[[
	Build a hallway section
]]
local function BuildHallway(position, length, isVertical, parent)
	local hallway = Instance.new("Model")
	hallway.Name = "Hallway"
	hallway.Parent = parent

	local hallwayWidth = 8
	local hallwayHeight = 8

	local size
	if isVertical then
		size = Vector3.new(hallwayWidth, hallwayHeight, length)
	else
		size = Vector3.new(length, hallwayHeight, hallwayWidth)
	end

	-- Floor
	CreatePart(
		"Floor",
		Vector3.new(size.X, 0.5, size.Z),
		position + Vector3.new(0, -size.Y/2, 0),
		COLORS.Floor,
		Enum.Material.Concrete,
		hallway
	)

	-- Ceiling
	CreatePart(
		"Ceiling",
		Vector3.new(size.X, 0.5, size.Z),
		position + Vector3.new(0, size.Y/2, 0),
		COLORS.WallWhite,
		Enum.Material.SmoothPlastic,
		hallway
	)

	-- Add hallway lights every 10 studs
	local numLights = math.floor(length / 10)
	for i = 1, numLights do
		local lightPos
		if isVertical then
			lightPos = position + Vector3.new(0, size.Y/2 - 0.5, -length/2 + i * (length/(numLights+1)))
		else
			lightPos = position + Vector3.new(-length/2 + i * (length/(numLights+1)), size.Y/2 - 0.5, 0)
		end
		CreateCeilingLight(lightPos, hallway)
	end

	return hallway
end

--[[
	Build the main school structure
]]
function SchoolBuilder:BuildSchool()
	warn("[SchoolBuilder] Starting school construction...")

	-- Create main school model
	local school = Instance.new("Model")
	school.Name = "School"

	-- Building dimensions
	local buildingWidth = 80 -- X axis
	local buildingDepth = 60 -- Z axis
	local floorHeight = 10
	local numFloors = 3
	local totalHeight = floorHeight * numFloors

	local basePos = SCHOOL_POSITION

	-- ========================================================================
	-- FOUNDATION AND EXTERIOR WALLS
	-- ========================================================================

	-- Foundation
	local foundation = CreatePart(
		"Foundation",
		Vector3.new(buildingWidth + 4, 2, buildingDepth + 4),
		basePos + Vector3.new(0, -1, 0),
		COLORS.Concrete,
		Enum.Material.Concrete,
		school
	)

	-- Create exterior walls for each floor
	local wallThickness = 1

	for floor = 1, numFloors do
		local floorY = basePos.Y + (floor - 1) * floorHeight

		-- Front wall (with entrance on first floor)
		if floor == 1 then
			-- Left section of front wall
			CreatePart(
				"FrontWallLeft_Floor" .. floor,
				Vector3.new(30, floorHeight, wallThickness),
				Vector3.new(basePos.X - 25, floorY + floorHeight/2, basePos.Z - buildingDepth/2),
				COLORS.BrickRed,
				Enum.Material.Brick,
				school
			)

			-- Right section of front wall
			CreatePart(
				"FrontWallRight_Floor" .. floor,
				Vector3.new(30, floorHeight, wallThickness),
				Vector3.new(basePos.X + 25, floorY + floorHeight/2, basePos.Z - buildingDepth/2),
				COLORS.BrickRed,
				Enum.Material.Brick,
				school
			)

			-- Top section above door
			CreatePart(
				"FrontWallTop_Floor" .. floor,
				Vector3.new(20, floorHeight - 7.5, wallThickness),
				Vector3.new(basePos.X, floorY + floorHeight - (floorHeight - 7.5)/2, basePos.Z - buildingDepth/2),
				COLORS.BrickRed,
				Enum.Material.Brick,
				school
			)

			-- Main entrance doors (double doors)
			CreateDoor(
				Vector3.new(basePos.X - 5, floorY + 3.5, basePos.Z - buildingDepth/2),
				0,
				school
			)
			CreateDoor(
				Vector3.new(basePos.X + 5, floorY + 3.5, basePos.Z - buildingDepth/2),
				0,
				school
			)
		else
			-- Solid wall for upper floors
			CreatePart(
				"FrontWall_Floor" .. floor,
				Vector3.new(buildingWidth, floorHeight, wallThickness),
				Vector3.new(basePos.X, floorY + floorHeight/2, basePos.Z - buildingDepth/2),
				COLORS.BrickRed,
				Enum.Material.Brick,
				school
			)
		end

		-- Back wall
		CreatePart(
			"BackWall_Floor" .. floor,
			Vector3.new(buildingWidth, floorHeight, wallThickness),
			Vector3.new(basePos.X, floorY + floorHeight/2, basePos.Z + buildingDepth/2),
			COLORS.BrickRed,
			Enum.Material.Brick,
			school
		)

		-- Left wall
		CreatePart(
			"LeftWall_Floor" .. floor,
			Vector3.new(wallThickness, floorHeight, buildingDepth),
			Vector3.new(basePos.X - buildingWidth/2, floorY + floorHeight/2, basePos.Z),
			COLORS.BrickRed,
			Enum.Material.Brick,
			school
		)

		-- Right wall
		CreatePart(
			"RightWall_Floor" .. floor,
			Vector3.new(wallThickness, floorHeight, buildingDepth),
			Vector3.new(basePos.X + buildingWidth/2, floorY + floorHeight/2, basePos.Z),
			COLORS.BrickRed,
			Enum.Material.Brick,
			school
		)

		-- Add windows to exterior walls (every 10 studs)
		local windowHeight = floorY + floorHeight/2

		-- Front windows
		for i = -3, 3 do
			if i ~= 0 then -- Skip center (entrance area)
				CreateWindow(
					Vector3.new(basePos.X + i * 10, windowHeight, basePos.Z - buildingDepth/2),
					0,
					school
				)
			end
		end

		-- Back windows
		for i = -3, 3 do
			CreateWindow(
				Vector3.new(basePos.X + i * 10, windowHeight, basePos.Z + buildingDepth/2),
				180,
				school
			)
		end

		-- Side windows
		for i = -2, 2 do
			CreateWindow(
				Vector3.new(basePos.X - buildingWidth/2, windowHeight, basePos.Z + i * 10),
				90,
				school
			)
			CreateWindow(
				Vector3.new(basePos.X + buildingWidth/2, windowHeight, basePos.Z + i * 10),
				270,
				school
			)
		end
	end

	-- ========================================================================
	-- FLOORS
	-- ========================================================================

	for floor = 0, numFloors do
		local floorY = basePos.Y + floor * floorHeight
		CreatePart(
			"Floor" .. floor,
			Vector3.new(buildingWidth - 2, 0.5, buildingDepth - 2),
			Vector3.new(basePos.X, floorY, basePos.Z),
			COLORS.Floor,
			Enum.Material.Concrete,
			school
		)
	end

	-- ========================================================================
	-- INTERIOR: FIRST FLOOR
	-- ========================================================================

	local firstFloorY = basePos.Y + floorHeight/2

	-- Main hallway (runs along Z axis through center)
	BuildHallway(
		Vector3.new(basePos.X, firstFloorY, basePos.Z),
		buildingDepth - 10,
		true,
		school
	)

	-- Classrooms on first floor (2 on each side of hallway)
	BuildClassroom(
		Vector3.new(basePos.X - 25, firstFloorY, basePos.Z - 15),
		101,
		school
	)
	BuildClassroom(
		Vector3.new(basePos.X + 25, firstFloorY, basePos.Z - 15),
		102,
		school
	)
	BuildClassroom(
		Vector3.new(basePos.X - 25, firstFloorY, basePos.Z + 15),
		103,
		school
	)
	BuildClassroom(
		Vector3.new(basePos.X + 25, firstFloorY, basePos.Z + 15),
		104,
		school
	)

	-- ========================================================================
	-- INTERIOR: SECOND FLOOR
	-- ========================================================================

	local secondFloorY = basePos.Y + floorHeight * 1.5

	-- Main hallway
	BuildHallway(
		Vector3.new(basePos.X, secondFloorY, basePos.Z),
		buildingDepth - 10,
		true,
		school
	)

	-- Classrooms on second floor
	BuildClassroom(
		Vector3.new(basePos.X - 25, secondFloorY, basePos.Z - 15),
		201,
		school
	)
	BuildClassroom(
		Vector3.new(basePos.X + 25, secondFloorY, basePos.Z - 15),
		202,
		school
	)
	BuildClassroom(
		Vector3.new(basePos.X - 25, secondFloorY, basePos.Z + 15),
		203,
		school
	)
	BuildClassroom(
		Vector3.new(basePos.X + 25, secondFloorY, basePos.Z + 15),
		204,
		school
	)

	-- ========================================================================
	-- INTERIOR: THIRD FLOOR
	-- ========================================================================

	local thirdFloorY = basePos.Y + floorHeight * 2.5

	-- Main hallway
	BuildHallway(
		Vector3.new(basePos.X, thirdFloorY, basePos.Z),
		buildingDepth - 10,
		true,
		school
	)

	-- Classrooms on third floor
	BuildClassroom(
		Vector3.new(basePos.X - 25, thirdFloorY, basePos.Z - 15),
		301,
		school
	)
	BuildClassroom(
		Vector3.new(basePos.X + 25, thirdFloorY, basePos.Z - 15),
		302,
		school
	)
	BuildClassroom(
		Vector3.new(basePos.X - 25, thirdFloorY, basePos.Z + 15),
		303,
		school
	)
	BuildClassroom(
		Vector3.new(basePos.X + 25, thirdFloorY, basePos.Z + 15),
		304,
		school
	)

	-- ========================================================================
	-- ROOF
	-- ========================================================================

	local roofY = basePos.Y + totalHeight + 0.5

	-- Main roof
	CreatePart(
		"Roof",
		Vector3.new(buildingWidth + 2, 1, buildingDepth + 2),
		Vector3.new(basePos.X, roofY, basePos.Z),
		COLORS.RoofDark,
		Enum.Material.Slate,
		school
	)

	-- Roof trim
	CreatePart(
		"RoofTrim",
		Vector3.new(buildingWidth + 4, 0.5, buildingDepth + 4),
		Vector3.new(basePos.X, roofY - 0.75, basePos.Z),
		COLORS.Concrete,
		Enum.Material.Concrete,
		school
	)

	-- ========================================================================
	-- EXTERIOR DECORATIONS
	-- ========================================================================

	-- Flagpole
	local flagpoleBase = basePos + Vector3.new(-35, 0, -35)

	CreatePart(
		"FlagpoleBase",
		Vector3.new(2, 0.5, 2),
		flagpoleBase,
		COLORS.Concrete,
		Enum.Material.Concrete,
		school
	)

	local flagpole = CreatePart(
		"Flagpole",
		Vector3.new(0.4, 20, 0.4),
		flagpoleBase + Vector3.new(0, 10, 0),
		COLORS.FlagPoleGray,
		Enum.Material.Metal,
		school
	)
	flagpole.Shape = Enum.PartType.Cylinder
	flagpole.Orientation = Vector3.new(0, 0, 90)

	-- School sign
	local signPos = basePos + Vector3.new(0, 2, -buildingDepth/2 - 5)

	local signPost = CreatePart(
		"SignPost",
		Vector3.new(0.5, 4, 0.5),
		signPos,
		COLORS.WoodDesk,
		Enum.Material.Wood,
		school
	)

	local signBoard = CreatePart(
		"SignBoard",
		Vector3.new(15, 3, 0.5),
		signPos + Vector3.new(0, 3, 0),
		COLORS.SignBlue,
		Enum.Material.SmoothPlastic,
		school
	)

	-- Add text to sign
	local signText = Instance.new("SurfaceGui")
	signText.Face = Enum.NormalId.Front
	signText.Parent = signBoard

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "HOMEWORK DESTROYER ACADEMY"
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = signText

	-- Outdoor lights (lamp posts)
	local lampPositions = {
		basePos + Vector3.new(-35, 0, -buildingDepth/2 - 10),
		basePos + Vector3.new(35, 0, -buildingDepth/2 - 10),
		basePos + Vector3.new(-35, 0, buildingDepth/2 + 10),
		basePos + Vector3.new(35, 0, buildingDepth/2 + 10),
	}

	for i, lampPos in ipairs(lampPositions) do
		-- Lamp post
		local post = CreatePart(
			"LampPost" .. i,
			Vector3.new(0.5, 8, 0.5),
			lampPos + Vector3.new(0, 4, 0),
			COLORS.MetalGray,
			Enum.Material.Metal,
			school
		)

		-- Lamp head
		local lampHead = CreatePart(
			"LampHead" .. i,
			Vector3.new(1.5, 1, 1.5),
			lampPos + Vector3.new(0, 8.5, 0),
			COLORS.MetalGray,
			Enum.Material.Metal,
			school
		)
		lampHead.Shape = Enum.PartType.Ball

		-- Light source
		local light = Instance.new("PointLight")
		light.Brightness = 0.8
		light.Range = 25
		light.Color = Color3.fromRGB(255, 230, 180)
		light.Parent = lampHead
	end

	-- Grass patches around the building
	local grassPositions = {
		{pos = basePos + Vector3.new(-45, -1.5, -buildingDepth/2 - 15), size = Vector3.new(20, 1, 20)},
		{pos = basePos + Vector3.new(45, -1.5, -buildingDepth/2 - 15), size = Vector3.new(20, 1, 20)},
		{pos = basePos + Vector3.new(-45, -1.5, buildingDepth/2 + 15), size = Vector3.new(20, 1, 20)},
		{pos = basePos + Vector3.new(45, -1.5, buildingDepth/2 + 15), size = Vector3.new(20, 1, 20)},
	}

	for i, grass in ipairs(grassPositions) do
		CreatePart(
			"Grass" .. i,
			grass.size,
			grass.pos,
			COLORS.GrassGreen,
			Enum.Material.Grass,
			school
		)
	end

	-- ========================================================================
	-- STAIRS BETWEEN FLOORS (Central stairwell)
	-- ========================================================================

	-- Create stairwell for each floor transition
	for floor = 1, numFloors - 1 do
		local stairwellY = basePos.Y + (floor - 1) * floorHeight
		local stairwellPos = Vector3.new(basePos.X - 10, stairwellY, basePos.Z)

		-- Create individual steps (20 steps per floor)
		local numSteps = 20
		local stepHeight = floorHeight / numSteps
		local stepDepth = 1.5

		for step = 1, numSteps do
			local stepY = stairwellY + step * stepHeight
			local stepZ = stairwellPos.Z - (numSteps/2 * stepDepth) + step * stepDepth

			CreatePart(
				"Step_Floor" .. floor .. "_" .. step,
				Vector3.new(4, 0.3, stepDepth),
				Vector3.new(stairwellPos.X, stepY, stepZ),
				COLORS.Concrete,
				Enum.Material.Concrete,
				school
			)
		end

		-- Stairwell walls
		CreatePart(
			"StairwellWallLeft_Floor" .. floor,
			Vector3.new(0.3, floorHeight, numSteps * stepDepth),
			Vector3.new(stairwellPos.X - 2, stairwellY + floorHeight/2, stairwellPos.Z),
			COLORS.WallWhite,
			Enum.Material.SmoothPlastic,
			school
		)

		CreatePart(
			"StairwellWallRight_Floor" .. floor,
			Vector3.new(0.3, floorHeight, numSteps * stepDepth),
			Vector3.new(stairwellPos.X + 2, stairwellY + floorHeight/2, stairwellPos.Z),
			COLORS.WallWhite,
			Enum.Material.SmoothPlastic,
			school
		)
	end

	-- ========================================================================
	-- SPAWN POINT FOR PLAYERS
	-- ========================================================================

	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "SchoolSpawn"
	spawnLocation.Size = Vector3.new(6, 1, 6)
	spawnLocation.Position = basePos + Vector3.new(0, 1, -buildingDepth/2 - 15)
	spawnLocation.Anchored = true
	spawnLocation.CanCollide = true
	spawnLocation.Transparency = 0.5
	spawnLocation.BrickColor = BrickColor.new("Bright green")
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.TopSurface = Enum.SurfaceType.Smooth
	spawnLocation.Duration = 0
	spawnLocation.Parent = school

	-- Set as primary part for the model
	school.PrimaryPart = foundation

	-- Parent to workspace
	school.Parent = Workspace

	warn("[SchoolBuilder] School construction complete!")
	warn("[SchoolBuilder] School positioned at: " .. tostring(SCHOOL_POSITION))
	warn("[SchoolBuilder] Building dimensions: " .. buildingWidth .. "x" .. totalHeight .. "x" .. buildingDepth)
	warn("[SchoolBuilder] Total classrooms: " .. (numFloors * 4))

	return school
end

--[[
	Clean up existing school
]]
function SchoolBuilder:DestroySchool()
	local existingSchool = Workspace:FindFirstChild("School")
	if existingSchool then
		existingSchool:Destroy()
		warn("[SchoolBuilder] Existing school destroyed")
	end
end

--[[
	Initialize the school builder
]]
function SchoolBuilder:Initialize()
	warn("[SchoolBuilder] Initializing...")

	-- Remove any existing school
	self:DestroySchool()

	-- Build the new school
	local school = self:BuildSchool()

	if school then
		warn("[SchoolBuilder] School initialized successfully!")
		return true
	else
		warn("[SchoolBuilder] Failed to initialize school")
		return false
	end
end

return SchoolBuilder
