--[[
	QuestManager.lua

	Manages quest system with progression for Homework Destroyer

	Features:
	- Story-based quest chains
	- Side quests for exploration and rewards
	- Quest prerequisites and unlocking
	- Progress tracking
	- Multi-objective quests
	- Quest rewards (DP, items, unlocks)

	Author: Homework Destroyer Team
	Version: 1.0
]]

local QuestManager = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Quest Status
local QuestStatus = {
	LOCKED = "Locked",
	AVAILABLE = "Available",
	IN_PROGRESS = "InProgress",
	COMPLETED = "Completed",
	CLAIMED = "Claimed",
}

-- Quest Types
local QuestType = {
	STORY = "Story",
	SIDE = "Side",
	ZONE = "Zone",
	ACHIEVEMENT = "Achievement",
	TUTORIAL = "Tutorial",
}

-- Objective Types
local ObjectiveType = {
	DESTROY_HOMEWORK = "DestroyHomework",
	DESTROY_BOSS = "DestroyBoss",
	REACH_LEVEL = "ReachLevel",
	UNLOCK_ZONE = "UnlockZone",
	COLLECT_DP = "CollectDP",
	EQUIP_TOOL = "EquipTool",
	EQUIP_PET = "EquipPet",
	HATCH_EGGS = "HatchEggs",
	PURCHASE_UPGRADE = "PurchaseUpgrade",
	PERFORM_REBIRTH = "PerformRebirth",
	DEAL_DAMAGE = "DealDamage",
	EARN_DP = "EarnDP",
}

-- Quest Definitions
local QuestDatabase = {
	-- Tutorial Quests
	{
		ID = "TUTORIAL_1",
		Type = QuestType.TUTORIAL,
		Name = "First Destruction",
		Description = "Welcome to Homework Destroyer! Click on homework to destroy it and earn Destruction Points.",
		Objectives = {
			{Type = ObjectiveType.DESTROY_HOMEWORK, Target = 10, Description = "Destroy 10 homework"},
		},
		Prerequisites = {},
		Rewards = {DP = 1000},
		AutoAccept = true,
		OrderIndex = 1,
	},
	{
		ID = "TUTORIAL_2",
		Type = QuestType.TUTORIAL,
		Name = "Power Upgrade",
		Description = "Use your Destruction Points to purchase upgrades and become stronger!",
		Objectives = {
			{Type = ObjectiveType.PURCHASE_UPGRADE, Target = 1, Description = "Purchase any upgrade"},
		},
		Prerequisites = {"TUTORIAL_1"},
		Rewards = {DP = 2500},
		AutoAccept = true,
		OrderIndex = 2,
	},
	{
		ID = "TUTORIAL_3",
		Type = QuestType.TUTORIAL,
		Name = "Your First Pet",
		Description = "Hatch a pet egg to unlock your first companion! Pets help destroy homework automatically.",
		Objectives = {
			{Type = ObjectiveType.HATCH_EGGS, Target = 1, Description = "Hatch 1 pet egg"},
		},
		Prerequisites = {"TUTORIAL_2"},
		Rewards = {DP = 5000},
		AutoAccept = true,
		OrderIndex = 3,
	},

	-- Story Quests - Classroom Arc
	{
		ID = "STORY_CLASSROOM_1",
		Type = QuestType.STORY,
		Name = "The Assignment Avalanche",
		Description = "The classroom is overrun with homework! Destroy as much as you can to clear a path.",
		Objectives = {
			{Type = ObjectiveType.DESTROY_HOMEWORK, Target = 100, Description = "Destroy 100 homework in Classroom"},
		},
		Prerequisites = {"TUTORIAL_3"},
		Rewards = {DP = 10000},
		AutoAccept = true,
		OrderIndex = 10,
	},
	{
		ID = "STORY_CLASSROOM_2",
		Type = QuestType.STORY,
		Name = "Growing Stronger",
		Description = "You need more power to tackle the bigger assignments. Reach Level 5!",
		Objectives = {
			{Type = ObjectiveType.REACH_LEVEL, Target = 5, Description = "Reach Level 5"},
		},
		Prerequisites = {"STORY_CLASSROOM_1"},
		Rewards = {DP = 15000},
		AutoAccept = true,
		OrderIndex = 11,
	},
	{
		ID = "STORY_CLASSROOM_3",
		Type = QuestType.STORY,
		Name = "Boss Battle: Monday Morning Test",
		Description = "A powerful test has appeared! Defeat the Monday Morning Test boss.",
		Objectives = {
			{Type = ObjectiveType.DESTROY_BOSS, Target = 1, Description = "Defeat Monday Morning Test"},
		},
		Prerequisites = {"STORY_CLASSROOM_2"},
		Rewards = {DP = 25000},
		AutoAccept = true,
		OrderIndex = 12,
	},

	-- Library Zone Arc
	{
		ID = "STORY_LIBRARY_1",
		Type = QuestType.STORY,
		Name = "The Library Beckons",
		Description = "You've outgrown the classroom. Unlock the Library zone to continue your journey!",
		Objectives = {
			{Type = ObjectiveType.UNLOCK_ZONE, Target = 2, Description = "Unlock the Library zone"},
		},
		Prerequisites = {"STORY_CLASSROOM_3"},
		Rewards = {DP = 50000},
		AutoAccept = true,
		OrderIndex = 20,
	},
	{
		ID = "STORY_LIBRARY_2",
		Type = QuestType.STORY,
		Name = "Book Burning Bonanza",
		Description = "The library is filled with reading assignments. Show them no mercy!",
		Objectives = {
			{Type = ObjectiveType.DESTROY_HOMEWORK, Target = 500, Description = "Destroy 500 homework in Library"},
		},
		Prerequisites = {"STORY_LIBRARY_1"},
		Rewards = {DP = 75000},
		AutoAccept = true,
		OrderIndex = 21,
	},

	-- Rebirth Introduction
	{
		ID = "STORY_REBIRTH_1",
		Type = QuestType.STORY,
		Name = "The Path to Rebirth",
		Description = "You've reached the limits of normal progression. Reach Level 100 to unlock the power of Rebirth!",
		Objectives = {
			{Type = ObjectiveType.REACH_LEVEL, Target = 100, Description = "Reach Level 100"},
		},
		Prerequisites = {"STORY_LIBRARY_2"},
		Rewards = {DP = 500000},
		AutoAccept = true,
		OrderIndex = 30,
	},
	{
		ID = "STORY_REBIRTH_2",
		Type = QuestType.STORY,
		Name = "Cycle of Destruction",
		Description = "Perform your first Rebirth and begin the cycle anew with greater power!",
		Objectives = {
			{Type = ObjectiveType.PERFORM_REBIRTH, Target = 1, Description = "Perform 1 Rebirth"},
		},
		Prerequisites = {"STORY_REBIRTH_1"},
		Rewards = {DP = 100000},
		AutoAccept = true,
		OrderIndex = 31,
	},

	-- Side Quests
	{
		ID = "SIDE_COLLECTOR_1",
		Type = QuestType.SIDE,
		Name = "Pet Collector",
		Description = "Collect a variety of pets to increase your power!",
		Objectives = {
			{Type = ObjectiveType.HATCH_EGGS, Target = 5, Description = "Hatch 5 pet eggs"},
		},
		Prerequisites = {"TUTORIAL_3"},
		Rewards = {DP = 25000},
		AutoAccept = false,
		OrderIndex = 100,
	},
	{
		ID = "SIDE_ARSENAL_1",
		Type = QuestType.SIDE,
		Name = "Building Your Arsenal",
		Description = "Acquire new tools to diversify your destruction methods!",
		Objectives = {
			{Type = ObjectiveType.EQUIP_TOOL, Target = 3, Description = "Own 3 different tools"},
		},
		Prerequisites = {"STORY_CLASSROOM_1"},
		Rewards = {DP = 50000},
		AutoAccept = false,
		OrderIndex = 101,
	},
	{
		ID = "SIDE_DAMAGE_1",
		Type = QuestType.SIDE,
		Name = "Overwhelming Force",
		Description = "Deal massive damage to prove your destructive power!",
		Objectives = {
			{Type = ObjectiveType.DEAL_DAMAGE, Target = 1000000, Description = "Deal 1,000,000 total damage"},
		},
		Prerequisites = {"STORY_CLASSROOM_2"},
		Rewards = {DP = 100000},
		AutoAccept = false,
		OrderIndex = 102,
	},
	{
		ID = "SIDE_WEALTH_1",
		Type = QuestType.SIDE,
		Name = "Destruction Tycoon",
		Description = "Amass a fortune in Destruction Points!",
		Objectives = {
			{Type = ObjectiveType.EARN_DP, Target = 100000, Description = "Earn 100,000 DP (cumulative)"},
		},
		Prerequisites = {"STORY_CLASSROOM_1"},
		Rewards = {DP = 50000},
		AutoAccept = false,
		OrderIndex = 103,
	},
	{
		ID = "SIDE_BOSS_1",
		Type = QuestType.SIDE,
		Name = "Boss Hunter",
		Description = "Defeat multiple bosses to prove your strength!",
		Objectives = {
			{Type = ObjectiveType.DESTROY_BOSS, Target = 10, Description = "Defeat 10 bosses"},
		},
		Prerequisites = {"STORY_CLASSROOM_3"},
		Rewards = {DP = 150000},
		AutoAccept = false,
		OrderIndex = 104,
	},

	-- Zone-Specific Quests
	{
		ID = "ZONE_LIBRARY_1",
		Type = QuestType.ZONE,
		Name = "Library Master",
		Description = "Dominate the Library zone!",
		Objectives = {
			{Type = ObjectiveType.DESTROY_HOMEWORK, Target = 2000, Description = "Destroy 2,000 homework in Library"},
			{Type = ObjectiveType.DESTROY_BOSS, Target = 5, Description = "Defeat Overdue Library Book 5 times"},
		},
		Prerequisites = {"STORY_LIBRARY_1"},
		Rewards = {DP = 200000},
		AutoAccept = false,
		OrderIndex = 200,
	},
}

-- Active quest data per player
local PlayerQuests = {}

-- Utility Functions

--[[
	Check if a player meets quest prerequisites
]]
local function MeetsPrerequisites(playerQuestData, prerequisites)
	if #prerequisites == 0 then
		return true
	end

	for _, prereqID in ipairs(prerequisites) do
		local prereqQuest = playerQuestData[prereqID]
		if not prereqQuest or prereqQuest.Status ~= QuestStatus.CLAIMED then
			return false
		end
	end

	return true
end

--[[
	Get quest by ID from database
]]
local function GetQuestTemplate(questID)
	for _, quest in ipairs(QuestDatabase) do
		if quest.ID == questID then
			return quest
		end
	end
	return nil
end

--[[
	Initialize quest data structure for a player
]]
local function InitializeQuestData(questTemplate)
	local objectives = {}

	for i, obj in ipairs(questTemplate.Objectives) do
		objectives[i] = {
			Type = obj.Type,
			Target = obj.Target,
			Progress = 0,
			Description = obj.Description,
			Completed = false,
		}
	end

	return {
		ID = questTemplate.ID,
		Status = QuestStatus.LOCKED,
		Objectives = objectives,
		StartTime = 0,
		CompleteTime = 0,
	}
end

-- Public Functions

--[[
	Initialize quest system for a player
]]
function QuestManager:InitializePlayer(player, playerData)
	local userId = player.UserId

	-- Initialize quest data if not exists
	if not playerData.Quests then
		playerData.Quests = {
			Active = {},
			Completed = {},
			Progress = {},
		}
	end

	-- Create quest tracking structure
	local questData = {}

	for _, questTemplate in ipairs(QuestDatabase) do
		-- Check if quest exists in player data
		local existingQuest = playerData.Quests.Progress[questTemplate.ID]

		if existingQuest then
			-- Load existing quest
			questData[questTemplate.ID] = existingQuest
		else
			-- Create new quest entry
			local newQuest = InitializeQuestData(questTemplate)

			-- Check if prerequisites are met
			if MeetsPrerequisites(questData, questTemplate.Prerequisites) then
				if questTemplate.AutoAccept then
					newQuest.Status = QuestStatus.IN_PROGRESS
					newQuest.StartTime = os.time()
				else
					newQuest.Status = QuestStatus.AVAILABLE
				end
			else
				newQuest.Status = QuestStatus.LOCKED
			end

			questData[questTemplate.ID] = newQuest
			playerData.Quests.Progress[questTemplate.ID] = newQuest
		end
	end

	-- Store reference
	PlayerQuests[userId] = questData

	warn(string.format("[QuestManager] Initialized quests for %s", player.Name))
	return playerData
end

--[[
	Accept a quest
]]
function QuestManager:AcceptQuest(player, questID)
	local userId = player.UserId

	if not PlayerQuests[userId] then
		return false, "Quest data not initialized"
	end

	local quest = PlayerQuests[userId][questID]
	if not quest then
		return false, "Quest not found"
	end

	if quest.Status ~= QuestStatus.AVAILABLE then
		return false, "Quest not available"
	end

	-- Accept the quest
	quest.Status = QuestStatus.IN_PROGRESS
	quest.StartTime = os.time()

	warn(string.format("[QuestManager] %s accepted quest: %s", player.Name, questID))
	return true
end

--[[
	Update quest progress
]]
function QuestManager:UpdateQuestProgress(player, objectiveType, amount, extraData)
	local userId = player.UserId

	if not PlayerQuests[userId] then
		return
	end

	amount = amount or 1
	extraData = extraData or {}

	-- Iterate through all active quests
	for questID, quest in pairs(PlayerQuests[userId]) do
		if quest.Status == QuestStatus.IN_PROGRESS then
			local allObjectivesComplete = true

			-- Update each objective
			for _, objective in ipairs(quest.Objectives) do
				if objective.Type == objectiveType and not objective.Completed then
					objective.Progress = math.min(objective.Progress + amount, objective.Target)

					-- Check if objective is complete
					if objective.Progress >= objective.Target then
						objective.Completed = true
						warn(string.format("[QuestManager] %s completed objective: %s (%s)", player.Name, objective.Description, questID))
					end
				end

				if not objective.Completed then
					allObjectivesComplete = false
				end
			end

			-- Check if all objectives are complete
			if allObjectivesComplete and quest.Status == QuestStatus.IN_PROGRESS then
				quest.Status = QuestStatus.COMPLETED
				quest.CompleteTime = os.time()

				-- Notify player
				local remoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
				local questTemplate = GetQuestTemplate(questID)
				if questTemplate then
					remoteEvents.SafeFireClient("ShowNotification", player, "Quest", "Quest Complete!",
						questTemplate.Name .. " - Return to claim your reward!", 7)
				end

				warn(string.format("[QuestManager] %s completed quest: %s", player.Name, questID))
			end
		end
	end
end

--[[
	Claim quest reward
]]
function QuestManager:ClaimQuestReward(player, questID, DataManager)
	local userId = player.UserId

	if not PlayerQuests[userId] then
		return false, "Quest data not initialized"
	end

	local quest = PlayerQuests[userId][questID]
	if not quest then
		return false, "Quest not found"
	end

	if quest.Status ~= QuestStatus.COMPLETED then
		return false, "Quest not completed"
	end

	-- Get quest template for rewards
	local questTemplate = GetQuestTemplate(questID)
	if not questTemplate then
		return false, "Quest template not found"
	end

	-- Mark as claimed
	quest.Status = QuestStatus.CLAIMED

	-- Award rewards
	local rewards = questTemplate.Rewards
	if rewards.DP and rewards.DP > 0 then
		DataManager:IncrementPlayerData(player, "DestructionPoints", rewards.DP)
		DataManager:IncrementPlayerData(player, "LifetimeDP", rewards.DP)
	end

	-- Unlock next quests
	self:UnlockNextQuests(player)

	warn(string.format("[QuestManager] %s claimed reward for quest: %s", player.Name, questID))
	return true, rewards
end

--[[
	Unlock quests that now meet prerequisites
]]
function QuestManager:UnlockNextQuests(player)
	local userId = player.UserId

	if not PlayerQuests[userId] then
		return
	end

	for questID, quest in pairs(PlayerQuests[userId]) do
		if quest.Status == QuestStatus.LOCKED then
			local questTemplate = GetQuestTemplate(questID)

			if questTemplate and MeetsPrerequisites(PlayerQuests[userId], questTemplate.Prerequisites) then
				if questTemplate.AutoAccept then
					quest.Status = QuestStatus.IN_PROGRESS
					quest.StartTime = os.time()

					warn(string.format("[QuestManager] Auto-accepted quest for %s: %s", player.Name, questID))
				else
					quest.Status = QuestStatus.AVAILABLE

					-- Notify player
					local remoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
					remoteEvents.SafeFireClient("ShowNotification", player, "Quest", "New Quest Available!",
						questTemplate.Name, 5)

					warn(string.format("[QuestManager] Quest now available for %s: %s", player.Name, questID))
				end
			end
		end
	end
end

--[[
	Get all quests for a player (formatted for UI)
]]
function QuestManager:GetPlayerQuests(player)
	local userId = player.UserId

	if not PlayerQuests[userId] then
		return nil
	end

	local quests = {
		Tutorial = {},
		Story = {},
		Side = {},
		Zone = {},
	}

	for questID, quest in pairs(PlayerQuests[userId]) do
		local questTemplate = GetQuestTemplate(questID)

		if questTemplate then
			local questData = {
				ID = questID,
				Name = questTemplate.Name,
				Description = questTemplate.Description,
				Type = questTemplate.Type,
				Status = quest.Status,
				Objectives = quest.Objectives,
				Rewards = questTemplate.Rewards,
				OrderIndex = questTemplate.OrderIndex,
			}

			-- Categorize by type
			if questTemplate.Type == QuestType.TUTORIAL then
				table.insert(quests.Tutorial, questData)
			elseif questTemplate.Type == QuestType.STORY then
				table.insert(quests.Story, questData)
			elseif questTemplate.Type == QuestType.SIDE then
				table.insert(quests.Side, questData)
			elseif questTemplate.Type == QuestType.ZONE then
				table.insert(quests.Zone, questData)
			end
		end
	end

	-- Sort each category by OrderIndex
	for _, category in pairs(quests) do
		table.sort(category, function(a, b)
			return a.OrderIndex < b.OrderIndex
		end)
	end

	return quests
end

--[[
	Get active quests for a player
]]
function QuestManager:GetActiveQuests(player)
	local userId = player.UserId

	if not PlayerQuests[userId] then
		return {}
	end

	local activeQuests = {}

	for questID, quest in pairs(PlayerQuests[userId]) do
		if quest.Status == QuestStatus.IN_PROGRESS then
			local questTemplate = GetQuestTemplate(questID)
			if questTemplate then
				table.insert(activeQuests, {
					ID = questID,
					Name = questTemplate.Name,
					Description = questTemplate.Description,
					Objectives = quest.Objectives,
				})
			end
		end
	end

	return activeQuests
end

--[[
	Cleanup when player leaves
]]
function QuestManager:OnPlayerLeaving(player)
	local userId = player.UserId
	PlayerQuests[userId] = nil

	warn(string.format("[QuestManager] Cleaned up quests for %s", player.Name))
end

--[[
	Initialize the Quest Manager
]]
function QuestManager:Initialize()
	-- Get DataManager from global
	local DataManager = require(game:GetService("ServerScriptService").DataManager)

	-- Connect RemoteEvent handlers
	local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
	local remotes = RemoteEvents.Get()

	-- Handle quest acceptance
	if remotes.AcceptQuest then
		remotes.AcceptQuest.OnServerEvent:Connect(function(player, questID)
			local success, message = QuestManager:AcceptQuest(player, questID)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				local title = success and "Quest Accepted!" or "Accept Failed"
				remotes.ShowNotification:FireClient(player, notifType, title, message or "", 3)
			end
		end)
	end

	-- Handle quest completion/claiming
	if remotes.CompleteQuest then
		remotes.CompleteQuest.OnServerEvent:Connect(function(player, questID)
			local success, reward = QuestManager:ClaimQuestReward(player, questID, DataManager)

			-- Notify client
			if remotes.ShowNotification then
				local notifType = success and "Success" or "Error"
				local title = success and "Quest Reward Claimed!" or "Claim Failed"
				local message = success and string.format("Received %d DP!", reward.DP or 0) or tostring(reward)
				remotes.ShowNotification:FireClient(player, notifType, title, message, 3)
			end

			-- Sync data after claiming
			if success and remotes.DataUpdate then
				local data = DataManager:GetPlayerData(player)
				if data then
					remotes.DataUpdate:FireClient(player, "DestructionPoints", data.DestructionPoints)
				end
			end
		end)
	end

	warn(string.format("[QuestManager] Quest system initialized with %d quests", #QuestDatabase))
	return true
end

return QuestManager
