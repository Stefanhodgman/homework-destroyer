# Visual Effects System Documentation

## Overview

The VFX (Visual Effects) system for Homework Destroyer provides a complete, production-ready solution for all visual and audio feedback in the game. The system is highly optimized with object pooling, smooth animations, and coordinated audio-visual effects.

## Architecture

### Core Modules

1. **VFXManager** (`ReplicatedStorage/SharedModules/VFXManager.lua`)
   - Central configuration for all particle effects
   - Defines damage numbers, screen effects, and particle emitter settings
   - Shared between client and server for consistent configuration

2. **VFXController** (`StarterPlayer/StarterPlayerScripts/VFXController.lua`)
   - Client-side controller that creates and manages all visual effects
   - Listens for server events and displays effects
   - Implements object pooling for performance optimization

3. **SoundManager** (`ReplicatedStorage/SharedModules/SoundManager.lua`)
   - Manages all audio playback
   - Coordinates with VFX for synchronized audio-visual effects
   - Handles background music and 3D spatial audio

4. **CombatManager** (`ServerStorage/Modules/CombatManager.lua`)
   - Server-side combat logic
   - Triggers VFX events via RemoteEvents
   - Coordinates destruction effects with all nearby players

5. **HomeworkSpawner** (`ServerStorage/Modules/HomeworkSpawner.lua`)
   - Manages homework spawning and health tracking
   - Implements smooth health bar animations with TweenService

## Features

### 1. Damage Numbers

Floating text that appears when homework is clicked, showing damage dealt.

**Features:**
- Normal and critical hit variants
- Different colors (white for normal, gold for critical)
- Smooth upward animation with fade out
- Number formatting with commas for large values
- Random spread to prevent overlap
- Object pooling for performance

**Configuration:**
```lua
VFXManager.DamageNumbers = {
    Normal = {
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Color = Color3.fromRGB(255, 255, 255),
        Duration = 1.5,
        RiseDistance = 4
    },
    Critical = {
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        Color = Color3.fromRGB(255, 215, 0),
        Duration = 2,
        RiseDistance = 6,
        Prefix = "CRIT! "
    }
}
```

### 2. Particle Effects

#### Hit Particles
Appear when clicking homework, customized by homework type:

- **Paper**: White paper scraps with ink splatters
- **Book**: Brown particles with dust clouds
- **Digital**: Blue/cyan sparkles with light emission
- **Project**: Orange/yellow particles
- **Void**: Purple/black particles with high light emission

#### Critical Hit Particles
- Gold sparkles radiating outward
- Shockwave ring effect
- More particles and higher speed than normal hits

#### Destruction Particles
- **Normal**: Yellow-orange explosion with smoke
- **Boss**: Massive red-orange explosion with large smoke clouds and shockwave

#### Level Up Particles
- Cyan sparkles rising upward
- Glowing aura effect around player
- Follows player for 3 seconds

**Performance Optimization:**
- Particle parts pooled and reused
- Automatic cleanup with Debris service
- Burst emission for short effects
- Configurable emission counts

### 3. Screen Effects

#### Screen Shake
Camera shake on critical hits and explosions:

- **Critical**: Moderate shake (0.5 intensity, 0.2s duration)
- **Destruction**: Light shake (0.3 intensity, 0.15s duration)
- **Boss Destruction**: Heavy shake (1.2 intensity, 0.5s duration)

Features:
- Smooth falloff over duration
- Non-intrusive (doesn't interfere with gameplay)
- Frequency-based oscillation

#### Screen Flash
Full-screen color flash for dramatic moments:

- **Boss Destruction**: White flash
- **Level Up**: Cyan flash

Features:
- Smooth fade out with TweenService
- Configurable colors and duration
- Layered at high DisplayOrder

### 4. Health Bar Animations

Smooth health bar updates with visual feedback:

- **Size Tween**: Health bar smoothly shrinks (0.15s duration)
- **Color Transition**: Smooth color change based on health
  - Green: >50% health
  - Yellow: 25-50% health
  - Red: <25% health
- **Flash Effect**: Brief white flash when damaged
- **Text Update**: Shows current/max HP with homework name

### 5. Sound Integration

Coordinated audio-visual effects:

- **Hit Sounds**: Type-specific sounds for each homework type
- **Critical Hits**: Powerful impact sound
- **Destruction**: Explosion sounds (normal and boss variants)
- **Level Up**: Triumphant fanfare
- **3D Spatial Audio**: Sounds positioned at effect location

## Remote Events

The system uses three main RemoteEvents for client-server communication:

### DamageDealt
Fired by server to show damage numbers and hit effects:
```lua
DamageDealtEvent:FireClient(player, {
    Position = Vector3,
    Damage = number,
    IsCritical = boolean,
    HomeworkType = string -- "Paper", "Book", "Digital", "Project", "Void"
})
```

### PlayEffect
Fired by server to trigger visual effects:
```lua
PlayEffectEvent:FireClient(player, {
    Type = string, -- "Destruction", "LevelUp", "Hit", "ScreenShake", "ScreenFlash"
    Position = Vector3,
    ExtraData = {
        IsBoss = boolean,
        HomeworkType = string,
        IsCritical = boolean,
        ShakeType = string,
        FlashType = string
    }
})
```

### ShowNotification
Fired by server for notifications (triggers level up effect):
```lua
ShowNotificationEvent:FireClient(player, notifType, title, message, duration)
```

## Performance Optimization

### Object Pooling
- **Damage Numbers**: Pool of up to 20 BillboardGuis
- **Particle Parts**: Pool of up to 20 parts with attachments
- **Sounds**: Separate pools for 2D (10) and 3D (20) sounds

Benefits:
- Reduced garbage collection
- Instant effect creation (no Instance.new delays)
- Consistent performance during combat

### Cleanup
- Automatic cleanup with Debris service
- Task-based delayed cleanup
- Connection cleanup on effect end
- Regular cleanup loop for orphaned objects

### Network Optimization
- Effects only sent to players within render distance (500 studs)
- Burst particle emission (no continuous emitters for hits)
- Minimal data sent over RemoteEvents

## Usage Examples

### Server-Side (Trigger Effects)

```lua
-- Trigger destruction effect for all nearby players
local PlayEffectEvent = RemoteEventsModule.GetEvent("PlayEffect")
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character and player.Character.PrimaryPart then
        local distance = (player.Character.PrimaryPart.Position - position).Magnitude
        if distance < 500 then
            PlayEffectEvent:FireClient(player, {
                Type = "Destruction",
                Position = position,
                ExtraData = {
                    IsBoss = true
                }
            })
        end
    end
end
```

### Client-Side (Manual Effect Triggering)

```lua
-- Manually trigger damage number
local VFXController = require(script.VFXController)
VFXController.ShowDamageNumber(Vector3.new(0, 10, 0), 1234, true)

-- Manually trigger particles
VFXController.ShowHitParticles(Vector3.new(0, 10, 0), "Paper", false)

-- Manually trigger screen shake
VFXController.ScreenShake("Critical")

-- Manually trigger screen flash
VFXController.ScreenFlash("Boss")
```

## Configuration Guide

### Adding New Particle Effects

1. Open `VFXManager.lua`
2. Add particle configuration to `VFXManager.ParticleConfigs`
3. Create array of particle emitter configs with properties:
   - Texture, Color, Size, Transparency, Lifetime
   - Rate, Speed, SpreadAngle, Acceleration
   - LightEmission, Rotation, etc.

Example:
```lua
VFXManager.ParticleConfigs.NewEffect = {
    {
        Texture = "rbxasset://textures/particles/sparkles_main.dds",
        Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)),
        Size = NumberSequence.new(0.5),
        Lifetime = NumberRange.new(1, 2),
        Rate = 0,
        EmissionCount = 20,
        Speed = NumberRange.new(10, 20)
    }
}
```

### Customizing Screen Effects

Edit `VFXManager.ScreenEffects`:

```lua
VFXManager.ScreenEffects.Shake.NewShake = {
    Intensity = 0.8,  -- Higher = more shake
    Duration = 0.3,   -- Seconds
    Frequency = 30    -- Oscillations per second
}

VFXManager.ScreenEffects.Flash.NewFlash = {
    Color = Color3.fromRGB(255, 0, 0),
    Duration = 0.5,
    StartTransparency = 0.3,
    EndTransparency = 1
}
```

### Adjusting Damage Number Appearance

Edit `VFXManager.DamageNumbers`:

```lua
VFXManager.DamageNumbers.Custom = {
    Font = Enum.Font.GothamBold,
    TextSize = 24,
    Color = Color3.fromRGB(0, 255, 0),
    StrokeColor = Color3.fromRGB(0, 0, 0),
    StrokeTransparency = 0.5,
    Duration = 2,
    RiseDistance = 5,
    Spread = 2,
    Prefix = "MEGA! "
}
```

## Troubleshooting

### Effects Not Showing
1. Check RemoteEvents are initialized on server
2. Verify player is within render distance (500 studs)
3. Check VFXController is running (should print initialization message)
4. Ensure camera exists and is accessible

### Performance Issues
1. Reduce particle emission counts in VFXManager
2. Increase pool cleanup intervals
3. Reduce render distance for effects
4. Disable particle emission for distant effects

### Sound Not Playing
1. Check SoundManager is initialized
2. Verify sound IDs are valid (not placeholders)
3. Check volume settings aren't muted
4. Ensure SoundService is accessible

### Health Bars Not Animating
1. Verify TweenService is imported in HomeworkSpawner
2. Check health bar UI elements exist
3. Ensure UpdateHomeworkHealth is being called
4. Check for tween conflicts

## Best Practices

1. **Always use RemoteEvents for server-triggered effects** - Never try to create effects directly on client from server scripts

2. **Pool objects for frequently-created effects** - Damage numbers and particles should always use pooling

3. **Clean up effects properly** - Use Debris service or task.delay for automatic cleanup

4. **Test performance with many simultaneous effects** - Ensure game runs smoothly during intense combat

5. **Coordinate audio and visual effects** - Always trigger sound with visual effect for best player experience

6. **Provide visual feedback for all player actions** - Every click should have some visual response

7. **Use appropriate effect intensity** - Don't overdo screen shake or particle counts

## Future Enhancements

Potential improvements for the VFX system:

- [ ] Achievement unlock effects with unique particles
- [ ] Pet-specific attack particles
- [ ] Tool-specific hit effects based on weapon type
- [ ] Zone transition effects
- [ ] Boss intro/outro animations
- [ ] Rebirth/Prestige celebration effects
- [ ] Combo hit multiplier visual feedback
- [ ] Damage type indicators (normal, elemental, bonus, etc.)
- [ ] Hit streak effects
- [ ] Particle LOD (level of detail) based on distance
- [ ] Custom VFX for special events/holidays

## Credits

VFX system designed for Homework Destroyer by Claude Code.
All particle effects, screen effects, and damage numbers are production-ready and performance-optimized.
