# HOMEWORK DESTROYER - CORE GAMEPLAY & MECHANICS
## A Roblox Clicker/Simulator Game Design Document

---

## 1. CORE LOOP

### Basic Click-to-Destroy Mechanic

**Primary Action:** Players click on homework objects to destroy them and earn "Destruction Points" (DP).

**Click Interaction Flow:**
1. Player equips a destruction tool from their inventory
2. Player clicks on a homework object (paper, textbook, assignment, etc.)
3. Each click deals damage equal to: `Base Damage x Tool Multiplier x Pet Bonus x Rebirth Multiplier`
4. Homework object displays floating damage numbers
5. Health bar above homework depletes
6. When health reaches 0, homework explodes and rewards DP

**Visual Feedback System:**
| Action | Visual Effect | Sound Effect |
|--------|--------------|--------------|
| Click Hit | Paper tear particles, ink splatter | "Rip" or "Crunch" sound |
| Critical Hit (5% chance) | Golden particles, screen shake | "BOOM" sound, x2 damage |
| Destroy Object | Confetti explosion, DP counter flies to UI | Satisfying "cha-ching" |
| Level Up | Full-screen flash, fireworks | Trumpet fanfare |

**Homework Object Types per Zone:**
- **Paper Homework:** 100 HP base, rewards 10 DP
- **Worksheet Stack:** 500 HP base, rewards 60 DP
- **Textbook:** 2,000 HP base, rewards 300 DP
- **Project Board:** 10,000 HP base, rewards 2,000 DP
- **Final Exam:** 50,000 HP base, rewards 15,000 DP
- **Boss Homework:** 500,000+ HP, rewards 200,000+ DP (spawns every 10 minutes)

**Auto-Click System:**
- Unlocked at Rebirth 1
- Base rate: 1 click per 2 seconds
- Upgradeable to 5 clicks per second maximum
- Auto-click deals 50% of manual click damage

---

## 2. PROGRESSION SYSTEM

### A. Experience & Leveling

**Level Cap:** 100 (before first rebirth)

**XP Requirements:**
| Level Range | XP per Level | Cumulative XP |
|-------------|--------------|---------------|
| 1-10 | 100 | 1,000 |
| 11-25 | 500 | 8,500 |
| 26-50 | 2,000 | 58,500 |
| 51-75 | 10,000 | 308,500 |
| 76-100 | 50,000 | 1,558,500 |

**Level Rewards:**
- Every level: +5% base damage
- Every 5 levels: Free pet egg
- Every 10 levels: Tool unlock or upgrade token
- Level 25: Unlock Pet Equip Slot 2
- Level 50: Unlock Pet Equip Slot 3
- Level 75: Unlock Tool Dual-Wield
- Level 100: Unlock Rebirth

### B. Upgrade Paths

**Damage Upgrades (Purchased with DP):**
| Upgrade | Levels | Cost Formula | Effect per Level |
|---------|--------|--------------|------------------|
| Sharper Tools | 50 | 100 x (1.5^level) | +2 base damage |
| Stronger Arms | 50 | 200 x (1.5^level) | +5% click damage |
| Critical Chance | 25 | 500 x (2^level) | +1% crit chance (max 30%) |
| Critical Damage | 25 | 750 x (2^level) | +10% crit multiplier |
| Paper Weakness | 20 | 1,000 x (1.8^level) | +10% damage to paper types |

**Speed Upgrades:**
| Upgrade | Levels | Cost Formula | Effect per Level |
|---------|--------|--------------|------------------|
| Quick Hands | 30 | 300 x (1.6^level) | -2% click cooldown |
| Auto-Click Speed | 20 | 5,000 x (2^level) | +0.1 auto-clicks/sec |
| Movement Speed | 15 | 400 x (1.5^level) | +3% walk speed |

**Economy Upgrades:**
| Upgrade | Levels | Cost Formula | Effect per Level |
|---------|--------|--------------|------------------|
| DP Bonus | 50 | 150 x (1.4^level) | +3% DP earned |
| Lucky Drops | 20 | 2,000 x (1.8^level) | +2% rare drop chance |
| Egg Luck | 15 | 10,000 x (2^level) | +3% pet rarity luck |

### C. Rebirth System

**Requirements to Rebirth:**
- Reach Level 100
- Destroy the "Ultimate Final Exam" boss (1,000,000 HP)
- Pay 10,000,000 DP (first rebirth)

**What Resets:**
- Player level (back to 1)
- Destruction Points (to 0)
- Zone progress (back to Classroom)
- Basic upgrades (damage, speed, economy)

**What You Keep:**
- All tools (weapons)
- All pets
- Rebirth upgrades
- Achievements/Badges
- Gamepasses

**Rebirth Bonuses:**
| Rebirth Level | DP Multiplier | Damage Multiplier | Special Unlock |
|---------------|---------------|-------------------|----------------|
| 1 | x1.5 | x1.25 | Auto-Click feature |
| 2 | x2.0 | x1.5 | Pet Slot 4 |
| 3 | x2.75 | x1.75 | Rebirth Shop access |
| 4 | x3.5 | x2.0 | Pet Slot 5 |
| 5 | x4.5 | x2.5 | Exclusive Zone: Detention |
| 10 | x10 | x5 | Legendary Tool Chest |
| 15 | x20 | x8 | Pet Slot 6 |
| 20 | x35 | x12 | Prestige System unlock |
| 25 | x50 | x15 | Secret Zone: Principal's Vault |

**Rebirth Tokens:**
- Earned: 1 token per rebirth + bonus tokens at milestones
- Spent in Rebirth Shop on permanent upgrades:
  - "Starting Boost" (5 tokens): Start each rebirth at Level 10
  - "DP Saver" (10 tokens): Keep 10% of DP through rebirth
  - "Zone Skip" (15 tokens): Start at Zone 3 after rebirth
  - "Super Auto" (20 tokens): Auto-click deals 100% damage instead of 50%

### D. Prestige System (Unlocked at Rebirth 20)

**Prestige Requirements:**
- Reach Rebirth 20
- Collect 1 Billion total lifetime DP
- Own at least 1 Legendary pet

**Prestige Ranks:**
| Rank | Name | Requirement | Permanent Bonus |
|------|------|-------------|-----------------|
| I | Homework Hater | Prestige once | +100% all damage |
| II | Assignment Annihilator | 5 total rebirths post-prestige | +200% DP |
| III | Test Terminator | 15 total rebirths post-prestige | Exclusive pet: Golden Eraser |
| IV | Scholar Slayer | 30 total rebirths post-prestige | +50% pet damage |
| V | Education Eliminator | 50 total rebirths post-prestige | Access to Void Zone |
| MAX | HOMEWORK DESTROYER | 100 total rebirths post-prestige | Rainbow name, x10 all stats |

---

## 3. ZONES/AREAS

### Zone Progression Map

```
[Classroom] -> [Library] -> [Cafeteria] -> [Computer Lab] -> [Gymnasium]
                                                                  |
                                                                  v
[Principal's Office] <- [Science Lab] <- [Art Room] <- [Music Room]
         |
         v
    [THE VOID] (Secret Endgame Zone)
```

### Detailed Zone Breakdown

#### ZONE 1: THE CLASSROOM (Starter Zone)
**Unlock Cost:** Free (Starting Area)
**Theme:** Classic school classroom with desks, chalkboard, scattered papers
**Homework Types:**
- Spelling Worksheet (100 HP) - 10 DP
- Math Problems (200 HP) - 25 DP
- Reading Assignment (400 HP) - 55 DP
- Pop Quiz (1,000 HP) - 150 DP

**Boss:** "Monday Morning Test" - 25,000 HP, spawns every 10 min, drops 5,000 DP
**Special Feature:** Tutorial NPC "Teacher's Pet" explains mechanics
**Recommended Level:** 1-15

---

#### ZONE 2: THE LIBRARY
**Unlock Cost:** 5,000 DP + Level 10
**Theme:** Towering bookshelves, quiet study areas, librarian desk
**Homework Types:**
- Book Report (500 HP) - 65 DP
- Research Paper (1,500 HP) - 200 DP
- Encyclopedia Entry (3,000 HP) - 450 DP
- Thesis Statement (6,000 HP) - 1,000 DP

**Boss:** "Overdue Library Book" - 75,000 HP, spawns every 10 min, drops 15,000 DP
**Special Feature:** "Speed Reading" mini-event every 30 min (2x DP for 2 min)
**Recommended Level:** 15-30

---

#### ZONE 3: THE CAFETERIA
**Unlock Cost:** 50,000 DP + Level 25
**Theme:** Lunch tables, food trays, sticky floors, food fight aftermath
**Homework Types:**
- Nutrition Worksheet (2,000 HP) - 300 DP
- Food Diary Project (5,000 HP) - 800 DP
- Cooking Recipe Assignment (10,000 HP) - 1,800 DP
- Health Class Essay (20,000 HP) - 4,000 DP

**Boss:** "Cafeteria Mystery Meat" - 200,000 HP, spawns every 10 min, drops 50,000 DP
**Special Feature:** "Lunch Rush" event - double homework spawns for 5 min
**Recommended Level:** 25-40

---

#### ZONE 4: COMPUTER LAB
**Unlock Cost:** 250,000 DP + Level 35
**Theme:** Desktop computers, tangled wires, loading screens, error messages
**Homework Types:**
- Typing Test (8,000 HP) - 1,200 DP
- PowerPoint Presentation (20,000 HP) - 3,500 DP
- Coding Assignment (45,000 HP) - 8,000 DP
- Computer Science Project (100,000 HP) - 20,000 DP

**Boss:** "Blue Screen of Doom" - 500,000 HP, spawns every 10 min, drops 150,000 DP
**Special Feature:** "Virus Attack" event - defeat waves for bonus rewards
**Recommended Level:** 35-50

---

#### ZONE 5: GYMNASIUM
**Unlock Cost:** 1,000,000 DP + Level 45
**Theme:** Basketball court, bleachers, locker rooms, PE equipment
**Homework Types:**
- Fitness Log (30,000 HP) - 5,000 DP
- Sports Report (75,000 HP) - 15,000 DP
- Health Assessment (150,000 HP) - 35,000 DP
- Physical Education Portfolio (300,000 HP) - 80,000 DP

**Boss:** "Coach's Impossible Fitness Test" - 1,500,000 HP, spawns every 10 min, drops 500,000 DP
**Special Feature:** "Dodgeball Mode" - dodge falling homework for bonus DP
**Recommended Level:** 45-60

---

#### ZONE 6: MUSIC ROOM
**Unlock Cost:** 5,000,000 DP + Level 55
**Theme:** Instruments, sheet music stands, soundproof walls, practice rooms
**Homework Types:**
- Sheet Music Practice (100,000 HP) - 18,000 DP
- Music Theory Test (250,000 HP) - 50,000 DP
- Instrument Recital Paper (500,000 HP) - 120,000 DP
- Symphony Analysis (1,000,000 HP) - 280,000 DP

**Boss:** "Discordant Symphony" - 5,000,000 HP, spawns every 10 min, drops 1,500,000 DP
**Special Feature:** Rhythm mini-game for 3x damage buff (30 seconds)
**Recommended Level:** 55-70

---

#### ZONE 7: ART ROOM
**Unlock Cost:** 25,000,000 DP + Level 65
**Theme:** Paint splatters, easels, sculptures, messy art supplies
**Homework Types:**
- Sketch Assignment (400,000 HP) - 75,000 DP
- Painting Project (900,000 HP) - 180,000 DP
- Sculpture Report (2,000,000 HP) - 450,000 DP
- Art History Essay (4,500,000 HP) - 1,100,000 DP

**Boss:** "Monstrous Masterpiece" - 20,000,000 HP, spawns every 10 min, drops 6,000,000 DP
**Special Feature:** "Creative Burst" - random damage multipliers (1x-5x)
**Recommended Level:** 65-80

---

#### ZONE 8: SCIENCE LAB
**Unlock Cost:** 100,000,000 DP + Level 75
**Theme:** Bubbling beakers, lab equipment, periodic table, safety goggles
**Homework Types:**
- Lab Report (1,500,000 HP) - 300,000 DP
- Chemical Equation Sheet (3,500,000 HP) - 750,000 DP
- Experiment Documentation (8,000,000 HP) - 1,900,000 DP
- Scientific Method Project (18,000,000 HP) - 4,500,000 DP

**Boss:** "Failed Experiment" - 75,000,000 HP, spawns every 10 min, drops 25,000,000 DP
**Special Feature:** "Chemical Reaction" - combine elements for mega explosions
**Recommended Level:** 75-90

---

#### ZONE 9: PRINCIPAL'S OFFICE
**Unlock Cost:** 500,000,000 DP + Level 90 + Rebirth 3
**Theme:** Intimidating desk, trophy case, detention slips, report cards
**Homework Types:**
- Detention Essay (7,000,000 HP) - 1,500,000 DP
- Behavior Report (15,000,000 HP) - 3,500,000 DP
- Academic Probation File (35,000,000 HP) - 9,000,000 DP
- Permanent Record (80,000,000 HP) - 22,000,000 DP

**Boss:** "THE PRINCIPAL" - 500,000,000 HP, spawns every 15 min, drops 200,000,000 DP
**Special Feature:** "Sent to Detention" debuff - survive waves of homework
**Recommended Level:** 90-100

---

#### SECRET ZONE 10: THE VOID
**Unlock Cost:** 10,000,000,000 DP + Rebirth 25 + Prestige Rank III
**Theme:** Dark dimension, floating homework fragments, distorted reality
**Homework Types:**
- Void Assignment (500,000,000 HP) - 150,000,000 DP
- Dimensional Essay (1,500,000,000 HP) - 500,000,000 DP
- Reality-Breaking Test (5,000,000,000 HP) - 2,000,000,000 DP
- THE ULTIMATE HOMEWORK (25,000,000,000 HP) - 12,000,000,000 DP

**Boss:** "HOMEWORK OVERLORD" - 100,000,000,000 HP, spawns every 20 min, drops 50,000,000,000 DP
**Special Feature:** Gravity shifts, homework attacks back, true endgame challenge
**Recommended Level:** 100 + High Rebirth

---

## 4. TOOLS/WEAPONS

### Tool Rarity System
- **Common** (White) - Base stats
- **Uncommon** (Green) - +25% damage
- **Rare** (Blue) - +50% damage, +10% crit
- **Epic** (Purple) - +100% damage, +15% crit, special effect
- **Legendary** (Orange) - +200% damage, +25% crit, powerful effect
- **Mythic** (Red) - +500% damage, +40% crit, unique ability
- **SECRET** (Rainbow) - +1000% damage, +50% crit, game-changing ability

### Complete Tool List (18 Tools)

#### STARTER TOOLS (Zones 1-3)

**1. Pencil Eraser** (Common - Starting Tool)
- Base Damage: 1
- Click Speed: 1.0/sec
- Special: None
- Cost: Free (Starting Equipment)
- *"Every destroyer starts somewhere."*

**2. Wooden Ruler** (Common)
- Base Damage: 3
- Click Speed: 1.0/sec
- Special: +10% damage to paper homework
- Cost: 500 DP
- *"Measure twice, destroy once."*

**3. Safety Scissors** (Uncommon)
- Base Damage: 8
- Click Speed: 1.1/sec
- Special: 5% chance to instantly destroy paper homework
- Cost: 2,500 DP
- *"Now you can run with them."*

**4. Permanent Marker** (Uncommon)
- Base Damage: 15
- Click Speed: 1.0/sec
- Special: Marks homework for +20% damage for 5 seconds
- Cost: 8,000 DP
- *"This ink never comes off."*

**5. Staple Remover** (Rare)
- Base Damage: 30
- Click Speed: 1.2/sec
- Special: +25% damage to stacked homework, removes buffs from boss homework
- Cost: 25,000 DP
- *"The jaws of destruction."*

#### MID-GAME TOOLS (Zones 4-6)

**6. Electric Pencil Sharpener** (Rare)
- Base Damage: 60
- Click Speed: 1.3/sec
- Special: Deals damage over time (10 DPS for 3 sec after click)
- Cost: 75,000 DP
- *"Sharpened for maximum destruction."*

**7. Textbook (Ironic Weapon)** (Rare)
- Base Damage: 100
- Click Speed: 0.8/sec
- Special: +50% damage to all homework in the Library zone
- Cost: 200,000 DP
- *"Fight fire with fire."*

**8. Laser Pointer** (Epic)
- Base Damage: 175
- Click Speed: 1.5/sec
- Special: Can hit homework from double distance, +15% crit chance
- Cost: 500,000 DP
- *"Precision destruction."*

**9. Industrial Shredder** (Epic)
- Base Damage: 300
- Click Speed: 1.0/sec
- Special: Hits 3 homework at once, +30% damage to paper types
- Cost: 1,500,000 DP
- *"Feed it your problems."*

**10. Detention Hammer** (Epic)
- Base Damage: 500
- Click Speed: 0.7/sec
- Special: Stuns boss homework for 2 seconds, +40% boss damage
- Cost: 5,000,000 DP
- *"Order in the classroom!"*

#### LATE-GAME TOOLS (Zones 7-9)

**11. Acid Beaker** (Legendary)
- Base Damage: 900
- Click Speed: 1.2/sec
- Special: Corrodes homework, -20% enemy HP over 5 seconds, splash damage
- Cost: 20,000,000 DP
- *"Safety goggles not included."*

**12. Tesla Coil Pen** (Legendary)
- Base Damage: 1,500
- Click Speed: 1.4/sec
- Special: Chain lightning hits 5 nearby homework for 50% damage
- Cost: 75,000,000 DP
- *"Shocking results guaranteed."*

**13. Black Hole Backpack** (Legendary)
- Base Damage: 2,800
- Click Speed: 1.0/sec
- Special: Pulls all nearby homework closer, +25% DP from destroyed homework
- Cost: 250,000,000 DP
- *"It all disappears eventually."*

**14. Report Card Shuriken** (Mythic)
- Base Damage: 5,000
- Click Speed: 2.0/sec
- Special: Bounces between 7 targets, +30% crit damage, bleeds for 5% HP/sec
- Cost: 1,000,000,000 DP
- *"Straight F's... for the homework."*

**15. Nuclear Eraser** (Mythic)
- Base Damage: 12,000
- Click Speed: 0.5/sec
- Special: Creates explosion dealing 10,000 damage to all homework in range, 10% chance to instantly destroy non-boss homework
- Cost: 5,000,000,000 DP
- *"Total annihilation."*

#### ENDGAME/SECRET TOOLS (Zone 10 / Special)

**16. Principal's Golden Pen** (Mythic - Boss Drop)
- Base Damage: 25,000
- Click Speed: 1.5/sec
- Special: Signs homework's "death warrant" - marked homework takes 3x damage from all sources for 10 seconds
- Cost: Drops from THE PRINCIPAL boss (1% chance) or 25,000,000,000 DP
- *"With great power comes great responsibility... to destroy homework."*

**17. Void Eraser** (SECRET - Quest Reward)
- Base Damage: 50,000
- Click Speed: 1.8/sec
- Special: Erases homework from existence - bypasses 50% of homework defenses, deals true damage to bosses, x2 damage in The Void
- Cost: Complete "The Void Walker" quest chain (Rebirth 25, defeat Homework Overlord 10 times)
- *"It was never assigned."*

**18. THE DESTROYER'S HAND** (SECRET - Ultimate Weapon)
- Base Damage: 100,000
- Click Speed: 2.5/sec
- Special: Every 10th click triggers "DESTRUCTION WAVE" dealing 1,000,000 damage to all homework on screen. +100% all stats. Intimidates homework (-25% enemy HP).
- Cost: Achieve MAX Prestige Rank + Own all other tools + 100,000,000,000 DP
- *"You ARE the Homework Destroyer."*

### Tool Upgrade System

Each tool can be upgraded 10 times using **Tool Upgrade Tokens**:
- Earned from: Level milestones, daily rewards, boss drops, achievements
- Each upgrade: +15% damage, +5% speed
- Cost per upgrade: 1 token (levels 1-5), 2 tokens (levels 6-8), 5 tokens (levels 9-10)

---

## 5. PETS

### Pet System Overview
- **Equip Slots:** Start with 1, unlock up to 6 through progression
- **Pet Function:** Auto-destroy homework, provide passive bonuses
- **Pet Leveling:** Pets gain XP when equipped, max level 100
- **Pet Fusion:** Combine 3 same pets for chance at higher rarity

### Pet Rarity Drop Rates (Standard Egg)
| Rarity | Drop Rate | Damage Bonus | Passive Strength |
|--------|-----------|--------------|------------------|
| Common | 50% | +5% | Minor |
| Uncommon | 30% | +15% | Small |
| Rare | 15% | +35% | Moderate |
| Epic | 4% | +75% | Significant |
| Legendary | 0.9% | +150% | Powerful |
| Mythic | 0.1% | +400% | Extreme |

### Complete Pet List (15 Pets)

#### COMMON PETS

**1. Paper Airplane**
- Auto-Attack: 5 damage every 3 seconds
- Passive: +3% movement speed
- Egg: Classroom Egg (1,000 DP)
- Max Level Bonus: +10% paper homework damage
- *"Flies around destroying worksheets."*

**2. Pencil Buddy**
- Auto-Attack: 8 damage every 3 seconds
- Passive: +5% XP gain
- Egg: Classroom Egg (1,000 DP)
- Max Level Bonus: +15% XP gain
- *"Your number two companion."*

**3. Eraser Blob**
- Auto-Attack: 6 damage every 2.5 seconds
- Passive: +3% DP gain
- Egg: Classroom Egg (1,000 DP)
- Max Level Bonus: +8% chance to double DP from destroyed homework
- *"Bounces around erasing mistakes... permanently."*

#### UNCOMMON PETS

**4. Angry Calculator**
- Auto-Attack: 20 damage every 2.5 seconds
- Passive: +10% damage to math homework
- Egg: Library Egg (10,000 DP)
- Max Level Bonus: +25% damage to math homework, calculates optimal targets
- *"ERROR: DIVISION BY DESTRUCTION"*

**5. Runaway Scissors**
- Auto-Attack: 35 damage every 2 seconds
- Passive: +8% crit chance
- Egg: Art Egg (50,000 DP)
- Max Level Bonus: +15% crit chance, crits cause bleeding
- *"Finally free to run."*

**6. Cafeteria Slime**
- Auto-Attack: 25 damage every 2 seconds
- Passive: +12% DP gain in Cafeteria zone
- Egg: Cafeteria Egg (25,000 DP)
- Max Level Bonus: Absorbs destroyed homework, grows stronger each absorption (+1% damage, stacks 50x)
- *"Mystery meat's revenge."*

#### RARE PETS

**7. Hyperactive Hamster**
- Auto-Attack: 80 damage every 1.5 seconds
- Passive: +15% attack speed for player
- Egg: Science Egg (150,000 DP)
- Max Level Bonus: +25% attack speed, occasionally triggers "Hamster Wheel" (5 second speed boost)
- *"Running on pure energy and spite."*

**8. Floating Textbook**
- Auto-Attack: 120 damage every 2 seconds
- Passive: +20% damage in Library, +10% XP
- Egg: Library Egg (10,000 DP) - Rare pull
- Max Level Bonus: Occasionally drops knowledge orbs (+500 XP each)
- *"The student becomes the teacher."*

**9. Computer Virus**
- Auto-Attack: 100 damage every 1.5 seconds, hits 3 targets
- Passive: +15% damage in Computer Lab
- Egg: Tech Egg (200,000 DP)
- Max Level Bonus: Spreads to additional targets, infects boss homework (-10% boss defense)
- *"Corrupting files and homework alike."*

#### EPIC PETS

**10. Flaming Report Card**
- Auto-Attack: 300 damage every 1.5 seconds + burn (50 DPS for 3 sec)
- Passive: +30% crit damage, +10% all damage
- Egg: Principal's Egg (1,000,000 DP)
- Max Level Bonus: Burn damage increased to 100 DPS, burning homework takes +20% damage
- *"Straight A's in destruction."*

**11. Mini Shredder Bot**
- Auto-Attack: 250 damage every 1 second
- Passive: +25% paper homework damage, auto-collects DP
- Egg: Tech Egg (200,000 DP) - Epic pull
- Max Level Bonus: Shreds 2 homework simultaneously, +50% paper damage
- *"Beep boop, homework deleted."*

**12. Detention Ghost**
- Auto-Attack: 400 damage every 2 seconds, phases through defenses
- Passive: +20% boss damage, homework can't target you for 0.5 sec after kill
- Egg: Principal's Egg (1,000,000 DP)
- Max Level Bonus: Can possess boss homework (stuns for 3 seconds, once per boss)
- *"Serving eternal detention... to homework."*

#### LEGENDARY PETS

**13. Golden Eraser** (Prestige Reward)
- Auto-Attack: 1,000 damage every 1 second
- Passive: +50% all damage, +25% DP gain, +20% crit chance
- Obtained: Reach Prestige Rank III
- Max Level Bonus: x2 all passive effects, golden particles attract nearby DP
- *"The ultimate erasing machine."*

**14. Phoenix Homework (Tamed)**
- Auto-Attack: 1,500 damage every 1.5 seconds + explosion on kill
- Passive: +40% damage, revives player once per zone (resets on zone change)
- Egg: Void Egg (50,000,000 DP) - Legendary pull (0.9%)
- Max Level Bonus: Explosion chain-reacts, revival gives 10-second invincibility
- *"Homework reborn... as your ally."*

#### MYTHIC PETS

**15. HOMEWORK DRAGON**
- Auto-Attack: 5,000 damage every 0.8 seconds + fire breath (2,000 AoE damage)
- Passive: +100% all damage, +50% DP, +30% crit, intimidates homework (-15% enemy HP)
- Egg: Void Egg (50,000,000 DP) - Mythic pull (0.1%)
- Alternative: Fuse 5 Legendary pets (25% success rate)
- Max Level Bonus: Fire breath becomes permanent aura, all stats doubled
- *"Born from the ashes of a thousand destroyed assignments."*

### Pet Egg Types & Costs

| Egg Name | Cost | Location | Notable Pets |
|----------|------|----------|--------------|
| Classroom Egg | 1,000 DP | Zone 1 | Paper Airplane, Pencil Buddy, Eraser Blob |
| Library Egg | 10,000 DP | Zone 2 | Angry Calculator, Floating Textbook |
| Cafeteria Egg | 25,000 DP | Zone 3 | Cafeteria Slime |
| Art Egg | 50,000 DP | Zone 7 | Runaway Scissors |
| Science Egg | 150,000 DP | Zone 8 | Hyperactive Hamster |
| Tech Egg | 200,000 DP | Zone 4 | Computer Virus, Mini Shredder Bot |
| Principal's Egg | 1,000,000 DP | Zone 9 | Flaming Report Card, Detention Ghost |
| Void Egg | 50,000,000 DP | Zone 10 | Phoenix Homework, HOMEWORK DRAGON |

---

## 6. DAILY/WEEKLY SYSTEMS

### A. Daily Login Rewards

**7-Day Rotation Cycle:**

| Day | Reward |
|-----|--------|
| Day 1 | 5,000 DP + 1 Classroom Egg |
| Day 2 | 10,000 DP + 15 minute 2x DP boost |
| Day 3 | 1 Tool Upgrade Token + 2 Library Eggs |
| Day 4 | 25,000 DP + 1 Rare Pet guaranteed egg |
| Day 5 | 50,000 DP + 30 minute 2x Damage boost |
| Day 6 | 3 Tool Upgrade Tokens + 1 Science Egg |
| Day 7 | 100,000 DP + 1 Epic Pet guaranteed egg + "Weekly Warrior" title |

**Streak Bonuses:**
- 14 days: Exclusive "Dedicated Destroyer" pet (Epic rarity)
- 30 days: 500,000 DP + Legendary Tool Chest
- 60 days: Exclusive "Time Traveler" tool (Legendary)
- 100 days: 5,000,000 DP + Mythic Pet guaranteed egg + "Centurion" badge

### B. Daily Challenges (Refresh at midnight UTC)

**Players receive 3 random challenges daily:**

| Challenge Type | Examples | Reward |
|---------------|----------|--------|
| Destruction Count | "Destroy 100 homework" | 5,000 DP |
| Zone Specific | "Destroy 50 homework in Library" | 8,000 DP + zone egg |
| Tool Challenge | "Deal 10,000 damage with Scissors" | 10,000 DP |
| Pet Challenge | "Let pets destroy 25 homework" | Pet XP boost (1 hour) |
| Boss Challenge | "Defeat any boss 3 times" | 25,000 DP + Tool Token |
| Speed Challenge | "Destroy 50 homework in 2 minutes" | 15,000 DP + speed boost |
| Critical Challenge | "Land 20 critical hits" | 12,000 DP + crit boost |
| Collection Challenge | "Collect 50,000 DP" | 10,000 bonus DP |

**Daily Challenge Completion Bonus:**
- Complete 1 challenge: 2,000 bonus DP
- Complete 2 challenges: 5,000 bonus DP + 1 egg
- Complete all 3: 15,000 bonus DP + 1 Tool Token + "Daily Destroyer" temporary buff (+10% all stats for 2 hours)

### C. Weekly Events

**Rotating Weekly Event Schedule:**

**Week 1: DESTRUCTION DERBY**
- Duration: Friday 6 PM - Sunday 11 PM
- Mechanic: Compete on leaderboard for most homework destroyed
- Rewards:
  - Top 1%: 1,000,000 DP + Exclusive "Derby Champion" tool skin
  - Top 10%: 500,000 DP + 5 Tool Tokens
  - Top 25%: 250,000 DP + 3 Tool Tokens
  - Top 50%: 100,000 DP + 1 Tool Token
  - Participation: 25,000 DP

**Week 2: BOSS RUSH**
- Duration: Saturday 12 PM - Sunday 6 PM
- Mechanic: Special boss arena with waves of increasingly difficult bosses
- Rewards per wave completed:
  - Wave 5: 50,000 DP
  - Wave 10: 150,000 DP + Rare egg
  - Wave 15: 400,000 DP + Epic egg
  - Wave 20: 1,000,000 DP + "Boss Slayer" badge
  - Wave 25 (Final): 2,500,000 DP + Legendary egg + exclusive title

**Week 3: PET PARADE**
- Duration: All week
- Mechanic: Pets deal 3x damage, pet XP gain 5x, special pet eggs available
- Special Event Egg: "Parade Egg" (100,000 DP) - Higher legendary/mythic rates
- Bonus: Fusion success rate +25%

**Week 4: DOUBLE TROUBLE**
- Duration: All week
- Mechanic: 2x DP from all sources, 2x XP gain
- Special: All egg costs reduced by 50%
- Bonus: Rebirth requirements reduced by 25%

### D. Seasonal Events (4 per year)

**BACK TO SCHOOL (September)**
- Special Zone: "First Day Chaos"
- Exclusive Homework: Syllabus stacks, fresh textbooks
- Limited Pet: "New Backpack" (Legendary, only available during event)
- Limited Tool: "Fresh Pencil Set" (Epic)
- Special Currency: "School Supplies" - trade for exclusive items

**WINTER BREAK (December)**
- Special Zone: "Holiday Homework Mountain"
- Exclusive Homework: Winter essays, holiday projects
- Limited Pet: "Snowball" (Legendary)
- Limited Tool: "Candy Cane Destroyer" (Legendary)
- Special: Gift boxes drop from homework (contain random rewards)

**SPRING CLEANING (April)**
- Special Zone: "The Locker of Forgotten Assignments"
- Exclusive Homework: Old projects, forgotten worksheets, moldy assignments
- Limited Pet: "Dust Bunny" (Epic)
- Limited Tool: "Spring Cleaning Vacuum" (Legendary)
- Special: 3x drops from old homework types

**SUMMER FREEDOM (June)**
- Special Zone: "Summer School Escape"
- Exclusive Homework: Summer reading lists, vacation worksheets
- Limited Pet: "Beach Ball Bouncer" (Legendary)
- Limited Tool: "Water Balloon Launcher" (Mythic - one-time event)
- Special: No summer homework should exist! 5x damage all week

---

## 7. ACHIEVEMENTS/BADGES

### Achievement Categories

#### DESTRUCTION ACHIEVEMENTS (10)

| Badge | Requirement | Reward |
|-------|-------------|--------|
| First Steps | Destroy 10 homework | 100 DP, "Beginner" title |
| Paper Shredder | Destroy 100 homework | 500 DP |
| Assignment Assassin | Destroy 1,000 homework | 2,500 DP, +5% permanent damage |
| Homework Hater | Destroy 10,000 homework | 25,000 DP, Uncommon pet egg |
| Destruction Machine | Destroy 100,000 homework | 250,000 DP, Rare pet egg |
| Annihilation Expert | Destroy 1,000,000 homework | 2,500,000 DP, Epic pet egg, "Expert" title |
| Apocalypse Bringer | Destroy 10,000,000 homework | 25,000,000 DP, Legendary pet egg |
| Cosmic Destroyer | Destroy 100,000,000 homework | 250,000,000 DP, Mythic pet egg, "Cosmic" title |
| Reality Breaker | Destroy 1,000,000,000 homework | 2,500,000,000 DP, exclusive "Reality" aura |
| THE DESTROYER | Destroy 10,000,000,000 homework | 25,000,000,000 DP, "THE DESTROYER" title, rainbow name effect |

#### BOSS ACHIEVEMENTS (5)

| Badge | Requirement | Reward |
|-------|-------------|--------|
| Boss Fighter | Defeat any boss | 5,000 DP |
| Boss Hunter | Defeat 10 bosses | 50,000 DP, +10% boss damage permanent |
| Boss Slayer | Defeat 100 bosses | 500,000 DP, "Slayer" title |
| Boss Nightmare | Defeat 1,000 bosses | 5,000,000 DP, exclusive boss-themed pet |
| Boss Exterminator | Defeat THE PRINCIPAL 100 times | 50,000,000 DP, "Principal's Nightmare" title, golden badge |

#### ZONE ACHIEVEMENTS (5)

| Badge | Requirement | Reward |
|-------|-------------|--------|
| Explorer | Unlock 3 zones | 10,000 DP |
| Adventurer | Unlock 5 zones | 100,000 DP, +10% movement speed |
| World Traveler | Unlock all main zones (1-9) | 1,000,000 DP, "Traveler" title |
| Void Walker | Enter The Void | 10,000,000 DP, exclusive void particles |
| Master of All | Complete all zone challenges | 100,000,000 DP, "Master" title, all-zone damage +25% |

#### REBIRTH ACHIEVEMENTS (5)

| Badge | Requirement | Reward |
|-------|-------------|--------|
| Born Again | Complete first rebirth | 10,000 DP (post-rebirth), "Reborn" title |
| Cycle Breaker | Reach Rebirth 5 | 100,000 DP, +10% rebirth multiplier |
| Eternal Student | Reach Rebirth 10 | 1,000,000 DP, exclusive rebirth pet |
| Time Lord | Reach Rebirth 25 | 10,000,000 DP, "Time Lord" title |
| Infinite Loop | Reach Rebirth 50 | 100,000,000 DP, "Infinite" aura, permanent 2x XP |

#### COLLECTION ACHIEVEMENTS (5)

| Badge | Requirement | Reward |
|-------|-------------|--------|
| Tool Collector | Own 5 different tools | 5,000 DP |
| Arsenal Builder | Own 10 different tools | 50,000 DP, tool inventory expansion |
| Weapon Master | Own all tools | 5,000,000 DP, "Weapon Master" title |
| Pet Lover | Own 5 different pets | 5,000 DP, +1 pet slot |
| Pet Hoarder | Own 15 different pets | 100,000 DP, pet damage +15% |
| Legendary Tamer | Own 3 Legendary pets | 1,000,000 DP |
| Mythic Master | Own a Mythic pet | 10,000,000 DP, "Mythic Master" title |

#### SPECIAL ACHIEVEMENTS (5)

| Badge | Requirement | Reward |
|-------|-------------|--------|
| Speed Demon | Destroy 100 homework in 1 minute | 25,000 DP, permanent +5% speed |
| Critical King | Land 50 critical hits in a row | 50,000 DP, +5% permanent crit |
| Untouchable | Defeat a boss without taking damage (Void only) | 1,000,000 DP, "Untouchable" title |
| Millionaire | Accumulate 1,000,000 DP at once | 100,000 bonus DP |
| Billionaire | Accumulate 1,000,000,000 DP at once | 100,000,000 bonus DP, "Billionaire" badge |
| True Completionist | Earn all other achievements | 1,000,000,000 DP, "Completionist" title, exclusive rainbow aura, unique sound effect on destroy |

### Secret Achievements (Hidden until unlocked)

| Badge | Requirement | Reward |
|-------|-------------|--------|
| Night Owl | Play at 3 AM server time | 10,000 DP, "Night Owl" title |
| Marathon Runner | Play for 10 hours total | 50,000 DP |
| Old Timer | Return after 30+ days away | 100,000 DP, "Returnee" gift box |
| Easter Egg Hunter | Find the hidden classroom message | 25,000 DP, secret pet "???" |
| The One | Deal exactly 1,000,000 damage in one hit | 500,000 DP, "The One" title |

---

## APPENDIX: QUICK REFERENCE TABLES

### Damage Formula
```
Final Damage = Base Tool Damage
               x (1 + Damage Upgrades)
               x Tool Rarity Multiplier
               x (1 + Pet Bonus)
               x Rebirth Multiplier
               x Prestige Multiplier
               x Zone Bonus (if applicable)
               x Critical Multiplier (if crit)
```

### DP Earning Formula
```
DP Earned = Base Homework DP
            x (1 + DP Upgrades)
            x Rebirth DP Multiplier
            x Event Multiplier (if active)
            x Pet DP Bonus
```

### Recommended Progression Path
1. Zones 1-3: Focus on damage upgrades, get Uncommon/Rare pets
2. Zones 4-6: Prioritize Epic tools, level pets to 50+
3. Zones 7-9: Chase Legendary pets, max out key upgrades
4. First Rebirth: Complete at Level 100 with decent tool
5. Rebirths 1-5: Speed-run levels, unlock auto-click
6. Rebirths 5-20: Farm efficiently, prepare for Prestige
7. Post-Prestige: Chase Mythic pets, complete Void zone
8. Endgame: Max Prestige, all achievements, THE DESTROYER'S HAND

---

*Document Version 1.0 - Homework Destroyer Core Mechanics*
*Designed for Roblox Studio implementation*
*Estimated development time for beginner: 2-4 months for core systems*
