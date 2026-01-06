--[[
	UIController.lua
	Main UI controller for Homework Destroyer

	Handles:
	- Stats display updates (DP, papers completed, rate, etc.)
	- Level and XP bar
	- Rebirth and Prestige information display
	- UI animations and transitions
	- Communication with server for stat updates
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents and RemoteFunctions
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetPlayerStatsFunc = Remotes:WaitForChild("GetPlayerStats", 5) or Instance.new("RemoteFunction")
if not GetPlayerStatsFunc.Parent then
	GetPlayerStatsFunc.Name = "GetPlayerStats"
	GetPlayerStatsFunc.Parent = Remotes
end

local UpdateStatsEvent = Remotes:WaitForChild("UpdateStats", 5) or Instance.new("RemoteEvent")
if not UpdateStatsEvent.Parent then
	UpdateStatsEvent.Name = "UpdateStats"
	UpdateStatsEvent.Parent = Remotes
end

-- UI Components (will be created dynamically)
local mainUI
local statsFrame
local dpLabel
local papersLabel
local levelLabel
local xpBar
local rebirthLabel
local prestigeLabel
local rateLabel

-- Stats cache
local currentStats = {
	DP = 0,
	PapersDestroyed = 0,
	Level = 1,
	XP = 0,
	XPRequired = 100,
	Rebirth = 0,
	Prestige = 0,
	DamageRate = 0,
	DPPerSecond = 0,
}

-- Animation settings
local UPDATE_ANIMATION_TIME = 0.3
local NUMBER_COUNT_DURATION = 0.5

--[[
	Formats large numbers with abbreviations (K, M, B, T, etc.)
--]]
local function formatNumber(num)
	if num < 1000 then
		return tostring(math.floor(num))
	elseif num < 1000000 then
		return string.format("%.1fK", num / 1000)
	elseif num < 1000000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num < 1000000000000 then
		return string.format("%.1fB", num / 1000000000)
	elseif num < 1000000000000000 then
		return string.format("%.1fT", num / 1000000000000)
	else
		return string.format("%.1fQd", num / 1000000000000000)
	end
end

--[[
	Animates a number counting up
--]]
local function animateNumberCount(label, startValue, endValue, duration)
	local startTime = tick()
	local connection

	connection = game:GetService("RunService").Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local progress = math.min(elapsed / duration, 1)

		-- Ease out cubic
		local easedProgress = 1 - math.pow(1 - progress, 3)
		local currentValue = startValue + (endValue - startValue) * easedProgress

		label.Text = formatNumber(currentValue)

		if progress >= 1 then
			connection:Disconnect()
			label.Text = formatNumber(endValue)
		end
	end)
end

--[[
	Creates the main stats UI
--]]
local function createMainUI()
	-- Create ScreenGui
	mainUI = Instance.new("ScreenGui")
	mainUI.Name = "MainStatsUI"
	mainUI.ResetOnSpawn = false
	mainUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mainUI.Parent = playerGui

	-- Create main stats frame
	statsFrame = Instance.new("Frame")
	statsFrame.Name = "StatsFrame"
	statsFrame.Size = UDim2.new(0, 300, 0, 200)
	statsFrame.Position = UDim2.new(0, 10, 0, 10)
	statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	statsFrame.BackgroundTransparency = 0.3
	statsFrame.BorderSizePixel = 0
	statsFrame.Parent = mainUI

	-- Add corner rounding
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = statsFrame

	-- Add padding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.Parent = statsFrame

	-- Add layout
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = statsFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 25)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "HOMEWORK DESTROYER"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.LayoutOrder = 1
	titleLabel.Parent = statsFrame

	-- DP (Destruction Points) Label
	dpLabel = Instance.new("TextLabel")
	dpLabel.Name = "DPLabel"
	dpLabel.Size = UDim2.new(1, 0, 0, 20)
	dpLabel.BackgroundTransparency = 1
	dpLabel.Text = "DP: 0"
	dpLabel.Font = Enum.Font.Gotham
	dpLabel.TextSize = 14
	dpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	dpLabel.TextXAlignment = Enum.TextXAlignment.Left
	dpLabel.LayoutOrder = 2
	dpLabel.Parent = statsFrame

	-- Papers Destroyed Label
	papersLabel = Instance.new("TextLabel")
	papersLabel.Name = "PapersLabel"
	papersLabel.Size = UDim2.new(1, 0, 0, 20)
	papersLabel.BackgroundTransparency = 1
	papersLabel.Text = "Papers: 0"
	papersLabel.Font = Enum.Font.Gotham
	papersLabel.TextSize = 14
	papersLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	papersLabel.TextXAlignment = Enum.TextXAlignment.Left
	papersLabel.LayoutOrder = 3
	papersLabel.Parent = statsFrame

	-- Level Label
	levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Size = UDim2.new(1, 0, 0, 20)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Level: 1"
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.TextSize = 14
	levelLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.LayoutOrder = 4
	levelLabel.Parent = statsFrame

	-- XP Bar Container
	local xpBarContainer = Instance.new("Frame")
	xpBarContainer.Name = "XPBarContainer"
	xpBarContainer.Size = UDim2.new(1, 0, 0, 16)
	xpBarContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	xpBarContainer.BorderSizePixel = 0
	xpBarContainer.LayoutOrder = 5
	xpBarContainer.Parent = statsFrame

	local xpCorner = Instance.new("UICorner")
	xpCorner.CornerRadius = UDim.new(0, 8)
	xpCorner.Parent = xpBarContainer

	-- XP Bar Fill
	xpBar = Instance.new("Frame")
	xpBar.Name = "XPBar"
	xpBar.Size = UDim2.new(0, 0, 1, 0)
	xpBar.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
	xpBar.BorderSizePixel = 0
	xpBar.Parent = xpBarContainer

	local xpFillCorner = Instance.new("UICorner")
	xpFillCorner.CornerRadius = UDim.new(0, 8)
	xpFillCorner.Parent = xpBar

	-- XP Text
	local xpText = Instance.new("TextLabel")
	xpText.Name = "XPText"
	xpText.Size = UDim2.new(1, 0, 1, 0)
	xpText.BackgroundTransparency = 1
	xpText.Text = "0 / 100"
	xpText.Font = Enum.Font.GothamBold
	xpText.TextSize = 12
	xpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	xpText.ZIndex = 2
	xpText.Parent = xpBarContainer

	-- Rate Label (DP/s)
	rateLabel = Instance.new("TextLabel")
	rateLabel.Name = "RateLabel"
	rateLabel.Size = UDim2.new(1, 0, 0, 18)
	rateLabel.BackgroundTransparency = 1
	rateLabel.Text = "Rate: 0 DP/s"
	rateLabel.Font = Enum.Font.Gotham
	rateLabel.TextSize = 12
	rateLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	rateLabel.TextXAlignment = Enum.TextXAlignment.Left
	rateLabel.LayoutOrder = 6
	rateLabel.Parent = statsFrame

	-- Rebirth Label
	rebirthLabel = Instance.new("TextLabel")
	rebirthLabel.Name = "RebirthLabel"
	rebirthLabel.Size = UDim2.new(1, 0, 0, 18)
	rebirthLabel.BackgroundTransparency = 1
	rebirthLabel.Text = "Rebirth: 0"
	rebirthLabel.Font = Enum.Font.GothamBold
	rebirthLabel.TextSize = 12
	rebirthLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
	rebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
	rebirthLabel.LayoutOrder = 7
	rebirthLabel.Parent = statsFrame

	-- Prestige Label
	prestigeLabel = Instance.new("TextLabel")
	prestigeLabel.Name = "PrestigeLabel"
	prestigeLabel.Size = UDim2.new(1, 0, 0, 18)
	prestigeLabel.BackgroundTransparency = 1
	prestigeLabel.Text = ""
	prestigeLabel.Font = Enum.Font.GothamBold
	prestigeLabel.TextSize = 12
	prestigeLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	prestigeLabel.TextXAlignment = Enum.TextXAlignment.Left
	prestigeLabel.LayoutOrder = 8
	prestigeLabel.Parent = statsFrame
end

--[[
	Updates the UI with new stats
--]]
local function updateUI(stats, animate)
	if not stats then return end

	animate = animate == nil and true or animate

	-- Update DP with animation
	if animate and stats.DP ~= currentStats.DP then
		animateNumberCount(dpLabel, currentStats.DP, stats.DP, NUMBER_COUNT_DURATION)
	end
	dpLabel.Text = "DP: " .. formatNumber(stats.DP)

	-- Update papers destroyed
	if animate and stats.PapersDestroyed ~= currentStats.PapersDestroyed then
		animateNumberCount(papersLabel, currentStats.PapersDestroyed, stats.PapersDestroyed, NUMBER_COUNT_DURATION)
	end
	papersLabel.Text = "Papers: " .. formatNumber(stats.PapersDestroyed)

	-- Update level
	levelLabel.Text = "Level: " .. tostring(stats.Level)

	-- Check for level up
	if stats.Level > currentStats.Level then
		playLevelUpAnimation()
	end

	-- Update XP bar
	local xpProgress = stats.XPRequired > 0 and (stats.XP / stats.XPRequired) or 0
	local xpBarGoal = {Size = UDim2.new(xpProgress, 0, 1, 0)}

	if animate then
		local tween = TweenService:Create(
			xpBar,
			TweenInfo.new(UPDATE_ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			xpBarGoal
		)
		tween:Play()
	else
		xpBar.Size = xpBarGoal.Size
	end

	local xpText = xpBar.Parent:FindFirstChild("XPText")
	if xpText then
		xpText.Text = formatNumber(stats.XP) .. " / " .. formatNumber(stats.XPRequired)
	end

	-- Update rate
	rateLabel.Text = "Rate: " .. formatNumber(stats.DPPerSecond or 0) .. " DP/s"

	-- Update rebirth
	rebirthLabel.Text = "Rebirth: " .. tostring(stats.Rebirth)

	-- Update prestige (only show if > 0)
	if stats.Prestige and stats.Prestige > 0 then
		local prestigeNames = {
			[1] = "I - Homework Hater",
			[2] = "II - Assignment Annihilator",
			[3] = "III - Test Terminator",
			[4] = "IV - Scholar Slayer",
			[5] = "V - Education Eliminator",
			[6] = "MAX - HOMEWORK DESTROYER",
		}
		prestigeLabel.Text = "Prestige: " .. (prestigeNames[stats.Prestige] or "Rank " .. stats.Prestige)
		prestigeLabel.Visible = true
	else
		prestigeLabel.Visible = false
	end

	-- Update cache
	currentStats = stats
end

--[[
	Plays level up animation
--]]
function playLevelUpAnimation()
	-- Flash the level label
	local originalColor = levelLabel.TextColor3
	levelLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

	-- Scale animation
	local originalSize = levelLabel.TextSize
	local tween = TweenService:Create(
		levelLabel,
		TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{TextSize = originalSize * 1.5}
	)
	tween:Play()

	-- Reset after delay
	task.delay(0.5, function()
		local resetTween = TweenService:Create(
			levelLabel,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{TextSize = originalSize, TextColor3 = originalColor}
		)
		resetTween:Play()
	end)

	-- Create particles effect
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 200)
	billboard.AlwaysOnTop = true
	billboard.Parent = levelLabel

	local particles = Instance.new("ImageLabel")
	particles.Size = UDim2.new(1, 0, 1, 0)
	particles.BackgroundTransparency = 1
	particles.Image = "rbxasset://textures/particles/sparkles_main.dds"
	particles.ImageColor3 = Color3.fromRGB(255, 215, 0)
	particles.Parent = billboard

	game:GetService("Debris"):AddItem(billboard, 1)
end

--[[
	Requests initial stats from server
--]]
local function requestStats()
	local success, stats = pcall(function()
		return GetPlayerStatsFunc:InvokeServer()
	end)

	if success and stats then
		updateUI(stats, false)
	else
		warn("Failed to get player stats:", stats)
	end
end

--[[
	Initializes the UI controller
--]]
local function initialize()
	-- Create UI
	createMainUI()

	-- Request initial stats
	requestStats()

	-- Listen for stat updates from server
	UpdateStatsEvent.OnClientEvent:Connect(function(stats)
		updateUI(stats, true)
	end)

	-- Periodic stats refresh (every 2 seconds as backup)
	task.spawn(function()
		while true do
			task.wait(2)
			requestStats()
		end
	end)

	print("UIController initialized")
end

-- Initialize when player is ready
if player.Character then
	task.wait(1) -- Give time for UI to load
	initialize()
else
	player.CharacterAdded:Connect(function()
		task.wait(1)
		initialize()
	end)
end

-- Expose functions for other scripts
return {
	UpdateUI = updateUI,
	FormatNumber = formatNumber,
	GetCurrentStats = function() return currentStats end,
}
