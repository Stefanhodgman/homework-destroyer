# Quick Fix: Rojo Version Mismatch

## Problem
```
Your plugin: 7.6.0-Boatly (protocol 5)
Your server: 7.6.1 (protocol 4)
```

They don't match! 😱

---

## ⚡ FASTEST FIX (30 seconds)

### Option 1: Update Rojo Server

1. **Download latest Rojo:**
   - Go to: https://github.com/rojo-rbx/rojo/releases/latest
   - Download: `rojo-X.X.X-windows.zip`

2. **Extract and replace:**
   - Extract `rojo.exe` from the zip
   - Copy it to: `C:\Users\blackbox\Documents\Github\homework-destroyer\`
   - Replace the old `rojo.exe`

3. **Verify:**
   ```bash
   rojo.exe --version
   ```
   Should show version 7.4.0 or newer

4. **Run game:**
   ```
   Double-click START_GAME.bat
   ```

---

### Option 2: Use the Auto-Fix Script

1. **Run the fix script:**
   ```
   Double-click FIX_ROJO_VERSION.bat
   ```

2. **Press 'A' for automatic download**

3. **Wait for download to complete**

4. **Run START_GAME.bat**

---

## 🔍 Alternative: Downgrade Plugin

If updating server doesn't work, downgrade your Roblox Studio plugin:

1. **Remove current plugin:**
   - In Studio: Plugins → Manage Plugins
   - Find "Rojo" and uninstall

2. **Install matching version:**
   - Go to: https://github.com/rojo-rbx/rojo/releases/tag/v7.6.1
   - Download: `Rojo.rbxm`
   - In Studio: Plugins → Folder → Install from file

---

## ✅ How to Verify It's Fixed

After updating, you should see in Studio:
```
Connected to Rojo dev server (localhost:34872)
Protocol version: 4 (matching!)
```

No more error! 🎉

---

## 🎮 Then Start Your Game

```
START_GAME.bat → Sync → Play!
```
