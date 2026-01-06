--[[
	SettingsUI.lua
	Settings menu for Homework Destroyer

	Features:
	- Visual settings (damage numbers, particles, motion)
	- Audio settings (master, music, SFX volumes)
	- Gameplay settings (auto-equip, confirmations)
	- UI settings (compact mode, leaderboard)
	- Settings persistence via RemoteEvents
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local RemoteEvents = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvents"))
local remotes = RemoteEvents.Get()

local SettingsUI = {}
SettingsUI.__index = SettingsUI

-- Colors
local COLORS = {
	Background = Color3.fromRGB(20, 20, 25),
	Panel = Color3.fromRGB(30, 30, 40),
	Header = Color3.fromRGB(40, 40, 50),
	Button = Color3.fromRGB(50, 130, 230),
	ButtonHover = Color3.fromRGB(70, 150, 250),
	ToggleOn = Color3.fromRGB(76, 175, 80),
	ToggleOff = Color3.fromRGB(120, 120, 130),
	Text = {
		Primary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(180, 180, 180),
	},
}

-- ========================================
-- CONSTRUCTOR
-- ========================================

function SettingsUI.new()
	local self = setmetatable({}, SettingsUI)

	-- Current settings (defaults)
	self.settings = {
		-- Visual
		ShowDamageNumbers = true,
		ShowCritEffects = true,
		ShowParticles = true,
		ReducedMotion = false,

		-- Audio
		MasterVolume = 1.0,
		MusicVolume = 0.7,
		SFXVolume = 1.0,

		-- Gameplay
		AutoEquipBestTool = false,
		AutoEquipBestPet = false,
		ShowTutorials = true,
		ConfirmExpensivePurchases = true,

		-- UI
		CompactUI = false,
		ShowLeaderboard = true,
		ShowPlayerList = true,
	}

	self.gui = nil
	self.mainFrame = nil
	self.settingsControls = {}

	self:CreateUI()
	self:SetupEventListeners()
	self:RequestSettings()

	return self
end

-- ========================================
-- UI CREATION
-- ========================================

function SettingsUI:CreateUI()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SettingsUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 15
	screenGui.Parent = playerGui

	self.gui = screenGui

	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 600, 0, 500)
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

	-- Settings Categories
	self:CreateSettingsCategories(mainFrame)

	-- Close Button
	self:CreateCloseButton(mainFrame)
end

function SettingsUI:CreateHeader(parent)
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
	title.Text = "⚙️ SETTINGS"
	title.Parent = header
end

function SettingsUI:CreateSettingsCategories(parent)
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "SettingsScroll"
	scrollFrame.Size = UDim2.new(1, -40, 1, -100)
	scrollFrame.Position = UDim2.new(0, 20, 0, 70)
	scrollFrame.BackgroundColor3 = COLORS.Panel
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.ScrollBarImageColor3 = COLORS.Button
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.Parent = parent

	local scrollCorner = Instance.new("UICorner")
	scrollCorner.CornerRadius = UDim.new(0, 8)
	scrollCorner.Parent = scrollFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 15)
	padding.PaddingBottom = UDim.new(0, 15)
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.Parent = scrollFrame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 15)
	layout.Parent = scrollFrame

	-- Create categories
	self:CreateCategory(scrollFrame, "Visual Settings", {
		{Name = "ShowDamageNumbers", Label = "Show Damage Numbers", Type = "Toggle"},
		{Name = "ShowCritEffects", Label = "Show Critical Hit Effects", Type = "Toggle"},
		{Name = "ShowParticles", Label = "Show Particle Effects", Type = "Toggle"},
		{Name = "ReducedMotion", Label = "Reduced Motion", Type = "Toggle"},
	}, 1)

	self:CreateCategory(scrollFrame, "Audio Settings", {
		{Name = "MasterVolume", Label = "Master Volume", Type = "Slider"},
		{Name = "MusicVolume", Label = "Music Volume", Type = "Slider"},
		{Name = "SFXVolume", Label = "SFX Volume", Type = "Slider"},
	}, 2)

	self:CreateCategory(scrollFrame, "Gameplay Settings", {
		{Name = "AutoEquipBestTool", Label = "Auto-Equip Best Tool", Type = "Toggle"},
		{Name = "AutoEquipBestPet", Label = "Auto-Equip Best Pet", Type = "Toggle"},
		{Name = "ShowTutorials", Label = "Show Tutorial Hints", Type = "Toggle"},
		{Name = "ConfirmExpensivePurchases", Label = "Confirm Expensive Purchases (>1M DP)", Type = "Toggle"},
	}, 3)

	self:CreateCategory(scrollFrame, "UI Settings", {
		{Name = "CompactUI", Label = "Compact UI Mode", Type = "Toggle"},
		{Name = "ShowLeaderboard", Label = "Show Leaderboard", Type = "Toggle"},
		{Name = "ShowPlayerList", Label = "Show Player List", Type = "Toggle"},
	}, 4)
end

function SettingsUI:CreateCategory(parent, categoryName, settings, order)
	local categoryFrame = Instance.new("Frame")
	categoryFrame.Name = categoryName
	categoryFrame.Size = UDim2.new(1, 0, 0, 0)
	categoryFrame.AutomaticSize = Enum.AutomaticSize.Y
	categoryFrame.BackgroundColor3 = COLORS.Header
	categoryFrame.BorderSizePixel = 0
	categoryFrame.LayoutOrder = order
	categoryFrame.Parent = parent

	local categoryCorner = Instance.new("UICorner")
	categoryCorner.CornerRadius = UDim.new(0, 8)
	categoryCorner.Parent = categoryFrame

	local categoryPadding = Instance.new("UIPadding")
	categoryPadding.PaddingTop = UDim.new(0, 10)
	categoryPadding.PaddingBottom = UDim.new(0, 10)
	categoryPadding.PaddingLeft = UDim.new(0, 10)
	categoryPadding.PaddingRight = UDim.new(0, 10)
	categoryPadding.Parent = categoryFrame

	local categoryLayout = Instance.new("UIListLayout")
	categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	categoryLayout.Padding = UDim.new(0, 8)
	categoryLayout.Parent = categoryFrame

	-- Category Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 25)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = COLORS.Button
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = categoryName
	title.LayoutOrder = 0
	title.Parent = categoryFrame

	-- Create settings controls
	for i, settingData in ipairs(settings) do
		if settingData.Type == "Toggle" then
			self:CreateToggle(categoryFrame, settingData, i)
		elseif settingData.Type == "Slider" then
			self:CreateSlider(categoryFrame, settingData, i)
		end
	end
end

function SettingsUI:CreateToggle(parent, settingData, order)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = settingData.Name
	toggleFrame.Size = UDim2.new(1, 0, 0, 35)
	toggleFrame.BackgroundTransparency = 1
	toggleFrame.LayoutOrder = order
	toggleFrame.Parent = parent

	-- Label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = COLORS.Text.Primary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = settingData.Label
	label.Parent = toggleFrame

	-- Toggle Button
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Size = UDim2.new(0, 60, 0, 25)
	toggleButton.Position = UDim2.new(1, -60, 0.5, -12.5)
	toggleButton.BackgroundColor3 = self.settings[settingData.Name] and COLORS.ToggleOn or COLORS.ToggleOff
	toggleButton.BorderSizePixel = 0
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.TextSize = 12
	toggleButton.TextColor3 = COLORS.Text.Primary
	toggleButton.Text = self.settings[settingData.Name] and "ON" or "OFF"
	toggleButton.Parent = toggleFrame

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 6)
	toggleCorner.Parent = toggleButton

	self.settingsControls[settingData.Name] = toggleButton

	toggleButton.MouseButton1Click:Connect(function()
		self:ToggleSetting(settingData.Name)
	end)
end

function SettingsUI:CreateSlider(parent, settingData, order)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = settingData.Name
	sliderFrame.Size = UDim2.new(1, 0, 0, 50)
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.LayoutOrder = order
	sliderFrame.Parent = parent

	-- Label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 0, 25)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = COLORS.Text.Primary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = settingData.Label
	label.Parent = sliderFrame

	-- Value Label
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "ValueLabel"
	valueLabel.Size = UDim2.new(0, 50, 0, 25)
	valueLabel.Position = UDim2.new(1, -50, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 14
	valueLabel.TextColor3 = COLORS.Button
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Text = string.format("%.0f%%", self.settings[settingData.Name] * 100)
	valueLabel.Parent = sliderFrame

	-- Slider Background
	local sliderBg = Instance.new("Frame")
	sliderBg.Name = "SliderBg"
	sliderBg.Size = UDim2.new(1, 0, 0, 8)
	sliderBg.Position = UDim2.new(0, 0, 0, 30)
	sliderBg.BackgroundColor3 = COLORS.Panel
	sliderBg.BorderSizePixel = 0
	sliderBg.Parent = sliderFrame

	local sliderBgCorner = Instance.new("UICorner")
	sliderBgCorner.CornerRadius = UDim.new(0, 4)
	sliderBgCorner.Parent = sliderBg

	-- Slider Fill
	local sliderFill = Instance.new("Frame")
	sliderFill.Name = "SliderFill"
	sliderFill.Size = UDim2.new(self.settings[settingData.Name], 0, 1, 0)
	sliderFill.BackgroundColor3 = COLORS.Button
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderBg

	local sliderFillCorner = Instance.new("UICorner")
	sliderFillCorner.CornerRadius = UDim.new(0, 4)
	sliderFillCorner.Parent = sliderFill

	self.settingsControls[settingData.Name] = {Fill = sliderFill, ValueLabel = valueLabel}

	-- Slider interaction
	local dragging = false

	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			self:UpdateSlider(settingData.Name, sliderBg, input.Position.X)
		end
	end)

	sliderBg.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			self:UpdateSlider(settingData.Name, sliderBg, input.Position.X)
		end
	end)
end

function SettingsUI:CreateCloseButton(parent)
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 10)
	closeButton.BackgroundColor3 = COLORS.Button
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

-- ========================================
-- SETTINGS FUNCTIONS
-- ========================================

function SettingsUI:ToggleSetting(settingName)
	local newValue = not self.settings[settingName]
	self.settings[settingName] = newValue

	-- Update UI
	local control = self.settingsControls[settingName]
	if control and control:IsA("TextButton") then
		control.Text = newValue and "ON" or "OFF"
		control.BackgroundColor3 = newValue and COLORS.ToggleOn or COLORS.ToggleOff
	end

	-- Apply setting
	self:ApplySetting(settingName, newValue)

	-- Save to server
	self:SaveSetting(settingName, newValue)
end

function SettingsUI:UpdateSlider(settingName, sliderBg, mouseX)
	local relativeX = mouseX - sliderBg.AbsolutePosition.X
	local percentage = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)

	self.settings[settingName] = percentage

	-- Update UI
	local control = self.settingsControls[settingName]
	if control then
		control.Fill.Size = UDim2.new(percentage, 0, 1, 0)
		control.ValueLabel.Text = string.format("%.0f%%", percentage * 100)
	end

	-- Apply setting
	self:ApplySetting(settingName, percentage)

	-- Save to server (debounced)
	task.wait(0.1)
	self:SaveSetting(settingName, percentage)
end

function SettingsUI:ApplySetting(settingName, value)
	-- Apply settings locally
	if settingName == "MasterVolume" then
		SoundService.Volume = value
	elseif settingName == "MusicVolume" then
		-- Would adjust music sound group volume
	elseif settingName == "SFXVolume" then
		-- Would adjust SFX sound group volume
	elseif settingName == "ShowPlayerList" then
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, value)
	end

	-- Other settings would be handled by other UI systems
end

function SettingsUI:SaveSetting(settingName, value)
	-- Save setting to server
	if remotes.UpdateSettings then
		remotes.UpdateSettings:FireServer(settingName, value)
	end
end

-- ========================================
-- UI CONTROL
-- ========================================

function SettingsUI:Show()
	self.mainFrame.Visible = true
	self.mainFrame.Position = UDim2.new(0.5, 0, 1.5, 0)

	TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()
end

function SettingsUI:Hide()
	local tween = TweenService:Create(self.mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	})

	tween:Play()
	tween.Completed:Connect(function()
		self.mainFrame.Visible = false
	end)
end

function SettingsUI:Toggle()
	if self.mainFrame.Visible then
		self:Hide()
	else
		self:Show()
	end
end

-- ========================================
-- EVENT LISTENERS
-- ========================================

function SettingsUI:SetupEventListeners()
	-- Listen for full data sync (includes settings)
	if remotes.FullDataSync then
		remotes.FullDataSync.OnClientEvent:Connect(function(playerData)
			if playerData and playerData.Settings then
				self:LoadSettings(playerData.Settings)
			end
		end)
	end
end

function SettingsUI:RequestSettings()
	-- Request full data sync to get settings
	if remotes.RequestDataSync then
		remotes.RequestDataSync:FireServer()
	end
end

function SettingsUI:LoadSettings(settingsData)
	for settingName, value in pairs(settingsData) do
		if self.settings[settingName] ~= nil then
			self.settings[settingName] = value

			-- Update UI controls
			local control = self.settingsControls[settingName]
			if control then
				if control:IsA("TextButton") then
					-- Toggle
					control.Text = value and "ON" or "OFF"
					control.BackgroundColor3 = value and COLORS.ToggleOn or COLORS.ToggleOff
				elseif type(control) == "table" then
					-- Slider
					control.Fill.Size = UDim2.new(value, 0, 1, 0)
					control.ValueLabel.Text = string.format("%.0f%%", value * 100)
				end
			end

			-- Apply setting
			self:ApplySetting(settingName, value)
		end
	end
end

-- ========================================
-- INITIALIZATION
-- ========================================

local settingsUI = SettingsUI.new()

-- Expose global API
_G.SettingsUI = {
	Show = function() settingsUI:Show() end,
	Hide = function() settingsUI:Hide() end,
	Toggle = function() settingsUI:Toggle() end,
}

print("[SettingsUI] Initialized successfully - Press ESC to open settings")

return settingsUI
