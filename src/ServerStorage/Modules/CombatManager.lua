--[[
	CombatManager.lua
	Handles combat interactions between players and homework

	Responsibilities:
	- Process player clicks on homework
	- Calculate damage based on player stats
	- Update homework health
	- Handle homework destruction
	- Award rewards (DP, XP)
	- Manage critical hits
	- Display damage numbers and effects
--]]

local CombatManager = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Modules
local HomeworkConfig = require(script.Parent.HomeworkConfig)
local StatsCalculator = require(script.Parent.StatsCalculator)
local UpgradesConfig = require(script.Parent.UpgradesConfig)
local AchievementManager = require(script.Parent.AchievementManager)
local ServerSoundManager = require(script.Parent.ServerSoundManager)

-- Remote events
local RemoteEventsModule = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvents"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local HomeworkClickedEvent = Remotes:FindFirstChild("HomeworkClicked")
local DamageDealtEvent = Remotes:FindFirstChild("DamageDealt")

-- Constants
local CLICK_COOLDOWN = 0.2 -- Base click cooldown in seconds
local CRITICAL_HIT_BASE_CHANCE = 0.05 -- 5% base crit chance
local CRITICAL_HIT_MULTIPLIER = 2.0 -- Base 2x damage on crit

-- Player click tracking (to prevent spam)
local playerClickCooldowns = {}

--[[
	Initialize CombatManager
	Sets up event connections
--]]
function CombatManager.Initialize()
	-- Create remote events if they don't exist
	if not HomeworkClickedEvent then
		HomeworkClickedEvent = Instance.new("RemoteEvent")
		HomeworkClickedEvent.Name = "HomeworkClicked"
		HomeworkClickedEvent.Parent = Remotes
	end

	if not DamageDealtEvent then
		DamageDealtEvent = Instance.new("RemoteEvent")
		DamageDealtEvent.Name = "DamageDealt"
		DamageDealtEvent.Parent = Remotes
	end

	-- Initialize ServerSoundManager
	ServerSoundManager:Initialize()

	print("CombatManager: Initialized")
end

--[[
	Handle player click on homework
	@param player - Player who clicked
	@param homeworkModel - The homework model clicked
	@param homeworkSpawner - The spawner managing this homework
	@param playerData - Player's current data
--]]
function CombatManager.HandleClick(player, homeworkModel, homeworkSpawner, playerData)
	-- Validate input
	if not player or not homeworkModel or not homeworkSpawner or not playerData then
		return false
	end

	-- Check click cooldown
	if not CombatManager.CanClick(player) then
		return false
	end

	-- Get homework instance
	local homeworkInstance = homeworkSpawner:GetHomeworkInstance(homeworkModel)
	if not homeworkInstance then
		return false
	end

	-- Check if homework is already destroyed
	if homeworkInstance.CurrentHealth <= 0 then
		return false
	end

	-- Calculate damage
	local damageInfo = CombatManager.CalculateDamage(player, playerData, homeworkInstance)

	-- Apply damage
	local destroyed = CombatManager.ApplyDamage(homeworkInstance, damageInfo.totalDamage, homeworkSpawner)

	-- Show damage feedback
	CombatManager.ShowDamageNumber(player, homeworkModel, damageInfo)

	-- Play hit sound
	local toolData = CombatManager.GetEquippedTool(playerData)
	local position = homeworkModel.PrimaryPart and homeworkModel.PrimaryPart.Position or Vector3.new(0, 0, 0)
	ServerSoundManager:PlayHitSound(player, position, toolData.ID, toolData.Category, damageInfo.isCritical)

	-- If homework destroyed, award rewards and play destroy sound
	if destroyed then
		CombatManager.AwardRewards(player, playerData, homeworkInstance)
		ServerSoundManager:PlayDestroySound(position)
	end

	-- Update click cooldown
	CombatManager.SetClickCooldown(player, playerData)

	return true
end

--[[
	Check if player can click (cooldown check)
--]]
function CombatManager.CanClick(player)
	local cooldownData = playerClickCooldowns[player.UserId]
	if not cooldownData then
		return true
	end

	local currentTime = tick()
	return currentTime >= cooldownData.nextClickTime
end

--[[
	Set click cooldown for player
--]]
function CombatManager.SetClickCooldown(player, playerData)
	local cooldown = StatsCalculator.CalculateClickCooldown(playerData)

	playerClickCooldowns[player.UserId] = {
		nextClickTime = tick() + cooldown
	}
end

--[[
	Calculate damage from player click
	Returns damage info including base damage, multipliers, critical hit
--]]
function CombatManager.CalculateDamage(player, playerData, homeworkInstance)
	-- Get equipped tool data
	local toolData = CombatManager.GetEquippedTool(playerData)

	-- Get equipped pets data
	local petData = CombatManager.GetEquippedPets(playerData)

	-- Check for critical hit
	local isCritical = CombatManager.RollCriticalHit(playerData, toolData)

	-- Calculate final damage
	local targetType = homeworkInstance.Data.Type
	local finalDamage = StatsCalculator.CalculateFinalDamage(
		playerData,
		toolData,
		petData,
		isCritical,
		targetType
	)

	return {
		baseDamage = StatsCalculator.CalculateBaseDamage(playerData, toolData),
		totalDamage = finalDamage,
		isCritical = isCritical,
		targetType = targetType
	}
end

--[[
	Roll for critical hit
--]]
function CombatManager.RollCriticalHit(playerData, toolData)
	local critChance = StatsCalculator.GetCriticalChance(playerData, toolData)
	local roll = math.random()

	return roll <= critChance
end

--[[
	Apply damage to homework
	Returns true if homework was destroyed
--]]
function CombatManager.ApplyDamage(homeworkInstance, damage, homeworkSpawner)
	-- Reduce health
	homeworkInstance.CurrentHealth = math.max(0, homeworkInstance.CurrentHealth - damage)

	-- Update health bar
	homeworkSpawner:UpdateHomeworkHealth(homeworkInstance)

	-- Check if destroyed
	if homeworkInstance.CurrentHealth <= 0 then
		CombatManager.DestroyHomework(homeworkInstance, homeworkSpawner)
		return true
	end

	return false
end

--[[
	Destroy homework with visual effects
--]]
function CombatManager.DestroyHomework(homeworkInstance, homeworkSpawner)
	local model = homeworkInstance.Model
	if not model then
		return
	end

	-- Play destruction effect
	CombatManager.PlayDestructionEffect(model, homeworkInstance.IsBoss)

	-- Remove homework from spawner
	homeworkSpawner:RemoveHomework(model)
end

--[[
	Play destruction visual effect
--]]
function CombatManager.PlayDestructionEffect(model, isBoss)
	if not model or not model.PrimaryPart then
		return
	end

	local position = model.PrimaryPart.Position

	-- Send effect event to all clients in range
	local PlayEffectEvent = RemoteEventsModule.GetEvent("PlayEffect")
	if PlayEffectEvent then
		-- Fire to all players within render distance
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character and player.Character.PrimaryPart then
				local distance = (player.Character.PrimaryPart.Position - position).Magnitude
				if distance < 500 then -- Within render distance
					PlayEffectEvent:FireClient(player, {
						Type = "Destruction",
						Position = position,
						ExtraData = {
							IsBoss = isBoss
						}
					})
				end
			end
		end
	end

	-- Play sound (server-side for all players to hear)
	local destroySound = Instance.new("Sound")
	destroySound.SoundId = "rbxassetid://12222216" -- Explosion sound
	destroySound.Volume = isBoss and 1 or 0.5
	destroySound.Parent = workspace
	destroySound.PlayOnRemove = false

	-- Position sound at destruction location
	local soundPart = Instance.new("Part")
	soundPart.Transparency = 1
	soundPart.CanCollide = false
	soundPart.Anchored = true
	soundPart.Size = Vector3.new(1, 1, 1)
	soundPart.Position = position
	soundPart.Parent = workspace
	destroySound.Parent = soundPart

	destroySound:Play()
	game:GetService("Debris"):AddItem(soundPart, 3)
end

--[[
	Show damage number to player
--]]
function CombatManager.ShowDamageNumber(player, homeworkModel, damageInfo)
	if not DamageDealtEvent then
		return
	end

	-- Send damage info to client for display
	DamageDealtEvent:FireClient(player, {
		Position = homeworkModel.PrimaryPart and homeworkModel.PrimaryPart.Position or Vector3.new(0, 0, 0),
		Damage = damageInfo.totalDamage,
		IsCritical = damageInfo.isCritical,
		HomeworkType = damageInfo.targetType
	})
end

--[[
	Award rewards to player for destroying homework
--]]
function CombatManager.AwardRewards(player, playerData, homeworkInstance)
	local homeworkData = homeworkInstance.Data

	-- Calculate DP reward
	local baseDP = homeworkData.Reward
	local dpEarned = StatsCalculator.CalculateDPEarned(baseDP, playerData)

	-- Calculate XP reward (simplified - you may want to adjust this)
	local xpEarned = homeworkData.IsBoss and 1000 or 50

	-- Award DP
	playerData.DestructionPoints = playerData.DestructionPoints + dpEarned

	-- Award XP
	playerData.Experience = playerData.Experience + xpEarned

	-- Update lifetime stats
	playerData.LifetimeStats.TotalDestructionPoints = playerData.LifetimeStats.TotalDestructionPoints + dpEarned
	playerData.LifetimeStats.TotalHomeworkDestroyed = playerData.LifetimeStats.TotalHomeworkDestroyed + 1

	if homeworkInstance.IsBoss then
		playerData.LifetimeStats.TotalBossesDefeated = playerData.LifetimeStats.TotalBossesDefeated + 1
	end

	-- Check for level up
	CombatManager.CheckLevelUp(player, playerData)

	-- Check for achievements
	CombatManager.CheckAchievements(player, playerData)

	print(string.format("%s destroyed %s and earned %d DP, %d XP",
		player.Name,
		homeworkData.Name,
		dpEarned,
		xpEarned))

	return dpEarned, xpEarned
end

--[[
	Check if player should level up
--]]
function CombatManager.CheckLevelUp(player, playerData)
	local xpRequired = StatsCalculator.GetXPRequiredForLevel(playerData.Level)

	while playerData.Experience >= xpRequired and playerData.Level < 100 do
		-- Level up
		playerData.Level = playerData.Level + 1
		playerData.Experience = playerData.Experience - xpRequired

		print(string.format("%s leveled up to Level %d!", player.Name, playerData.Level))

		-- Play level up sound
		ServerSoundManager:PlayLevelUpSound(player)

		-- Award level rewards
		CombatManager.AwardLevelRewards(player, playerData, playerData.Level)

		-- Fire level up event to client
		local showNotificationEvent = RemoteEventsModule.GetEvent("ShowNotification")
		if showNotificationEvent then
			showNotificationEvent:FireClient(player, "LevelUp", "Level Up!", string.format("You reached Level %d!", playerData.Level), 5)
		end

		xpRequired = StatsCalculator.GetXPRequiredForLevel(playerData.Level)
	end
end

--[[
	Award rewards for reaching a level milestone
--]]
function CombatManager.AwardLevelRewards(player, playerData, level)
	local levelRewards = UpgradesConfig.LevelRewards
	if not levelRewards then
		return
	end

	-- Every 5 levels: Award a pet egg
	if level % 5 == 0 and levelRewards.Every5Levels then
		local eggType = levelRewards.Every5Levels.Value
		if playerData.Eggs and playerData.Eggs[eggType] then
			playerData.Eggs[eggType] = playerData.Eggs[eggType] + 1
			print(string.format("%s earned 1 %s for reaching Level %d", player.Name, eggType, level))
		end
	end

	-- Every 10 levels: Award tool upgrade token
	if level % 10 == 0 and levelRewards.Every10Levels then
		local tokenAmount = levelRewards.Every10Levels.Value
		playerData.ToolUpgradeTokens = playerData.ToolUpgradeTokens + tokenAmount
		print(string.format("%s earned %d Tool Upgrade Token(s) for reaching Level %d", player.Name, tokenAmount, level))
	end

	-- Specific level milestones
	if levelRewards.SpecificLevels and levelRewards.SpecificLevels[level] then
		local reward = levelRewards.SpecificLevels[level]

		if reward.Type == "PetSlot" then
			-- Unlock a new pet slot
			if playerData.Pets and playerData.Pets.MaxSlots then
				playerData.Pets.MaxSlots = math.max(playerData.Pets.MaxSlots, reward.Value)
				print(string.format("%s unlocked Pet Slot %d at Level %d", player.Name, reward.Value, level))
			end
		elseif reward.Type == "ToolDualWield" then
			-- Unlock dual-wield capability
			print(string.format("%s unlocked Tool Dual-Wield at Level %d", player.Name, level))
			-- The dual-wield is tracked by level, no specific flag needed
		elseif reward.Type == "RebirthUnlock" then
			-- Unlock rebirth capability
			print(string.format("%s unlocked Rebirth at Level %d", player.Name, level))
			-- Rebirth is unlocked at level 100, checked by level requirement
		end
	end
end

--[[
	Check for achievement progress
--]]
function CombatManager.CheckAchievements(player, playerData)
	local stats = playerData.LifetimeStats
	local achievements = playerData.Achievements

	-- Destruction count achievements
	if stats.TotalHomeworkDestroyed >= 10 and not achievements.FirstSteps then
		CombatManager.UnlockAchievement(player, playerData, "FirstSteps")
	end

	if stats.TotalHomeworkDestroyed >= 100 and not achievements.PaperShredder then
		CombatManager.UnlockAchievement(player, playerData, "PaperShredder")
	end

	if stats.TotalHomeworkDestroyed >= 1000 and not achievements.AssignmentAssassin then
		CombatManager.UnlockAchievement(player, playerData, "AssignmentAssassin")
	end

	if stats.TotalHomeworkDestroyed >= 10000 and not achievements.HomeworkHater then
		CombatManager.UnlockAchievement(player, playerData, "HomeworkHater")
	end

	-- Boss achievements
	if stats.TotalBossesDefeated >= 1 and not achievements.BossFighter then
		CombatManager.UnlockAchievement(player, playerData, "BossFighter")
	end

	if stats.TotalBossesDefeated >= 10 and not achievements.BossHunter then
		CombatManager.UnlockAchievement(player, playerData, "BossHunter")
	end

	-- DP achievements
	if playerData.DestructionPoints >= 1000000 and not achievements.Millionaire then
		CombatManager.UnlockAchievement(player, playerData, "Millionaire")
	end

	if playerData.DestructionPoints >= 1000000000 and not achievements.Billionaire then
		CombatManager.UnlockAchievement(player, playerData, "Billionaire")
	end
end

--[[
	Unlock an achievement for player
--]]
function CombatManager.UnlockAchievement(player, playerData, achievementID)
	-- Use AchievementManager to handle the full unlock process
	-- This will mark it as unlocked, award rewards, and notify the client
	AchievementManager:UnlockAchievement(player, achievementID)

	print(string.format("%s unlocked achievement: %s", player.Name, achievementID))
end

--[[
	Get equipped tool data
	Looks up the player's equipped tool from ToolsConfig
--]]
function CombatManager.GetEquippedTool(playerData)
	-- Get the equipped tool ID
	local equippedToolID = playerData.Tools and playerData.Tools.Equipped
	if not equippedToolID then
		-- Return default starter tool if nothing equipped
		return {
			BaseDamage = 1,
			Rarity = "Common",
			UpgradeLevel = 0,
			CritChance = 0,
			SpecialBonus = {}
		}
	end

	-- Load ToolsConfig to get tool data
	local ToolsConfig = require(script.Parent.ToolsConfig)
	local toolData = ToolsConfig.GetTool(equippedToolID)

	if not toolData then
		-- Fallback if tool not found
		return {
			BaseDamage = 1,
			Rarity = "Common",
			UpgradeLevel = 0,
			CritChance = 0,
			SpecialBonus = {}
		}
	end

	-- Get the upgrade level for this tool
	local upgradeLevel = 0
	if playerData.Tools.UpgradeLevels and playerData.Tools.UpgradeLevels[equippedToolID] then
		upgradeLevel = playerData.Tools.UpgradeLevels[equippedToolID]
	end

	-- Return tool data with upgrade level
	return {
		ID = toolData.ID,
		Name = toolData.Name,
		BaseDamage = toolData.BaseDamage,
		Rarity = toolData.Rarity,
		ClickSpeed = toolData.ClickSpeed,
		UpgradeLevel = upgradeLevel,
		SpecialEffect = toolData.SpecialEffect or {},
		Category = toolData.Category
	}
end

--[[
	Get equipped pets data
	Returns array of equipped pet instances with their stats
--]]
function CombatManager.GetEquippedPets(playerData)
	-- Check if player has pets system
	if not playerData.Pets or not playerData.Pets.Equipped or not playerData.Pets.Owned then
		return {}
	end

	local equippedPetIDs = playerData.Pets.Equipped
	if #equippedPetIDs == 0 then
		return {}
	end

	-- Load PetConfig to get base pet data
	local PetConfig = require(script.Parent.PetConfig)
	local equippedPets = {}

	-- Build a lookup table of owned pets for faster access
	-- Support both ID and UniqueId fields for flexibility
	local ownedPetsMap = {}
	for _, petInstance in ipairs(playerData.Pets.Owned) do
		local petKey = petInstance.UniqueId or petInstance.ID
		if petKey then
			ownedPetsMap[petKey] = petInstance
		end
	end

	-- For each equipped pet ID, find the pet instance and include its stats
	for _, petID in ipairs(equippedPetIDs) do
		local petInstance = ownedPetsMap[petID]
		if petInstance then
			-- Get the base pet type identifier (PetId from PetManager or PetType from other systems)
			local basePetId = petInstance.PetId or petInstance.PetType or petID

			-- Get base pet config data
			local basePetData = PetConfig.GetPetData(basePetId)

			if basePetData then
				-- Combine instance data with base data
				table.insert(equippedPets, {
					ID = petInstance.UniqueId or petInstance.ID,
					PetId = basePetId,
					Name = basePetData.Name,
					Rarity = petInstance.Rarity,
					Level = petInstance.Level or 1,
					XP = petInstance.XP or 0,
					AutoAttackDamage = basePetData.AutoAttackDamage,
					AutoAttackSpeed = basePetData.AutoAttackSpeed,
					PassiveBonus = basePetData.PassiveBonus,
					MaxLevelBonus = basePetData.MaxLevelBonus,
				})
			end
		end
	end

	return equippedPets
end

--[[
	Calculate damage per second for a player
	Includes manual clicks and auto-clicks
--]]
function CombatManager.CalculateDPS(playerData)
	local toolData = CombatManager.GetEquippedTool(playerData)
	local petData = CombatManager.GetEquippedPets(playerData)

	-- Manual click DPS
	local clickCooldown = StatsCalculator.CalculateClickCooldown(playerData)
	local clicksPerSecond = 1 / clickCooldown
	local damagePerClick = StatsCalculator.CalculateFinalDamage(playerData, toolData, petData, false, nil)
	local manualDPS = clicksPerSecond * damagePerClick

	-- Auto-click DPS
	local autoClickRate = StatsCalculator.CalculateAutoClickRate(playerData)
	local autoClickDamage = StatsCalculator.CalculateAutoClickDamage(playerData, toolData, petData)
	local autoDPS = autoClickRate * autoClickDamage

	-- Pet DPS (placeholder)
	local petDPS = 0

	return {
		Manual = math.floor(manualDPS),
		Auto = math.floor(autoDPS),
		Pet = math.floor(petDPS),
		Total = math.floor(manualDPS + autoDPS + petDPS)
	}
end

--[[
	Handle auto-click damage
	Called periodically by server for players with auto-click unlocked
--]]
function CombatManager.ProcessAutoClick(player, playerData, nearestHomework, homeworkSpawner)
	if not nearestHomework or not homeworkSpawner then
		return false
	end

	-- Check if auto-click is unlocked
	local autoClickRate = StatsCalculator.CalculateAutoClickRate(playerData)
	if autoClickRate <= 0 then
		return false
	end

	-- Get homework instance
	local homeworkInstance = homeworkSpawner:GetHomeworkInstance(nearestHomework)
	if not homeworkInstance or homeworkInstance.CurrentHealth <= 0 then
		return false
	end

	-- Calculate auto-click damage
	local toolData = CombatManager.GetEquippedTool(playerData)
	local petData = CombatManager.GetEquippedPets(playerData)
	local damage = StatsCalculator.CalculateAutoClickDamage(playerData, toolData, petData)

	-- Apply damage
	local destroyed = CombatManager.ApplyDamage(homeworkInstance, damage, homeworkSpawner)

	-- If homework destroyed, award rewards
	if destroyed then
		CombatManager.AwardRewards(player, playerData, homeworkInstance)
	end

	return true
end

--[[
	Clean up player data on leave
--]]
function CombatManager.CleanupPlayer(player)
	playerClickCooldowns[player.UserId] = nil
end

return CombatManager
