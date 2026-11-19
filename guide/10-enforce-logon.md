# 10 — Enforce at logon

## Objective

Make the debloat a standing invariant rather than a one-time pass. LDPlayer updates re-ship the bloat; a hidden, elevated task re-applies the fix at every logon.

## Register the task

```powershell
$a = New-ScheduledTaskAction -Execute 'powershell.exe' `
  -Argument '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\LDPlayer\reapply-debloat.ps1 -Silent'
$t = New-ScheduledTaskTrigger -AtLogOn
$p = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -RunLevel Highest -LogonType Interactive
$s = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -Hidden
Register-ScheduledTask -TaskName 'LDPlayerDebloatEnforce' -Action $a -Trigger $t -Principal $p -Settings $s -Force
```

`-Silent` is supported by the shipped `reapply-debloat.ps1`; it writes to `C:\LDPlayer\reapply-log.txt` without opening a console.

## Prove it

```powershell
Start-ScheduledTask -TaskName 'LDPlayerDebloatEnforce'
Start-Sleep -Seconds 10
(Get-ScheduledTaskInfo -TaskName 'LDPlayerDebloatEnforce').LastTaskResult   # 0
Get-Content 'C:\LDPlayer\reapply-log.txt' -Tail 8
```

## Inspect / remove

```powershell
Get-ScheduledTask -TaskName 'LDPlayerDebloatEnforce' | Select-Object TaskName, State
Unregister-ScheduledTask -TaskName 'LDPlayerDebloatEnforce' -Confirm:$false
```

## Failure modes

| Symptom | Fix |
|---|---|
| `LastTaskResult` non-zero | Script path wrong, or missing `-Silent` support — re-copy from `scripts/` |
| Task runs but state reverts | Update happened after logon — run `reapply-debloat.ps1` manually |
| Task not visible | Wrong user context — register under the interactive account |

**Next:** [11 — Verify (Windows)](11-verify-windows.md)
