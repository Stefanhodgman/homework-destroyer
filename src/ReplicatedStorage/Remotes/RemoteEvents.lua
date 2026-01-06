--[[
	RemoteEvents.lua
	Creates and manages all RemoteEvents and RemoteFunctions for client-server communication

	This module creates all necessary RemoteEvents when required from the server
	and provides a centralized way to access them from both client and server
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

-- Remote Events Container
local remotesFolder

-- Event Names and Descriptions
local REMOTE_CONFIGS = {
	-- Gameplay Events
	{
		Name = "ClickHomework",
		Type = "Event",
		Description = "Fired when player clicks on homework to destroy it",
		Parameters = "homeworkInstance, clickPosition, isCritical"
	},
	{
		Name = "PurchaseUpgrade",
		Type = "Event",
		Description = "Request to purchase an upgrade",
		Parameters = "upgradeCategory, upgradeName"
	},
	{
		Name = "PurchaseTool",
		Type = "Event",
		Description = "Request to purchase a tool/weapon",
		Parameters = "toolID"
	},
	{
		Name = "EquipTool",
		Type = "Event",
		Description = "Request to equip a tool",
		Parameters = "toolID, slotNumber (1 or 2 for dual-wield)"
	},
	{
		Name = "UpgradeTool",
		Type = "Event",
		Description = "Request to upgrade a tool using tokens",
		Parameters = "toolID"
	},

	-- Pet Events
	{
		Name = "HatchEgg",
		Type = "Event",
		Description = "Request to hatch a pet egg",
		Parameters = "eggType"
	},
	{
		Name = "EquipPet",
		Type = "Event",
		Description = "Request to equip/unequip a pet",
		Parameters = "petID, slotNumber (1-6)"
	},
	{
		Name = "FusePets",
		Type = "Event",
		Description = "Request to fuse 3 pets for higher rarity",
		Parameters = "petID1, petID2, petID3"
	},
	{
		Name = "DeletePet",
		Type = "Event",
		Description = "Request to delete a pet from inventory",
		Parameters = "petID"
	},

	-- Zone Events
	{
		Name = "UnlockZone",
		Type = "Event",
		Description = "Request to unlock a new zone",
		Parameters = "zoneID"
	},
	{
		Name = "TeleportToZone",
		Type = "Event",
		Description = "Request to teleport to an unlocked zone",
		Parameters = "zoneID"
	},

	-- Rebirth/Prestige Events
	{
		Name = "PerformRebirth",
		Type = "Event",
		Description = "Request to perform a rebirth",
		Parameters = "none"
	},
	{
		Name = "PurchaseRebirthUpgrade",
		Type = "Event",
		Description = "Purchase an upgrade from the Rebirth Shop",
		Parameters = "upgradeID"
	},
	{
		Name = "PerformPrestige",
		Type = "Event",
		Description = "Request to prestige (requires Rebirth 20)",
		Parameters = "none"
	},

	-- Data Sync Events
	{
		Name = "DataUpdate",
		Type = "Event",
		Description = "Server sends updated player data to client",
		Parameters = "dataType, newValue"
	},
	{
		Name = "FullDataSync",
		Type = "Event",
		Description = "Server sends complete player data to client",
		Parameters = "playerData"
	},
	{
		Name = "RequestDataSync",
		Type = "Event",
		Description = "Client requests full data sync from server",
		Parameters = "none"
	},

	-- Quest/Challenge Events
	{
		Name = "AcceptQuest",
		Type = "Event",
		Description = "Accept a quest",
		Parameters = "questID"
	},
	{
		Name = "CompleteQuest",
		Type = "Event",
		Description = "Turn in a completed quest",
		Parameters = "questID"
	},
	{
		Name = "ClaimDailyReward",
		Type = "Event",
		Description = "Claim daily login reward",
		Parameters = "none"
	},
	{
		Name = "ClaimChallengeReward",
		Type = "Event",
		Description = "Claim reward for completed daily challenge",
		Parameters = "challengeIndex"
	},

	-- Shop/Economy Events
	{
		Name = "PurchaseGamepass",
		Type = "Function",
		Description = "Handle gamepass purchase (returns success/failure)",
		Parameters = "gamepassID"
	},
	{
		Name = "ClaimFreeReward",
		Type = "Event",
		Description = "Claim a free reward (ads, social media, etc.)",
		Parameters = "rewardType"
	},

	-- Social/UI Events
	{
		Name = "UpdateSettings",
		Type = "Event",
		Description = "Update player settings",
		Parameters = "settingName, value"
	},
	{
		Name = "ReportBug",
		Type = "Event",
		Description = "Submit a bug report",
		Parameters = "bugDescription"
	},
	{
		Name = "RequestLeaderboardData",
		Type = "Function",
		Description = "Request leaderboard data (returns leaderboard table)",
		Parameters = "leaderboardType, pageNumber"
	},

	-- Boss Events
	{
		Name = "BossSpawned",
		Type = "Event",
		Description = "Server notifies clients that a boss has spawned",
		Parameters = "bossType, bossInstance, zoneID"
	},
	{
		Name = "BossDefeated",
		Type = "Event",
		Description = "Server notifies clients that a boss was defeated",
		Parameters = "bossType, topDamagers, rewards"
	},

	-- Particle/Effect Events (Client-side effects triggered by server)
	{
		Name = "PlayEffect",
		Type = "Event",
		Description = "Play a visual/sound effect at a position",
		Parameters = "effectType, position, extraData"
	},
	{
		Name = "ShowNotification",
		Type = "Event",
		Description = "Show a notification to the player",
		Parameters = "notificationType, title, message, duration"
	},
	{
		Name = "UnlockAchievement",
		Type = "Event",
		Description = "Notify client that achievement was unlocked",
		Parameters = "achievementID, rewardData"
	},

	-- Auto-Click Events
	{
		Name = "ToggleAutoClick",
		Type = "Event",
		Description = "Toggle auto-click on/off (requires Rebirth 1)",
		Parameters = "enabled (boolean)"
	},

	-- Tutorial Events
	{
		Name = "CompleteTutorialStep",
		Type = "Event",
		Description = "Mark a tutorial step as completed",
		Parameters = "stepNumber"
	},
	{
		Name = "SkipTutorial",
		Type = "Event",
		Description = "Skip the entire tutorial",
		Parameters = "none"
	},

	-- Sound Events
	{
		Name = "PlaySound",
		Type = "Event",
		Description = "Play a 2D sound on client (UI, ambient, etc.)",
		Parameters = "soundName (string), options (table: {Volume, Pitch})"
	},
	{
		Name = "PlaySoundAt",
		Type = "Event",
		Description = "Play a 3D sound at a world position",
		Parameters = "soundName (string), position (Vector3), volumeOverride (number)"
	},
}

-- Initialize all RemoteEvents and RemoteFunctions
function RemoteEvents.Initialize()
	-- Check if folder already exists
	remotesFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")

	if not remotesFolder then
		-- Create folder
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = "RemoteEvents"
		remotesFolder.Parent = ReplicatedStorage
	end

	-- Create each remote
	for _, config in ipairs(REMOTE_CONFIGS) do
		local existingRemote = remotesFolder:FindFirstChild(config.Name)

		if not existingRemote then
			local remote

			if config.Type == "Event" then
				remote = Instance.new("RemoteEvent")
			elseif config.Type == "Function" then
				remote = Instance.new("RemoteFunction")
			end

			if remote then
				remote.Name = config.Name
				remote.Parent = remotesFolder

				-- Add description as attribute for documentation
				remote:SetAttribute("Description", config.Description)
				remote:SetAttribute("Parameters", config.Parameters)

				print(string.format("[RemoteEvents] Created %s: %s", config.Type, config.Name))
			end
		end
	end

	print(string.format("[RemoteEvents] Initialized %d remotes", #REMOTE_CONFIGS))
end

-- Get a specific RemoteEvent
function RemoteEvents.GetEvent(eventName)
	if not remotesFolder then
		warn("[RemoteEvents] RemoteEvents not initialized! Call Initialize() first.")
		return nil
	end

	local remote = remotesFolder:FindFirstChild(eventName)

	if not remote then
		warn(string.format("[RemoteEvents] RemoteEvent '%s' not found!", eventName))
		return nil
	end

	if not remote:IsA("RemoteEvent") then
		warn(string.format("[RemoteEvents] '%s' is not a RemoteEvent!", eventName))
		return nil
	end

	return remote
end

-- Get a specific RemoteFunction
function RemoteEvents.GetFunction(functionName)
	if not remotesFolder then
		warn("[RemoteEvents] RemoteEvents not initialized! Call Initialize() first.")
		return nil
	end

	local remote = remotesFolder:FindFirstChild(functionName)

	if not remote then
		warn(string.format("[RemoteEvents] RemoteFunction '%s' not found!", functionName))
		return nil
	end

	if not remote:IsA("RemoteFunction") then
		warn(string.format("[RemoteEvents] '%s' is not a RemoteFunction!", functionName))
		return nil
	end

	return remote
end

-- Quick access functions for commonly used events
function RemoteEvents.Get()
	if not remotesFolder then
		RemoteEvents.Initialize()
	end

	return {
		-- Gameplay
		ClickHomework = RemoteEvents.GetEvent("ClickHomework"),
		PurchaseUpgrade = RemoteEvents.GetEvent("PurchaseUpgrade"),
		PurchaseTool = RemoteEvents.GetEvent("PurchaseTool"),
		EquipTool = RemoteEvents.GetEvent("EquipTool"),
		UpgradeTool = RemoteEvents.GetEvent("UpgradeTool"),

		-- Pets
		HatchEgg = RemoteEvents.GetEvent("HatchEgg"),
		EquipPet = RemoteEvents.GetEvent("EquipPet"),
		FusePets = RemoteEvents.GetEvent("FusePets"),
		DeletePet = RemoteEvents.GetEvent("DeletePet"),

		-- Zones
		UnlockZone = RemoteEvents.GetEvent("UnlockZone"),
		TeleportToZone = RemoteEvents.GetEvent("TeleportToZone"),

		-- Rebirth/Prestige
		PerformRebirth = RemoteEvents.GetEvent("PerformRebirth"),
		PurchaseRebirthUpgrade = RemoteEvents.GetEvent("PurchaseRebirthUpgrade"),
		PerformPrestige = RemoteEvents.GetEvent("PerformPrestige"),

		-- Data Sync
		DataUpdate = RemoteEvents.GetEvent("DataUpdate"),
		FullDataSync = RemoteEvents.GetEvent("FullDataSync"),
		RequestDataSync = RemoteEvents.GetEvent("RequestDataSync"),

		-- Quests/Challenges
		AcceptQuest = RemoteEvents.GetEvent("AcceptQuest"),
		CompleteQuest = RemoteEvents.GetEvent("CompleteQuest"),
		ClaimDailyReward = RemoteEvents.GetEvent("ClaimDailyReward"),
		ClaimChallengeReward = RemoteEvents.GetEvent("ClaimChallengeReward"),

		-- Shop
		PurchaseGamepass = RemoteEvents.GetFunction("PurchaseGamepass"),
		ClaimFreeReward = RemoteEvents.GetEvent("ClaimFreeReward"),

		-- Social/UI
		UpdateSettings = RemoteEvents.GetEvent("UpdateSettings"),
		ReportBug = RemoteEvents.GetEvent("ReportBug"),
		RequestLeaderboardData = RemoteEvents.GetFunction("RequestLeaderboardData"),

		-- Boss
		BossSpawned = RemoteEvents.GetEvent("BossSpawned"),
		BossDefeated = RemoteEvents.GetEvent("BossDefeated"),

		-- Effects
		PlayEffect = RemoteEvents.GetEvent("PlayEffect"),
		ShowNotification = RemoteEvents.GetEvent("ShowNotification"),
		UnlockAchievement = RemoteEvents.GetEvent("UnlockAchievement"),

		-- Auto-Click
		ToggleAutoClick = RemoteEvents.GetEvent("ToggleAutoClick"),

		-- Tutorial
		CompleteTutorialStep = RemoteEvents.GetEvent("CompleteTutorialStep"),
		SkipTutorial = RemoteEvents.GetEvent("SkipTutorial"),
	}
end

-- List all available remotes (useful for debugging)
function RemoteEvents.ListAll()
	print("=== AVAILABLE REMOTE EVENTS ===")
	for _, config in ipairs(REMOTE_CONFIGS) do
		print(string.format("%s (%s)", config.Name, config.Type))
		print(string.format("  Description: %s", config.Description))
		print(string.format("  Parameters: %s", config.Parameters))
		print("")
	end
end

-- Safety wrapper for firing to client (prevents errors from crashing server)
function RemoteEvents.SafeFireClient(eventName, player, ...)
	local event = RemoteEvents.GetEvent(eventName)
	if event then
		local args = {...}
		local success, err = pcall(function()
			event:FireClient(player, table.unpack(args))
		end)
		if not success then
			warn(string.format("[RemoteEvents] Error firing %s to %s: %s", eventName, player.Name, tostring(err)))
		end
	end
end

-- Safety wrapper for firing to all clients
function RemoteEvents.SafeFireAllClients(eventName, ...)
	local event = RemoteEvents.GetEvent(eventName)
	if event then
		local args = {...}
		local success, err = pcall(function()
			event:FireAllClients(table.unpack(args))
		end)
		if not success then
			warn(string.format("[RemoteEvents] Error firing %s to all clients: %s", eventName, tostring(err)))
		end
	end
end

-- Auto-initialize on require (server-side only)
if game:GetService("RunService"):IsServer() then
	RemoteEvents.Initialize()
end

return RemoteEvents
