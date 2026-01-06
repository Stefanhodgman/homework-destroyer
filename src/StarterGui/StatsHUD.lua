--[[
	StatsHUD.lua
	Top-of-screen stats display for Homework Destroyer

	Displays:
	- Current Level and XP progress bar
	- Destruction Points (DP) counter
	- Current Zone name
	- Rebirth level (if > 0)
	- Prestige rank (if > 0)

	Features:
	- Responsive design with scaling
	- Smooth animations for stat changes
	- Mobile-friendly layout
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local RemoteEvents = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvents"))
local remotes = RemoteEvents.Get()

-- Player Data Template for XP calculations
local PlayerDataTemplate = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("PlayerDataTemplate"))

local StatsHUD = {}
StatsHUD.__index = StatsHUD

-- Colors
local COLORS = {
	Background = Color3.fromRGB(20, 20, 25),
	Panel = Color3.fromRGB(30, 30, 40),
	Text = {
		Primary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(180, 180, 180),
		Gold = Color3.fromRGB(255, 215, 0),
		Rebirth = Color3.fromRGB(138, 43, 226),
		Prestige = Color3.fromRGB(255, 105, 180),
	},
	XPBar = {
		Fill = Color3.fromRGB(76, 175, 80),
		Background = Color3.fromRGB(40, 40, 50),
	},
	DP = Color3.fromRGB(85, 255, 85),
}

-- ========================================
-- CONSTRUCTOR
-- ========================================

function StatsHUD.new()
	local self = setmetatable({}, StatsHUD)

	-- Player data cache
	self.playerData = {
		Level = 1,
		Experience = 0,
		DestructionPoints = 0,
		CurrentZone = 1,
		RebirthLevel = 0,
		PrestigeLevel = 0,
		PostPrestigeRebirths = 0,
	}

	-- UI References
	self.gui = nil
	self.levelLabel = nil
	self.xpBar = nil
	self.xpBarFill = nil
	self.xpText = nil
	self.dpLabel = nil
	self.zoneLabel = nil
	self.rebirthLabel = nil
	self.prestigeLabel = nil

	-- Animation tracking
	self.dpTween = nil
	self.xpTween = nil

	self:CreateUI()
	self:SetupEventListeners()
	self:RequestInitialData()

	return self
end

-- ========================================
-- UI CREATION
-- ========================================

function StatsHUD:CreateUI()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StatsHUD"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 10 -- Above other UI
	screenGui.Parent = playerGui

	self.gui = screenGui

	-- Main Container - Top center
	local mainContainer = Instance.new("Frame")
	mainContainer.Name = "MainContainer"
	mainContainer.Size = UDim2.new(0, 500, 0, 100)
	mainContainer.Position = UDim2.new(0.5, -250, 0, 10)
	mainContainer.AnchorPoint = Vector2.new(0, 0)
	mainContainer.BackgroundColor3 = COLORS.Background
	mainContainer.BackgroundTransparency = 0.2
	mainContainer.BorderSizePixel = 0
	mainContainer.Parent = screenGui

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 12)
	containerCorner.Parent = mainContainer

	-- Add subtle border
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 80)
	stroke.Thickness = 2
	stroke.Transparency = 0.5
	stroke.Parent = mainContainer

	-- Padding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = mainContainer

	-- Top row: Level, Zone, Special badges
	local topRow = Instance.new("Frame")
	topRow.Name = "TopRow"
	topRow.Size = UDim2.new(1, 0, 0, 25)
	topRow.Position = UDim2.new(0, 0, 0, 0)
	topRow.BackgroundTransparency = 1
	topRow.Parent = mainContainer

	-- Level Label (Left)
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Size = UDim2.new(0, 120, 1, 0)
	levelLabel.Position = UDim2.new(0, 0, 0, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.TextSize = 18
	levelLabel.TextColor3 = COLORS.Text.Gold
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.Text = "Level 1"
	levelLabel.Parent = topRow

	self.levelLabel = levelLabel

	-- Zone Label (Center)
	local zoneLabel = Instance.new("TextLabel")
	zoneLabel.Name = "ZoneLabel"
	zoneLabel.Size = UDim2.new(0, 200, 1, 0)
	zoneLabel.Position = UDim2.new(0.5, -100, 0, 0)
	zoneLabel.BackgroundTransparency = 1
	zoneLabel.Font = Enum.Font.Gotham
	zoneLabel.TextSize = 14
	zoneLabel.TextColor3 = COLORS.Text.Secondary
	zoneLabel.TextXAlignment = Enum.TextXAlignment.Center
	zoneLabel.Text = "Zone: Classroom"
	zoneLabel.Parent = topRow

	self.zoneLabel = zoneLabel

	-- Rebirth/Prestige Container (Right)
	local badgeContainer = Instance.new("Frame")
	badgeContainer.Name = "BadgeContainer"
	badgeContainer.Size = UDim2.new(0, 150, 1, 0)
	badgeContainer.Position = UDim2.new(1, -150, 0, 0)
	badgeContainer.BackgroundTransparency = 1
	badgeContainer.Parent = topRow

	local badgeLayout = Instance.new("UIListLayout")
	badgeLayout.FillDirection = Enum.FillDirection.Horizontal
	badgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	badgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	badgeLayout.Padding = UDim.new(0, 5)
	badgeLayout.Parent = badgeContainer

	-- Rebirth Badge
	local rebirthLabel = Instance.new("TextLabel")
	rebirthLabel.Name = "RebirthLabel"
	rebirthLabel.Size = UDim2.new(0, 0, 1, 0)
	rebirthLabel.AutomaticSize = Enum.AutomaticSize.X
	rebirthLabel.BackgroundColor3 = COLORS.Text.Rebirth
	rebirthLabel.Font = Enum.Font.GothamBold
	rebirthLabel.TextSize = 12
	rebirthLabel.TextColor3 = COLORS.Text.Primary
	rebirthLabel.Text = ""
	rebirthLabel.Visible = false
	rebirthLabel.Parent = badgeContainer

	local rebirthPadding = Instance.new("UIPadding")
	rebirthPadding.PaddingLeft = UDim.new(0, 8)
	rebirthPadding.PaddingRight = UDim.new(0, 8)
	rebirthPadding.Parent = rebirthLabel

	local rebirthCorner = Instance.new("UICorner")
	rebirthCorner.CornerRadius = UDim.new(0, 6)
	rebirthCorner.Parent = rebirthLabel

	self.rebirthLabel = rebirthLabel

	-- Prestige Badge
	local prestigeLabel = Instance.new("TextLabel")
	prestigeLabel.Name = "PrestigeLabel"
	prestigeLabel.Size = UDim2.new(0, 0, 1, 0)
	prestigeLabel.AutomaticSize = Enum.AutomaticSize.X
	prestigeLabel.BackgroundColor3 = COLORS.Text.Prestige
	prestigeLabel.Font = Enum.Font.GothamBold
	prestigeLabel.TextSize = 12
	prestigeLabel.TextColor3 = COLORS.Text.Primary
	prestigeLabel.Text = ""
	prestigeLabel.Visible = false
	prestigeLabel.Parent = badgeContainer

	local prestigePadding = Instance.new("UIPadding")
	prestigePadding.PaddingLeft = UDim.new(0, 8)
	prestigePadding.PaddingRight = UDim.new(0, 8)
	prestigePadding.Parent = prestigeLabel

	local prestigeCorner = Instance.new("UICorner")
	prestigeCorner.CornerRadius = UDim.new(0, 6)
	prestigeCorner.Parent = prestigeLabel

	self.prestigeLabel = prestigeLabel

	-- XP Bar Container
	local xpContainer = Instance.new("Frame")
	xpContainer.Name = "XPContainer"
	xpContainer.Size = UDim2.new(1, 0, 0, 20)
	xpContainer.Position = UDim2.new(0, 0, 0, 30)
	xpContainer.BackgroundColor3 = COLORS.XPBar.Background
	xpContainer.BorderSizePixel = 0
	xpContainer.Parent = mainContainer

	local xpCorner = Instance.new("UICorner")
	xpCorner.CornerRadius = UDim.new(0, 10)
	xpCorner.Parent = xpContainer

	-- XP Bar Fill
	local xpBarFill = Instance.new("Frame")
	xpBarFill.Name = "XPBarFill"
	xpBarFill.Size = UDim2.new(0, 0, 1, 0)
	xpBarFill.BackgroundColor3 = COLORS.XPBar.Fill
	xpBarFill.BorderSizePixel = 0
	xpBarFill.Parent = xpContainer

	local xpFillCorner = Instance.new("UICorner")
	xpFillCorner.CornerRadius = UDim.new(0, 10)
	xpFillCorner.Parent = xpBarFill

	self.xpBar = xpContainer
	self.xpBarFill = xpBarFill

	-- XP Text Overlay
	local xpText = Instance.new("TextLabel")
	xpText.Name = "XPText"
	xpText.Size = UDim2.new(1, 0, 1, 0)
	xpText.BackgroundTransparency = 1
	xpText.Font = Enum.Font.GothamBold
	xpText.TextSize = 12
	xpText.TextColor3 = COLORS.Text.Primary
	xpText.Text = "0 / 100 XP"
	xpText.ZIndex = 2
	xpText.Parent = xpContainer

	self.xpText = xpText

	-- DP Counter (Bottom)
	local dpContainer = Instance.new("Frame")
	dpContainer.Name = "DPContainer"
	dpContainer.Size = UDim2.new(1, 0, 0, 25)
	dpContainer.Position = UDim2.new(0, 0, 0, 55)
	dpContainer.BackgroundTransparency = 1
	dpContainer.Parent = mainContainer

	local dpIcon = Instance.new("TextLabel")
	dpIcon.Name = "DPIcon"
	dpIcon.Size = UDim2.new(0, 25, 1, 0)
	dpIcon.BackgroundTransparency = 1
	dpIcon.Font = Enum.Font.GothamBold
	dpIcon.TextSize = 20
	dpIcon.TextColor3 = COLORS.DP
	dpIcon.Text = "💰"
	dpIcon.Parent = dpContainer

	local dpLabel = Instance.new("TextLabel")
	dpLabel.Name = "DPLabel"
	dpLabel.Size = UDim2.new(1, -30, 1, 0)
	dpLabel.Position = UDim2.new(0, 30, 0, 0)
	dpLabel.BackgroundTransparency = 1
	dpLabel.Font = Enum.Font.GothamBold
	dpLabel.TextSize = 18
	dpLabel.TextColor3 = COLORS.DP
	dpLabel.TextXAlignment = Enum.TextXAlignment.Left
	dpLabel.Text = "0 DP"
	dpLabel.Parent = dpContainer

	self.dpLabel = dpLabel
end

-- ========================================
-- DATA UPDATE FUNCTIONS
-- ========================================

function StatsHUD:UpdateLevel(level)
	if self.playerData.Level ~= level then
		self.playerData.Level = level
		self.levelLabel.Text = string.format("Level %d", level)

		-- Flash animation on level up
		if level > 1 then
			self:FlashElement(self.levelLabel, COLORS.Text.Gold)
		end
	end
end

function StatsHUD:UpdateXP(currentXP, maxXP)
	self.playerData.Experience = currentXP

	-- Calculate percentage
	local percentage = math.clamp(currentXP / math.max(maxXP, 1), 0, 1)

	-- Update XP text
	self.xpText.Text = string.format("%s / %s XP", self:FormatNumber(currentXP), self:FormatNumber(maxXP))

	-- Animate XP bar
	if self.xpTween then
		self.xpTween:Cancel()
	end

	self.xpTween = TweenService:Create(
		self.xpBarFill,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.new(percentage, 0, 1, 0)}
	)
	self.xpTween:Play()
end

function StatsHUD:UpdateDP(dp)
	local oldDP = self.playerData.DestructionPoints
	self.playerData.DestructionPoints = dp

	-- Update label with formatted number
	self.dpLabel.Text = string.format("%s DP", self:FormatNumber(dp))

	-- Flash green if DP increased
	if dp > oldDP and oldDP > 0 then
		self:FlashElement(self.dpLabel, Color3.fromRGB(150, 255, 150))
	end
end

function StatsHUD:UpdateZone(zoneId, zoneName)
	self.playerData.CurrentZone = zoneId

	-- Get zone name from ID
	local zoneNames = {
		[1] = "Classroom",
		[2] = "Library",
		[3] = "Cafeteria",
		[4] = "Computer Lab",
		[5] = "Gymnasium",
		[6] = "Music Room",
		[7] = "Art Room",
		[8] = "Science Lab",
		[9] = "Principal's Office",
		[10] = "The Void",
	}

	local displayName = zoneName or zoneNames[zoneId] or "Unknown Zone"
	self.zoneLabel.Text = string.format("Zone: %s", displayName)
end

function StatsHUD:UpdateRebirth(rebirthLevel)
	self.playerData.RebirthLevel = rebirthLevel

	if rebirthLevel > 0 then
		self.rebirthLabel.Text = string.format("Rebirth %d", rebirthLevel)
		self.rebirthLabel.Visible = true
	else
		self.rebirthLabel.Visible = false
	end
end

function StatsHUD:UpdatePrestige(prestigeLevel, postPrestigeRebirths)
	self.playerData.PrestigeLevel = prestigeLevel
	self.playerData.PostPrestigeRebirths = postPrestigeRebirths or 0

	if prestigeLevel > 0 then
		-- Map prestige level to rank name
		local prestigeRanks = {
			[1] = "I",
			[2] = "II",
			[3] = "III",
			[4] = "IV",
			[5] = "V",
			[6] = "MAX"
		}

		local rankDisplay = prestigeRanks[prestigeLevel] or tostring(prestigeLevel)
		self.prestigeLabel.Text = string.format("Prestige %s", rankDisplay)
		self.prestigeLabel.Visible = true

		-- Rainbow effect for MAX prestige
		if prestigeLevel >= 6 then
			self:ApplyRainbowEffect(self.prestigeLabel)
		end
	else
		self.prestigeLabel.Visible = false
	end
end

function StatsHUD:UpdateAllStats(data)
	-- Update all stats from player data
	self:UpdateLevel(data.Level or 1)

	-- Calculate XP required for next level
	local maxXP = PlayerDataTemplate.GetXPRequiredForLevel(data.Level or 1)
	self:UpdateXP(data.Experience or 0, maxXP)

	self:UpdateDP(data.DestructionPoints or 0)
	self:UpdateZone(data.CurrentZone or 1)
	self:UpdateRebirth(data.RebirthLevel or 0)
	self:UpdatePrestige(data.PrestigeLevel or 0, data.PostPrestigeRebirths or 0)
end

-- ========================================
-- VISUAL EFFECTS
-- ========================================

function StatsHUD:FlashElement(element, color)
	local originalColor = element.TextColor3

	-- Flash to bright color
	element.TextColor3 = color

	-- Fade back to original
	task.delay(0.1, function()
		local tween = TweenService:Create(
			element,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{TextColor3 = originalColor}
		)
		tween:Play()
	end)
end

function StatsHUD:ApplyRainbowEffect(element)
	-- Rainbow text color animation for MAX prestige
	local hue = 0

	RunService.RenderStepped:Connect(function(dt)
		if not element or not element.Parent then return end
		if self.playerData.PrestigeLevel < 6 then return end

		hue = (hue + dt * 0.5) % 1
		element.TextColor3 = Color3.fromHSV(hue, 1, 1)
	end)
end

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

function StatsHUD:FormatNumber(num)
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
-- EVENT LISTENERS
-- ========================================

function StatsHUD:SetupEventListeners()
	-- Listen for individual stat updates
	remotes.DataUpdate.OnClientEvent:Connect(function(dataType, newValue, extraData)
		if dataType == "Level" then
			self:UpdateLevel(newValue)
		elseif dataType == "Experience" then
			local maxXP = PlayerDataTemplate.GetXPRequiredForLevel(self.playerData.Level)
			self:UpdateXP(newValue, maxXP)
		elseif dataType == "DestructionPoints" then
			self:UpdateDP(newValue)
		elseif dataType == "CurrentZone" then
			self:UpdateZone(newValue, extraData)
		elseif dataType == "RebirthLevel" then
			self:UpdateRebirth(newValue)
		elseif dataType == "PrestigeLevel" then
			self:UpdatePrestige(newValue, extraData)
		end
	end)

	-- Listen for full data sync
	remotes.FullDataSync.OnClientEvent:Connect(function(playerData)
		if playerData then
			self:UpdateAllStats(playerData)
		end
	end)

	-- Listen for level up events (for special animations)
	if remotes.ShowNotification then
		remotes.ShowNotification.OnClientEvent:Connect(function(notificationType, title, message, duration)
			if notificationType == "LevelUp" then
				-- Play level up animation
				self:FlashElement(self.levelLabel, Color3.fromRGB(255, 255, 100))
			end
		end)
	end
end

function StatsHUD:RequestInitialData()
	-- Request full data sync from server
	if remotes.RequestDataSync then
		remotes.RequestDataSync:FireServer()
	end
end

-- ========================================
-- PUBLIC API
-- ========================================

function StatsHUD:Show()
	self.gui.Enabled = true
end

function StatsHUD:Hide()
	self.gui.Enabled = false
end

function StatsHUD:Toggle()
	self.gui.Enabled = not self.gui.Enabled
end

-- ========================================
-- INITIALIZATION
-- ========================================

-- Create and initialize the HUD
local statsHUD = StatsHUD.new()

-- Expose global API
_G.StatsHUD = {
	Show = function() statsHUD:Show() end,
	Hide = function() statsHUD:Hide() end,
	Toggle = function() statsHUD:Toggle() end,
	UpdateStats = function(data) statsHUD:UpdateAllStats(data) end,
}

print("[StatsHUD] Initialized successfully")

return statsHUD
