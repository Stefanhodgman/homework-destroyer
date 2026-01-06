# VFX System Architecture

## System Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           SERVER SIDE                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌────────────────────┐          ┌─────────────────────┐               │
│  │  CombatManager     │          │  HomeworkSpawner    │               │
│  │                    │          │                     │               │
│  │  - HandleClick()   │          │  - SpawnHomework()  │               │
│  │  - CalculateDamage │          │  - UpdateHealth()   │               │
│  │  - DestroyHomework │──────────│  - RemoveHomework() │               │
│  │  - AwardRewards()  │          │                     │               │
│  └─────────┬──────────┘          └─────────────────────┘               │
│            │                                                             │
│            │ Fires RemoteEvents                                         │
│            ▼                                                             │
│  ┌────────────────────────────────────────────────────┐                │
│  │            Remote Events (ReplicatedStorage)       │                │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │                │
│  │  │ DamageDealt  │  │ PlayEffect   │  │ ShowNoti │ │                │
│  │  └──────────────┘  └──────────────┘  └──────────┘ │                │
│  └────────────────────────────────────────────────────┘                │
│            │                       │                │                   │
└────────────┼───────────────────────┼────────────────┼───────────────────┘
             │                       │                │
             │    Network Boundary   │                │
             ▼                       ▼                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           CLIENT SIDE                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                     VFXController                                 │  │
│  │  ┌────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │  │
│  │  │ Event Handlers │→ │ Effect Creators │→ │ Object Pools    │   │  │
│  │  │                │  │                 │  │                 │   │  │
│  │  │ onDamageDealt  │  │ ShowDamageNum   │  │ DamageNumberPool│   │  │
│  │  │ onPlayEffect   │  │ CreateParticles │  │ ParticlePartPool│   │  │
│  │  │ onNotification │  │ ScreenShake     │  │                 │   │  │
│  │  │                │  │ ScreenFlash     │  │                 │   │  │
│  │  └────────────────┘  └─────────────────┘  └─────────────────┘   │  │
│  └──────────────┬────────────────────┬──────────────────────────────┘  │
│                 │                    │                                  │
│                 │                    │                                  │
│                 ▼                    ▼                                  │
│  ┌──────────────────────┐  ┌─────────────────────┐                    │
│  │    VFXManager        │  │   SoundManager       │                    │
│  │  (Configuration)     │  │  (Audio Playback)    │                    │
│  │                      │  │                      │                    │
│  │ - ParticleConfigs    │  │ - PlayHitSound()     │                    │
│  │ - ScreenEffects      │  │ - PlayDestruction()  │                    │
│  │ - DamageNumbers      │  │ - PlayLevelUp()      │                    │
│  │ - Helper Functions   │  │ - 3D Spatial Audio   │                    │
│  └──────────────────────┘  └─────────────────────┘                    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Damage Number Flow
```
Player Clicks Homework
        ↓
CombatManager.HandleClick()
        ↓
CalculateDamage() → Returns {damage, isCritical, targetType}
        ↓
ShowDamageNumber() → FireClient(DamageDealt)
        ↓
─────── NETWORK ───────
        ↓
VFXController.onDamageDealt()
        ↓
┌───────────────┬──────────────┐
↓               ↓              ↓
ShowDamageNumber  ShowHitParticles  PlayHitSound
↓               ↓              ↓
BillboardGui    ParticleEmitters   Sound Instance
```

### 2. Destruction Effect Flow
```
Homework Health <= 0
        ↓
CombatManager.DestroyHomework()
        ↓
PlayDestructionEffect() → FireClient(PlayEffect) to all nearby
        ↓
─────── NETWORK ───────
        ↓
VFXController.onPlayEffect()
        ↓
ShowDestructionEffect()
        ↓
┌──────────────┬─────────────┬──────────────┐
↓              ↓             ↓              ↓
CreateParticles ScreenShake  ScreenFlash  PlaySound
↓              ↓             ↓              ↓
Explosion      Camera CFrame Screen Frame   Audio
Particles      Offset        Fade Out       3D Position
```

### 3. Level Up Effect Flow
```
Player Gains XP
        ↓
CombatManager.CheckLevelUp()
        ↓
ShowNotification("LevelUp") → FireClient
        ↓
─────── NETWORK ───────
        ↓
VFXController.onNotification()
        ↓
ShowLevelUpEffect()
        ↓
┌──────────────┬─────────────┬──────────────┐
↓              ↓             ↓              ↓
CreateParticles ScreenFlash  PlaySound    Follow Player
(Continuous)   (Cyan)       (Fanfare)    (3 seconds)
```

## Component Responsibilities

### Server Components

#### CombatManager
- **Purpose**: Combat logic and calculations
- **Responsibilities**:
  - Calculate damage (normal vs critical)
  - Update homework health
  - Trigger VFX events via RemoteEvents
  - Award rewards on destruction
- **VFX Integration**:
  - Fires DamageDealt with homework type
  - Fires PlayEffect for destruction
  - Coordinates with all nearby players

#### HomeworkSpawner
- **Purpose**: Homework lifecycle management
- **Responsibilities**:
  - Spawn homework objects
  - Manage health bars
  - Update health display with animations
  - Clean up destroyed homework
- **VFX Integration**:
  - Smooth health bar tweens
  - Color transitions
  - Flash effects on damage

### Client Components

#### VFXController
- **Purpose**: Main VFX orchestrator
- **Responsibilities**:
  - Listen to server RemoteEvents
  - Create and manage all visual effects
  - Handle object pooling
  - Coordinate audio and visuals
- **Key Functions**:
  - `ShowDamageNumber()` - Floating text
  - `CreateParticleEffect()` - Particle spawning
  - `ShowHitParticles()` - Hit feedback
  - `ShowDestructionEffect()` - Explosion
  - `ShowLevelUpEffect()` - Level up celebration
  - `ScreenShake()` - Camera shake
  - `ScreenFlash()` - Screen flash

#### VFXManager
- **Purpose**: Configuration and presets
- **Responsibilities**:
  - Store all effect configurations
  - Provide helper functions
  - Define particle emitter properties
  - Configure screen effects and damage numbers
- **Configuration Tables**:
  - `ParticleConfigs` - All particle settings
  - `ScreenEffects` - Shake and flash configs
  - `DamageNumbers` - Text appearance settings

#### SoundManager
- **Purpose**: Audio playback
- **Responsibilities**:
  - Play 2D and 3D sounds
  - Manage sound pooling
  - Handle volume control
  - Spatial audio positioning
- **Key Functions**:
  - `PlayCombatSound()` - 3D positioned sound
  - `PlayUISound()` - 2D UI sound
  - Sound pooling and cleanup

## Object Pooling System

```
┌─────────────────────────────────────────────────────────────────┐
│                     Object Pool Architecture                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────┐           ┌─────────────────────┐    │
│  │  Damage Number Pool  │           │  Particle Part Pool │    │
│  │  (Max: 20)           │           │  (Max: 20)          │    │
│  │                      │           │                     │    │
│  │  Available ────┐     │           │  Available ────┐    │    │
│  │  [□][□][□][□]  │     │           │  [□][□][□][□]  │    │    │
│  │                │     │           │                │    │    │
│  │  In Use ───────┘     │           │  In Use ───────┘    │    │
│  │  [■][■][■]           │           │  [■][■]             │    │
│  └──────┬───────────────┘           └──────┬──────────────┘    │
│         │                                  │                   │
│         │ getDamageNumberBillboard()       │ getParticlePart() │
│         ▼                                  ▼                   │
│  ┌─────────────────┐             ┌──────────────────┐         │
│  │ Create Effect   │             │ Create Particles │         │
│  │ - Show number   │             │ - Emit particles │         │
│  │ - Animate       │             │ - Play for 1-3s  │         │
│  │ - Fade out      │             │ - Auto cleanup   │         │
│  └────────┬────────┘             └─────────┬────────┘         │
│           │                                 │                  │
│           │ After animation (1.5-2s)        │ After duration   │
│           ▼                                 ▼                  │
│  ┌─────────────────────┐         ┌──────────────────────┐     │
│  │ returnToPool()      │         │ returnToPool()       │     │
│  │ - Reset properties  │         │ - Clean emitters     │     │
│  │ - Disable           │         │ - Reset position     │     │
│  │ - Mark available    │         │ - Mark available     │     │
│  └─────────────────────┘         └──────────────────────┘     │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### Pool Benefits
- ✓ No Instance.new() calls during gameplay
- ✓ Reduced garbage collection
- ✓ Consistent performance
- ✓ Instant effect creation
- ✓ Automatic cleanup
- ✓ Memory efficient

## Performance Characteristics

### Network Traffic
- **Per Hit**: ~50 bytes (DamageDealt event)
  - Position: Vector3 (12 bytes)
  - Damage: number (8 bytes)
  - IsCritical: boolean (1 byte)
  - HomeworkType: string (5-10 bytes)

- **Per Destruction**: ~60 bytes (PlayEffect event)
  - Type: string (~11 bytes)
  - Position: Vector3 (12 bytes)
  - IsBoss: boolean (1 byte)

- **Range Optimization**: Only sent to players within 500 studs

### Client Performance
- **Particle Count per Hit**: 15-40 particles
- **Particle Count per Destruction**: 50-150 particles
- **Tween Count per Hit**: 2-3 tweens
- **Object Creation**: ~0 (pooled)
- **FPS Impact**: <5% on modern devices

### Memory Usage
- **Damage Number Pool**: ~20 KB (20 BillboardGuis)
- **Particle Part Pool**: ~40 KB (20 Parts + Attachments)
- **Sound Pool**: ~30 KB (30 Sound instances)
- **Total Overhead**: ~100 KB

## Extension Points

### Adding New Effect Types

1. **New Particle Effect**
   ```lua
   -- In VFXManager.lua
   VFXManager.ParticleConfigs.NewEffect = { ... }

   -- In VFXController.lua
   function VFXController.ShowNewEffect(position)
       local config = VFXManager.ParticleConfigs.NewEffect
       VFXController.CreateParticleEffect(position, config, 2)
   end
   ```

2. **New Screen Effect**
   ```lua
   -- In VFXManager.lua
   VFXManager.ScreenEffects.Shake.NewShake = { ... }

   -- In VFXController.lua (no changes needed)
   VFXController.ScreenShake("NewShake")
   ```

3. **New Sound**
   ```lua
   -- In SoundConfig.lua
   Combat = {
       NewSound = {
           SoundId = "rbxassetid://...",
           Volume = 0.5,
           Type = "3D"
       }
   }

   -- In VFXController.lua
   SoundManager:PlayCombatSound("NewSound", position)
   ```

## Best Practices

### Do's ✓
- Always use RemoteEvents for server-triggered effects
- Pool frequently-created objects
- Clean up effects with Debris or task.delay
- Coordinate audio with visual effects
- Test with multiple simultaneous effects
- Use appropriate effect intensities
- Provide feedback for all player actions

### Don'ts ✗
- Don't create effects directly on client from server
- Don't skip object pooling for frequent effects
- Don't create orphaned objects without cleanup
- Don't overuse screen shake or particles
- Don't send effects to distant players
- Don't use continuous particle emission for hits
- Don't forget to test performance

## Debugging Tips

### Check VFX System Status
```lua
-- Print initialization messages in output
[VFXController] Initializing...
[VFXController] Connected to DamageDealt event
[VFXController] Connected to PlayEffect event
[VFXController] Initialized successfully
```

### Monitor Pool Usage
```lua
-- Add to VFXController for debugging
print("Damage Pool:", #damageNumberPool, "available")
print("Particle Pool:", #particlePartPool, "available")
```

### Test Individual Effects
```lua
-- In command bar (client)
local VFXController = require(game:GetService("StarterPlayer").StarterPlayerScripts.VFXController)
VFXController.ShowDamageNumber(Vector3.new(0, 10, 0), 9999, true)
VFXController.ScreenShake("Critical")
VFXController.ScreenFlash("Boss")
```

## Summary

The VFX architecture is:
- **Modular**: Clear separation of concerns
- **Performant**: Object pooling and optimization
- **Extensible**: Easy to add new effects
- **Maintainable**: Well-documented and organized
- **Network-Efficient**: Minimal data transfer
- **Coordinated**: Audio-visual synchronization

All components work together to provide a polished, professional player experience.
