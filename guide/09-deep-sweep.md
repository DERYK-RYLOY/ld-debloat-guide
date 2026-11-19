# 09 — Deep sweep

## Objective

Remove the second telemetry stack, the app-store intercept feed, and the recommendation database that the classic sweep does not cover.

## Targets

| Path | Content |
|---|---|
| `LDPlayer9\upload\` | Huawei OBS crash-telemetry SDK (`ldupload.exe` + DLLs) |
| `ldmutiplayer\bugreport.exe` | Reporter beside the multi-instance manager |
| `Documents\XuanZhi9\Applications\ld_launcher\`, `cpi.data`, `appInfo.txt`, hex-named fetch stamps | LD-store redirect / ad-slot map |
| `LDPlayer9\vms\recommendConfigs\dir_*.dir`, `package_configs_1005*` | Game recommendation DB with ad placements |

`dynamic-key.xml` is kept — it holds smart-keymap data.

## Apply (part of the master script)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\reapply-debloat.ps1
```

Log lines: `vaulted: ...\upload`, `vaulted: ...\ld_launcher`, `vaulted: ...\recommendConfigs\dir_kmps.dir`, etc.

## Verify

```powershell
$LD = 'C:\LDPlayer\LDPlayer9'
Test-Path "$LD\upload"                                  # False
Test-Path "$LD\ldmutiplayer\bugreport.exe"              # False
$rec = "$LD\vms\recommendConfigs"
Get-ChildItem $rec -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -ne 'dynamic-key.xml' }         # no output
$app = Join-Path $env:USERPROFILE 'Documents\XuanZhi9\Applications'
Test-Path "$app\cpi.data"                               # False
Test-Path "$app\ld_launcher"                            # False
```

## Failure modes

| Symptom | Fix |
|---|---|
| Items reappear after launch | The 75-second watcher in `clean-launch.ps1` re-sweeps them |
| Items reappear after update | Logon task re-applies; verify with `verify-debloat.ps1` |
| Path differs on this build | Add the actual vendor folder name to the candidate list in the script |

## Rollback

All items are in `C:\LDPlayer\vault\<run>\` under mirrored subfolders (`upload`, `intercept`, `recommendConfigs`).

**Next:** [10 — Enforce at logon](10-enforce-logon.md)
