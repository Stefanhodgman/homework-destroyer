# Pet System Documentation

## Overview
The Pet System is a core feature of Homework Destroyer that allows players to hatch, collect, equip, level up, fuse, and customize companion pets that provide damage bonuses and auto-attack functionality.

## File Structure

### Server-Side Files
- **`src/ServerStorage/Modules/PetConfig.lua`** - Configuration for all pets, eggs, rarities, and stats
- **`src/ServerStorage/Modules/PetManager.lua`** - Server-side pet management logic

### Client-Side Files
- **`src/StarterPlayer/StarterPlayerScripts/PetFollowScript.lua`** - Client-side pet following behavior

## Features

### 1. Egg Hatching System
Players can purchase and hatch eggs to obtain pets of various rarities.

**Available Eggs:**
- **Classroom Egg** (1,000 DP) - Starter pets
- **Library Egg** (10,000 DP) - Knowledge-themed pets
- **Cafeteria Egg** (25,000 DP) - Food-themed pets
- **Art Egg** (50,000 DP) - Creative pets
- **Science Egg** (150,000 DP) - Experimental pets
- **Tech Egg** (200,000 DP) - Digital pets
- **Principal's Egg** (1,000,000 DP) - Authority pets
- **Void Egg** (50,000,000 DP) - Endgame pets

**Rarity Drop Rates (Standard Egg):**
- Common: 50%
- Uncommon: 30%
- Rare: 15%
- Epic: 4%
- Legendary: 0.9%
- Mythic: 0.1%

### 2. Pet Rarity System

Each rarity provides increasing damage bonuses:
- **Common** (White) - +5% damage
- **Uncommon** (Green) - +15% damage
- **Rare** (Blue) - +35% damage
- **Epic** (Purple) - +75% damage
- **Legendary** (Orange) - +150% damage
- **Mythic** (Red) - +400% damage

### 3. Complete Pet List

#### Common Pets
1. **Paper Airplane** - Flies around destroying worksheets
   - Auto-Attack: 5 damage every 3s
   - Passive: +3% movement speed
   - Max Level: +10% paper homework damage

2. **Pencil Buddy** - Your number two companion
   - Auto-Attack: 8 damage every 3s
   - Passive: +5% XP gain
   - Max Level: +15% XP gain

3. **Eraser Blob** - Bounces around erasing mistakes
   - Auto-Attack: 6 damage every 2.5s
   - Passive: +3% DP gain
   - Max Level: 8% chance to double DP

#### Uncommon Pets
4. **Angry Calculator** - ERROR: DIVISION BY DESTRUCTION
   - Auto-Attack: 20 damage every 2.5s
   - Passive: +10% math homework damage
   - Max Level: +25% math damage + optimal targeting

5. **Runaway Scissors** - Finally free to run
   - Auto-Attack: 35 damage every 2s
   - Passive: +8% crit chance
   - Max Level: +15% crit chance + bleeding crits

6. **Cafeteria Slime** - Mystery meat's revenge
   - Auto-Attack: 25 damage every 2s
   - Passive: +12% DP in Cafeteria
   - Max Level: Grows stronger with kills (+1% per kill, 50 max)

#### Rare Pets
7. **Hyperactive Hamster** - Running on pure energy and spite
   - Auto-Attack: 80 damage every 1.5s
   - Passive: +15% attack speed
   - Max Level: +25% attack speed + Hamster Wheel boost

8. **Floating Textbook** - The student becomes the teacher
   - Auto-Attack: 120 damage every 2s
   - Passive: +20% Library damage, +10% XP
   - Max Level: Drops knowledge orbs (+500 XP)

9. **Computer Virus** - Corrupting files and homework alike
   - Auto-Attack: 100 damage every 1.5s (hits 3 targets)
   - Passive: +15% Computer Lab damage
   - Max Level: Infects bosses (-10% boss defense)

#### Epic Pets
10. **Flaming Report Card** - Straight A's in destruction
    - Auto-Attack: 300 damage every 1.5s + 50 burn DPS
    - Passive: +30% crit damage, +10% all damage
    - Max Level: 100 burn DPS, +20% damage to burning targets

11. **Mini Shredder Bot** - Beep boop, homework deleted
    - Auto-Attack: 250 damage every 1s
    - Passive: +25% paper damage, auto-collects DP
    - Max Level: Shreds 2 simultaneously, +50% paper damage

12. **Detention Ghost** - Serving eternal detention
    - Auto-Attack: 400 damage every 2s (ignores defenses)
    - Passive: +20% boss damage, 0.5s invulnerability after kill
    - Max Level: Possesses bosses (3s stun, once per boss)

#### Legendary Pets
13. **Golden Eraser** - The ultimate erasing machine
    - Auto-Attack: 1,000 damage every 1s
    - Passive: +50% all damage, +25% DP, +20% crit
    - Max Level: 2x all passive effects + DP attraction
    - **Obtained:** Prestige Rank III reward

14. **Phoenix Homework (Tamed)** - Homework reborn as your ally
    - Auto-Attack: 1,500 damage every 1.5s + explosion on kill
    - Passive: +40% damage, revives player once per zone
    - Max Level: Chain explosions, 10s invincibility on revive

#### Mythic Pets
15. **HOMEWORK DRAGON** - Born from destroyed assignments
    - Auto-Attack: 5,000 damage every 0.8s + 2,000 AoE fire breath
    - Passive: +100% damage, +50% DP, +30% crit, -15% enemy HP
    - Max Level: Permanent fire aura, 2x all stats
    - **Obtained:** Void Egg (0.1%) OR Fuse 5 Legendary pets (25% success)

### 4. Pet Leveling System

**Max Level:** 100

**XP Requirements:**
- Levels 1-10: 100 × level
- Levels 11-25: 500 × level
- Levels 26-50: 2,000 × level
- Levels 51-75: 10,000 × level
- Levels 76-100: 50,000 × level

**Scaling:**
- +5% damage per level
- Max level multiplier: 2.5× base stats
- Max level bonus: Unlock special ability

### 5. Pet Fusion System

#### Standard Fusion
- **Requirements:** 3 identical pets of the same rarity
- **Success Rates:**
  - Common → Uncommon: 80%
  - Uncommon → Rare: 70%
  - Rare → Epic: 60%
  - Epic → Legendary: 50%
  - Legendary → Mythic: 25%
- **On Failure:** Keep 1 of the 3 pets

#### Special Fusion: Homework Dragon
- **Requirements:** 5 Legendary pets (any combination)
- **Success Rate:** 25%
- **On Failure:** Lose all 5 pets

#### Event Bonuses
- **Pet Parade Week:** +25% fusion success rate

### 6. Pet Equip Slots

Players can equip multiple pets simultaneously:

| Slot | Unlock Requirement |
|------|-------------------|
| 1 | Default |
| 2 | Level 25 |
| 3 | Level 50 |
| 4 | Rebirth 2 |
| 5 | Rebirth 4 |
| 6 | Rebirth 15 |

### 7. Pet Following Behavior

The client-side script provides smooth, visually appealing pet following:

**Features:**
- **Orbit Formation:** Pets orbit around the player
- **Bobbing Animation:** Gentle up/down floating motion
- **Smooth Following:** Lerp-based movement for fluid motion
- **Rotation:** Pets face the player while moving
- **Height Variation:** Each pet has customizable float height
- **Particle Effects:** Legendary/Mythic pets have special effects

**Customization:**
- Follow Distance: 3 studs
- Follow Speed: 0.15 (lerp factor)
- Orbit Speed: 0.5 rad/s
- Bounce Height: 0.3 studs
- Formation Modes: Circle, Line, V-Formation

## API Reference

### PetManager Functions

#### Initialization
```lua
PetManager.InitializePlayer(player)
-- Initializes pet data for a player
-- Returns: playerData table

PetManager.SavePlayerData(player)
-- Saves player's pet data to DataStore
-- Returns: boolean (success)

PetManager.CleanupPlayer(player)
-- Cleanup when player leaves
```

#### Egg Hatching
```lua
PetManager.HatchEgg(player, eggId)
-- Hatches an egg for the player
-- Parameters:
--   player: Player instance
--   eggId: String (e.g., "ClassroomEgg")
-- Returns: {Success, Pet, PetData, Message}

-- Example:
local result = PetManager.HatchEgg(player, "ClassroomEgg")
if result.Success then
    print("Hatched: " .. result.PetData.Name)
    print("Rarity: " .. result.Pet.Rarity)
end
```

#### Pet Equipping
```lua
PetManager.EquipPet(player, petUniqueId, slotIndex)
-- Equips a pet to a specific slot
-- Parameters:
--   player: Player instance
--   petUniqueId: Unique ID string
--   slotIndex: Number (1-6)
-- Returns: {Success, Message}

PetManager.UnequipPet(player, slotIndex)
-- Unequips pet from slot
-- Returns: {Success, Message}

PetManager.GetEquippedPets(player)
-- Returns table of equipped pets by slot
```

#### Pet Fusion
```lua
PetManager.FusePets(player, petUniqueIds)
-- Fuses 3 pets of the same type
-- Parameters:
--   player: Player instance
--   petUniqueIds: Array of 3 unique ID strings
-- Returns: {Success, Fused, Pet, Message}

PetManager.FuseForDragon(player, petUniqueIds)
-- Special fusion for Homework Dragon
-- Parameters:
--   player: Player instance
--   petUniqueIds: Array of 5 Legendary pet IDs
-- Returns: {Success, Fused, Pet, Message}
```

#### Pet Management
```lua
PetManager.DeletePet(player, petUniqueId)
-- Deletes a pet from inventory
-- Returns: {Success, Message}

PetManager.GetPlayerInventory(player)
-- Returns array of all pets in inventory

PetManager.UnlockPetSlot(player, slotIndex)
-- Unlocks a new pet equip slot
-- Returns: {Success, Message}
```

#### Pet Leveling
```lua
PetManager.AddPetXP(player, petUniqueId, xpAmount)
-- Adds XP to a specific pet
-- Returns: leveledUp (boolean), newLevel (number)

PetManager.AddXPToEquippedPets(player, xpAmount)
-- Adds XP to all equipped pets
```

#### Damage Calculation
```lua
PetManager.GetEquippedPetsDamageBonus(player)
-- Returns total damage bonus from equipped pets
-- Returns: Number (e.g., 0.35 for +35%)

PetManager.GetPetAutoAttackDamage(pet)
-- Calculates auto-attack damage for a pet
-- Returns: Number (damage value)
```

### PetConfig Functions

```lua
PetConfig.GetPetData(petId)
-- Returns pet configuration data
-- Example: PetConfig.GetPetData("PaperAirplane")

PetConfig.GetEggData(eggId)
-- Returns egg configuration data
-- Example: PetConfig.GetEggData("ClassroomEgg")

PetConfig.GetTotalPetDamageBonus(equippedPets)
-- Calculates total damage bonus from array of pets
-- Returns: Number (total bonus multiplier)

PetConfig.GetRarityFromRoll(roll, eggData)
-- Determines rarity from random roll
-- Parameters:
--   roll: Number 0-100
--   eggData: Egg configuration
-- Returns: String (rarity name)
```

## Integration Guide

### 1. Integrate with Economy System

Replace the placeholder DP check in `PetManager.HatchEgg`:

```lua
-- In HatchEgg function, replace:
local hasEnoughDP = true -- TODO: Check player's DP

-- With your actual economy check:
local PlayerData = require(path.to.PlayerDataModule)
local playerData = PlayerData.GetPlayerData(player)
local hasEnoughDP = playerData.DestructionPoints >= eggData.Cost

if hasEnoughDP then
    playerData.DestructionPoints = playerData.DestructionPoints - eggData.Cost
end
```

### 2. Integrate with Progression System

Replace level/rebirth checks in `PetManager.UnlockPetSlot`:

```lua
-- Replace placeholder:
local meetsRequirements = true -- TODO: Check player level/rebirth

-- With actual checks:
local PlayerData = require(path.to.PlayerDataModule)
local playerData = PlayerData.GetPlayerData(player)

local meetsRequirements = true
if requirements.Level and playerData.Level < requirements.Level then
    meetsRequirements = false
end
if requirements.Rebirth and playerData.Rebirth < requirements.Rebirth then
    meetsRequirements = false
end
```

### 3. Integrate with Damage System

In your damage calculation module:

```lua
local PetManager = require(ServerStorage.Modules.PetManager)

function CalculateDamage(player, baseDamage)
    local petBonus = PetManager.GetEquippedPetsDamageBonus(player)

    local finalDamage = baseDamage * (1 + petBonus)

    return finalDamage
end
```

### 4. Add Pet XP Rewards

When homework is destroyed:

```lua
local xpToAward = homeworkValue * 0.1 -- 10% of DP as XP
PetManager.AddXPToEquippedPets(player, xpToAward)
```

### 5. Setup Remote Events

Create RemoteEvents for client-server communication:

```lua
-- In ReplicatedStorage.Remotes
local PetRemotes = Instance.new("Folder")
PetRemotes.Name = "PetRemotes"
PetRemotes.Parent = ReplicatedStorage.Remotes

local HatchEgg = Instance.new("RemoteEvent")
HatchEgg.Name = "HatchEgg"
HatchEgg.Parent = PetRemotes

local EquipPet = Instance.new("RemoteEvent")
EquipPet.Name = "EquipPet"
EquipPet.Parent = PetRemotes

local FusePets = Instance.new("RemoteEvent")
FusePets.Name = "FusePets"
FusePets.Parent = PetRemotes

-- Add server-side handlers:
HatchEgg.OnServerEvent:Connect(function(player, eggId)
    local result = PetManager.HatchEgg(player, eggId)
    -- Send result back to client
end)
```

## Example Usage

### Hatching an Egg
```lua
-- Server-side
local result = PetManager.HatchEgg(player, "ClassroomEgg")
if result.Success then
    print(player.Name .. " hatched a " .. result.Pet.Rarity .. " " .. result.PetData.Name)
else
    warn(result.Message)
end
```

### Equipping a Pet
```lua
-- Server-side
local inventory = PetManager.GetPlayerInventory(player)
local firstPet = inventory[1]

if firstPet then
    local result = PetManager.EquipPet(player, firstPet.UniqueId, 1)
    if result.Success then
        print("Pet equipped to slot 1")
    end
end
```

### Fusing Pets
```lua
-- Server-side
local inventory = PetManager.GetPlayerInventory(player)

-- Find 3 common Paper Airplanes
local paperAirplanes = {}
for _, pet in ipairs(inventory) do
    if pet.PetId == "PaperAirplane" and pet.Rarity == "Common" and not pet.Equipped then
        table.insert(paperAirplanes, pet.UniqueId)
        if #paperAirplanes == 3 then break end
    end
end

if #paperAirplanes == 3 then
    local result = PetManager.FusePets(player, paperAirplanes)
    if result.Success and result.Fused then
        print("Fusion successful! Got " .. result.Pet.Rarity .. " pet!")
    else
        print("Fusion failed")
    end
end
```

### Getting Damage Bonus
```lua
-- Server-side
local damageBonus = PetManager.GetEquippedPetsDamageBonus(player)
print("Total pet damage bonus: +" .. (damageBonus * 100) .. "%")
```

## Configuration

### Adjusting Drop Rates

Edit `PetConfig.lua`:

```lua
-- Modify rarity weights in egg definitions
ClassroomEgg = {
    -- ...
    RarityWeights = {
        Common = 50,    -- Increase for more commons
        Uncommon = 30,
        Rare = 15,
        Epic = 4,
        Legendary = 0.9,
        Mythic = 0.1
    }
}
```

### Adjusting Pet Stats

Edit individual pet definitions in `PetConfig.lua`:

```lua
PaperAirplane = {
    Name = "Paper Airplane",
    AutoAttackDamage = 5,      -- Increase for more damage
    AutoAttackSpeed = 3,        -- Decrease for faster attacks
    -- ...
}
```

### Adjusting Follow Behavior

Edit `PetFollowScript.lua`:

```lua
-- At the top of the file:
local FOLLOW_DISTANCE = 3      -- Distance from player
local FOLLOW_SPEED = 0.15      -- Higher = faster following
local ORBIT_SPEED = 0.5        -- Rotation speed around player
local BOUNCE_HEIGHT = 0.3      -- Bobbing intensity
```

## Performance Considerations

1. **Pet Limit:** Max 6 pets equipped at once to maintain performance
2. **Update Optimization:** Distant pets update less frequently
3. **Model Complexity:** Simple sphere models used by default (replace with custom models)
4. **Auto-Save:** Implement proper timed auto-save (every 5 minutes recommended)

## Future Enhancements

Potential additions to the pet system:
- Pet abilities that can be manually activated
- Pet breeding system
- Pet trading between players
- Seasonal/event-exclusive pets
- Pet accessories and customization
- Pet mini-games
- Achievement system tied to pet collection
- Pet prestige system (reset level for permanent bonuses)

## Troubleshooting

### Pets Not Following
- Check that `PetFollowScript.lua` is in StarterPlayerScripts
- Verify pet folder exists in workspace
- Check console for errors

### Fusion Not Working
- Ensure all 3 pets are the same type and rarity
- Verify pets are not equipped
- Check that pets exist in inventory

### Data Not Saving
- Verify DataStore is enabled in game settings
- Check for DataStore errors in console
- Implement proper error handling and retries

### Pets Not Spawning
- Check that PetManager.InitializePlayer is called
- Verify pet models are being created correctly
- Check workspace for pet folder

## Credits

Pet System designed and implemented for Homework Destroyer based on the Game Design Document specifications.
