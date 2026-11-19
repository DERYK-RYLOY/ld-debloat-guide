# 03 — Vault classic bloat

## Objective

Move the launcher's advertising/reporting executables into the vault. Nothing is deleted.

## What the sweep moves

| Path | Reason |
|---|---|
| `LDPlayer9\ldplayerpartner.exe`, `ldplayerpartner2.exe` | Launcher-side ad process |
| `LDPlayer9\bugreport.exe` | Crash/telemetry reporter |
| `ldmutiplayer\bugreport.exe` | Second reporter alongside the manager |
| `LDPlayer9\log\ldpartner.log` | Partner report log |
| `LDPlayer9\dnrepairer.exe` | Built-in repair tool (see recovery note below) |
| `LDPlayer9\LDPlayer_<build>.exe` | Full offline installer payload (~800 MB) |

## Apply

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\reapply-debloat.ps1
```

Expected lines include `vaulted: ...\ldplayerpartner.exe`, `vaulted: ...\dnrepairer.exe`, `vaulted: ...\LDPlayer_*.exe`.

## Verify

```powershell
$LD = 'C:\LDPlayer\LDPlayer9'
Test-Path "$LD\ldplayerpartner.exe"          # False
Test-Path "$LD\dnrepairer.exe"               # False
(Get-ChildItem "$LD" -Filter 'LDPlayer_*.exe' | Measure-Object).Count   # 0
Get-ChildItem 'C:\LDPlayer\vault' -Directory | Sort-Object LastWriteTime -Descending |
  Select-Object -First 1 Name
```

## Recovery note

`dnrepairer.exe` is what the launcher's **Fix** button invokes; `LDPlayer_<build>.exe` is the offline repair installer. Both are vaulted here by design. To use either:

```powershell
$vault = (Get-ChildItem 'C:\LDPlayer\vault' -Directory |
          Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
Copy-Item "$vault\LDPlayer9\dnrepairer.exe" 'C:\LDPlayer\LDPlayer9\dnrepairer.exe'
Copy-Item "$vault\LDPlayer9\LDPlayer_<build>.exe" 'C:\LDPlayer\LDPlayer9\'
```

Restore only when repairing; re-run `reapply-debloat.ps1` afterwards to re-vault them.

## Rollback

Move any single file back from its vault subfolder (layout mirrors the source paths).

**Next:** [04 — Seal the ad cache](04-seal-ad-cache.md)
