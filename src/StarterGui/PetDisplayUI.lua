--[[
	PetDisplayUI.lua
	Pet management and display UI for Homework Destroyer

	Features:
	- Shows all equipped pets with stats
	- Pet inventory browser
	- Equip/unequip pets
	- Pet fusion interface
	- Pet level display and XP bars
	- Rarity-based coloring
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local RemoteEvents = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvents"))
local remotes = RemoteEvents.Get()

local PetDisplayUI = {}
PetDisplayUI.__index = PetDisplayUI

-- Colors
local COLORS = {
	Background = Color3.fromRGB(20, 20, 25),
	Panel = Color3.fromRGB(30, 30, 40),
	Header = Color3.fromRGB(40, 40, 50),
	Button = Color3.fromRGB(50, 130, 230),
	ButtonHover = Color3.fromRGB(70, 150, 250),
	Success = Color3.fromRGB(40, 180, 80),
	Error = Color3.fromRGB(220, 50, 50),
	Rarity = {
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
	},
}

-- ========================================
-- CONSTRUCTOR
-- ========================================

function PetDisplayUI.new()
	local self = setmetatable({}, PetDisplayUI)

	self.equippedPets = {}
	self.ownedPets = {}
	self.maxPetSlots = 1

	self.gui = nil
	self.mainFrame = nil
	self.selectedPets = {} -- For fusion

	self:CreateUI()
	self:SetupEventListeners()
	self:RequestPetData()

	return self
end

-- ========================================
-- UI CREATION
-- ========================================

function PetDisplayUI:CreateUI()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PetDisplayUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 6
	screenGui.Parent = playerGui

	self.gui = screenGui

	-- Main Frame (Hidden by default)
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

	-- Equipped Pets Display (Top)
	self:CreateEquippedPetsDisplay(mainFrame)

	-- Pet Inventory (Bottom)
	self:CreatePetInventory(mainFrame)

	-- Close Button
	self:CreateCloseButton(mainFrame)

	-- Compact HUD for equipped pets (always visible)
	self:CreateCompactHUD()
end

function PetDisplayUI:CreateHeader(parent)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = COLORS.Header
	header.BorderSizePixel = 0
	header.Parent = parent

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header

	local bottomCover = Instance.new("Frame")
	bottomCover.Size = UDim2.new(1, 0, 0, 12)
	bottomCover.Position = UDim2.new(0, 0, 1, -12)
	bottomCover.BackgroundColor3 = COLORS.Header
	bottomCover.BorderSizePixel = 0
	bottomCover.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 300, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.TextColor3 = COLORS.Text.Primary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "🐾 PETS"
	title.Parent = header
end

function PetDisplayUI:CreateEquippedPetsDisplay(parent)
	local equippedFrame = Instance.new("Frame")
	equippedFrame.Name = "EquippedPets"
	equippedFrame.Size = UDim2.new(1, -40, 0, 150)
	equippedFrame.Position = UDim2.new(0, 20, 0, 70)
	equippedFrame.BackgroundColor3 = COLORS.Panel
	equippedFrame.BorderSizePixel = 0
	equippedFrame.Parent = parent

	local equippedCorner = Instance.new("UICorner")
	equippedCorner.CornerRadius = UDim.new(0, 8)
	equippedCorner.Parent = equippedFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 30)
	titleLabel.Position = UDim2.new(0, 10, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = COLORS.Text.Primary
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = "Equipped Pets"
	titleLabel.Parent = equippedFrame

	-- Pet slots container
	local slotsContainer = Instance.new("Frame")
	slotsContainer.Name = "SlotsContainer"
	slotsContainer.Size = UDim2.new(1, -20, 1, -45)
	slotsContainer.Position = UDim2.new(0, 10, 0, 40)
	slotsContainer.BackgroundTransparency = 1
	slotsContainer.Parent = equippedFrame

	local slotsLayout = Instance.new("UIListLayout")
	slotsLayout.FillDirection = Enum.FillDirection.Horizontal
	slotsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	slotsLayout.Padding = UDim.new(0, 10)
	slotsLayout.Parent = slotsContainer

	self.equippedSlotsContainer = slotsContainer

	-- Create pet slots (up to 6)
	for i = 1, 6 do
		self:CreatePetSlot(slotsContainer, i)
	end
end

function PetDisplayUI:CreatePetSlot(parent, slotNumber)
	local slotFrame = Instance.new("Frame")
	slotFrame.Name = "Slot" .. slotNumber
	slotFrame.Size = UDim2.new(0, 130, 1, 0)
	slotFrame.BackgroundColor3 = COLORS.Header
	slotFrame.BorderSizePixel = 0
	slotFrame.Visible = slotNumber <= self.maxPetSlots
	slotFrame.Parent = parent

	local slotCorner = Instance.new("UICorner")
	slotCorner.CornerRadius = UDim.new(0, 8)
	slotCorner.Parent = slotFrame

	-- Lock overlay for locked slots
	if slotNumber > self.maxPetSlots then
		local lockOverlay = Instance.new("Frame")
		lockOverlay.Name = "LockOverlay"
		lockOverlay.Size = UDim2.new(1, 0, 1, 0)
		lockOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		lockOverlay.BackgroundTransparency = 0.7
		lockOverlay.BorderSizePixel = 0
		lockOverlay.Parent = slotFrame

		local lockIcon = Instance.new("TextLabel")
		lockIcon.Size = UDim2.new(1, 0, 1, 0)
		lockIcon.BackgroundTransparency = 1
		lockIcon.Font = Enum.Font.GothamBold
		lockIcon.TextSize = 40
		lockIcon.TextColor3 = COLORS.Text.Secondary
		lockIcon.Text = "🔒"
		lockIcon.Parent = lockOverlay
	end

	-- Pet icon placeholder
	local petIcon = Instance.new("TextLabel")
	petIcon.Name = "PetIcon"
	petIcon.Size = UDim2.new(1, -10, 0, 50)
	petIcon.Position = UDim2.new(0, 5, 0, 5)
	petIcon.BackgroundTransparency = 1
	petIcon.Font = Enum.Font.GothamBold
	petIcon.TextSize = 40
	petIcon.TextColor3 = COLORS.Text.Secondary
	petIcon.Text = "+"
	petIcon.Parent = slotFrame

	-- Pet name
	local petName = Instance.new("TextLabel")
	petName.Name = "PetName"
	petName.Size = UDim2.new(1, -10, 0, 20)
	petName.Position = UDim2.new(0, 5, 0, 55)
	petName.BackgroundTransparency = 1
	petName.Font = Enum.Font.GothamBold
	petName.TextSize = 12
	petName.TextColor3 = COLORS.Text.Primary
	petName.Text = "Empty"
	petName.TextTruncate = Enum.TextTruncate.AtEnd
	petName.Parent = slotFrame

	-- Pet level
	local petLevel = Instance.new("TextLabel")
	petLevel.Name = "PetLevel"
	petLevel.Size = UDim2.new(1, -10, 0, 15)
	petLevel.Position = UDim2.new(0, 5, 0, 75)
	petLevel.BackgroundTransparency = 1
	petLevel.Font = Enum.Font.Gotham
	petLevel.TextSize = 10
	petLevel.TextColor3 = COLORS.Text.Secondary
	petLevel.Text = ""
	petLevel.Parent = slotFrame

	return slotFrame
end

function PetDisplayUI:CreatePetInventory(parent)
	local inventoryFrame = Instance.new("Frame")
	inventoryFrame.Name = "PetInventory"
	inventoryFrame.Size = UDim2.new(1, -40, 1, -250)
	inventoryFrame.Position = UDim2.new(0, 20, 0, 230)
	inventoryFrame.BackgroundColor3 = COLORS.Panel
	inventoryFrame.BorderSizePixel = 0
	inventoryFrame.Parent = parent

	local inventoryCorner = Instance.new("UICorner")
	inventoryCorner.CornerRadius = UDim.new(0, 8)
	inventoryCorner.Parent = inventoryFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 30)
	titleLabel.Position = UDim2.new(0, 10, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = COLORS.Text.Primary
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = "Pet Inventory"
	titleLabel.Parent = inventoryFrame

	-- Fusion button
	local fusionButton = Instance.new("TextButton")
	fusionButton.Name = "FusionButton"
	fusionButton.Size = UDim2.new(0, 120, 0, 30)
	fusionButton.Position = UDim2.new(1, -130, 0, 5)
	fusionButton.BackgroundColor3 = COLORS.Button
	fusionButton.BorderSizePixel = 0
	fusionButton.Font = Enum.Font.GothamBold
	fusionButton.TextSize = 12
	fusionButton.TextColor3 = COLORS.Text.Primary
	fusionButton.Text = "Fuse Pets (0/3)"
	fusionButton.Parent = inventoryFrame

	local fusionCorner = Instance.new("UICorner")
	fusionCorner.CornerRadius = UDim.new(0, 6)
	fusionCorner.Parent = fusionButton

	self.fusionButton = fusionButton

	fusionButton.MouseButton1Click:Connect(function()
		self:AttemptFusion()
	end)

	-- Scroll frame for pets
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "PetScroll"
	scrollFrame.Size = UDim2.new(1, -20, 1, -50)
	scrollFrame.Position = UDim2.new(0, 10, 0, 40)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.ScrollBarImageColor3 = COLORS.Button
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.Parent = inventoryFrame

	local scrollLayout = Instance.new("UIGridLayout")
	scrollLayout.CellSize = UDim2.new(0, 150, 0, 180)
	scrollLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
	scrollLayout.Parent = scrollFrame

	self.petScrollFrame = scrollFrame
end

function PetDisplayUI:CreatePetCard(petData, index)
	local cardFrame = Instance.new("Frame")
	cardFrame.Name = "Pet_" .. (petData.ID or index)
	cardFrame.Size = UDim2.new(0, 150, 0, 180)
	cardFrame.BackgroundColor3 = COLORS.Header
	cardFrame.BorderSizePixel = 0
	cardFrame.LayoutOrder = index
	cardFrame.Parent = self.petScrollFrame

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = cardFrame

	-- Rarity border
	local rarityColor = COLORS.Rarity[petData.Rarity] or COLORS.Rarity.Common
	local rarityStroke = Instance.new("UIStroke")
	rarityStroke.Color = rarityColor
	rarityStroke.Thickness = 3
	rarityStroke.Parent = cardFrame

	-- Pet icon
	local petIcon = Instance.new("TextLabel")
	petIcon.Size = UDim2.new(0, 80, 0, 80)
	petIcon.Position = UDim2.new(0.5, 0, 0, 10)
	petIcon.AnchorPoint = Vector2.new(0.5, 0)
	petIcon.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	petIcon.Font = Enum.Font.GothamBold
	petIcon.TextSize = 50
	petIcon.TextColor3 = rarityColor
	petIcon.Text = "🐾"
	petIcon.Parent = cardFrame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = petIcon

	-- Pet name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 20)
	nameLabel.Position = UDim2.new(0, 5, 0, 95)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 12
	nameLabel.TextColor3 = rarityColor
	nameLabel.Text = petData.Name or "Unknown Pet"
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = cardFrame

	-- Pet level
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(1, -10, 0, 15)
	levelLabel.Position = UDim2.new(0, 5, 0, 115)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextSize = 10
	levelLabel.TextColor3 = COLORS.Text.Secondary
	levelLabel.Text = string.format("Level %d", petData.Level or 1)
	levelLabel.Parent = cardFrame

	-- Rarity label
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -10, 0, 15)
	rarityLabel.Position = UDim2.new(0, 5, 0, 130)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.Gotham
	rarityLabel.TextSize = 10
	rarityLabel.TextColor3 = rarityColor
	rarityLabel.Text = petData.Rarity or "Common"
	rarityLabel.Parent = cardFrame

	-- Equip/Select button
	local actionButton = Instance.new("TextButton")
	actionButton.Size = UDim2.new(1, -20, 0, 25)
	actionButton.Position = UDim2.new(0, 10, 1, -35)
	actionButton.BackgroundColor3 = COLORS.Button
	actionButton.BorderSizePixel = 0
	actionButton.Font = Enum.Font.GothamBold
	actionButton.TextSize = 11
	actionButton.TextColor3 = COLORS.Text.Primary
	actionButton.Text = petData.IsEquipped and "Unequip" or "Equip"
	actionButton.Parent = cardFrame

	local actionCorner = Instance.new("UICorner")
	actionCorner.CornerRadius = UDim.new(0, 6)
	actionCorner.Parent = actionButton

	actionButton.MouseButton1Click:Connect(function()
		if petData.IsEquipped then
			self:UnequipPet(petData.ID)
		else
			self:EquipPet(petData.ID)
		end
	end)

	return cardFrame
end

function PetDisplayUI:CreateCloseButton(parent)
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
end

function PetDisplayUI:CreateCompactHUD()
	-- Small always-visible HUD showing equipped pets
	local compactHUD = Instance.new("Frame")
	compactHUD.Name = "PetCompactHUD"
	compactHUD.Size = UDim2.new(0, 60, 0, 0)
	compactHUD.Position = UDim2.new(0, 10, 1, -10)
	compactHUD.AnchorPoint = Vector2.new(0, 1)
	compactHUD.BackgroundTransparency = 1
	compactHUD.AutomaticSize = Enum.AutomaticSize.Y
	compactHUD.Parent = self.gui

	local compactLayout = Instance.new("UIListLayout")
	compactLayout.SortOrder = Enum.SortOrder.LayoutOrder
	compactLayout.Padding = UDim.new(0, 5)
	compactLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	compactLayout.Parent = compactHUD

	self.compactHUD = compactHUD
end

-- ========================================
-- PET FUNCTIONS
-- ========================================

function PetDisplayUI:EquipPet(petID)
	if remotes.EquipPet then
		-- Find next available slot
		local slot = #self.equippedPets + 1
		remotes.EquipPet:FireServer(petID, slot)
	end
end

function PetDisplayUI:UnequipPet(petID)
	if remotes.EquipPet then
		remotes.EquipPet:FireServer(petID, 0) -- 0 = unequip
	end
end

function PetDisplayUI:AttemptFusion()
	if #self.selectedPets < 3 then
		return
	end

	if remotes.FusePets then
		remotes.FusePets:FireServer(self.selectedPets[1], self.selectedPets[2], self.selectedPets[3])
		self.selectedPets = {}
		self:UpdateFusionButton()
	end
end

function PetDisplayUI:UpdateFusionButton()
	if self.fusionButton then
		self.fusionButton.Text = string.format("Fuse Pets (%d/3)", #self.selectedPets)
	end
end

function PetDisplayUI:LoadPetData(petData)
	-- Clear existing pet cards
	for _, child in ipairs(self.petScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Create pet cards
	if petData.Owned then
		for i, pet in ipairs(petData.Owned) do
			self:CreatePetCard(pet, i)
		end
	end

	-- Update equipped slots
	self.equippedPets = petData.Equipped or {}
	self.maxPetSlots = petData.MaxSlots or 1

	self:UpdateEquippedSlots()
end

function PetDisplayUI:UpdateEquippedSlots()
	for i = 1, 6 do
		local slot = self.equippedSlotsContainer:FindFirstChild("Slot" .. i)
		if slot then
			slot.Visible = i <= self.maxPetSlots

			local pet = self.equippedPets[i]
			if pet then
				slot.PetName.Text = pet.Name
				slot.PetLevel.Text = string.format("Lv. %d", pet.Level or 1)
				slot.PetIcon.Text = "🐾"
			else
				slot.PetName.Text = "Empty"
				slot.PetLevel.Text = ""
				slot.PetIcon.Text = "+"
			end
		end
	end
end

-- ========================================
-- UI CONTROL
-- ========================================

function PetDisplayUI:Show()
	self.mainFrame.Visible = true
	self.mainFrame.Position = UDim2.new(0.5, 0, 1.5, 0)

	TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()

	self:RequestPetData()
end

function PetDisplayUI:Hide()
	local tween = TweenService:Create(self.mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	})

	tween:Play()
	tween.Completed:Connect(function()
		self.mainFrame.Visible = false
	end)
end

function PetDisplayUI:Toggle()
	if self.mainFrame.Visible then
		self:Hide()
	else
		self:Show()
	end
end

-- ========================================
-- EVENT LISTENERS
-- ========================================

function PetDisplayUI:SetupEventListeners()
	-- Listen for full data sync
	if remotes.FullDataSync then
		remotes.FullDataSync.OnClientEvent:Connect(function(playerData)
			if playerData and playerData.Pets then
				self:LoadPetData(playerData.Pets)
			end
		end)
	end

	-- Hotkey (P key)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.P then
			self:Toggle()
		end
	end)
end

function PetDisplayUI:RequestPetData()
	-- Request full data sync
	if remotes.RequestDataSync then
		remotes.RequestDataSync:FireServer()
	end
end

-- ========================================
-- INITIALIZATION
-- ========================================

local petDisplayUI = PetDisplayUI.new()

-- Expose global API
_G.PetDisplayUI = {
	Show = function() petDisplayUI:Show() end,
	Hide = function() petDisplayUI:Hide() end,
	Toggle = function() petDisplayUI:Toggle() end,
}

print("[PetDisplayUI] Initialized successfully - Press P to open pets")

return petDisplayUI
