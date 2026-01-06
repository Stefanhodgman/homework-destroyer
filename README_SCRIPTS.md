# Homework Destroyer - Quick Start Scripts

## 🚀 Available Scripts

### **START_GAME.bat** (RECOMMENDED)
**What it does:**
1. Starts Rojo server in background
2. Opens Roblox Studio with your place file
3. Shows instructions for syncing

**How to use:**
- Double-click `START_GAME.bat`
- Wait for Studio to open
- Click Rojo plugin → Connect → Sync In
- Hit Play!

**When to use:** Every time you want to work on the game

---

### **QUICK_TEST.bat**
**What it does:**
1. Builds your code into the .rbxl file
2. Opens Studio automatically

**How to use:**
- Double-click `QUICK_TEST.bat`
- Wait for Studio to open
- Hit Play immediately!

**When to use:** Quick testing without live sync

---

### **BUILD_TO_FILE.bat**
**What it does:**
- Builds your src/ code into HomeworkDestroyer.rbxl
- Doesn't open Studio

**How to use:**
- Double-click `BUILD_TO_FILE.bat`
- Manually open HomeworkDestroyer.rbxl later

**When to use:** When you want to save a snapshot

---

### **STOP_ROJO.bat**
**What it does:**
- Stops the Rojo server

**How to use:**
- Double-click `STOP_ROJO.bat`

**When to use:** When you're done working

---

## 📋 Typical Workflow

### **Option 1: Live Development (with Rojo)**
```
1. Run START_GAME.bat
2. In Studio: Rojo → Connect → Sync In
3. Edit files in src/ folder
4. Changes auto-sync to Studio
5. When done: Run STOP_ROJO.bat
```

### **Option 2: Quick Test**
```
1. Run QUICK_TEST.bat
2. Studio opens automatically
3. Hit Play
```

---

## 🎮 In-Game Controls

- **Click** - Destroy homework
- **S** - Shop
- **U** - Upgrades
- **P** - Pets
- **H** - Toggle HUD
- **ESC** - Settings

---

## ❓ Troubleshooting

### "Rojo server won't start"
- Make sure `rojo.exe` is in the folder
- Close any existing Rojo servers first

### "Studio won't open"
- Check if Roblox Studio is installed
- Manually open `HomeworkDestroyer.rbxl`

### "Sync button doesn't work"
- Make sure Rojo plugin is installed in Studio
- Check that server shows "localhost:34872"

### "Game has errors in Studio"
- Check Output window for error messages
- Make sure you clicked "Sync In" after connecting

---

## 📁 File Structure

```
homework-destroyer/
├── START_GAME.bat       ← Use this!
├── QUICK_TEST.bat       ← Or this!
├── BUILD_TO_FILE.bat
├── STOP_ROJO.bat
├── HomeworkDestroyer.rbxl
├── rojo.exe
├── default.project.json
└── src/                 ← Your code is here
    ├── ServerScriptService/
    ├── ServerStorage/
    ├── ReplicatedStorage/
    └── StarterGui/
```

---

## 🎯 Next Steps

1. **Double-click START_GAME.bat**
2. Wait for Studio to open
3. Connect Rojo and sync
4. Hit Play and enjoy!

Your game has:
- ✅ Complete UI system
- ✅ Sound effects
- ✅ Visual effects
- ✅ 3D homework models
- ✅ School building
- ✅ 10 zones with progression

**Have fun!** 🎮
