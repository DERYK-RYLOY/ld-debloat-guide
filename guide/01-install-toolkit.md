# 01 — Install the toolkit

## Objective

Place the five scripts where the guide, the verifiers, and the scheduled task expect them.

## Files

| Script | Role |
|---|---|
| `reapply-debloat.ps1` | Master re-fixer; idempotent; `-Silent` for scheduled use |
| `clean-launch.ps1` | Debloat → launch → delayed re-sweep |
| `android-refresh.ps1` | In-guest re-apply over ADB |
| `verify-debloat.ps1` | Read-only Windows-side audit |
| `verify-android.ps1` | Read-only Android-side audit |

## Copy from the repo root

```powershell
New-Item -ItemType Directory -Force -Path 'C:\LDPlayer' | Out-Null
Copy-Item '.\scripts\reapply-debloat.ps1' 'C:\LDPlayer\reapply-debloat.ps1' -Force
Copy-Item '.\scripts\clean-launch.ps1'    'C:\LDPlayer\clean-launch.ps1' -Force
Copy-Item '.\scripts\android-refresh.ps1' 'C:\LDPlayer\android-refresh.ps1' -Force
Copy-Item '.\scripts\verify-debloat.ps1'  'C:\LDPlayer\verify-debloat.ps1' -Force
Copy-Item '.\scripts\verify-android.ps1'  'C:\LDPlayer\verify-android.ps1' -Force
```

Run this from the repository root (where `scripts\` lives). Overwriting an older copy is expected and safe.

## Syntax-check before first run

```powershell
Get-ChildItem 'C:\LDPlayer\*.ps1' | ForEach-Object {
  $err = $null
  [void][System.Management.Automation.Language.Parser]::ParseFile($_.FullName,[ref]$null,[ref]$err)
  if ($err) { "FAIL $($_.Name): $($err[0].Message)" } else { "OK   $($_.Name)" }
}
```

All five must print `OK`.

## Verify detection

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\reapply-debloat.ps1 -Silent
Get-Content 'C:\LDPlayer\reapply-log.txt' -Tail 3
```

The log's first line must name your install root, e.g. `using install root: C:\LDPlayer\LDPlayer9`.

## Failure modes

| Symptom | Fix |
|---|---|
| `Copy-Item` cannot find source | Wrong working directory — `cd` to the repo root |
| `ERROR: no LDPlayer install ... found` | Set `$LD_ROOT` manually in `reapply-debloat.ps1` |
| Parse errors | Re-copy the script; do not edit line endings by hand |

**Next:** [02 — Inventory & baseline](02-inventory.md)
