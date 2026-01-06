--[[
	ZonesConfig.lua
	Configuration for all zones in Homework Destroyer

	Defines all 10 zones with unlock requirements, homework types,
	bosses, special features, and zone-specific settings.

	Based on Game Design Document zone specifications
]]

local ZonesConfig = {}

--[[
	ZONE STRUCTURE:
	{
		ID = number,
		Name = string,
		Description = string,
		Theme = string,

		-- Unlock Requirements
		UnlockRequirements = {
			DP = number,
			Level = number,
			RebirthLevel = number (optional),
			PrestigeRank = number (optional),
		},

		-- Spawn Configuration
		SpawnLocation = Vector3, -- Relative to zone model
		SafeZoneRadius = number,

		-- Homework Types in this zone
		HomeworkTypes = {
			{Name, HP, DPReward, SpawnWeight}
		},

		-- Boss Configuration
		Boss = {
			Name = string,
			HP = number,
			DPReward = number,
			SpawnInterval = number (seconds),
			SpawnLocation = Vector3,
			Model = string (reference to model)
		},

		-- Special Features
		SpecialFeature = {
			Name = string,
			Description = string,
			Type = string,
			Settings = table
		},

		-- Recommended stats
		RecommendedLevel = {Min, Max},
		DifficultyTier = number (1-10),

		-- Zone bonuses/multipliers
		ZoneBonuses = {
			DPMultiplier = number,
			XPMultiplier = number,
			SpawnRateMultiplier = number
		}
	}
]]

-- ============================================================================
-- ZONE 1: THE CLASSROOM (Starter Zone)
-- ============================================================================
ZonesConfig[1] = {
	ID = 1,
	Name = "The Classroom",
	Description = "A classic school classroom filled with desks, chalkboards, and scattered papers waiting to be destroyed.",
	Theme = "Classic school classroom with desks, chalkboard, scattered papers",

	-- Free to access (starting zone)
	UnlockRequirements = {
		DP = 0,
		Level = 1,
	},

	SpawnLocation = Vector3.new(0, 5, 0),
	SafeZoneRadius = 10,

	-- Homework Types
	HomeworkTypes = {
		{
			Name = "Spelling Worksheet",
			HP = 100,
			DPReward = 10,
			XPReward = 5,
			SpawnWeight = 40, -- Higher weight = more common
			Model = "SpellingWorksheet",
		},
		{
			Name = "Math Problems",
			HP = 200,
			DPReward = 25,
			XPReward = 12,
			SpawnWeight = 30,
			Model = "MathProblems",
		},
		{
			Name = "Reading Assignment",
			HP = 400,
			DPReward = 55,
			XPReward = 25,
			SpawnWeight = 20,
			Model = "ReadingAssignment",
		},
		{
			Name = "Pop Quiz",
			HP = 1000,
			DPReward = 150,
			XPReward = 60,
			SpawnWeight = 10,
			Model = "PopQuiz",
		},
	},

	-- Boss Configuration
	Boss = {
		Name = "Monday Morning Test",
		HP = 25000,
		DPReward = 5000,
		XPReward = 1000,
		SpawnInterval = 600, -- 10 minutes in seconds
		SpawnLocation = Vector3.new(0, 5, 30),
		Model = "MondayMorningTest",
		Attacks = {
			{Name = "Paper Storm", Damage = 5, Cooldown = 3},
		},
	},

	-- Special Feature
	SpecialFeature = {
		Name = "Tutorial Helper",
		Description = "Teacher's Pet NPC explains game mechanics to new players",
		Type = "NPC",
		Settings = {
			NPCName = "Teacher's Pet",
			DialogueEnabled = true,
			TutorialQuests = true,
		},
	},

	RecommendedLevel = {1, 15},
	DifficultyTier = 1,

	ZoneBonuses = {
		DPMultiplier = 1.0,
		XPMultiplier = 1.0,
		SpawnRateMultiplier = 1.0,
	},

	-- Visual/Audio
	BackgroundMusic = "rbxassetid://ClassroomTheme",
	AmbientColor = Color3.fromRGB(255, 250, 240),
	LightingBrightness = 2,
}

-- ============================================================================
-- ZONE 2: THE LIBRARY
-- ============================================================================
ZonesConfig[2] = {
	ID = 2,
	Name = "The Library",
	Description = "Towering bookshelves and quiet study areas. Time to make some noise!",
	Theme = "Towering bookshelves, quiet study areas, librarian desk",

	UnlockRequirements = {
		DP = 5000,
		Level = 10,
	},

	SpawnLocation = Vector3.new(100, 5, 0),
	SafeZoneRadius = 12,

	HomeworkTypes = {
		{
			Name = "Book Report",
			HP = 500,
			DPReward = 65,
			XPReward = 30,
			SpawnWeight = 40,
			Model = "BookReport",
		},
		{
			Name = "Research Paper",
			HP = 1500,
			DPReward = 200,
			XPReward = 90,
			SpawnWeight = 30,
			Model = "ResearchPaper",
		},
		{
			Name = "Encyclopedia Entry",
			HP = 3000,
			DPReward = 450,
			XPReward = 200,
			SpawnWeight = 20,
			Model = "EncyclopediaEntry",
		},
		{
			Name = "Thesis Statement",
			HP = 6000,
			DPReward = 1000,
			XPReward = 400,
			SpawnWeight = 10,
			Model = "ThesisStatement",
		},
	},

	Boss = {
		Name = "Overdue Library Book",
		HP = 75000,
		DPReward = 15000,
		XPReward = 3000,
		SpawnInterval = 600,
		SpawnLocation = Vector3.new(100, 5, 30),
		Model = "OverdueLibraryBook",
		Attacks = {
			{Name = "Book Slam", Damage = 10, Cooldown = 4},
			{Name = "Silence Aura", Damage = 5, Cooldown = 2, AOE = true},
		},
	},

	SpecialFeature = {
		Name = "Speed Reading",
		Description = "Mini-event every 30 minutes grants 2x DP for 2 minutes",
		Type = "TimedEvent",
		Settings = {
			EventInterval = 1800, -- 30 minutes
			EventDuration = 120, -- 2 minutes
			DPMultiplier = 2.0,
			Announcement = "Speed Reading event started! 2x DP for 2 minutes!",
		},
	},

	RecommendedLevel = {15, 30},
	DifficultyTier = 2,

	ZoneBonuses = {
		DPMultiplier = 1.1,
		XPMultiplier = 1.15,
		SpawnRateMultiplier = 1.0,
	},

	BackgroundMusic = "rbxassetid://LibraryTheme",
	AmbientColor = Color3.fromRGB(230, 230, 210),
	LightingBrightness = 1.5,
}

-- ============================================================================
-- ZONE 3: THE CAFETERIA
-- ============================================================================
ZonesConfig[3] = {
	ID = 3,
	Name = "The Cafeteria",
	Description = "Lunch tables, sticky floors, and food fight aftermath. It's always lunch time!",
	Theme = "Lunch tables, food trays, sticky floors, food fight aftermath",

	UnlockRequirements = {
		DP = 50000,
		Level = 25,
	},

	SpawnLocation = Vector3.new(200, 5, 0),
	SafeZoneRadius = 15,

	HomeworkTypes = {
		{
			Name = "Nutrition Worksheet",
			HP = 2000,
			DPReward = 300,
			XPReward = 120,
			SpawnWeight = 40,
			Model = "NutritionWorksheet",
		},
		{
			Name = "Food Diary Project",
			HP = 5000,
			DPReward = 800,
			XPReward = 320,
			SpawnWeight = 30,
			Model = "FoodDiaryProject",
		},
		{
			Name = "Cooking Recipe Assignment",
			HP = 10000,
			DPReward = 1800,
			XPReward = 700,
			SpawnWeight = 20,
			Model = "CookingRecipe",
		},
		{
			Name = "Health Class Essay",
			HP = 20000,
			DPReward = 4000,
			XPReward = 1500,
			SpawnWeight = 10,
			Model = "HealthClassEssay",
		},
	},

	Boss = {
		Name = "Cafeteria Mystery Meat",
		HP = 200000,
		DPReward = 50000,
		XPReward = 10000,
		SpawnInterval = 600,
		SpawnLocation = Vector3.new(200, 5, 30),
		Model = "MysteryMeat",
		Attacks = {
			{Name = "Gravy Splash", Damage = 15, Cooldown = 3, AOE = true},
			{Name = "Food Toss", Damage = 20, Cooldown = 5},
		},
	},

	SpecialFeature = {
		Name = "Lunch Rush",
		Description = "Random event triggers double homework spawns for 5 minutes",
		Type = "SpawnEvent",
		Settings = {
			EventInterval = 1200, -- 20 minutes average
			EventDuration = 300, -- 5 minutes
			SpawnMultiplier = 2.0,
			Announcement = "Lunch Rush! Double homework spawns!",
		},
	},

	RecommendedLevel = {25, 40},
	DifficultyTier = 3,

	ZoneBonuses = {
		DPMultiplier = 1.2,
		XPMultiplier = 1.2,
		SpawnRateMultiplier = 1.1,
	},

	BackgroundMusic = "rbxassetid://CafeteriaTheme",
	AmbientColor = Color3.fromRGB(255, 240, 220),
	LightingBrightness = 2,
}

-- ============================================================================
-- ZONE 4: COMPUTER LAB
-- ============================================================================
ZonesConfig[4] = {
	ID = 4,
	Name = "Computer Lab",
	Description = "Desktop computers, tangled wires, and endless loading screens await.",
	Theme = "Desktop computers, tangled wires, loading screens, error messages",

	UnlockRequirements = {
		DP = 250000,
		Level = 35,
	},

	SpawnLocation = Vector3.new(300, 5, 0),
	SafeZoneRadius = 15,

	HomeworkTypes = {
		{
			Name = "Typing Test",
			HP = 8000,
			DPReward = 1200,
			XPReward = 450,
			SpawnWeight = 40,
			Model = "TypingTest",
		},
		{
			Name = "PowerPoint Presentation",
			HP = 20000,
			DPReward = 3500,
			XPReward = 1200,
			SpawnWeight = 30,
			Model = "PowerPoint",
		},
		{
			Name = "Coding Assignment",
			HP = 45000,
			DPReward = 8000,
			XPReward = 3000,
			SpawnWeight = 20,
			Model = "CodingAssignment",
		},
		{
			Name = "Computer Science Project",
			HP = 100000,
			DPReward = 20000,
			XPReward = 7000,
			SpawnWeight = 10,
			Model = "CSProject",
		},
	},

	Boss = {
		Name = "Blue Screen of Doom",
		HP = 500000,
		DPReward = 150000,
		XPReward = 30000,
		SpawnInterval = 600,
		SpawnLocation = Vector3.new(300, 5, 30),
		Model = "BlueScreenOfDoom",
		Attacks = {
			{Name = "System Crash", Damage = 25, Cooldown = 6},
			{Name = "Error Spam", Damage = 15, Cooldown = 3, AOE = true},
			{Name = "Force Restart", Damage = 50, Cooldown = 15, Stun = 2},
		},
	},

	SpecialFeature = {
		Name = "Virus Attack",
		Description = "Wave-based event where players defeat virus waves for bonus rewards",
		Type = "WaveEvent",
		Settings = {
			EventInterval = 1800, -- 30 minutes
			WaveCount = 5,
			WaveReward = 5000,
			CompletionBonus = 50000,
			Announcement = "Virus Attack! Defend the lab!",
		},
	},

	RecommendedLevel = {35, 50},
	DifficultyTier = 4,

	ZoneBonuses = {
		DPMultiplier = 1.3,
		XPMultiplier = 1.25,
		SpawnRateMultiplier = 1.0,
	},

	BackgroundMusic = "rbxassetid://ComputerLabTheme",
	AmbientColor = Color3.fromRGB(200, 220, 255),
	LightingBrightness = 1.8,
}

-- ============================================================================
-- ZONE 5: GYMNASIUM
-- ============================================================================
ZonesConfig[5] = {
	ID = 5,
	Name = "Gymnasium",
	Description = "Basketball courts, bleachers, and PE equipment. Time to exercise your destruction skills!",
	Theme = "Basketball court, bleachers, locker rooms, PE equipment",

	UnlockRequirements = {
		DP = 1000000,
		Level = 45,
	},

	SpawnLocation = Vector3.new(400, 5, 0),
	SafeZoneRadius = 20,

	HomeworkTypes = {
		{
			Name = "Fitness Log",
			HP = 30000,
			DPReward = 5000,
			XPReward = 1800,
			SpawnWeight = 40,
			Model = "FitnessLog",
		},
		{
			Name = "Sports Report",
			HP = 75000,
			DPReward = 15000,
			XPReward = 5000,
			SpawnWeight = 30,
			Model = "SportsReport",
		},
		{
			Name = "Health Assessment",
			HP = 150000,
			DPReward = 35000,
			XPReward = 12000,
			SpawnWeight = 20,
			Model = "HealthAssessment",
		},
		{
			Name = "Physical Education Portfolio",
			HP = 300000,
			DPReward = 80000,
			XPReward = 25000,
			SpawnWeight = 10,
			Model = "PEPortfolio",
		},
	},

	Boss = {
		Name = "Coach's Impossible Fitness Test",
		HP = 1500000,
		DPReward = 500000,
		XPReward = 100000,
		SpawnInterval = 600,
		SpawnLocation = Vector3.new(400, 5, 40),
		Model = "FitnessTest",
		Attacks = {
			{Name = "Whistle Blast", Damage = 30, Cooldown = 4, Stun = 1},
			{Name = "Dodgeball Barrage", Damage = 40, Cooldown = 6, AOE = true},
			{Name = "Motivational Speech", Damage = 0, Cooldown = 20, Buff = "Enrage"},
		},
	},

	SpecialFeature = {
		Name = "Dodgeball Mode",
		Description = "Dodge falling homework for bonus DP multipliers",
		Type = "MiniGame",
		Settings = {
			EventInterval = 900, -- 15 minutes
			EventDuration = 180, -- 3 minutes
			DodgeBonus = 1.5,
			Announcement = "Dodgeball Mode activated! Dodge homework for bonus DP!",
		},
	},

	RecommendedLevel = {45, 60},
	DifficultyTier = 5,

	ZoneBonuses = {
		DPMultiplier = 1.4,
		XPMultiplier = 1.3,
		SpawnRateMultiplier = 1.2,
	},

	BackgroundMusic = "rbxassetid://GymnasiumTheme",
	AmbientColor = Color3.fromRGB(255, 245, 230),
	LightingBrightness = 2.2,
}

-- ============================================================================
-- ZONE 6: MUSIC ROOM
-- ============================================================================
ZonesConfig[6] = {
	ID = 6,
	Name = "Music Room",
	Description = "Instruments, sheet music, and soundproof walls. Make beautiful destruction!",
	Theme = "Instruments, sheet music stands, soundproof walls, practice rooms",

	UnlockRequirements = {
		DP = 5000000,
		Level = 55,
	},

	SpawnLocation = Vector3.new(500, 5, 0),
	SafeZoneRadius = 15,

	HomeworkTypes = {
		{
			Name = "Sheet Music Practice",
			HP = 100000,
			DPReward = 18000,
			XPReward = 6000,
			SpawnWeight = 40,
			Model = "SheetMusic",
		},
		{
			Name = "Music Theory Test",
			HP = 250000,
			DPReward = 50000,
			XPReward = 16000,
			SpawnWeight = 30,
			Model = "MusicTheoryTest",
		},
		{
			Name = "Instrument Recital Paper",
			HP = 500000,
			DPReward = 120000,
			XPReward = 38000,
			SpawnWeight = 20,
			Model = "RecitalPaper",
		},
		{
			Name = "Symphony Analysis",
			HP = 1000000,
			DPReward = 280000,
			XPReward = 85000,
			SpawnWeight = 10,
			Model = "SymphonyAnalysis",
		},
	},

	Boss = {
		Name = "Discordant Symphony",
		HP = 5000000,
		DPReward = 1500000,
		XPReward = 300000,
		SpawnInterval = 600,
		SpawnLocation = Vector3.new(500, 5, 35),
		Model = "DiscordantSymphony",
		Attacks = {
			{Name = "Sonic Wave", Damage = 50, Cooldown = 4, AOE = true},
			{Name = "Off-Key Note", Damage = 60, Cooldown = 5},
			{Name = "Crescendo", Damage = 100, Cooldown = 12, Knockback = true},
		},
	},

	SpecialFeature = {
		Name = "Rhythm Challenge",
		Description = "Complete rhythm mini-game for 3x damage buff (30 seconds)",
		Type = "RhythmGame",
		Settings = {
			EventInterval = 600, -- 10 minutes
			BuffDuration = 30,
			DamageMultiplier = 3.0,
			Announcement = "Rhythm Challenge! Hit the beat for 3x damage!",
		},
	},

	RecommendedLevel = {55, 70},
	DifficultyTier = 6,

	ZoneBonuses = {
		DPMultiplier = 1.5,
		XPMultiplier = 1.4,
		SpawnRateMultiplier = 1.0,
	},

	BackgroundMusic = "rbxassetid://MusicRoomTheme",
	AmbientColor = Color3.fromRGB(240, 230, 255),
	LightingBrightness = 1.6,
}

-- ============================================================================
-- ZONE 7: ART ROOM
-- ============================================================================
ZonesConfig[7] = {
	ID = 7,
	Name = "Art Room",
	Description = "Paint splatters, easels, and messy art supplies. Create chaos from creativity!",
	Theme = "Paint splatters, easels, sculptures, messy art supplies",

	UnlockRequirements = {
		DP = 25000000,
		Level = 65,
	},

	SpawnLocation = Vector3.new(600, 5, 0),
	SafeZoneRadius = 18,

	HomeworkTypes = {
		{
			Name = "Sketch Assignment",
			HP = 400000,
			DPReward = 75000,
			XPReward = 22000,
			SpawnWeight = 40,
			Model = "SketchAssignment",
		},
		{
			Name = "Painting Project",
			HP = 900000,
			DPReward = 180000,
			XPReward = 52000,
			SpawnWeight = 30,
			Model = "PaintingProject",
		},
		{
			Name = "Sculpture Report",
			HP = 2000000,
			DPReward = 450000,
			XPReward = 125000,
			SpawnWeight = 20,
			Model = "SculptureReport",
		},
		{
			Name = "Art History Essay",
			HP = 4500000,
			DPReward = 1100000,
			XPReward = 300000,
			SpawnWeight = 10,
			Model = "ArtHistoryEssay",
		},
	},

	Boss = {
		Name = "Monstrous Masterpiece",
		HP = 20000000,
		DPReward = 6000000,
		XPReward = 1000000,
		SpawnInterval = 600,
		SpawnLocation = Vector3.new(600, 5, 40),
		Model = "MonstrousMasterpiece",
		Attacks = {
			{Name = "Paint Blast", Damage = 75, Cooldown = 3, AOE = true},
			{Name = "Sculpture Slam", Damage = 100, Cooldown = 6},
			{Name = "Canvas Shield", Damage = 0, Cooldown = 15, Shield = 1000000},
		},
	},

	SpecialFeature = {
		Name = "Creative Burst",
		Description = "Random damage multipliers (1x-5x) applied to each attack",
		Type = "RandomMultiplier",
		Settings = {
			MinMultiplier = 1.0,
			MaxMultiplier = 5.0,
			ChanceForBonus = 0.3, -- 30% chance
			Announcement = "Creative Burst active! Random damage multipliers!",
		},
	},

	RecommendedLevel = {65, 80},
	DifficultyTier = 7,

	ZoneBonuses = {
		DPMultiplier = 1.6,
		XPMultiplier = 1.5,
		SpawnRateMultiplier = 1.1,
	},

	BackgroundMusic = "rbxassetid://ArtRoomTheme",
	AmbientColor = Color3.fromRGB(255, 235, 245),
	LightingBrightness = 2,
}

-- ============================================================================
-- ZONE 8: SCIENCE LAB
-- ============================================================================
ZonesConfig[8] = {
	ID = 8,
	Name = "Science Lab",
	Description = "Bubbling beakers, lab equipment, and volatile experiments await!",
	Theme = "Bubbling beakers, lab equipment, periodic table, safety goggles",

	UnlockRequirements = {
		DP = 100000000,
		Level = 75,
	},

	SpawnLocation = Vector3.new(700, 5, 0),
	SafeZoneRadius = 18,

	HomeworkTypes = {
		{
			Name = "Lab Report",
			HP = 1500000,
			DPReward = 300000,
			XPReward = 85000,
			SpawnWeight = 40,
			Model = "LabReport",
		},
		{
			Name = "Chemical Equation Sheet",
			HP = 3500000,
			DPReward = 750000,
			XPReward = 200000,
			SpawnWeight = 30,
			Model = "ChemicalEquations",
		},
		{
			Name = "Experiment Documentation",
			HP = 8000000,
			DPReward = 1900000,
			XPReward = 480000,
			SpawnWeight = 20,
			Model = "ExperimentDoc",
		},
		{
			Name = "Scientific Method Project",
			HP = 18000000,
			DPReward = 4500000,
			XPReward = 1100000,
			SpawnWeight = 10,
			Model = "ScientificMethodProject",
		},
	},

	Boss = {
		Name = "Failed Experiment",
		HP = 75000000,
		DPReward = 25000000,
		XPReward = 4000000,
		SpawnInterval = 600,
		SpawnLocation = Vector3.new(700, 5, 45),
		Model = "FailedExperiment",
		Attacks = {
			{Name = "Acid Splash", Damage = 100, Cooldown = 4, DOT = 20},
			{Name = "Chemical Explosion", Damage = 150, Cooldown = 8, AOE = true},
			{Name = "Toxic Cloud", Damage = 50, Cooldown = 6, AOE = true, DOT = 30},
		},
	},

	SpecialFeature = {
		Name = "Chemical Reaction",
		Description = "Combine homework elements for mega explosions and bonus damage",
		Type = "ComboSystem",
		Settings = {
			ComboBonus = 2.5,
			ExplosionRadius = 30,
			ComboDuration = 5,
			Announcement = "Chemical Reaction! Combo attacks for mega damage!",
		},
	},

	RecommendedLevel = {75, 90},
	DifficultyTier = 8,

	ZoneBonuses = {
		DPMultiplier = 1.8,
		XPMultiplier = 1.6,
		SpawnRateMultiplier = 1.0,
	},

	BackgroundMusic = "rbxassetid://ScienceLabTheme",
	AmbientColor = Color3.fromRGB(220, 255, 220),
	LightingBrightness = 1.9,
}

-- ============================================================================
-- ZONE 9: PRINCIPAL'S OFFICE
-- ============================================================================
ZonesConfig[9] = {
	ID = 9,
	Name = "Principal's Office",
	Description = "The ultimate authority. An intimidating desk, trophies, and your permanent record.",
	Theme = "Intimidating desk, trophy case, detention slips, report cards",

	UnlockRequirements = {
		DP = 500000000,
		Level = 90,
		RebirthLevel = 3,
	},

	SpawnLocation = Vector3.new(800, 5, 0),
	SafeZoneRadius = 20,

	HomeworkTypes = {
		{
			Name = "Detention Essay",
			HP = 7000000,
			DPReward = 1500000,
			XPReward = 350000,
			SpawnWeight = 40,
			Model = "DetentionEssay",
		},
		{
			Name = "Behavior Report",
			HP = 15000000,
			DPReward = 3500000,
			XPReward = 800000,
			SpawnWeight = 30,
			Model = "BehaviorReport",
		},
		{
			Name = "Academic Probation File",
			HP = 35000000,
			DPReward = 9000000,
			XPReward = 2000000,
			SpawnWeight = 20,
			Model = "ProbationFile",
		},
		{
			Name = "Permanent Record",
			HP = 80000000,
			DPReward = 22000000,
			XPReward = 5000000,
			SpawnWeight = 10,
			Model = "PermanentRecord",
		},
	},

	Boss = {
		Name = "THE PRINCIPAL",
		HP = 500000000,
		DPReward = 200000000,
		XPReward = 25000000,
		SpawnInterval = 900, -- 15 minutes
		SpawnLocation = Vector3.new(800, 5, 50),
		Model = "ThePrincipal",
		Attacks = {
			{Name = "Authority Strike", Damage = 150, Cooldown = 3},
			{Name = "Detention Wave", Damage = 100, Cooldown = 5, AOE = true, Stun = 2},
			{Name = "Expulsion Beam", Damage = 300, Cooldown = 10, Knockback = true},
			{Name = "Final Warning", Damage = 500, Cooldown = 20},
		},
	},

	SpecialFeature = {
		Name = "Sent to Detention",
		Description = "Survive waves of homework with increasing difficulty",
		Type = "SurvivalWave",
		Settings = {
			EventInterval = 1200, -- 20 minutes
			WaveCount = 10,
			DifficultyIncrease = 1.5,
			CompletionReward = 100000000,
			Announcement = "Sent to Detention! Survive the homework waves!",
		},
	},

	RecommendedLevel = {90, 100},
	DifficultyTier = 9,

	ZoneBonuses = {
		DPMultiplier = 2.0,
		XPMultiplier = 1.8,
		SpawnRateMultiplier = 1.0,
	},

	BackgroundMusic = "rbxassetid://PrincipalOfficeTheme",
	AmbientColor = Color3.fromRGB(200, 200, 220),
	LightingBrightness = 1.5,
}

-- ============================================================================
-- SECRET ZONE 10: THE VOID
-- ============================================================================
ZonesConfig[10] = {
	ID = 10,
	Name = "The Void",
	Description = "A dark dimension where homework fragments float in distorted reality. The ultimate challenge.",
	Theme = "Dark dimension, floating homework fragments, distorted reality",

	UnlockRequirements = {
		DP = 10000000000, -- 10 billion
		Level = 100,
		RebirthLevel = 25,
		PrestigeRank = 3,
	},

	SpawnLocation = Vector3.new(0, 100, 1000),
	SafeZoneRadius = 25,

	HomeworkTypes = {
		{
			Name = "Void Assignment",
			HP = 500000000,
			DPReward = 150000000,
			XPReward = 20000000,
			SpawnWeight = 40,
			Model = "VoidAssignment",
		},
		{
			Name = "Dimensional Essay",
			HP = 1500000000,
			DPReward = 500000000,
			XPReward = 60000000,
			SpawnWeight = 30,
			Model = "DimensionalEssay",
		},
		{
			Name = "Reality-Breaking Test",
			HP = 5000000000,
			DPReward = 2000000000,
			XPReward = 200000000,
			SpawnWeight = 20,
			Model = "RealityBreakingTest",
		},
		{
			Name = "THE ULTIMATE HOMEWORK",
			HP = 25000000000,
			DPReward = 12000000000,
			XPReward = 1000000000,
			SpawnWeight = 10,
			Model = "UltimateHomework",
		},
	},

	Boss = {
		Name = "HOMEWORK OVERLORD",
		HP = 100000000000, -- 100 billion
		DPReward = 50000000000,
		XPReward = 5000000000,
		SpawnInterval = 1200, -- 20 minutes
		SpawnLocation = Vector3.new(0, 100, 1100),
		Model = "HomeworkOverlord",
		Attacks = {
			{Name = "Void Slash", Damage = 250, Cooldown = 2},
			{Name = "Homework Storm", Damage = 200, Cooldown = 4, AOE = true},
			{Name = "Reality Warp", Damage = 300, Cooldown = 6, Teleport = true},
			{Name = "Dimensional Collapse", Damage = 500, Cooldown = 12, AOE = true, Stun = 3},
			{Name = "ULTIMATE DESTRUCTION", Damage = 1000, Cooldown = 30},
		},
	},

	SpecialFeature = {
		Name = "Void Mechanics",
		Description = "Gravity shifts, homework fights back, true endgame challenge",
		Type = "AdvancedMechanics",
		Settings = {
			GravityShift = true,
			HomeworkCounterAttack = true,
			RealityDistortion = true,
			DamageReflection = 0.1, -- Homework reflects 10% damage
			Announcement = "Welcome to The Void. Reality no longer applies here.",
		},
	},

	RecommendedLevel = {100, 100},
	DifficultyTier = 10,

	ZoneBonuses = {
		DPMultiplier = 5.0,
		XPMultiplier = 3.0,
		SpawnRateMultiplier = 0.8,
	},

	BackgroundMusic = "rbxassetid://VoidTheme",
	AmbientColor = Color3.fromRGB(20, 0, 40),
	LightingBrightness = 0.5,

	-- Special void effects
	VoidEffects = {
		ParticleColor = Color3.fromRGB(138, 43, 226),
		FogEnabled = true,
		FogColor = Color3.fromRGB(10, 0, 20),
		FogStart = 50,
		FogEnd = 500,
	},
}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Get zone configuration by ID
function ZonesConfig.GetZone(zoneID)
	return ZonesConfig[zoneID]
end

-- Get zone name by ID
function ZonesConfig.GetZoneName(zoneID)
	local zone = ZonesConfig[zoneID]
	return zone and zone.Name or "Unknown Zone"
end

-- Check if player meets zone unlock requirements
function ZonesConfig.CanUnlockZone(zoneID, playerData)
	local zone = ZonesConfig[zoneID]
	if not zone then
		return false, "Zone does not exist"
	end

	local requirements = zone.UnlockRequirements

	-- Check DP requirement
	if playerData.DestructionPoints < requirements.DP then
		return false, string.format("Requires %s DP", ZonesConfig.FormatNumber(requirements.DP))
	end

	-- Check level requirement
	if playerData.Level < requirements.Level then
		return false, string.format("Requires Level %d", requirements.Level)
	end

	-- Check rebirth requirement (if exists)
	if requirements.RebirthLevel and playerData.RebirthLevel < requirements.RebirthLevel then
		return false, string.format("Requires Rebirth %d", requirements.RebirthLevel)
	end

	-- Check prestige requirement (if exists)
	if requirements.PrestigeRank and playerData.PrestigeLevel < requirements.PrestigeRank then
		return false, string.format("Requires Prestige Rank %d", requirements.PrestigeRank)
	end

	return true, "Requirements met"
end

-- Get all unlocked zones for a player
function ZonesConfig.GetUnlockedZones(playerData)
	local unlockedZones = {}

	for zoneID, zone in pairs(ZonesConfig) do
		if type(zone) == "table" and zone.ID then
			-- Check if zone is in player's unlocked zones list
			for _, unlockedID in ipairs(playerData.UnlockedZones) do
				if unlockedID == zoneID then
					table.insert(unlockedZones, zone)
					break
				end
			end
		end
	end

	return unlockedZones
end

-- Get next locked zone that player can potentially unlock
function ZonesConfig.GetNextZone(playerData)
	for i = 1, 10 do
		-- Check if zone is not already unlocked
		local isUnlocked = false
		for _, unlockedID in ipairs(playerData.UnlockedZones) do
			if unlockedID == i then
				isUnlocked = true
				break
			end
		end

		if not isUnlocked then
			return ZonesConfig[i]
		end
	end

	return nil -- All zones unlocked
end

-- Get unlock cost for a zone
function ZonesConfig.GetUnlockCost(zoneID)
	local zone = ZonesConfig[zoneID]
	if not zone then
		return 0
	end
	return zone.UnlockRequirements.DP
end

-- Calculate zone bonuses based on player stats
function ZonesConfig.ApplyZoneBonuses(zoneID, baseValue, bonusType)
	local zone = ZonesConfig[zoneID]
	if not zone then
		return baseValue
	end

	local multiplier = 1.0
	if bonusType == "DP" then
		multiplier = zone.ZoneBonuses.DPMultiplier
	elseif bonusType == "XP" then
		multiplier = zone.ZoneBonuses.XPMultiplier
	elseif bonusType == "Spawn" then
		multiplier = zone.ZoneBonuses.SpawnRateMultiplier
	end

	return baseValue * multiplier
end

-- Format large numbers for display
function ZonesConfig.FormatNumber(num)
	if num >= 1000000000000 then
		return string.format("%.2fT", num / 1000000000000)
	elseif num >= 1000000000 then
		return string.format("%.2fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.2fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.2fK", num / 1000)
	else
		return tostring(num)
	end
end

-- Get total number of zones
function ZonesConfig.GetTotalZones()
	return 10
end

-- Get zones by difficulty tier
function ZonesConfig.GetZonesByDifficulty(difficultyTier)
	local zones = {}
	for i = 1, 10 do
		local zone = ZonesConfig[i]
		if zone.DifficultyTier == difficultyTier then
			table.insert(zones, zone)
		end
	end
	return zones
end

-- Check if zone is a secret zone
function ZonesConfig.IsSecretZone(zoneID)
	return zoneID == 10 -- The Void is the only secret zone
end

return ZonesConfig
