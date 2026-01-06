--[[
	BossAI.lua

	AI controller for boss behaviors, attack patterns, and special abilities
	for Homework Destroyer

	Responsibilities:
	- Control boss movement and positioning
	- Execute attack patterns based on boss type
	- Manage special ability cooldowns and execution
	- Handle phase changes and behavior transitions
	- Target selection and threat management
	- Environmental interactions

	Author: Homework Destroyer Team
	Version: 1.0
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")

local BossAI = {}

-- ========================================
-- AI CONTROLLER CLASS
-- ========================================

local AIController = {}
AIController.__index = AIController

function BossAI.CreateController(bossInstance)
	local self = setmetatable({}, AIController)

	-- Boss reference
	self.Boss = bossInstance
	self.BossData = bossInstance.BossData
	self.Model = bossInstance.Model

	-- AI state
	self.CurrentTarget = nil
	self.State = "Idle" -- Idle, Moving, Attacking, CastingAbility
	self.LastStateChange = tick()

	-- Movement
	self.MovementType = self.BossData.Mechanics.Type or "Stationary"
	self.MovementSpeed = 16 * (self.BossData.Scale or 1)
	self.WanderRadius = 50
	self.HomePosition = self.Model.PrimaryPart.Position

	-- Attack pattern
	self.AttackPattern = self.BossData.Mechanics.AttackPattern or "None"
	self.AttackCooldown = 2.0
	self.LastAttack = 0

	-- Abilities
	self.Abilities = {}
	self.AbilityCooldowns = {}
	self:InitializeAbilities()

	-- Phase data
	self.CurrentPhaseData = nil
	self.PhaseMultipliers = {
		Speed = 1.0,
		Damage = 1.0,
		CooldownReduction = 0.0,
	}

	-- Targeting
	self.ThreatTable = {} -- [Player] = threatValue
	self.TargetUpdateInterval = 1.0
	self.LastTargetUpdate = 0

	-- Pathfinding
	self.Path = nil
	self.CurrentWaypoint = 0
	self.PathUpdateInterval = 2.0
	self.LastPathUpdate = 0

	-- Active status effects
	self.StatusEffects = {}

	warn("[BossAI] Created AI controller for " .. self.BossData.Name .. " (Type: " .. self.MovementType .. ")")

	return self
end

function AIController:InitializeAbilities()
	if not self.BossData.Mechanics.SpecialAbilities then return end

	for i, abilityData in ipairs(self.BossData.Mechanics.SpecialAbilities) do
		local ability = {
			Name = abilityData.Name,
			Data = abilityData,
			LastUsed = -abilityData.Cooldown, -- Ready immediately
			IsActive = false,
			StartTime = 0,
		}
		self.Abilities[i] = ability
		self.AbilityCooldowns[abilityData.Name] = 0
	end
end

-- ========================================
-- MAIN UPDATE LOOP
-- ========================================

function AIController:Update(deltaTime)
	if not self.Boss.IsAlive or not self.Model or not self.Model.PrimaryPart then
		return
	end

	-- Update targeting
	if tick() - self.LastTargetUpdate >= self.TargetUpdateInterval then
		self:UpdateTarget()
		self.LastTargetUpdate = tick()
	end

	-- Update abilities
	self:UpdateAbilities(deltaTime)

	-- Update status effects
	self:UpdateStatusEffects(deltaTime)

	-- Update movement and behavior based on type
	if self.MovementType == "Stationary" then
		self:UpdateStationary(deltaTime)
	elseif self.MovementType == "Wandering" then
		self:UpdateWandering(deltaTime)
	elseif self.MovementType == "Aggressive" then
		self:UpdateAggressive(deltaTime)
	elseif self.MovementType == "Teleporting" then
		self:UpdateTeleporting(deltaTime)
	elseif self.MovementType == "PhaseChange" or self.MovementType == "MultiphaseEnraged" then
		self:UpdatePhaseChange(deltaTime)
	elseif self.MovementType == "Rhythmic" then
		self:UpdateRhythmic(deltaTime)
	elseif self.MovementType == "Shapeshifter" then
		self:UpdateShapeshifter(deltaTime)
	elseif self.MovementType == "Elemental" then
		self:UpdateElemental(deltaTime)
	elseif self.MovementType == "VoidBoss" then
		self:UpdateVoidBoss(deltaTime)
	end

	-- Update attack pattern
	if self.CurrentTarget and tick() - self.LastAttack >= self.AttackCooldown then
		self:ExecuteAttackPattern()
		self.LastAttack = tick()
	end
end

-- ========================================
-- MOVEMENT BEHAVIORS
-- ========================================

function AIController:UpdateStationary(deltaTime)
	-- Boss doesn't move, just rotates to face target
	if self.CurrentTarget and self.CurrentTarget.Character then
		self:FaceTarget(self.CurrentTarget.Character.PrimaryPart)
	end
end

function AIController:UpdateWandering(deltaTime)
	-- Move around slowly, occasionally changing direction
	if not self.Path or tick() - self.LastPathUpdate >= self.PathUpdateInterval then
		local randomPos = self.HomePosition + Vector3.new(
			math.random(-self.WanderRadius, self.WanderRadius),
			0,
			math.random(-self.WanderRadius, self.WanderRadius)
		)
		self:MoveTo(randomPos)
		self.LastPathUpdate = tick()
	end

	self:FollowPath(deltaTime)
end

function AIController:UpdateAggressive(deltaTime)
	-- Chase the current target
	if self.CurrentTarget and self.CurrentTarget.Character then
		local targetPos = self.CurrentTarget.Character.PrimaryPart.Position

		if tick() - self.LastPathUpdate >= self.PathUpdateInterval then
			self:MoveTo(targetPos)
			self.LastPathUpdate = tick()
		end

		self:FollowPath(deltaTime)
	else
		-- No target, wander
		self:UpdateWandering(deltaTime)
	end
end

function AIController:UpdateTeleporting(deltaTime)
	-- Teleport to random positions periodically
	if tick() - self.LastPathUpdate >= 8.0 then -- Teleport every 8 seconds
		local randomPos = self.HomePosition + Vector3.new(
			math.random(-40, 40),
			5,
			math.random(-40, 40)
		)
		self:TeleportTo(randomPos)
		self.LastPathUpdate = tick()
	end

	-- Face target while stationary
	if self.CurrentTarget and self.CurrentTarget.Character then
		self:FaceTarget(self.CurrentTarget.Character.PrimaryPart)
	end
end

function AIController:UpdatePhaseChange(deltaTime)
	-- Behavior changes based on current phase
	if self.Boss.CurrentPhase >= 2 then
		-- More aggressive in later phases
		self:UpdateAggressive(deltaTime)
	else
		self:UpdateWandering(deltaTime)
	end
end

function AIController:UpdateRhythmic(deltaTime)
	-- Move and attack in rhythm patterns
	local timeSinceSpawn = tick() - self.Boss.SpawnTime
	local beat = math.floor(timeSinceSpawn * 2) -- 120 BPM

	if beat % 4 == 0 then -- Every 2 seconds
		self:UpdateAggressive(deltaTime)
	end
end

function AIController:UpdateShapeshifter(deltaTime)
	-- Change forms periodically
	if tick() - self.LastStateChange >= 20.0 then
		self:ChangeForm()
		self.LastStateChange = tick()
	end

	self:UpdateAggressive(deltaTime)
end

function AIController:UpdateElemental(deltaTime)
	-- Uses elemental-based movement
	self:UpdateAggressive(deltaTime)
end

function AIController:UpdateVoidBoss(deltaTime)
	-- Endgame boss with complex behavior
	-- Combines multiple movement patterns

	local healthPercent = self.Boss.CurrentHealth / self.Boss.MaxHealth

	if healthPercent < 0.25 then
		-- Desperate phase: aggressive + teleporting
		if math.random() < 0.1 then
			self:UpdateTeleporting(deltaTime)
		else
			self:UpdateAggressive(deltaTime)
		end
	elseif healthPercent < 0.50 then
		-- Mid phase: aggressive
		self:UpdateAggressive(deltaTime)
	else
		-- Early phase: wandering
		self:UpdateWandering(deltaTime)
	end
end

-- ========================================
-- MOVEMENT HELPERS
-- ========================================

function AIController:MoveTo(position)
	if not self.Model or not self.Model.PrimaryPart then return end

	-- Create path
	self.Path = PathfindingService:CreatePath({
		AgentRadius = 5,
		AgentHeight = 10,
		AgentCanJump = false,
	})

	local success, errorMsg = pcall(function()
		self.Path:ComputeAsync(self.Model.PrimaryPart.Position, position)
	end)

	if success and self.Path.Status == Enum.PathStatus.Success then
		self.CurrentWaypoint = 1
	else
		self.Path = nil
	end
end

function AIController:FollowPath(deltaTime)
	if not self.Path or not self.Model or not self.Model.PrimaryPart then return end

	local waypoints = self.Path:GetWaypoints()
	if self.CurrentWaypoint > #waypoints then return end

	local targetWaypoint = waypoints[self.CurrentWaypoint]
	local direction = (targetWaypoint.Position - self.Model.PrimaryPart.Position).Unit
	local distance = (targetWaypoint.Position - self.Model.PrimaryPart.Position).Magnitude

	-- Apply phase speed multiplier
	local speed = self.MovementSpeed * self.PhaseMultipliers.Speed

	if distance > 2 then
		-- Move towards waypoint
		local velocity = direction * speed
		self.Model.PrimaryPart.CFrame = self.Model.PrimaryPart.CFrame + velocity * deltaTime
	else
		-- Reached waypoint, move to next
		self.CurrentWaypoint = self.CurrentWaypoint + 1
	end
end

function AIController:TeleportTo(position)
	if not self.Model or not self.Model.PrimaryPart then return end

	-- Create teleport effect
	self:CreateTeleportEffect(self.Model.PrimaryPart.Position)

	-- Teleport
	self.Model:SetPrimaryPartCFrame(CFrame.new(position))

	-- Create arrival effect
	self:CreateTeleportEffect(position)
end

function AIController:FaceTarget(targetPart)
	if not targetPart or not self.Model or not self.Model.PrimaryPart then return end

	local lookAt = targetPart.Position
	local currentPos = self.Model.PrimaryPart.Position
	local direction = (lookAt - currentPos).Unit

	local newCFrame = CFrame.new(currentPos, currentPos + direction)
	self.Model.PrimaryPart.CFrame = newCFrame
end

function AIController:CreateTeleportEffect(position)
	-- Create visual effect for teleportation
	local effect = Instance.new("Part")
	effect.Size = Vector3.new(1, 1, 1)
	effect.Position = position
	effect.Anchored = true
	effect.CanCollide = false
	effect.Material = Enum.Material.Neon
	effect.BrickColor = BrickColor.new("Bright blue")
	effect.Transparency = 0.5
	effect.Parent = workspace

	-- Animate
	TweenService:Create(effect, TweenInfo.new(0.5), {
		Size = Vector3.new(10, 10, 10),
		Transparency = 1,
	}):Play()

	game:GetService("Debris"):AddItem(effect, 1)
end

-- ========================================
-- TARGETING SYSTEM
-- ========================================

function AIController:UpdateTarget()
	local nearestPlayer = nil
	local nearestDistance = math.huge
	local highestThreat = nil
	local highestThreatValue = 0

	-- Find players in range
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - self.Model.PrimaryPart.Position).Magnitude

			-- Update threat
			local threat = self.ThreatTable[player] or 0
			if distance < 100 then -- Detection range
				if threat > highestThreatValue then
					highestThreat = player
					highestThreatValue = threat
				end

				if distance < nearestDistance then
					nearestPlayer = player
					nearestDistance = distance
				end
			end
		end
	end

	-- Prioritize highest threat, fallback to nearest
	self.CurrentTarget = highestThreat or nearestPlayer
end

function AIController:AddThreat(player, amount)
	if not self.ThreatTable[player] then
		self.ThreatTable[player] = 0
	end
	self.ThreatTable[player] = self.ThreatTable[player] + amount
end

function AIController:OnDamaged(damage, player)
	if player then
		-- Add threat based on damage
		self:AddThreat(player, damage * 0.1)
	end

	-- Chance to change target to attacker
	if player and math.random() < 0.3 then
		self.CurrentTarget = player
	end
end

-- ========================================
-- ATTACK PATTERNS
-- ========================================

function AIController:ExecuteAttackPattern()
	if self.AttackPattern == "None" then
		return
	elseif self.AttackPattern == "PaperThrow" then
		self:AttackPaperThrow()
	elseif self.AttackPattern == "FoodSplatter" then
		self:AttackFoodSplatter()
	elseif self.AttackPattern == "ErrorSpam" then
		self:AttackErrorSpam()
	elseif self.AttackPattern == "PhysicalAssault" then
		self:AttackPhysicalAssault()
	elseif self.AttackPattern == "MusicalWaves" then
		self:AttackMusicalWaves()
	elseif self.AttackPattern == "Creative" then
		self:AttackCreative()
	elseif self.AttackPattern == "Chemical" then
		self:AttackChemical()
	elseif self.AttackPattern == "Authoritative" then
		self:AttackAuthoritative()
	elseif self.AttackPattern == "Apocalyptic" then
		self:AttackApocalyptic()
	elseif self.AttackPattern == "FinalExam" then
		self:AttackFinalExam()
	end
end

function AIController:AttackPaperThrow()
	if not self.CurrentTarget or not self.CurrentTarget.Character then return end

	-- Create paper projectile
	self:CreateProjectile(self.CurrentTarget.Character.HumanoidRootPart.Position, {
		Damage = self.Boss.Damage * 0.5,
		Speed = 50,
		Size = Vector3.new(2, 0.1, 2),
		Color = Color3.new(1, 1, 1),
	})
end

function AIController:AttackFoodSplatter()
	if not self.CurrentTarget or not self.CurrentTarget.Character then return end

	-- Create multiple food projectiles in spread pattern
	for i = 1, 3 do
		local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
		local targetPos = self.CurrentTarget.Character.HumanoidRootPart.Position + offset

		self:CreateProjectile(targetPos, {
			Damage = self.Boss.Damage * 0.4,
			Speed = 40,
			Size = Vector3.new(1, 1, 1),
			Color = Color3.new(0.5, 0.3, 0.1),
		})
	end
end

function AIController:AttackErrorSpam()
	-- Create error message projectiles in all directions
	for i = 1, 8 do
		local angle = (i / 8) * math.pi * 2
		local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local targetPos = self.Model.PrimaryPart.Position + (direction * 30)

		self:CreateProjectile(targetPos, {
			Damage = self.Boss.Damage * 0.3,
			Speed = 60,
			Size = Vector3.new(2, 2, 0.5),
			Color = Color3.new(0, 0, 1),
		})
	end
end

function AIController:AttackPhysicalAssault()
	if not self.CurrentTarget or not self.CurrentTarget.Character then return end

	-- Melee range attack
	local distance = (self.CurrentTarget.Character.HumanoidRootPart.Position - self.Model.PrimaryPart.Position).Magnitude

	if distance < 15 then
		-- In range, damage player
		self:DamagePlayer(self.CurrentTarget, self.Boss.Damage)
	end
end

function AIController:AttackMusicalWaves()
	-- Create sound wave effect
	self:CreateAoEEffect(self.Model.PrimaryPart.Position, 30, self.Boss.Damage * 0.4)
end

function AIController:AttackCreative()
	if not self.CurrentTarget or not self.CurrentTarget.Character then return end

	-- Random between projectile and AoE
	if math.random() < 0.5 then
		self:AttackPaperThrow()
	else
		self:AttackMusicalWaves()
	end
end

function AIController:AttackChemical()
	-- Create toxic cloud
	self:CreateAoEEffect(self.Model.PrimaryPart.Position, 25, self.Boss.Damage * 0.3)
end

function AIController:AttackAuthoritative()
	if not self.CurrentTarget or not self.CurrentTarget.Character then return end

	-- Powerful single-target attack
	self:CreateProjectile(self.CurrentTarget.Character.HumanoidRootPart.Position, {
		Damage = self.Boss.Damage * 0.8,
		Speed = 70,
		Size = Vector3.new(3, 3, 3),
		Color = Color3.new(1, 0, 0),
	})
end

function AIController:AttackApocalyptic()
	-- Massive multi-target attack
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - self.Model.PrimaryPart.Position).Magnitude
			if distance < 80 then
				self:CreateProjectile(player.Character.HumanoidRootPart.Position, {
					Damage = self.Boss.Damage * 0.6,
					Speed = 80,
					Size = Vector3.new(4, 4, 4),
					Color = Color3.new(0.5, 0, 0.5),
				})
			end
		end
	end
end

function AIController:AttackFinalExam()
	-- Rapid projectile attack
	if not self.CurrentTarget or not self.CurrentTarget.Character then return end

	for i = 1, 5 do
		task.delay(i * 0.2, function()
			if self.CurrentTarget and self.CurrentTarget.Character then
				self:AttackPaperThrow()
			end
		end)
	end
end

-- ========================================
-- PROJECTILE SYSTEM
-- ========================================

function AIController:CreateProjectile(targetPosition, config)
	if not self.Model or not self.Model.PrimaryPart then return end

	local projectile = Instance.new("Part")
	projectile.Size = config.Size or Vector3.new(2, 2, 2)
	projectile.Position = self.Model.PrimaryPart.Position + Vector3.new(0, 5, 0)
	projectile.Anchored = false
	projectile.CanCollide = false
	projectile.Material = Enum.Material.Neon
	projectile.Color = config.Color or Color3.new(1, 0, 0)
	projectile.Parent = workspace

	-- Add velocity
	local direction = (targetPosition - projectile.Position).Unit
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = direction * (config.Speed or 50)
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Parent = projectile

	-- Store damage value
	local damageValue = Instance.new("NumberValue")
	damageValue.Name = "Damage"
	damageValue.Value = config.Damage or 100
	damageValue.Parent = projectile

	-- Collision detection
	projectile.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") then
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				self:DamagePlayer(player, config.Damage or 100)
				projectile:Destroy()
			end
		end
	end)

	-- Cleanup after 5 seconds
	game:GetService("Debris"):AddItem(projectile, 5)
end

function AIController:CreateAoEEffect(position, radius, damage)
	-- Create visual effect
	local effect = Instance.new("Part")
	effect.Size = Vector3.new(1, 1, 1)
	effect.Position = position
	effect.Anchored = true
	effect.CanCollide = false
	effect.Material = Enum.Material.Neon
	effect.BrickColor = BrickColor.new("Bright red")
	effect.Transparency = 0.7
	effect.Shape = Enum.PartType.Ball
	effect.Parent = workspace

	-- Expand animation
	TweenService:Create(effect, TweenInfo.new(0.5), {
		Size = Vector3.new(radius * 2, radius * 2, radius * 2),
		Transparency = 1,
	}):Play()

	-- Damage players in radius
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - position).Magnitude
			if distance <= radius then
				self:DamagePlayer(player, damage)
			end
		end
	end

	game:GetService("Debris"):AddItem(effect, 1)
end

function AIController:DamagePlayer(player, damage)
	if not player or not player.Character then return end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	if humanoid then
		-- Apply phase damage multiplier
		local finalDamage = damage * self.PhaseMultipliers.Damage

		-- In real implementation, would handle through combat system
		warn("[BossAI] Boss damaged " .. player.Name .. " for " .. finalDamage .. " damage")

		-- Would actually damage player here
		-- humanoid:TakeDamage(finalDamage)
	end
end

-- ========================================
-- ABILITY SYSTEM
-- ========================================

function AIController:UpdateAbilities(deltaTime)
	local currentTime = tick()

	for _, ability in ipairs(self.Abilities) do
		-- Check if ability is off cooldown
		local cooldown = ability.Data.Cooldown
		local cooldownReduction = self.PhaseMultipliers.CooldownReduction
		local adjustedCooldown = cooldown * (1 - cooldownReduction)

		if currentTime - ability.LastUsed >= adjustedCooldown then
			-- Check if should use ability (random chance or conditional)
			if self:ShouldUseAbility(ability) then
				self:UseAbility(ability)
				ability.LastUsed = currentTime
			end
		end

		-- Update active abilities
		if ability.IsActive then
			if currentTime - ability.StartTime >= ability.Data.Duration then
				ability.IsActive = false
				self:EndAbility(ability)
			end
		end
	end
end

function AIController:ShouldUseAbility(ability)
	-- Check ability conditions
	if ability.Data.Trigger then
		local healthPercent = self.Boss.CurrentHealth / self.Boss.MaxHealth
		if healthPercent > ability.Data.Trigger then
			return false -- Not at trigger threshold yet
		end
	end

	-- Random chance to use ability (30% when off cooldown)
	return math.random() < 0.30
end

function AIController:UseAbility(ability)
	warn("[BossAI] Boss using ability: " .. ability.Name)

	ability.IsActive = true
	ability.StartTime = tick()

	local effect = ability.Data.Effect

	if effect == "DefenseBoost" then
		self:AbilityDefenseBoost(ability)
	elseif effect == "SummonMinions" then
		self:AbilitySummonMinions(ability)
	elseif effect == "RandomBuff" then
		self:AbilityRandomBuff(ability)
	elseif effect == "AreaDamage" then
		self:AbilityAreaDamage(ability)
	elseif effect == "Invulnerable" then
		self:AbilityInvulnerable(ability)
	elseif effect == "PlayerDebuff" then
		self:AbilityPlayerDebuff(ability)
	elseif effect == "StunPlayers" then
		self:AbilityStunPlayers(ability)
	elseif effect == "SelfHeal" then
		self:AbilitySelfHeal(ability)
	elseif effect == "ProjectileBarrage" then
		self:AbilityProjectileBarrage(ability)
	elseif effect == "SonicWave" then
		self:AbilitySonicWave(ability)
	elseif effect == "RampingDamage" then
		self:AbilityRampingDamage(ability)
	elseif effect == "HomingProjectiles" then
		self:AbilityHomingProjectiles(ability)
	elseif effect == "SlowPlayers" then
		self:AbilitySlowPlayers(ability)
	elseif effect == "Evasion" then
		self:AbilityEvasion(ability)
	elseif effect == "SummonClones" then
		self:AbilitySummonClones(ability)
	elseif effect == "ZoneDoT" then
		self:AbilityZoneDoT(ability)
	elseif effect == "CounterExplosion" then
		self:AbilityCounterExplosion(ability)
	elseif effect == "HealingDebuff" then
		self:AbilityHealingDebuff(ability)
	elseif effect == "AdaptiveDefense" then
		self:AbilityAdaptiveDefense(ability)
	elseif effect == "ImmobilizePlayer" then
		self:AbilityImmobilizePlayer(ability)
	elseif effect == "Banish" then
		self:AbilityBanish(ability)
	elseif effect == "VulnerabilityMark" then
		self:AbilityVulnerabilityMark(ability)
	elseif effect == "MeteorStorm" then
		self:AbilityMeteorStorm(ability)
	elseif effect == "ScramblePlayers" then
		self:AbilityScramblePlayers(ability)
	elseif effect == "HealthDrain" then
		self:AbilityHealthDrain(ability)
	elseif effect == "SummonElites" then
		self:AbilitySummonElites(ability)
	elseif effect == "PhaseShift" then
		self:AbilityPhaseShift(ability)
	elseif effect == "GravityInvert" then
		self:AbilityGravityInvert(ability)
	end
end

function AIController:EndAbility(ability)
	warn("[BossAI] Boss ability ended: " .. ability.Name)
	-- Clean up ability effects
end

-- ========================================
-- ABILITY IMPLEMENTATIONS
-- ========================================

function AIController:AbilityDefenseBoost(ability)
	self.Boss.Defense = self.Boss.Defense + (100 * ability.Data.Value)
end

function AIController:AbilitySummonMinions(ability)
	local count = ability.Data.Value or 3
	for i = 1, count do
		-- In real implementation, spawn minion enemies
		warn("[BossAI] Spawning minion " .. i .. "/" .. count)
	end
end

function AIController:AbilityRandomBuff(ability)
	if math.random() < 0.5 then
		self.PhaseMultipliers.Damage = self.PhaseMultipliers.Damage + ability.Data.Value
	else
		self.PhaseMultipliers.Speed = self.PhaseMultipliers.Speed + ability.Data.Value
	end
end

function AIController:AbilityAreaDamage(ability)
	self:CreateAoEEffect(
		self.Model.PrimaryPart.Position,
		ability.Data.Radius or 30,
		ability.Data.Value or 500
	)
end

function AIController:AbilityInvulnerable(ability)
	self.Boss.IsImmune = true
	-- Will be cleared when ability ends
end

function AIController:AbilityPlayerDebuff(ability)
	-- Would apply debuff to all players in range
	warn("[BossAI] Applying player debuff: " .. ability.Name)
end

function AIController:AbilityStunPlayers(ability)
	local radius = ability.Data.Radius or 40
	self:CreateAoEEffect(self.Model.PrimaryPart.Position, radius, 0)
	-- Would apply stun effect to players
end

function AIController:AbilitySelfHeal(ability)
	local healAmount = self.Boss.MaxHealth * ability.Data.Value
	self.Boss:Heal(healAmount)
end

function AIController:AbilityProjectileBarrage(ability)
	local count = ability.Data.ProjectileCount or 10
	local damage = ability.Data.Value or 100

	for i = 1, count do
		task.delay(i * 0.1, function()
			if self.CurrentTarget and self.CurrentTarget.Character then
				self:CreateProjectile(self.CurrentTarget.Character.HumanoidRootPart.Position, {
					Damage = damage,
					Speed = 60,
					Size = Vector3.new(1, 1, 1),
					Color = Color3.new(1, 1, 0),
				})
			end
		end)
	end
end

function AIController:AbilitySonicWave(ability)
	self:CreateAoEEffect(
		self.Model.PrimaryPart.Position,
		ability.Data.Radius or 50,
		ability.Data.Value or 800
	)
end

function AIController:AbilityRampingDamage(ability)
	-- Increase damage over time during ability duration
	task.spawn(function()
		local startTime = tick()
		while ability.IsActive do
			local elapsed = tick() - startTime
			self.PhaseMultipliers.Damage = 1 + (elapsed * ability.Data.Value)
			task.wait(1)
		end
		self.PhaseMultipliers.Damage = 1.0
	end)
end

function AIController:AbilityHomingProjectiles(ability)
	local count = ability.Data.ProjectileCount or 8
	for i = 1, count do
		local randomPlayer = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
		if randomPlayer and randomPlayer.Character then
			self:CreateProjectile(randomPlayer.Character.HumanoidRootPart.Position, {
				Damage = ability.Data.Value or 150,
				Speed = 50,
				Size = Vector3.new(2, 2, 2),
				Color = Color3.new(1, 0, 1),
			})
		end
	end
end

function AIController:AbilitySlowPlayers(ability)
	self:CreateAoEEffect(
		self.Model.PrimaryPart.Position,
		ability.Data.Radius or 35,
		0
	)
	-- Would apply slow effect
end

function AIController:AbilityEvasion(ability)
	-- Boss has chance to dodge attacks
	-- Implemented in damage calculation
end

function AIController:AbilitySummonClones(ability)
	-- Would create clone instances
	warn("[BossAI] Summoning " .. ability.Data.Value .. " clones")
end

function AIController:AbilityZoneDoT(ability)
	-- Apply damage over time to entire zone
	task.spawn(function()
		local startTime = tick()
		while ability.IsActive do
			for _, player in ipairs(Players:GetPlayers()) do
				self:DamagePlayer(player, ability.Data.Value or 100)
			end
			task.wait(1)
		end
	end)
end

function AIController:AbilityCounterExplosion(ability)
	self:CreateAoEEffect(
		self.Model.PrimaryPart.Position,
		ability.Data.Radius or 60,
		ability.Data.Value or 2000
	)
end

function AIController:AbilityHealingDebuff(ability)
	warn("[BossAI] Applying healing debuff")
end

function AIController:AbilityAdaptiveDefense(ability)
	self.Boss.Defense = self.Boss.Defense + (100 * ability.Data.Value)
end

function AIController:AbilityImmobilizePlayer(ability)
	if self.CurrentTarget then
		warn("[BossAI] Immobilizing " .. self.CurrentTarget.Name)
	end
end

function AIController:AbilityBanish(ability)
	if self.CurrentTarget then
		warn("[BossAI] Banishing " .. self.CurrentTarget.Name)
	end
end

function AIController:AbilityVulnerabilityMark(ability)
	if self.CurrentTarget then
		warn("[BossAI] Marking " .. self.CurrentTarget.Name)
	end
end

function AIController:AbilityMeteorStorm(ability)
	local count = ability.Data.MeteorCount or 50
	for i = 1, count do
		task.delay(i * 0.1, function()
			local randomPos = self.Model.PrimaryPart.Position + Vector3.new(
				math.random(-50, 50),
				50,
				math.random(-50, 50)
			)
			self:CreateProjectile(randomPos - Vector3.new(0, 50, 0), {
				Damage = ability.Data.Value or 800,
				Speed = 100,
				Size = Vector3.new(3, 3, 3),
				Color = Color3.new(1, 0.5, 0),
			})
		end)
	end
end

function AIController:AbilityScramblePlayers(ability)
	warn("[BossAI] Scrambling player positions")
end

function AIController:AbilityHealthDrain(ability)
	task.spawn(function()
		while ability.IsActive do
			local totalDrained = 0
			for _, player in ipairs(Players:GetPlayers()) do
				local drained = ability.Data.Value or 500
				self:DamagePlayer(player, drained)
				totalDrained = totalDrained + drained
			end

			-- Convert to boss health
			local healing = totalDrained * (ability.Data.ConversionRate or 0.5)
			self.Boss:Heal(healing)

			task.wait(1)
		end
	end)
end

function AIController:AbilitySummonElites(ability)
	warn("[BossAI] Summoning elite enemies")
end

function AIController:AbilityPhaseShift(ability)
	self.Boss.IsImmune = true
	self:TeleportTo(self.HomePosition)
end

function AIController:AbilityGravityInvert(ability)
	warn("[BossAI] Inverting gravity")
end

-- ========================================
-- STATUS EFFECTS
-- ========================================

function AIController:UpdateStatusEffects(deltaTime)
	-- Update active status effects (buffs/debuffs)
	-- Would track burning, slowing, etc.
end

-- ========================================
-- PHASE CHANGES
-- ========================================

function AIController:OnPhaseChange(phaseData)
	warn("[BossAI] Phase change: " .. phaseData.Name)

	self.CurrentPhaseData = phaseData

	-- Update multipliers
	if phaseData.SpeedMultiplier then
		self.PhaseMultipliers.Speed = phaseData.SpeedMultiplier
		self.MovementSpeed = 16 * (self.BossData.Scale or 1) * phaseData.SpeedMultiplier
	end

	if phaseData.DamageMultiplier then
		self.PhaseMultipliers.Damage = phaseData.DamageMultiplier
	end

	if phaseData.AbilityCooldownReduction then
		self.PhaseMultipliers.CooldownReduction = phaseData.AbilityCooldownReduction
	end

	-- Change behavior if enraged
	if phaseData.Enraged then
		self.AttackCooldown = self.AttackCooldown * 0.5 -- Attack twice as fast
	end

	if phaseData.Berserk then
		self.AttackCooldown = 0.5 -- Very fast attacks
	end
end

function AIController:ChangeForm()
	if not self.BossData.Mechanics.Forms then return end

	local forms = self.BossData.Mechanics.Forms
	local form = forms[math.random(1, #forms)]

	warn("[BossAI] Changing to form: " .. form.Name)

	-- Apply form bonuses
	if form.DefenseBonus then
		self.Boss.Defense = self.Boss.Defense * (1 + form.DefenseBonus)
	end

	-- Would update visual appearance here
end

-- ========================================
-- CLEANUP
-- ========================================

function AIController:OnDefeat()
	warn("[BossAI] Boss defeated, cleaning up AI")
	self.State = "Defeated"
end

function AIController:Destroy()
	-- Clean up connections and references
	self.Boss = nil
	self.Model = nil
	self.CurrentTarget = nil
	self.ThreatTable = {}
	self.Abilities = {}
end

return BossAI
