# Rojo Setup Guide

This project uses Rojo for syncing code between your editor and Roblox Studio.

## Prerequisites

Install the following tools:

1. **Rojo** - Download from [rojo.space](https://rojo.space/)
2. **Rojo VS Code Extension** - Install from VS Code marketplace
3. **Luau Language Server** - Install from VS Code marketplace
4. **StyLua** (optional) - Code formatter: `cargo install stylua` or download from [releases](https://github.com/JohnnyMorganz/StyLua/releases)

## Quick Start

### 1. Install Rojo Plugin in Roblox Studio

```bash
rojo plugin install
```

### 2. Start Rojo Server

In the project root directory, run:

```bash
rojo serve
```

This will start a development server on port 34872 (default).

### 3. Connect from Roblox Studio

1. Open Roblox Studio
2. Click the **Rojo** plugin button in the toolbar
3. Click **Connect** to sync with the development server

## Project Structure

```
src/
├── ServerScriptService/   # Server-side game logic
├── ServerStorage/         # Server-only assets and modules
├── ReplicatedStorage/     # Shared modules and assets
├── StarterGui/           # UI elements
└── StarterPlayer/        # Player starter scripts
```

## Configuration Files

### default.project.json
The main Rojo configuration that maps your file system to Roblox's DataModel.

### .vscode/settings.json
VS Code settings for:
- Luau language server configuration
- File associations
- Editor formatting rules
- Rojo integration

### .stylua.toml
Code formatting configuration for consistent style across the project.

### selene.toml
Linter configuration for catching common Luau mistakes.

### wally.toml
Package manager configuration for Roblox dependencies.

## Development Workflow

1. **Start Rojo Server**: `rojo serve`
2. **Connect in Studio**: Use the Rojo plugin to connect
3. **Edit Code**: Make changes in VS Code
4. **Auto-sync**: Changes automatically sync to Studio
5. **Test**: Test your changes in Studio

## Building for Production

To build a place file without running the server:

```bash
rojo build -o HomeworkDestroyer.rbxl
```

To build a model file:

```bash
rojo build -o HomeworkDestroyer.rbxm
```

## Common Commands

| Command | Description |
|---------|-------------|
| `rojo serve` | Start development server |
| `rojo build` | Build a place/model file |
| `rojo plugin install` | Install Rojo Studio plugin |
| `rojo plugin uninstall` | Uninstall Rojo Studio plugin |

## Troubleshooting

### Port Already in Use
If port 34872 is already in use:
```bash
rojo serve --port 34873
```

### Connection Issues
1. Ensure Rojo server is running
2. Check firewall settings
3. Verify the plugin is installed in Studio

### Sync Not Working
1. Disconnect and reconnect in Studio
2. Restart the Rojo server
3. Check the terminal for error messages

## Additional Resources

- [Rojo Documentation](https://rojo.space/docs/)
- [Luau Documentation](https://luau-lang.org/)
- [Roblox Creator Documentation](https://create.roblox.com/docs)
- [Wally Package Manager](https://github.com/UpliftGames/wally)
