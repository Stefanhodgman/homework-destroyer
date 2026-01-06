--[[
	PetManager.lua
	Server-side pet management: hatching, equipping, fusion, deletion, leveling
	Part of the Homework Destroyer Pet System
]]

local PetManager = {}

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local PetConfig = require(script.Parent.PetConfig)
local DataManager = require(game.ServerScriptService.DataManager)

-- No longer using separate DataStore - integrated with DataManager
-- Pet data is stored in DataManager under player.Pets

-- ==================== HELPER TO ACCESS PET DATA ====================

-- Get pet data from DataManager
local function GetPetData(player)
	local playerData = DataManager:GetPlayerData(player)
	if not playerData then return nil end

	-- Initialize Pets structure if it doesn't exist
	if not playerData.Pets then
		playerData.Pets = {
			Inventory = {},
			Equipped = {},
			UnlockedSlots = PetConfig.EquipSlots.DefaultSlots
		}
	end

	-- Migrate old structure if needed (Owned -> Inventory, MaxSlots -> UnlockedSlots)
	if playerData.Pets.Owned and not playerData.Pets.Inventory then
		playerData.Pets.Inventory = playerData.Pets.Owned
		playerData.Pets.Owned = nil
	end
	if playerData.Pets.MaxSlots and not playerData.Pets.UnlockedSlots then
		playerData.Pets.UnlockedSlots = playerData.Pets.MaxSlots
		playerData.Pets.MaxSlots = nil
	end

	return playerData.Pets
end

-- ==================== INITIALIZATION ====================

function PetManager.InitializePlayer(player)
	-- Pet data is now handled by DataManager
	-- Just ensure Pets structure exists
	local petData = GetPetData(player)

	if not petData then
		warn("[PetManager] Failed to initialize pet data for " .. player.Name)
		return nil
	end

	-- Setup pet containers in workspace
	local petFolder = Instance.new("Folder")
	petFolder.Name = player.Name .. "_Pets"
	petFolder.Parent = workspace

	return petData
end

function PetManager.SavePlayerData(player)
	-- Data is automatically saved by DataManager, no need for separate save
	-- Just trigger a save in DataManager
	DataManager:SavePlayerData(player)
	return true
end

function PetManager.CleanupPlayer(player)
	-- Save before cleanup (handled by DataManager)
	PetManager.SavePlayerData(player)

	-- Remove pet models
	local petFolder = workspace:FindFirstChild(player.Name .. "_Pets")
	if petFolder then
		petFolder:Destroy()
	end

	-- Memory is cleared by DataManager
end

-- ==================== EGG HATCHING ====================

function PetManager.HatchEgg(player, eggId)
	local data = GetPetData(player)

	if not data then
		return {Success = false, Message = "Player data not initialized"}
	end

	-- Get egg configuration
	local eggData = PetConfig.GetEggData(eggId)
	if not eggData then
		return {Success = false, Message = "Invalid egg type"}
	end

	-- Check if player can afford the egg
	local playerData = DataManager:GetPlayerData(player)
	if not playerData then
		return {Success = false, Message = "Failed to load player data"}
	end

	local hasEnoughDP = playerData.DestructionPoints >= eggData.Cost
	if not hasEnoughDP then
		return {Success = false, Message = "Not enough Destruction Points (Need: " .. eggData.Cost .. " DP)"}
	end

	-- Deduct the DP cost
	DataManager:IncrementPlayerData(player, "DestructionPoints", -eggData.Cost)

	-- Roll for rarity
	local roll = math.random() * 100
	local rarity = PetConfig.GetRarityFromRoll(roll, eggData)

	-- Select pet from pool based on rarity
	local petPool = eggData.PetPool
	local selectedPetId = petPool[math.random(1, #petPool)]
	local petData = PetConfig.GetPetData(selectedPetId)

	-- Ensure the pet matches the rolled rarity (for multi-rarity pools)
	-- For simple pools, override the pet's rarity
	local finalRarity = rarity

	-- Create new pet instance
	local newPet = {
		PetId = selectedPetId,
		UniqueId = PetManager.GenerateUniqueId(),
		Rarity = finalRarity,
		Level = 1,
		XP = 0,
		Equipped = false,
		HatchTime = os.time()
	}

	-- Add to inventory
	table.insert(data.Inventory, newPet)

	-- Save data
	PetManager.SavePlayerData(player)

	return {
		Success = true,
		Pet = newPet,
		PetData = petData,
		Message = "Hatched " .. finalRarity .. " " .. petData.Name .. "!"
	}
end

function PetManager.GenerateUniqueId()
	return tostring(tick()) .. "_" .. tostring(math.random(10000, 99999))
end

-- ==================== PET EQUIPPING ====================

function PetManager.EquipPet(player, petUniqueId, slotIndex)
	local data = GetPetData(player)

	if not data then
		return {Success = false, Message = "Player data not initialized"}
	end

	-- Check if slot is unlocked
	if slotIndex > data.UnlockedSlots then
		return {Success = false, Message = "Pet slot not unlocked"}
	end

	-- Find the pet in inventory
	local pet = PetManager.FindPetByUniqueId(data.Inventory, petUniqueId)
	if not pet then
		return {Success = false, Message = "Pet not found in inventory"}
	end

	-- Check if pet is already equipped
	if pet.Equipped then
		return {Success = false, Message = "Pet already equipped"}
	end

	-- Unequip any pet in this slot
	if data.Equipped[slotIndex] then
		local oldPet = PetManager.FindPetByUniqueId(data.Inventory, data.Equipped[slotIndex])
		if oldPet then
			oldPet.Equipped = false
		end
	end

	-- Equip the new pet
	pet.Equipped = true
	data.Equipped[slotIndex] = petUniqueId

	-- Spawn pet model
	PetManager.SpawnPetModel(player, pet, slotIndex)

	-- Save data
	PetManager.SavePlayerData(player)

	return {Success = true, Message = "Pet equipped successfully"}
end

function PetManager.UnequipPet(player, slotIndex)
	local data = GetPetData(player)

	if not data then
		return {Success = false, Message = "Player data not initialized"}
	end

	local petUniqueId = data.Equipped[slotIndex]
	if not petUniqueId then
		return {Success = false, Message = "No pet in this slot"}
	end

	-- Find and unequip the pet
	local pet = PetManager.FindPetByUniqueId(data.Inventory, petUniqueId)
	if pet then
		pet.Equipped = false
	end

	data.Equipped[slotIndex] = nil

	-- Remove pet model
	PetManager.RemovePetModel(player, slotIndex)

	-- Save data
	PetManager.SavePlayerData(player)

	return {Success = true, Message = "Pet unequipped"}
end

function PetManager.SpawnPetModel(player, pet, slotIndex)
	local petData = PetConfig.GetPetData(pet.PetId)
	if not petData then return end

	local petFolder = workspace:FindFirstChild(player.Name .. "_Pets")
	if not petFolder then return end

	-- Remove existing pet in this slot
	PetManager.RemovePetModel(player, slotIndex)

	-- Create simple pet representation (replace with actual model loading)
	local petModel = Instance.new("Part")
	petModel.Name = "Pet_Slot" .. slotIndex
	petModel.Size = Vector3.new(petData.Size, petData.Size, petData.Size)
	petModel.Shape = Enum.PartType.Ball
	petModel.Material = Enum.Material.Neon
	petModel.Color = PetConfig.Rarities[pet.Rarity].Color
	petModel.CanCollide = false
	petModel.Anchored = false
	petModel.TopSurface = Enum.SurfaceType.Smooth
	petModel.BottomSurface = Enum.SurfaceType.Smooth

	-- Add body position for floating
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyPosition.P = 10000
	bodyPosition.Parent = petModel

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
	bodyGyro.P = 3000
	bodyGyro.Parent = petModel

	-- Store pet data
	local petInfo = Instance.new("ObjectValue")
	petInfo.Name = "PetInfo"
	petInfo.Value = pet
	petInfo.Parent = petModel

	local slotInfo = Instance.new("IntValue")
	slotInfo.Name = "SlotIndex"
	slotInfo.Value = slotIndex
	slotInfo.Parent = petModel

	petModel.Parent = petFolder

	-- Position near player
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local rootPart = player.Character.HumanoidRootPart
		local offset = Vector3.new(math.cos(slotIndex * math.pi / 3) * 3, petData.FloatHeight, math.sin(slotIndex * math.pi / 3) * 3)
		petModel.CFrame = rootPart.CFrame + offset
	end

	return petModel
end

function PetManager.RemovePetModel(player, slotIndex)
	local petFolder = workspace:FindFirstChild(player.Name .. "_Pets")
	if not petFolder then return end

	local petModel = petFolder:FindFirstChild("Pet_Slot" .. slotIndex)
	if petModel then
		petModel:Destroy()
	end
end

-- ==================== PET FUSION ====================

function PetManager.FusePets(player, petUniqueIds)
	local data = GetPetData(player)

	if not data then
		return {Success = false, Message = "Player data not initialized"}
	end

	-- Validate we have 3 pets
	if #petUniqueIds ~= 3 then
		return {Success = false, Message = "Fusion requires exactly 3 pets"}
	end

	-- Find all pets
	local pets = {}
	for _, uniqueId in ipairs(petUniqueIds) do
		local pet = PetManager.FindPetByUniqueId(data.Inventory, uniqueId)
		if not pet then
			return {Success = false, Message = "One or more pets not found"}
		end
		if pet.Equipped then
			return {Success = false, Message = "Cannot fuse equipped pets"}
		end
		table.insert(pets, pet)
	end

	-- Verify all pets are the same
	local firstPetId = pets[1].PetId
	local firstRarity = pets[1].Rarity

	for _, pet in ipairs(pets) do
		if pet.PetId ~= firstPetId then
			return {Success = false, Message = "All pets must be the same type"}
		end
		if pet.Rarity ~= firstRarity then
			return {Success = false, Message = "All pets must be the same rarity"}
		end
	end

	-- Get fusion config
	local fusionConfig = PetConfig.Fusion.StandardFusion
	local successRate = fusionConfig.SuccessRates[firstRarity]

	if not successRate then
		return {Success = false, Message = "Cannot fuse " .. firstRarity .. " pets"}
	end

	-- Roll for success
	local roll = math.random()
	local success = roll <= successRate

	if success then
		-- Remove the 3 pets
		for _, pet in ipairs(pets) do
			PetManager.RemovePetFromInventory(data.Inventory, pet.UniqueId)
		end

		-- Determine new rarity
		local rarityOrder = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}
		local currentIndex = table.find(rarityOrder, firstRarity)
		local newRarity = rarityOrder[math.min(currentIndex + 1, #rarityOrder)]

		-- Create new pet with higher rarity
		local newPet = {
			PetId = firstPetId,
			UniqueId = PetManager.GenerateUniqueId(),
			Rarity = newRarity,
			Level = 1,
			XP = 0,
			Equipped = false,
			HatchTime = os.time(),
			FusedFrom = firstRarity
		}

		table.insert(data.Inventory, newPet)

		-- Save data
		PetManager.SavePlayerData(player)

		local petData = PetConfig.GetPetData(firstPetId)
		return {
			Success = true,
			Fused = true,
			Pet = newPet,
			Message = "Fusion successful! Created " .. newRarity .. " " .. petData.Name .. "!"
		}
	else
		-- Failure - keep one pet
		for i = 2, 3 do
			PetManager.RemovePetFromInventory(data.Inventory, pets[i].UniqueId)
		end

		-- Save data
		PetManager.SavePlayerData(player)

		return {
			Success = true,
			Fused = false,
			Message = "Fusion failed! 2 pets were lost, 1 pet remains."
		}
	end
end

function PetManager.FuseForDragon(player, petUniqueIds)
	local data = GetPetData(player)

	if not data then
		return {Success = false, Message = "Player data not initialized"}
	end

	-- Validate we have 5 pets
	if #petUniqueIds ~= 5 then
		return {Success = false, Message = "Dragon fusion requires exactly 5 Legendary pets"}
	end

	-- Find all pets and verify they're Legendary
	local pets = {}
	for _, uniqueId in ipairs(petUniqueIds) do
		local pet = PetManager.FindPetByUniqueId(data.Inventory, uniqueId)
		if not pet then
			return {Success = false, Message = "One or more pets not found"}
		end
		if pet.Equipped then
			return {Success = false, Message = "Cannot fuse equipped pets"}
		end
		if pet.Rarity ~= "Legendary" then
			return {Success = false, Message = "All pets must be Legendary rarity"}
		end
		table.insert(pets, pet)
	end

	-- Get dragon fusion config
	local dragonConfig = PetConfig.Fusion.SpecialFusions.HomeworkDragon
	local successRate = dragonConfig.SuccessRate

	-- Roll for success
	local roll = math.random()
	local success = roll <= successRate

	if success then
		-- Remove all 5 pets
		for _, pet in ipairs(pets) do
			PetManager.RemovePetFromInventory(data.Inventory, pet.UniqueId)
		end

		-- Create the Homework Dragon!
		local newPet = {
			PetId = "HomeworkDragon",
			UniqueId = PetManager.GenerateUniqueId(),
			Rarity = "Mythic",
			Level = 1,
			XP = 0,
			Equipped = false,
			HatchTime = os.time(),
			FusedFrom = "5xLegendary"
		}

		table.insert(data.Inventory, newPet)

		-- Save data
		PetManager.SavePlayerData(player)

		return {
			Success = true,
			Fused = true,
			Pet = newPet,
			Message = "LEGENDARY FUSION! You obtained the HOMEWORK DRAGON!"
		}
	else
		-- Failure - all pets lost
		for _, pet in ipairs(pets) do
			PetManager.RemovePetFromInventory(data.Inventory, pet.UniqueId)
		end

		-- Save data
		PetManager.SavePlayerData(player)

		return {
			Success = true,
			Fused = false,
			Message = "Dragon fusion failed! All 5 Legendary pets were lost."
		}
	end
end

-- ==================== PET DELETION ====================

function PetManager.DeletePet(player, petUniqueId)
	local data = GetPetData(player)

	if not data then
		return {Success = false, Message = "Player data not initialized"}
	end

	-- Find the pet
	local pet = PetManager.FindPetByUniqueId(data.Inventory, petUniqueId)
	if not pet then
		return {Success = false, Message = "Pet not found"}
	end

	-- Check if equipped
	if pet.Equipped then
		return {Success = false, Message = "Cannot delete equipped pet. Unequip first."}
	end

	-- Remove from inventory
	PetManager.RemovePetFromInventory(data.Inventory, petUniqueId)

	-- Save data
	PetManager.SavePlayerData(player)

	return {Success = true, Message = "Pet deleted"}
end

-- ==================== PET LEVELING ====================

function PetManager.AddPetXP(player, petUniqueId, xpAmount)
	local data = GetPetData(player)

	if not data then return false end

	local pet = PetManager.FindPetByUniqueId(data.Inventory, petUniqueId)
	if not pet then return false end

	-- Add XP
	pet.XP = pet.XP + xpAmount

	-- Check for level ups
	local leveledUp = false
	while pet.Level < PetConfig.LevelScaling.MaxLevel do
		local requiredXP = PetConfig.LevelScaling.GetXPForLevel(pet.Level + 1)
		if pet.XP >= requiredXP then
			pet.XP = pet.XP - requiredXP
			pet.Level = pet.Level + 1
			leveledUp = true
		else
			break
		end
	end

	if leveledUp then
		-- Save data
		PetManager.SavePlayerData(player)
		return true, pet.Level
	end

	return false
end

function PetManager.AddXPToEquippedPets(player, xpAmount)
	local data = GetPetData(player)

	if not data then return end

	-- Add XP to all equipped pets
	for slotIndex, petUniqueId in pairs(data.Equipped) do
		if petUniqueId then
			PetManager.AddPetXP(player, petUniqueId, xpAmount)
		end
	end
end

-- ==================== DAMAGE CALCULATION ====================

function PetManager.GetEquippedPetsDamageBonus(player)
	local data = GetPetData(player)

	if not data then return 0 end

	local equippedPets = {}
	for _, petUniqueId in pairs(data.Equipped) do
		if petUniqueId then
			local pet = PetManager.FindPetByUniqueId(data.Inventory, petUniqueId)
			if pet then
				table.insert(equippedPets, pet)
			end
		end
	end

	return PetConfig.GetTotalPetDamageBonus(equippedPets)
end

function PetManager.GetPetAutoAttackDamage(pet)
	if not pet then return 0 end

	local petData = PetConfig.GetPetData(pet.PetId)
	if not petData then return 0 end

	local baseDamage = petData.AutoAttackDamage

	-- Apply level scaling
	local levelMultiplier = 1 + ((pet.Level - 1) * PetConfig.LevelScaling.DamagePerLevel)

	-- Apply max level bonus
	if pet.Level == PetConfig.LevelScaling.MaxLevel then
		levelMultiplier = levelMultiplier * PetConfig.LevelScaling.MaxLevelMultiplier
	end

	return baseDamage * levelMultiplier
end

-- ==================== SLOT UNLOCKING ====================

function PetManager.UnlockPetSlot(player, slotIndex)
	local data = GetPetData(player)

	if not data then
		return {Success = false, Message = "Player data not initialized"}
	end

	-- Check if already unlocked
	if data.UnlockedSlots >= slotIndex then
		return {Success = false, Message = "Slot already unlocked"}
	end

	-- Check requirements
	local requirements = PetConfig.EquipSlots.UnlockRequirements[slotIndex]
	if not requirements then
		return {Success = false, Message = "Invalid slot"}
	end

	-- Check level/rebirth requirements
	local playerData = DataManager:GetPlayerData(player)
	if not playerData then
		return {Success = false, Message = "Failed to load player data"}
	end

	local meetsRequirements = true
	local requirementMessage = ""

	-- Check level requirement
	if requirements.Level then
		if playerData.Level < requirements.Level then
			meetsRequirements = false
			requirementMessage = "Requires Level " .. requirements.Level
		end
	end

	-- Check rebirth requirement
	if requirements.Rebirth then
		if playerData.RebirthLevel < requirements.Rebirth then
			meetsRequirements = false
			requirementMessage = "Requires Rebirth " .. requirements.Rebirth
		end
	end

	if not meetsRequirements then
		return {Success = false, Message = requirementMessage}
	end

	-- Unlock slot
	data.UnlockedSlots = slotIndex

	-- Save data
	PetManager.SavePlayerData(player)

	return {Success = true, Message = "Pet slot " .. slotIndex .. " unlocked!"}
end

-- ==================== UTILITY FUNCTIONS ====================

function PetManager.FindPetByUniqueId(inventory, uniqueId)
	for _, pet in ipairs(inventory) do
		if pet.UniqueId == uniqueId then
			return pet
		end
	end
	return nil
end

function PetManager.RemovePetFromInventory(inventory, uniqueId)
	for i, pet in ipairs(inventory) do
		if pet.UniqueId == uniqueId then
			table.remove(inventory, i)
			return true
		end
	end
	return false
end

function PetManager.GetPlayerInventory(player)
	local data = GetPetData(player)

	if not data then return {} end
	return data.Inventory
end

function PetManager.GetEquippedPets(player)
	local data = GetPetData(player)

	if not data then return {} end

	local equipped = {}
	for slotIndex, petUniqueId in pairs(data.Equipped) do
		if petUniqueId then
			local pet = PetManager.FindPetByUniqueId(data.Inventory, petUniqueId)
			if pet then
				equipped[slotIndex] = pet
			end
		end
	end

	return equipped
end

-- ==================== AUTO-SAVE SYSTEM ====================

-- Auto-save every 5 minutes
game:GetService("RunService").Heartbeat:Connect(function()
	-- This would be better with a timer, but for simplicity:
	-- In production, use a proper timed loop
end)

-- ==================== PLAYER CONNECTION EVENTS ====================

Players.PlayerAdded:Connect(function(player)
	PetManager.InitializePlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	PetManager.CleanupPlayer(player)
end)

return PetManager
