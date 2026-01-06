--[[
	VFXManager.lua
	Central configuration for all visual effects in Homework Destroyer

	This module defines all particle effects, animations, and visual configurations
	Used by client-side VFXController to create consistent effects

	Performance optimized with particle pooling and proper cleanup
--]]

local VFXManager = {}

-- Services
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

--[[
	PARTICLE EFFECT CONFIGURATIONS
	Each effect type has predefined particle emitter properties
--]]

VFXManager.ParticleConfigs = {
	-- Hit particles when clicking homework
	Hit = {
		Paper = {
			{
				Texture = "rbxasset://textures/particles/smoke_main.dds",
				Color = ColorSequence.new(Color3.fromRGB(255, 240, 220)),
				Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.3),
					NumberSequenceKeypoint.new(1, 0.1)
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.3, 0.8),
				Rate = 0, -- Burst only
				EmissionCount = 15,
				Speed = NumberRange.new(5, 10),
				SpreadAngle = Vector2.new(90, 90),
				Acceleration = Vector3.new(0, -5, 0),
				Rotation = NumberRange.new(0, 360),
				RotSpeed = NumberRange.new(-180, 180)
			},
			-- Ink splatter
			{
				Texture = "rbxasset://textures/particles/sparkles_main.dds",
				Color = ColorSequence.new(Color3.fromRGB(20, 20, 20)),
				Size = NumberSequence.new(0.15),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.2, 0.5),
				Rate = 0,
				EmissionCount = 8,
				Speed = NumberRange.new(3, 8),
				SpreadAngle = Vector2.new(60, 60),
				Acceleration = Vector3.new(0, -10, 0)
			}
		},

		Book = {
			{
				Texture = "rbxasset://textures/particles/smoke_main.dds",
				Color = ColorSequence.new(Color3.fromRGB(139, 90, 43)),
				Size = NumberSequence.new(0.4, 0.2),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.3),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.5, 1),
				Rate = 0,
				EmissionCount = 20,
				Speed = NumberRange.new(8, 15),
				SpreadAngle = Vector2.new(120, 120),
				Acceleration = Vector3.new(0, -8, 0),
				Rotation = NumberRange.new(0, 360),
				RotSpeed = NumberRange.new(-360, 360)
			},
			-- Dust particles
			{
				Texture = "rbxasset://textures/particles/smoke_main.dds",
				Color = ColorSequence.new(Color3.fromRGB(180, 180, 180)),
				Size = NumberSequence.new(0.5, 0.8),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.7),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.8, 1.5),
				Rate = 0,
				EmissionCount = 5,
				Speed = NumberRange.new(2, 5),
				SpreadAngle = Vector2.new(180, 180)
			}
		},

		Digital = {
			{
				Texture = "rbxasset://textures/particles/sparkles_main.dds",
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 162, 255)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				}),
				Size = NumberSequence.new(0.2, 0.05),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.3, 0.7),
				Rate = 0,
				EmissionCount = 25,
				Speed = NumberRange.new(10, 20),
				SpreadAngle = Vector2.new(120, 120),
				LightEmission = 1,
				LightInfluence = 0
			}
		},

		Project = {
			{
				Texture = "rbxasset://textures/particles/smoke_main.dds",
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 0))
				}),
				Size = NumberSequence.new(0.35, 0.15),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.4, 0.9),
				Rate = 0,
				EmissionCount = 18,
				Speed = NumberRange.new(6, 12),
				SpreadAngle = Vector2.new(100, 100),
				Acceleration = Vector3.new(0, -6, 0),
				Rotation = NumberRange.new(0, 360)
			}
		},

		Void = {
			{
				Texture = "rbxasset://textures/particles/smoke_main.dds",
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 128)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(75, 0, 130)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
				}),
				Size = NumberSequence.new(0.5, 0.2),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.5, 1.2),
				Rate = 0,
				EmissionCount = 30,
				Speed = NumberRange.new(8, 18),
				SpreadAngle = Vector2.new(180, 180),
				LightEmission = 0.8,
				LightInfluence = 0.2,
				Rotation = NumberRange.new(0, 360),
				RotSpeed = NumberRange.new(-270, 270)
			}
		}
	},

	-- Critical hit particles (more intense)
	Critical = {
		{
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			}),
			Size = NumberSequence.new(0.4, 0.1),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.8, 0.5),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Lifetime = NumberRange.new(0.5, 1),
			Rate = 0,
			EmissionCount = 40,
			Speed = NumberRange.new(15, 30),
			SpreadAngle = Vector2.new(180, 180),
			LightEmission = 1,
			LightInfluence = 0,
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-540, 540)
		},
		-- Shockwave ring
		{
			Texture = "rbxasset://textures/particles/smoke_main.dds",
			Color = ColorSequence.new(Color3.fromRGB(255, 200, 0)),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 2)
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Lifetime = NumberRange.new(0.3, 0.5),
			Rate = 0,
			EmissionCount = 10,
			Speed = NumberRange.new(20, 25),
			SpreadAngle = Vector2.new(180, 180),
			LightEmission = 0.8
		}
	},

	-- Destruction/explosion particles
	Destruction = {
		Normal = {
			{
				Texture = "rbxasset://textures/particles/sparkles_main.dds",
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 170, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 0))
				}),
				Size = NumberSequence.new(0.5, 0.2),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.7, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.5, 1.5),
				Rate = 0,
				EmissionCount = 50,
				Speed = NumberRange.new(10, 25),
				SpreadAngle = Vector2.new(180, 180),
				LightEmission = 1,
				LightInfluence = 0,
				Acceleration = Vector3.new(0, -10, 0)
			},
			-- Smoke
			{
				Texture = "rbxasset://textures/particles/smoke_main.dds",
				Color = ColorSequence.new(Color3.fromRGB(100, 100, 100)),
				Size = NumberSequence.new(1, 2),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(1, 2),
				Rate = 0,
				EmissionCount = 15,
				Speed = NumberRange.new(5, 10),
				SpreadAngle = Vector2.new(180, 180),
				Acceleration = Vector3.new(0, 5, 0),
				Rotation = NumberRange.new(0, 360),
				RotSpeed = NumberRange.new(-90, 90)
			}
		},

		Boss = {
			{
				Texture = "rbxasset://textures/particles/sparkles_main.dds",
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
					ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 150, 0)),
					ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				}),
				Size = NumberSequence.new(1.5, 0.5),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.7, 0.3),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(1, 2),
				Rate = 0,
				EmissionCount = 100,
				Speed = NumberRange.new(20, 40),
				SpreadAngle = Vector2.new(180, 180),
				LightEmission = 1,
				LightInfluence = 0,
				Acceleration = Vector3.new(0, -15, 0),
				Rotation = NumberRange.new(0, 360),
				RotSpeed = NumberRange.new(-720, 720)
			},
			-- Large smoke cloud
			{
				Texture = "rbxasset://textures/particles/smoke_main.dds",
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
				}),
				Size = NumberSequence.new(2, 4),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(2, 3),
				Rate = 0,
				EmissionCount = 25,
				Speed = NumberRange.new(8, 15),
				SpreadAngle = Vector2.new(180, 180),
				Acceleration = Vector3.new(0, 8, 0),
				Rotation = NumberRange.new(0, 360),
				RotSpeed = NumberRange.new(-120, 120)
			},
			-- Shockwave
			{
				Texture = "rbxasset://textures/particles/smoke_main.dds",
				Color = ColorSequence.new(Color3.fromRGB(255, 100, 100)),
				Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 5)
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.5, 0.8),
				Rate = 0,
				EmissionCount = 15,
				Speed = NumberRange.new(30, 40),
				SpreadAngle = Vector2.new(180, 180),
				LightEmission = 0.9
			}
		}
	},

	-- Level up particles
	LevelUp = {
		{
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			}),
			Size = NumberSequence.new(0.3, 0.1),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Lifetime = NumberRange.new(1, 2),
			Rate = 20,
			Speed = NumberRange.new(5, 10),
			SpreadAngle = Vector2.new(180, 180),
			LightEmission = 1,
			LightInfluence = 0,
			Acceleration = Vector3.new(0, 8, 0),
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-360, 360)
		},
		-- Rising aura
		{
			Texture = "rbxasset://textures/particles/smoke_main.dds",
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 255, 255))
			}),
			Size = NumberSequence.new(1, 1.5),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Lifetime = NumberRange.new(1.5, 2),
			Rate = 15,
			Speed = NumberRange.new(3, 6),
			SpreadAngle = Vector2.new(30, 30),
			LightEmission = 0.7,
			Acceleration = Vector3.new(0, 5, 0),
			VelocitySpread = Vector3.new(2, 0, 2)
		}
	}
}

--[[
	SCREEN EFFECT CONFIGURATIONS
--]]

VFXManager.ScreenEffects = {
	-- Screen shake settings
	Shake = {
		Critical = {
			Intensity = 0.5,
			Duration = 0.2,
			Frequency = 30
		},
		Destruction = {
			Intensity = 0.3,
			Duration = 0.15,
			Frequency = 25
		},
		BossDestruction = {
			Intensity = 1.2,
			Duration = 0.5,
			Frequency = 35
		}
	},

	-- Screen flash settings
	Flash = {
		Boss = {
			Color = Color3.fromRGB(255, 255, 255),
			Duration = 0.3,
			StartTransparency = 0.5,
			EndTransparency = 1
		},
		LevelUp = {
			Color = Color3.fromRGB(100, 200, 255),
			Duration = 0.4,
			StartTransparency = 0.4,
			EndTransparency = 1
		}
	}
}

--[[
	DAMAGE NUMBER CONFIGURATIONS
--]]

VFXManager.DamageNumbers = {
	Normal = {
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Color = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		StrokeTransparency = 0.5,
		Duration = 1.5,
		RiseDistance = 4,
		Spread = 1
	},

	Critical = {
		Font = Enum.Font.GothamBold,
		TextSize = 28,
		Color = Color3.fromRGB(255, 215, 0),
		StrokeColor = Color3.fromRGB(100, 0, 0),
		StrokeTransparency = 0.3,
		Duration = 2,
		RiseDistance = 6,
		Spread = 1.5,
		Prefix = "CRIT! "
	}
}

--[[
	HELPER FUNCTIONS
--]]

-- Create particle emitter from config
function VFXManager.CreateParticleEmitter(config)
	local emitter = Instance.new("ParticleEmitter")

	-- Apply all properties from config
	for property, value in pairs(config) do
		if property ~= "EmissionCount" then
			pcall(function()
				emitter[property] = value
			end)
		end
	end

	return emitter
end

-- Create multiple particle emitters from config array
function VFXManager.CreateParticleEmitters(configArray)
	local emitters = {}

	for _, config in ipairs(configArray) do
		table.insert(emitters, VFXManager.CreateParticleEmitter(config))
	end

	return emitters
end

-- Get particle config for homework type
function VFXManager.GetHitParticleConfig(homeworkType, isCritical)
	if isCritical then
		return VFXManager.ParticleConfigs.Critical
	end

	-- Get type-specific hit particles
	local hitConfigs = VFXManager.ParticleConfigs.Hit
	return hitConfigs[homeworkType] or hitConfigs.Paper
end

-- Get destruction particle config
function VFXManager.GetDestructionParticleConfig(isBoss)
	if isBoss then
		return VFXManager.ParticleConfigs.Destruction.Boss
	else
		return VFXManager.ParticleConfigs.Destruction.Normal
	end
end

-- Get level up particle config
function VFXManager.GetLevelUpParticleConfig()
	return VFXManager.ParticleConfigs.LevelUp
end

-- Get damage number config
function VFXManager.GetDamageNumberConfig(isCritical)
	if isCritical then
		return VFXManager.DamageNumbers.Critical
	else
		return VFXManager.DamageNumbers.Normal
	end
end

-- Get screen shake config
function VFXManager.GetScreenShakeConfig(effectType)
	return VFXManager.ScreenEffects.Shake[effectType]
end

-- Get screen flash config
function VFXManager.GetScreenFlashConfig(effectType)
	return VFXManager.ScreenEffects.Flash[effectType]
end

-- Format damage number text
function VFXManager.FormatDamageNumber(damage, isCritical)
	local config = VFXManager.GetDamageNumberConfig(isCritical)
	local text = tostring(math.floor(damage))

	-- Add prefix if critical
	if isCritical and config.Prefix then
		text = config.Prefix .. text
	end

	-- Add commas for large numbers
	if damage >= 1000 then
		text = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
		if text:sub(1, 1) == "," then
			text = text:sub(2)
		end
	end

	return text
end

return VFXManager
