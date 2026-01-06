--[[
	HomeworkConfig.lua
	Configuration for all homework (enemy) types in Homework Destroyer

	Defines homework properties, health, rewards, and scaling per zone
	Data-driven design for easy balancing
--]]

local HomeworkConfig = {}

--[[
	ZONE CONFIGURATION
	Defines all zones with unlock requirements and spawn settings
--]]
HomeworkConfig.Zones = {
	{
		ZoneID = 1,
		Name = "The Classroom",
		UnlockCost = 0,
		UnlockLevel = 1,
		RecommendedLevel = {1, 15},
		MaxHomeworkSpawns = 15,
		SpawnInterval = 3, -- Seconds between spawns
		BossSpawnInterval = 600, -- 10 minutes
		SpawnRadius = 50, -- Studs from spawn points
	},
	{
		ZoneID = 2,
		Name = "The Library",
		UnlockCost = 5000,
		UnlockLevel = 10,
		RecommendedLevel = {15, 30},
		MaxHomeworkSpawns = 20,
		SpawnInterval = 2.5,
		BossSpawnInterval = 600,
		SpawnRadius = 60,
	},
	{
		ZoneID = 3,
		Name = "The Cafeteria",
		UnlockCost = 50000,
		UnlockLevel = 25,
		RecommendedLevel = {25, 40},
		MaxHomeworkSpawns = 25,
		SpawnInterval = 2,
		BossSpawnInterval = 600,
		SpawnRadius = 70,
	},
	{
		ZoneID = 4,
		Name = "Computer Lab",
		UnlockCost = 250000,
		UnlockLevel = 35,
		RecommendedLevel = {35, 50},
		MaxHomeworkSpawns = 30,
		SpawnInterval = 2,
		BossSpawnInterval = 600,
		SpawnRadius = 70,
	},
	{
		ZoneID = 5,
		Name = "Gymnasium",
		UnlockCost = 1000000,
		UnlockLevel = 45,
		RecommendedLevel = {45, 60},
		MaxHomeworkSpawns = 30,
		SpawnInterval = 1.5,
		BossSpawnInterval = 600,
		SpawnRadius = 80,
	},
	{
		ZoneID = 6,
		Name = "Music Room",
		UnlockCost = 5000000,
		UnlockLevel = 55,
		RecommendedLevel = {55, 70},
		MaxHomeworkSpawns = 35,
		SpawnInterval = 1.5,
		BossSpawnInterval = 600,
		SpawnRadius = 80,
	},
	{
		ZoneID = 7,
		Name = "Art Room",
		UnlockCost = 25000000,
		UnlockLevel = 65,
		RecommendedLevel = {65, 80},
		MaxHomeworkSpawns = 40,
		SpawnInterval = 1,
		BossSpawnInterval = 600,
		SpawnRadius = 90,
	},
	{
		ZoneID = 8,
		Name = "Science Lab",
		UnlockCost = 100000000,
		UnlockLevel = 75,
		RecommendedLevel = {75, 90},
		MaxHomeworkSpawns = 40,
		SpawnInterval = 1,
		BossSpawnInterval = 600,
		SpawnRadius = 90,
	},
	{
		ZoneID = 9,
		Name = "Principal's Office",
		UnlockCost = 500000000,
		UnlockLevel = 90,
		RebirthRequired = 3,
		RecommendedLevel = {90, 100},
		MaxHomeworkSpawns = 50,
		SpawnInterval = 0.5,
		BossSpawnInterval = 900, -- 15 minutes
		SpawnRadius = 100,
	},
	{
		ZoneID = 10,
		Name = "The Void",
		UnlockCost = 10000000000,
		UnlockLevel = 100,
		RebirthRequired = 25,
		PrestigeRequired = 3,
		RecommendedLevel = {100, 100},
		MaxHomeworkSpawns = 100,
		SpawnInterval = 0.3,
		BossSpawnInterval = 1200, -- 20 minutes
		SpawnRadius = 150,
	}
}

--[[
	HOMEWORK TYPE DEFINITIONS
	Each zone has 4 regular homework types and 1 boss
	Properties:
	- Health: Base HP (scales with zone progression)
	- Reward: Base DP reward
	- Type: "Paper", "Book", "Project", "Digital", "Boss"
	- SpawnWeight: Relative spawn chance (higher = more common)
	- Model: Name of model to spawn (references workspace folder)
--]]

HomeworkConfig.HomeworkTypes = {
	-- ========================================
	-- ZONE 1: THE CLASSROOM
	-- ========================================
	Zone1 = {
		{
			HomeworkID = "SpellingWorksheet",
			Name = "Spelling Worksheet",
			Health = 100,
			Reward = 10,
			Type = "Paper",
			SpawnWeight = 40,
			Model = "SpellingWorksheet",
			Description = "Basic paper homework"
		},
		{
			HomeworkID = "MathProblems",
			Name = "Math Problems",
			Health = 200,
			Reward = 25,
			Type = "Paper",
			SpawnWeight = 30,
			Model = "MathProblems",
			Description = "Simple arithmetic worksheet"
		},
		{
			HomeworkID = "ReadingAssignment",
			Name = "Reading Assignment",
			Health = 400,
			Reward = 55,
			Type = "Paper",
			SpawnWeight = 20,
			Model = "ReadingAssignment",
			Description = "Reading comprehension homework"
		},
		{
			HomeworkID = "PopQuiz",
			Name = "Pop Quiz",
			Health = 1000,
			Reward = 150,
			Type = "Paper",
			SpawnWeight = 10,
			Model = "PopQuiz",
			Description = "Surprise quiz"
		},
		-- Boss
		{
			HomeworkID = "MondayMorningTest",
			Name = "Monday Morning Test",
			Health = 25000,
			Reward = 5000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "MondayMorningTest",
			IsBoss = true,
			Description = "The worst way to start the week"
		}
	},

	-- ========================================
	-- ZONE 2: THE LIBRARY
	-- ========================================
	Zone2 = {
		{
			HomeworkID = "BookReport",
			Name = "Book Report",
			Health = 500,
			Reward = 65,
			Type = "Paper",
			SpawnWeight = 40,
			Model = "BookReport",
			Description = "Multi-page book analysis"
		},
		{
			HomeworkID = "ResearchPaper",
			Name = "Research Paper",
			Health = 1500,
			Reward = 200,
			Type = "Paper",
			SpawnWeight = 30,
			Model = "ResearchPaper",
			Description = "Extensive research assignment"
		},
		{
			HomeworkID = "EncyclopediaEntry",
			Name = "Encyclopedia Entry",
			Health = 3000,
			Reward = 450,
			Type = "Book",
			SpawnWeight = 20,
			Model = "EncyclopediaEntry",
			Description = "Heavy reference material"
		},
		{
			HomeworkID = "ThesisStatement",
			Name = "Thesis Statement",
			Health = 6000,
			Reward = 1000,
			Type = "Paper",
			SpawnWeight = 10,
			Model = "ThesisStatement",
			Description = "Complex argumentative essay"
		},
		-- Boss
		{
			HomeworkID = "OverdueLibraryBook",
			Name = "Overdue Library Book",
			Health = 75000,
			Reward = 15000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "OverdueLibraryBook",
			IsBoss = true,
			Description = "Collecting late fees and souls"
		}
	},

	-- ========================================
	-- ZONE 3: THE CAFETERIA
	-- ========================================
	Zone3 = {
		{
			HomeworkID = "NutritionWorksheet",
			Name = "Nutrition Worksheet",
			Health = 2000,
			Reward = 300,
			Type = "Paper",
			SpawnWeight = 40,
			Model = "NutritionWorksheet",
			Description = "Food pyramid homework"
		},
		{
			HomeworkID = "FoodDiaryProject",
			Name = "Food Diary Project",
			Health = 5000,
			Reward = 800,
			Type = "Project",
			SpawnWeight = 30,
			Model = "FoodDiaryProject",
			Description = "Week-long meal tracking"
		},
		{
			HomeworkID = "CookingRecipeAssignment",
			Name = "Cooking Recipe Assignment",
			Health = 10000,
			Reward = 1800,
			Type = "Project",
			SpawnWeight = 20,
			Model = "CookingRecipeAssignment",
			Description = "Full recipe documentation"
		},
		{
			HomeworkID = "HealthClassEssay",
			Name = "Health Class Essay",
			Health = 20000,
			Reward = 4000,
			Type = "Paper",
			SpawnWeight = 10,
			Model = "HealthClassEssay",
			Description = "Lengthy health education paper"
		},
		-- Boss
		{
			HomeworkID = "CafeteriaMysteryMeat",
			Name = "Cafeteria Mystery Meat",
			Health = 200000,
			Reward = 50000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "CafeteriaMysteryMeat",
			IsBoss = true,
			Description = "Nobody knows what it is"
		}
	},

	-- ========================================
	-- ZONE 4: COMPUTER LAB
	-- ========================================
	Zone4 = {
		{
			HomeworkID = "TypingTest",
			Name = "Typing Test",
			Health = 8000,
			Reward = 1200,
			Type = "Digital",
			SpawnWeight = 40,
			Model = "TypingTest",
			Description = "Speed and accuracy test"
		},
		{
			HomeworkID = "PowerPointPresentation",
			Name = "PowerPoint Presentation",
			Health = 20000,
			Reward = 3500,
			Type = "Digital",
			SpawnWeight = 30,
			Model = "PowerPointPresentation",
			Description = "Slide deck with transitions"
		},
		{
			HomeworkID = "CodingAssignment",
			Name = "Coding Assignment",
			Health = 45000,
			Reward = 8000,
			Type = "Digital",
			SpawnWeight = 20,
			Model = "CodingAssignment",
			Description = "Programming project"
		},
		{
			HomeworkID = "ComputerScienceProject",
			Name = "Computer Science Project",
			Health = 100000,
			Reward = 20000,
			Type = "Digital",
			SpawnWeight = 10,
			Model = "ComputerScienceProject",
			Description = "Full software development"
		},
		-- Boss
		{
			HomeworkID = "BlueScreenOfDoom",
			Name = "Blue Screen of Doom",
			Health = 500000,
			Reward = 150000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "BlueScreenOfDoom",
			IsBoss = true,
			Description = "CRITICAL_PROCESS_DIED"
		}
	},

	-- ========================================
	-- ZONE 5: GYMNASIUM
	-- ========================================
	Zone5 = {
		{
			HomeworkID = "FitnessLog",
			Name = "Fitness Log",
			Health = 30000,
			Reward = 5000,
			Type = "Paper",
			SpawnWeight = 40,
			Model = "FitnessLog",
			Description = "Daily exercise tracking"
		},
		{
			HomeworkID = "SportsReport",
			Name = "Sports Report",
			Health = 75000,
			Reward = 15000,
			Type = "Paper",
			SpawnWeight = 30,
			Model = "SportsReport",
			Description = "Athletic activity analysis"
		},
		{
			HomeworkID = "HealthAssessment",
			Name = "Health Assessment",
			Health = 150000,
			Reward = 35000,
			Type = "Project",
			SpawnWeight = 20,
			Model = "HealthAssessment",
			Description = "Complete fitness evaluation"
		},
		{
			HomeworkID = "PhysicalEducationPortfolio",
			Name = "Physical Education Portfolio",
			Health = 300000,
			Reward = 80000,
			Type = "Project",
			SpawnWeight = 10,
			Model = "PhysicalEducationPortfolio",
			Description = "Semester PE documentation"
		},
		-- Boss
		{
			HomeworkID = "CoachImpossibleFitnessTest",
			Name = "Coach's Impossible Fitness Test",
			Health = 1500000,
			Reward = 500000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "CoachImpossibleFitnessTest",
			IsBoss = true,
			Description = "100 push-ups is just the warmup"
		}
	},

	-- ========================================
	-- ZONE 6: MUSIC ROOM
	-- ========================================
	Zone6 = {
		{
			HomeworkID = "SheetMusicPractice",
			Name = "Sheet Music Practice",
			Health = 100000,
			Reward = 18000,
			Type = "Paper",
			SpawnWeight = 40,
			Model = "SheetMusicPractice",
			Description = "Musical notation exercises"
		},
		{
			HomeworkID = "MusicTheoryTest",
			Name = "Music Theory Test",
			Health = 250000,
			Reward = 50000,
			Type = "Paper",
			SpawnWeight = 30,
			Model = "MusicTheoryTest",
			Description = "Complex harmonic analysis"
		},
		{
			HomeworkID = "InstrumentRecitalPaper",
			Name = "Instrument Recital Paper",
			Health = 500000,
			Reward = 120000,
			Type = "Project",
			SpawnWeight = 20,
			Model = "InstrumentRecitalPaper",
			Description = "Performance documentation"
		},
		{
			HomeworkID = "SymphonyAnalysis",
			Name = "Symphony Analysis",
			Health = 1000000,
			Reward = 280000,
			Type = "Paper",
			SpawnWeight = 10,
			Model = "SymphonyAnalysis",
			Description = "Full orchestral breakdown"
		},
		-- Boss
		{
			HomeworkID = "DiscordantSymphony",
			Name = "Discordant Symphony",
			Health = 5000000,
			Reward = 1500000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "DiscordantSymphony",
			IsBoss = true,
			Description = "Out of tune and out for blood"
		}
	},

	-- ========================================
	-- ZONE 7: ART ROOM
	-- ========================================
	Zone7 = {
		{
			HomeworkID = "SketchAssignment",
			Name = "Sketch Assignment",
			Health = 400000,
			Reward = 75000,
			Type = "Paper",
			SpawnWeight = 40,
			Model = "SketchAssignment",
			Description = "Detailed pencil drawings"
		},
		{
			HomeworkID = "PaintingProject",
			Name = "Painting Project",
			Health = 900000,
			Reward = 180000,
			Type = "Project",
			SpawnWeight = 30,
			Model = "PaintingProject",
			Description = "Canvas masterpiece required"
		},
		{
			HomeworkID = "SculptureReport",
			Name = "Sculpture Report",
			Health = 2000000,
			Reward = 450000,
			Type = "Project",
			SpawnWeight = 20,
			Model = "SculptureReport",
			Description = "3D art documentation"
		},
		{
			HomeworkID = "ArtHistoryEssay",
			Name = "Art History Essay",
			Health = 4500000,
			Reward = 1100000,
			Type = "Paper",
			SpawnWeight = 10,
			Model = "ArtHistoryEssay",
			Description = "Renaissance to modern analysis"
		},
		-- Boss
		{
			HomeworkID = "MonstrousMasterpiece",
			Name = "Monstrous Masterpiece",
			Health = 20000000,
			Reward = 6000000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "MonstrousMasterpiece",
			IsBoss = true,
			Description = "Art that fights back"
		}
	},

	-- ========================================
	-- ZONE 8: SCIENCE LAB
	-- ========================================
	Zone8 = {
		{
			HomeworkID = "LabReport",
			Name = "Lab Report",
			Health = 1500000,
			Reward = 300000,
			Type = "Paper",
			SpawnWeight = 40,
			Model = "LabReport",
			Description = "Experiment documentation"
		},
		{
			HomeworkID = "ChemicalEquationSheet",
			Name = "Chemical Equation Sheet",
			Health = 3500000,
			Reward = 750000,
			Type = "Paper",
			SpawnWeight = 30,
			Model = "ChemicalEquationSheet",
			Description = "Balance all reactions"
		},
		{
			HomeworkID = "ExperimentDocumentation",
			Name = "Experiment Documentation",
			Health = 8000000,
			Reward = 1900000,
			Type = "Project",
			SpawnWeight = 20,
			Model = "ExperimentDocumentation",
			Description = "Full scientific method"
		},
		{
			HomeworkID = "ScientificMethodProject",
			Name = "Scientific Method Project",
			Health = 18000000,
			Reward = 4500000,
			Type = "Project",
			SpawnWeight = 10,
			Model = "ScientificMethodProject",
			Description = "Hypothesis to conclusion"
		},
		-- Boss
		{
			HomeworkID = "FailedExperiment",
			Name = "Failed Experiment",
			Health = 75000000,
			Reward = 25000000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "FailedExperiment",
			IsBoss = true,
			Description = "What could possibly go wrong?"
		}
	},

	-- ========================================
	-- ZONE 9: PRINCIPAL'S OFFICE
	-- ========================================
	Zone9 = {
		{
			HomeworkID = "DetentionEssay",
			Name = "Detention Essay",
			Health = 7000000,
			Reward = 1500000,
			Type = "Paper",
			SpawnWeight = 40,
			Model = "DetentionEssay",
			Description = "I will not misbehave x1000"
		},
		{
			HomeworkID = "BehaviorReport",
			Name = "Behavior Report",
			Health = 15000000,
			Reward = 3500000,
			Type = "Paper",
			SpawnWeight = 30,
			Model = "BehaviorReport",
			Description = "Conduct evaluation"
		},
		{
			HomeworkID = "AcademicProbationFile",
			Name = "Academic Probation File",
			Health = 35000000,
			Reward = 9000000,
			Type = "Project",
			SpawnWeight = 20,
			Model = "AcademicProbationFile",
			Description = "Student records"
		},
		{
			HomeworkID = "PermanentRecord",
			Name = "Permanent Record",
			Health = 80000000,
			Reward = 22000000,
			Type = "Project",
			SpawnWeight = 10,
			Model = "PermanentRecord",
			Description = "This stays with you forever"
		},
		-- Boss
		{
			HomeworkID = "ThePrincipal",
			Name = "THE PRINCIPAL",
			Health = 500000000,
			Reward = 200000000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "ThePrincipal",
			IsBoss = true,
			Description = "To my office. NOW."
		}
	},

	-- ========================================
	-- ZONE 10: THE VOID (SECRET ENDGAME)
	-- ========================================
	Zone10 = {
		{
			HomeworkID = "VoidAssignment",
			Name = "Void Assignment",
			Health = 500000000,
			Reward = 150000000,
			Type = "Void",
			SpawnWeight = 40,
			Model = "VoidAssignment",
			Description = "Homework from beyond reality"
		},
		{
			HomeworkID = "DimensionalEssay",
			Name = "Dimensional Essay",
			Health = 1500000000,
			Reward = 500000000,
			Type = "Void",
			SpawnWeight = 30,
			Model = "DimensionalEssay",
			Description = "Words that defy physics"
		},
		{
			HomeworkID = "RealityBreakingTest",
			Name = "Reality-Breaking Test",
			Health = 5000000000,
			Reward = 2000000000,
			Type = "Void",
			SpawnWeight = 20,
			Model = "RealityBreakingTest",
			Description = "Questions with no answers"
		},
		{
			HomeworkID = "TheUltimateHomework",
			Name = "THE ULTIMATE HOMEWORK",
			Health = 25000000000,
			Reward = 12000000000,
			Type = "Void",
			SpawnWeight = 10,
			Model = "TheUltimateHomework",
			Description = "The final assignment"
		},
		-- Boss
		{
			HomeworkID = "HomeworkOverlord",
			Name = "HOMEWORK OVERLORD",
			Health = 100000000000,
			Reward = 50000000000,
			Type = "Boss",
			SpawnWeight = 0,
			Model = "HomeworkOverlord",
			IsBoss = true,
			Description = "The source of all homework"
		}
	}
}

--[[
	HELPER FUNCTIONS
--]]

-- Get zone configuration by zone ID
function HomeworkConfig.GetZone(zoneID)
	for _, zone in ipairs(HomeworkConfig.Zones) do
		if zone.ZoneID == zoneID then
			return zone
		end
	end
	return nil
end

-- Get homework types for a specific zone
function HomeworkConfig.GetHomeworkForZone(zoneID)
	local zoneKey = "Zone" .. tostring(zoneID)
	return HomeworkConfig.HomeworkTypes[zoneKey] or {}
end

-- Get a specific homework type by ID
function HomeworkConfig.GetHomeworkByID(homeworkID)
	for _, zoneHomework in pairs(HomeworkConfig.HomeworkTypes) do
		for _, homework in ipairs(zoneHomework) do
			if homework.HomeworkID == homeworkID then
				return homework
			end
		end
	end
	return nil
end

-- Get random homework from zone based on spawn weights
function HomeworkConfig.GetRandomHomework(zoneID, includeBoss)
	local homeworkList = HomeworkConfig.GetHomeworkForZone(zoneID)
	if #homeworkList == 0 then
		return nil
	end

	-- Filter out bosses if not included
	local availableHomework = {}
	local totalWeight = 0

	for _, homework in ipairs(homeworkList) do
		if includeBoss or not homework.IsBoss then
			table.insert(availableHomework, homework)
			totalWeight = totalWeight + homework.SpawnWeight
		end
	end

	if #availableHomework == 0 or totalWeight == 0 then
		return nil
	end

	-- Weighted random selection
	local randomValue = math.random() * totalWeight
	local currentWeight = 0

	for _, homework in ipairs(availableHomework) do
		currentWeight = currentWeight + homework.SpawnWeight
		if randomValue <= currentWeight then
			return homework
		end
	end

	-- Fallback to first available
	return availableHomework[1]
end

-- Get boss homework for a zone
function HomeworkConfig.GetBossHomework(zoneID)
	local homeworkList = HomeworkConfig.GetHomeworkForZone(zoneID)
	for _, homework in ipairs(homeworkList) do
		if homework.IsBoss then
			return homework
		end
	end
	return nil
end

-- Check if a zone is unlocked for a player
function HomeworkConfig.IsZoneUnlocked(zoneID, playerData)
	local zone = HomeworkConfig.GetZone(zoneID)
	if not zone then
		return false, "Zone not found"
	end

	-- Check level requirement
	if playerData.Level < zone.UnlockLevel then
		return false, string.format("Requires Level %d", zone.UnlockLevel)
	end

	-- Check DP cost
	if playerData.DestructionPoints < zone.UnlockCost then
		return false, string.format("Requires %d DP", zone.UnlockCost)
	end

	-- Check rebirth requirement
	if zone.RebirthRequired and playerData.RebirthLevel < zone.RebirthRequired then
		return false, string.format("Requires Rebirth %d", zone.RebirthRequired)
	end

	-- Check prestige requirement
	if zone.PrestigeRequired and playerData.PrestigeLevel < zone.PrestigeRequired then
		return false, string.format("Requires Prestige Rank %d", zone.PrestigeRequired)
	end

	return true, "Unlocked"
end

-- Calculate scaled homework stats based on player progression
function HomeworkConfig.GetScaledHomework(homeworkData, playerLevel, rebirthLevel)
	local scaled = {}
	for key, value in pairs(homeworkData) do
		scaled[key] = value
	end

	-- Scale health and rewards based on rebirth level
	-- Each rebirth increases homework difficulty
	local rebirthScaling = 1 + (rebirthLevel * 0.5) -- +50% per rebirth

	scaled.Health = math.floor(homeworkData.Health * rebirthScaling)
	scaled.Reward = math.floor(homeworkData.Reward * rebirthScaling)

	return scaled
end

-- Get total spawn weights for a zone
function HomeworkConfig.GetTotalSpawnWeight(zoneID, includeBoss)
	local homeworkList = HomeworkConfig.GetHomeworkForZone(zoneID)
	local totalWeight = 0

	for _, homework in ipairs(homeworkList) do
		if includeBoss or not homework.IsBoss then
			totalWeight = totalWeight + homework.SpawnWeight
		end
	end

	return totalWeight
end

return HomeworkConfig
