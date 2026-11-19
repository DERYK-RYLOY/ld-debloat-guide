# 07 — Disable the telemetry service

## Objective

Stop the auto-start service that brings up launcher plumbing before the user starts anything.

## Service names across builds

`LDPlayerENSvr`, `LDPlayerENSvc`, `LDPlayerServiceEN`

## Apply

```powershell
foreach ($s in 'LDPlayerENSvr','LDPlayerENSvc','LDPlayerServiceEN') {
  $svc = Get-Service $s -ErrorAction SilentlyContinue
  if ($svc) {
    if ($svc.Status -ne 'Stopped') { Stop-Service $s -Force }
    Set-Service $s -StartupType Disabled
  }
}
```

The master script applies the same loop with graceful skips.

## Verify

```powershell
Get-Service LDPlayerENSvr -ErrorAction SilentlyContinue |
  Select-Object Name, Status, StartType
```

Expected: `Stopped / Disabled`. If an update re-registers it as Automatic, the logon task corrects it.

## Failure modes

| Symptom | Fix |
|---|---|
| Access denied | Run elevated |
| Service re-appears Automatic | Update re-registered it — re-run `reapply-debloat.ps1` |
| Emulator fails to start after disabling | Rare build dependency — restore with `Set-Service LDPlayerENSvr -StartupType Manual` and report the build |

## Rollback

```powershell
Set-Service LDPlayerENSvr -StartupType Automatic
Start-Service LDPlayerENSvr
```

**Next:** [08 — Hosts + firewall blocks](08-network-blocks.md)
