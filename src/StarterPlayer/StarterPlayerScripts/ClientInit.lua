--[[
	ClientInit.lua
	Initializes all client-side systems for Homework Destroyer

	This script loads in the following order:
	1. SoundManager (audio system)
	2. UISoundHandler (UI audio integration)
	3. Other client systems

	Place this in StarterPlayer/StarterPlayerScripts
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

print("[ClientInit] Initializing client systems for", player.Name)

-- ========================================
-- LOAD SHARED MODULES
-- ========================================

-- Wait for SharedModules folder
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules", 10)
if not SharedModules then
	warn("[ClientInit] CRITICAL: SharedModules folder not found in ReplicatedStorage!")
	return
end

-- ========================================
-- INITIALIZE SOUND SYSTEM
-- ========================================

local SoundManager = nil
local soundSuccess, soundError = pcall(function()
	SoundManager = require(SharedModules:WaitForChild("SoundManager", 5))
end)

if soundSuccess and SoundManager then
	print("[ClientInit] ✓ SoundManager loaded successfully")
else
	warn("[ClientInit] ✗ Failed to load SoundManager:", soundError)
end

-- ========================================
-- WAIT FOR CHARACTER
-- ========================================

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid", 10)

if humanoid then
	print("[ClientInit] ✓ Character loaded")
else
	warn("[ClientInit] ✗ Humanoid not found")
end

-- ========================================
-- ADDITIONAL CLIENT SYSTEMS
-- ========================================

-- Add initialization for other client systems here as they're created
-- Example:
-- local UIController = require(somewhere)
-- UIController:Initialize()

-- ========================================
-- DEBUGGING INFO
-- ========================================

if game:GetService("RunService"):IsStudio() then
	-- Print debug info in Studio
	print("[ClientInit] Debug Info:")
	print("  Player:", player.Name)
	print("  Character:", character.Name)
	print("  SoundManager:", SoundManager and "Loaded" or "Failed")

	-- Test sound system
	if SoundManager then
		task.wait(2)
		print("[ClientInit] Testing sound system...")
		local testSound = SoundManager:PlayUISound("ButtonClick")
		if testSound then
			print("[ClientInit] ✓ Sound system test passed")
		else
			warn("[ClientInit] ✗ Sound system test failed (this is normal if using placeholder sound IDs)")
		end
	end
end

print("[ClientInit] Client initialization complete")
