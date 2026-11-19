# 13 — Maintenance

## Objective

Keep the invariant after updates without redoing the setup.

## Launch path

Use the wrapper instead of the stock shortcut:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\clean-launch.ps1
```

It runs `reapply-debloat.ps1`, launches index 0, then spawns a detached watcher that re-sweeps ~75 seconds later (catching the launch-time ad-feed download).

Optional desktop shortcut target:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\LDPlayer\clean-launch.ps1
```

## After each LDPlayer update

```powershell
Start-ScheduledTask -TaskName 'LDPlayerDebloatEnforce'
Start-Sleep -Seconds 15
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-debloat.ps1
& 'C:\LDPlayer\LDPlayer9\adb.exe' devices
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-android.ps1
```

An update typically resets: the telemetry service to Automatic, the timestamps to now, the ad feed, ADB debugging, and the in-guest HOME. The commands above correct the first four automatically; ADB/HOME need step 12.

## What persists vs what is restored

| Persists | Restored by update |
|---|---|
| Hosts fence, firewall rules, service start type | Launcher bloat executables |
| Cache deny-write ACE | Ad feed files, recommendation DB |
| Telemetry pins (after reapply) | ADB debugging flag, in-guest HOME |
| Vault contents | `dnrepairer.exe` / installer stub |

## Vault lifecycle

```powershell
Get-ChildItem 'C:\LDPlayer\vault' -Directory |
  Sort-Object LastWriteTime | Select-Object Name, LastWriteTime
```

Keep vaults until at least one clean update cycle has passed. Delete only after verifying that nothing needed is inside:

```powershell
Remove-Item 'C:\LDPlayer\vault' -Recurse -Force
```

## Recovery path

The sweep vaults the repair tool and offline installer. To repair an update-broken install:

```powershell
$v = (Get-ChildItem 'C:\LDPlayer\vault' -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
Copy-Item "$v\LDPlayer9\dnrepairer.exe" 'C:\LDPlayer\LDPlayer9\dnrepairer.exe'
Copy-Item "$v\LDPlayer9\LDPlayer_<build>.exe" 'C:\LDPlayer\LDPlayer9\'
```

Then use the launcher's **Fix** button or run the offline installer. Re-run `reapply-debloat.ps1` afterwards.

## Exit criteria

```text
verify-debloat.ps1  -> RESULT: ALL CHECKS PASSED   (exit 0)
verify-android.ps1  -> RESULT: ALL ANDROID CHECKS PASSED (exit 0, emulator attached)
```

**Next:** [Command index](../reference/commands.md) · [Troubleshooting](../reference/troubleshooting.md)
