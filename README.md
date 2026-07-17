# Role Check Timer

A small World of Warcraft addon that shows a movable 30-second countdown when a Dungeon Finder role check appears.

It does **not** choose a role or accept the role check for you.

## Quick installation on Windows

1. Download or clone this repository.
2. Open PowerShell in the repository folder.
3. Run:

   ```powershell
   .\Install.ps1
   ```

The script searches the common World of Warcraft install locations and copies the addon files into:

`World of Warcraft\_retail_\Interface\AddOns\RoleCheckTimer\`

For a custom installation location, provide the main World of Warcraft folder or the `_retail_` folder:

```powershell
.\Install.ps1 -WowPath "D:\Games\World of Warcraft"
```

You may need to allow the script for the current PowerShell session:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Install.ps1
```

## Manual installation

1. Exit World of Warcraft.
2. Download or clone this repository.
3. Put the addon folder in:

   `World of Warcraft\_retail_\Interface\AddOns\RoleCheckTimer\`

4. Make sure the folder contains:

   - `RoleCheckTimer.toc`
   - `RoleCheckTimer.lua`

5. Start WoW and enable **Role Check Timer** on the AddOns screen.

## Commands

- `/rct test` — shows a 30-second test timer.
- `/rct stop` — hides the timer.
- `/rct reset` — resets the timer position.

Drag the timer with the left mouse button while it is visible.

## Notes

- The timer begins when your client receives `LFG_ROLE_CHECK_SHOW`.
- Accept with a small safety margin rather than waiting until exactly `0.0`.
- If WoW marks it out of date after a minor patch, enable **Load out of date AddOns**.
