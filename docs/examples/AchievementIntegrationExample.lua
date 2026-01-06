--[[
	AchievementIntegrationExample.lua

	Example integration of Achievement System into Homework Destroyer

	This example shows how to properly connect the AchievementManager
	to various game systems for automatic tracking and unlocking.

	Place this code in your existing game managers or create a new
	AchievementIntegration module.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Module references
local AchievementManager = require(ServerStorage.Modules.AchievementManager)
local DataManager = require(ServerScriptService.DataManager)

-- Remote events
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local ClickHomeworkEvent = RemoteEventsFolder:WaitForChild("ClickHomework")

local AchievementIntegration = {}

-- ============================================================
-- INITIALIZATION
-- ============================================================

function AchievementIntegration:Initialize()
	warn("[AchievementIntegration] Initializing achievement tracking...")

	-- Initialize the achievement system
	AchievementManager:Initialize()

	-- Connect to game events
	self:ConnectGameplayEvents()
	self:ConnectBossEvents()
	self:ConnectProgressionEvents()
	self:ConnectCollectionEvents()
	self:ConnectSpecialEvents()

	warn("[AchievementIntegration] Achievement tracking initialized")
end

-- ============================================================
-- GAMEPLAY EVENT CONNECTIONS
-- ============================================================

function AchievementIntegration:ConnectGameplayEvents()
	-- Example: Connect to homework destruction
	-- In your actual implementation, this would be in your CombatManager or similar

	ClickHomeworkEvent.OnServerEvent:Connect(function(player, homeworkInstance, clickPosition, isCritical)
		-- Process the click (your existing logic)
		-- ...

		-- After successful destruction, track for achievements
		local data = DataManager:GetPlayerData(player)
		if data then
			-- Track the destruction timestamp for Speed Demon
			AchievementManager:OnHomeworkDestroyed(player, os.time())

			-- Track critical hit for Critical King
			AchievementManager:OnCriticalHit(player, isCritical)

			-- Check destruction achievements periodically (not every click to avoid spam)
			if data.LifetimeStats.TotalHomeworkDestroyed % 10 == 0 then
				AchievementManager:CheckDestructionAchievements(player)
			end

			-- Check special achievements
			if data.LifetimeStats.TotalHomeworkDestroyed % 100 == 0 then
				AchievementManager:CheckSpecialAchievements(player)
			end
		end
	end)
end

-- ============================================================
-- BOSS EVENT CONNECTIONS
-- ============================================================

function AchievementIntegration:ConnectBossEvents()
	-- Example boss fight tracking
	-- This assumes you have a BossManager module

	local BossManager = require(ServerStorage.Modules.BossManager)

	-- Track when boss fight starts
	BossManager.BossSpawned:Connect(function(boss, zoneID)
		-- Notify all nearby players
		for _, player in ipairs(Players:GetPlayers()) do
			local data = DataManager:GetPlayerData(player)
			if data and data.CurrentZone == zoneID then
				local isVoidZone = (zoneID == 10)
				AchievementManager:OnBossFightStart(player, boss.Name, isVoidZone)
			end
		end
	end)

	-- Track when player takes damage from boss
	BossManager.PlayerDamagedByBoss:Connect(function(player, boss, damage)
		AchievementManager:OnPlayerDamagedByBoss(player)
	end)

	-- Track when boss is defeated
	BossManager.BossDefeated:Connect(function(boss, topDamagers)
		for _, player in ipairs(topDamagers) do
			-- Check if it was The Principal
			if boss.Name == "THE PRINCIPAL" then
				AchievementManager:OnPrincipalDefeated(player)
			end

			-- Mark boss fight as complete
			AchievementManager:OnBossFightEnd(player, true)

			-- Check boss achievements
			AchievementManager:CheckBossAchievements(player)
		end
	end)
end

-- ============================================================
-- PROGRESSION EVENT CONNECTIONS
-- ============================================================

function AchievementIntegration:ConnectProgressionEvents()
	-- Zone unlocking
	RemoteEventsFolder.UnlockZone.OnServerEvent:Connect(function(player, zoneID)
		-- Your existing zone unlock logic
		-- ...

		-- After successful unlock, check achievements
		AchievementManager:CheckZoneAchievements(player)
	end)

	-- Rebirth
	RemoteEventsFolder.PerformRebirth.OnServerEvent:Connect(function(player)
		-- Your existing rebirth logic
		-- ...

		-- After rebirth, check achievements
		AchievementManager:CheckRebirthAchievements(player)
	end)

	-- Level up
	-- Assuming you have a level-up event
	local function OnPlayerLevelUp(player, newLevel)
		-- Check for any level-based achievements
		AchievementManager:CheckAllAchievements(player)
	end
end

-- ============================================================
-- COLLECTION EVENT CONNECTIONS
-- ============================================================

function AchievementIntegration:ConnectCollectionEvents()
	-- Tool purchases
	RemoteEventsFolder.PurchaseTool.OnServerEvent:Connect(function(player, toolID)
		-- Your existing tool purchase logic
		-- ...

		-- After purchase, check collection achievements
		AchievementManager:CheckCollectionAchievements(player)
	end)

	-- Pet hatching
	RemoteEventsFolder.HatchEgg.OnServerEvent:Connect(function(player, eggType)
		-- Your existing egg hatching logic
		-- ...

		-- After hatching, check collection achievements
		AchievementManager:CheckCollectionAchievements(player)
	end)

	-- Pet fusion
	RemoteEventsFolder.FusePets.OnServerEvent:Connect(function(player, petID1, petID2, petID3)
		-- Your existing fusion logic
		-- ...

		-- After fusion (if successful and creates legendary/mythic), check achievements
		AchievementManager:CheckCollectionAchievements(player)
	end)
end

-- ============================================================
-- SPECIAL EVENT CONNECTIONS
-- ============================================================

function AchievementIntegration:ConnectSpecialEvents()
	-- Track damage for "The One" achievement (exactly 1M damage)
	-- This would be in your combat system
	local function OnDamageDealt(player, damage)
		AchievementManager:OnDamageDealt(player, damage)
	end

	-- Easter egg discovery
	-- Place a hidden part in the Classroom with a ClickDetector
	local easterEggPart = workspace:FindFirstChild("Classroom") and
	                      workspace.Classroom:FindFirstChild("HiddenMessage")

	if easterEggPart and easterEggPart:FindFirstChild("ClickDetector") then
		easterEggPart.ClickDetector.MouseClick:Connect(function(playerWhoClicked)
			if playerWhoClicked and playerWhoClicked:IsA("Player") then
				AchievementManager:TriggerEasterEgg(playerWhoClicked)
			end
		end)
	end

	-- Check for DP milestones after DP is awarded
	-- This would be called in your DP awarding function
	local function OnDPAwarded(player, amount)
		local data = DataManager:GetPlayerData(player)
		if data then
			-- Check for Millionaire/Billionaire achievements
			if data.DestructionPoints >= 1000000 then
				AchievementManager:CheckAchievement(player, "Millionaire")
			end
			if data.DestructionPoints >= 1000000000 then
				AchievementManager:CheckAchievement(player, "Billionaire")
			end
		end
	end
end

-- ============================================================
-- PERIODIC CHECKS
-- ============================================================

function AchievementIntegration:StartPeriodicChecks()
	-- Check all achievements periodically for players
	-- This catches any achievements that might have been missed
	spawn(function()
		while true do
			wait(300) -- Every 5 minutes

			for _, player in ipairs(Players:GetPlayers()) do
				-- Do a full achievement check
				local newUnlocks = AchievementManager:CheckAllAchievements(player)
				if newUnlocks > 0 then
					warn("[AchievementIntegration] Periodic check found " .. newUnlocks .. " new achievements for " .. player.Name)
				end
			end
		end
	end)
end

-- ============================================================
-- PLAYER JOIN/LEAVE
-- ============================================================

function AchievementIntegration:OnPlayerJoined(player)
	-- Initial achievement check when player joins
	-- Give them a moment for data to load
	wait(2)

	-- Check all achievements
	local newUnlocks = AchievementManager:CheckAllAchievements(player)
	if newUnlocks > 0 then
		warn("[AchievementIntegration] Found " .. newUnlocks .. " unlockable achievements for " .. player.Name)
	end
end

-- ============================================================
-- ADMIN COMMANDS (for testing)
-- ============================================================

function AchievementIntegration:SetupAdminCommands()
	-- Example admin command system
	-- Only works for specific users (replace with your admin system)

	local ADMINS = {
		[123456789] = true, -- Replace with actual admin UserIds
	}

	Players.PlayerAdded:Connect(function(player)
		if not ADMINS[player.UserId] then
			return
		end

		-- Create admin commands
		player.Chatted:Connect(function(message)
			local args = string.split(message, " ")

			-- Command: /unlockachievement [achievementID]
			if args[1] == "/unlockachievement" and args[2] then
				local achievementID = args[2]
				local success = AchievementManager:UnlockAchievement(player, achievementID)
				if success then
					print("[Admin] Unlocked achievement: " .. achievementID)
				else
					warn("[Admin] Failed to unlock achievement: " .. achievementID)
				end
			end

			-- Command: /checkachievements
			if args[1] == "/checkachievements" then
				local newUnlocks = AchievementManager:CheckAllAchievements(player)
				print("[Admin] Found " .. newUnlocks .. " unlockable achievements")
			end

			-- Command: /achievementstats
			if args[1] == "/achievementstats" then
				local stats = AchievementManager:GetPlayerStats(player)
				print("[Admin] Achievement Stats:")
				print("  Total: " .. stats.Total)
				print("  Unlocked: " .. stats.Unlocked)
				print("  Locked: " .. stats.Locked)
				print("  Completion: " .. string.format("%.1f%%", stats.CompletionRate))
			end

			-- Command: /simulatecritstreak [count]
			if args[1] == "/simulatecritstreak" and args[2] then
				local count = tonumber(args[2]) or 50
				for i = 1, count do
					AchievementManager:OnCriticalHit(player, true)
				end
				print("[Admin] Simulated " .. count .. " critical hits")
			end

			-- Command: /simulatespeed
			if args[1] == "/simulatespeed" then
				-- Simulate 100 homework destructions in 1 second
				local timestamp = os.time()
				for i = 1, 100 do
					AchievementManager:OnHomeworkDestroyed(player, timestamp)
				end
				print("[Admin] Simulated Speed Demon scenario")
			end
		end)
	end)
end

-- ============================================================
-- EXAMPLE: Manual Achievement Triggers
-- ============================================================

-- Example: Award achievement when player completes specific task
function AchievementIntegration:OnSpecialQuestCompleted(player, questID)
	if questID == "TheVoidWalkerQuest" then
		-- Manually unlock an achievement
		AchievementManager:UnlockAchievement(player, "VoidWalker")
	end
end

-- Example: Check progress toward an achievement
function AchievementIntegration:GetPlayerAchievementProgress(player, achievementID)
	local progress = AchievementManager:GetAchievementProgress(player, achievementID)
	local percentage = math.floor(progress * 100)
	return percentage -- Returns 0-100
end

-- Example: Award bonus for achievement milestones
function AchievementIntegration:CheckMilestones(player)
	local stats = AchievementManager:GetPlayerStats(player)

	-- Award bonus for every 10 achievements
	if stats.Unlocked % 10 == 0 and stats.Unlocked > 0 then
		local bonusDP = stats.Unlocked * 1000
		DataManager:IncrementPlayerData(player, "DestructionPoints", bonusDP)
		warn("[AchievementIntegration] Milestone bonus! Awarded " .. bonusDP .. " DP for " .. stats.Unlocked .. " achievements")
	end
end

-- ============================================================
-- AUTO-INITIALIZE
-- ============================================================

-- Connect player events
Players.PlayerAdded:Connect(function(player)
	AchievementIntegration:OnPlayerJoined(player)
end)

-- Initialize on require
AchievementIntegration:Initialize()
AchievementIntegration:StartPeriodicChecks()
AchievementIntegration:SetupAdminCommands()

return AchievementIntegration
