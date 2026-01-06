# Development Guide

## Development Workflow

### ✅ What You CAN Do in PowerShell/Terminal:
1. **Write Lua Scripts** - Create all .lua files in `src/` folder
2. **Version Control** - Git commit/push from command line
3. **Project Organization** - Manage file structure
4. **Code Editing** - Use VS Code or any text editor
5. **Documentation** - Update docs and README

### 🎮 What You NEED Roblox Studio For:
1. **Testing** - Run and test your game
2. **UI Creation** - Build GUI elements visually
3. **3D Modeling** - Create parts, tools, pets
4. **Publishing** - Deploy to Roblox platform
5. **DataStore Testing** - Test save/load systems

---

## Recommended Workflow

### Option 1: Manual Sync (Beginner-Friendly)
```bash
# 1. Write code in src/ folder
code src/ServerScriptService/GameServer.lua

# 2. Open Roblox Studio
# 3. Copy-paste scripts from src/ into Studio
# 4. Test in Studio
# 5. Make changes in Studio
# 6. Copy back to src/ folder
# 7. Commit to git
git add .
git commit -m "Added GameServer script"
git push
```

### Option 2: Rojo (Advanced - Recommended)
Rojo syncs your file system with Roblox Studio in real-time!

**Install Rojo:**
```powershell
# Install from GitHub releases
# https://github.com/rojo-rbx/rojo/releases

# Or use Aftman (Roblox tool manager)
aftman add rojo-rbx/rojo@7.4.1
```

**Use Rojo:**
```bash
# Start Rojo server (syncs files → Studio)
rojo serve

# In Roblox Studio: Install Rojo plugin, click "Connect"
# Now your src/ folder automatically syncs to Studio!
```

---

## Current Project Structure

```
homework-destroyer/
├── src/                          # ← Your Lua code goes here
│   ├── ServerScriptService/
│   │   ├── GameServer.lua
│   │   ├── DataManager.lua
│   │   └── AntiExploit.lua
│   ├── ServerStorage/
│   │   └── Modules/
│   │       ├── PlayerDataTemplate.lua
│   │       ├── UpgradesConfig.lua
│   │       ├── PetsConfig.lua
│   │       └── RebirthConfig.lua
│   ├── ReplicatedStorage/
│   │   ├── Remotes/              # (Create RemoteEvents in Studio)
│   │   └── SharedModules/
│   │       └── FormatNumbers.lua
│   ├── StarterGui/
│   │   └── MainGuiScript.lua
│   └── StarterPlayer/
│       └── StarterPlayerScripts/
│           └── ClickHandler.lua
│
├── docs/                         # Documentation
├── assets/                       # (Coming soon) Models, images, sounds
├── GameDesign.md                 # Main design document
└── README.md                     # Project overview
```

---

## Getting Started with Development

### Step 1: Install Tools (Optional but Recommended)
```powershell
# Install VS Code (if not already)
winget install Microsoft.VisualStudioCode

# Install Roblox LSP extension for VS Code
# Opens VS Code, then: Ctrl+Shift+X → Search "Roblox LSP"
```

### Step 2: Create Your First Script
```bash
# We can create starter scripts from PowerShell!
cd src/ServerScriptService
code GameServer.lua  # Opens in VS Code
```

### Step 3: Development Cycle
```
1. Write code in src/ (PowerShell/VS Code)
   ↓
2. Copy to Roblox Studio (manually or via Rojo)
   ↓
3. Test in Studio (Play button)
   ↓
4. Fix bugs, iterate
   ↓
5. Copy final version back to src/
   ↓
6. Git commit & push
   ↓
7. Repeat!
```

---

## Quick Commands

### Create a new Lua script:
```bash
cd /c/Users/blackbox/Documents/Github/homework-destroyer
code src/ServerScriptService/MyScript.lua
```

### View current structure:
```bash
tree src/ /F  # Windows
find src/    # Git Bash
```

### Commit changes:
```bash
git add .
git commit -m "Your message"
git push
```

---

## VS Code Extensions for Roblox Development

1. **Roblox LSP** - Luau language support
   - Autocomplete for Roblox API
   - Type checking
   - Error detection

2. **Selene** - Lua linter
   - Catches common mistakes
   - Best practices

3. **StyLua** - Code formatter
   - Consistent code style
   - Auto-formatting

Install via VS Code Extensions (Ctrl+Shift+X)

---

## Tips

### ✅ DO:
- Write all scripts in `src/` folder
- Use git for version control
- Test frequently in Roblox Studio
- Keep src/ synced with Studio

### ❌ DON'T:
- Edit only in Studio (hard to version control)
- Forget to copy changes back to src/
- Skip testing before committing

---

## Next Steps

Ready to start coding? I can:
1. Generate the starter scripts (DataManager, GameServer, etc.)
2. Set up a Rojo configuration
3. Create template files for each system
4. Help you set up VS Code with Roblox extensions

What would you like to start with?
