--[[
	ShopUI.lua
	Complete shop interface for Homework Destroyer

	Features:
	- Tool Shop UI
	- Egg Shop UI (8 egg types)
	- Rebirth Token Shop UI
	- Gamepass Shop UI
	- Responsive layouts and animations
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ShopUI = {}
ShopUI.__index = ShopUI

-- Remote Events
local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)
local remotes = RemoteEvents.Get()

-- UI Configuration
local COLORS = {
	Background = Color3.fromRGB(20, 20, 25),
	Panel = Color3.fromRGB(30, 30, 35),
	Header = Color3.fromRGB(40, 40, 50),
	Button = Color3.fromRGB(50, 130, 230),
	ButtonHover = Color3.fromRGB(70, 150, 250),
	ButtonDisabled = Color3.fromRGB(80, 80, 90),
	Success = Color3.fromRGB(40, 180, 80),
	Error = Color3.fromRGB(220, 50, 50),
	Rare = {
		Common = Color3.fromRGB(180, 180, 180),
		Uncommon = Color3.fromRGB(76, 175, 80),
		Rare = Color3.fromRGB(33, 150, 243),
		Epic = Color3.fromRGB(156, 39, 176),
		Legendary = Color3.fromRGB(255, 193, 7),
		Mythic = Color3.fromRGB(255, 0, 128),
	},
	Text = {
		Primary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(180, 180, 180),
		Disabled = Color3.fromRGB(100, 100, 100),
	},
}

-- ========================================
-- UI CREATION
-- ========================================

function ShopUI.new()
	local self = setmetatable({}, ShopUI)

	self.currentShop = "Tools" -- Tools, Eggs, Rebirth, Gamepasses
	self.shopData = {
		Tools = {},
		Eggs = {},
		RebirthItems = {},
	}

	self:CreateMainUI()
	self:SetupEventListeners()

	return self
end

function ShopUI:CreateMainUI()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	self.gui = screenGui

	-- Main Container (Hidden by default)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 900, 0, 600)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = COLORS.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.Parent = screenGui

	self.mainFrame = mainFrame

	-- Add UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	-- Add UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.Button
	stroke.Thickness = 2
	stroke.Parent = mainFrame

	-- Header
	self:CreateHeader(mainFrame)

	-- Tab Navigation
	self:CreateTabNavigation(mainFrame)

	-- Content Area
	self:CreateContentArea(mainFrame)

	-- Close Button
	self:CreateCloseButton(mainFrame)

	-- Currency Display
	self:CreateCurrencyDisplay(mainFrame)
end

function ShopUI:CreateHeader(parent)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BackgroundColor3 = COLORS.Header
	header.BorderSizePixel = 0
	header.Parent = parent

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header

	-- Cover bottom corners
	local bottomCover = Instance.new("Frame")
	bottomCover.Size = UDim2.new(1, 0, 0, 12)
	bottomCover.Position = UDim2.new(0, 0, 1, -12)
	bottomCover.BackgroundColor3 = COLORS.Header
	bottomCover.BorderSizePixel = 0
	bottomCover.Parent = header

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(0, 300, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.TextColor3 = COLORS.Text.Primary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "SHOP"
	title.Parent = header

	self.headerTitle = title
end

function ShopUI:CreateTabNavigation(parent)
	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "TabNavigation"
	tabContainer.Size = UDim2.new(1, -40, 0, 50)
	tabContainer.Position = UDim2.new(0, 20, 0, 70)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.Parent = tabContainer

	self.tabContainer = tabContainer
	self.tabs = {}

	-- Create tabs
	local tabs = {
		{Name = "Tools", Icon = "🔧", Order = 1},
		{Name = "Eggs", Icon = "🥚", Order = 2},
		{Name = "Rebirth", Icon = "🔄", Order = 3},
		{Name = "Gamepasses", Icon = "💎", Order = 4},
	}

	for _, tabData in ipairs(tabs) do
		self:CreateTab(tabContainer, tabData)
	end
end

function ShopUI:CreateTab(parent, tabData)
	local button = Instance.new("TextButton")
	button.Name = tabData.Name .. "Tab"
	button.Size = UDim2.new(0, 200, 1, 0)
	button.BackgroundColor3 = COLORS.Panel
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 18
	button.TextColor3 = COLORS.Text.Primary
	button.Text = tabData.Icon .. " " .. tabData.Name
	button.LayoutOrder = tabData.Order
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	self.tabs[tabData.Name] = button

	-- Click handler
	button.MouseButton1Click:Connect(function()
		self:SwitchTab(tabData.Name)
	end)

	-- Hover effects
	button.MouseEnter:Connect(function()
		if self.currentShop ~= tabData.Name then
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Button}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if self.currentShop ~= tabData.Name then
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Panel}):Play()
		end
	end)
end

function ShopUI:CreateContentArea(parent)
	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Name = "ContentArea"
	contentFrame.Size = UDim2.new(1, -40, 1, -200)
	contentFrame.Position = UDim2.new(0, 20, 0, 130)
	contentFrame.BackgroundColor3 = COLORS.Panel
	contentFrame.BorderSizePixel = 0
	contentFrame.ScrollBarThickness = 8
	contentFrame.ScrollBarImageColor3 = COLORS.Button
	contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentFrame.Parent = parent

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 8)
	contentCorner.Parent = contentFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 15)
	padding.PaddingBottom = UDim.new(0, 15)
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.Parent = contentFrame

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0, 260, 0, 180)
	layout.CellPadding = UDim2.new(0, 15, 0, 15)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = contentFrame

	self.contentArea = contentFrame
	self.contentLayout = layout
end

function ShopUI:CreateCloseButton(parent)
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 10)
	closeButton.BackgroundColor3 = COLORS.Error
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 24
	closeButton.TextColor3 = COLORS.Text.Primary
	closeButton.Text = "✕"
	closeButton.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		self:Hide()
	end)

	-- Hover effect
	closeButton.MouseEnter:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
	end)

	closeButton.MouseLeave:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Error}):Play()
	end)
end

function ShopUI:CreateCurrencyDisplay(parent)
	local currencyFrame = Instance.new("Frame")
	currencyFrame.Name = "CurrencyDisplay"
	currencyFrame.Size = UDim2.new(0, 400, 0, 50)
	currencyFrame.Position = UDim2.new(1, -420, 1, -60)
	currencyFrame.BackgroundColor3 = COLORS.Header
	currencyFrame.BorderSizePixel = 0
	currencyFrame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = currencyFrame

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 20)
	layout.Parent = currencyFrame

	-- DP Display
	local dpLabel = Instance.new("TextLabel")
	dpLabel.Name = "DP"
	dpLabel.Size = UDim2.new(0, 150, 0, 30)
	dpLabel.BackgroundTransparency = 1
	dpLabel.Font = Enum.Font.GothamBold
	dpLabel.TextSize = 16
	dpLabel.TextColor3 = COLORS.Text.Primary
	dpLabel.Text = "💵 DP: 0"
	dpLabel.Parent = currencyFrame

	-- Gems Display
	local gemsLabel = Instance.new("TextLabel")
	gemsLabel.Name = "Gems"
	gemsLabel.Size = UDim2.new(0, 120, 0, 30)
	gemsLabel.BackgroundTransparency = 1
	gemsLabel.Font = Enum.Font.GothamBold
	gemsLabel.TextSize = 16
	gemsLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	gemsLabel.Text = "💎 Gems: 0"
	gemsLabel.Parent = currencyFrame

	-- Rebirth Tokens Display
	local tokensLabel = Instance.new("TextLabel")
	tokensLabel.Name = "Tokens"
	tokensLabel.Size = UDim2.new(0, 100, 0, 30)
	tokensLabel.BackgroundTransparency = 1
	tokensLabel.Font = Enum.Font.GothamBold
	tokensLabel.TextSize = 16
	tokensLabel.TextColor3 = COLORS.Rare.Legendary
	tokensLabel.Text = "🔄 RT: 0"
	tokensLabel.Parent = currencyFrame

	self.currencyLabels = {
		DP = dpLabel,
		Gems = gemsLabel,
		Tokens = tokensLabel,
	}
end

-- ========================================
-- SHOP ITEM CREATION
-- ========================================

function ShopUI:CreateToolItem(toolData, index)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = "Tool_" .. toolData.ID
	itemFrame.Size = UDim2.new(0, 260, 0, 180)
	itemFrame.BackgroundColor3 = COLORS.Header
	itemFrame.BorderSizePixel = 0
	itemFrame.LayoutOrder = index
	itemFrame.Parent = self.contentArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = itemFrame

	-- Rarity border
	local rarityStroke = Instance.new("UIStroke")
	rarityStroke.Color = COLORS.Rare[toolData.Rarity] or COLORS.Rare.Common
	rarityStroke.Thickness = 3
	rarityStroke.Parent = itemFrame

	-- Icon
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 80, 0, 80)
	icon.Position = UDim2.new(0.5, 0, 0, 10)
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.BackgroundTransparency = 1
	icon.Image = toolData.Icon or ""
	icon.Parent = itemFrame

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 95)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = COLORS.Rare[toolData.Rarity] or COLORS.Text.Primary
	nameLabel.Text = toolData.Name
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = itemFrame

	-- Stats
	local statsLabel = Instance.new("TextLabel")
	statsLabel.Name = "Stats"
	statsLabel.Size = UDim2.new(1, -10, 0, 20)
	statsLabel.Position = UDim2.new(0, 5, 0, 120)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Font = Enum.Font.Gotham
	statsLabel.TextSize = 11
	statsLabel.TextColor3 = COLORS.Text.Secondary
	statsLabel.Text = string.format("DMG: %d | Crit: %.0f%%", toolData.BaseDamage, toolData.CritChance * 100)
	statsLabel.Parent = itemFrame

	-- Purchase/Upgrade Button
	local button = Instance.new("TextButton")
	button.Name = "ActionButton"
	button.Size = UDim2.new(1, -20, 0, 30)
	button.Position = UDim2.new(0, 10, 1, -40)
	button.BackgroundColor3 = toolData.CanPurchase and COLORS.Button or COLORS.ButtonDisabled
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.TextColor3 = COLORS.Text.Primary
	button.Parent = itemFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button

	if toolData.IsOwned then
		-- Upgrade button
		if toolData.UpgradeLevel >= toolData.MaxUpgradeLevel then
			button.Text = "MAX LEVEL"
			button.BackgroundColor3 = COLORS.Success
		else
			button.Text = string.format("Upgrade: %d DP (Lv. %d/%d)", toolData.UpgradeCost or 0, toolData.UpgradeLevel, toolData.MaxUpgradeLevel)
			button.MouseButton1Click:Connect(function()
				self:UpgradeTool(toolData.ID)
			end)
		end
	else
		-- Purchase button
		if toolData.Cost == 0 then
			button.Text = "FREE - Claim"
		else
			button.Text = string.format("Purchase: %d DP", toolData.Cost)
		end

		if toolData.CanPurchase then
			button.MouseButton1Click:Connect(function()
				self:PurchaseTool(toolData.ID)
			end)
		else
			button.Text = toolData.Reason or "Locked"
		end
	end

	-- Hover effects
	if toolData.CanPurchase or (toolData.IsOwned and toolData.UpgradeLevel < toolData.MaxUpgradeLevel) then
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHover}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Button}):Play()
		end)
	end

	return itemFrame
end

function ShopUI:CreateEggItem(eggData, index)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = "Egg_" .. eggData.ID
	itemFrame.Size = UDim2.new(0, 260, 0, 200)
	itemFrame.BackgroundColor3 = COLORS.Header
	itemFrame.BorderSizePixel = 0
	itemFrame.LayoutOrder = index
	itemFrame.Parent = self.contentArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = itemFrame

	-- Premium border
	if eggData.IsPremium then
		local premiumStroke = Instance.new("UIStroke")
		premiumStroke.Color = COLORS.Rare.Legendary
		premiumStroke.Thickness = 4
		premiumStroke.Parent = itemFrame
	end

	-- Icon
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 80, 0, 80)
	icon.Position = UDim2.new(0.5, 0, 0, 10)
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.BackgroundTransparency = 1
	icon.Image = eggData.Icon or ""
	icon.Parent = itemFrame

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 95)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = eggData.IsPremium and COLORS.Rare.Legendary or COLORS.Text.Primary
	nameLabel.Text = eggData.Name
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = itemFrame

	-- Rarity chances
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "Rarity"
	rarityLabel.Size = UDim2.new(1, -10, 0, 30)
	rarityLabel.Position = UDim2.new(0, 5, 0, 120)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.Gotham
	rarityLabel.TextSize = 10
	rarityLabel.TextColor3 = COLORS.Text.Secondary
	rarityLabel.TextWrapped = true

	local rarityText = ""
	if eggData.RarityChances.Legendary > 0 then
		rarityText = string.format("Legendary: %.1f%%", eggData.RarityChances.Legendary)
	elseif eggData.RarityChances.Epic > 0 then
		rarityText = string.format("Epic: %.1f%%", eggData.RarityChances.Epic)
	else
		rarityText = string.format("Rare: %.1f%%", eggData.RarityChances.Rare)
	end
	rarityLabel.Text = rarityText
	rarityLabel.Parent = itemFrame

	-- Owned count
	if eggData.OwnedCount > 0 then
		local ownedLabel = Instance.new("TextLabel")
		ownedLabel.Name = "Owned"
		ownedLabel.Size = UDim2.new(0, 60, 0, 25)
		ownedLabel.Position = UDim2.new(1, -65, 0, 5)
		ownedLabel.BackgroundColor3 = COLORS.Success
		ownedLabel.Font = Enum.Font.GothamBold
		ownedLabel.TextSize = 12
		ownedLabel.TextColor3 = COLORS.Text.Primary
		ownedLabel.Text = string.format("x%d", eggData.OwnedCount)
		ownedLabel.Parent = itemFrame

		local ownedCorner = Instance.new("UICorner")
		ownedCorner.CornerRadius = UDim.new(0, 6)
		ownedCorner.Parent = ownedLabel
	end

	-- Purchase Button
	local button = Instance.new("TextButton")
	button.Name = "PurchaseButton"
	button.Size = UDim2.new(1, -20, 0, 35)
	button.Position = UDim2.new(0, 10, 1, -45)
	button.BackgroundColor3 = eggData.CanPurchase and COLORS.Button or COLORS.ButtonDisabled
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.TextColor3 = COLORS.Text.Primary
	button.Parent = itemFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button

	if eggData.CanPurchase then
		local costText = ""
		if eggData.Cost.Currency == "DestructionPoints" then
			costText = string.format("Buy: %d DP", eggData.Cost.Amount)
		elseif eggData.Cost.Currency == "Gems" then
			costText = string.format("Buy: %d Gems", eggData.Cost.Amount)
		elseif eggData.Cost.Currency == "Robux" then
			costText = string.format("Buy: %d Robux", eggData.Cost.Amount)
		end
		button.Text = costText

		button.MouseButton1Click:Connect(function()
			self:PurchaseEgg(eggData.ID)
		end)

		-- Hover effects
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHover}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Button}):Play()
		end)
	else
		button.Text = eggData.Reason or "Locked"
	end

	return itemFrame
end

function ShopUI:CreateRebirthItem(itemData, index)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = "Rebirth_" .. itemData.ID
	itemFrame.Size = UDim2.new(0, 260, 0, 160)
	itemFrame.BackgroundColor3 = COLORS.Header
	itemFrame.BorderSizePixel = 0
	itemFrame.LayoutOrder = index
	itemFrame.Parent = self.contentArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = itemFrame

	-- Maxed border
	if itemData.IsMaxed then
		local maxedStroke = Instance.new("UIStroke")
		maxedStroke.Color = COLORS.Success
		maxedStroke.Thickness = 3
		maxedStroke.Parent = itemFrame
	end

	-- Icon
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 10, 0, 10)
	icon.BackgroundTransparency = 1
	icon.Image = itemData.Icon or ""
	icon.Parent = itemFrame

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -85, 0, 25)
	nameLabel.Position = UDim2.new(0, 75, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = COLORS.Text.Primary
	nameLabel.Text = itemData.Name
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = itemFrame

	-- Category badge
	local categoryBadge = Instance.new("TextLabel")
	categoryBadge.Size = UDim2.new(0, 80, 0, 20)
	categoryBadge.Position = UDim2.new(0, 75, 0, 35)
	categoryBadge.BackgroundColor3 = COLORS.Button
	categoryBadge.Font = Enum.Font.Gotham
	categoryBadge.TextSize = 10
	categoryBadge.TextColor3 = COLORS.Text.Primary
	categoryBadge.Text = itemData.Category
	categoryBadge.Parent = itemFrame

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 4)
	badgeCorner.Parent = categoryBadge

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "Description"
	descLabel.Size = UDim2.new(1, -20, 0, 40)
	descLabel.Position = UDim2.new(0, 10, 0, 75)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 11
	descLabel.TextColor3 = COLORS.Text.Secondary
	descLabel.Text = itemData.Description
	descLabel.TextWrapped = true
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = itemFrame

	-- Purchase count (if stackable)
	if itemData.Stackable and itemData.PurchaseCount > 0 then
		local countLabel = Instance.new("TextLabel")
		countLabel.Size = UDim2.new(0, 50, 0, 20)
		countLabel.Position = UDim2.new(1, -55, 0, 10)
		countLabel.BackgroundColor3 = COLORS.Rare.Legendary
		countLabel.Font = Enum.Font.GothamBold
		countLabel.TextSize = 12
		countLabel.TextColor3 = COLORS.Text.Primary
		countLabel.Text = string.format("%d/%d", itemData.PurchaseCount, itemData.MaxPurchases)
		countLabel.Parent = itemFrame

		local countCorner = Instance.new("UICorner")
		countCorner.CornerRadius = UDim.new(0, 4)
		countCorner.Parent = countLabel
	end

	-- Purchase Button
	local button = Instance.new("TextButton")
	button.Name = "PurchaseButton"
	button.Size = UDim2.new(1, -20, 0, 30)
	button.Position = UDim2.new(0, 10, 1, -40)
	button.BackgroundColor3 = itemData.CanPurchase and COLORS.Button or COLORS.ButtonDisabled
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.TextColor3 = COLORS.Text.Primary
	button.Parent = itemFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button

	if itemData.IsMaxed then
		button.Text = "MAXED OUT"
		button.BackgroundColor3 = COLORS.Success
	elseif itemData.CanPurchase then
		button.Text = string.format("Purchase: %d RT", itemData.Cost.Amount)
		button.MouseButton1Click:Connect(function()
			self:PurchaseRebirthItem(itemData.ID)
		end)

		-- Hover effects
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHover}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Button}):Play()
		end)
	else
		button.Text = itemData.Reason or "Locked"
	end

	return itemFrame
end

function ShopUI:CreateGamepassItem(gamepassData, index)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = "Gamepass_" .. gamepassData.ID
	itemFrame.Size = UDim2.new(0, 260, 0, 200)
	itemFrame.BackgroundColor3 = COLORS.Header
	itemFrame.BorderSizePixel = 0
	itemFrame.LayoutOrder = index
	itemFrame.Parent = self.contentArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = itemFrame

	-- Premium glow
	local glowStroke = Instance.new("UIStroke")
	glowStroke.Color = COLORS.Rare.Legendary
	glowStroke.Thickness = 4
	glowStroke.Parent = itemFrame

	-- Icon
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 100, 0, 100)
	icon.Position = UDim2.new(0.5, 0, 0, 10)
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.BackgroundTransparency = 1
	icon.Image = gamepassData.Icon or ""
	icon.Parent = itemFrame

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 115)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = COLORS.Rare.Legendary
	nameLabel.Text = gamepassData.Name
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = itemFrame

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "Description"
	descLabel.Size = UDim2.new(1, -20, 0, 20)
	descLabel.Position = UDim2.new(0, 10, 0, 140)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 11
	descLabel.TextColor3 = COLORS.Text.Secondary
	descLabel.Text = gamepassData.Description
	descLabel.TextWrapped = true
	descLabel.Parent = itemFrame

	-- Purchase Button
	local button = Instance.new("TextButton")
	button.Name = "PurchaseButton"
	button.Size = UDim2.new(1, -20, 0, 35)
	button.Position = UDim2.new(0, 10, 1, -45)
	button.BackgroundColor3 = gamepassData.Owned and COLORS.Success or COLORS.Rare.Legendary
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.TextColor3 = COLORS.Text.Primary
	button.Parent = itemFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button

	if gamepassData.Owned then
		button.Text = "✓ OWNED"
	else
		button.Text = string.format("Purchase: %d Robux", gamepassData.Price)
		button.MouseButton1Click:Connect(function()
			self:PurchaseGamepass(gamepassData.ID)
		end)

		-- Hover effects
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(255, 220, 50)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = COLORS.Rare.Legendary
			}):Play()
		end)
	end

	return itemFrame
end

-- ========================================
-- TAB SWITCHING
-- ========================================

function ShopUI:SwitchTab(tabName)
	self.currentShop = tabName

	-- Update tab colors
	for name, button in pairs(self.tabs) do
		if name == tabName then
			button.BackgroundColor3 = COLORS.Button
		else
			button.BackgroundColor3 = COLORS.Panel
		end
	end

	-- Clear content
	for _, child in ipairs(self.contentArea:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Load new content
	if tabName == "Tools" then
		self:LoadToolShop()
	elseif tabName == "Eggs" then
		self:LoadEggShop()
	elseif tabName == "Rebirth" then
		self:LoadRebirthShop()
	elseif tabName == "Gamepasses" then
		self:LoadGamepassShop()
	end
end

-- ========================================
-- SHOP LOADING FUNCTIONS
-- ========================================

function ShopUI:LoadToolShop()
	-- Request tool data from server
	remotes.RequestShopData:InvokeServer("Tools")
end

function ShopUI:LoadEggShop()
	-- Request egg data from server
	remotes.RequestShopData:InvokeServer("Eggs")
end

function ShopUI:LoadRebirthShop()
	-- Request rebirth shop data from server
	remotes.RequestShopData:InvokeServer("Rebirth")
end

function ShopUI:LoadGamepassShop()
	-- Request gamepass data from server
	remotes.RequestShopData:InvokeServer("Gamepasses")
end

function ShopUI:UpdateToolShop(toolsData)
	self.shopData.Tools = toolsData

	for i, toolData in ipairs(toolsData) do
		self:CreateToolItem(toolData, i)
	end
end

function ShopUI:UpdateEggShop(eggsData)
	self.shopData.Eggs = eggsData

	for i, eggData in ipairs(eggsData) do
		self:CreateEggItem(eggData, i)
	end
end

function ShopUI:UpdateRebirthShop(rebirthData)
	self.shopData.RebirthItems = rebirthData

	for i, itemData in ipairs(rebirthData) do
		self:CreateRebirthItem(itemData, i)
	end
end

function ShopUI:UpdateGamepassShop(gamepassData)
	for i, passData in ipairs(gamepassData) do
		self:CreateGamepassItem(passData, i)
	end
end

-- ========================================
-- PURCHASE FUNCTIONS
-- ========================================

function ShopUI:PurchaseTool(toolID)
	remotes.PurchaseTool:FireServer(toolID)
end

function ShopUI:UpgradeTool(toolID)
	remotes.UpgradeTool:FireServer(toolID)
end

function ShopUI:PurchaseEgg(eggID)
	remotes.PurchaseEgg:FireServer(eggID)
end

function ShopUI:PurchaseRebirthItem(itemID)
	remotes.PurchaseRebirthUpgrade:FireServer(itemID)
end

function ShopUI:PurchaseGamepass(gamepassID)
	remotes.PurchaseGamepass:InvokeServer(gamepassID)
end

-- ========================================
-- UI CONTROL
-- ========================================

function ShopUI:Show()
	self.mainFrame.Visible = true
	self.mainFrame.Position = UDim2.new(0.5, 0, 1.5, 0)

	-- Animate in
	TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()

	-- Load current tab
	self:SwitchTab(self.currentShop)
end

function ShopUI:Hide()
	-- Animate out
	local tween = TweenService:Create(self.mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	})

	tween:Play()
	tween.Completed:Connect(function()
		self.mainFrame.Visible = false
	end)
end

function ShopUI:Toggle()
	if self.mainFrame.Visible then
		self:Hide()
	else
		self:Show()
	end
end

function ShopUI:UpdateCurrency(dp, gems, tokens)
	self.currencyLabels.DP.Text = string.format("💵 DP: %s", self:FormatNumber(dp))
	self.currencyLabels.Gems.Text = string.format("💎 Gems: %s", self:FormatNumber(gems))
	self.currencyLabels.Tokens.Text = string.format("🔄 RT: %d", tokens)
end

-- ========================================
-- EVENT LISTENERS
-- ========================================

function ShopUI:SetupEventListeners()
	-- Listen for shop data updates
	remotes.ShopDataUpdate.OnClientEvent:Connect(function(shopType, data)
		if shopType == "Tools" then
			self:UpdateToolShop(data)
		elseif shopType == "Eggs" then
			self:UpdateEggShop(data)
		elseif shopType == "Rebirth" then
			self:UpdateRebirthShop(data)
		elseif shopType == "Gamepasses" then
			self:UpdateGamepassShop(data)
		end
	end)

	-- Listen for currency updates
	remotes.DataUpdate.OnClientEvent:Connect(function(dataType, newValue)
		if dataType == "DestructionPoints" or dataType == "Gems" or dataType == "RebirthTokens" then
			-- Request full currency update
			self:RequestCurrencyUpdate()
		end
	end)

	-- Listen for purchase success/failure
	remotes.PurchaseResult.OnClientEvent:Connect(function(success, message, data)
		self:ShowNotification(success, message)

		if success then
			-- Refresh current shop
			self:SwitchTab(self.currentShop)
		end
	end)
end

function ShopUI:RequestCurrencyUpdate()
	-- This would be handled by the main UI controller
	-- For now, just a placeholder
end

function ShopUI:ShowNotification(success, message)
	-- Create notification popup
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(0, 300, 0, 60)
	notification.Position = UDim2.new(0.5, 0, 0, -70)
	notification.AnchorPoint = Vector2.new(0.5, 0)
	notification.BackgroundColor3 = success and COLORS.Success or COLORS.Error
	notification.BorderSizePixel = 0
	notification.Parent = self.gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notification

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextColor3 = COLORS.Text.Primary
	label.Text = message
	label.TextWrapped = true
	label.Parent = notification

	-- Animate in
	TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, 10)}):Play()

	-- Auto-hide after 3 seconds
	task.delay(3, function()
		local tween = TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, -70)})
		tween:Play()
		tween.Completed:Connect(function()
			notification:Destroy()
		end)
	end)
end

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

function ShopUI:FormatNumber(num)
	if num >= 1000000000 then
		return string.format("%.2fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.2fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.2fK", num / 1000)
	else
		return tostring(math.floor(num))
	end
end

-- ========================================
-- INITIALIZATION
-- ========================================

local shopUI = ShopUI.new()

-- Expose global functions for hotkey binding
_G.ShopUI = {
	Show = function() shopUI:Show() end,
	Hide = function() shopUI:Hide() end,
	Toggle = function() shopUI:Toggle() end,
}

return shopUI
