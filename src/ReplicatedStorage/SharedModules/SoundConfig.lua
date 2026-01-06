--[[
	SoundConfig.lua
	Complete sound effects configuration for Homework Destroyer

	Defines all sound effects with IDs, volumes, and playback settings
	Organized by category: Combat, UI, Ambient, Boss, Achievement

	Note: Some sound IDs are placeholders (rbxassetid://0)
	These should be replaced with actual Roblox audio library IDs or uploaded sounds
]]

local SoundConfig = {}

-- ========================================
-- ROBLOX FREE AUDIO LIBRARY IDs
-- ========================================
--[[
	WORKING Roblox Sound IDs (from free audio library):
	- Click: 12221967 (Button click)
	- Success: 12222084 (Success chime)
	- Error: 12222095 (Error buzz)
	- Explosion: 12222216 (Explosion sound)
	- Whoosh: 12222030 (Whoosh/swing)
	- PowerUp: 12221976 (Power up sound)
	- Victory: 12222252 (Victory fanfare)
	- Hit: 12222105 (Impact sound)
	- Metal: 12222095 (Metal clang)
	- Glass: 12222124 (Glass break)
	- Sparkle: 12221967 (Sparkle)

	NOTE: These IDs are from Roblox's older audio library.
	For production, you should:
	1. Use Roblox's Creator Marketplace free sounds
	2. Upload your own audio (requires ID verification)
	3. Use audio discovery service in Studio
]]

-- ========================================
-- SOUND CATEGORIES
-- ========================================

SoundConfig.Categories = {
	Combat = "Combat",
	UI = "UI",
	Ambient = "Ambient",
	Boss = "Boss",
	Achievement = "Achievement",
	Pet = "Pet",
	Zone = "Zone"
}

-- ========================================
-- COMBAT SOUNDS
-- ========================================

SoundConfig.Combat = {

	-- Click/Hit Sounds (Different per tool type)
	Hit_Paper = {
		SoundId = "rbxassetid://12222105",
		Volume = 0.3,
		Pitch = 1.0,
		PitchVariation = 0.1,
		Category = "Combat",
		Description = "Paper rip/crunch sound",
		Type = "3D", -- Plays at homework position
		MaxDistance = 50,
		RollOffMaxDistance = 100
	},

	Hit_Scissors = {
		SoundId = "rbxassetid://12222124", -- Glass/cutting sound
		Volume = 0.35,
		Pitch = 1.2,
		PitchVariation = 0.15,
		Category = "Combat",
		Description = "Scissors cutting sound",
		Type = "3D",
		MaxDistance = 50,
		RollOffMaxDistance = 100
	},

	Hit_Ruler = {
		SoundId = "rbxassetid://12222030", -- Whoosh
		Volume = 0.3,
		Pitch = 0.9,
		PitchVariation = 0.1,
		Category = "Combat",
		Description = "Ruler whack sound",
		Type = "3D",
		MaxDistance = 50,
		RollOffMaxDistance = 100
	},

	Hit_Marker = {
		SoundId = "rbxassetid://12221967",
		Volume = 0.25,
		Pitch = 1.1,
		PitchVariation = 0.1,
		Category = "Combat",
		Description = "Marker squeak",
		Type = "3D",
		MaxDistance = 50,
		RollOffMaxDistance = 100
	},

	Hit_Heavy = {
		SoundId = "rbxassetid://12222095", -- Metal clang
		Volume = 0.4,
		Pitch = 0.8,
		PitchVariation = 0.1,
		Category = "Combat",
		Description = "Heavy weapon impact (hammer, textbook)",
		Type = "3D",
		MaxDistance = 75,
		RollOffMaxDistance = 150
	},

	Hit_Energy = {
		SoundId = "rbxassetid://12221976", -- Power up
		Volume = 0.35,
		Pitch = 1.3,
		PitchVariation = 0.15,
		Category = "Combat",
		Description = "Energy weapon (laser, tesla coil)",
		Type = "3D",
		MaxDistance = 60,
		RollOffMaxDistance = 120
	},

	-- Critical Hit
	CriticalHit = {
		SoundId = "rbxassetid://12222216", -- Explosion
		Volume = 0.5,
		Pitch = 1.2,
		PitchVariation = 0.1,
		Category = "Combat",
		Description = "Critical hit impact",
		Type = "3D",
		MaxDistance = 100,
		RollOffMaxDistance = 200
	},

	-- Homework Destruction
	HomeworkDestroy = {
		SoundId = "rbxassetid://12222084", -- Success chime
		Volume = 0.4,
		Pitch = 1.0,
		PitchVariation = 0.05,
		Category = "Combat",
		Description = "Homework destruction success",
		Type = "3D",
		MaxDistance = 75,
		RollOffMaxDistance = 150
	},

	-- Multi-Hit/Chain
	ChainHit = {
		SoundId = "rbxassetid://12221967", -- Sparkle/chain sound
		Volume = 0.35,
		Pitch = 1.4,
		PitchVariation = 0.2,
		Category = "Combat",
		Description = "Chain lightning/multi-hit effect",
		Type = "3D",
		MaxDistance = 80,
		RollOffMaxDistance = 160
	},

	-- Special Effect Trigger
	SpecialEffect = {
		SoundId = "rbxassetid://12221976", -- Power up
		Volume = 0.4,
		Pitch = 1.0,
		PitchVariation = 0.1,
		Category = "Combat",
		Description = "Special effect activated",
		Type = "3D",
		MaxDistance = 70,
		RollOffMaxDistance = 140
	}
}

-- ========================================
-- BOSS SOUNDS
-- ========================================

SoundConfig.Boss = {

	-- Boss Spawn
	BossSpawn = {
		SoundId = "rbxassetid://12222252", -- Victory/dramatic sound
		Volume = 0.7,
		Pitch = 0.8,
		PitchVariation = 0,
		Category = "Boss",
		Description = "Boss spawned warning",
		Type = "2D", -- Plays for all players
	},

	-- Boss Hit (special sound for hitting boss)
	BossHit = {
		SoundId = "rbxassetid://12222095", -- Metal clang
		Volume = 0.45,
		Pitch = 0.9,
		PitchVariation = 0.1,
		Category = "Boss",
		Description = "Hit boss",
		Type = "3D",
		MaxDistance = 100,
		RollOffMaxDistance = 200
	},

	-- Boss Defeated
	BossDefeat = {
		SoundId = "rbxassetid://12222252", -- Victory fanfare
		Volume = 0.8,
		Pitch = 1.0,
		PitchVariation = 0,
		Category = "Boss",
		Description = "Boss defeated victory",
		Type = "2D", -- Plays for all players
	}
}

-- ========================================
-- UI SOUNDS
-- ========================================

SoundConfig.UI = {

	-- Button Click
	ButtonClick = {
		SoundId = "rbxassetid://12221967", -- Click
		Volume = 0.3,
		Pitch = 1.0,
		PitchVariation = 0.05,
		Category = "UI",
		Description = "Generic button click",
		Type = "2D"
	},

	-- Button Hover
	ButtonHover = {
		SoundId = "rbxassetid://12221967",
		Volume = 0.15,
		Pitch = 1.2,
		PitchVariation = 0,
		Category = "UI",
		Description = "Button hover sound",
		Type = "2D"
	},

	-- Purchase Success
	PurchaseSuccess = {
		SoundId = "rbxassetid://12222084", -- Success chime
		Volume = 0.5,
		Pitch = 1.0,
		PitchVariation = 0,
		Category = "UI",
		Description = "Successful purchase",
		Type = "2D"
	},

	-- Purchase Fail
	PurchaseFail = {
		SoundId = "rbxassetid://12222095", -- Error buzz
		Volume = 0.4,
		Pitch = 0.8,
		PitchVariation = 0,
		Category = "UI",
		Description = "Purchase failed/insufficient funds",
		Type = "2D"
	},

	-- Level Up
	LevelUp = {
		SoundId = "rbxassetid://12221976", -- Power up
		Volume = 0.6,
		Pitch = 1.0,
		PitchVariation = 0,
		Category = "UI",
		Description = "Player leveled up",
		Type = "2D"
	},

	-- Achievement Unlock
	AchievementUnlock = {
		SoundId = "rbxassetid://12222252", -- Victory
		Volume = 0.6,
		Pitch = 1.1,
		PitchVariation = 0,
		Category = "UI",
		Description = "Achievement unlocked",
		Type = "2D"
	},

	-- Tab Switch
	TabSwitch = {
		SoundId = "rbxassetid://12221967",
		Volume = 0.25,
		Pitch = 1.1,
		PitchVariation = 0,
		Category = "UI",
		Description = "UI tab switch",
		Type = "2D"
	},

	-- Window Open
	WindowOpen = {
		SoundId = "rbxassetid://12222030", -- Whoosh
		Volume = 0.3,
		Pitch = 1.0,
		PitchVariation = 0,
		Category = "UI",
		Description = "UI window opened",
		Type = "2D"
	},

	-- Window Close
	WindowClose = {
		SoundId = "rbxassetid://12222030",
		Volume = 0.3,
		Pitch = 0.9,
		PitchVariation = 0,
		Category = "UI",
		Description = "UI window closed",
		Type = "2D"
	},

	-- Notification Appear
	NotificationAppear = {
		SoundId = "rbxassetid://12221967",
		Volume = 0.35,
		Pitch = 1.2,
		PitchVariation = 0,
		Category = "UI",
		Description = "Notification popup",
		Type = "2D"
	},

	-- Rebirth/Prestige
	Rebirth = {
		SoundId = "rbxassetid://12222252", -- Victory
		Volume = 0.7,
		Pitch = 0.9,
		PitchVariation = 0,
		Category = "UI",
		Description = "Rebirth/Prestige completed",
		Type = "2D"
	},

	-- Egg Hatch
	EggHatch = {
		SoundId = "rbxassetid://12222084", -- Success
		Volume = 0.5,
		Pitch = 1.1,
		PitchVariation = 0.1,
		Category = "UI",
		Description = "Pet egg hatched",
		Type = "2D"
	}
}

-- ========================================
-- AMBIENT SOUNDS
-- ========================================

SoundConfig.Ambient = {

	-- Background Music (per zone)
	-- Note: Background music should be looping and subtle

	BGM_Classroom = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload ambient classroom music
		Volume = 0.2,
		Pitch = 1.0,
		Category = "Ambient",
		Description = "Classroom background ambience",
		Type = "2D",
		Looped = true,
		FadeInTime = 2,
		FadeOutTime = 2
	},

	BGM_Library = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload library ambience
		Volume = 0.2,
		Pitch = 1.0,
		Category = "Ambient",
		Description = "Library background ambience",
		Type = "2D",
		Looped = true,
		FadeInTime = 2,
		FadeOutTime = 2
	},

	BGM_Cafeteria = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload cafeteria ambience
		Volume = 0.25,
		Pitch = 1.0,
		Category = "Ambient",
		Description = "Cafeteria background ambience",
		Type = "2D",
		Looped = true,
		FadeInTime = 2,
		FadeOutTime = 2
	},

	BGM_ComputerLab = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload computer lab ambience
		Volume = 0.2,
		Pitch = 1.0,
		Category = "Ambient",
		Description = "Computer Lab background ambience",
		Type = "2D",
		Looped = true,
		FadeInTime = 2,
		FadeOutTime = 2
	},

	BGM_Gymnasium = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload gym ambience
		Volume = 0.25,
		Pitch = 1.0,
		Category = "Ambient",
		Description = "Gymnasium background ambience",
		Type = "2D",
		Looped = true,
		FadeInTime = 2,
		FadeOutTime = 2
	},

	BGM_MusicRoom = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload music room ambience
		Volume = 0.25,
		Pitch = 1.0,
		Category = "Ambient",
		Description = "Music Room background ambience",
		Type = "2D",
		Looped = true,
		FadeInTime = 2,
		FadeOutTime = 2
	},

	BGM_ArtRoom = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload art room ambience
		Volume = 0.2,
		Pitch = 1.0,
		Category = "Ambient",
		Description = "Art Room background ambience",
		Type = "2D",
		Looped = true,
		FadeInTime = 2,
		FadeOutTime = 2
	},

	BGM_ScienceLab = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload science lab ambience
		Volume = 0.2,
		Pitch = 1.0,
		Category = "Ambient",
		Description = "Science Lab background ambience",
		Type = "2D",
		Looped = true,
		FadeInTime = 2,
		FadeOutTime = 2
	},

	BGM_PrincipalsOffice = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload tense/dramatic music
		Volume = 0.25,
		Pitch = 1.0,
		Category = "Ambient",
		Description = "Principal's Office background music",
		Type = "2D",
		Looped = true,
		FadeInTime = 2,
		FadeOutTime = 2
	},

	BGM_TheVoid = {
		SoundId = "rbxassetid://0", -- PLACEHOLDER - Upload ominous/void ambience
		Volume = 0.3,
		Pitch = 0.9,
		Category = "Ambient",
		Description = "The Void background ambience",
		Type = "2D",
		Looped = true,
		FadeInTime = 3,
		FadeOutTime = 3
	},

	-- Zone Transition
	ZoneTransition = {
		SoundId = "rbxassetid://12222030", -- Whoosh
		Volume = 0.4,
		Pitch = 1.0,
		PitchVariation = 0,
		Category = "Ambient",
		Description = "Zone transition effect",
		Type = "2D"
	}
}

-- ========================================
-- PET SOUNDS
-- ========================================

SoundConfig.Pet = {

	-- Pet Auto-Attack
	PetAttack = {
		SoundId = "rbxassetid://12221967",
		Volume = 0.2,
		Pitch = 1.3,
		PitchVariation = 0.1,
		Category = "Pet",
		Description = "Pet performs auto-attack",
		Type = "3D",
		MaxDistance = 40,
		RollOffMaxDistance = 80
	},

	-- Pet Level Up
	PetLevelUp = {
		SoundId = "rbxassetid://12221976", -- Power up
		Volume = 0.4,
		Pitch = 1.2,
		PitchVariation = 0,
		Category = "Pet",
		Description = "Pet leveled up",
		Type = "2D"
	},

	-- Pet Equip
	PetEquip = {
		SoundId = "rbxassetid://12222084", -- Success
		Volume = 0.3,
		Pitch = 1.1,
		PitchVariation = 0,
		Category = "Pet",
		Description = "Pet equipped",
		Type = "2D"
	},

	-- Pet Fusion
	PetFusion = {
		SoundId = "rbxassetid://12222252", -- Victory
		Volume = 0.5,
		Pitch = 1.0,
		PitchVariation = 0,
		Category = "Pet",
		Description = "Pet fusion completed",
		Type = "2D"
	}
}

-- ========================================
-- TOOL-TO-SOUND MAPPING
-- ========================================

-- Maps tool categories/types to their hit sounds
SoundConfig.ToolSounds = {
	-- Basic/Starter tools
	["PencilEraser"] = "Hit_Paper",
	["WoodenRuler"] = "Hit_Ruler",
	["SafetyScissors"] = "Hit_Scissors",
	["PermanentMarker"] = "Hit_Marker",
	["StapleRemover"] = "Hit_Scissors",

	-- Mid-game tools
	["ElectricPencilSharpener"] = "Hit_Energy",
	["Textbook"] = "Hit_Heavy",
	["LaserPointer"] = "Hit_Energy",
	["IndustrialShredder"] = "Hit_Heavy",
	["DetentionHammer"] = "Hit_Heavy",

	-- Late-game tools
	["AcidBeaker"] = "Hit_Energy",
	["TeslaCoilPen"] = "Hit_Energy",
	["BlackHoleBackpack"] = "Hit_Energy",
	["ReportCardShuriken"] = "Hit_Paper",
	["NuclearEraser"] = "Hit_Heavy",

	-- Endgame/Secret
	["PrincipalsGoldenPen"] = "Hit_Energy",
	["VoidEraser"] = "Hit_Energy",
	["TheDestroyersHand"] = "Hit_Heavy"
}

-- Default sound by tool category
SoundConfig.DefaultToolSounds = {
	Starter = "Hit_Paper",
	MidGame = "Hit_Heavy",
	LateGame = "Hit_Energy",
	Endgame = "Hit_Energy",
	Secret = "Hit_Energy",
	Ultimate = "Hit_Heavy"
}

-- ========================================
-- SOUND PRESETS
-- ========================================

-- Master volume multipliers (for settings)
SoundConfig.MasterVolume = {
	Master = 1.0,
	Combat = 1.0,
	UI = 1.0,
	Ambient = 1.0,
	Boss = 1.0
}

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

-- Get sound config by name
function SoundConfig.GetSound(soundName)
	-- Search all categories
	for _, category in pairs({SoundConfig.Combat, SoundConfig.Boss, SoundConfig.UI, SoundConfig.Ambient, SoundConfig.Pet}) do
		if category[soundName] then
			return category[soundName]
		end
	end
	return nil
end

-- Get tool hit sound ID
function SoundConfig.GetToolSound(toolID, toolCategory)
	-- Try direct mapping first
	local soundName = SoundConfig.ToolSounds[toolID]

	-- Fall back to category default
	if not soundName and toolCategory then
		soundName = SoundConfig.DefaultToolSounds[toolCategory]
	end

	-- Fall back to generic hit
	soundName = soundName or "Hit_Paper"

	return SoundConfig.Combat[soundName]
end

-- Get zone background music
function SoundConfig.GetZoneMusic(zoneID)
	local musicKeys = {
		[1] = "BGM_Classroom",
		[2] = "BGM_Library",
		[3] = "BGM_Cafeteria",
		[4] = "BGM_ComputerLab",
		[5] = "BGM_Gymnasium",
		[6] = "BGM_MusicRoom",
		[7] = "BGM_ArtRoom",
		[8] = "BGM_ScienceLab",
		[9] = "BGM_PrincipalsOffice",
		[10] = "BGM_TheVoid"
	}

	local musicKey = musicKeys[zoneID]
	return musicKey and SoundConfig.Ambient[musicKey]
end

-- Calculate final volume with master volume multipliers
function SoundConfig.CalculateVolume(soundConfig, categoryVolume)
	categoryVolume = categoryVolume or 1.0
	local baseVolume = soundConfig.Volume or 0.5

	return baseVolume * categoryVolume * SoundConfig.MasterVolume.Master
end

-- Apply random pitch variation
function SoundConfig.GetRandomPitch(soundConfig)
	local basePitch = soundConfig.Pitch or 1.0
	local variation = soundConfig.PitchVariation or 0

	if variation > 0 then
		return basePitch + (math.random() * variation * 2 - variation)
	end

	return basePitch
end

-- Check if sound ID is placeholder
function SoundConfig.IsPlaceholder(soundConfig)
	return soundConfig.SoundId == "rbxassetid://0"
end

return SoundConfig
