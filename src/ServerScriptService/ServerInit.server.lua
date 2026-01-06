--[[
	ServerInit.lua

	Main server initialization script for Homework Destroyer
	This script initializes GameServer and starts the game

	Place this in ServerScriptService as the main entry point
]]

local ServerScriptService = game:GetService("ServerScriptService")

-- Initialize GameServer
local GameServer = require(ServerScriptService.GameServer)

-- Start the game server
GameServer:Initialize()

warn("[ServerInit] Game initialized and ready!")
