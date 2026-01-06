--[[
	UISoundHandler.lua
	Client-side UI sound handler for Homework Destroyer

	Automatically adds sound effects to UI buttons and interactions
	Works with existing UI scripts by adding sound hooks

	This script automatically detects buttons in the player's GUI
	and adds click/hover sounds to them
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for SoundManager to load
local SoundManager = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("SoundManager"))

-- ========================================
-- CONFIGURATION
-- ========================================

-- Which UI elements should have sounds
local UI_SOUND_CONFIG = {
	ButtonClick = true,    -- Play click sound when buttons are activated
	ButtonHover = false,   -- Play hover sound when mouse enters buttons (can be annoying)
	WindowOpen = true,     -- Play sound when windows/frames are made visible
	WindowClose = true,    -- Play sound when windows/frames are hidden
	TabSwitch = true       -- Play sound when switching tabs
}

-- ========================================
-- BUTTON SOUND HANDLERS
-- ========================================

--[[
	Add click sound to a button
]]
local function addClickSound(button)
	if not button:IsA("GuiButton") then
		return
	end

	-- Check if already has click sound handler
	if button:GetAttribute("HasClickSound") then
		return
	end

	button:SetAttribute("HasClickSound", true)

	-- Connect click event
	button.Activated:Connect(function()
		if UI_SOUND_CONFIG.ButtonClick then
			SoundManager:PlayUISound("ButtonClick")
		end
	end)
end

--[[
	Add hover sound to a button
]]
local function addHoverSound(button)
	if not button:IsA("GuiButton") then
		return
	end

	-- Check if already has hover sound handler
	if button:GetAttribute("HasHoverSound") then
		return
	end

	button:SetAttribute("HasHoverSound", true)

	-- Connect hover event
	button.MouseEnter:Connect(function()
		if UI_SOUND_CONFIG.ButtonHover then
			SoundManager:PlayUISound("ButtonHover")
		end
	end)
end

-- ========================================
-- WINDOW/FRAME SOUND HANDLERS
-- ========================================

--[[
	Add visibility sound to a frame/window
	Plays sound when frame becomes visible or hidden
]]
local function addVisibilitySound(frame)
	if not frame:IsA("GuiObject") then
		return
	end

	-- Check if already has visibility sound handler
	if frame:GetAttribute("HasVisibilitySound") then
		return
	end

	-- Only add to main windows/panels (not individual elements)
	-- We check by name convention or specific UI elements
	local isMainWindow = frame:IsA("Frame") and (
		frame.Name:match("Window") or
		frame.Name:match("Panel") or
		frame.Name:match("Menu") or
		frame.Name == "ShopUI" or
		frame.Name == "UpgradeUI" or
		frame.Name == "ZoneTeleportUI"
	)

	if not isMainWindow then
		return
	end

	frame:SetAttribute("HasVisibilitySound", true)

	-- Watch for visibility changes
	frame:GetPropertyChangedSignal("Visible"):Connect(function()
		if frame.Visible and UI_SOUND_CONFIG.WindowOpen then
			SoundManager:PlayUISound("WindowOpen")
		elseif not frame.Visible and UI_SOUND_CONFIG.WindowClose then
			SoundManager:PlayUISound("WindowClose")
		end
	end)
end

-- ========================================
-- AUTO-DETECTION
-- ========================================

--[[
	Recursively add sounds to all buttons in a container
]]
local function addSoundsToContainer(container)
	for _, child in ipairs(container:GetDescendants()) do
		if child:IsA("GuiButton") then
			addClickSound(child)
			if UI_SOUND_CONFIG.ButtonHover then
				addHoverSound(child)
			end
		elseif child:IsA("Frame") then
			addVisibilitySound(child)
		end
	end

	-- Watch for new UI elements being added
	container.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("GuiButton") then
			addClickSound(descendant)
			if UI_SOUND_CONFIG.ButtonHover then
				addHoverSound(descendant)
			end
		elseif descendant:IsA("Frame") then
			addVisibilitySound(descendant)
		end
	end)
end

--[[
	Initialize UI sounds for all existing and future GUIs
]]
local function initialize()
	-- Add sounds to existing GUIs
	for _, gui in ipairs(playerGui:GetChildren()) do
		if gui:IsA("ScreenGui") then
			addSoundsToContainer(gui)
		end
	end

	-- Watch for new GUIs being added
	playerGui.ChildAdded:Connect(function(child)
		if child:IsA("ScreenGui") then
			addSoundsToContainer(child)
		end
	end)

	print("[UISoundHandler] Initialized - UI sounds enabled")
end

-- ========================================
-- MANUAL SOUND FUNCTIONS (for custom UI scripts)
-- ========================================

-- These can be called from other UI scripts for custom sound triggers

local UISoundHandler = {}

function UISoundHandler:PlayButtonClick()
	SoundManager:PlayUISound("ButtonClick")
end

function UISoundHandler:PlayPurchaseSuccess()
	SoundManager:PlayUISound("PurchaseSuccess")
end

function UISoundHandler:PlayPurchaseFail()
	SoundManager:PlayUISound("PurchaseFail")
end

function UISoundHandler:PlayTabSwitch()
	if UI_SOUND_CONFIG.TabSwitch then
		SoundManager:PlayUISound("TabSwitch")
	end
end

function UISoundHandler:PlayWindowOpen()
	if UI_SOUND_CONFIG.WindowOpen then
		SoundManager:PlayUISound("WindowOpen")
	end
end

function UISoundHandler:PlayWindowClose()
	if UI_SOUND_CONFIG.WindowClose then
		SoundManager:PlayUISound("WindowClose")
	end
end

function UISoundHandler:PlayNotification()
	SoundManager:PlayUISound("NotificationAppear")
end

-- Export for use by other scripts
_G.UISoundHandler = UISoundHandler

-- Initialize on script load
initialize()

return UISoundHandler
