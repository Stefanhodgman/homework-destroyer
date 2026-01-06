--[[
	ToolsConfig.lua
	Complete tool/weapon configuration for Homework Destroyer

	Defines all 18 tools with stats, rarities, special effects, and progression
	Based on GameDesign.md tool specifications
]]

local ToolsConfig = {}

-- ========================================
-- TOOL RARITY SYSTEM
-- ========================================

ToolsConfig.Rarities = {
	Common = {
		Color = Color3.fromRGB(255, 255, 255), -- White
		DamageMultiplier = 1.0,
		CritBonus = 0,
		DropChance = 0.5, -- 50%
		DisplayName = "Common"
	},
	Uncommon = {
		Color = Color3.fromRGB(30, 255, 0), -- Green
		DamageMultiplier = 1.25,
		CritBonus = 0,
		DropChance = 0.3, -- 30%
		DisplayName = "Uncommon"
	},
	Rare = {
		Color = Color3.fromRGB(0, 112, 221), -- Blue
		DamageMultiplier = 1.5,
		CritBonus = 0.10, -- +10% crit chance
		DropChance = 0.15, -- 15%
		DisplayName = "Rare"
	},
	Epic = {
		Color = Color3.fromRGB(163, 53, 238), -- Purple
		DamageMultiplier = 2.0,
		CritBonus = 0.15, -- +15% crit chance
		DropChance = 0.04, -- 4%
		DisplayName = "Epic"
	},
	Legendary = {
		Color = Color3.fromRGB(255, 128, 0), -- Orange
		DamageMultiplier = 3.0,
		CritBonus = 0.25, -- +25% crit chance
		DropChance = 0.009, -- 0.9%
		DisplayName = "Legendary"
	},
	Mythic = {
		Color = Color3.fromRGB(255, 0, 0), -- Red
		DamageMultiplier = 6.0,
		CritBonus = 0.40, -- +40% crit chance
		DropChance = 0.001, -- 0.1%
		DisplayName = "Mythic"
	},
	SECRET = {
		Color = Color3.new(1, 1, 1), -- Rainbow (handled separately in UI)
		DamageMultiplier = 11.0,
		CritBonus = 0.50, -- +50% crit chance
		DropChance = 0, -- Not obtainable from drops
		DisplayName = "SECRET",
		IsRainbow = true
	}
}

-- ========================================
-- TOOL UPGRADE TOKEN COSTS
-- ========================================

ToolsConfig.UpgradeCosts = {
	-- Levels 1-5: 1 token each
	[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
	-- Levels 6-8: 2 tokens each
	[6] = 2, [7] = 2, [8] = 2,
	-- Levels 9-10: 5 tokens each
	[9] = 5, [10] = 5
}

ToolsConfig.MaxUpgradeLevel = 10
ToolsConfig.UpgradeDamageBonus = 0.15 -- +15% damage per upgrade
ToolsConfig.UpgradeSpeedBonus = 0.05 -- +5% speed per upgrade

-- ========================================
-- COMPLETE TOOL DEFINITIONS (18 TOOLS)
-- ========================================

ToolsConfig.Tools = {

	-- ==================== STARTER TOOLS (Zones 1-3) ====================

	PencilEraser = {
		ID = "PencilEraser",
		Name = "Pencil Eraser",
		Description = "Every destroyer starts somewhere.",
		Rarity = "Common",
		BaseDamage = 1,
		ClickSpeed = 1.0, -- Clicks per second
		Cost = 0, -- Free starting tool
		UnlockLevel = 0,
		UnlockZone = 1,
		SpecialEffect = nil,
		Category = "Starter",
		Icon = "rbxassetid://0", -- Placeholder
	},

	WoodenRuler = {
		ID = "WoodenRuler",
		Name = "Wooden Ruler",
		Description = "Measure twice, destroy once.",
		Rarity = "Common",
		BaseDamage = 3,
		ClickSpeed = 1.0,
		Cost = 500,
		UnlockLevel = 1,
		UnlockZone = 1,
		SpecialEffect = {
			Type = "TypeBonus",
			Target = "Paper",
			Bonus = 0.10 -- +10% damage to paper homework
		},
		Category = "Starter",
		Icon = "rbxassetid://0",
	},

	SafetyScissors = {
		ID = "SafetyScissors",
		Name = "Safety Scissors",
		Description = "Now you can run with them.",
		Rarity = "Uncommon",
		BaseDamage = 8,
		ClickSpeed = 1.1,
		Cost = 2500,
		UnlockLevel = 3,
		UnlockZone = 1,
		SpecialEffect = {
			Type = "InstantKill",
			Target = "Paper",
			Chance = 0.05 -- 5% chance to instantly destroy paper homework
		},
		Category = "Starter",
		Icon = "rbxassetid://0",
	},

	PermanentMarker = {
		ID = "PermanentMarker",
		Name = "Permanent Marker",
		Description = "This ink never comes off.",
		Rarity = "Uncommon",
		BaseDamage = 15,
		ClickSpeed = 1.0,
		Cost = 8000,
		UnlockLevel = 5,
		UnlockZone = 1,
		SpecialEffect = {
			Type = "Mark",
			Duration = 5, -- seconds
			Bonus = 0.20 -- Marked homework takes +20% damage for 5 seconds
		},
		Category = "Starter",
		Icon = "rbxassetid://0",
	},

	StapleRemover = {
		ID = "StapleRemover",
		Name = "Staple Remover",
		Description = "The jaws of destruction.",
		Rarity = "Rare",
		BaseDamage = 30,
		ClickSpeed = 1.2,
		Cost = 25000,
		UnlockLevel = 10,
		UnlockZone = 2,
		SpecialEffect = {
			Type = "MultiTarget",
			Target = "Stacked",
			Bonus = 0.25, -- +25% damage to stacked homework
			RemoveBuffs = true -- Removes buffs from boss homework
		},
		Category = "Starter",
		Icon = "rbxassetid://0",
	},

	-- ==================== MID-GAME TOOLS (Zones 4-6) ====================

	ElectricPencilSharpener = {
		ID = "ElectricPencilSharpener",
		Name = "Electric Pencil Sharpener",
		Description = "Sharpened for maximum destruction.",
		Rarity = "Rare",
		BaseDamage = 60,
		ClickSpeed = 1.3,
		Cost = 75000,
		UnlockLevel = 20,
		UnlockZone = 3,
		SpecialEffect = {
			Type = "DamageOverTime",
			DPS = 10, -- 10 damage per second
			Duration = 3 -- 3 seconds
		},
		Category = "MidGame",
		Icon = "rbxassetid://0",
	},

	Textbook = {
		ID = "Textbook",
		Name = "Textbook (Ironic Weapon)",
		Description = "Fight fire with fire.",
		Rarity = "Rare",
		BaseDamage = 100,
		ClickSpeed = 0.8,
		Cost = 200000,
		UnlockLevel = 25,
		UnlockZone = 2,
		SpecialEffect = {
			Type = "ZoneBonus",
			Zone = "Library",
			Bonus = 0.50 -- +50% damage in Library zone
		},
		Category = "MidGame",
		Icon = "rbxassetid://0",
	},

	LaserPointer = {
		ID = "LaserPointer",
		Name = "Laser Pointer",
		Description = "Precision destruction.",
		Rarity = "Epic",
		BaseDamage = 175,
		ClickSpeed = 1.5,
		Cost = 500000,
		UnlockLevel = 30,
		UnlockZone = 4,
		SpecialEffect = {
			Type = "Range",
			RangeMultiplier = 2.0, -- Can hit homework from double distance
			CritBonus = 0.15 -- Additional +15% crit chance
		},
		Category = "MidGame",
		Icon = "rbxassetid://0",
	},

	IndustrialShredder = {
		ID = "IndustrialShredder",
		Name = "Industrial Shredder",
		Description = "Feed it your problems.",
		Rarity = "Epic",
		BaseDamage = 300,
		ClickSpeed = 1.0,
		Cost = 1500000,
		UnlockLevel = 35,
		UnlockZone = 4,
		SpecialEffect = {
			Type = "MultiHit",
			Targets = 3, -- Hits 3 homework at once
			TypeBonus = {
				Target = "Paper",
				Bonus = 0.30 -- +30% damage to paper types
			}
		},
		Category = "MidGame",
		Icon = "rbxassetid://0",
	},

	DetentionHammer = {
		ID = "DetentionHammer",
		Name = "Detention Hammer",
		Description = "Order in the classroom!",
		Rarity = "Epic",
		BaseDamage = 500,
		ClickSpeed = 0.7,
		Cost = 5000000,
		UnlockLevel = 40,
		UnlockZone = 5,
		SpecialEffect = {
			Type = "BossEffect",
			StunDuration = 2, -- Stuns boss for 2 seconds
			BossDamageBonus = 0.40 -- +40% damage to bosses
		},
		Category = "MidGame",
		Icon = "rbxassetid://0",
	},

	-- ==================== LATE-GAME TOOLS (Zones 7-9) ====================

	AcidBeaker = {
		ID = "AcidBeaker",
		Name = "Acid Beaker",
		Description = "Safety goggles not included.",
		Rarity = "Legendary",
		BaseDamage = 900,
		ClickSpeed = 1.2,
		Cost = 20000000,
		UnlockLevel = 50,
		UnlockZone = 8,
		SpecialEffect = {
			Type = "Corrode",
			HPReduction = 0.20, -- Reduces enemy HP by 20% over duration
			Duration = 5, -- seconds
			SplashDamage = true -- Damages nearby homework
		},
		Category = "LateGame",
		Icon = "rbxassetid://0",
	},

	TeslaCoilPen = {
		ID = "TeslaCoilPen",
		Name = "Tesla Coil Pen",
		Description = "Shocking results guaranteed.",
		Rarity = "Legendary",
		BaseDamage = 1500,
		ClickSpeed = 1.4,
		Cost = 75000000,
		UnlockLevel = 60,
		UnlockZone = 8,
		SpecialEffect = {
			Type = "ChainLightning",
			Targets = 5, -- Hits 5 nearby homework
			DamagePercent = 0.50 -- Each chain does 50% damage
		},
		Category = "LateGame",
		Icon = "rbxassetid://0",
	},

	BlackHoleBackpack = {
		ID = "BlackHoleBackpack",
		Name = "Black Hole Backpack",
		Description = "It all disappears eventually.",
		Rarity = "Legendary",
		BaseDamage = 2800,
		ClickSpeed = 1.0,
		Cost = 250000000,
		UnlockLevel = 70,
		UnlockZone = 9,
		SpecialEffect = {
			Type = "Gravity",
			PullRange = 50, -- Pulls homework within 50 studs
			DPBonus = 0.25 -- +25% DP from destroyed homework
		},
		Category = "LateGame",
		Icon = "rbxassetid://0",
	},

	ReportCardShuriken = {
		ID = "ReportCardShuriken",
		Name = "Report Card Shuriken",
		Description = "Straight F's... for the homework.",
		Rarity = "Mythic",
		BaseDamage = 5000,
		ClickSpeed = 2.0,
		Cost = 1000000000,
		UnlockLevel = 80,
		UnlockZone = 9,
		SpecialEffect = {
			Type = "Bounce",
			BounceTargets = 7, -- Bounces between 7 targets
			CritDamageBonus = 0.30, -- +30% crit damage
			BleedPercent = 0.05 -- 5% HP bleed per second
		},
		Category = "LateGame",
		Icon = "rbxassetid://0",
	},

	NuclearEraser = {
		ID = "NuclearEraser",
		Name = "Nuclear Eraser",
		Description = "Total annihilation.",
		Rarity = "Mythic",
		BaseDamage = 12000,
		ClickSpeed = 0.5,
		Cost = 5000000000,
		UnlockLevel = 90,
		UnlockZone = 9,
		SpecialEffect = {
			Type = "Explosion",
			ExplosionDamage = 10000, -- Deals 10,000 damage in area
			ExplosionRange = 30, -- 30 studs radius
			InstantKillChance = 0.10 -- 10% chance to instantly destroy non-boss homework
		},
		Category = "LateGame",
		Icon = "rbxassetid://0",
	},

	-- ==================== ENDGAME/SECRET TOOLS ====================

	PrincipalsGoldenPen = {
		ID = "PrincipalsGoldenPen",
		Name = "Principal's Golden Pen",
		Description = "With great power comes great responsibility... to destroy homework.",
		Rarity = "Mythic",
		BaseDamage = 25000,
		ClickSpeed = 1.5,
		Cost = 25000000000,
		UnlockLevel = 95,
		UnlockZone = 9,
		RequiresBossDrop = {
			BossName = "THE PRINCIPAL",
			DropChance = 0.01 -- 1% drop chance
		},
		SpecialEffect = {
			Type = "DeathWarrant",
			DamageMultiplier = 3.0, -- Marked homework takes 3x damage from all sources
			Duration = 10 -- seconds
		},
		Category = "Endgame",
		Icon = "rbxassetid://0",
	},

	VoidEraser = {
		ID = "VoidEraser",
		Name = "Void Eraser",
		Description = "It was never assigned.",
		Rarity = "SECRET",
		BaseDamage = 50000,
		ClickSpeed = 1.8,
		Cost = 0, -- Not purchasable
		UnlockLevel = 100,
		UnlockZone = 10,
		RequiresQuest = {
			QuestName = "The Void Walker",
			Requirements = {
				RebirthLevel = 25,
				BossKills = {
					BossName = "HOMEWORK OVERLORD",
					Count = 10
				}
			}
		},
		SpecialEffect = {
			Type = "TrueDamage",
			DefenseBypass = 0.50, -- Bypasses 50% of homework defenses
			VoidBonus = 2.0 -- x2 damage in The Void zone
		},
		Category = "Secret",
		Icon = "rbxassetid://0",
	},

	TheDestroyersHand = {
		ID = "TheDestroyersHand",
		Name = "THE DESTROYER'S HAND",
		Description = "You ARE the Homework Destroyer.",
		Rarity = "SECRET",
		BaseDamage = 100000,
		ClickSpeed = 2.5,
		Cost = 100000000000,
		UnlockLevel = 100,
		UnlockZone = 10,
		RequiresCompletion = {
			PrestigeRank = 6, -- MAX Prestige Rank
			AllTools = true, -- Must own all other tools
		},
		SpecialEffect = {
			Type = "DestructionWave",
			WaveTrigger = 10, -- Every 10th click
			WaveDamage = 1000000, -- Deals 1,000,000 damage to all homework on screen
			AllStatsBonus = 1.0, -- +100% all stats
			Intimidate = 0.25 -- Reduces enemy HP by 25%
		},
		Category = "Ultimate",
		Icon = "rbxassetid://0",
	},
}

-- ========================================
-- TOOL SHOP CATEGORIES
-- ========================================

ToolsConfig.ShopCategories = {
	{
		Name = "Starter Tools",
		Description = "Basic tools for beginning your destruction journey",
		Filter = "Starter",
		UnlockLevel = 0
	},
	{
		Name = "Mid-Game Arsenal",
		Description = "Powerful weapons for serious destroyers",
		Filter = "MidGame",
		UnlockLevel = 20
	},
	{
		Name = "Late-Game Devastation",
		Description = "Legendary tools of mass destruction",
		Filter = "LateGame",
		UnlockLevel = 50
	},
	{
		Name = "Endgame Collection",
		Description = "The ultimate weapons of homework annihilation",
		Filter = "Endgame",
		UnlockLevel = 90
	},
	{
		Name = "Secret Weapons",
		Description = "Hidden tools of unimaginable power",
		Filter = "Secret",
		UnlockLevel = 100,
		RequiresPrestige = true
	}
}

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

-- Get tool data by ID
function ToolsConfig.GetTool(toolID)
	return ToolsConfig.Tools[toolID]
end

-- Get all tools in a category
function ToolsConfig.GetToolsByCategory(category)
	local tools = {}
	for id, tool in pairs(ToolsConfig.Tools) do
		if tool.Category == category then
			table.insert(tools, tool)
		end
	end
	return tools
end

-- Get tools available for purchase at a given level
function ToolsConfig.GetAvailableTools(playerLevel, playerZone, playerRebirthLevel, playerPrestigeRank)
	local available = {}

	for id, tool in pairs(ToolsConfig.Tools) do
		local canUnlock = true

		-- Check level requirement
		if tool.UnlockLevel > playerLevel then
			canUnlock = false
		end

		-- Check zone requirement
		if tool.UnlockZone > playerZone then
			canUnlock = false
		end

		-- Check boss drop requirement
		if tool.RequiresBossDrop then
			canUnlock = false -- Must be obtained through boss drops
		end

		-- Check quest requirement
		if tool.RequiresQuest then
			canUnlock = false -- Must be obtained through quest
		end

		-- Check completion requirement
		if tool.RequiresCompletion then
			if tool.RequiresCompletion.PrestigeRank then
				if playerPrestigeRank < tool.RequiresCompletion.PrestigeRank then
					canUnlock = false
				end
			end
		end

		if canUnlock then
			table.insert(available, tool)
		end
	end

	-- Sort by cost
	table.sort(available, function(a, b)
		return a.Cost < b.Cost
	end)

	return available
end

-- Check if player can purchase a tool
function ToolsConfig.CanPurchaseTool(toolID, playerData)
	local tool = ToolsConfig.GetTool(toolID)
	if not tool then
		return false, "Tool not found"
	end

	-- Check if already owned
	if playerData.Tools and playerData.Tools.Owned then
		for _, ownedID in ipairs(playerData.Tools.Owned) do
			if ownedID == toolID then
				return false, "Already owned"
			end
		end
	end

	-- Check level requirement
	if playerData.Level < tool.UnlockLevel then
		return false, string.format("Requires Level %d", tool.UnlockLevel)
	end

	-- Check DP cost
	if playerData.DestructionPoints < tool.Cost then
		return false, string.format("Need %s DP", ToolsConfig.FormatNumber(tool.Cost))
	end

	-- Check special requirements
	if tool.RequiresBossDrop then
		return false, "Must be obtained from boss drop"
	end

	if tool.RequiresQuest then
		return false, "Must be obtained from quest"
	end

	if tool.RequiresCompletion then
		if tool.RequiresCompletion.AllTools then
			-- Check if player owns all other tools
			local totalTools = 0
			for _ in pairs(ToolsConfig.Tools) do
				totalTools = totalTools + 1
			end

			local ownedCount = playerData.Tools and playerData.Tools.Owned and #playerData.Tools.Owned or 0
			if ownedCount < totalTools - 1 then
				return false, "Must own all other tools first"
			end
		end

		if tool.RequiresCompletion.PrestigeRank then
			if (playerData.PrestigeLevel or 0) < tool.RequiresCompletion.PrestigeRank then
				return false, string.format("Requires Prestige Rank %d", tool.RequiresCompletion.PrestigeRank)
			end
		end
	end

	return true, "Can purchase"
end

-- Calculate tool's effective damage with upgrades
function ToolsConfig.CalculateToolDamage(tool, upgradeLevel)
	local rarity = ToolsConfig.Rarities[tool.Rarity]
	local baseDamage = tool.BaseDamage

	-- Apply rarity multiplier
	baseDamage = baseDamage * rarity.DamageMultiplier

	-- Apply upgrade bonus
	upgradeLevel = upgradeLevel or 0
	local upgradeBonus = 1 + (upgradeLevel * ToolsConfig.UpgradeDamageBonus)
	baseDamage = baseDamage * upgradeBonus

	return math.floor(baseDamage)
end

-- Calculate tool's effective click speed with upgrades
function ToolsConfig.CalculateToolSpeed(tool, upgradeLevel)
	local baseSpeed = tool.ClickSpeed

	-- Apply upgrade bonus
	upgradeLevel = upgradeLevel or 0
	local upgradeBonus = 1 + (upgradeLevel * ToolsConfig.UpgradeSpeedBonus)
	baseSpeed = baseSpeed * upgradeBonus

	return baseSpeed
end

-- Get upgrade cost for a tool
function ToolsConfig.GetToolUpgradeCost(currentLevel)
	if currentLevel >= ToolsConfig.MaxUpgradeLevel then
		return nil -- Max level reached
	end

	return ToolsConfig.UpgradeCosts[currentLevel + 1] or 0
end

-- Format large numbers for display
function ToolsConfig.FormatNumber(number)
	if number >= 1000000000000 then
		return string.format("%.2fT", number / 1000000000000)
	elseif number >= 1000000000 then
		return string.format("%.2fB", number / 1000000000)
	elseif number >= 1000000 then
		return string.format("%.2fM", number / 1000000)
	elseif number >= 1000 then
		return string.format("%.2fK", number / 1000)
	else
		return tostring(number)
	end
end

-- Get total number of tools
function ToolsConfig.GetTotalToolCount()
	local count = 0
	for _ in pairs(ToolsConfig.Tools) do
		count = count + 1
	end
	return count
end

-- Get rarity color
function ToolsConfig.GetRarityColor(rarity)
	local rarityData = ToolsConfig.Rarities[rarity]
	return rarityData and rarityData.Color or Color3.new(1, 1, 1)
end

-- Get rarity display name
function ToolsConfig.GetRarityName(rarity)
	local rarityData = ToolsConfig.Rarities[rarity]
	return rarityData and rarityData.DisplayName or "Unknown"
end

return ToolsConfig
