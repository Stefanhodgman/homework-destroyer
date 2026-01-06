--[[
	ChallengesUI.lua

	Client-side UI for viewing and tracking challenges and quests

	Features:
	- Daily/Weekly challenge display
	- Quest tracking UI
	- Progress bars and completion indicators
	- Reward claiming interface
	- Challenge/quest filtering and sorting
	- Streak display

	Author: Homework Destroyer Team
	Version: 1.0
]]

local ChallengesUI = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
local remotes = RemoteEvents.Get()

-- UI State
local currentTab = "Daily" -- Daily, Weekly, Quests
local challengeData = {
	Daily = {},
	Weekly = {},
	Quests = {},
}
local streakCount = 0

-- UI References
local screenGui
local mainFrame
local tabButtons = {}
local contentFrames = {}

-- Constants
local COLORS = {
	Background = Color3.fromRGB(30, 30, 40),
	Secondary = Color3.fromRGB(45, 45, 55),
	Accent = Color3.fromRGB(100, 200, 255),
	Success = Color3.fromRGB(100, 255, 150),
	Warning = Color3.fromRGB(255, 200, 100),
	Text = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(200, 200, 200),
	Easy = Color3.fromRGB(150, 255, 150),
	Medium = Color3.fromRGB(255, 200, 100),
	Hard = Color3.fromRGB(255, 100, 100),
}

-- UI Creation Functions

--[[
	Create the main UI structure
]]
local function CreateMainUI()
	-- Create ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ChallengesUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Main Frame (hidden by default)
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 700, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
	mainFrame.BackgroundColor3 = COLORS.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.Parent = screenGui

	-- Corner rounding
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = COLORS.Secondary
	header.BorderSizePixel = 0
	header.Parent = mainFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(0.6, 0, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Challenges & Quests"
	title.TextColor3 = COLORS.Text
	title.TextSize = 28
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Streak Display
	local streakLabel = Instance.new("TextLabel")
	streakLabel.Name = "StreakLabel"
	streakLabel.Size = UDim2.new(0.3, -40, 0.6, 0)
	streakLabel.Position = UDim2.new(0.6, 0, 0.2, 0)
	streakLabel.BackgroundColor3 = COLORS.Accent
	streakLabel.Text = "Streak: 0 days"
	streakLabel.TextColor3 = COLORS.Text
	streakLabel.TextSize = 16
	streakLabel.Font = Enum.Font.GothamBold
	streakLabel.Parent = header

	local streakCorner = Instance.new("UICorner")
	streakCorner.CornerRadius = UDim.new(0, 8)
	streakCorner.Parent = streakLabel

	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 10)
	closeButton.BackgroundColor3 = COLORS.Warning
	closeButton.Text = "X"
	closeButton.TextColor3 = COLORS.Text
	closeButton.TextSize = 24
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		ChallengesUI:Hide()
	end)

	-- Tab Buttons Container
	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "TabContainer"
	tabContainer.Size = UDim2.new(1, -40, 0, 50)
	tabContainer.Position = UDim2.new(0, 20, 0, 70)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = mainFrame

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabLayout.Padding = UDim.new(0, 10)
	tabLayout.Parent = tabContainer

	-- Create Tabs
	local tabs = {"Daily", "Weekly", "Quests"}
	for _, tabName in ipairs(tabs) do
		local tabButton = Instance.new("TextButton")
		tabButton.Name = tabName .. "Tab"
		tabButton.Size = UDim2.new(0, 150, 1, 0)
		tabButton.BackgroundColor3 = COLORS.Secondary
		tabButton.Text = tabName
		tabButton.TextColor3 = COLORS.TextSecondary
		tabButton.TextSize = 20
		tabButton.Font = Enum.Font.GothamBold
		tabButton.Parent = tabContainer

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 8)
		tabCorner.Parent = tabButton

		tabButtons[tabName] = tabButton

		tabButton.MouseButton1Click:Connect(function()
			ChallengesUI:SwitchTab(tabName)
		end)
	end

	-- Content Area
	local contentArea = Instance.new("ScrollingFrame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, -40, 1, -140)
	contentArea.Position = UDim2.new(0, 20, 0, 130)
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.ScrollBarThickness = 8
	contentArea.ScrollBarImageColor3 = COLORS.Accent
	contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentArea.Parent = mainFrame

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 10)
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	contentLayout.Parent = contentArea

	-- Auto-resize canvas
	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		contentArea.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
	end)

	contentFrames.ContentArea = contentArea

	screenGui.Parent = playerGui

	return screenGui
end

--[[
	Create a challenge card
]]
local function CreateChallengeCard(challengeInfo, isWeekly, index)
	local cardFrame = Instance.new("Frame")
	cardFrame.Name = "ChallengeCard_" .. index
	cardFrame.Size = UDim2.new(1, -20, 0, 100)
	cardFrame.BackgroundColor3 = COLORS.Secondary
	cardFrame.BorderSizePixel = 0

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = cardFrame

	-- Difficulty badge (for daily challenges)
	if not isWeekly and challengeInfo.Difficulty then
		local difficultyColor = COLORS.Easy
		if challengeInfo.Difficulty == "Medium" then
			difficultyColor = COLORS.Medium
		elseif challengeInfo.Difficulty == "Hard" then
			difficultyColor = COLORS.Hard
		end

		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, 80, 0, 25)
		badge.Position = UDim2.new(0, 10, 0, 10)
		badge.BackgroundColor3 = difficultyColor
		badge.BorderSizePixel = 0
		badge.Parent = cardFrame

		local badgeCorner = Instance.new("UICorner")
		badgeCorner.CornerRadius = UDim.new(0, 6)
		badgeCorner.Parent = badge

		local badgeText = Instance.new("TextLabel")
		badgeText.Size = UDim2.new(1, 0, 1, 0)
		badgeText.BackgroundTransparency = 1
		badgeText.Text = challengeInfo.Difficulty
		badgeText.TextColor3 = COLORS.Text
		badgeText.TextSize = 14
		badgeText.Font = Enum.Font.GothamBold
		badgeText.Parent = badge
	end

	-- Challenge Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(0.6, -20, 0, 25)
	nameLabel.Position = UDim2.new(0, isWeekly and 10 or 100, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = challengeInfo.Name
	nameLabel.TextColor3 = COLORS.Text
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = cardFrame

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "Description"
	descLabel.Size = UDim2.new(0.6, -20, 0, 20)
	descLabel.Position = UDim2.new(0, 10, 0, 40)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = challengeInfo.Description
	descLabel.TextColor3 = COLORS.TextSecondary
	descLabel.TextSize = 14
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = cardFrame

	-- Progress Bar Background
	local progressBG = Instance.new("Frame")
	progressBG.Name = "ProgressBG"
	progressBG.Size = UDim2.new(0.6, -20, 0, 20)
	progressBG.Position = UDim2.new(0, 10, 0, 70)
	progressBG.BackgroundColor3 = COLORS.Background
	progressBG.BorderSizePixel = 0
	progressBG.Parent = cardFrame

	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 6)
	progressCorner.Parent = progressBG

	-- Progress Bar Fill
	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	local progressPercent = math.min(challengeInfo.Progress / challengeInfo.Target, 1)
	progressFill.Size = UDim2.new(progressPercent, 0, 1, 0)
	progressFill.BackgroundColor3 = challengeInfo.Completed and COLORS.Success or COLORS.Accent
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBG

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = progressFill

	-- Progress Text
	local progressText = Instance.new("TextLabel")
	progressText.Size = UDim2.new(1, 0, 1, 0)
	progressText.BackgroundTransparency = 1
	progressText.Text = string.format("%d / %d", challengeInfo.Progress, challengeInfo.Target)
	progressText.TextColor3 = COLORS.Text
	progressText.TextSize = 14
	progressText.Font = Enum.Font.GothamBold
	progressText.ZIndex = 2
	progressText.Parent = progressBG

	-- Reward Display
	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Name = "Reward"
	rewardLabel.Size = UDim2.new(0.35, -20, 0, 30)
	rewardLabel.Position = UDim2.new(0.65, 0, 0, 20)
	rewardLabel.BackgroundColor3 = COLORS.Background
	rewardLabel.Text = "Reward: " .. (challengeInfo.Reward.DP or 0) .. " DP"
	rewardLabel.TextColor3 = COLORS.Success
	rewardLabel.TextSize = 16
	rewardLabel.Font = Enum.Font.GothamBold
	rewardLabel.Parent = cardFrame

	local rewardCorner = Instance.new("UICorner")
	rewardCorner.CornerRadius = UDim.new(0, 6)
	rewardCorner.Parent = rewardLabel

	-- Claim Button (if completed)
	if challengeInfo.Completed and not challengeInfo.Claimed then
		local claimButton = Instance.new("TextButton")
		claimButton.Name = "ClaimButton"
		claimButton.Size = UDim2.new(0.35, -20, 0, 30)
		claimButton.Position = UDim2.new(0.65, 0, 0, 60)
		claimButton.BackgroundColor3 = COLORS.Success
		claimButton.Text = "CLAIM REWARD"
		claimButton.TextColor3 = COLORS.Text
		claimButton.TextSize = 16
		claimButton.Font = Enum.Font.GothamBold
		claimButton.Parent = cardFrame

		local claimCorner = Instance.new("UICorner")
		claimCorner.CornerRadius = UDim.new(0, 6)
		claimCorner.Parent = claimButton

		claimButton.MouseButton1Click:Connect(function()
			remotes.ClaimChallengeReward:FireServer(isWeekly, index)
			claimButton.Visible = false
		end)
	elseif challengeInfo.Claimed then
		local claimedLabel = Instance.new("TextLabel")
		claimedLabel.Size = UDim2.new(0.35, -20, 0, 30)
		claimedLabel.Position = UDim2.new(0.65, 0, 0, 60)
		claimedLabel.BackgroundColor3 = COLORS.TextSecondary
		claimedLabel.Text = "CLAIMED"
		claimedLabel.TextColor3 = COLORS.Text
		claimedLabel.TextSize = 16
		claimedLabel.Font = Enum.Font.GothamBold
		claimedLabel.Parent = cardFrame

		local claimedCorner = Instance.new("UICorner")
		claimedCorner.CornerRadius = UDim.new(0, 6)
		claimedCorner.Parent = claimedLabel
	end

	return cardFrame
end

--[[
	Create a quest card
]]
local function CreateQuestCard(questInfo, index)
	local cardFrame = Instance.new("Frame")
	cardFrame.Name = "QuestCard_" .. index
	cardFrame.Size = UDim2.new(1, -20, 0, 120)
	cardFrame.BackgroundColor3 = COLORS.Secondary
	cardFrame.BorderSizePixel = 0

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = cardFrame

	-- Quest Type Badge
	local typeColor = COLORS.Accent
	if questInfo.Type == "Tutorial" then
		typeColor = COLORS.Success
	elseif questInfo.Type == "Story" then
		typeColor = COLORS.Warning
	end

	local typeBadge = Instance.new("Frame")
	typeBadge.Size = UDim2.new(0, 80, 0, 25)
	typeBadge.Position = UDim2.new(0, 10, 0, 10)
	typeBadge.BackgroundColor3 = typeColor
	typeBadge.BorderSizePixel = 0
	typeBadge.Parent = cardFrame

	local typeCorner = Instance.new("UICorner")
	typeCorner.CornerRadius = UDim.new(0, 6)
	typeCorner.Parent = typeBadge

	local typeText = Instance.new("TextLabel")
	typeText.Size = UDim2.new(1, 0, 1, 0)
	typeText.BackgroundTransparency = 1
	typeText.Text = questInfo.Type
	typeText.TextColor3 = COLORS.Text
	typeText.TextSize = 14
	typeText.Font = Enum.Font.GothamBold
	typeText.Parent = typeBadge

	-- Quest Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.6, -100, 0, 25)
	nameLabel.Position = UDim2.new(0, 100, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = questInfo.Name
	nameLabel.TextColor3 = COLORS.Text
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = cardFrame

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -20, 0, 30)
	descLabel.Position = UDim2.new(0, 10, 0, 40)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = questInfo.Description
	descLabel.TextColor3 = COLORS.TextSecondary
	descLabel.TextSize = 14
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = cardFrame

	-- Objectives
	local objectivesText = ""
	for i, objective in ipairs(questInfo.Objectives) do
		local checkmark = objective.Completed and "[✓]" or "[ ]"
		objectivesText = objectivesText .. string.format("%s %s (%d/%d)\n", checkmark, objective.Description, objective.Progress, objective.Target)
	end

	local objectivesLabel = Instance.new("TextLabel")
	objectivesLabel.Size = UDim2.new(1, -20, 0, 40)
	objectivesLabel.Position = UDim2.new(0, 10, 0, 75)
	objectivesLabel.BackgroundTransparency = 1
	objectivesLabel.Text = objectivesText
	objectivesLabel.TextColor3 = COLORS.TextSecondary
	objectivesLabel.TextSize = 12
	objectivesLabel.Font = Enum.Font.Gotham
	objectivesLabel.TextXAlignment = Enum.TextXAlignment.Left
	objectivesLabel.TextYAlignment = Enum.TextYAlignment.Top
	objectivesLabel.TextWrapped = true
	objectivesLabel.Parent = cardFrame

	-- Expand card height if needed
	local objectiveCount = #questInfo.Objectives
	if objectiveCount > 2 then
		cardFrame.Size = UDim2.new(1, -20, 0, 120 + (objectiveCount - 2) * 20)
	end

	-- Status Button
	if questInfo.Status == "Available" then
		local acceptButton = Instance.new("TextButton")
		acceptButton.Size = UDim2.new(0, 120, 0, 35)
		acceptButton.Position = UDim2.new(1, -130, 0, 10)
		acceptButton.BackgroundColor3 = COLORS.Accent
		acceptButton.Text = "ACCEPT"
		acceptButton.TextColor3 = COLORS.Text
		acceptButton.TextSize = 16
		acceptButton.Font = Enum.Font.GothamBold
		acceptButton.Parent = cardFrame

		local acceptCorner = Instance.new("UICorner")
		acceptCorner.CornerRadius = UDim.new(0, 6)
		acceptCorner.Parent = acceptButton

		acceptButton.MouseButton1Click:Connect(function()
			remotes.AcceptQuest:FireServer(questInfo.ID)
		end)
	elseif questInfo.Status == "Completed" then
		local claimButton = Instance.new("TextButton")
		claimButton.Size = UDim2.new(0, 120, 0, 35)
		claimButton.Position = UDim2.new(1, -130, 0, 10)
		claimButton.BackgroundColor3 = COLORS.Success
		claimButton.Text = "CLAIM"
		claimButton.TextColor3 = COLORS.Text
		claimButton.TextSize = 16
		claimButton.Font = Enum.Font.GothamBold
		claimButton.Parent = cardFrame

		local claimCorner = Instance.new("UICorner")
		claimCorner.CornerRadius = UDim.new(0, 6)
		claimCorner.Parent = claimButton

		claimButton.MouseButton1Click:Connect(function()
			remotes.CompleteQuest:FireServer(questInfo.ID)
		end)
	end

	return cardFrame
end

-- Public Functions

--[[
	Initialize the UI
]]
function ChallengesUI:Initialize()
	CreateMainUI()

	-- Set default tab
	self:SwitchTab("Daily")

	-- Request initial data from server
	remotes.RequestDataSync:FireServer()

	warn("[ChallengesUI] UI initialized")
end

--[[
	Show the challenges UI
]]
function ChallengesUI:Show()
	if mainFrame then
		mainFrame.Visible = true

		-- Request updated data
		remotes.RequestDataSync:FireServer()
	end
end

--[[
	Hide the challenges UI
]]
function ChallengesUI:Hide()
	if mainFrame then
		mainFrame.Visible = false
	end
end

--[[
	Toggle UI visibility
]]
function ChallengesUI:Toggle()
	if mainFrame and mainFrame.Visible then
		self:Hide()
	else
		self:Show()
	end
end

--[[
	Switch between tabs
]]
function ChallengesUI:SwitchTab(tabName)
	currentTab = tabName

	-- Update tab button appearances
	for name, button in pairs(tabButtons) do
		if name == tabName then
			button.BackgroundColor3 = COLORS.Accent
			button.TextColor3 = COLORS.Text
		else
			button.BackgroundColor3 = COLORS.Secondary
			button.TextColor3 = COLORS.TextSecondary
		end
	end

	-- Update content
	self:UpdateContent()
end

--[[
	Update the content area based on current tab
]]
function ChallengesUI:UpdateContent()
	local contentArea = contentFrames.ContentArea

	-- Clear existing content
	for _, child in ipairs(contentArea:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	if currentTab == "Daily" then
		for i, challenge in ipairs(challengeData.Daily) do
			local card = CreateChallengeCard(challenge, false, i)
			card.Parent = contentArea
		end
	elseif currentTab == "Weekly" then
		for i, challenge in ipairs(challengeData.Weekly) do
			local card = CreateChallengeCard(challenge, true, i)
			card.Parent = contentArea
		end
	elseif currentTab == "Quests" then
		-- Show all quest types
		local questLists = {"Tutorial", "Story", "Side", "Zone"}
		for _, questType in ipairs(questLists) do
			if challengeData.Quests[questType] then
				for i, quest in ipairs(challengeData.Quests[questType]) do
					if quest.Status ~= "Locked" and quest.Status ~= "Claimed" then
						local card = CreateQuestCard(quest, i)
						card.Parent = contentArea
					end
				end
			end
		end
	end
end

--[[
	Update challenge data from server
]]
function ChallengesUI:UpdateData(dailyChallenges, weeklyChallenges, quests, streak)
	challengeData.Daily = dailyChallenges or {}
	challengeData.Weekly = weeklyChallenges or {}
	challengeData.Quests = quests or {}
	streakCount = streak or 0

	-- Update streak display
	if mainFrame then
		local streakLabel = mainFrame.Header:FindFirstChild("StreakLabel")
		if streakLabel then
			streakLabel.Text = "Streak: " .. streakCount .. " days"
		end
	end

	-- Update current tab content
	self:UpdateContent()
end

-- Keyboard shortcut (C key to toggle)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.C then
		ChallengesUI:Toggle()
	end
end)

return ChallengesUI
