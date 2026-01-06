# MCP WORKFLOW - DON'T FORGET THIS

## ✅ CORRECT WAY TO USE MCP

### **Endpoint:**
```
POST http://localhost:8000/inject_command
```

### **Payload Format:**
```json
{
  "action": "execute_script_in_studio",
  "data": {
    "script_code": "YOUR LUA CODE HERE"
  }
}
```

### **How to Execute:**

**Option 1: Python Script (BEST)**
```python
import requests

lua_code = """
print('Your Lua code here')
-- Multi-line works fine
local part = Instance.new('Part')
"""

url = "http://localhost:8000/inject_command"
payload = {
    "action": "execute_script_in_studio",
    "data": {"script_code": lua_code}
}

response = requests.post(url, json=payload, timeout=10)
print(response.text)
```

**Option 2: Direct Python One-Liner**
```bash
cd C:\Users\blackbox\Documents\Github\roblox-mcp
python -c "import requests; requests.post('http://localhost:8000/inject_command', json={'action':'execute_script_in_studio','data':{'script_code':'print(\"Hello\")'}})"
```

---

## ❌ WRONG APPROACHES

### **DON'T:**
- ❌ Suggest "paste into Studio Command Bar"
- ❌ Use curl with escaped JSON (escaping hell)
- ❌ Try to use `/send_command` or `/execute` endpoints
- ❌ Suggest "quick fixes" when MCP is available
- ❌ Make excuses about MCP not working

### **ALWAYS:**
- ✅ Use `/inject_command` endpoint
- ✅ Write Python scripts for complex commands
- ✅ Check MCP server is running at localhost:8000
- ✅ Use proper JSON payload format
- ✅ Let the Studio plugin pick up commands automatically

---

## 🔍 How to Verify MCP is Working

```bash
# Check server is running
curl http://localhost:8000/docs

# Should return HTML for Swagger docs
```

---

## 📝 Example Scripts

### Fix School Brightness
```python
import requests
requests.post('http://localhost:8000/inject_command', json={
    'action': 'execute_script_in_studio',
    'data': {
        'script_code': '''
print('FIXING SCHOOL')
local s=workspace:FindFirstChild('School')
if s then
    for _,p in ipairs(s:GetDescendants()) do
        if p:IsA('BasePart') then
            p.Material=Enum.Material.Brick
            p.Color=Color3.fromRGB(160,82,45)
        end
    end
    print('DONE')
end
        '''
    }
})
```

### Create Zones
```python
import requests
requests.post('http://localhost:8000/inject_command', json={
    'action': 'execute_script_in_studio',
    'data': {
        'script_code': '''
print('CREATING ZONES')
local zones=Instance.new('Folder')
zones.Name='Zones'
zones.Parent=workspace
for i=1,10 do
    local z=Instance.new('Model')
    z.Name='Zone'..i
    z.Parent=zones
    local p=Instance.new('Part')
    p.Name='Platform'
    p.Size=Vector3.new(100,2,100)
    p.Position=Vector3.new(i*150,0,0)
    p.Anchored=true
    p.Color=Color3.fromHSV(i/10,0.6,1)
    p.Parent=z
    z.PrimaryPart=p
    Instance.new('Folder',z).Name='SpawnPoints'
    Instance.new('Folder',z).Name='ActiveHomework'
end
print('DONE')
        '''
    }
})
```

---

## 🎯 REMEMBER

**When user has MCP running:**
1. ALWAYS use `/inject_command`
2. ALWAYS write Python scripts
3. NEVER suggest Studio Command Bar
4. NEVER make excuses

**MCP server location:**
`C:\Users\blackbox\Documents\Github\roblox-mcp`

**Start MCP:**
`START_MCP_SERVER.bat`

**Stop MCP:**
`STOP_MCP_SERVER.bat`
