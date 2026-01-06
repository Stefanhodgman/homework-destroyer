# Roblox MCP Server Setup Plan (dax8it/roblox-mcp)

## 🎯 Goal
Install and configure the dax8it/roblox-mcp server to enable AI-assisted Roblox Studio development with live manipulation, code execution, and cloud integration.

---

## 📋 Prerequisites Check

### Required Software
- [x] Python 3.10+ (check with `python --version`)
- [ ] `uv` package manager (Python package installer)
- [x] Roblox Studio (already installed)
- [x] Git (already installed)

### Optional (for Cloud Features)
- [ ] Roblox API Key (for DataStores, asset upload, publishing)

---

## 🚀 Installation Steps

### Step 1: Install `uv` Package Manager
**What:** Fast Python package installer (replaces pip)

**Commands:**
```bash
# Windows (PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Verify installation
uv --version
```

**Expected Output:**
```
uv 0.x.x
```

---

### Step 2: Clone the Repository
**What:** Download the MCP server code

**Commands:**
```bash
cd C:\Users\blackbox\Documents\Github
git clone https://github.com/dax8it/roblox-mcp.git
cd roblox-mcp
```

**Expected Result:**
- New folder: `C:\Users\blackbox\Documents\Github\roblox-mcp`
- Contains: Python server code, plugin files, configuration

---

### Step 3: Install Python Dependencies
**What:** Install required Python packages

**Commands:**
```bash
cd C:\Users\blackbox\Documents\Github\roblox-mcp

# Install dependencies from pyproject.toml
uv pip sync pyproject.toml
```

**Expected Output:**
```
Resolved X packages in X.XXs
Installed X packages in X.XXs
```

**Common Issues:**
- If `uv pip sync` fails, try: `uv pip install -r requirements.txt` (if exists)
- If Python version mismatch: Install Python 3.10 or newer

---

### Step 4: Install Roblox Studio Plugin
**What:** Install the companion plugin that connects Studio to the MCP server

**Steps:**
1. **Locate the plugin file:**
   - Look in `roblox-mcp` folder for `.rbxm` or `.rbxmx` file
   - Usually named `MCPPlugin.rbxm` or similar

2. **Install plugin:**
   ```bash
   # Copy plugin to Roblox plugins folder
   cp MCPPlugin.rbxm %LOCALAPPDATA%/Roblox/Plugins/

   # Or manually:
   # 1. Open File Explorer
   # 2. Navigate to: C:\Users\blackbox\AppData\Local\Roblox\Plugins
   # 3. Copy the .rbxm file there
   ```

3. **Verify in Studio:**
   - Open Roblox Studio
   - Go to Plugins tab
   - Should see "MCP" or "Roblox MCP" plugin

---

### Step 5: Configure Roblox Studio Settings
**What:** Enable HTTP requests so plugin can communicate with server

**Steps:**
1. Open Roblox Studio
2. Open your `HomeworkDestroyer.rbxl` place
3. Go to **Home** → **Game Settings** (or press Alt+S)
4. Navigate to **Security** tab
5. Check **"Allow HTTP Requests"**
6. Click **Save**

**Important:** This allows the plugin to communicate with localhost:8000

---

### Step 6: Start the MCP Server
**What:** Run the Python FastAPI server that Claude will connect to

**Commands:**
```bash
cd C:\Users\blackbox\Documents\Github\roblox-mcp

# Start the server
./server.sh

# If server.sh doesn't work on Windows, try:
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

**Expected Output:**
```
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Troubleshooting:**
- If port 8000 is busy: Change port in command or config
- If `server.sh` fails: Check if it has Windows line endings (use `dos2unix` or run Python directly)

---

### Step 7: Configure Claude Code MCP Client
**What:** Tell Claude Code to connect to the Roblox MCP server

**Option A: Automatic (if server provides config)**
```bash
claude mcp add roblox-studio --sse http://localhost:8000/sse
```

**Option B: Manual Configuration**
1. Find your Claude Code MCP config file:
   - Location: `%APPDATA%\.claude\mcp.json` or similar

2. Add this entry:
   ```json
   {
     "mcpServers": {
       "roblox-studio": {
         "type": "sse",
         "url": "http://localhost:8000/sse",
         "timeout": 30000
       }
     }
   }
   ```

3. Restart Claude Code

---

### Step 8: Verify Connection
**What:** Test that all components are communicating

**Steps:**
1. **Check server is running:**
   - Visit http://localhost:8000 in browser
   - Should see API documentation or status page

2. **Check Studio plugin:**
   - Open Studio with HomeworkDestroyer.rbxl
   - Look for plugin in Plugins tab
   - Check Output window for MCP connection messages

3. **Test in Claude Code:**
   - Ask Claude: "List all tools available in Roblox Studio"
   - Should see 15+ tools listed

**Expected Tools:**
- create_part
- delete_instance
- get_scene_tree
- execute_lua
- set_property
- get_output_logs
- etc.

---

## 🔧 Optional: Cloud Integration Setup

### Step 9: Configure Roblox API Key (Optional)
**What:** Enable cloud features (DataStores, publishing, assets)

**Steps:**
1. **Get API Key:**
   - Go to https://create.roblox.com/credentials
   - Create new API key
   - Copy the key

2. **Configure server:**
   - Create `.env` file in `roblox-mcp` folder:
     ```env
     ROBLOX_API_KEY=your_api_key_here
     ROBLOX_UNIVERSE_ID=your_universe_id
     ```

3. **Restart server:**
   ```bash
   # Stop server (Ctrl+C)
   # Start again
   ./server.sh
   ```

**Cloud Features Unlocked:**
- DataStore read/write operations
- Asset upload to Roblox
- Place publishing
- Cloud Lua execution

---

## ✅ Verification Checklist

Before using, verify:

- [ ] `uv` installed and working
- [ ] Repository cloned to `C:\Users\blackbox\Documents\Github\roblox-mcp`
- [ ] Python dependencies installed
- [ ] Plugin file copied to `%LOCALAPPDATA%/Roblox/Plugins/`
- [ ] HTTP Requests enabled in Studio settings
- [ ] Server running on http://localhost:8000
- [ ] Claude Code MCP config updated
- [ ] Plugin appears in Studio Plugins tab
- [ ] Can see MCP tools in Claude Code
- [ ] Test command works (e.g., "get scene tree")

---

## 🎮 Usage Examples

Once setup is complete, you can ask Claude:

### Scene Exploration
```
"Show me the current scene tree in Roblox Studio"
"List all scripts in the ServerStorage folder"
```

### Object Manipulation
```
"Create 10 spawn points in Zone1 folder"
"Set all parts in workspace to Anchored = true"
"Create a folder called 'Zones' with 10 subfolders Zone1 through Zone10"
```

### Code Execution
```
"Execute Lua code to print all service names"
"Run code to spawn a test homework object"
```

### Property Inspection
```
"Get all properties of the Baseplate part"
"Find all parts with Transparency > 0.5"
```

### World Building
```
"Create spawn points for all 10 zones with proper spacing"
"Generate basic zone boundaries as invisible parts"
"Set up player spawn locations for each zone"
```

---

## 🐛 Troubleshooting

### Server Won't Start
**Issue:** `server.sh` fails or Python errors

**Solutions:**
- Check Python version: `python --version` (needs 3.10+)
- Try direct command: `python -m uvicorn main:app --port 8000`
- Check dependencies: `uv pip sync pyproject.toml`
- Look at error logs in console

### Plugin Not Appearing
**Issue:** Plugin doesn't show in Studio

**Solutions:**
- Verify file is in correct location: `%LOCALAPPDATA%\Roblox\Plugins\`
- Check file extension is `.rbxm` or `.rbxmx`
- Restart Roblox Studio completely
- Look for plugin under Plugins tab, not Tools

### Connection Refused
**Issue:** Plugin can't connect to server

**Solutions:**
- Verify server is running: http://localhost:8000
- Check HTTP Requests enabled in Game Settings
- Check Windows Firewall isn't blocking port 8000
- Try different port if 8000 is busy

### Claude Can't See Tools
**Issue:** MCP tools not available in Claude

**Solutions:**
- Verify MCP config file has correct entry
- Check server URL: http://localhost:8000/sse
- Restart Claude Code after config change
- Check server logs for connection attempts

---

## 📁 File Structure After Setup

```
C:\Users\blackbox\Documents\Github\
├── homework-destroyer/          # Your game project
│   ├── src/
│   ├── HomeworkDestroyer.rbxl
│   └── ...
└── roblox-mcp/                  # MCP Server
    ├── main.py                  # FastAPI server
    ├── pyproject.toml           # Dependencies
    ├── server.sh                # Start script
    ├── MCPPlugin.rbxm           # Studio plugin
    └── .env                     # API keys (optional)

C:\Users\blackbox\AppData\Local\Roblox\Plugins\
└── MCPPlugin.rbxm               # Installed plugin
```

---

## 🎯 Next Steps After Setup

1. **Test basic commands:**
   - Ask Claude to explore your workspace
   - Try creating simple objects

2. **Build game world:**
   - Use MCP to create zone folders
   - Generate spawn points automatically
   - Set up zone boundaries

3. **Integrate with development:**
   - Use for rapid prototyping
   - Bulk operations on game objects
   - Testing and debugging

---

## 📚 Resources

- **Repository:** https://github.com/dax8it/roblox-mcp
- **MCP Documentation:** https://modelcontextprotocol.io/
- **Roblox API Docs:** https://create.roblox.com/docs/
- **UV Package Manager:** https://github.com/astral-sh/uv

---

## 🔄 Workflow Integration

### Daily Development Workflow:
1. Start MCP server: `cd roblox-mcp && ./server.sh`
2. Open Roblox Studio with your place
3. Work with Claude Code to build/modify game
4. Server stays running in background
5. Stop server when done: Ctrl+C

### With Rojo Workflow:
1. Keep MCP server running
2. Use Claude to modify workspace (zones, spawns, etc.)
3. Use Rojo for code sync (scripts, modules)
4. MCP handles 3D world building
5. Rojo handles code management

---

**Status:** Ready to begin installation
**Estimated Time:** 15-20 minutes
**Difficulty:** Medium

---

*Last Updated: 2026-01-06*
*For: Homework Destroyer Game Development*
