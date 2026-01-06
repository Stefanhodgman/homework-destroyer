--[[
	PetConfig.lua
	Configuration for all pets, eggs, rarities, and stats
	Part of the Homework Destroyer Pet System
]]

local PetConfig = {}

-- ==================== RARITY DEFINITIONS ====================
PetConfig.Rarities = {
	Common = {
		Name = "Common",
		Color = Color3.fromRGB(255, 255, 255), -- White
		DropRate = 50, -- 50%
		DamageBonus = 0.05, -- +5%
		PassiveStrength = "Minor"
	},
	Uncommon = {
		Name = "Uncommon",
		Color = Color3.fromRGB(85, 255, 85), -- Green
		DropRate = 30, -- 30%
		DamageBonus = 0.15, -- +15%
		PassiveStrength = "Small"
	},
	Rare = {
		Name = "Rare",
		Color = Color3.fromRGB(85, 170, 255), -- Blue
		DropRate = 15, -- 15%
		DamageBonus = 0.35, -- +35%
		PassiveStrength = "Moderate"
	},
	Epic = {
		Name = "Epic",
		Color = Color3.fromRGB(170, 85, 255), -- Purple
		DropRate = 4, -- 4%
		DamageBonus = 0.75, -- +75%
		PassiveStrength = "Significant"
	},
	Legendary = {
		Name = "Legendary",
		Color = Color3.fromRGB(255, 170, 0), -- Orange
		DropRate = 0.9, -- 0.9%
		DamageBonus = 1.5, -- +150%
		PassiveStrength = "Powerful"
	},
	Mythic = {
		Name = "Mythic",
		Color = Color3.fromRGB(255, 85, 85), -- Red
		DropRate = 0.1, -- 0.1%
		DamageBonus = 4.0, -- +400%
		PassiveStrength = "Extreme"
	}
}

-- ==================== PET DEFINITIONS ====================
PetConfig.Pets = {

	-- ========== COMMON PETS ==========
	PaperAirplane = {
		Name = "Paper Airplane",
		Rarity = "Common",
		Description = "Flies around destroying worksheets.",
		AutoAttackDamage = 5,
		AutoAttackSpeed = 3, -- seconds
		PassiveBonus = {
			Type = "MovementSpeed",
			Value = 0.03 -- +3%
		},
		MaxLevelBonus = {
			Type = "PaperDamage",
			Value = 0.10 -- +10% paper homework damage
		},
		ModelName = "PaperAirplanePet",
		Size = 1.5,
		FloatHeight = 2
	},

	PencilBuddy = {
		Name = "Pencil Buddy",
		Rarity = "Common",
		Description = "Your number two companion.",
		AutoAttackDamage = 8,
		AutoAttackSpeed = 3,
		PassiveBonus = {
			Type = "XPGain",
			Value = 0.05 -- +5%
		},
		MaxLevelBonus = {
			Type = "XPGain",
			Value = 0.15 -- +15%
		},
		ModelName = "PencilBuddyPet",
		Size = 1.2,
		FloatHeight = 1
	},

	EraserBlob = {
		Name = "Eraser Blob",
		Rarity = "Common",
		Description = "Bounces around erasing mistakes... permanently.",
		AutoAttackDamage = 6,
		AutoAttackSpeed = 2.5,
		PassiveBonus = {
			Type = "DPGain",
			Value = 0.03 -- +3%
		},
		MaxLevelBonus = {
			Type = "DoubleDPChance",
			Value = 0.08 -- 8% chance to double DP
		},
		ModelName = "EraserBlobPet",
		Size = 1.3,
		FloatHeight = 0.5
	},

	-- ========== UNCOMMON PETS ==========
	AngryCalculator = {
		Name = "Angry Calculator",
		Rarity = "Uncommon",
		Description = "ERROR: DIVISION BY DESTRUCTION",
		AutoAttackDamage = 20,
		AutoAttackSpeed = 2.5,
		PassiveBonus = {
			Type = "MathHomeworkDamage",
			Value = 0.10 -- +10%
		},
		MaxLevelBonus = {
			Type = "MathHomeworkDamage",
			Value = 0.25, -- +25%
			Special = "CalculatesOptimalTargets"
		},
		ModelName = "AngryCalculatorPet",
		Size = 1.4,
		FloatHeight = 1.5
	},

	RunawayScissors = {
		Name = "Runaway Scissors",
		Rarity = "Uncommon",
		Description = "Finally free to run.",
		AutoAttackDamage = 35,
		AutoAttackSpeed = 2,
		PassiveBonus = {
			Type = "CritChance",
			Value = 0.08 -- +8%
		},
		MaxLevelBonus = {
			Type = "CritChance",
			Value = 0.15, -- +15%
			Special = "CritsCauseBleeding"
		},
		ModelName = "RunawayScissorsPet",
		Size = 1.5,
		FloatHeight = 1.2
	},

	CafeteriaSlime = {
		Name = "Cafeteria Slime",
		Rarity = "Uncommon",
		Description = "Mystery meat's revenge.",
		AutoAttackDamage = 25,
		AutoAttackSpeed = 2,
		PassiveBonus = {
			Type = "ZoneDPBonus",
			Zone = "Cafeteria",
			Value = 0.12 -- +12% in Cafeteria
		},
		MaxLevelBonus = {
			Type = "AbsorptionStacks",
			Value = 0.01, -- +1% per absorption
			MaxStacks = 50,
			Special = "GrowsStrongerWithEachKill"
		},
		ModelName = "CafeteriaSlimePet",
		Size = 1.6,
		FloatHeight = 0.3
	},

	-- ========== RARE PETS ==========
	HyperactiveHamster = {
		Name = "Hyperactive Hamster",
		Rarity = "Rare",
		Description = "Running on pure energy and spite.",
		AutoAttackDamage = 80,
		AutoAttackSpeed = 1.5,
		PassiveBonus = {
			Type = "AttackSpeed",
			Value = 0.15 -- +15%
		},
		MaxLevelBonus = {
			Type = "AttackSpeed",
			Value = 0.25, -- +25%
			Special = "HamsterWheelBoost" -- 5 sec speed boost
		},
		ModelName = "HyperactiveHamsterPet",
		Size = 1.3,
		FloatHeight = 0.5
	},

	FloatingTextbook = {
		Name = "Floating Textbook",
		Rarity = "Rare",
		Description = "The student becomes the teacher.",
		AutoAttackDamage = 120,
		AutoAttackSpeed = 2,
		PassiveBonus = {
			Type = "MultiBonus",
			Bonuses = {
				{Type = "ZoneDamageBonus", Zone = "Library", Value = 0.20},
				{Type = "XPGain", Value = 0.10}
			}
		},
		MaxLevelBonus = {
			Type = "KnowledgeOrbs",
			Value = 500, -- +500 XP per orb
			Special = "DropsKnowledgeOrbs"
		},
		ModelName = "FloatingTextbookPet",
		Size = 1.8,
		FloatHeight = 2.5
	},

	ComputerVirus = {
		Name = "Computer Virus",
		Rarity = "Rare",
		Description = "Corrupting files and homework alike.",
		AutoAttackDamage = 100,
		AutoAttackSpeed = 1.5,
		TargetCount = 3, -- Hits 3 targets
		PassiveBonus = {
			Type = "ZoneDamageBonus",
			Zone = "ComputerLab",
			Value = 0.15 -- +15%
		},
		MaxLevelBonus = {
			Type = "Infection",
			Value = 0.10, -- -10% boss defense
			Special = "InfectsBossHomework"
		},
		ModelName = "ComputerVirusPet",
		Size = 1.4,
		FloatHeight = 1.5
	},

	-- ========== EPIC PETS ==========
	FlamingReportCard = {
		Name = "Flaming Report Card",
		Rarity = "Epic",
		Description = "Straight A's in destruction.",
		AutoAttackDamage = 300,
		AutoAttackSpeed = 1.5,
		BurnDamage = 50, -- DPS
		BurnDuration = 3, -- seconds
		PassiveBonus = {
			Type = "MultiBonus",
			Bonuses = {
				{Type = "CritDamage", Value = 0.30},
				{Type = "AllDamage", Value = 0.10}
			}
		},
		MaxLevelBonus = {
			Type = "EnhancedBurn",
			BurnDPS = 100,
			BurningDamageBonus = 0.20, -- +20% damage to burning targets
			Special = "EnhancedBurnEffect"
		},
		ModelName = "FlamingReportCardPet",
		Size = 1.6,
		FloatHeight = 2
	},

	MiniShredderBot = {
		Name = "Mini Shredder Bot",
		Rarity = "Epic",
		Description = "Beep boop, homework deleted.",
		AutoAttackDamage = 250,
		AutoAttackSpeed = 1,
		PassiveBonus = {
			Type = "MultiBonus",
			Bonuses = {
				{Type = "PaperDamage", Value = 0.25},
				{Type = "AutoCollectDP", Value = true}
			}
		},
		MaxLevelBonus = {
			Type = "DualShred",
			TargetCount = 2,
			PaperDamageBonus = 0.50, -- +50% paper damage
			Special = "ShredsTwoSimultaneously"
		},
		ModelName = "MiniShredderBotPet",
		Size = 1.7,
		FloatHeight = 1
	},

	DetentionGhost = {
		Name = "Detention Ghost",
		Rarity = "Epic",
		Description = "Serving eternal detention... to homework.",
		AutoAttackDamage = 400,
		AutoAttackSpeed = 2,
		IgnoresDefenses = true,
		PassiveBonus = {
			Type = "MultiBonus",
			Bonuses = {
				{Type = "BossDamage", Value = 0.20},
				{Type = "InvulnerabilityAfterKill", Duration = 0.5}
			}
		},
		MaxLevelBonus = {
			Type = "BossPossession",
			StunDuration = 3, -- seconds
			CooldownPerBoss = true,
			Special = "PossessesBosses"
		},
		ModelName = "DetentionGhostPet",
		Size = 2,
		FloatHeight = 2.5
	},

	-- ========== LEGENDARY PETS ==========
	GoldenEraser = {
		Name = "Golden Eraser",
		Rarity = "Legendary",
		Description = "The ultimate erasing machine.",
		AutoAttackDamage = 1000,
		AutoAttackSpeed = 1,
		PrestigeReward = true, -- Obtained at Prestige Rank III
		PassiveBonus = {
			Type = "MultiBonus",
			Bonuses = {
				{Type = "AllDamage", Value = 0.50},
				{Type = "DPGain", Value = 0.25},
				{Type = "CritChance", Value = 0.20}
			}
		},
		MaxLevelBonus = {
			Type = "DoublePassives",
			Multiplier = 2,
			Special = "GoldenParticlesAttractDP"
		},
		ModelName = "GoldenEraserPet",
		Size = 2.5,
		FloatHeight = 2
	},

	PhoenixHomework = {
		Name = "Phoenix Homework (Tamed)",
		Rarity = "Legendary",
		Description = "Homework reborn... as your ally.",
		AutoAttackDamage = 1500,
		AutoAttackSpeed = 1.5,
		ExplosionOnKill = true,
		PassiveBonus = {
			Type = "MultiBonus",
			Bonuses = {
				{Type = "AllDamage", Value = 0.40},
				{Type = "PlayerRevive", PerZone = true}
			}
		},
		MaxLevelBonus = {
			Type = "ChainExplosion",
			ReviveInvincibility = 10, -- seconds
			Special = "ExplosionsChainReact"
		},
		ModelName = "PhoenixHomeworkPet",
		Size = 2.8,
		FloatHeight = 3
	},

	-- ========== MYTHIC PETS ==========
	HomeworkDragon = {
		Name = "HOMEWORK DRAGON",
		Rarity = "Mythic",
		Description = "Born from the ashes of a thousand destroyed assignments.",
		AutoAttackDamage = 5000,
		AutoAttackSpeed = 0.8,
		FireBreathDamage = 2000, -- AoE
		PassiveBonus = {
			Type = "MultiBonus",
			Bonuses = {
				{Type = "AllDamage", Value = 1.00}, -- +100%
				{Type = "DPGain", Value = 0.50},
				{Type = "CritChance", Value = 0.30},
				{Type = "IntimidateEnemies", Value = 0.15} -- -15% enemy HP
			}
		},
		MaxLevelBonus = {
			Type = "PermanentAura",
			StatMultiplier = 2, -- All stats doubled
			Special = "FireBreathBecomesAura"
		},
		ModelName = "HomeworkDragonPet",
		Size = 4,
		FloatHeight = 4,
		FusionRecipe = {
			RequiredPets = 5, -- 5 Legendary pets
			RequiredRarity = "Legendary",
			SuccessRate = 0.25 -- 25%
		}
	}
}

-- ==================== EGG DEFINITIONS ====================
PetConfig.Eggs = {
	ClassroomEgg = {
		Name = "Classroom Egg",
		Cost = 1000,
		Zone = "Classroom",
		Description = "A basic egg from the classroom.",
		PetPool = {"PaperAirplane", "PencilBuddy", "EraserBlob"},
		RarityWeights = {
			Common = 50,
			Uncommon = 30,
			Rare = 15,
			Epic = 4,
			Legendary = 0.9,
			Mythic = 0.1
		},
		ModelName = "ClassroomEggModel"
	},

	LibraryEgg = {
		Name = "Library Egg",
		Cost = 10000,
		Zone = "Library",
		Description = "An egg filled with knowledge.",
		PetPool = {"AngryCalculator", "FloatingTextbook"},
		RarityWeights = {
			Common = 40,
			Uncommon = 35,
			Rare = 20,
			Epic = 4,
			Legendary = 0.9,
			Mythic = 0.1
		},
		ModelName = "LibraryEggModel"
	},

	CafeteriaEgg = {
		Name = "Cafeteria Egg",
		Cost = 25000,
		Zone = "Cafeteria",
		Description = "Smells like mystery meat.",
		PetPool = {"CafeteriaSlime"},
		RarityWeights = {
			Common = 40,
			Uncommon = 35,
			Rare = 20,
			Epic = 4,
			Legendary = 0.9,
			Mythic = 0.1
		},
		ModelName = "CafeteriaEggModel"
	},

	ArtEgg = {
		Name = "Art Egg",
		Cost = 50000,
		Zone = "ArtRoom",
		Description = "Painted with creativity.",
		PetPool = {"RunawayScissors"},
		RarityWeights = {
			Common = 35,
			Uncommon = 35,
			Rare = 25,
			Epic = 4,
			Legendary = 0.9,
			Mythic = 0.1
		},
		ModelName = "ArtEggModel"
	},

	ScienceEgg = {
		Name = "Science Egg",
		Cost = 150000,
		Zone = "ScienceLab",
		Description = "Contains experimental lifeforms.",
		PetPool = {"HyperactiveHamster"},
		RarityWeights = {
			Common = 30,
			Uncommon = 35,
			Rare = 28,
			Epic = 6,
			Legendary = 0.9,
			Mythic = 0.1
		},
		ModelName = "ScienceEggModel"
	},

	TechEgg = {
		Name = "Tech Egg",
		Cost = 200000,
		Zone = "ComputerLab",
		Description = "Digitally encrypted egg.",
		PetPool = {"ComputerVirus", "MiniShredderBot"},
		RarityWeights = {
			Common = 30,
			Uncommon = 30,
			Rare = 30,
			Epic = 8,
			Legendary = 1.8,
			Mythic = 0.2
		},
		ModelName = "TechEggModel"
	},

	PrincipalsEgg = {
		Name = "Principal's Egg",
		Cost = 1000000,
		Zone = "PrincipalsOffice",
		Description = "An egg of authority and power.",
		PetPool = {"FlamingReportCard", "DetentionGhost"},
		RarityWeights = {
			Common = 20,
			Uncommon = 25,
			Rare = 30,
			Epic = 20,
			Legendary = 4,
			Mythic = 1
		},
		ModelName = "PrincipalsEggModel"
	},

	VoidEgg = {
		Name = "Void Egg",
		Cost = 50000000,
		Zone = "TheVoid",
		Description = "An egg from beyond reality.",
		PetPool = {"PhoenixHomework", "HomeworkDragon"},
		RarityWeights = {
			Common = 10,
			Uncommon = 15,
			Rare = 30,
			Epic = 30,
			Legendary = 12,
			Mythic = 3
		},
		ModelName = "VoidEggModel"
	}
}

-- ==================== PET LEVEL SCALING ====================
PetConfig.LevelScaling = {
	MaxLevel = 100,

	-- XP required per level (formula-based)
	GetXPForLevel = function(level)
		if level <= 10 then
			return 100 * level
		elseif level <= 25 then
			return 500 * level
		elseif level <= 50 then
			return 2000 * level
		elseif level <= 75 then
			return 10000 * level
		else
			return 50000 * level
		end
	end,

	-- Damage scaling per level
	DamagePerLevel = 0.05, -- +5% per level

	-- Stats at max level multiplier
	MaxLevelMultiplier = 2.5 -- 250% of base stats at level 100
}

-- ==================== PET FUSION SYSTEM ====================
PetConfig.Fusion = {
	-- Standard fusion (3 same pets)
	StandardFusion = {
		RequiredPets = 3,
		MustBeSamePet = true,
		MustBeSameRarity = true,
		SuccessRates = {
			Common = 0.80, -- 80% to get Uncommon
			Uncommon = 0.70, -- 70% to get Rare
			Rare = 0.60, -- 60% to get Epic
			Epic = 0.50, -- 50% to get Legendary
			Legendary = 0.25 -- 25% to get Mythic
		},
		FailureKeepsOnePet = true -- On failure, you keep 1 of the 3 pets
	},

	-- Special fusion (for Homework Dragon)
	SpecialFusions = {
		HomeworkDragon = {
			RequiredPets = 5,
			RequiredRarity = "Legendary",
			AnyLegendaries = true,
			SuccessRate = 0.25,
			FailureKeepsAllPets = false
		}
	},

	-- Fusion bonuses during events
	EventBonuses = {
		PetParadeWeek = 0.25 -- +25% success rate during Pet Parade
	}
}

-- ==================== PET EQUIP SLOTS ====================
PetConfig.EquipSlots = {
	DefaultSlots = 1,
	MaxSlots = 6,
	UnlockRequirements = {
		[2] = {Level = 25},
		[3] = {Level = 50},
		[4] = {Rebirth = 2},
		[5] = {Rebirth = 4},
		[6] = {Rebirth = 15}
	}
}

-- ==================== HELPER FUNCTIONS ====================

-- Get total damage bonus from equipped pets
function PetConfig.GetTotalPetDamageBonus(equippedPets)
	local totalBonus = 0
	for _, pet in ipairs(equippedPets) do
		if pet and pet.Rarity then
			local rarityData = PetConfig.Rarities[pet.Rarity]
			if rarityData then
				totalBonus = totalBonus + rarityData.DamageBonus
				-- Add level scaling
				if pet.Level then
					local levelBonus = (pet.Level - 1) * PetConfig.LevelScaling.DamagePerLevel
					totalBonus = totalBonus + levelBonus
				end
			end
		end
	end
	return totalBonus
end

-- Get pet data by ID
function PetConfig.GetPetData(petId)
	return PetConfig.Pets[petId]
end

-- Get egg data by ID
function PetConfig.GetEggData(eggId)
	return PetConfig.Eggs[eggId]
end

-- Get rarity by drop rate
function PetConfig.GetRarityFromRoll(roll, eggData)
	local weights = eggData.RarityWeights or PetConfig.Eggs.ClassroomEgg.RarityWeights
	local cumulative = 0

	for _, rarityName in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}) do
		cumulative = cumulative + weights[rarityName]
		if roll <= cumulative then
			return rarityName
		end
	end

	return "Common" -- Fallback
end

return PetConfig
