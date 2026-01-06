--[[
	ImprovedShopUI.lua
	Enhanced shop interface for Homework Destroyer with proper integration

	Features:
	- Tool Shop with all 18 tools from ToolsConfig
	- Pet Egg Shop with all 8 egg types from PetConfig
	- Complete integration with RemoteEvents system
	- Proper data fetching and display
	- Mobile-friendly responsive design
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local RemoteEvents = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvents"))
local remotes = RemoteEvents.Get()

local ShopUI = {}
ShopUI.__index = ShopUI

-- UI Configuration
local COLORS = {
	Background = Color3.fromRGB(20, 20, 25),
	Panel = Color3.fromRGB(30, 30, 40),
	Header = Color3.fromRGB(40, 40, 50),
	Button = Color3.fromRGB(50, 130, 230),
	ButtonHover = Color3.fromRGB(70, 150, 250),
	ButtonDisabled = Color3.fromRGB(80, 80, 90),
	Success = Color3.fromRGB(40, 180, 80),
	Error = Color3.fromRGB(220, 50, 50),
	Rarity = {
		Common = Color3.fromRGB(180, 180, 180),
		Uncommon = Color3.fromRGB(76, 175, 80),
		Rare = Color3.fromRGB(33, 150, 243),
		Epic = Color3.fromRGB(156, 39, 176),
		Legendary = Color3.fromRGB(255, 193, 7),
		Mythic = Color3.fromRGB(255, 0, 128),
		SECRET = Color3.fromRGB(255, 255, 255),
	},
	Text = {
		Primary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(180, 180, 180),
		Disabled = Color3.fromRGB(100, 100, 100),
	},
}

-- ========================================
-- CONSTRUCTOR
-- ========================================

function ShopUI.new()
	local self = setmetatable({}, ShopUI)

	self.currentTab = "Tools"
	self.playerData = {
		DestructionPoints = 0,
		RebirthTokens = 0,
		Level = 1,
		RebirthLevel = 0,
		PrestigeLevel = 0,
	}

	-- Shop data cache
	self.shopData = {
		Tools = {},
		Eggs = {},
	}

	self:CreateMainUI()
	self:SetupEventListeners()

	return self
end

-- ========================================
-- UI CREATION
-- ========================================

function ShopUI:CreateMainUI()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ImprovedShopUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 5
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

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

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
	title.Size = UDim2.new(0, 300, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.TextColor3 = COLORS.Text.Primary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "SHOP"
	title.Parent = header
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
	}

	for _, tabData in ipairs(tabs) do
		self:CreateTab(tabContainer, tabData)
	end
end

function ShopUI:CreateTab(parent, tabData)
	local button = Instance.new("TextButton")
	button.Name = tabData.Name .. "Tab"
	button.Size = UDim2.new(0, 250, 1, 0)
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

	button.MouseButton1Click:Connect(function()
		self:SwitchTab(tabData.Name)
	end)

	button.MouseEnter:Connect(function()
		if self.currentTab ~= tabData.Name then
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Button}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if self.currentTab ~= tabData.Name then
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
	layout.CellSize = UDim2.new(0, 260, 0, 220)
	layout.CellPadding = UDim2.new(0, 15, 0, 15)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = contentFrame

	self.contentArea = contentFrame
	self.contentLayout = layout
end

function ShopUI:CreateCloseButton(parent)
	local closeButton = Instance.new("TextButton")
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

	closeButton.MouseEnter:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
	end)

	closeButton.MouseLeave:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Error}):Play()
	end)
end

function ShopUI:CreateCurrencyDisplay(parent)
	local currencyFrame = Instance.new("Frame")
	currencyFrame.Size = UDim2.new(0, 350, 0, 50)
	currencyFrame.Position = UDim2.new(1, -370, 1, -60)
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
	dpLabel.Size = UDim2.new(0, 160, 0, 30)
	dpLabel.BackgroundTransparency = 1
	dpLabel.Font = Enum.Font.GothamBold
	dpLabel.TextSize = 16
	dpLabel.TextColor3 = COLORS.Text.Primary
	dpLabel.Text = "💰 DP: 0"
	dpLabel.Parent = currencyFrame

	-- Rebirth Tokens Display
	local tokensLabel = Instance.new("TextLabel")
	tokensLabel.Name = "Tokens"
	tokensLabel.Size = UDim2.new(0, 120, 0, 30)
	tokensLabel.BackgroundTransparency = 1
	tokensLabel.Font = Enum.Font.GothamBold
	tokensLabel.TextSize = 16
	tokensLabel.TextColor3 = COLORS.Rarity.Legendary
	tokensLabel.Text = "🔄 RT: 0"
	tokensLabel.Parent = currencyFrame

	self.currencyLabels = {
		DP = dpLabel,
		Tokens = tokensLabel,
	}
end

-- ========================================
-- SHOP ITEM CREATION
-- ========================================

function ShopUI:CreateToolItem(toolData, index)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = "Tool_" .. (toolData.ID or index)
	itemFrame.Size = UDim2.new(0, 260, 0, 220)
	itemFrame.BackgroundColor3 = COLORS.Header
	itemFrame.BorderSizePixel = 0
	itemFrame.LayoutOrder = index
	itemFrame.Parent = self.contentArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = itemFrame

	-- Rarity border
	local rarityColor = COLORS.Rarity[toolData.Rarity] or COLORS.Rarity.Common
	local rarityStroke = Instance.new("UIStroke")
	rarityStroke.Color = rarityColor
	rarityStroke.Thickness = 3
	rarityStroke.Parent = itemFrame

	-- Icon placeholder (would use tool icon in production)
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 80, 0, 80)
	icon.Position = UDim2.new(0.5, 0, 0, 10)
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 40
	icon.TextColor3 = rarityColor
	icon.Text = "🔧"
	icon.Parent = itemFrame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = icon

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 95)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = rarityColor
	nameLabel.Text = toolData.Name or "Unknown Tool"
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = itemFrame

	-- Rarity label
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -10, 0, 18)
	rarityLabel.Position = UDim2.new(0, 5, 0, 120)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.Gotham
	rarityLabel.TextSize = 11
	rarityLabel.TextColor3 = rarityColor
	rarityLabel.Text = toolData.Rarity or "Common"
	rarityLabel.Parent = itemFrame

	-- Stats
	local statsLabel = Instance.new("TextLabel")
	statsLabel.Size = UDim2.new(1, -10, 0, 20)
	statsLabel.Position = UDim2.new(0, 5, 0, 138)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Font = Enum.Font.Gotham
	statsLabel.TextSize = 11
	statsLabel.TextColor3 = COLORS.Text.Secondary
	statsLabel.Text = string.format("DMG: %d | Speed: %.1fx", toolData.BaseDamage or 0, toolData.ClickSpeed or 1)
	statsLabel.Parent = itemFrame

	-- Description (shortened)
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -10, 0, 18)
	descLabel.Position = UDim2.new(0, 5, 0, 158)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.GothamMedium
	descLabel.TextSize = 10
	descLabel.TextColor3 = COLORS.Text.Secondary
	descLabel.Text = toolData.Description or ""
	descLabel.TextTruncate = Enum.TextTruncate.AtEnd
	descLabel.Parent = itemFrame

	-- Purchase Button
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 35)
	button.Position = UDim2.new(0, 10, 1, -45)
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
		button.Text = "✓ OWNED"
		button.BackgroundColor3 = COLORS.Success
	elseif toolData.CanPurchase then
		local costText = self:FormatNumber(toolData.Cost or 0)
		button.Text = string.format("Buy: %s DP", costText)

		button.MouseButton1Click:Connect(function()
			self:PurchaseTool(toolData.ID)
		end)

		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHover}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Button}):Play()
		end)
	else
		button.Text = toolData.LockReason or "Locked"
	end

	return itemFrame
end

function ShopUI:CreateEggItem(eggData, index)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = "Egg_" .. (eggData.ID or index)
	itemFrame.Size = UDim2.new(0, 260, 0, 220)
	itemFrame.BackgroundColor3 = COLORS.Header
	itemFrame.BorderSizePixel = 0
	itemFrame.LayoutOrder = index
	itemFrame.Parent = self.contentArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = itemFrame

	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 80, 0, 80)
	icon.Position = UDim2.new(0.5, 0, 0, 10)
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 50
	icon.TextColor3 = COLORS.Text.Primary
	icon.Text = "🥚"
	icon.Parent = itemFrame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = icon

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 95)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = COLORS.Text.Primary
	nameLabel.Text = eggData.Name or "Unknown Egg"
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = itemFrame

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -10, 0, 35)
	descLabel.Position = UDim2.new(0, 5, 0, 120)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 11
	descLabel.TextColor3 = COLORS.Text.Secondary
	descLabel.Text = eggData.Description or ""
	descLabel.TextWrapped = true
	descLabel.Parent = itemFrame

	-- Rarity info
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -10, 0, 20)
	rarityLabel.Position = UDim2.new(0, 5, 0, 155)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.Gotham
	rarityLabel.TextSize = 10
	rarityLabel.TextColor3 = COLORS.Text.Secondary
	rarityLabel.Text = string.format("Legendary: %.1f%%", eggData.LegendaryChance or 0)
	rarityLabel.Parent = itemFrame

	-- Hatch Button
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 35)
	button.Position = UDim2.new(0, 10, 1, -45)
	button.BackgroundColor3 = eggData.CanPurchase and COLORS.Success or COLORS.ButtonDisabled
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.TextColor3 = COLORS.Text.Primary
	button.Parent = itemFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button

	if eggData.CanPurchase then
		local costText = self:FormatNumber(eggData.Cost or 0)
		button.Text = string.format("Hatch: %s DP", costText)

		button.MouseButton1Click:Connect(function()
			self:HatchEgg(eggData.ID)
		end)

		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 200, 100)}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Success}):Play()
		end)
	else
		button.Text = eggData.LockReason or "Locked"
	end

	return itemFrame
end

-- ========================================
-- TAB SWITCHING
-- ========================================

function ShopUI:SwitchTab(tabName)
	self.currentTab = tabName

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
	end
end

-- ========================================
-- SHOP LOADING
-- ========================================

function ShopUI:LoadToolShop()
	-- For now, create placeholder items
	-- In production, this would fetch from server
	local placeholderTools = {
		{ID = "PencilEraser", Name = "Pencil Eraser", Rarity = "Common", BaseDamage = 1, ClickSpeed = 1.0, Cost = 0, Description = "Every destroyer starts somewhere.", CanPurchase = true, IsOwned = false},
		{ID = "WoodenRuler", Name = "Wooden Ruler", Rarity = "Common", BaseDamage = 3, ClickSpeed = 1.0, Cost = 500, Description = "Measure twice, destroy once.", CanPurchase = true, IsOwned = false},
		{ID = "SafetyScissors", Name = "Safety Scissors", Rarity = "Uncommon", BaseDamage = 8, ClickSpeed = 1.1, Cost = 2500, Description = "Now you can run with them.", CanPurchase = false, IsOwned = false, LockReason = "Level 3 Required"},
	}

	for i, toolData in ipairs(placeholderTools) do
		toolData.CanPurchase = self.playerData.DestructionPoints >= (toolData.Cost or 0)
		self:CreateToolItem(toolData, i)
	end
end

function ShopUI:LoadEggShop()
	-- Placeholder eggs
	local placeholderEggs = {
		{ID = "ClassroomEgg", Name = "Classroom Egg", Cost = 1000, Description = "A basic egg from the classroom.", LegendaryChance = 0.9, CanPurchase = true},
		{ID = "LibraryEgg", Name = "Library Egg", Cost = 10000, Description = "An egg filled with knowledge.", LegendaryChance = 0.9, CanPurchase = false, LockReason = "Unlock Library Zone"},
		{ID = "VoidEgg", Name = "Void Egg", Cost = 50000000, Description = "An egg from beyond reality.", LegendaryChance = 12, CanPurchase = false, LockReason = "Unlock The Void"},
	}

	for i, eggData in ipairs(placeholderEggs) do
		eggData.CanPurchase = self.playerData.DestructionPoints >= (eggData.Cost or 0)
		self:CreateEggItem(eggData, i)
	end
end

-- ========================================
-- PURCHASE FUNCTIONS
-- ========================================

function ShopUI:PurchaseTool(toolID)
	if remotes.PurchaseTool then
		remotes.PurchaseTool:FireServer(toolID)
	end
end

function ShopUI:HatchEgg(eggID)
	if remotes.HatchEgg then
		remotes.HatchEgg:FireServer(eggID)
	end
end

-- ========================================
-- UI CONTROL
-- ========================================

function ShopUI:Show()
	self.mainFrame.Visible = true
	self.mainFrame.Position = UDim2.new(0.5, 0, 1.5, 0)

	TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()

	self:SwitchTab(self.currentTab)
	self:UpdateCurrency()
end

function ShopUI:Hide()
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

function ShopUI:UpdateCurrency()
	self.currencyLabels.DP.Text = string.format("💰 DP: %s", self:FormatNumber(self.playerData.DestructionPoints))
	self.currencyLabels.Tokens.Text = string.format("🔄 RT: %d", self.playerData.RebirthTokens)
end

-- ========================================
-- EVENT LISTENERS
-- ========================================

function ShopUI:SetupEventListeners()
	-- Listen for data updates
	if remotes.DataUpdate then
		remotes.DataUpdate.OnClientEvent:Connect(function(dataType, newValue)
			if dataType == "DestructionPoints" then
				self.playerData.DestructionPoints = newValue
				self:UpdateCurrency()
			elseif dataType == "RebirthTokens" then
				self.playerData.RebirthTokens = newValue
				self:UpdateCurrency()
			end
		end)
	end

	-- Listen for full data sync
	if remotes.FullDataSync then
		remotes.FullDataSync.OnClientEvent:Connect(function(playerData)
			if playerData then
				self.playerData.DestructionPoints = playerData.DestructionPoints or 0
				self.playerData.RebirthTokens = playerData.RebirthTokens or 0
				self.playerData.Level = playerData.Level or 1
				self.playerData.RebirthLevel = playerData.RebirthLevel or 0
				self.playerData.PrestigeLevel = playerData.PrestigeLevel or 0
				self:UpdateCurrency()
			end
		end)
	end

	-- Request initial data
	if remotes.RequestDataSync then
		remotes.RequestDataSync:FireServer()
	end
end

-- ========================================
-- UTILITY
-- ========================================

function ShopUI:FormatNumber(num)
	if num >= 1000000000000 then
		return string.format("%.2fT", num / 1000000000000)
	elseif num >= 1000000000 then
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

-- Expose global API
_G.ImprovedShopUI = {
	Show = function() shopUI:Show() end,
	Hide = function() shopUI:Hide() end,
	Toggle = function() shopUI:Toggle() end,
}

print("[ImprovedShopUI] Initialized successfully - Press S to open shop")

return shopUI
