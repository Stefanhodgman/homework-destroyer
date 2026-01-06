--[[
	MainUIController.lua
	Central UI controller for Homework Destroyer

	Features:
	- Manages all UI systems (HUD, Shop, Upgrades, Settings, Pets)
	- Handles keyboard shortcuts and hotkeys
	- Coordinates data sync across all UI elements
	- Mobile-friendly touch controls
	- Centralized notification system
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local RemoteEvents = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvents"))
local remotes = RemoteEvents.Get()

local MainUIController = {}
MainUIController.__index = MainUIController

-- UI System References
local statsHUD
local shopUI
local upgradeUI
local settingsUI

-- Notification System
local NOTIFICATION_COLORS = {
	Success = Color3.fromRGB(40, 180, 80),
	Error = Color3.fromRGB(220, 50, 50),
	Info = Color3.fromRGB(50, 130, 230),
	Warning = Color3.fromRGB(255, 193, 7),
	LevelUp = Color3.fromRGB(255, 215, 0),
	Achievement = Color3.fromRGB(138, 43, 226),
}

-- ========================================
-- CONSTRUCTOR
-- ========================================

function MainUIController.new()
	local self = setmetatable({}, MainUIController)

	-- Player data cache
	self.playerData = nil

	-- UI state
	self.currentOpenUI = nil
	self.notificationQueue = {}
	self.isProcessingNotification = false

	-- Mobile controls
	self.isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	self:InitializeUI()
	self:SetupHotkeys()
	self:SetupEventListeners()
	self:CreateNotificationSystem()
	self:CreateMobileControls()
	self:RequestInitialData()

	return self
end

-- ========================================
-- UI INITIALIZATION
-- ========================================

function MainUIController:InitializeUI()
	-- Load all UI systems
	local success, err

	-- Stats HUD
	success, statsHUD = pcall(function()
		return require(script.Parent:WaitForChild("StatsHUD"))
	end)
	if not success then
		warn("[MainUIController] Failed to load StatsHUD:", err)
	end

	-- Shop UI (use improved version if available)
	success, shopUI = pcall(function()
		return require(script.Parent:FindFirstChild("ImprovedShopUI") or script.Parent:WaitForChild("ShopUI"))
	end)
	if not success then
		warn("[MainUIController] Failed to load ShopUI:", err)
	end

	-- Upgrade UI
	success, upgradeUI = pcall(function()
		return require(script.Parent:WaitForChild("UpgradeUI"))
	end)
	if not success then
		warn("[MainUIController] Failed to load UpgradeUI:", err)
	end

	-- Settings UI
	success, settingsUI = pcall(function()
		return require(script.Parent:WaitForChild("SettingsUI"))
	end)
	if not success then
		warn("[MainUIController] Failed to load SettingsUI:", err)
	end

	print("[MainUIController] UI systems initialized")
end

-- ========================================
-- HOTKEY SYSTEM
-- ========================================

function MainUIController:SetupHotkeys()
	-- Keyboard shortcuts
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Close any open UI with ESC
		if input.KeyCode == Enum.KeyCode.Escape then
			if self.currentOpenUI then
				self:CloseCurrentUI()
			else
				-- Open settings if nothing is open
				self:ToggleSettings()
			end

		-- Shop (S key)
		elseif input.KeyCode == Enum.KeyCode.S then
			self:ToggleShop()

		-- Upgrades (U key)
		elseif input.KeyCode == Enum.KeyCode.U then
			self:ToggleUpgrades()

		-- Stats HUD toggle (H key)
		elseif input.KeyCode == Enum.KeyCode.H then
			if statsHUD then
				statsHUD:Toggle()
			end

		-- Settings (F1 or Backquote)
		elseif input.KeyCode == Enum.KeyCode.F1 or input.KeyCode == Enum.KeyCode.Backquote then
			self:ToggleSettings()
		end
	end)

	print("[MainUIController] Hotkeys configured: S=Shop, U=Upgrades, H=HUD, ESC/F1=Settings")
end

-- ========================================
-- UI CONTROL FUNCTIONS
-- ========================================

function MainUIController:ToggleShop()
	if _G.ImprovedShopUI then
		_G.ImprovedShopUI.Toggle()
		self.currentOpenUI = _G.ImprovedShopUI
	elseif _G.ShopUI then
		_G.ShopUI.Toggle()
		self.currentOpenUI = _G.ShopUI
	end
end

function MainUIController:ToggleUpgrades()
	if upgradeUI and upgradeUI.ToggleUI then
		upgradeUI.ToggleUI()
		self.currentOpenUI = upgradeUI
	end
end

function MainUIController:ToggleSettings()
	if _G.SettingsUI then
		_G.SettingsUI.Toggle()
		self.currentOpenUI = _G.SettingsUI
	end
end

function MainUIController:CloseCurrentUI()
	if self.currentOpenUI then
		if self.currentOpenUI.Hide then
			self.currentOpenUI:Hide()
		end
		self.currentOpenUI = nil
	end
end

-- ========================================
-- EVENT LISTENERS
-- ========================================

function MainUIController:SetupEventListeners()
	-- Listen for full data sync
	if remotes.FullDataSync then
		remotes.FullDataSync.OnClientEvent:Connect(function(playerData)
			self:OnDataSync(playerData)
		end)
	end

	-- Listen for individual data updates
	if remotes.DataUpdate then
		remotes.DataUpdate.OnClientEvent:Connect(function(dataType, newValue, extraData)
			self:OnDataUpdate(dataType, newValue, extraData)
		end)
	end

	-- Listen for notifications
	if remotes.ShowNotification then
		remotes.ShowNotification.OnClientEvent:Connect(function(notificationType, title, message, duration)
			self:ShowNotification(notificationType, title, message, duration)
		end)
	end

	-- Listen for achievement unlocks
	if remotes.UnlockAchievement then
		remotes.UnlockAchievement.OnClientEvent:Connect(function(achievementID, rewardData)
			self:OnAchievementUnlocked(achievementID, rewardData)
		end)
	end

	print("[MainUIController] Event listeners configured")
end

-- ========================================
-- DATA SYNC
-- ========================================

function MainUIController:RequestInitialData()
	-- Request full data sync from server
	if remotes.RequestDataSync then
		remotes.RequestDataSync:FireServer()
	end
end

function MainUIController:OnDataSync(playerData)
	self.playerData = playerData

	-- Update all UI systems
	if statsHUD then
		statsHUD:UpdateAllStats(playerData)
	end

	print("[MainUIController] Data synced successfully")
end

function MainUIController:OnDataUpdate(dataType, newValue, extraData)
	-- Update cached player data
	if self.playerData then
		self.playerData[dataType] = newValue
	end

	-- Special handling for certain updates
	if dataType == "Level" and newValue > 1 then
		-- Level up notification
		self:ShowNotification("LevelUp", "LEVEL UP!", string.format("You reached Level %d!", newValue), 3)
	end
end

function MainUIController:OnAchievementUnlocked(achievementID, rewardData)
	-- Show achievement notification
	local achievementName = achievementID:gsub("([A-Z])", " %1"):gsub("^%s+", "")
	self:ShowNotification("Achievement", "ACHIEVEMENT UNLOCKED!", achievementName, 5)
end

-- ========================================
-- NOTIFICATION SYSTEM
-- ========================================

function MainUIController:CreateNotificationSystem()
	-- Create notification container
	local notificationContainer = Instance.new("Frame")
	notificationContainer.Name = "NotificationContainer"
	notificationContainer.Size = UDim2.new(0, 400, 0, 0)
	notificationContainer.Position = UDim2.new(0.5, -200, 0, 20)
	notificationContainer.BackgroundTransparency = 1
	notificationContainer.Parent = playerGui:WaitForChild("StatsHUD") or playerGui

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = notificationContainer

	self.notificationContainer = notificationContainer
end

function MainUIController:ShowNotification(notificationType, title, message, duration)
	duration = duration or 3

	-- Create notification frame
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(0, 380, 0, 0)
	notification.BackgroundColor3 = NOTIFICATION_COLORS[notificationType] or NOTIFICATION_COLORS.Info
	notification.BorderSizePixel = 0
	notification.AutomaticSize = Enum.AutomaticSize.Y
	notification.Parent = self.notificationContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notification

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0.7
	stroke.Parent = notification

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.Parent = notification

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 5)
	layout.Parent = notification

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 25)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Text = title
	titleLabel.LayoutOrder = 1
	titleLabel.Parent = notification

	-- Message
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, 0, 0, 0)
	messageLabel.AutomaticSize = Enum.AutomaticSize.Y
	messageLabel.BackgroundTransparency = 1
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextSize = 14
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.Text = message
	messageLabel.TextWrapped = true
	messageLabel.LayoutOrder = 2
	messageLabel.Parent = notification

	-- Animate in
	notification.Position = UDim2.new(0, -400, 0, 0)
	TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()

	-- Auto-hide
	task.delay(duration, function()
		local tween = TweenService:Create(notification, TweenInfo.new(0.3), {
			Position = UDim2.new(0, -400, 0, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			notification:Destroy()
		end)
	end)
end

-- ========================================
-- MOBILE CONTROLS
-- ========================================

function MainUIController:CreateMobileControls()
	if not self.isMobile then return end

	-- Create mobile button container
	local mobileContainer = Instance.new("Frame")
	mobileContainer.Name = "MobileControls"
	mobileContainer.Size = UDim2.new(0, 80, 0, 300)
	mobileContainer.Position = UDim2.new(1, -90, 0.5, -150)
	mobileContainer.BackgroundTransparency = 1
	mobileContainer.Parent = playerGui:FindFirstChild("StatsHUD") or playerGui

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = mobileContainer

	-- Create mobile buttons
	self:CreateMobileButton(mobileContainer, "Shop", "🛒", 1, function() self:ToggleShop() end)
	self:CreateMobileButton(mobileContainer, "Upgrades", "⬆️", 2, function() self:ToggleUpgrades() end)
	self:CreateMobileButton(mobileContainer, "Settings", "⚙️", 3, function() self:ToggleSettings() end)

	print("[MainUIController] Mobile controls created")
end

function MainUIController:CreateMobileButton(parent, name, icon, order, callback)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0, 70, 0, 70)
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	button.BackgroundTransparency = 0.3
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 32
	button.Text = icon
	button.LayoutOrder = order
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 80)
	stroke.Thickness = 2
	stroke.Parent = button

	button.MouseButton1Click:Connect(callback)
end

-- ========================================
-- PUBLIC API
-- ========================================

function MainUIController:GetPlayerData()
	return self.playerData
end

function MainUIController:RefreshAllUI()
	self:RequestInitialData()
end

-- ========================================
-- INITIALIZATION
-- ========================================

local controller = MainUIController.new()

-- Expose global API
_G.MainUIController = {
	ShowNotification = function(type, title, message, duration)
		controller:ShowNotification(type, title, message, duration)
	end,
	GetPlayerData = function()
		return controller:GetPlayerData()
	end,
	RefreshUI = function()
		controller:RefreshAllUI()
	end,
}

print("[MainUIController] System initialized successfully")
print("==============================================")
print("HOMEWORK DESTROYER - UI CONTROLS")
print("==============================================")
print("S - Open Shop")
print("U - Open Upgrades")
print("H - Toggle Stats HUD")
print("ESC/F1 - Open Settings")
print("==============================================")

return controller
