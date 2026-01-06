--[[
	ZoneTeleportUI.lua
	Client-side UI for zone selection and teleportation

	Features:
	- Display all zones with unlock status
	- Show zone requirements and details
	- Handle zone unlock purchases
	- Teleport to unlocked zones
	- Visual feedback for locked/unlocked zones

	Depends on:
	- RemoteEvents
]]

local ZoneTeleportUI = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Player and UI
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local RemoteEvents = require(ReplicatedStorage.Remotes.RemoteEvents)

-- UI References (will be created dynamically)
local screenGui = nil
local mainFrame = nil
local zoneListFrame = nil
local detailsFrame = nil
local closeButton = nil

-- State
local isUIOpen = false
local selectedZone = nil
local zoneData = {} -- Cache of zone data
local unlockedZones = {}

-- Constants
local TOTAL_ZONES = 10
local UI_TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Colors
local COLOR_LOCKED = Color3.fromRGB(100, 100, 100)
local COLOR_UNLOCKED = Color3.fromRGB(100, 200, 100)
local COLOR_SELECTED = Color3.fromRGB(200, 200, 50)
local COLOR_CAN_UNLOCK = Color3.fromRGB(150, 150, 255)
local COLOR_SECRET = Color3.fromRGB(138, 43, 226)

--[[
	Initialize the Zone Teleport UI
]]
function ZoneTeleportUI.Init()
	print("[ZoneTeleportUI] Initializing Zone Teleport UI...")

	-- Create UI
	ZoneTeleportUI.CreateUI()

	-- Connect remote events
	ZoneTeleportUI.ConnectRemoteEvents()

	-- Connect input for opening UI (bind to 'Z' key)
	ZoneTeleportUI.ConnectInput()

	-- Request initial data
	ZoneTeleportUI.RequestUnlockedZones()

	print("[ZoneTeleportUI] Zone Teleport UI initialized!")
end

--[[
	Create the UI structure
]]
function ZoneTeleportUI.CreateUI()
	-- Main ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ZoneTeleportUI"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 10
	screenGui.Enabled = false
	screenGui.Parent = playerGui

	-- Background overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.Parent = screenGui

	-- Main frame
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0.8, 0, 0.85, 0)
	mainFrame.Position = UDim2.new(0.1, 0, 0.075, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -40, 0, 50)
	titleLabel.Position = UDim2.new(0, 20, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "ZONE SELECTION"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 32
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = mainFrame

	-- Subtitle
	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "SubtitleLabel"
	subtitleLabel.Size = UDim2.new(1, -40, 0, 25)
	subtitleLabel.Position = UDim2.new(0, 20, 0, 50)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Text = "Choose your destination"
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextSize = 16
	subtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.Parent = mainFrame

	-- Close button
	closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 24
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Parent = mainFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		ZoneTeleportUI.CloseUI()
	end)

	-- Zone list frame (left side)
	zoneListFrame = Instance.new("ScrollingFrame")
	zoneListFrame.Name = "ZoneListFrame"
	zoneListFrame.Size = UDim2.new(0.45, -15, 1, -100)
	zoneListFrame.Position = UDim2.new(0, 10, 0, 85)
	zoneListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	zoneListFrame.BorderSizePixel = 0
	zoneListFrame.ScrollBarThickness = 6
	zoneListFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated
	zoneListFrame.Parent = mainFrame

	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 8)
	listCorner.Parent = zoneListFrame

	-- Add list layout
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = zoneListFrame

	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 8)
	listPadding.PaddingBottom = UDim.new(0, 8)
	listPadding.PaddingLeft = UDim.new(0, 8)
	listPadding.PaddingRight = UDim.new(0, 8)
	listPadding.Parent = zoneListFrame

	-- Details frame (right side)
	detailsFrame = Instance.new("Frame")
	detailsFrame.Name = "DetailsFrame"
	detailsFrame.Size = UDim2.new(0.55, -15, 1, -100)
	detailsFrame.Position = UDim2.new(0.45, 5, 0, 85)
	detailsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	detailsFrame.BorderSizePixel = 0
	detailsFrame.Parent = mainFrame

	local detailsCorner = Instance.new("UICorner")
	detailsCorner.CornerRadius = UDim.new(0, 8)
	detailsCorner.Parent = detailsFrame

	-- Populate zone list
	ZoneTeleportUI.PopulateZoneList()
end

--[[
	Populate zone list with all zones
]]
function ZoneTeleportUI.PopulateZoneList()
	-- Clear existing
	for _, child in ipairs(zoneListFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Create zone buttons for all zones
	for i = 1, TOTAL_ZONES do
		ZoneTeleportUI.CreateZoneButton(i)
	end

	-- Update canvas size
	local listLayout = zoneListFrame:FindFirstChildOfClass("UIListLayout")
	if listLayout then
		zoneListFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
	end
end

--[[
	Create a zone button
]]
function ZoneTeleportUI.CreateZoneButton(zoneID)
	local zoneButton = Instance.new("Frame")
	zoneButton.Name = "Zone" .. zoneID
	zoneButton.Size = UDim2.new(1, -16, 0, 70)
	zoneButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	zoneButton.BorderSizePixel = 0
	zoneButton.LayoutOrder = zoneID
	zoneButton.Parent = zoneListFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = zoneButton

	-- Zone number icon
	local zoneNumberLabel = Instance.new("TextLabel")
	zoneNumberLabel.Name = "ZoneNumber"
	zoneNumberLabel.Size = UDim2.new(0, 50, 0, 50)
	zoneNumberLabel.Position = UDim2.new(0, 10, 0.5, -25)
	zoneNumberLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
	zoneNumberLabel.Text = tostring(zoneID)
	zoneNumberLabel.Font = Enum.Font.GothamBold
	zoneNumberLabel.TextSize = 24
	zoneNumberLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	zoneNumberLabel.Parent = zoneButton

	local numberCorner = Instance.new("UICorner")
	numberCorner.CornerRadius = UDim.new(0.5, 0)
	numberCorner.Parent = zoneNumberLabel

	-- Zone name
	local zoneNameLabel = Instance.new("TextLabel")
	zoneNameLabel.Name = "ZoneName"
	zoneNameLabel.Size = UDim2.new(1, -140, 0, 30)
	zoneNameLabel.Position = UDim2.new(0, 70, 0, 10)
	zoneNameLabel.BackgroundTransparency = 1
	zoneNameLabel.Text = "Zone " .. zoneID
	zoneNameLabel.Font = Enum.Font.GothamBold
	zoneNameLabel.TextSize = 18
	zoneNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	zoneNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	zoneNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	zoneNameLabel.Parent = zoneButton

	-- Status label
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -140, 0, 20)
	statusLabel.Position = UDim2.new(0, 70, 0, 42)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Loading..."
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 14
	statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = zoneButton

	-- Lock icon (for locked zones)
	local lockIcon = Instance.new("TextLabel")
	lockIcon.Name = "LockIcon"
	lockIcon.Size = UDim2.new(0, 30, 0, 30)
	lockIcon.Position = UDim2.new(1, -40, 0.5, -15)
	lockIcon.BackgroundTransparency = 1
	lockIcon.Text = "🔒"
	lockIcon.Font = Enum.Font.Gotham
	lockIcon.TextSize = 20
	lockIcon.TextColor3 = COLOR_LOCKED
	lockIcon.Visible = true
	lockIcon.Parent = zoneButton

	-- Clickable button
	local clickButton = Instance.new("TextButton")
	clickButton.Name = "ClickButton"
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.Parent = zoneButton

	-- Hover effect
	clickButton.MouseEnter:Connect(function()
		TweenService:Create(zoneButton, UI_TWEEN_INFO, {
			BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		}):Play()
	end)

	clickButton.MouseLeave:Connect(function()
		TweenService:Create(zoneButton, UI_TWEEN_INFO, {
			BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		}):Play()
	end)

	-- Click handler
	clickButton.MouseButton1Click:Connect(function()
		ZoneTeleportUI.SelectZone(zoneID)
	end)

	-- Store reference
	zoneButton:SetAttribute("ZoneID", zoneID)

	return zoneButton
end

--[[
	Update zone button appearance based on unlock status
]]
function ZoneTeleportUI.UpdateZoneButton(zoneID, isUnlocked, canUnlock, zoneName, statusText)
	local zoneButton = zoneListFrame:FindFirstChild("Zone" .. zoneID)
	if not zoneButton then
		return
	end

	local zoneNameLabel = zoneButton:FindFirstChild("ZoneName")
	local statusLabel = zoneButton:FindFirstChild("StatusLabel")
	local lockIcon = zoneButton:FindFirstChild("LockIcon")
	local zoneNumberLabel = zoneButton:FindFirstChild("ZoneNumber")

	-- Update name
	if zoneNameLabel then
		zoneNameLabel.Text = zoneName or ("Zone " .. zoneID)
	end

	-- Update status and appearance
	if isUnlocked then
		-- Zone is unlocked
		if statusLabel then
			statusLabel.Text = "✓ Unlocked"
			statusLabel.TextColor3 = COLOR_UNLOCKED
		end
		if lockIcon then
			lockIcon.Visible = false
		end
		if zoneNumberLabel then
			zoneNumberLabel.BackgroundColor3 = COLOR_UNLOCKED
		end
	elseif canUnlock then
		-- Zone can be unlocked
		if statusLabel then
			statusLabel.Text = statusText or "Can Unlock"
			statusLabel.TextColor3 = COLOR_CAN_UNLOCK
		end
		if lockIcon then
			lockIcon.Visible = true
			lockIcon.TextColor3 = COLOR_CAN_UNLOCK
		end
		if zoneNumberLabel then
			zoneNumberLabel.BackgroundColor3 = COLOR_CAN_UNLOCK
		end
	else
		-- Zone is locked
		if statusLabel then
			statusLabel.Text = statusText or "Locked"
			statusLabel.TextColor3 = COLOR_LOCKED
		end
		if lockIcon then
			lockIcon.Visible = true
			lockIcon.TextColor3 = COLOR_LOCKED
		end
		if zoneNumberLabel then
			zoneNumberLabel.BackgroundColor3 = COLOR_LOCKED
		end
	end

	-- Special color for secret zones
	if zoneID == 10 then
		if zoneNumberLabel then
			zoneNumberLabel.BackgroundColor3 = COLOR_SECRET
		end
	end
end

--[[
	Select a zone and show details
]]
function ZoneTeleportUI.SelectZone(zoneID)
	selectedZone = zoneID

	-- Request zone info from server
	RemoteEvents.RequestZoneInfo:FireServer(zoneID)

	-- Highlight selected zone
	for _, zoneButton in ipairs(zoneListFrame:GetChildren()) do
		if zoneButton:IsA("Frame") and zoneButton:GetAttribute("ZoneID") then
			local clickButton = zoneButton:FindFirstChild("ClickButton")
			if zoneButton:GetAttribute("ZoneID") == zoneID then
				zoneButton.BackgroundColor3 = COLOR_SELECTED
			else
				zoneButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			end
		end
	end

	print("[ZoneTeleportUI] Selected Zone", zoneID)
end

--[[
	Display zone details in details frame
]]
function ZoneTeleportUI.DisplayZoneDetails(zoneInfo)
	-- Clear existing details
	for _, child in ipairs(detailsFrame:GetChildren()) do
		if not child:IsA("UICorner") then
			child:Destroy()
		end
	end

	-- Zone title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "DetailTitle"
	titleLabel.Size = UDim2.new(1, -40, 0, 40)
	titleLabel.Position = UDim2.new(0, 20, 0, 20)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = zoneInfo.Name or "Unknown Zone"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 28
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextWrapped = true
	titleLabel.Parent = detailsFrame

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "Description"
	descLabel.Size = UDim2.new(1, -40, 0, 60)
	descLabel.Position = UDim2.new(0, 20, 0, 70)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = zoneInfo.Description or ""
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 16
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.TextWrapped = true
	descLabel.Parent = detailsFrame

	-- Requirements section
	local reqLabel = Instance.new("TextLabel")
	reqLabel.Name = "RequirementsLabel"
	reqLabel.Size = UDim2.new(1, -40, 0, 30)
	reqLabel.Position = UDim2.new(0, 20, 0, 150)
	reqLabel.BackgroundTransparency = 1
	reqLabel.Text = "Requirements:"
	reqLabel.Font = Enum.Font.GothamBold
	reqLabel.TextSize = 20
	reqLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	reqLabel.TextXAlignment = Enum.TextXAlignment.Left
	reqLabel.Parent = detailsFrame

	-- Requirements list
	local yOffset = 190
	local requirements = zoneInfo.Requirements or {}

	if requirements.DP and requirements.DP > 0 then
		yOffset = ZoneTeleportUI.CreateRequirementLabel(detailsFrame, yOffset, "Destruction Points:", ZoneTeleportUI.FormatNumber(requirements.DP))
	end

	if requirements.Level and requirements.Level > 1 then
		yOffset = ZoneTeleportUI.CreateRequirementLabel(detailsFrame, yOffset, "Level:", tostring(requirements.Level))
	end

	if requirements.RebirthLevel and requirements.RebirthLevel > 0 then
		yOffset = ZoneTeleportUI.CreateRequirementLabel(detailsFrame, yOffset, "Rebirth:", tostring(requirements.RebirthLevel))
	end

	if requirements.PrestigeRank and requirements.PrestigeRank > 0 then
		yOffset = ZoneTeleportUI.CreateRequirementLabel(detailsFrame, yOffset, "Prestige Rank:", tostring(requirements.PrestigeRank))
	end

	-- Recommended level
	if zoneInfo.RecommendedLevel then
		yOffset = yOffset + 10
		local recLabel = Instance.new("TextLabel")
		recLabel.Name = "RecommendedLevel"
		recLabel.Size = UDim2.new(1, -40, 0, 25)
		recLabel.Position = UDim2.new(0, 20, 0, yOffset)
		recLabel.BackgroundTransparency = 1
		recLabel.Text = string.format("Recommended Level: %d - %d", zoneInfo.RecommendedLevel[1], zoneInfo.RecommendedLevel[2])
		recLabel.Font = Enum.Font.Gotham
		recLabel.TextSize = 14
		recLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		recLabel.TextXAlignment = Enum.TextXAlignment.Left
		recLabel.Parent = detailsFrame
		yOffset = yOffset + 30
	end

	-- Difficulty indicator
	if zoneInfo.DifficultyTier then
		local diffLabel = Instance.new("TextLabel")
		diffLabel.Name = "Difficulty"
		diffLabel.Size = UDim2.new(1, -40, 0, 25)
		diffLabel.Position = UDim2.new(0, 20, 0, yOffset)
		diffLabel.BackgroundTransparency = 1
		diffLabel.Text = "Difficulty: " .. string.rep("★", zoneInfo.DifficultyTier) .. string.rep("☆", 10 - zoneInfo.DifficultyTier)
		diffLabel.Font = Enum.Font.Gotham
		diffLabel.TextSize = 16
		diffLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		diffLabel.TextXAlignment = Enum.TextXAlignment.Left
		diffLabel.Parent = detailsFrame
		yOffset = yOffset + 35
	end

	-- Action buttons
	yOffset = yOffset + 20

	if zoneInfo.IsUnlocked then
		-- Teleport button
		local teleportButton = Instance.new("TextButton")
		teleportButton.Name = "TeleportButton"
		teleportButton.Size = UDim2.new(0, 200, 0, 50)
		teleportButton.Position = UDim2.new(0.5, -100, 0, yOffset)
		teleportButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		teleportButton.Text = "TELEPORT"
		teleportButton.Font = Enum.Font.GothamBold
		teleportButton.TextSize = 20
		teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		teleportButton.Parent = detailsFrame

		local teleportCorner = Instance.new("UICorner")
		teleportCorner.CornerRadius = UDim.new(0, 8)
		teleportCorner.Parent = teleportButton

		teleportButton.MouseButton1Click:Connect(function()
			ZoneTeleportUI.TeleportToZone(zoneInfo.ZoneID)
		end)
	elseif zoneInfo.CanUnlock then
		-- Unlock button
		local unlockButton = Instance.new("TextButton")
		unlockButton.Name = "UnlockButton"
		unlockButton.Size = UDim2.new(0, 200, 0, 50)
		unlockButton.Position = UDim2.new(0.5, -100, 0, yOffset)
		unlockButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
		unlockButton.Text = "UNLOCK ZONE"
		unlockButton.Font = Enum.Font.GothamBold
		unlockButton.TextSize = 20
		unlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		unlockButton.Parent = detailsFrame

		local unlockCorner = Instance.new("UICorner")
		unlockCorner.CornerRadius = UDim.new(0, 8)
		unlockCorner.Parent = unlockButton

		unlockButton.MouseButton1Click:Connect(function()
			ZoneTeleportUI.UnlockZone(zoneInfo.ZoneID)
		end)
	else
		-- Locked status
		local lockedLabel = Instance.new("TextLabel")
		lockedLabel.Name = "LockedLabel"
		lockedLabel.Size = UDim2.new(1, -40, 0, 50)
		lockedLabel.Position = UDim2.new(0, 20, 0, yOffset)
		lockedLabel.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
		lockedLabel.Text = "🔒 " .. (zoneInfo.UnlockReason or "LOCKED")
		lockedLabel.Font = Enum.Font.GothamBold
		lockedLabel.TextSize = 18
		lockedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		lockedLabel.Parent = detailsFrame

		local lockedCorner = Instance.new("UICorner")
		lockedCorner.CornerRadius = UDim.new(0, 8)
		lockedCorner.Parent = lockedLabel
	end
end

--[[
	Create a requirement label
]]
function ZoneTeleportUI.CreateRequirementLabel(parent, yPos, label, value)
	local reqFrame = Instance.new("Frame")
	reqFrame.Size = UDim2.new(1, -40, 0, 25)
	reqFrame.Position = UDim2.new(0, 20, 0, yPos)
	reqFrame.BackgroundTransparency = 1
	reqFrame.Parent = parent

	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(0.5, 0, 1, 0)
	labelText.Position = UDim2.new(0, 0, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.Font = Enum.Font.Gotham
	labelText.TextSize = 16
	labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Parent = reqFrame

	local valueText = Instance.new("TextLabel")
	valueText.Size = UDim2.new(0.5, 0, 1, 0)
	valueText.Position = UDim2.new(0.5, 0, 0, 0)
	valueText.BackgroundTransparency = 1
	valueText.Text = value
	valueText.Font = Enum.Font.GothamBold
	valueText.TextSize = 16
	valueText.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueText.TextXAlignment = Enum.TextXAlignment.Right
	valueText.Parent = reqFrame

	return yPos + 30
end

--[[
	Request to unlock a zone
]]
function ZoneTeleportUI.UnlockZone(zoneID)
	print("[ZoneTeleportUI] Requesting to unlock Zone", zoneID)
	RemoteEvents.RequestZoneUnlock:FireServer(zoneID)
end

--[[
	Request to teleport to a zone
]]
function ZoneTeleportUI.TeleportToZone(zoneID)
	print("[ZoneTeleportUI] Requesting teleport to Zone", zoneID)
	RemoteEvents.RequestZoneTeleport:FireServer(zoneID)
	ZoneTeleportUI.CloseUI()
end

--[[
	Request unlocked zones from server
]]
function ZoneTeleportUI.RequestUnlockedZones()
	RemoteEvents.GetUnlockedZones:FireServer()
end

--[[
	Connect remote events
]]
function ZoneTeleportUI.ConnectRemoteEvents()
	-- Receive zone info
	RemoteEvents.ReceiveZoneInfo.OnClientEvent:Connect(function(zoneInfo)
		-- Cache zone data
		zoneData[zoneInfo.ZoneID] = zoneInfo

		-- Update zone button
		ZoneTeleportUI.UpdateZoneButton(
			zoneInfo.ZoneID,
			zoneInfo.IsUnlocked,
			zoneInfo.CanUnlock,
			zoneInfo.Name,
			zoneInfo.UnlockReason
		)

		-- If this is the selected zone, display details
		if selectedZone == zoneInfo.ZoneID then
			ZoneTeleportUI.DisplayZoneDetails(zoneInfo)
		end
	end)

	-- Receive unlocked zones
	RemoteEvents.ReceiveUnlockedZones.OnClientEvent:Connect(function(zones)
		unlockedZones = zones

		-- Request info for all zones
		for i = 1, TOTAL_ZONES do
			RemoteEvents.RequestZoneInfo:FireServer(i)
		end
	end)

	-- Zone unlock result
	RemoteEvents.ZoneUnlockResult.OnClientEvent:Connect(function(success, message)
		if success then
			print("[ZoneTeleportUI] Zone unlock successful:", message)
			-- Refresh zone data
			ZoneTeleportUI.RequestUnlockedZones()
			-- Re-select current zone to refresh details
			if selectedZone then
				RemoteEvents.RequestZoneInfo:FireServer(selectedZone)
			end
		else
			warn("[ZoneTeleportUI] Zone unlock failed:", message)
		end
	end)

	-- Zone teleport result
	RemoteEvents.ZoneTeleportResult.OnClientEvent:Connect(function(success, message)
		if success then
			print("[ZoneTeleportUI] Teleport successful:", message)
		else
			warn("[ZoneTeleportUI] Teleport failed:", message)
		end
	end)

	print("[ZoneTeleportUI] Remote events connected")
end

--[[
	Connect input for opening/closing UI
]]
function ZoneTeleportUI.ConnectInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		-- Press 'Z' to toggle zone UI
		if input.KeyCode == Enum.KeyCode.Z then
			ZoneTeleportUI.ToggleUI()
		end

		-- Press 'Escape' to close UI
		if input.KeyCode == Enum.KeyCode.Escape and isUIOpen then
			ZoneTeleportUI.CloseUI()
		end
	end)

	print("[ZoneTeleportUI] Input connected (Press 'Z' to open Zone UI)")
end

--[[
	Toggle UI visibility
]]
function ZoneTeleportUI.ToggleUI()
	if isUIOpen then
		ZoneTeleportUI.CloseUI()
	else
		ZoneTeleportUI.OpenUI()
	end
end

--[[
	Open UI
]]
function ZoneTeleportUI.OpenUI()
	screenGui.Enabled = true
	isUIOpen = true

	-- Refresh data
	ZoneTeleportUI.RequestUnlockedZones()

	-- Animate in
	mainFrame.Position = UDim2.new(0.1, 0, -1, 0)
	TweenService:Create(mainFrame, UI_TWEEN_INFO, {
		Position = UDim2.new(0.1, 0, 0.075, 0)
	}):Play()

	print("[ZoneTeleportUI] UI opened")
end

--[[
	Close UI
]]
function ZoneTeleportUI.CloseUI()
	-- Animate out
	local closeTween = TweenService:Create(mainFrame, UI_TWEEN_INFO, {
		Position = UDim2.new(0.1, 0, -1, 0)
	})

	closeTween.Completed:Connect(function()
		screenGui.Enabled = false
		isUIOpen = false
	end)

	closeTween:Play()

	print("[ZoneTeleportUI] UI closed")
end

--[[
	Format large numbers for display
]]
function ZoneTeleportUI.FormatNumber(num)
	if num >= 1000000000000 then
		return string.format("%.2fT", num / 1000000000000)
	elseif num >= 1000000000 then
		return string.format("%.2fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.2fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.2fK", num / 1000)
	else
		return tostring(num)
	end
end

-- Auto-initialize when script loads
ZoneTeleportUI.Init()

return ZoneTeleportUI
