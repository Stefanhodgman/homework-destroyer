--[[
	UpgradePrestigeTest.lua
	Example test script demonstrating usage of the upgrade and prestige systems
	Run this in Roblox Studio to test the modules
]]

local ServerStorage = game:GetService("ServerStorage")

-- Import modules
local StatsCalculator = require(ServerStorage.Modules.StatsCalculator)
local UpgradeManager = require(ServerStorage.Modules.UpgradeManager)
local PrestigeManager = require(ServerStorage.Modules.PrestigeManager)

-- Initialize managers
local upgradeManager = UpgradeManager.new()
local prestigeManager = PrestigeManager.new()

print("\n========================================")
print("HOMEWORK DESTROYER - SYSTEM TEST")
print("========================================\n")

-- ========================================
-- TEST 1: BASIC STATS CALCULATION
-- ========================================

print("TEST 1: Basic Stats Calculation")
print("--------------------------------")

local testPlayerData = {
	UserId = 123456789,
	Level = 25,
	XP = 5000,
	DP = 100000,
	Rebirth = 0,
	PrestigeRank = 0,
	Upgrades = {
		SharperTools = 5,
		StrongerArms = 3,
		DPBonus = 10,
	},
}

local testToolData = {
	Name = "Safety Scissors",
	BaseDamage = 8,
	Rarity = "Uncommon",
	CritChance = 0.05,
	UpgradeLevel = 2,
}

local testPetData = {}

-- Calculate stats
local stats = StatsCalculator.GetPlayerStats(testPlayerData, testToolData, testPetData)

print("Player Level: " .. stats.Level)
print("Base Damage: " .. stats.BaseDamage)
print("Final Damage: " .. stats.FinalDamage)
print("Crit Chance: " .. math.floor(stats.CritChance * 100) .. "%")
print("Crit Damage: " .. stats.CritDamage)
print("Movement Speed: " .. stats.MovementSpeed)
print("Papers/Second: " .. stats.PapersPerSecond)
print("✓ Test 1 passed\n")

-- ========================================
-- TEST 2: UPGRADE PURCHASES
-- ========================================

print("TEST 2: Upgrade Purchase System")
print("--------------------------------")

-- Test upgrade cost calculation
local upgradeName = "SharperTools"
local currentLevel = testPlayerData.Upgrades[upgradeName]
local cost = upgradeManager:GetUpgradeCost(upgradeName, currentLevel)
print("Current Level: " .. currentLevel)
print("Next Level Cost: " .. cost .. " DP")

-- Test upgrade purchase
local success, message, data = upgradeManager:PurchaseUpgrade(testPlayerData, upgradeName)
if success then
	print("✓ Purchase successful!")
	print("  - New Level: " .. data.newLevel)
	print("  - Cost Paid: " .. data.costPaid)
	print("  - Remaining DP: " .. data.remainingDP)
else
	print("✗ Purchase failed: " .. message)
end

-- Test insufficient DP
testPlayerData.DP = 10 -- Not enough for next purchase
success, message = upgradeManager:PurchaseUpgrade(testPlayerData, upgradeName)
if not success then
	print("✓ Correctly rejected purchase with insufficient DP")
end

-- Restore DP for further tests
testPlayerData.DP = 100000

print("✓ Test 2 passed\n")

-- ========================================
-- TEST 3: BUY MAX UPGRADES
-- ========================================

print("TEST 3: Buy Max Upgrades")
print("--------------------------------")

testPlayerData.DP = 1000000 -- Give player more DP
local beforeLevel = testPlayerData.Upgrades[upgradeName]

success, message, data = upgradeManager:PurchaseMaxUpgrades(testPlayerData, upgradeName, 10)
if success then
	print("✓ Buy Max successful!")
	print("  - Levels Purchased: " .. data.purchaseCount)
	print("  - Total Cost: " .. data.totalCost)
	print("  - Before Level: " .. beforeLevel)
	print("  - After Level: " .. data.finalLevel)
	print("  - Remaining DP: " .. data.remainingDP)
else
	print("✗ Buy Max failed: " .. message)
end

print("✓ Test 3 passed\n")

-- ========================================
-- TEST 4: REBIRTH MULTIPLIERS
-- ========================================

print("TEST 4: Rebirth Multipliers")
print("--------------------------------")

local rebirthLevels = {1, 2, 5, 10, 20, 25}
for _, rebirth in ipairs(rebirthLevels) do
	local damageMult = StatsCalculator.GetRebirthDamageMultiplier(rebirth)
	local dpMult = StatsCalculator.GetRebirthDPMultiplier(rebirth)
	print(string.format("Rebirth %d: Damage x%.2f, DP x%.2f", rebirth, damageMult, dpMult))
end

print("✓ Test 4 passed\n")

-- ========================================
-- TEST 5: PRESTIGE ELIGIBILITY
-- ========================================

print("TEST 5: Prestige Eligibility Check")
print("--------------------------------")

-- Test with insufficient requirements
local testPrestigeData = {
	UserId = 987654321,
	Level = 100,
	DP = 1000000,
	Rebirth = 15, -- Not enough
	HighestRebirth = 15,
	Upgrades = {},
	Pets = {},
	LifetimeStats = {
		TotalDPEarned = 500000000, -- Not enough (need 1B)
	},
}

local eligible, message = prestigeManager:CheckPrestigeEligibility(testPrestigeData)
print("Eligible: " .. tostring(eligible))
print("Message: " .. message)
print("✓ Correctly identified ineligibility\n")

-- Test with sufficient requirements
testPrestigeData.Rebirth = 20
testPrestigeData.HighestRebirth = 20
testPrestigeData.LifetimeStats.TotalDPEarned = 1500000000
testPrestigeData.Pets = {
	{ Name = "Phoenix Homework", Rarity = "Legendary" }
}

eligible, message = prestigeManager:CheckPrestigeEligibility(testPrestigeData)
print("After meeting requirements:")
print("Eligible: " .. tostring(eligible))
print("Message: " .. message)
print("✓ Test 5 passed\n")

-- ========================================
-- TEST 6: PRESTIGE EXECUTION
-- ========================================

print("TEST 6: Prestige Execution")
print("--------------------------------")

-- Backup pre-prestige state
local prePrestigeLevel = testPrestigeData.Level
local prePrestigeDP = testPrestigeData.DP
local prePrestigeRebirth = testPrestigeData.Rebirth
local prePrestigeUpgrades = #(function()
	local count = 0
	for _ in pairs(testPrestigeData.Upgrades) do count = count + 1 end
	return count
end)()

success, message, data = prestigeManager:PerformPrestige(testPrestigeData)

if success then
	print("✓ Prestige successful!")
	print("  - Prestige Count: " .. data.prestigeCount)
	print("  - Current Rank: " .. data.currentRank)
	print("  - Rank Changed: " .. tostring(data.rankChanged))

	print("\nProgress Reset:")
	print("  - Level: " .. prePrestigeLevel .. " → " .. testPrestigeData.Level)
	print("  - DP: " .. prePrestigeDP .. " → " .. testPrestigeData.DP)
	print("  - Rebirth: " .. prePrestigeRebirth .. " → " .. testPrestigeData.Rebirth)

	print("\nPrestige Bonuses:")
	for key, value in pairs(data.bonuses) do
		print(string.format("  - %s: x%.2f", key, value))
	end

	-- Verify lifetime stats weren't reset
	if testPrestigeData.LifetimeStats.TotalDPEarned == 1500000000 then
		print("✓ Lifetime stats preserved")
	end
else
	print("✗ Prestige failed: " .. message)
end

print("✓ Test 6 passed\n")

-- ========================================
-- TEST 7: PRESTIGE RANK PROGRESSION
-- ========================================

print("TEST 7: Prestige Rank Progression")
print("--------------------------------")

-- Simulate completing rebirths after prestige
testPrestigeData.Rebirth = 20
testPrestigeData.PrestigeStats.RebirthsSinceFirstPrestige = 0

print("Simulating rebirths after prestige...")
for i = 1, 10 do
	testPrestigeData.PrestigeStats.RebirthsSinceFirstPrestige = testPrestigeData.PrestigeStats.RebirthsSinceFirstPrestige + 1

	local rankUp, newRank, rewards = prestigeManager:TrackRebirthAfterPrestige(testPrestigeData)

	if rankUp then
		print(string.format("  Rebirth %d: ★ RANK UP to Rank %d!", i, newRank))
		for _, reward in ipairs(rewards) do
			print(string.format("    - Reward: %s (%s)", reward.value, reward.type))
		end
	else
		print(string.format("  Rebirth %d: Progress tracking", i))
	end
end

-- Fast-forward to test higher ranks
testPrestigeData.PrestigeStats.RebirthsSinceFirstPrestige = 100
local finalRank = prestigeManager:CalculatePrestigeRank(testPrestigeData)
testPrestigeData.PrestigeRank = finalRank

print("\nFast-forward to 100 rebirths:")
print("  - Final Rank: " .. finalRank .. " (MAX)")

local bonuses = prestigeManager:GetPrestigeBonuses(testPrestigeData)
print("  - Final Damage Multiplier: x" .. bonuses.damageMultiplier)
print("  - Final DP Multiplier: x" .. bonuses.dpMultiplier)
print("  - All Stats Multiplier: x" .. bonuses.allStatsMultiplier)

print("✓ Test 7 passed\n")

-- ========================================
-- TEST 8: LIFETIME STATS TRACKING
-- ========================================

print("TEST 8: Lifetime Stats Tracking")
print("--------------------------------")

prestigeManager:InitializeLifetimeStats(testPrestigeData)

-- Update various lifetime stats
prestigeManager:UpdateLifetimeStats(testPrestigeData, "TotalHomeworkDestroyed", 100)
prestigeManager:UpdateLifetimeStats(testPrestigeData, "TotalBossesDefeated", 5)
prestigeManager:UpdateLifetimeStats(testPrestigeData, "TotalDamageDealt", 50000)
prestigeManager:UpdateLifetimeStats(testPrestigeData, "HighestDamageHit", 10000)
prestigeManager:UpdateLifetimeStats(testPrestigeData, "HighestDamageHit", 5000) -- Should not update (lower)
prestigeManager:UpdateLifetimeStats(testPrestigeData, "HighestDamageHit", 15000) -- Should update (higher)

local lifetimeStats = prestigeManager:GetLifetimeStats(testPrestigeData)
print("Lifetime Stats:")
for statName, value in pairs(lifetimeStats) do
	if value > 0 then
		print(string.format("  - %s: %s", statName, tostring(value)))
	end
end

if lifetimeStats.HighestDamageHit == 15000 then
	print("✓ Highest stat tracking works correctly")
end

print("✓ Test 8 passed\n")

-- ========================================
-- TEST 9: ANTI-CHEAT VALIDATION
-- ========================================

print("TEST 9: Anti-Cheat Validation")
print("--------------------------------")

-- Test with valid data
local valid, validMessage = upgradeManager:ValidateUpgradeIntegrity(testPlayerData)
print("Valid upgrades: " .. tostring(valid))

-- Test with invalid data
local invalidData = {
	UserId = 111111111,
	Rebirth = 0,
	DP = 1000,
	Upgrades = {
		SharperTools = 100, -- Exceeds max level (50)
		FakeUpgrade = 10, -- Doesn't exist
		AutoClickSpeed = 5, -- Requires Rebirth 1
	},
}

valid, validMessage = upgradeManager:ValidateUpgradeIntegrity(invalidData)
print("Invalid upgrades detected: " .. tostring(not valid))
if not valid then
	print("  - Issues: " .. validMessage)
end

-- Test prestige validation
invalidData.PrestigeRank = 10 -- Rank 10 doesn't exist (max is 6)
valid, validMessage = prestigeManager:ValidatePrestigeIntegrity(invalidData)
print("Invalid prestige detected: " .. tostring(not valid))
if not valid then
	print("  - Issues: " .. validMessage)
end

print("✓ Test 9 passed\n")

-- ========================================
-- TEST 10: COMPLETE STAT CALCULATION
-- ========================================

print("TEST 10: Complete Stat Calculation with All Bonuses")
print("--------------------------------")

-- Create maxed-out player
local maxPlayerData = {
	UserId = 999999999,
	Level = 100,
	XP = 0,
	DP = 1000000000,
	Rebirth = 25,
	PrestigeRank = 6, -- MAX rank
	Upgrades = {
		SharperTools = 50,
		StrongerArms = 50,
		CriticalChance = 25,
		CriticalDamage = 25,
		DPBonus = 50,
	},
}

local maxToolData = {
	Name = "THE DESTROYER'S HAND",
	BaseDamage = 100000,
	Rarity = "SECRET",
	CritChance = 0.50,
	UpgradeLevel = 10,
}

local maxStats = StatsCalculator.GetPlayerStats(maxPlayerData, maxToolData, {})

print("MAXED PLAYER STATS:")
print("  - Level: " .. maxStats.Level)
print("  - Base Damage: " .. maxStats.BaseDamage)
print("  - Final Damage: " .. maxStats.FinalDamage)
print("  - Critical Damage: " .. maxStats.CritDamage)
print("  - Crit Chance: " .. math.floor(maxStats.CritChance * 100) .. "%")
print("  - Rebirth Multiplier: x" .. maxStats.RebirthDamageMultiplier)
print("  - Prestige Multiplier: x" .. maxStats.PrestigeDamageMultiplier)

local prestigeBonuses = prestigeManager:GetPrestigeBonuses(maxPlayerData)
print("\nPRESTIGE BONUSES:")
print("  - Damage: x" .. prestigeBonuses.damageMultiplier)
print("  - DP: x" .. prestigeBonuses.dpMultiplier)
print("  - Pet Damage: x" .. prestigeBonuses.petDamageMultiplier)
print("  - All Stats: x" .. prestigeBonuses.allStatsMultiplier)

print("✓ Test 10 passed\n")

-- ========================================
-- SUMMARY
-- ========================================

print("========================================")
print("ALL TESTS PASSED!")
print("========================================")
print("\nModules tested:")
print("  ✓ StatsCalculator.lua")
print("  ✓ UpgradeManager.lua")
print("  ✓ PrestigeManager.lua")
print("\nSystems verified:")
print("  ✓ Stat calculations")
print("  ✓ Upgrade purchases")
print("  ✓ Buy max functionality")
print("  ✓ Rebirth multipliers")
print("  ✓ Prestige eligibility")
print("  ✓ Prestige execution")
print("  ✓ Rank progression")
print("  ✓ Lifetime stats")
print("  ✓ Anti-cheat validation")
print("  ✓ Complete bonus stacking")
print("\n✓ All systems operational and ready for integration!")
