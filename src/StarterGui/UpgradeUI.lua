--[[
	UpgradeUI.lua
	Upgrade shop interface for Homework Destroyer

	Handles:
	- Display of available upgrades
	- Show costs and current levels
	- Purchase button handling
	- Update UI on server confirmation
	- Multiple upgrade categories (Damage, Speed, Economy)
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents and RemoteFunctions
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetUpgradesFunc = Remotes:WaitForChild("GetUpgrades", 5) or Instance.new("RemoteFunction")
if not GetUpgradesFunc.Parent then
	GetUpgradesFunc.Name = "GetUpgrades"
	GetUpgradesFunc.Parent = Remotes
end

local PurchaseUpgradeEvent = Remotes:WaitForChild("PurchaseUpgrade", 5) or Instance.new("RemoteEvent")
if not PurchaseUpgradeEvent.Parent then
	PurchaseUpgradeEvent.Name = "PurchaseUpgrade"
	PurchaseUpgradeEvent.Parent = Remotes
end

local UpgradeUpdateEvent = Remotes:WaitForChild("UpgradeUpdate", 5) or Instance.new("RemoteEvent")
if not UpgradeUpdateEvent.Parent then
	UpgradeUpdateEvent.Name = "UpgradeUpdate"
	UpgradeUpdateEvent.Parent = Remotes
end

-- UI Components
local upgradeUI
local upgradeFrame
local categoryButtons = {}
local upgradeScrollFrame
local currentCategory = "Damage"
local playerDP = 0

-- Upgrade categories and their definitions
local UPGRADE_CATEGORIES = {
	Damage = {
		Color = Color3.fromRGB(255, 100, 100),
		Icon = "🗡️",
		Upgrades = {
			{Name = "Sharper Tools", Description = "+2 base damage", MaxLevel = 50},
			{Name = "Stronger Arms", Description = "+5% click damage", MaxLevel = 50},
			{Name = "Critical Chance", Description = "+1% crit chance", MaxLevel = 25},
			{Name = "Critical Damage", Description = "+10% crit multiplier", MaxLevel = 25},
			{Name = "Paper Weakness", Description = "+10% damage to paper", MaxLevel = 20},
		}
	},
	Speed = {
		Color = Color3.fromRGB(100, 255, 100),
		Icon = "⚡",
		Upgrades = {
			{Name = "Quick Hands", Description = "-2% click cooldown", MaxLevel = 30},
			{Name = "Auto-Click Speed", Description = "+0.1 auto-clicks/sec", MaxLevel = 20},
			{Name = "Movement Speed", Description = "+3% walk speed", MaxLevel = 15},
		}
	},
	Economy = {
		Color = Color3.fromRGB(255, 215, 0),
		Icon = "💰",
		Upgrades = {
			{Name = "DP Bonus", Description = "+3% DP earned", MaxLevel = 50},
			{Name = "Lucky Drops", Description = "+2% rare drop chance", MaxLevel = 20},
			{Name = "Egg Luck", Description = "+3% pet rarity luck", MaxLevel = 15},
		}
	}
}

--[[
	Formats large numbers with abbreviations
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
	Calculates upgrade cost based on formula
--]]
local function calculateUpgradeCost(upgradeName, currentLevel)
	-- Cost formulas from GameDesign.md
	local formulas = {
		["Sharper Tools"] = function(level) return 100 * math.pow(1.5, level) end,
		["Stronger Arms"] = function(level) return 200 * math.pow(1.5, level) end,
		["Critical Chance"] = function(level) return 500 * math.pow(2, level) end,
		["Critical Damage"] = function(level) return 750 * math.pow(2, level) end,
		["Paper Weakness"] = function(level) return 1000 * math.pow(1.8, level) end,
		["Quick Hands"] = function(level) return 300 * math.pow(1.6, level) end,
		["Auto-Click Speed"] = function(level) return 5000 * math.pow(2, level) end,
		["Movement Speed"] = function(level) return 400 * math.pow(1.5, level) end,
		["DP Bonus"] = function(level) return 150 * math.pow(1.4, level) end,
		["Lucky Drops"] = function(level) return 2000 * math.pow(1.8, level) end,
		["Egg Luck"] = function(level) return 10000 * math.pow(2, level) end,
	}

	local formula = formulas[upgradeName]
	if formula then
		return math.floor(formula(currentLevel))
	end
	return 100
end

--[[
	Creates the main upgrade UI
--]]
local function createUpgradeUI()
	-- Create ScreenGui
	upgradeUI = Instance.new("ScreenGui")
	upgradeUI.Name = "UpgradeUI"
	upgradeUI.ResetOnSpawn = false
	upgradeUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	upgradeUI.Enabled = false -- Start hidden
	upgradeUI.Parent = playerGui

	-- Create main upgrade frame
	upgradeFrame = Instance.new("Frame")
	upgradeFrame.Name = "UpgradeFrame"
	upgradeFrame.Size = UDim2.new(0, 600, 0, 500)
	upgradeFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
	upgradeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	upgradeFrame.BackgroundTransparency = 0.1
	upgradeFrame.BorderSizePixel = 0
	upgradeFrame.Parent = upgradeUI

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = upgradeFrame

	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 50)
	titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = upgradeFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 15)
	titleCorner.Parent = titleBar

	-- Title text
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -100, 1, 0)
	titleLabel.Position = UDim2.new(0, 20, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "UPGRADES"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 24
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0.5, -20)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 20
	closeButton.TextColor3 = Color3.white
	closeButton.BorderSizePixel = 0
	closeButton.Parent = titleBar

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 10)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		toggleUpgradeUI(false)
	end)

	-- DP Display
	local dpDisplay = Instance.new("TextLabel")
	dpDisplay.Name = "DPDisplay"
	dpDisplay.Size = UDim2.new(0, 200, 0, 30)
	dpDisplay.Position = UDim2.new(0, 20, 0, 60)
	dpDisplay.BackgroundTransparency = 1
	dpDisplay.Text = "Your DP: 0"
	dpDisplay.Font = Enum.Font.Gotham
	dpDisplay.TextSize = 16
	dpDisplay.TextColor3 = Color3.fromRGB(255, 215, 0)
	dpDisplay.TextXAlignment = Enum.TextXAlignment.Left
	dpDisplay.Parent = upgradeFrame

	-- Category buttons container
	local categoryContainer = Instance.new("Frame")
	categoryContainer.Name = "CategoryContainer"
	categoryContainer.Size = UDim2.new(1, -40, 0, 40)
	categoryContainer.Position = UDim2.new(0, 20, 0, 100)
	categoryContainer.BackgroundTransparency = 1
	categoryContainer.Parent = upgradeFrame

	local categoryLayout = Instance.new("UIListLayout")
	categoryLayout.FillDirection = Enum.FillDirection.Horizontal
	categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	categoryLayout.Padding = UDim.new(0, 10)
	categoryLayout.Parent = categoryContainer

	-- Create category buttons
	for categoryName, categoryData in pairs(UPGRADE_CATEGORIES) do
		local button = Instance.new("TextButton")
		button.Name = categoryName .. "Button"
		button.Size = UDim2.new(0, 150, 1, 0)
		button.BackgroundColor3 = categoryData.Color
		button.BackgroundTransparency = 0.7
		button.Text = categoryData.Icon .. " " .. categoryName
		button.Font = Enum.Font.GothamBold
		button.TextSize = 14
		button.TextColor3 = Color3.white
		button.BorderSizePixel = 0
		button.Parent = categoryContainer

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = button

		categoryButtons[categoryName] = button

		button.MouseButton1Click:Connect(function()
			selectCategory(categoryName)
		end)
	end

	-- Upgrade scroll frame
	upgradeScrollFrame = Instance.new("ScrollingFrame")
	upgradeScrollFrame.Name = "UpgradeScrollFrame"
	upgradeScrollFrame.Size = UDim2.new(1, -40, 1, -170)
	upgradeScrollFrame.Position = UDim2.new(0, 20, 0, 150)
	upgradeScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	upgradeScrollFrame.BackgroundTransparency = 0.5
	upgradeScrollFrame.BorderSizePixel = 0
	upgradeScrollFrame.ScrollBarThickness = 8
	upgradeScrollFrame.Parent = upgradeFrame

	local scrollCorner = Instance.new("UICorner")
	scrollCorner.CornerRadius = UDim.new(0, 10)
	scrollCorner.Parent = upgradeScrollFrame

	local scrollLayout = Instance.new("UIListLayout")
	scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
	scrollLayout.Padding = UDim.new(0, 10)
	scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	scrollLayout.Parent = upgradeScrollFrame

	local scrollPadding = Instance.new("UIPadding")
	scrollPadding.PaddingTop = UDim.new(0, 10)
	scrollPadding.PaddingBottom = UDim.new(0, 10)
	scrollPadding.Parent = upgradeScrollFrame
end

--[[
	Creates an upgrade item UI element
--]]
local function createUpgradeItem(upgradeData, currentLevel)
	local maxLevel = upgradeData.MaxLevel
	local isMaxed = currentLevel >= maxLevel
	local cost = calculateUpgradeCost(upgradeData.Name, currentLevel)
	local canAfford = playerDP >= cost

	local item = Instance.new("Frame")
	item.Name = upgradeData.Name
	item.Size = UDim2.new(0.95, 0, 0, 80)
	item.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	item.BorderSizePixel = 0
	item.Parent = upgradeScrollFrame

	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 10)
	itemCorner.Parent = item

	-- Upgrade name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0.6, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = upgradeData.Name
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Color3.white
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = item

	-- Level display
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Size = UDim2.new(0.3, -10, 0, 25)
	levelLabel.Position = UDim2.new(0.7, 0, 0, 5)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Level: " .. currentLevel .. "/" .. maxLevel
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextSize = 14
	levelLabel.TextColor3 = isMaxed and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(200, 200, 200)
	levelLabel.TextXAlignment = Enum.TextXAlignment.Right
	levelLabel.Parent = item

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, -20, 0, 20)
	descLabel.Position = UDim2.new(0, 10, 0, 30)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = upgradeData.Description
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 12
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = item

	-- Purchase button
	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyButton"
	buyButton.Size = UDim2.new(0, 120, 0, 25)
	buyButton.Position = UDim2.new(0, 10, 1, -30)
	buyButton.BorderSizePixel = 0
	buyButton.Font = Enum.Font.GothamBold
	buyButton.TextSize = 14
	buyButton.Parent = item

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 6)
	buyCorner.Parent = buyButton

	if isMaxed then
		buyButton.Text = "MAXED"
		buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		buyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
		buyButton.AutoButtonColor = false
	elseif canAfford then
		buyButton.Text = "Buy: " .. formatNumber(cost) .. " DP"
		buyButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		buyButton.TextColor3 = Color3.white
		buyButton.MouseButton1Click:Connect(function()
			purchaseUpgrade(upgradeData.Name, currentCategory)
		end)
	else
		buyButton.Text = "Cost: " .. formatNumber(cost) .. " DP"
		buyButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		buyButton.TextColor3 = Color3.white
		buyButton.AutoButtonColor = false
	end

	return item
end

--[[
	Selects a category and updates the upgrade list
--]]
function selectCategory(categoryName)
	currentCategory = categoryName

	-- Update button states
	for name, button in pairs(categoryButtons) do
		if name == categoryName then
			button.BackgroundTransparency = 0.2
		else
			button.BackgroundTransparency = 0.7
		end
	end

	-- Refresh upgrades list
	refreshUpgradesList()
end

--[[
	Refreshes the upgrades list for current category
--]]
function refreshUpgradesList()
	-- Clear existing items
	for _, child in pairs(upgradeScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Get upgrade data from server
	local success, upgradeData = pcall(function()
		return GetUpgradesFunc:InvokeServer()
	end)

	if not success or not upgradeData then
		warn("Failed to get upgrade data:", upgradeData)
		return
	end

	-- Update player DP
	playerDP = upgradeData.PlayerDP or 0
	local dpDisplay = upgradeFrame:FindFirstChild("DPDisplay")
	if dpDisplay then
		dpDisplay.Text = "Your DP: " .. formatNumber(playerDP)
	end

	-- Create upgrade items
	local categoryData = UPGRADE_CATEGORIES[currentCategory]
	if categoryData then
		for _, upgradeInfo in ipairs(categoryData.Upgrades) do
			local currentLevel = upgradeData.Levels[upgradeInfo.Name] or 0
			createUpgradeItem(upgradeInfo, currentLevel)
		end
	end

	-- Update canvas size
	local layout = upgradeScrollFrame:FindFirstChildOfClass("UIListLayout")
	if layout then
		upgradeScrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end
end

--[[
	Purchases an upgrade
--]]
function purchaseUpgrade(upgradeName, category)
	-- Send purchase request to server
	PurchaseUpgradeEvent:FireServer(upgradeName, category)

	-- Play purchase animation
	local item = upgradeScrollFrame:FindFirstChild(upgradeName)
	if item then
		local originalSize = item.Size
		local tween = TweenService:Create(
			item,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 1.05, 0, originalSize.Y.Offset * 1.05)}
		)
		tween:Play()
	end

	-- Refresh list after a short delay
	task.wait(0.3)
	refreshUpgradesList()
end

--[[
	Toggles upgrade UI visibility
--]]
function toggleUpgradeUI(visible)
	if visible == nil then
		visible = not upgradeUI.Enabled
	end

	upgradeUI.Enabled = visible

	if visible then
		-- Animate in
		upgradeFrame.Size = UDim2.new(0, 0, 0, 0)
		upgradeFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

		local tween = TweenService:Create(
			upgradeFrame,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(0, 600, 0, 500),
				Position = UDim2.new(0.5, -300, 0.5, -250)
			}
		)
		tween:Play()

		-- Refresh the list
		refreshUpgradesList()
	end
end

--[[
	Initializes the upgrade UI
--]]
local function initialize()
	-- Create UI
	createUpgradeUI()

	-- Select default category
	selectCategory("Damage")

	-- Listen for upgrade updates from server
	UpgradeUpdateEvent.OnClientEvent:Connect(function()
		if upgradeUI.Enabled then
			refreshUpgradesList()
		end
	end)

	-- Keybind to toggle upgrade UI (U key)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.U then
			toggleUpgradeUI()
		end
	end)

	print("UpgradeUI initialized - Press U to open upgrades")
end

-- Initialize when player is ready
if player.Character then
	task.wait(1)
	initialize()
else
	player.CharacterAdded:Connect(function()
		task.wait(1)
		initialize()
	end)
end

-- Expose functions for other scripts
return {
	ToggleUI = toggleUpgradeUI,
	RefreshList = refreshUpgradesList,
}
