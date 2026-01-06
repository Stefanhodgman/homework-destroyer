# Homework Destroyer: Modern School Design Document (Comprehensive)

> **Version**: 2.0 (Expanded Technical Specification)
> **Theme**: "Future Academy" meets "Destruction Playground"
> **Architectural Style**: Neo-Futurist L-Shape with a central glass "Crystal Atrium".
> **Core Purpose**: Central Hub for Simulator Mechanics (Spawn, Upgrades, Shops, Portals).

---

## 1. Technical Architecture & Geometry

### 1.1 The Crystal Atrium (Central Hub)
The Atrium is the visual anchor of the map. It is designed to feel massive and airy.

*   **Dimensions**:
    *   **Footprint**: 60x60 Studs (centered at `0, 0, -100`).
    *   **Floor to Ceiling Height**: 50 Studs (approx. 3.5 floors).
*   **Structural Elements**:
    *   **Floor**: `Enum.Material.Marble` (White), Reflectance `0.2`. Tiled visual texture (4x4 stud grid).
    *   **Curtain Walls (Front/Back)**:
        *   **Glass**: `Enum.Material.Glass`, Color `[200, 225, 255]`, Transparency `0.5`.
        *   **Mullions (Frame)**: 1x1 stud Metal beams, Black, arranged in a Voronoi or Hexagonal pattern (Asset ID: `rbxassetid://...` or constructed via Unions).
    *   **Roof Structure**:
        *   **Skylight**: A circular opening (radius 20 studs) covered by `Glass`.
        *   **Trusses**: Exposed white steel trusses (`Enum.Material.Metal`, White) supporting the roof.

### 1.2 The East Wing (Classrooms & Store)
Extends along the positive X-axis from the Atrium.

*   **Dimensions**: 120 (Length) x 40 (Width) x 45 (Height) studs.
*   **Floor Plan**:
    *   **Ground Floor (H: 15 studs)**: **The School Store**.
        *   **Layout**: Open laneway. No classroom walls.
        *   **Counter**: A continuous curved desk (Studs: 40 long) on the South wall for Weapons.
        *   **Vending Area**: North wall lined with 10 "Egg Dispenser" slots (Width 8 studs each).
    *   **Floors 2 & 3 (H: 12 studs each)**: **Farming Zones**.
        *   **Corridor**: Central, 12 studs wide.
        *   **Classrooms**: 3 per floor (Size: 30x30 studs).
        *   **Walls**: Glass facing corridor, Concrete separating rooms.

### 1.3 The South Wing (Labs & Upgrades)
Extends along the positive Z-axis from the Atrium.

*   **Dimensions**: 40 (Width) x 100 (Length) x 45 (Height) studs.
*   **Floor Plan**:
    *   **Ground Floor (H: 15 studs)**: **The Lab**.
        *   **Style**: Industrial/High-Tech. Darker lighting.
        *   **Center**: "Pet Fusion Reactor" (Cylinder, Radius 8, Neon Blue core).
        *   **Walls**: Workbench stations for "Character Upgrades" (Speed, Luck, Magnet).
    *   **Floors 2 & 3**: **Science Labs** (Destructible props: Beakers, skeletons).
    *   **Rooftop**: **Helipad/VIP Zone** (Accessible via parkour).

---

## 2. Lighting & Atmosphere Specification

To achieve the "Future Academy" look, we use a specific lighting profile.

### 2.1 Global Lighting Settings
*   **Technology**: `ShadowMap` (Required for crisp shadows) or `Future` (if performance allows).
*   **Ambient**: `[50, 50, 60]` (Slightly blue tint).
*   **OutdoorAmbient**: `[100, 100, 100]` (Bright but neutral).
*   **ExposureCompensation**: `0.5` (Prevents neon blowout).

### 2.2 Interior Area Lighting
| Area | Light Type | Brightness | Range | Color (RGB) | Shadows | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Atrium Info** | `SurfaceLight` (Ceiling) | 3.0 | 60 | `255, 250, 240` (Warm White) | True | Main ambient fill. |
| **Atrium Accents** | `PointLight` (Base) | 2.0 | 15 | `0, 255, 255` (Cyan) | False | Up-lighting on pillars. |
| **Store (East)** | `SpotLight` (Over Eggs) | 4.0 | 20 | `255, 255, 200` (Gold) | True | Highlights the egg machines. |
| **Lab (South)** | `PointLight` (Reactor) | 5.0 | 30 | `50, 100, 255` (Deep Blue) | True | Dramatic shadows from the core. |
| **Classrooms** | `SurfaceLight` (Strip) | 1.5 | 40 | `255, 255, 255` | False | Even, clinical lighting. |

---

## 3. Materials & Color Palette (Strict)

Using specific RGB values ensures consistency.

| Surface Role | Material | Color3 (RGB) | Properties |
| :--- | :--- | :--- | :--- |
| **Primary Structure** | `Concrete` | `240, 240, 242` (Off-White) | Structure, Exterior Walls. |
| **Secondary Structure** | `Metal` | `40, 40, 45` (Dark Grey) | Window Frames, Trusses. |
| **Flooring (Hub)** | `Marble` | `230, 230, 230` | High Reflectance (`0.2`). |
| **Flooring (Labs)** | `DiamondPlate` | `80, 85, 90` | Industrial feel. |
| **Accents (Good)** | `Neon` | `0, 170, 255` (Roblox Blue) | UI borders, Guide lines. |
| **Accents (Bad/Boss)** | `Neon` | `255, 50, 50` (Red) | Boss portals, Danger zones. |
| **Glass** | `Glass` | `200, 240, 255` | Transparency `0.6`, Reflectance `0.4`. |
| **Wood Trim** | `WoodPlanks` | `140, 90, 60` | Warmth in classrooms. |

---

## 4. Play Area & Interactive Zones

### 4.1 Zone 1: The Crystal Atrium
1.  **Spawn Location**: Invisible `SpawnLocation` part (Size 20x1x20) centered at `0, 1, -100`.
2.  **Leaderboards**:
    *   **Global Layout**: 3 huge panels on the back wall (North facing).
    *   **Dimensions**: 15x25 studs each.
    *   **Content**: "Top DP (All Time)", "Top Rebirths", "Top Gems".
3.  **Group Reward Chest**:
    *   **Model**: Large Treasure Chest (4x4x4).
    *   **Interaction**: `ProximityPrompt` (ActionText: "Claim Daily Reward").
    *   **Logic**: Checks `player:IsInGroup(GroupID)`.

### 4.2 Zone 2: The Store (East Wing Ground)
1.  **Weapon Shop Console**:
    *   **Location**: South Wall.
    *   **Visual**: Floating holograms of the "Next Best Weapon".
    *   **Interaction**: Circle Pad on floor (color `Yellow`). Touching opens `ShopGUI`.
2.  **Egg Dispensers**:
    *   **Layout**: 10 machines along the North Wall.
    *   **Visual**: Glass dome containing "Pets".
    *   **Interaction**: Key `E` to buy.
    *   **Cost Display**: `SurfaceGui` above each machine showing Price (e.g., "500 Coins").

### 4.3 Zone 3: The Lab (South Wing Ground)
1.  **Upgrade Stations**:
    *   **Speed Station**: Treadmill model. Grants MoveSpeed.
    *   **Luck Station**: Four-leaf clover neon sign. Grants DropRate.
2.  **Pet Fusion**:
    *   **Machine**: Large central reactor.
    *   **GUI**: Opens "Fusion/Crafting" interface.

---

## 5. Scripting Interfaces (API)

The **SchoolBuilder** module must expose markers for scripts to find these locations easily without hardcoding coordinates.

### 5.1 Required Module Structure
```lua
-- SchoolBuilder.lua API
local SchoolBuilder = {}

-- Returns the Model instance
function SchoolBuilder:GetModel() end

-- Returns specific CFrame locations for gameplay systems
function SchoolBuilder:GetSpawnCFrame() end
function SchoolBuilder:GetLeaderboardSurface(boardType) end -- Returns Part for SurfaceGui
function SchoolBuilder:GetEggMachineLocation(tier) end
function SchoolBuilder:GetShopLocation() end

-- Events
SchoolBuilder.ConstructionFinished = Instance.new("BindableEvent")
```

### 5.2 Folder Hierarchy (Generated)
The script should organize instances logically for client replication:
```txt
Workspace/
  School/
    Structure/         -- Static Geometry (Walls, Floors) - Anchored
    Interactables/     -- Things players click/touch
      Chests/
      VendingMachines/
      ShopPads/
    Lights/            -- All lighting objects
    Zones/             -- Invisible TouchParts for detecting region entry
    Spawn/
```

---

## 6. Performance Optimization Strategy

1.  **Anchoring**: 100% of building parts must be `.Anchored = true`.
2.  **Collision**:
    *   **Main Floors/Walls**: `.CanCollide = true`.
    *   **Detail Props** (Lamps, Railings, Posters): `.CanCollide = false`. Use invisible "Blocker" parts for smooth player movement if needed.
3.  **Instancing**:
    *   Desks and Chairs should be cloned from a single Template to save memory (if using `Packages`).
4.  **Streaming**:
    *   Building Size is ~200 studs. This is small enough to generally stay in memory, but `Model.LevelOfDetail` should be set to `StreamingMesh` if using MeshParts.

---

## 7. Fun/Easter Egg Checklist

*   [ ] **The Vent**: A small vent in the Janitor's Closet (East Wing) leads to a hidden room "The Detention Dungeon" with a skeletal student prop.
*   [ ] **Roof Parkour**: A truss ladder on the back of the South Wing allows access to the roof.
*   [ ] **Physics Props**: A "Wet Floor" sign in the lobby that is unanchored and can be kicked around.
