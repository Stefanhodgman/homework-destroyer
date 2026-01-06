# Server Modules

This directory contains the core server-side modules for Homework Destroyer.

## Upgrade & Prestige System Modules

### StatsCalculator.lua
Calculates all player statistics including:
- Damage calculations (base, multiplied, critical)
- DP (Destruction Points) earnings
- Auto-click rates and damage
- Papers per second (DPS)
- All multipliers (rebirth, prestige, upgrades)
- Upgrade costs with scaling formulas

**No initialization required** - all functions are stateless and can be called directly.

### UpgradeManager.lua
Manages the upgrade system:
- 11 different upgrades (damage, speed, economy)
- Purchase validation and processing
- Buy max functionality
- Upgrade cost calculations
- Effect tracking and application
- Reset on rebirth
- Anti-cheat validation

**Usage:**
```lua
local UpgradeManager = require(ServerStorage.Modules.UpgradeManager)
local upgradeManager = UpgradeManager.new()
```

### PrestigeManager.lua
Handles the prestige system:
- Eligibility checking
- 6 prestige ranks with requirements
- Progress reset on prestige
- Lifetime stats tracking
- Prestige bonuses and multipliers
- Rank progression through rebirths
- Reward granting
- Anti-cheat validation

**Usage:**
```lua
local PrestigeManager = require(ServerStorage.Modules.PrestigeManager)
local prestigeManager = PrestigeManager.new()
```

## Documentation

See `docs/UpgradePrestigeSystem.md` for complete documentation including:
- API reference
- Integration guide
- Player data structure
- Testing checklist
- Performance considerations

## Testing

Run `tests/UpgradePrestigeTest.lua` in Roblox Studio to test all modules.

## Anti-Cheat Features

All modules include built-in validation:
- Server-side only (no client access)
- Purchase validation before and after
- Level cap enforcement
- Requirement checking
- Integrity validation functions
- Logging for analytics

## Dependencies

Modules are designed with minimal dependencies:
- `StatsCalculator` - No dependencies (pure calculation)
- `UpgradeManager` - Requires StatsCalculator
- `PrestigeManager` - Requires StatsCalculator

## File Sizes

- StatsCalculator.lua: ~17 KB
- UpgradeManager.lua: ~17 KB
- PrestigeManager.lua: ~19 KB

Total: ~53 KB of server code
