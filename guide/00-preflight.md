# 00 — Preflight

## Objective

Establish a known-good install path, elevation, and a restorable baseline before touching anything.

## 1. Resolve the install root

```powershell
$LD = 'C:\LDPlayer\LDPlayer9'   # change if yours lives elsewhere
Test-Path "$LD\ldconsole.exe"   # must print True
Test-Path "$LD\dnplayer.exe"    # must print True
```

All five scripts auto-detect this folder. If detection fails, set `$LD_ROOT` at the top of the script rather than changing its logic.

## 2. Confirm elevation

```powershell
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

Must print `True`. Every mutating script self-elevates; verifiers must be started elevated to read firewall/ACL state.

## 3. Confirm PowerShell version

```powershell
$PSVersionTable.PSVersion.Major   # 5 or higher
```

## 4. Capture a baseline (read-only)

```powershell
Get-ChildItem "$LD" -Force | Sort-Object Name | Select-Object Name, Length, LastWriteTime
Get-ChildItem "$LD\vms\config" -Force | Select-Object Name, Length
Get-Service LDPlayerENSvr -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType
```

Copy the output somewhere outside `C:\LDPlayer`. It is the reference for "what did this step change?"

## 5. Confirm the vault is writable

```powershell
New-Item -ItemType Directory -Force -Path 'C:\LDPlayer\vault' | Out-Null
Test-Path 'C:\LDPlayer\vault'
```

## Failure modes

| Symptom | Fix |
|---|---|
| `Test-Path` false for `ldconsole.exe` | Wrong install path — set `$LD` for this session and `$LD_ROOT` in the scripts |
| Elevation false | Run PowerShell as administrator; verifiers otherwise report false FAILs |
| Vault creation access denied | Run elevated; check ACL on `C:\LDPlayer` |

**Next:** [01 — Install the toolkit](01-install-toolkit.md)
