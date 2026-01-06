--[[
	AchievementNotification.lua

	Client-side achievement notification system for Homework Destroyer

	Responsibilities:
	- Display achievement unlock popups
	- Handle notification queue
	- Play achievement unlock animations and sounds
	- Create dynamic UI for achievement notifications

	Features:
	- Animated slide-in/slide-out notifications
	- Queued notifications (if multiple unlock at once)
	- Category-specific styling
	- Reward display
	- Sound effects and particle effects

	Author: Homework Destroyer Team
	Version: 1.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local AchievementNotification = {}

-- Local player reference
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote events
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local AchievementUnlockedEvent

-- Notification queue
local NotificationQueue = {}
local CurrentNotification = nil
local IsDisplaying = false

-- UI Configuration
local CONFIG = {
	-- Position and sizing
	NotificationSize = UDim2.new(0, 400, 0, 120),
	NotificationPosition = UDim2.new(1, -20, 0, 100), -- Top right, off-screen initially
	DisplayPosition = UDim2.new(1, -420, 0, 100), -- Slide in position

	-- Timing
	SlideInDuration = 0.5,
	DisplayDuration = 5.0, -- How long to show notification
	SlideOutDuration = 0.5,

	-- Animation easing
	EasingStyle = Enum.EasingStyle.Quint,
	EasingDirection = Enum.EasingDirection.Out,

	-- Colors by category
	CategoryColors = {
		Destruction = Color3.fromRGB(255, 75, 75), -- Red
		Boss = Color3.fromRGB(255, 165, 0), -- Orange
		Zone = Color3.fromRGB(100, 200, 255), -- Blue
		Rebirth = Color3.fromRGB(200, 100, 255), -- Purple
		Collection = Color3.fromRGB(255, 215, 0), -- Gold
		Special = Color3.fromRGB(0, 255, 127), -- Green
		Secret = Color3.fromRGB(255, 105, 180), -- Pink
		Meta = Color3.fromRGB(255, 255, 255), -- White (rainbow animated)
	},

	-- Sound IDs (replace with actual Roblox asset IDs)
	SoundIDs = {
		Achievement = "rbxassetid://0", -- Achievement unlock sound
		Rare = "rbxassetid://0", -- For Epic+ achievements
		Secret = "rbxassetid://0", -- For secret achievements
	},
}

-- ============================================================
-- INITIALIZATION
-- ============================================================

function AchievementNotification:Initialize()
	warn("[AchievementNotification] Initializing client-side achievement system...")

	-- Get or wait for achievement event
	AchievementUnlockedEvent = RemoteEventsFolder:WaitForChild("UnlockAchievement")

	-- Connect to achievement unlock event
	AchievementUnlockedEvent.OnClientEvent:Connect(function(achievementData)
		self:QueueNotification(achievementData)
	end)

	warn("[AchievementNotification] Achievement notification system ready")
end

-- ============================================================
-- NOTIFICATION QUEUE MANAGEMENT
-- ============================================================

-- Add notification to queue
function AchievementNotification:QueueNotification(achievementData)
	table.insert(NotificationQueue, achievementData)

	-- Start processing queue if not already displaying
	if not IsDisplaying then
		self:ProcessQueue()
	end
end

-- Process notification queue
function AchievementNotification:ProcessQueue()
	if #NotificationQueue == 0 then
		IsDisplaying = false
		return
	end

	IsDisplaying = true
	local achievementData = table.remove(NotificationQueue, 1)

	-- Display the notification
	self:DisplayNotification(achievementData)
end

-- ============================================================
-- NOTIFICATION DISPLAY
-- ============================================================

-- Create and display achievement notification
function AchievementNotification:DisplayNotification(achievementData)
	CurrentNotification = achievementData

	-- Create notification UI
	local notificationGui = self:CreateNotificationUI(achievementData)

	-- Play sound
	self:PlayAchievementSound(achievementData.Category)

	-- Animate slide in
	local slideInTween = self:CreateSlideTween(notificationGui.Container, CONFIG.DisplayPosition, CONFIG.SlideInDuration)
	slideInTween:Play()

	slideInTween.Completed:Wait()

	-- Wait for display duration
	wait(CONFIG.DisplayDuration)

	-- Animate slide out
	local slideOutTween = self:CreateSlideTween(notificationGui.Container, CONFIG.NotificationPosition, CONFIG.SlideOutDuration)
	slideOutTween:Play()

	slideOutTween.Completed:Wait()

	-- Cleanup
	notificationGui:Destroy()
	CurrentNotification = nil

	-- Process next in queue
	self:ProcessQueue()
end

-- ============================================================
-- UI CREATION
-- ============================================================

-- Create the notification UI elements
function AchievementNotification:CreateNotificationUI(achievementData)
	-- Create ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AchievementNotification"
	screenGui.DisplayOrder = 100
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Main container frame
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = CONFIG.NotificationSize
	container.Position = CONFIG.NotificationPosition
	container.AnchorPoint = Vector2.new(1, 0)
	container.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	container.BorderSizePixel = 0
	container.Parent = screenGui

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = container

	-- Add gradient background
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.fromRGB(40, 40, 45), Color3.fromRGB(25, 25, 30))
	gradient.Rotation = 90
	gradient.Parent = container

	-- Category accent bar (colored based on category)
	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.Size = UDim2.new(0, 6, 1, 0)
	accentBar.Position = UDim2.new(0, 0, 0, 0)
	accentBar.BackgroundColor3 = CONFIG.CategoryColors[achievementData.Category] or Color3.fromRGB(255, 255, 255)
	accentBar.BorderSizePixel = 0
	accentBar.Parent = container

	-- Accent bar corner
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(0, 12)
	accentCorner.Parent = accentBar

	-- Icon background
	local iconBg = Instance.new("Frame")
	iconBg.Name = "IconBackground"
	iconBg.Size = UDim2.new(0, 80, 0, 80)
	iconBg.Position = UDim2.new(0, 20, 0.5, 0)
	iconBg.AnchorPoint = Vector2.new(0, 0.5)
	iconBg.BackgroundColor3 = CONFIG.CategoryColors[achievementData.Category] or Color3.fromRGB(255, 255, 255)
	iconBg.BorderSizePixel = 0
	iconBg.Parent = container

	-- Icon background corner
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 10)
	iconCorner.Parent = iconBg

	-- Achievement icon (placeholder - would use actual icon)
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0.8, 0, 0.8, 0)
	icon.Position = UDim2.new(0.5, 0, 0.5, 0)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.BackgroundTransparency = 1
	icon.Image = achievementData.Icon or "rbxassetid://0"
	icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	icon.Parent = iconBg

	-- Text container
	local textContainer = Instance.new("Frame")
	textContainer.Name = "TextContainer"
	textContainer.Size = UDim2.new(0, 270, 1, -20)
	textContainer.Position = UDim2.new(0, 115, 0, 10)
	textContainer.BackgroundTransparency = 1
	textContainer.Parent = container

	-- "Achievement Unlocked!" label
	local unlockLabel = Instance.new("TextLabel")
	unlockLabel.Name = "UnlockLabel"
	unlockLabel.Size = UDim2.new(1, 0, 0, 20)
	unlockLabel.Position = UDim2.new(0, 0, 0, 0)
	unlockLabel.BackgroundTransparency = 1
	unlockLabel.Text = "ACHIEVEMENT UNLOCKED!"
	unlockLabel.TextColor3 = CONFIG.CategoryColors[achievementData.Category] or Color3.fromRGB(255, 255, 255)
	unlockLabel.TextSize = 12
	unlockLabel.Font = Enum.Font.GothamBold
	unlockLabel.TextXAlignment = Enum.TextXAlignment.Left
	unlockLabel.Parent = textContainer

	-- Achievement name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0, 30)
	nameLabel.Position = UDim2.new(0, 0, 0, 22)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = achievementData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextWrapped = true
	nameLabel.Parent = textContainer

	-- Achievement description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, 0, 0, 25)
	descLabel.Position = UDim2.new(0, 0, 0, 54)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = achievementData.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 12
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = textContainer

	-- Rewards display
	if achievementData.Rewards then
		local rewardText = self:FormatRewards(achievementData.Rewards)
		local rewardLabel = Instance.new("TextLabel")
		rewardLabel.Name = "RewardLabel"
		rewardLabel.Size = UDim2.new(1, 0, 0, 18)
		rewardLabel.Position = UDim2.new(0, 0, 0, 80)
		rewardLabel.BackgroundTransparency = 1
		rewardLabel.Text = rewardText
		rewardLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		rewardLabel.TextSize = 11
		rewardLabel.Font = Enum.Font.GothamBold
		rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
		rewardLabel.TextWrapped = true
		rewardLabel.Parent = textContainer
	end

	-- Add shadow effect
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Placeholder shadow
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.ZIndex = -1
	shadow.Parent = container

	-- Add sparkle particles for special categories
	if achievementData.Category == "Meta" or achievementData.Category == "Secret" then
		self:AddSparkleEffect(container)
	end

	-- Store reference to container for animation
	screenGui.Container = container

	return screenGui
end

-- ============================================================
-- VISUAL EFFECTS
-- ============================================================

-- Add sparkle particle effect
function AchievementNotification:AddSparkleEffect(parent)
	-- Create particle emitter
	local attachment = Instance.new("Attachment")
	attachment.Parent = parent

	local particles = Instance.new("ParticleEmitter")
	particles.Name = "Sparkles"
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Rate = 20
	particles.Lifetime = NumberRange.new(1, 2)
	particles.Speed = NumberRange.new(1, 3)
	particles.SpreadAngle = Vector2.new(360, 360)
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	particles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 100))
	particles.LightEmission = 1
	particles.Parent = attachment

	-- Stop emitting after display duration
	task.delay(CONFIG.DisplayDuration, function()
		particles.Enabled = false
	end)
end

-- ============================================================
-- ANIMATION
-- ============================================================

-- Create slide tween
function AchievementNotification:CreateSlideTween(frame, targetPosition, duration)
	local tweenInfo = TweenInfo.new(
		duration,
		CONFIG.EasingStyle,
		CONFIG.EasingDirection
	)

	local tween = TweenService:Create(frame, tweenInfo, {
		Position = targetPosition
	})

	return tween
end

-- ============================================================
-- SOUND EFFECTS
-- ============================================================

-- Play achievement unlock sound
function AchievementNotification:PlayAchievementSound(category)
	local soundId = CONFIG.SoundIDs.Achievement

	-- Use special sounds for certain categories
	if category == "Secret" then
		soundId = CONFIG.SoundIDs.Secret
	elseif category == "Meta" then
		soundId = CONFIG.SoundIDs.Rare
	end

	-- Create and play sound
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = SoundService

	sound:Play()

	-- Cleanup after playing
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- Format rewards into readable text
function AchievementNotification:FormatRewards(rewards)
	local rewardParts = {}

	if rewards.DP then
		table.insert(rewardParts, string.format("+%s DP", self:FormatNumber(rewards.DP)))
	end

	if rewards.ToolTokens then
		table.insert(rewardParts, string.format("+%d Tool Token%s", rewards.ToolTokens, rewards.ToolTokens > 1 and "s" or ""))
	end

	if rewards.Eggs then
		for eggType, count in pairs(rewards.Eggs) do
			table.insert(rewardParts, string.format("+%d %s", count, eggType:gsub("Egg", " Egg")))
		end
	end

	if rewards.Title then
		table.insert(rewardParts, string.format("Title: '%s'", rewards.Title))
	end

	if rewards.Multiplier then
		local multPercent = math.floor(rewards.Multiplier.Amount * 100)
		table.insert(rewardParts, string.format("+%d%% %s", multPercent, rewards.Multiplier.Type))
	end

	if rewards.PetSlot then
		table.insert(rewardParts, "+1 Pet Slot")
	end

	if rewards.Unlock then
		table.insert(rewardParts, "Special Unlock!")
	end

	if rewards.Aura then
		table.insert(rewardParts, string.format("Aura: %s", rewards.Aura))
	end

	if #rewardParts == 0 then
		return "Achievement unlocked!"
	end

	return "Rewards: " .. table.concat(rewardParts, " | ")
end

-- Format large numbers with abbreviations
function AchievementNotification:FormatNumber(num)
	if num < 1000 then
		return tostring(num)
	elseif num < 1000000 then
		return string.format("%.1fK", num / 1000)
	elseif num < 1000000000 then
		return string.format("%.1fM", num / 1000000)
	else
		return string.format("%.1fB", num / 1000000000)
	end
end

-- ============================================================
-- PUBLIC API
-- ============================================================

-- Manually trigger a test notification (for debugging)
function AchievementNotification:TestNotification()
	local testData = {
		ID = "TestAchievement",
		Name = "Test Achievement",
		Description = "This is a test achievement notification",
		Category = "Special",
		Icon = "rbxassetid://0",
		Rewards = {
			DP = 1000000,
			ToolTokens = 5,
			Title = "Tester",
		},
		Timestamp = os.time(),
	}

	self:QueueNotification(testData)
end

-- Clear notification queue
function AchievementNotification:ClearQueue()
	NotificationQueue = {}
end

-- Get current queue size
function AchievementNotification:GetQueueSize()
	return #NotificationQueue
end

-- ============================================================
-- AUTO-INITIALIZATION
-- ============================================================

-- Auto-initialize when script runs
AchievementNotification:Initialize()

return AchievementNotification
